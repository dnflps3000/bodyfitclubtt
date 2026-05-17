import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/membership_constants.dart';
import '../../../core/theme/app_texts.dart';
import '../../audit/data/audit_log_service.dart';
import '../../schedule/domain/training_session.dart';
import '../domain/reservation.dart';

/* Obsahuje logiku rezervovania tréningov a načítania rezervácií
   prihláseného používateľa. */
class ReservationService {
  ReservationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final AuditLogService _auditLogService = AuditLogService();

  String _dateId(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _displayNameFromUserData(Map<String, dynamic> data) {
    final publicName = data['publicName'] as String? ?? '';
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final displayName = data['displayName'] as String? ?? '';
    final email = data['email'] as String? ?? '';

    if (publicName.trim().isNotEmpty) {
      return publicName.trim();
    }

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    if (displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    if (email.trim().isNotEmpty) {
      return email.trim();
    }

    return AppTexts.unknownUser;
  }

  // ignore: unused_element
  bool _isTrainerQrScanAllowed({
    required DateTime sessionStartTime,
    required DateTime now,
  }) {
    final scanWindowStart = sessionStartTime.subtract(
      const Duration(minutes: 30),
    );

    final isSameDay =
        sessionStartTime.year == now.year &&
        sessionStartTime.month == now.month &&
        sessionStartTime.day == now.day;

    if (!isSameDay) {
      return false;
    }

    return !now.isBefore(scanWindowStart);
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
        final planId = data['planId'] as String? ?? '';
        final sessionDateId = _dateId(sessionStartTime);

        final existingReservationSnapshot = await _firestore
            .collection('reservations')
            .where('userId', isEqualTo: userId)
            .where('reservationDateId', isEqualTo: sessionDateId)
            .get();

        final activeReservationsForDay = existingReservationSnapshot.docs.where(
          (reservationDocument) {
            final reservationData = reservationDocument.data();
            final reservationStatus =
                reservationData['status'] as String? ?? 'active';

            return reservationStatus != 'cancelled';
          },
        ).length;

        final activeBaseReservationsForDay = existingReservationSnapshot.docs
            .where((reservationDocument) {
              final reservationData = reservationDocument.data();
              final reservationStatus =
                  reservationData['status'] as String? ?? 'active';
              final reservationMembershipPlanId =
                  reservationData['membershipPlanId'] as String?;

              return reservationStatus != 'cancelled' &&
                  reservationMembershipPlanId !=
                      MembershipPlanIds.sameDayNextEntry;
            })
            .length;

        if (planId == MembershipPlanIds.sameDayNextEntry) {
          if (activeBaseReservationsForDay >= 1) {
            return document.reference;
          }

          continue;
        }

        if (activeReservationsForDay < entriesPerDay) {
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
          final reservations = snapshot.docs
              .map(Reservation.fromFirestore)
              .toList();

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
    final sessionRef = _firestore
        .collection('trainingSessions')
        .doc(session.id);

    final userRef = _firestore.collection('users').doc(currentUser.uid);

    final trainingTypeRef = _firestore
        .collection('trainingTypes')
        .doc(session.trainingTypeId);

    final trainerRef = _firestore.collection('users').doc(session.trainerId);

    final membershipRef = await _findUsableMembershipRef(
      userId: currentUser.uid,
      sessionStartTime: session.startTime,
    );

    if (membershipRef == null) {
      throw Exception('no-available-membership-entry');
    }

    final reservationId = '${session.id}_${currentUser.uid}';
    final reservationRef = _firestore
        .collection('reservations')
        .doc(reservationId);

    await _firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);
      final reservationSnapshot = await transaction.get(reservationRef);
      final membershipSnapshot = await transaction.get(membershipRef);
      final trainingTypeSnapshot = await transaction.get(trainingTypeRef);
      final trainerSnapshot = await transaction.get(trainerRef);
      final userSnapshot = await transaction.get(userRef);

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final sessionData = sessionSnapshot.data() ?? {};
      final isActive = sessionData['isActive'] as bool? ?? false;
      final status = sessionData['status'] as String? ?? '';
      final capacity = sessionData['capacity'] as int? ?? 0;
      final reservedCount = sessionData['reservedCount'] as int? ?? 0;
      final startTime = (sessionData['startTime'] as Timestamp?)?.toDate();
      final endTime = (sessionData['endTime'] as Timestamp?)?.toDate();
      final trainerId = sessionData['trainerId'] as String? ?? '';

      if (trainerId == currentUser.uid) {
        throw Exception('trainer-cannot-reserve-own-session');
      }

      if (startTime == null || endTime == null) {
        throw Exception('training-session-invalid-time');
      }

      if (!startTime.isAfter(DateTime.now())) {
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

        if (reservationStatus != 'cancelled') {
          throw Exception('reservation-already-exists');
        }
      }

      if (!membershipSnapshot.exists) {
        throw Exception('membership-not-found');
      }

      final membershipData = membershipSnapshot.data() ?? {};

      final trainingTypeData = trainingTypeSnapshot.data() ?? {};
      final trainerData = trainerSnapshot.data() ?? {};
      final userData = userSnapshot.data() ?? {};

      final trainingName =
          trainingTypeData['name'] as String? ?? AppTexts.unknownTraining;

      final trainerName = _displayNameFromUserData(trainerData);
      final userName = _displayNameFromUserData(userData);
      final userEmail = userData['email'] as String? ?? '';
      final membershipPlanName = membershipData['planName'] as String? ?? '';
      final membershipPlanId = membershipData['planId'] as String? ?? '';
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

      transaction.set(reservationRef, {
        'userId': currentUser.uid,
        'userRef': userRef,
        'userName': userName,
        'userEmail': userEmail,

        'trainingSessionId': session.id,
        'trainingSessionRef': sessionRef,
        'trainingName': trainingName,
        'trainingStartTime': Timestamp.fromDate(startTime),
        'trainingEndTime': Timestamp.fromDate(endTime),

        'trainerId': trainerId,
        'trainerRef': trainerRef,
        'trainerName': trainerName,

        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        'membershipId': membershipRef.id,
        'membershipRef': membershipRef,
        'membershipPlanName': membershipPlanName,
        'membershipPlanId': membershipPlanId,
        'entryStatus': 'reserved',
        'reservationDateId': _dateId(startTime),
      }, SetOptions(merge: true));

      transaction.update(sessionRef, {
        'reservedCount': reservedCount + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _auditLogService.createLogWithUsers(
      category: 'reservation',
      action: 'created',
      targetType: 'reservation',
      targetId: reservationId,
      targetUserId: currentUser.uid,
      actor: currentUser,
      title: AppTexts.auditReservationCreatedTitle,
      description: AppTexts.auditReservationCreatedDescription,
      changes: {
        'trainingSessionId': {'oldValue': null, 'newValue': session.id},
        'membershipId': {'oldValue': null, 'newValue': membershipRef.id},
        'entryStatus': {'oldValue': null, 'newValue': 'reserved'},
      },
    );
  }

  Future<void> cancelReservation({
    required String reservationId,
    required String trainingSessionId,
  }) async {
    final reservationRef = _firestore
        .collection('reservations')
        .doc(reservationId);

    final sessionRef = _firestore
        .collection('trainingSessions')
        .doc(trainingSessionId);

    String reservationUserId = '';
    String reservationMembershipId = '';
    String oldEntryStatus = '';

    await _firestore.runTransaction((transaction) async {
      final reservationSnapshot = await transaction.get(reservationRef);
      final sessionSnapshot = await transaction.get(sessionRef);

      final reservationDataForMembership = reservationSnapshot.data();
      final membershipRef =
          reservationDataForMembership?['membershipRef']
              as DocumentReference<Map<String, dynamic>>?;

      final membershipSnapshot = membershipRef == null
          ? null
          : await transaction.get(membershipRef);

      if (!reservationSnapshot.exists) {
        throw Exception('reservation-not-found');
      }

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final reservationData = reservationSnapshot.data() ?? {};
      final sessionData = sessionSnapshot.data() ?? {};

      reservationUserId = reservationData['userId'] as String? ?? '';
      reservationMembershipId =
          reservationData['membershipId'] as String? ?? '';
      oldEntryStatus = reservationData['entryStatus'] as String? ?? '';

      final reservationTrainingSessionId =
          reservationData['trainingSessionId'] as String? ?? '';

      if (reservationTrainingSessionId != trainingSessionId) {
        throw Exception('reservation-session-mismatch');
      }

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
          final newEntriesReserved = entriesReserved > 0
              ? entriesReserved - 1
              : 0;

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

    final currentUser = FirebaseAuth.instance.currentUser;

    await _auditLogService.createLogWithUsers(
      category: 'reservation',
      action: 'cancelled',
      targetType: 'reservation',
      targetId: reservationId,
      targetUserId: reservationUserId,
      actor: currentUser,
      title: AppTexts.auditReservationCancelledTitle,
      description: AppTexts.auditReservationCancelledDescription,
      changes: {
        'trainingSessionId': {
          'oldValue': trainingSessionId,
          'newValue': trainingSessionId,
        },
        'membershipId': {
          'oldValue': reservationMembershipId,
          'newValue': reservationMembershipId,
        },
        'status': {'oldValue': 'active', 'newValue': 'cancelled'},
        'entryStatus': {'oldValue': oldEntryStatus, 'newValue': 'released'},
      },
    );
  }

  Future<void> markReservationAttendance({
    required String reservationId,
    required String trainingSessionId,
    required bool attended,
    String? trainerId,
  }) async {
    final reservationRef = _firestore
        .collection('reservations')
        .doc(reservationId);

    final sessionRef = _firestore
        .collection('trainingSessions')
        .doc(trainingSessionId);

    String reservationUserId = '';
    String reservationMembershipId = '';
    String oldEntryStatus = '';

    await _firestore.runTransaction((transaction) async {
      final reservationSnapshot = await transaction.get(reservationRef);
      final sessionSnapshot = await transaction.get(sessionRef);

      final reservationDataForMembership = reservationSnapshot.data();
      final membershipRef =
          reservationDataForMembership?['membershipRef']
              as DocumentReference<Map<String, dynamic>>?;

      final membershipSnapshot = membershipRef == null
          ? null
          : await transaction.get(membershipRef);

      if (!reservationSnapshot.exists) {
        throw Exception('reservation-not-found');
      }

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final sessionData = sessionSnapshot.data() ?? {};
      final sessionTrainerId = sessionData['trainerId'] as String? ?? '';
      final sessionStartTime = (sessionData['startTime'] as Timestamp?)
          ?.toDate();

      if (trainerId != null && sessionTrainerId != trainerId) {
        throw Exception('trainer-not-owner-of-session');
      }

      if (sessionStartTime == null) {
        throw Exception('training-session-start-time-missing');
      }

      final now = DateTime.now();

      final isToday =
          sessionStartTime.year == now.year &&
          sessionStartTime.month == now.month &&
          sessionStartTime.day == now.day;

      if (!isToday) {
        throw Exception('attendance-only-for-today');
      }

      if (trainerId != null &&
          !_isTrainerQrScanAllowed(
            sessionStartTime: sessionStartTime,
            now: now,
          )) {
        throw Exception('trainer-qr-scan-too-early');
      }

      final reservationData = reservationSnapshot.data() ?? {};

      reservationUserId = reservationData['userId'] as String? ?? '';
      reservationMembershipId =
          reservationData['membershipId'] as String? ?? '';
      oldEntryStatus = reservationData['entryStatus'] as String? ?? '';

      final reservationTrainingSessionId =
          reservationData['trainingSessionId'] as String? ?? '';

      if (reservationTrainingSessionId != trainingSessionId) {
        throw Exception('reservation-session-mismatch');
      }

      final reservationStatus =
          reservationData['status'] as String? ?? 'active';

      if (reservationStatus != 'active') {
        throw Exception('reservation-not-active');
      }

      final entryStatus = reservationData['entryStatus'] as String? ?? '';

      if (entryStatus != 'reserved') {
        throw Exception('reservation-entry-not-reserved');
      }

      if (membershipRef != null &&
          membershipSnapshot != null &&
          membershipSnapshot.exists) {
        final membershipData = membershipSnapshot.data() ?? {};

        final entriesTotal = membershipData['entriesTotal'] as int?;
        final entriesRemaining =
            membershipData['entriesRemaining'] as int? ?? 0;
        final entriesReserved = membershipData['entriesReserved'] as int? ?? 0;

        if (entriesTotal != null) {
          final newEntriesReserved = entriesReserved > 0
              ? entriesReserved - 1
              : 0;

          final newEntriesRemaining = entriesRemaining > 0
              ? entriesRemaining - 1
              : 0;

          transaction.update(membershipRef, {
            'entriesReserved': newEntriesReserved,
            'entriesRemaining': newEntriesRemaining,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      transaction.update(reservationRef, {
        'status': attended ? 'attended' : 'no_show',
        'entryStatus': 'used',
        'attended': attended,
        'noShow': !attended,
        'attendanceMarkedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(sessionRef, {
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    final currentUser = FirebaseAuth.instance.currentUser;

    await _auditLogService.createLogWithUsers(
      category: 'attendance',
      action: attended
          ? 'attendance_marked_attended'
          : 'attendance_marked_no_show',
      targetType: 'reservation',
      targetId: reservationId,
      targetUserId: reservationUserId,
      actor: currentUser,
      title: attended
          ? AppTexts.auditAttendanceAttendedTitle
          : AppTexts.auditAttendanceNoShowTitle,
      description: attended
          ? AppTexts.auditAttendanceAttendedDescription
          : AppTexts.auditAttendanceNoShowDescription,
      changes: {
        'trainingSessionId': {
          'oldValue': trainingSessionId,
          'newValue': trainingSessionId,
        },
        'membershipId': {
          'oldValue': reservationMembershipId,
          'newValue': reservationMembershipId,
        },
        'status': {
          'oldValue': 'active',
          'newValue': attended ? 'attended' : 'no_show',
        },
        'entryStatus': {'oldValue': oldEntryStatus, 'newValue': 'used'},
        'attended': {'oldValue': null, 'newValue': attended},
      },
    );
  }
}
