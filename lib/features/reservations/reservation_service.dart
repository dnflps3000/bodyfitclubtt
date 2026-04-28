import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../schedule/training_session.dart';
import 'reservation.dart';

/* Obsahuje logiku rezervovania tréningov a načítania rezervácií
   prihláseného používateľa. */
class ReservationService {
  ReservationService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _dateId(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<DocumentReference<Map<String, dynamic>>?> _findUsableMembershipRef({
    required String userId,
    required DateTime sessionStartTime,
  }) async {
    final now = DateTime.now();

    final snapshot = await _firestore
        .collection('memberships')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    final memberships = snapshot.docs.where((document) {
      final data = document.data();

      final validFrom = (data['validFrom'] as Timestamp?)?.toDate();
      final validUntil = (data['validUntil'] as Timestamp?)?.toDate();

      if (validFrom == null || validUntil == null) {
        return false;
      }

      if (now.isBefore(validFrom) || now.isAfter(validUntil)) {
        return false;
      }

      if (sessionStartTime.isBefore(validFrom) ||
          sessionStartTime.isAfter(validUntil)) {
        return false;
      }

      return true;
    }).toList();

    memberships.sort((a, b) {
      final aPlanId = a.data()['planId'] as String? ?? '';
      final bPlanId = b.data()['planId'] as String? ?? '';

      int priority(String planId) {
        if (planId == 'same_day_next_entry') {
          return 3;
        }

        if (planId == 'single_entry' || planId == 'single_entry_discount') {
          return 2;
        }

        return 1;
      }

      return priority(aPlanId).compareTo(priority(bPlanId));
    });

    for (final document in memberships) {
      final data = document.data();

      final entriesTotal = data['entriesTotal'] as int?;
      final entriesRemaining = data['entriesRemaining'] as int?;
      final entriesReserved = data['entriesReserved'] as int? ?? 0;
      final entriesPerDay = data['entriesPerDay'] as int?;

      if (entriesTotal != null) {
        final availableEntries = (entriesRemaining ?? 0) - entriesReserved;

        if (availableEntries > 0) {
          return document.reference;
        }

        continue;
      }

      if (entriesPerDay != null) {
        final sessionDateId = _dateId(sessionStartTime);

        final existingReservationSnapshot = await _firestore
            .collection('reservations')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'active')
            .where('reservationDateId', isEqualTo: sessionDateId)
            .limit(1)
            .get();

        if (existingReservationSnapshot.docs.isEmpty) {
          return document.reference;
        }
      }
    }

    return null;
  }
  
  Stream<List<Reservation>> watchMyReservations() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('reservations')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final reservations =
          snapshot.docs.map(Reservation.fromFirestore).toList();

      reservations.sort((a, b) {
        final firstCreatedAt = a.createdAt;
        final secondCreatedAt = b.createdAt;

        if (firstCreatedAt == null && secondCreatedAt == null) {
          return 0;
        }

        if (firstCreatedAt == null) {
          return 1;
        }

        if (secondCreatedAt == null) {
          return -1;
        }

        return secondCreatedAt.compareTo(firstCreatedAt);
      });

      return reservations;
    });
  }

  Future<void> reserveTrainingSession({
    required TrainingSession session,
    required User currentUser,
  }) async {
    final sessionRef =
        _firestore.collection('trainingSessions').doc(session.id);

    final userRef = _firestore.collection('users').doc(currentUser.uid);

    final membershipRef = await _findUsableMembershipRef(
      userId: currentUser.uid,
      sessionStartTime: session.startTime,
    );

    if (membershipRef == null) {
      throw Exception('no-available-membership-entry');
    }

    final reservationId = '${session.id}_${currentUser.uid}';
    final reservationRef =
        _firestore.collection('reservations').doc(reservationId);

    await _firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);
      final reservationSnapshot = await transaction.get(reservationRef);
      final membershipSnapshot = await transaction.get(membershipRef);

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final sessionData = sessionSnapshot.data() ?? {};

      final isActive = sessionData['isActive'] as bool? ?? false;
      final status = sessionData['status'] as String? ?? '';
      final capacity = sessionData['capacity'] as int? ?? 0;
      final reservedCount = sessionData['reservedCount'] as int? ?? 0;
      final startTime = (sessionData['startTime'] as Timestamp?)?.toDate();
      final trainerId = sessionData['trainerId'] as String? ?? '';

      if (trainerId == currentUser.uid) {
        throw Exception('trainer-cannot-reserve-own-session');
      }

      if (startTime == null || !startTime.isAfter(DateTime.now())) {
        throw Exception('training-session-already-started');
      }

      if (!isActive || status != 'scheduled') {
        throw Exception('training-session-not-available');
      }

      if (reservedCount >= capacity) {
        throw Exception('training-session-full');
      }

      if (reservationSnapshot.exists) {
        final reservationData = reservationSnapshot.data() ?? {};
        final reservationStatus =
            reservationData['status'] as String? ?? 'active';

        if (reservationStatus == 'active') {
          throw Exception('reservation-already-exists');
        }
      }

      if (!membershipSnapshot.exists) {
        throw Exception('membership-not-found');
      }

      final membershipData = membershipSnapshot.data() ?? {};

      final membershipStatus = membershipData['status'] as String? ?? '';
      final membershipEntriesTotal = membershipData['entriesTotal'] as int?;
      final membershipEntriesRemaining =
          membershipData['entriesRemaining'] as int?;
      final membershipEntriesReserved =
          membershipData['entriesReserved'] as int? ?? 0;

      if (membershipStatus != 'active') {
        throw Exception('membership-not-active');
      }

      if (membershipEntriesTotal != null) {
        final availableEntries =
            (membershipEntriesRemaining ?? 0) - membershipEntriesReserved;

        if (availableEntries <= 0) {
          throw Exception('no-available-membership-entry');
        }

        transaction.update(membershipRef, {
          'entriesReserved': membershipEntriesReserved + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(
        reservationRef,
        {
          'userId': currentUser.uid,
          'userRef': userRef,
          'trainingSessionId': session.id,
          'trainingSessionRef': sessionRef,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'membershipId': membershipRef.id,
          'membershipRef': membershipRef,
          'entryStatus': 'reserved',
          'reservationDateId': _dateId(startTime),
        },
        SetOptions(merge: true),
      );

      transaction.update(sessionRef, {
        'reservedCount': reservedCount + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelReservation({
    required String reservationId,
    required String trainingSessionId,
  }) async {
    final reservationRef =
        _firestore.collection('reservations').doc(reservationId);

    final sessionRef =
        _firestore.collection('trainingSessions').doc(trainingSessionId);

    await _firestore.runTransaction((transaction) async {
      final reservationSnapshot = await transaction.get(reservationRef);
      final sessionSnapshot = await transaction.get(sessionRef);

      final reservationDataForMembership = reservationSnapshot.data();
      final membershipRef =
          reservationDataForMembership?['membershipRef']
              as DocumentReference<Map<String, dynamic>>?;

      final membershipSnapshot =
          membershipRef == null ? null : await transaction.get(membershipRef);

      if (!reservationSnapshot.exists) {
        throw Exception('reservation-not-found');
      }

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final reservationData = reservationSnapshot.data() ?? {};
      final sessionData = sessionSnapshot.data() ?? {};

      final reservationStatus =
          reservationData['status'] as String? ?? 'active';

      if (reservationStatus != 'active') {
        throw Exception('reservation-not-active');
      }

      final reservedCount = sessionData['reservedCount'] as int? ?? 0;
      final newReservedCount = reservedCount > 0 ? reservedCount - 1 : 0;

      final entryStatus = reservationData['entryStatus'] as String? ?? '';

      if (membershipRef != null &&
          membershipSnapshot != null &&
          membershipSnapshot.exists &&
          entryStatus == 'reserved') {
        final membershipData = membershipSnapshot.data() ?? {};
        final entriesTotal = membershipData['entriesTotal'] as int?;
        final entriesReserved = membershipData['entriesReserved'] as int? ?? 0;

        if (entriesTotal != null) {
          final newEntriesReserved =
              entriesReserved > 0 ? entriesReserved - 1 : 0;

          transaction.update(membershipRef, {
            'entriesReserved': newEntriesReserved,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      transaction.update(reservationRef, {
        'status': 'cancelled',
        'entryStatus': 'released',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(sessionRef, {
        'reservedCount': newReservedCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}