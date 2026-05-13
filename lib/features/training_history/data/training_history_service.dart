import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_texts.dart';
import '../../audit/data/audit_log_service.dart';
import '../../schedule/domain/training_session.dart';

class TrainingHistoryService {
  TrainingHistoryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final AuditLogService _auditLogService = AuditLogService();

  Stream<List<TrainingHistorySession>> watchTrainingHistory({
    required DateTime from,
    required DateTime to,
    int limit = 100,
  }) {
    return _firestore
        .collection('trainingSessions')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('startTime', isLessThan: Timestamp.fromDate(to))
        .orderBy('startTime', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return TrainingHistorySession.fromFirestore(document);
          }).toList();
        });
  }

  Stream<List<TrainingHistoryReservation>> watchTrainingReservations({
    required String trainingSessionId,
  }) {
    return _firestore
        .collection('reservations')
        .where('trainingSessionId', isEqualTo: trainingSessionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return TrainingHistoryReservation.fromFirestore(document);
          }).toList();
        });
  }

  Stream<List<TrainingHistoryUserOption>> watchUsersForAttendance() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .where('isActive', isEqualTo: true)
        .orderBy('email')
        .limit(200)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs.map((document) {
            return TrainingHistoryUserOption.fromFirestore(document);
          }).toList();

          users.sort((a, b) {
            return a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            );
          });

          return users;
        });
  }

  Stream<List<TrainingHistoryMembershipOption>> watchUsableMembershipsForUser({
    required String userId,
    required DateTime trainingStartTime,
  }) {
    return _firestore
        .collection('memberships')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final memberships = snapshot.docs
              .map((document) {
                return TrainingHistoryMembershipOption.fromFirestore(document);
              })
              .where((membership) {
                return membership.isUsableFor(trainingStartTime);
              })
              .toList();

          memberships.sort((a, b) {
            final firstDate = a.validUntil;
            final secondDate = b.validUntil;

            if (firstDate == null && secondDate == null) {
              return a.planName.compareTo(b.planName);
            }

            if (firstDate == null) {
              return 1;
            }

            if (secondDate == null) {
              return -1;
            }

            return firstDate.compareTo(secondDate);
          });

          return memberships;
        });
  }

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

  Future<void> markReservationAttendanceFromHistory({
    required String reservationId,
    required String trainingSessionId,
    required bool attended,
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

      if (!reservationSnapshot.exists) {
        throw Exception('reservation-not-found');
      }

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
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

      final membershipRef =
          reservationData['membershipRef']
              as DocumentReference<Map<String, dynamic>>?;

      if (membershipRef != null) {
        final membershipSnapshot = await transaction.get(membershipRef);

        if (membershipSnapshot.exists) {
          final membershipData = membershipSnapshot.data() ?? {};
          final entriesTotal = membershipData['entriesTotal'] as int?;
          final entriesRemaining =
              membershipData['entriesRemaining'] as int? ?? 0;
          final entriesReserved =
              membershipData['entriesReserved'] as int? ?? 0;

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
      }

      transaction.update(reservationRef, {
        'status': attended ? 'attended' : 'no_show',
        'entryStatus': 'used',
        'attended': attended,
        'noShow': !attended,
        'attendanceMarkedAt': FieldValue.serverTimestamp(),
        'attendanceRevertedAt': FieldValue.delete(),
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

  Future<void> cancelReservationFromHistory({
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

      final entryStatus = reservationData['entryStatus'] as String? ?? '';

      if (reservationStatus != 'active' || entryStatus != 'reserved') {
        throw Exception('reservation-not-active-reserved');
      }

      final membershipRef =
          reservationData['membershipRef']
              as DocumentReference<Map<String, dynamic>>?;

      if (membershipRef != null) {
        final membershipSnapshot = await transaction.get(membershipRef);

        if (membershipSnapshot.exists) {
          final membershipData = membershipSnapshot.data() ?? {};
          final entriesTotal = membershipData['entriesTotal'] as int?;
          final entriesReserved =
              membershipData['entriesReserved'] as int? ?? 0;

          if (entriesTotal != null) {
            transaction.update(membershipRef, {
              'entriesReserved': entriesReserved > 0 ? entriesReserved - 1 : 0,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      final reservedCount = sessionData['reservedCount'] as int? ?? 0;

      transaction.update(reservationRef, {
        'status': 'cancelled',
        'entryStatus': 'released',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(sessionRef, {
        'reservedCount': reservedCount > 0 ? reservedCount - 1 : 0,
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

  Future<void> addAttendanceFromHistory({
    required TrainingHistorySession session,
    required TrainingHistoryUserOption user,
    required TrainingHistoryMembershipOption membership,
  }) async {
    final sessionRef = _firestore
        .collection('trainingSessions')
        .doc(session.id);

    final userRef = _firestore.collection('users').doc(user.id);

    final membershipRef = _firestore
        .collection('memberships')
        .doc(membership.id);

    final reservationId = '${session.id}_${user.id}';

    final reservationRef = _firestore
        .collection('reservations')
        .doc(reservationId);

    await _firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);
      final userSnapshot = await transaction.get(userRef);
      final membershipSnapshot = await transaction.get(membershipRef);
      final reservationSnapshot = await transaction.get(reservationRef);

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      if (!userSnapshot.exists) {
        throw Exception('user-not-found');
      }

      if (!membershipSnapshot.exists) {
        throw Exception('membership-not-found');
      }

      if (reservationSnapshot.exists) {
        throw Exception('reservation-already-exists');
      }

      final sessionData = sessionSnapshot.data() ?? {};
      final userData = userSnapshot.data() ?? {};
      final membershipData = membershipSnapshot.data() ?? {};

      final isSessionActive = sessionData['isActive'] as bool? ?? true;
      final sessionStatus = sessionData['status'] as String? ?? 'scheduled';
      final capacity = sessionData['capacity'] as int? ?? 0;
      final reservedCount = sessionData['reservedCount'] as int? ?? 0;
      final startTime =
          (sessionData['startTime'] as Timestamp?)?.toDate() ??
          session.startTime;
      final endTime =
          (sessionData['endTime'] as Timestamp?)?.toDate() ?? session.endTime;

      if (!isSessionActive || sessionStatus == 'cancelled') {
        throw Exception('training-session-cancelled');
      }

      if (capacity > 0 && reservedCount >= capacity) {
        throw Exception('training-session-full');
      }

      final membershipUserId = membershipData['userId'] as String? ?? '';

      if (membershipUserId != user.id) {
        throw Exception('membership-user-mismatch');
      }

      final membershipStatus = membershipData['status'] as String? ?? '';
      final validFrom = (membershipData['validFrom'] as Timestamp?)?.toDate();
      final validUntil = (membershipData['validUntil'] as Timestamp?)?.toDate();
      final entriesTotal = membershipData['entriesTotal'] as int?;
      final entriesRemaining = membershipData['entriesRemaining'] as int?;
      final entriesReserved = membershipData['entriesReserved'] as int? ?? 0;

      if (membershipStatus != 'active') {
        throw Exception('membership-not-active');
      }

      if (validFrom == null || validUntil == null) {
        throw Exception('membership-invalid-validity');
      }

      if (startTime.isBefore(validFrom) || startTime.isAfter(validUntil)) {
        throw Exception('membership-not-valid-for-training');
      }

      if (entriesTotal != null) {
        final availableEntries = (entriesRemaining ?? 0) - entriesReserved;

        if (availableEntries <= 0) {
          throw Exception('no-available-membership-entry');
        }

        transaction.update(membershipRef, {
          'entriesRemaining': (entriesRemaining ?? 0) - 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final trainerId = sessionData['trainerId'] as String? ?? '';
      final trainerRef = trainerId.isEmpty
          ? null
          : _firestore.collection('users').doc(trainerId);

      transaction.set(reservationRef, {
        'userId': user.id,
        'userRef': userRef,
        'userName': _displayNameFromUserData(userData),
        'userEmail': userData['email'] as String? ?? '',

        'trainingSessionId': session.id,
        'trainingSessionRef': sessionRef,
        'trainingName':
            sessionData['trainingName'] as String? ?? session.trainingName,
        'trainingStartTime': Timestamp.fromDate(startTime),
        'trainingEndTime': Timestamp.fromDate(endTime),

        'trainerId': trainerId,
        'trainerRef': ?trainerRef,
        'trainerName':
            sessionData['trainerName'] as String? ?? session.trainerName,

        'status': 'attended',
        'entryStatus': 'used',
        'attended': true,
        'noShow': false,
        'attendanceMarkedAt': FieldValue.serverTimestamp(),

        'membershipId': membership.id,
        'membershipRef': membershipRef,
        'membershipPlanName':
            membershipData['planName'] as String? ?? membership.planName,

        'createdByAdmin': true,
        'createdByUserId': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'reservationDateId': _dateId(startTime),
      });

      transaction.update(sessionRef, {
        'reservedCount': reservedCount + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    final currentUser = FirebaseAuth.instance.currentUser;

    await _auditLogService.createLogWithUsers(
      category: 'attendance',
      action: 'attendance_added_from_history',
      targetType: 'reservation',
      targetId: reservationId,
      targetUserId: user.id,
      actor: currentUser,
      title: AppTexts.addTrainingAttendance,
      description: AppTexts.trainingAttendanceAdded,
      changes: {
        'trainingSessionId': {'oldValue': null, 'newValue': session.id},
        'membershipId': {'oldValue': null, 'newValue': membership.id},
        'status': {'oldValue': null, 'newValue': 'attended'},
        'entryStatus': {'oldValue': null, 'newValue': 'used'},
      },
    );
  }

  Future<void> revertReservationAttendanceFromHistory({
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
    String oldStatus = '';
    String oldEntryStatus = '';

    await _firestore.runTransaction((transaction) async {
      final reservationSnapshot = await transaction.get(reservationRef);
      final sessionSnapshot = await transaction.get(sessionRef);

      if (!reservationSnapshot.exists) {
        throw Exception('reservation-not-found');
      }

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final reservationData = reservationSnapshot.data() ?? {};

      reservationUserId = reservationData['userId'] as String? ?? '';
      reservationMembershipId =
          reservationData['membershipId'] as String? ?? '';
      oldStatus = reservationData['status'] as String? ?? '';
      oldEntryStatus = reservationData['entryStatus'] as String? ?? '';

      final reservationTrainingSessionId =
          reservationData['trainingSessionId'] as String? ?? '';

      if (reservationTrainingSessionId != trainingSessionId) {
        throw Exception('reservation-session-mismatch');
      }

      if (oldEntryStatus != 'used' ||
          (oldStatus != 'attended' && oldStatus != 'no_show')) {
        throw Exception('reservation-attendance-not-used');
      }

      final membershipRef =
          reservationData['membershipRef']
              as DocumentReference<Map<String, dynamic>>?;

      if (membershipRef != null) {
        final membershipSnapshot = await transaction.get(membershipRef);

        if (membershipSnapshot.exists) {
          final membershipData = membershipSnapshot.data() ?? {};
          final entriesTotal = membershipData['entriesTotal'] as int?;
          final entriesRemaining =
              membershipData['entriesRemaining'] as int? ?? 0;
          final entriesReserved =
              membershipData['entriesReserved'] as int? ?? 0;

          if (entriesTotal != null) {
            transaction.update(membershipRef, {
              'entriesRemaining': entriesRemaining + 1,
              'entriesReserved': entriesReserved + 1,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      transaction.update(reservationRef, {
        'status': 'active',
        'entryStatus': 'reserved',
        'attended': false,
        'noShow': false,
        'attendanceMarkedAt': FieldValue.delete(),
        'attendanceRevertedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(sessionRef, {
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    final currentUser = FirebaseAuth.instance.currentUser;

    await _auditLogService.createLogWithUsers(
      category: 'attendance',
      action: 'attendance_reverted',
      targetType: 'reservation',
      targetId: reservationId,
      targetUserId: reservationUserId,
      actor: currentUser,
      title: AppTexts.revertAttendance,
      description: AppTexts.revertAttendanceQuestion,
      changes: {
        'trainingSessionId': {
          'oldValue': trainingSessionId,
          'newValue': trainingSessionId,
        },
        'membershipId': {
          'oldValue': reservationMembershipId,
          'newValue': reservationMembershipId,
        },
        'status': {'oldValue': oldStatus, 'newValue': 'active'},
        'entryStatus': {'oldValue': oldEntryStatus, 'newValue': 'reserved'},
      },
    );
  }
}

class TrainingHistorySession {
  const TrainingHistorySession({
    required this.id,
    required this.trainingName,
    required this.trainerName,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.reservedCount,
    required this.status,
    required this.isActive,
  });

  final String id;
  final String trainingName;
  final String trainerName;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int reservedCount;
  final String status;
  final bool isActive;

  bool get isCancelled => status == 'cancelled' || !isActive;

  bool get isFinished => endTime.isBefore(DateTime.now());

  factory TrainingHistorySession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final startTime =
        (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();

    final endTime = (data['endTime'] as Timestamp?)?.toDate() ?? startTime;

    return TrainingHistorySession(
      id: document.id,
      trainingName: data['trainingName'] as String? ?? AppTexts.unknownTraining,
      trainerName: data['trainerName'] as String? ?? AppTexts.unknownTrainer,
      startTime: startTime,
      endTime: endTime,
      capacity: data['capacity'] as int? ?? 0,
      reservedCount: data['reservedCount'] as int? ?? 0,
      status: data['status'] as String? ?? 'scheduled',
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  TrainingSession toTrainingSession() {
    return TrainingSession(
      id: id,
      trainingTypeId: '',
      trainerId: '',
      startTime: startTime,
      endTime: endTime,
      capacity: capacity,
      reservedCount: reservedCount,
      status: status,
      isActive: isActive,
      trainingName: trainingName,
      trainingDescription: '',
      trainerName: trainerName,
      trainerRole: '',
      durationMinutes: endTime.difference(startTime).inMinutes,
    );
  }
}

class TrainingHistoryReservation {
  const TrainingHistoryReservation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.trainingSessionId,
    required this.membershipId,
    required this.membershipPlanName,
    required this.status,
    required this.entryStatus,
    required this.attended,
    required this.noShow,
    required this.createdAt,
    required this.attendanceMarkedAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String trainingSessionId;
  final String membershipId;
  final String membershipPlanName;
  final String status;
  final String entryStatus;
  final bool attended;
  final bool noShow;
  final DateTime? createdAt;
  final DateTime? attendanceMarkedAt;

  bool get isReserved => status == 'active' && entryStatus == 'reserved';

  bool get isAttended => status == 'attended' && entryStatus == 'used';

  bool get isNoShow => status == 'no_show' && entryStatus == 'used';

  bool get isCancelled => status == 'cancelled' || entryStatus == 'released';

  factory TrainingHistoryReservation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return TrainingHistoryReservation(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? AppTexts.unknownUser,
      userEmail: data['userEmail'] as String? ?? '',
      trainingSessionId: data['trainingSessionId'] as String? ?? '',
      membershipId: data['membershipId'] as String? ?? '',
      membershipPlanName: data['membershipPlanName'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      entryStatus: data['entryStatus'] as String? ?? '',
      attended: data['attended'] as bool? ?? false,
      noShow: data['noShow'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      attendanceMarkedAt: (data['attendanceMarkedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class TrainingHistoryUserOption {
  const TrainingHistoryUserOption({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;

  factory TrainingHistoryUserOption.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    final publicName = data['publicName'] as String? ?? '';
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final displayName = data['displayName'] as String? ?? '';
    final email = data['email'] as String? ?? '';

    String finalName = publicName.trim();

    if (finalName.isEmpty) {
      finalName = '$firstName $lastName'.trim();
    }

    if (finalName.isEmpty) {
      finalName = displayName.trim();
    }

    if (finalName.isEmpty) {
      finalName = email.trim();
    }

    if (finalName.isEmpty) {
      finalName = AppTexts.unknownUser;
    }

    return TrainingHistoryUserOption(
      id: document.id,
      email: email,
      displayName: finalName,
    );
  }
}

class TrainingHistoryMembershipOption {
  const TrainingHistoryMembershipOption({
    required this.id,
    required this.planName,
    required this.entriesTotal,
    required this.entriesRemaining,
    required this.entriesReserved,
    required this.validFrom,
    required this.validUntil,
    required this.status,
  });

  final String id;
  final String planName;
  final int? entriesTotal;
  final int? entriesRemaining;
  final int? entriesReserved;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String status;

  int get availableEntries {
    final remaining = entriesRemaining ?? 0;
    final reserved = entriesReserved ?? 0;
    final available = remaining - reserved;

    return available < 0 ? 0 : available;
  }

  bool isUsableFor(DateTime trainingStartTime) {
    if (status != 'active') {
      return false;
    }

    if (validFrom == null || validUntil == null) {
      return false;
    }

    if (trainingStartTime.isBefore(validFrom!) ||
        trainingStartTime.isAfter(validUntil!)) {
      return false;
    }

    if (entriesTotal == null) {
      return true;
    }

    return availableEntries > 0;
  }

  String get label {
    if (entriesTotal == null) {
      return planName;
    }

    return '$planName • ${AppTexts.entriesAvailable}: $availableEntries';
  }

  factory TrainingHistoryMembershipOption.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return TrainingHistoryMembershipOption(
      id: document.id,
      planName: data['planName'] as String? ?? '',
      entriesTotal: data['entriesTotal'] as int?,
      entriesRemaining: data['entriesRemaining'] as int?,
      entriesReserved: data['entriesReserved'] as int? ?? 0,
      validFrom: (data['validFrom'] as Timestamp?)?.toDate(),
      validUntil: (data['validUntil'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'active',
    );
  }
}
