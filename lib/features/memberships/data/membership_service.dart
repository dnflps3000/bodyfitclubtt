import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/membership.dart';
import '../domain/membership_plan.dart';

/* Obsahuje načítanie plánov permanentiek a aktívnych permanentiek používateľa. */
class MembershipService {
  MembershipService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<MembershipPlan>> watchActiveMembershipPlans() {
    return _firestore
        .collection('membershipPlans')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final plans = snapshot.docs
              .map(MembershipPlan.fromFirestore)
              .toList();

          plans.sort((a, b) => a.price.compareTo(b.price));

          return plans;
        });
  }

  Stream<List<Membership>> watchMyActiveMemberships() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('memberships')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
          final memberships = snapshot.docs.map(Membership.fromFirestore).where(
            (membership) {
              return membership.isValidNow && membership.hasRemainingEntries;
            },
          ).toList();

          memberships.sort((a, b) {
            final firstValidUntil = a.validUntil;
            final secondValidUntil = b.validUntil;

            if (firstValidUntil == null && secondValidUntil == null) {
              return 0;
            }

            if (firstValidUntil == null) {
              return 1;
            }

            if (secondValidUntil == null) {
              return -1;
            }

            return firstValidUntil.compareTo(secondValidUntil);
          });

          return memberships;
        });
  }

  Future<void> assignMembershipToUser({
    required MembershipPlan plan,
    required String userId,
    required User currentUser,
  }) async {
    final now = _startOfToday();
    final validUntil = _validUntilForPlan(plan);

    final userRef = _firestore.collection('users').doc(userId);
    final planRef = _firestore.collection('membershipPlans').doc(plan.id);
    final createdByRef = _firestore.collection('users').doc(currentUser.uid);

    await _firestore.collection('memberships').add({
      'userId': userId,
      'userRef': userRef,
      'planId': plan.id,
      'planRef': planRef,
      'planName': plan.name,
      'entriesTotal': plan.entriesTotal,
      'entriesRemaining': plan.entriesTotal,
      'entriesReserved': plan.entriesTotal == null ? null : 0,
      'entriesPerDay': plan.entriesPerDay,
      'validFrom': Timestamp.fromDate(now),
      'validUntil': Timestamp.fromDate(validUntil),
      'status': 'active',
      'paymentStatus': 'manual',
      'price': plan.price,
      'currency': plan.currency,
      'createdBy': currentUser.uid,
      'createdByRef': createdByRef,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createMembershipAfterPayment({
    required MembershipPlan plan,
    required User currentUser,
  }) async {
    final now = _startOfToday();
    final validUntil = _validUntilForPlan(plan);

    final userRef = _firestore.collection('users').doc(currentUser.uid);
    final planRef = _firestore.collection('membershipPlans').doc(plan.id);

    await _firestore.collection('memberships').add({
      'userId': currentUser.uid,
      'userRef': userRef,
      'planId': plan.id,
      'planRef': planRef,
      'planName': plan.name,
      'entriesTotal': plan.entriesTotal,
      'entriesRemaining': plan.entriesTotal,
      'entriesReserved': plan.entriesTotal == null ? null : 0,
      'entriesPerDay': plan.entriesPerDay,
      'validFrom': Timestamp.fromDate(now),
      'validUntil': Timestamp.fromDate(validUntil),
      'status': 'active',
      'paymentStatus': 'paid',
      'price': plan.price,
      'currency': plan.currency,
      'createdBy': currentUser.uid,
      'createdByRef': userRef,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Membership>> watchMyMemberships() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('memberships')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          final memberships = snapshot.docs
              .map(Membership.fromFirestore)
              .toList();

          memberships.sort((a, b) {
            final firstValidUntil = a.validUntil;
            final secondValidUntil = b.validUntil;

            if (firstValidUntil == null && secondValidUntil == null) {
              return 0;
            }

            if (firstValidUntil == null) {
              return 1;
            }

            if (secondValidUntil == null) {
              return -1;
            }

            return secondValidUntil.compareTo(firstValidUntil);
          });

          return memberships;
        });
  }

  Stream<List<Membership>> watchAllMemberships() {
    return _firestore.collection('memberships').snapshots().map((snapshot) {
      final memberships = snapshot.docs.map(Membership.fromFirestore).toList();

      memberships.sort((a, b) {
        final firstValidUntil = a.validUntil;
        final secondValidUntil = b.validUntil;

        if (firstValidUntil == null && secondValidUntil == null) {
          return 0;
        }

        if (firstValidUntil == null) {
          return 1;
        }

        if (secondValidUntil == null) {
          return -1;
        }

        return secondValidUntil.compareTo(firstValidUntil);
      });

      return memberships;
    });
  }

  Future<void> updateMembershipByAdmin({
    required Membership membership,
    required int? entriesRemaining,
    required String status,
    required User currentUser,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'updatedBy': currentUser.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (membership.entriesTotal != null && entriesRemaining != null) {
      updates['entriesRemaining'] = entriesRemaining;
    }

    await _firestore
        .collection('memberships')
        .doc(membership.id)
        .set(updates, SetOptions(merge: true));
  }

  Future<int> cancelReservedReservationsForMembership({
    required Membership membership,
    required User currentUser,
  }) async {
    final reservationsSnapshot = await _firestore
        .collection('reservations')
        .where('membershipId', isEqualTo: membership.id)
        .where('status', isEqualTo: 'active')
        .where('entryStatus', isEqualTo: 'reserved')
        .get();

    var cancelledCount = 0;

    for (final reservationDocument in reservationsSnapshot.docs) {
      final reservationData = reservationDocument.data();
      final trainingSessionId =
          reservationData['trainingSessionId'] as String? ?? '';

      if (trainingSessionId.isEmpty) {
        continue;
      }

      final reservationRef = _firestore
          .collection('reservations')
          .doc(reservationDocument.id);

      final sessionRef = _firestore
          .collection('trainingSessions')
          .doc(trainingSessionId);

      final membershipRef = _firestore
          .collection('memberships')
          .doc(membership.id);

      await _firestore.runTransaction((transaction) async {
        final reservationSnapshot = await transaction.get(reservationRef);
        final sessionSnapshot = await transaction.get(sessionRef);
        final membershipSnapshot = await transaction.get(membershipRef);

        if (!reservationSnapshot.exists) {
          return;
        }

        final currentReservationData = reservationSnapshot.data() ?? {};
        final reservationStatus =
            currentReservationData['status'] as String? ?? '';
        final entryStatus =
            currentReservationData['entryStatus'] as String? ?? '';

        if (reservationStatus != 'active' || entryStatus != 'reserved') {
          return;
        }

        if (sessionSnapshot.exists) {
          final sessionData = sessionSnapshot.data() ?? {};
          final reservedCount = sessionData['reservedCount'] as int? ?? 0;
          final newReservedCount = reservedCount > 0 ? reservedCount - 1 : 0;

          transaction.update(sessionRef, {
            'reservedCount': newReservedCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        if (membershipSnapshot.exists && membership.entriesTotal != null) {
          final membershipData = membershipSnapshot.data() ?? {};
          final entriesReserved =
              membershipData['entriesReserved'] as int? ?? 0;
          final newEntriesReserved = entriesReserved > 0
              ? entriesReserved - 1
              : 0;

          transaction.update(membershipRef, {
            'entriesReserved': newEntriesReserved,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        transaction.update(reservationRef, {
          'status': 'cancelled',
          'entryStatus': 'released',
          'cancelledBy': currentUser.uid,
          'cancelledAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      cancelledCount++;
    }

    return cancelledCount;
  }

  Future<void> cancelReservedReservationForMembership({
    required Membership membership,
    required MembershipUsageItem reservation,
    required User currentUser,
  }) async {
    final reservationRef = _firestore
        .collection('reservations')
        .doc(reservation.reservationId);

    final sessionRef = _firestore
        .collection('trainingSessions')
        .doc(reservation.trainingSessionId);

    final membershipRef = _firestore
        .collection('memberships')
        .doc(membership.id);

    await _firestore.runTransaction((transaction) async {
      final reservationSnapshot = await transaction.get(reservationRef);
      final sessionSnapshot = await transaction.get(sessionRef);
      final membershipSnapshot = await transaction.get(membershipRef);

      if (!reservationSnapshot.exists) {
        throw Exception('reservation-not-found');
      }

      final reservationData = reservationSnapshot.data() ?? {};
      final reservationStatus = reservationData['status'] as String? ?? '';
      final entryStatus = reservationData['entryStatus'] as String? ?? '';
      final reservationMembershipId =
          reservationData['membershipId'] as String? ?? '';
      final reservationTrainingSessionId =
          reservationData['trainingSessionId'] as String? ?? '';

      if (reservationMembershipId != membership.id) {
        throw Exception('reservation-membership-mismatch');
      }

      if (reservationTrainingSessionId != reservation.trainingSessionId) {
        throw Exception('reservation-session-mismatch');
      }

      if (reservationStatus != 'active' || entryStatus != 'reserved') {
        throw Exception('reservation-not-active');
      }

      if (sessionSnapshot.exists) {
        final sessionData = sessionSnapshot.data() ?? {};
        final reservedCount = sessionData['reservedCount'] as int? ?? 0;
        final newReservedCount = reservedCount > 0 ? reservedCount - 1 : 0;

        transaction.update(sessionRef, {
          'reservedCount': newReservedCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (membershipSnapshot.exists && membership.entriesTotal != null) {
        final membershipData = membershipSnapshot.data() ?? {};
        final entriesReserved = membershipData['entriesReserved'] as int? ?? 0;
        final newEntriesReserved = entriesReserved > 0
            ? entriesReserved - 1
            : 0;

        transaction.update(membershipRef, {
          'entriesReserved': newEntriesReserved,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.update(reservationRef, {
        'status': 'cancelled',
        'entryStatus': 'released',
        'cancelledBy': currentUser.uid,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<MembershipUsageSummary> loadMembershipUsage(
    Membership membership,
  ) async {
    final reservationsSnapshot = await _firestore
        .collection('reservations')
        .where('membershipId', isEqualTo: membership.id)
        .get();

    final allocatedReservations = <MembershipUsageItem>[];
    final usedEntries = <MembershipUsageItem>[];

    for (final reservationDocument in reservationsSnapshot.docs) {
      final reservationData = reservationDocument.data();

      final trainingSessionId =
          reservationData['trainingSessionId'] as String? ?? '';

      if (trainingSessionId.isEmpty) {
        continue;
      }

      final sessionDocument = await _firestore
          .collection('trainingSessions')
          .doc(trainingSessionId)
          .get();

      final sessionData = sessionDocument.data();

      if (sessionData == null) {
        continue;
      }

      final trainingTypeId = sessionData['trainingTypeId'] as String? ?? '';

      String trainingName = 'Tréning';

      if (trainingTypeId.isNotEmpty) {
        final trainingTypeDocument = await _firestore
            .collection('trainingTypes')
            .doc(trainingTypeId)
            .get();

        final trainingTypeData = trainingTypeDocument.data();

        trainingName = trainingTypeData?['name'] as String? ?? trainingName;
      }

      final startTime = (sessionData['startTime'] as Timestamp?)?.toDate();
      final endTime = (sessionData['endTime'] as Timestamp?)?.toDate();

      if (startTime == null || endTime == null) {
        continue;
      }

      final status = reservationData['status'] as String? ?? '';
      final entryStatus = reservationData['entryStatus'] as String? ?? '';

      final item = MembershipUsageItem(
        reservationId: reservationDocument.id,
        trainingSessionId: trainingSessionId,
        trainingName: trainingName,
        startTime: startTime,
        endTime: endTime,
        status: status,
        entryStatus: entryStatus,
      );

      if (status == 'active' && entryStatus == 'reserved') {
        allocatedReservations.add(item);
      }

      if (entryStatus == 'used') {
        usedEntries.add(item);
      }
    }

    allocatedReservations.sort((a, b) => a.startTime.compareTo(b.startTime));
    usedEntries.sort((a, b) => b.startTime.compareTo(a.startTime));

    return MembershipUsageSummary(
      allocatedReservations: allocatedReservations,
      usedEntries: usedEntries,
    );
  }

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _validUntilForPlan(MembershipPlan plan) {
    final start = _startOfToday();
    final lastValidDay = start.add(Duration(days: plan.validityDays - 1));

    return DateTime(
      lastValidDay.year,
      lastValidDay.month,
      lastValidDay.day,
      23,
      59,
      59,
    );
  }
}

class MembershipUsageSummary {
  const MembershipUsageSummary({
    required this.allocatedReservations,
    required this.usedEntries,
  });

  final List<MembershipUsageItem> allocatedReservations;
  final List<MembershipUsageItem> usedEntries;
}

class MembershipUsageItem {
  const MembershipUsageItem({
    required this.reservationId,
    required this.trainingSessionId,
    required this.trainingName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.entryStatus,
  });

  final String reservationId;
  final String trainingSessionId;
  final String trainingName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String entryStatus;
}
