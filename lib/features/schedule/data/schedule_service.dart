import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import '../domain/schedule_item.dart';
import '../domain/schedule_template.dart';
import '../domain/training_session.dart';
import '../domain/training_type.dart';

/* Načítava dáta z Firestore z kolekcií trainingSessions, trainingTypes a users
   a skladá ich do zoznamu položiek rozvrhu. */
class ScheduleService {
  ScheduleService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ScheduleItem>> watchScheduleItems() {
    return _firestore
        .collection('trainingSessions')
        .orderBy('startTime')
        .snapshots()
        .asyncMap((sessionsSnapshot) async {
          final typesSnapshot = await _firestore
              .collection('trainingTypes')
              .get();
          final usersSnapshot = await _firestore.collection('users').get();

          final trainingTypesById = {
            for (final document in typesSnapshot.docs)
              document.id: TrainingType.fromFirestore(document),
          };

          final usersById = {
            for (final document in usersSnapshot.docs)
              document.id: document.data(),
          };

          final items = <ScheduleItem>[];

          for (final document in sessionsSnapshot.docs) {
            final session = TrainingSession.fromFirestore(document);

            if (!session.isActive || !session.isScheduled) {
              continue;
            }

            final trainingType = trainingTypesById[session.trainingTypeId];
            final trainerData = usersById[session.trainerId];

            if (trainingType == null || !trainingType.isActive) {
              continue;
            }

            final trainerRole = trainerData?['role'] as String? ?? '';
            final trainerPublicName =
                trainerData?['publicName'] as String? ?? '';
            final trainerFirstName = trainerData?['firstName'] as String? ?? '';
            final trainerDisplayName =
                trainerData?['displayName'] as String? ?? '';

            final trainerBaseName = trainerPublicName.isNotEmpty
                ? trainerPublicName
                : trainerFirstName.isNotEmpty
                ? trainerFirstName
                : trainerDisplayName.isNotEmpty
                ? trainerDisplayName
                : AppTexts.unknownTrainer;

            final trainerName = trainerRole == AppRoles.admin
                ? '${AppTexts.roleAdmin} - $trainerBaseName'
                : trainerBaseName;

            items.add(
              ScheduleItem(
                session: session,
                trainingType: trainingType,
                trainerName: trainerName,
              ),
            );
          }

          return items;
        });
  }

  Stream<List<TrainingType>> watchTrainingTypes() {
    return _firestore
        .collection('trainingTypes')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final trainingTypes = snapshot.docs
              .map(TrainingType.fromFirestore)
              .toList();

          trainingTypes.sort((a, b) => a.name.compareTo(b.name));
          return trainingTypes;
        });
  }

  Stream<List<ScheduleTemplate>> watchScheduleTemplates() {
    return _firestore
        .collection('scheduleTemplates')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final scheduleTemplates = snapshot.docs
              .map(ScheduleTemplate.fromFirestore)
              .toList();

          scheduleTemplates.sort((a, b) {
            final weekdayCompare = a.weekday.compareTo(b.weekday);

            if (weekdayCompare != 0) {
              return weekdayCompare;
            }

            final hourCompare = a.startHour.compareTo(b.startHour);

            if (hourCompare != 0) {
              return hourCompare;
            }

            return a.startMinute.compareTo(b.startMinute);
          });

          return scheduleTemplates;
        });
  }

  Future<void> createTrainingType({
    required String name,
    required String description,
    required int defaultDurationMinutes,
    required int defaultCapacity,
    required User currentUser,
  }) async {
    final currentUserRef = _firestore.collection('users').doc(currentUser.uid);
    final trainingTypeId = _createTrainingTypeId(name);

    if (trainingTypeId.isEmpty) {
      throw Exception('invalid-training-type-name');
    }

    final existingTrainingType = await _firestore
        .collection('trainingTypes')
        .doc(trainingTypeId)
        .get();

    if (existingTrainingType.exists) {
      throw Exception('training-type-already-exists');
    }

    await _firestore.collection('trainingTypes').doc(trainingTypeId).set({
      'name': name,
      'description': description,
      'defaultDurationMinutes': defaultDurationMinutes,
      'defaultCapacity': defaultCapacity,
      'isActive': true,
      'createdBy': currentUser.uid,
      'createdByRef': currentUserRef,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createTrainingSession({
    required TrainingType trainingType,
    required User currentUser,
    required String trainerId,
    required DateTime startTime,
    required int durationMinutes,
    required int capacity,
  }) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    final currentUserRef = _firestore.collection('users').doc(currentUser.uid);
    final trainingTypeRef = _firestore
        .collection('trainingTypes')
        .doc(trainingType.id);
    final trainerRef = _firestore.collection('users').doc(trainerId);

    await _checkTrainingSessionOverlap(startTime: startTime, endTime: endTime);

    await _firestore.collection('trainingSessions').add({
      'trainingTypeId': trainingType.id,
      'trainingTypeRef': trainingTypeRef,
      'trainerId': trainerId,
      'trainerRef': trainerRef,
      'createdBy': currentUser.uid,
      'createdByRef': currentUserRef,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'capacity': capacity,
      'reservedCount': 0,
      'status': 'scheduled',
      'isActive': true,
      'source': 'manual',
      'templateId': null,
      'templateRef': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createScheduleTemplate({
    required TrainingType trainingType,
    required User currentUser,
    required String trainerId,
    required int weekday,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
    required int capacity,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    final currentUserRef = _firestore.collection('users').doc(currentUser.uid);
    final trainerRef = _firestore.collection('users').doc(trainerId);
    final trainingTypeRef = _firestore
        .collection('trainingTypes')
        .doc(trainingType.id);

    final scheduleTemplateId = _createScheduleTemplateId(
      trainingTypeId: trainingType.id,
      weekday: weekday,
      startHour: startHour,
      startMinute: startMinute,
    );

    final existingScheduleTemplate = await _firestore
        .collection('scheduleTemplates')
        .doc(scheduleTemplateId)
        .get();

    if (existingScheduleTemplate.exists) {
      throw Exception('schedule-template-already-exists');
    }
    await _checkScheduleTemplateOverlap(
      weekday: weekday,
      startHour: startHour,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
    );

    await _firestore
        .collection('scheduleTemplates')
        .doc(scheduleTemplateId)
        .set({
          'trainingTypeId': trainingType.id,
          'trainingTypeRef': trainingTypeRef,
          'trainerId': trainerId,
          'trainerRef': trainerRef,
          'weekday': weekday,
          'startHour': startHour,
          'startMinute': startMinute,
          'durationMinutes': durationMinutes,
          'capacity': capacity,
          'isActive': true,
          'validFrom': validFrom == null ? null : Timestamp.fromDate(validFrom),
          'validUntil': validUntil == null
              ? null
              : Timestamp.fromDate(validUntil),
          'createdBy': currentUser.uid,
          'createdByRef': currentUserRef,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _checkScheduleTemplateOverlap({
    required int weekday,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
  }) async {
    final newStartMinutes = startHour * 60 + startMinute;
    final newEndMinutes = newStartMinutes + durationMinutes;

    final templatesSnapshot = await _firestore
        .collection('scheduleTemplates')
        .where('weekday', isEqualTo: weekday)
        .where('isActive', isEqualTo: true)
        .get();

    final hasOverlap = templatesSnapshot.docs.any((document) {
      final data = document.data();

      final existingStartHour = data['startHour'] as int? ?? 0;
      final existingStartMinute = data['startMinute'] as int? ?? 0;
      final existingDurationMinutes = data['durationMinutes'] as int? ?? 0;

      final existingStartMinutes = existingStartHour * 60 + existingStartMinute;
      final existingEndMinutes = existingStartMinutes + existingDurationMinutes;

      return existingStartMinutes < newEndMinutes &&
          existingEndMinutes > newStartMinutes;
    });

    if (hasOverlap) {
      throw Exception('schedule-template-overlap');
    }
  }

  Future<void> updateTrainingSession({
    required ScheduleItem item,
    required User currentUser,
    required String? role,
    required String trainerId,
    required DateTime startTime,
    required int durationMinutes,
    required int capacity,
  }) async {
    final sessionId = item.session.id;
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    final sessionRef = _firestore.collection('trainingSessions').doc(sessionId);
    final trainerRef = _firestore.collection('users').doc(trainerId);

    await _checkTrainingSessionOverlap(
      startTime: startTime,
      endTime: endTime,
      ignoredSessionId: sessionId,
    );

    final reservationsSnapshot = await _firestore
        .collection('reservations')
        .where('trainingSessionId', isEqualTo: sessionId)
        .get();

    await _firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final sessionData = sessionSnapshot.data() ?? {};
      final sessionTrainerId = sessionData['trainerId'] as String? ?? '';
      final sessionStatus = sessionData['status'] as String? ?? '';
      final isActive = sessionData['isActive'] as bool? ?? false;
      final existingStartTime = (sessionData['startTime'] as Timestamp?)
          ?.toDate();
      final existingEndTime = (sessionData['endTime'] as Timestamp?)?.toDate();
      final reservedCount = sessionData['reservedCount'] as int? ?? 0;

      if (existingStartTime == null || existingEndTime == null) {
        throw Exception('training-session-invalid-time');
      }

      if (!isActive || sessionStatus != 'scheduled') {
        throw Exception('training-session-not-available');
      }

      final isAdmin = role == AppRoles.admin;
      final isTrainer = role == AppRoles.trainer;

      if (!isAdmin && !isTrainer) {
        throw Exception('permission-denied');
      }

      if (isTrainer && sessionTrainerId != currentUser.uid) {
        throw Exception('trainer-not-owner-of-session');
      }

      if (isTrainer && !existingStartTime.isAfter(DateTime.now())) {
        throw Exception('trainer-cannot-cancel-started-session');
      }

      final startTimeChanged =
          existingStartTime.millisecondsSinceEpoch !=
          startTime.millisecondsSinceEpoch;

      if (!startTimeChanged && capacity < reservedCount) {
        throw Exception('capacity-lower-than-reservations');
      }

      final reservationSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];

      if (startTimeChanged) {
        for (final reservationDocument in reservationsSnapshot.docs) {
          final reservationSnapshot = await transaction.get(
            reservationDocument.reference,
          );

          if (reservationSnapshot.exists) {
            reservationSnapshots.add(reservationSnapshot);
          }
        }
      }

      final membershipAdjustments = <String, _MembershipCancelAdjustment>{};

      if (startTimeChanged) {
        for (final reservationSnapshot in reservationSnapshots) {
          final reservationData = reservationSnapshot.data() ?? {};
          final reservationStatus = reservationData['status'] as String? ?? '';
          final entryStatus = reservationData['entryStatus'] as String? ?? '';

          if (reservationStatus == 'cancelled') {
            continue;
          }

          final membershipRef =
              reservationData['membershipRef']
                  as DocumentReference<Map<String, dynamic>>?;

          if (membershipRef == null) {
            continue;
          }

          final existingAdjustment =
              membershipAdjustments[membershipRef.path] ??
              _MembershipCancelAdjustment(membershipRef: membershipRef);

          if (entryStatus == 'reserved') {
            membershipAdjustments[membershipRef.path] = existingAdjustment
                .copyWith(
                  reservedToRelease: existingAdjustment.reservedToRelease + 1,
                );
          } else if (entryStatus == 'used') {
            membershipAdjustments[membershipRef.path] = existingAdjustment
                .copyWith(usedToRefund: existingAdjustment.usedToRefund + 1);
          }
        }
      }

      final membershipSnapshots =
          <String, DocumentSnapshot<Map<String, dynamic>>>{};

      if (startTimeChanged) {
        for (final adjustment in membershipAdjustments.values) {
          final membershipSnapshot = await transaction.get(
            adjustment.membershipRef,
          );

          membershipSnapshots[adjustment.membershipRef.path] =
              membershipSnapshot;
        }
      }

      if (startTimeChanged) {
        for (final reservationSnapshot in reservationSnapshots) {
          final reservationData = reservationSnapshot.data() ?? {};
          final reservationStatus = reservationData['status'] as String? ?? '';
          final entryStatus = reservationData['entryStatus'] as String? ?? '';

          if (reservationStatus == 'cancelled') {
            continue;
          }

          final newEntryStatus = entryStatus == 'used'
              ? 'refunded'
              : 'released';

          transaction.update(reservationSnapshot.reference, {
            'status': 'cancelled',
            'entryStatus': newEntryStatus,
            'cancelledAt': FieldValue.serverTimestamp(),
            'cancelledBy': currentUser.uid,
            'cancelledReason': 'training-session-time-changed',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        for (final adjustment in membershipAdjustments.values) {
          final membershipSnapshot =
              membershipSnapshots[adjustment.membershipRef.path];

          if (membershipSnapshot == null || !membershipSnapshot.exists) {
            continue;
          }

          final membershipData = membershipSnapshot.data() ?? {};
          final entriesTotal = membershipData['entriesTotal'] as int?;
          final entriesReserved =
              membershipData['entriesReserved'] as int? ?? 0;
          final entriesRemaining =
              membershipData['entriesRemaining'] as int? ?? 0;

          final updates = <String, Object?>{
            'updatedAt': FieldValue.serverTimestamp(),
          };

          if (entriesTotal != null) {
            final newEntriesReserved =
                entriesReserved - adjustment.reservedToRelease;
            final newEntriesRemaining =
                entriesRemaining + adjustment.usedToRefund;

            updates['entriesReserved'] = newEntriesReserved > 0
                ? newEntriesReserved
                : 0;
            updates['entriesRemaining'] = newEntriesRemaining > entriesTotal
                ? entriesTotal
                : newEntriesRemaining;
          }

          transaction.update(adjustment.membershipRef, updates);
        }
      }

      transaction.update(sessionRef, {
        'trainerId': trainerId,
        'trainerRef': trainerRef,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'capacity': capacity,
        'reservedCount': startTimeChanged ? 0 : reservedCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelTrainingSessionWithReservations({
    required String sessionId,
    required User currentUser,
    required String? role,
  }) async {
    final sessionRef = _firestore.collection('trainingSessions').doc(sessionId);

    final reservationsSnapshot = await _firestore
        .collection('reservations')
        .where('trainingSessionId', isEqualTo: sessionId)
        .get();

    await _firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final sessionData = sessionSnapshot.data() ?? {};
      final sessionTrainerId = sessionData['trainerId'] as String? ?? '';
      final sessionStatus = sessionData['status'] as String? ?? '';
      final isActive = sessionData['isActive'] as bool? ?? false;
      final startTime = (sessionData['startTime'] as Timestamp?)?.toDate();

      if (startTime == null) {
        throw Exception('training-session-invalid-start-time');
      }

      if (!isActive || sessionStatus != 'scheduled') {
        throw Exception('training-session-not-available');
      }

      final isAdmin = role == AppRoles.admin;
      final isTrainer = role == AppRoles.trainer;

      if (!isAdmin && !isTrainer) {
        throw Exception('permission-denied');
      }

      if (isTrainer && sessionTrainerId != currentUser.uid) {
        throw Exception('trainer-not-owner-of-session');
      }

      if (isTrainer && !startTime.isAfter(DateTime.now())) {
        throw Exception('trainer-cannot-cancel-started-session');
      }

      final reservationSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];

      for (final reservationDocument in reservationsSnapshot.docs) {
        final reservationSnapshot = await transaction.get(
          reservationDocument.reference,
        );

        if (reservationSnapshot.exists) {
          reservationSnapshots.add(reservationSnapshot);
        }
      }

      final membershipAdjustments = <String, _MembershipCancelAdjustment>{};

      for (final reservationSnapshot in reservationSnapshots) {
        final reservationData = reservationSnapshot.data() ?? {};
        final reservationStatus = reservationData['status'] as String? ?? '';
        final entryStatus = reservationData['entryStatus'] as String? ?? '';

        if (reservationStatus == 'cancelled') {
          continue;
        }

        final membershipRef =
            reservationData['membershipRef']
                as DocumentReference<Map<String, dynamic>>?;

        if (membershipRef == null) {
          continue;
        }

        final existingAdjustment =
            membershipAdjustments[membershipRef.path] ??
            _MembershipCancelAdjustment(membershipRef: membershipRef);

        if (entryStatus == 'reserved') {
          membershipAdjustments[membershipRef.path] = existingAdjustment
              .copyWith(
                reservedToRelease: existingAdjustment.reservedToRelease + 1,
              );
        } else if (entryStatus == 'used') {
          membershipAdjustments[membershipRef.path] = existingAdjustment
              .copyWith(usedToRefund: existingAdjustment.usedToRefund + 1);
        }
      }

      final membershipSnapshots =
          <String, DocumentSnapshot<Map<String, dynamic>>>{};

      for (final adjustment in membershipAdjustments.values) {
        final membershipSnapshot = await transaction.get(
          adjustment.membershipRef,
        );

        membershipSnapshots[adjustment.membershipRef.path] = membershipSnapshot;
      }

      for (final reservationSnapshot in reservationSnapshots) {
        final reservationData = reservationSnapshot.data() ?? {};
        final reservationStatus = reservationData['status'] as String? ?? '';
        final entryStatus = reservationData['entryStatus'] as String? ?? '';

        if (reservationStatus == 'cancelled') {
          continue;
        }

        final newEntryStatus = entryStatus == 'used' ? 'refunded' : 'released';

        transaction.update(reservationSnapshot.reference, {
          'status': 'cancelled',
          'entryStatus': newEntryStatus,
          'cancelledAt': FieldValue.serverTimestamp(),
          'cancelledBy': currentUser.uid,
          'cancelledReason': 'training-session-cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      for (final adjustment in membershipAdjustments.values) {
        final membershipSnapshot =
            membershipSnapshots[adjustment.membershipRef.path];

        if (membershipSnapshot == null || !membershipSnapshot.exists) {
          continue;
        }

        final membershipData = membershipSnapshot.data() ?? {};
        final entriesTotal = membershipData['entriesTotal'] as int?;
        final entriesReserved = membershipData['entriesReserved'] as int? ?? 0;
        final entriesRemaining =
            membershipData['entriesRemaining'] as int? ?? 0;

        final updates = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (entriesTotal != null) {
          final newEntriesReserved =
              entriesReserved - adjustment.reservedToRelease;

          final newEntriesRemaining =
              entriesRemaining + adjustment.usedToRefund;

          updates['entriesReserved'] = newEntriesReserved > 0
              ? newEntriesReserved
              : 0;

          updates['entriesRemaining'] = newEntriesRemaining > entriesTotal
              ? entriesTotal
              : newEntriesRemaining;
        }

        transaction.update(adjustment.membershipRef, updates);
      }

      transaction.update(sessionRef, {
        'isActive': false,
        'status': 'cancelled',
        'reservedCount': 0,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': currentUser.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _checkTrainingSessionOverlap({
    required DateTime startTime,
    required DateTime endTime,
    String? ignoredSessionId,
  }) async {
    final overlappingSessions = await _firestore
        .collection('trainingSessions')
        .where('startTime', isLessThan: Timestamp.fromDate(endTime))
        .get();

    final hasOverlap = overlappingSessions.docs.any((document) {
      if (ignoredSessionId != null && document.id == ignoredSessionId) {
        return false;
      }
      final data = document.data();

      final isActive = data['isActive'] as bool? ?? false;
      final status = data['status'] as String? ?? '';
      final existingEndTime = data['endTime'] as Timestamp?;

      if (!isActive || status != 'scheduled' || existingEndTime == null) {
        return false;
      }

      return existingEndTime.toDate().isAfter(startTime);
    });

    if (hasOverlap) {
      throw Exception('training-session-overlap');
    }
  }

  String _createTrainingTypeId(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('č', 'c')
        .replaceAll('ď', 'd')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ľ', 'l')
        .replaceAll('ĺ', 'l')
        .replaceAll('ň', 'n')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ŕ', 'r')
        .replaceAll('š', 's')
        .replaceAll('ť', 't')
        .replaceAll('ú', 'u')
        .replaceAll('ý', 'y')
        .replaceAll('ž', 'z')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }

  String _createScheduleTemplateId({
    required String trainingTypeId,
    required int weekday,
    required int startHour,
    required int startMinute,
  }) {
    final hour = startHour.toString().padLeft(2, '0');
    final minute = startMinute.toString().padLeft(2, '0');

    return '${trainingTypeId}_day${weekday}_$hour$minute';
  }
}

class _MembershipCancelAdjustment {
  const _MembershipCancelAdjustment({
    required this.membershipRef,
    this.reservedToRelease = 0,
    this.usedToRefund = 0,
  });

  final DocumentReference<Map<String, dynamic>> membershipRef;
  final int reservedToRelease;
  final int usedToRefund;

  _MembershipCancelAdjustment copyWith({
    int? reservedToRelease,
    int? usedToRefund,
  }) {
    return _MembershipCancelAdjustment(
      membershipRef: membershipRef,
      reservedToRelease: reservedToRelease ?? this.reservedToRelease,
      usedToRefund: usedToRefund ?? this.usedToRefund,
    );
  }
}
