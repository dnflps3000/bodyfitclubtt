import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import '../../../core/utils/localized_firestore_text.dart';
import '../../audit/data/audit_log_service.dart';
import '../domain/schedule_item.dart';
import '../domain/schedule_template.dart';
import '../domain/training_session.dart';
import '../domain/training_type.dart';
import 'schedule_system_message_localizer.dart';

/* Načítava dáta z Firestore z kolekcií trainingSessions, trainingTypes a users
   a skladá ich do zoznamu položiek rozvrhu. */
class ScheduleService {
  ScheduleService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final AuditLogService _auditLogService = AuditLogService();

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _defaultScheduleEndDate() {
    return _startOfToday().add(const Duration(days: 14));
  }

  String _resolveUserDisplayName(Map<String, dynamic>? data) {
    if (data == null) {
      return AppTexts.unknownTrainer;
    }

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

    if (firstName.trim().isNotEmpty) {
      return firstName.trim();
    }

    if (displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    if (email.trim().isNotEmpty) {
      return email.trim();
    }

    return AppTexts.unknownTrainer;
  }

  String _trainerDisplayName({
    required String trainerBaseName,
    required String trainerRole,
  }) {
    if (trainerRole == AppRoles.admin) {
      return '${AppTexts.roleAdmin} - $trainerBaseName';
    }

    return trainerBaseName;
  }

  TrainingType _trainingTypeFromSession(TrainingSession session) {
    return TrainingType(
      id: session.trainingTypeId,
      name: session.trainingName,
      description: session.trainingDescription,
      nameLocalized: session.trainingNameLocalized,
      descriptionLocalized: session.trainingDescriptionLocalized,
      defaultDurationMinutes: session.durationMinutes,
      defaultCapacity: session.capacity,
      isActive: true,
    );
  }

  Stream<List<ScheduleItem>> watchScheduleItems({
    DateTime? from,
    DateTime? to,
  }) {
    final scheduleStart = from ?? _startOfToday();
    final scheduleEnd = to ?? _defaultScheduleEndDate();

    return _firestore
        .collection('trainingSessions')
        .where(
          'startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(scheduleStart),
        )
        .where('startTime', isLessThan: Timestamp.fromDate(scheduleEnd))
        .orderBy('startTime')
        .snapshots()
        .asyncMap((sessionsSnapshot) async {
          final sessions = sessionsSnapshot.docs
              .map(TrainingSession.fromFirestore)
              .where((session) => session.isActive && session.isScheduled)
              .toList();

          final needsTrainingTypeFallback = sessions.any((session) {
            return session.trainingName.trim().isEmpty;
          });

          final needsTrainerFallback = sessions.any((session) {
            return session.trainerName.trim().isEmpty ||
                session.trainerRole.trim().isEmpty;
          });

          final trainingTypesById = <String, TrainingType>{};
          final usersById = <String, Map<String, dynamic>>{};

          if (needsTrainingTypeFallback) {
            final typesSnapshot = await _firestore
                .collection('trainingTypes')
                .get();

            for (final document in typesSnapshot.docs) {
              trainingTypesById[document.id] = TrainingType.fromFirestore(
                document,
              );
            }
          }

          if (needsTrainerFallback) {
            final usersSnapshot = await _firestore.collection('users').get();

            for (final document in usersSnapshot.docs) {
              usersById[document.id] = document.data();
            }
          }

          final items = <ScheduleItem>[];

          for (final session in sessions) {
            final hasDenormalizedTraining = session.trainingName
                .trim()
                .isNotEmpty;

            final trainingType = hasDenormalizedTraining
                ? _trainingTypeFromSession(session)
                : trainingTypesById[session.trainingTypeId];

            if (trainingType == null || !trainingType.isActive) {
              continue;
            }

            final hasDenormalizedTrainer = session.trainerName
                .trim()
                .isNotEmpty;

            String trainerName;

            if (hasDenormalizedTrainer) {
              trainerName = _trainerDisplayName(
                trainerBaseName: session.trainerName,
                trainerRole: session.trainerRole,
              );
            } else {
              final trainerData = usersById[session.trainerId];
              final trainerRole = trainerData?['role'] as String? ?? '';
              final trainerBaseName = _resolveUserDisplayName(trainerData);

              trainerName = _trainerDisplayName(
                trainerBaseName: trainerBaseName,
                trainerRole: trainerRole,
              );
            }

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
          final trainingTypes = snapshot.docs.map((document) {
            return TrainingType.fromFirestore(document);
          }).toList();

          trainingTypes.sort((a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

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

    await _createScheduleAuditLog(
      currentUser: currentUser,
      action: 'training_type_created',
      targetType: 'training_type',
      targetId: trainingTypeId,
      title: AppTexts.auditTrainingTypeCreatedTitle,
      description: AppTexts.auditTrainingTypeCreatedDescription(name),
      changes: {
        'name': {'oldValue': null, 'newValue': name},
        'defaultDurationMinutes': {
          'oldValue': null,
          'newValue': defaultDurationMinutes,
        },
        'defaultCapacity': {'oldValue': null, 'newValue': defaultCapacity},
      },
    );
  }

  Future<void> updateTrainingType({
    required TrainingType trainingType,
    required String name,
    required String description,
    required int defaultDurationMinutes,
    required int defaultCapacity,
    required User currentUser,
  }) async {
    final normalizedName = name.trim().toLowerCase();

    final trainingTypesSnapshot = await _firestore
        .collection('trainingTypes')
        .where('isActive', isEqualTo: true)
        .get();

    final duplicateExists = trainingTypesSnapshot.docs.any((document) {
      if (document.id == trainingType.id) {
        return false;
      }

      final data = document.data();
      final existingName = (data['name'] as String? ?? '').trim().toLowerCase();

      return existingName == normalizedName;
    });

    if (duplicateExists) {
      throw Exception('training-type-already-exists');
    }

    await _firestore.collection('trainingTypes').doc(trainingType.id).update({
      'name': name,
      'description': description,
      'defaultDurationMinutes': defaultDurationMinutes,
      'defaultCapacity': defaultCapacity,
      'updatedBy': currentUser.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _createScheduleAuditLog(
      currentUser: currentUser,
      action: 'training_type_updated',
      targetType: 'training_type',
      targetId: trainingType.id,
      title: AppTexts.auditTrainingTypeUpdatedTitle,
      description: AppTexts.auditTrainingTypeUpdatedDescription(name),
      changes: {
        'name': {'oldValue': trainingType.name, 'newValue': name},
        'description': {
          'oldValue': trainingType.description,
          'newValue': description,
        },
        'defaultDurationMinutes': {
          'oldValue': trainingType.defaultDurationMinutes,
          'newValue': defaultDurationMinutes,
        },
        'defaultCapacity': {
          'oldValue': trainingType.defaultCapacity,
          'newValue': defaultCapacity,
        },
      },
    );
  }

  Future<void> deactivateTrainingType({
    required TrainingType trainingType,
    required User currentUser,
  }) async {
    final templatesSnapshot = await _firestore
        .collection('scheduleTemplates')
        .where('trainingTypeId', isEqualTo: trainingType.id)
        .get();

    final isUsedByActiveTemplate = templatesSnapshot.docs.any((document) {
      final data = document.data();
      return data['isActive'] as bool? ?? false;
    });

    if (isUsedByActiveTemplate) {
      throw Exception('training-type-used-by-template');
    }

    final futureSessionsSnapshot = await _firestore
        .collection('trainingSessions')
        .where('trainingTypeId', isEqualTo: trainingType.id)
        .get();

    final now = DateTime.now();

    final isUsedByFutureSession = futureSessionsSnapshot.docs.any((document) {
      final data = document.data();
      final isActive = data['isActive'] as bool? ?? false;
      final startTime = (data['startTime'] as Timestamp?)?.toDate();

      return isActive && startTime != null && startTime.isAfter(now);
    });

    if (isUsedByFutureSession) {
      throw Exception('training-type-used-by-session');
    }

    await _firestore.collection('trainingTypes').doc(trainingType.id).update({
      'isActive': false,
      'deactivatedBy': currentUser.uid,
      'deactivatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _createScheduleAuditLog(
      currentUser: currentUser,
      action: 'training_type_deactivated',
      targetType: 'training_type',
      targetId: trainingType.id,
      title: AppTexts.auditTrainingTypeDeactivatedTitle,
      description: AppTexts.auditTrainingTypeDeactivatedDescription(
        trainingType.name,
      ),
      changes: {
        'isActive': {'oldValue': true, 'newValue': false},
      },
    );
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

    final now = DateTime.now();
    final latestAllowedDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 14, hours: 23, minutes: 59));

    if (startTime.isAfter(latestAllowedDate)) {
      throw Exception('training-session-too-far-in-future');
    }

    final currentUserRef = _firestore.collection('users').doc(currentUser.uid);
    final trainingTypeRef = _firestore
        .collection('trainingTypes')
        .doc(trainingType.id);
    final trainerRef = _firestore.collection('users').doc(trainerId);

    final trainerSnapshot = await trainerRef.get();
    final trainerData = trainerSnapshot.data();

    final trainerRole = trainerData?['role'] as String? ?? '';
    final trainerName = _resolveUserDisplayName(trainerData);

    await _checkTrainingSessionOverlap(startTime: startTime, endTime: endTime);

    await _checkTrainingSessionTemplateOverlap(
      startTime: startTime,
      endTime: endTime,
    );

    final sessionRef = await _firestore.collection('trainingSessions').add({
      'trainingTypeId': trainingType.id,
      'trainingTypeRef': trainingTypeRef,
      'trainingName': trainingType.name,
      'trainingDescription': trainingType.description,
      'trainingNameLocalized': trainingType.effectiveNameLocalized,
      'trainingDescriptionLocalized':
          trainingType.effectiveDescriptionLocalized,
      'trainerId': trainerId,
      'trainerRef': trainerRef,
      'trainerName': trainerName,
      'trainerRole': trainerRole,
      'createdBy': currentUser.uid,
      'createdByRef': currentUserRef,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMinutes': durationMinutes,
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

    await _createScheduleSystemMessage(
      currentUser: currentUser,
      sourceAction: 'training_session_created',
      text: AppTexts.scheduleMessageTrainingSessionCreated(
        trainingName: trainingType.name,
        date: _formatDate(startTime),
        time: _formatTime(startTime),
      ),
      textLocalized: ScheduleSystemMessageLocalizer.trainingSessionCreated(
        trainingNameLocalized: trainingType.effectiveNameLocalized,
        fallbackTrainingName: trainingType.name,
        date: _formatDate(startTime),
        time: _formatTime(startTime),
      ),
    );

    await _createScheduleAuditLog(
      currentUser: currentUser,
      action: 'training_session_created',
      targetType: 'training_session',
      targetId: sessionRef.id,
      title: AppTexts.auditTrainingSessionCreatedTitle,
      description: AppTexts.auditTrainingSessionCreatedDescription(
        trainingType.name,
      ),
      changes: {
        'trainingTypeId': {'oldValue': null, 'newValue': trainingType.id},
        'trainerId': {'oldValue': null, 'newValue': trainerId},
        'startTime': {
          'oldValue': null,
          'newValue': startTime.toIso8601String(),
        },
        'endTime': {'oldValue': null, 'newValue': endTime.toIso8601String()},
        'capacity': {'oldValue': null, 'newValue': capacity},
      },
    );
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

    final templateTime = _formatTemplateTime(
      startHour: startHour,
      startMinute: startMinute,
    );

    await _createScheduleSystemMessage(
      currentUser: currentUser,
      sourceAction: 'schedule_template_created',
      textLocalized: ScheduleSystemMessageLocalizer.templateCreated(
        trainingNameLocalized: trainingType.effectiveNameLocalized,
        fallbackTrainingName: trainingType.name,
        weekday: weekday,
        time: templateTime,
      ),
      text: AppTexts.scheduleMessageTemplateCreated(
        trainingName: trainingType.name,
        weekday: _weekdayLabel(weekday),
        time: templateTime,
      ),
    );

    await _createScheduleAuditLog(
      currentUser: currentUser,
      action: 'schedule_template_created',
      targetType: 'schedule_template',
      targetId: scheduleTemplateId,
      title: AppTexts.auditScheduleTemplateCreatedTitle,
      description: AppTexts.auditScheduleTemplateCreatedDescription(
        trainingType.name,
      ),
      changes: {
        'trainingTypeId': {'oldValue': null, 'newValue': trainingType.id},
        'trainerId': {'oldValue': null, 'newValue': trainerId},
        'weekday': {'oldValue': null, 'newValue': weekday},
        'startHour': {'oldValue': null, 'newValue': startHour},
        'startMinute': {'oldValue': null, 'newValue': startMinute},
        'durationMinutes': {'oldValue': null, 'newValue': durationMinutes},
        'capacity': {'oldValue': null, 'newValue': capacity},
      },
    );
  }

  Future<void> updateScheduleTemplate({
    required ScheduleTemplate scheduleTemplate,
    required TrainingType trainingType,
    required User currentUser,
    required String trainerId,
    required int weekday,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
    required int capacity,
  }) async {
    final oldWeekday = scheduleTemplate.weekday;
    final oldStartHour = scheduleTemplate.startHour;
    final oldStartMinute = scheduleTemplate.startMinute;

    await _checkScheduleTemplateOverlap(
      weekday: weekday,
      startHour: startHour,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      ignoredTemplateId: scheduleTemplate.id,
    );

    final trainerRef = _firestore.collection('users').doc(trainerId);
    final trainingTypeRef = _firestore
        .collection('trainingTypes')
        .doc(trainingType.id);

    await _firestore
        .collection('scheduleTemplates')
        .doc(scheduleTemplate.id)
        .update({
          'trainingTypeId': trainingType.id,
          'trainingTypeRef': trainingTypeRef,
          'trainerId': trainerId,
          'trainerRef': trainerRef,
          'weekday': weekday,
          'startHour': startHour,
          'startMinute': startMinute,
          'durationMinutes': durationMinutes,
          'capacity': capacity,
          'updatedBy': currentUser.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    final oldTemplateTime = _formatTemplateTime(
      startHour: oldStartHour,
      startMinute: oldStartMinute,
    );

    final newTemplateTime = _formatTemplateTime(
      startHour: startHour,
      startMinute: startMinute,
    );

    final oldSchedule = AppTexts.scheduleTimeLabel(
      weekday: _weekdayLabel(oldWeekday),
      time: oldTemplateTime,
    );

    final newSchedule = AppTexts.scheduleTimeLabel(
      weekday: _weekdayLabel(weekday),
      time: newTemplateTime,
    );

    await _createScheduleSystemMessage(
      currentUser: currentUser,
      sourceAction: 'schedule_template_updated',
      textLocalized: ScheduleSystemMessageLocalizer.templateUpdated(
        trainingNameLocalized: trainingType.effectiveNameLocalized,
        fallbackTrainingName: trainingType.name,
        oldWeekday: oldWeekday,
        oldTime: oldTemplateTime,
        newWeekday: weekday,
        newTime: newTemplateTime,
      ),
      text: AppTexts.scheduleMessageTemplateUpdated(
        trainingName: trainingType.name,
        oldSchedule: oldSchedule,
        newSchedule: newSchedule,
      ),
    );

    await _createScheduleAuditLog(
      currentUser: currentUser,
      action: 'schedule_template_updated',
      targetType: 'schedule_template',
      targetId: scheduleTemplate.id,
      title: AppTexts.auditScheduleTemplateUpdatedTitle,
      description: AppTexts.auditScheduleTemplateUpdatedDescription(
        trainingType.name,
      ),
      changes: {
        'trainingTypeId': {
          'oldValue': scheduleTemplate.trainingTypeId,
          'newValue': trainingType.id,
        },
        'trainerId': {
          'oldValue': scheduleTemplate.trainerId,
          'newValue': trainerId,
        },
        'weekday': {'oldValue': scheduleTemplate.weekday, 'newValue': weekday},
        'startHour': {
          'oldValue': scheduleTemplate.startHour,
          'newValue': startHour,
        },
        'startMinute': {
          'oldValue': scheduleTemplate.startMinute,
          'newValue': startMinute,
        },
        'durationMinutes': {
          'oldValue': scheduleTemplate.durationMinutes,
          'newValue': durationMinutes,
        },
        'capacity': {
          'oldValue': scheduleTemplate.capacity,
          'newValue': capacity,
        },
      },
    );
  }

  Future<void> deactivateScheduleTemplate({
    required ScheduleTemplate scheduleTemplate,
    required User currentUser,
  }) async {
    String trainingName = AppTexts.unknownTraining;
    Map<String, String> trainingNameLocalized = {};

    final trainingTypeSnapshot = await _firestore
        .collection('trainingTypes')
        .doc(scheduleTemplate.trainingTypeId)
        .get();

    if (trainingTypeSnapshot.exists) {
      final trainingTypeData = trainingTypeSnapshot.data() ?? {};
      trainingName = LocalizedFirestoreText.resolve(
        trainingTypeData,
        field: 'name',
        localizedField: 'nameLocalized',
        fallback: AppTexts.unknownTraining,
      );
      trainingNameLocalized = LocalizedFirestoreText.map(
        trainingTypeData['nameLocalized'],
      );
    }

    await _firestore
        .collection('scheduleTemplates')
        .doc(scheduleTemplate.id)
        .update({
          'isActive': false,
          'deactivatedBy': currentUser.uid,
          'deactivatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    final templateTime = _formatTemplateTime(
      startHour: scheduleTemplate.startHour,
      startMinute: scheduleTemplate.startMinute,
    );

    await _createScheduleSystemMessage(
      currentUser: currentUser,
      sourceAction: 'schedule_template_deactivated',
      textLocalized: ScheduleSystemMessageLocalizer.templateDeactivated(
        trainingNameLocalized: trainingNameLocalized,
        fallbackTrainingName: trainingName,
        weekday: scheduleTemplate.weekday,
        time: templateTime,
      ),
      text: AppTexts.scheduleMessageTemplateDeactivated(
        trainingName: trainingName,
        weekday: _weekdayLabel(scheduleTemplate.weekday),
        time: templateTime,
      ),
    );

    await _createScheduleAuditLog(
      currentUser: currentUser,
      action: 'schedule_template_deactivated',
      targetType: 'schedule_template',
      targetId: scheduleTemplate.id,
      title: AppTexts.auditScheduleTemplateDeactivatedTitle,
      description: AppTexts.auditScheduleTemplateDeactivatedDescription(
        trainingName,
      ),
      changes: {
        'isActive': {'oldValue': true, 'newValue': false},
      },
    );
  }

  Future<void> _checkScheduleTemplateOverlap({
    required int weekday,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
    String? ignoredTemplateId,
  }) async {
    final newStartMinutes = startHour * 60 + startMinute;
    final newEndMinutes = newStartMinutes + durationMinutes;

    final templatesSnapshot = await _firestore
        .collection('scheduleTemplates')
        .where('weekday', isEqualTo: weekday)
        .where('isActive', isEqualTo: true)
        .get();

    final hasOverlap = templatesSnapshot.docs.any((document) {
      if (ignoredTemplateId != null && document.id == ignoredTemplateId) {
        return false;
      }

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
    final now = DateTime.now();
    final latestAllowedDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 14, hours: 23, minutes: 59));

    if (startTime.isAfter(latestAllowedDate)) {
      throw Exception('training-session-too-far-in-future');
    }
    final sessionRef = _firestore.collection('trainingSessions').doc(sessionId);
    final trainerRef = _firestore.collection('users').doc(trainerId);

    final trainerSnapshot = await trainerRef.get();
    final trainerData = trainerSnapshot.data();

    final trainerRole = trainerData?['role'] as String? ?? '';
    final trainerName = _resolveUserDisplayName(trainerData);

    DateTime? oldTrainingStartTime;
    int? oldCapacity;
    String? oldTrainerId;

    final editedSessionSnapshot = await sessionRef.get();
    final editedSessionData = editedSessionSnapshot.data() ?? {};
    final editedTemplateId = editedSessionData['templateId'] as String?;

    await _checkTrainingSessionOverlap(
      startTime: startTime,
      endTime: endTime,
      ignoredSessionId: sessionId,
    );

    await _checkTrainingSessionTemplateOverlap(
      startTime: startTime,
      endTime: endTime,
      ignoredTemplateId: editedTemplateId,
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

      oldCapacity = sessionData['capacity'] as int?;
      oldTrainerId = sessionData['trainerId'] as String?;
      oldTrainingStartTime = existingStartTime;

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
        'trainerName': trainerName,
        'trainerRole': trainerRole,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'durationMinutes': durationMinutes,
        'capacity': capacity,
        'reservedCount': startTimeChanged ? 0 : reservedCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    final oldStartTime = oldTrainingStartTime;

    if (oldStartTime != null) {
      final startTimeChanged =
          oldStartTime.millisecondsSinceEpoch !=
          startTime.millisecondsSinceEpoch;

      await _createScheduleSystemMessage(
        currentUser: currentUser,
        sourceAction: startTimeChanged
            ? 'training_session_time_changed'
            : 'training_session_updated',
        textLocalized: startTimeChanged
            ? ScheduleSystemMessageLocalizer.trainingSessionTimeChanged(
                trainingNameLocalized: item.trainingType.effectiveNameLocalized,
                fallbackTrainingName: item.trainingType.name,
                oldDate: _formatDate(oldStartTime),
                oldTime: _formatTime(oldStartTime),
                newDate: _formatDate(startTime),
                newTime: _formatTime(startTime),
              )
            : ScheduleSystemMessageLocalizer.trainingSessionUpdated(
                trainingNameLocalized: item.trainingType.effectiveNameLocalized,
                fallbackTrainingName: item.trainingType.name,
                date: _formatDate(startTime),
                time: _formatTime(startTime),
              ),
        text: startTimeChanged
            ? AppTexts.scheduleMessageTrainingSessionTimeChanged(
                trainingName: item.trainingType.name,
                oldDate: _formatDate(oldStartTime),
                oldTime: _formatTime(oldStartTime),
                newDate: _formatDate(startTime),
                newTime: _formatTime(startTime),
              )
            : AppTexts.scheduleMessageTrainingSessionUpdated(
                trainingName: item.trainingType.name,
                date: _formatDate(startTime),
                time: _formatTime(startTime),
              ),
      );

      await _createScheduleAuditLog(
        currentUser: currentUser,
        action: startTimeChanged
            ? 'training_session_time_changed'
            : 'training_session_updated',
        targetType: 'training_session',
        targetId: sessionId,
        title: startTimeChanged
            ? AppTexts.auditTrainingSessionTimeChangedTitle
            : AppTexts.auditTrainingSessionUpdatedTitle,
        description: startTimeChanged
            ? AppTexts.auditTrainingSessionTimeChangedDescription(
                item.trainingType.name,
              )
            : AppTexts.auditTrainingSessionUpdatedDescription(
                item.trainingType.name,
              ),
        changes: {
          'trainerId': {'oldValue': oldTrainerId, 'newValue': trainerId},
          'startTime': {
            'oldValue': oldStartTime.toIso8601String(),
            'newValue': startTime.toIso8601String(),
          },
          'capacity': {'oldValue': oldCapacity, 'newValue': capacity},
        },
      );
    }
  }

  Future<void> cancelTrainingSessionWithReservations({
    required String sessionId,
    required User currentUser,
    required String? role,
  }) async {
    final sessionRef = _firestore.collection('trainingSessions').doc(sessionId);

    String cancelledTrainingName = AppTexts.unknownTraining;
    Map<String, String> cancelledTrainingNameLocalized = {};
    DateTime? cancelledTrainingStartTime;

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
      cancelledTrainingStartTime = (sessionData['startTime'] as Timestamp?)
          ?.toDate();

      final cancelledTrainingTypeId =
          sessionData['trainingTypeId'] as String? ?? '';

      if (cancelledTrainingTypeId.isNotEmpty) {
        final trainingTypeSnapshot = await transaction.get(
          _firestore.collection('trainingTypes').doc(cancelledTrainingTypeId),
        );

        if (trainingTypeSnapshot.exists) {
          final trainingTypeData = trainingTypeSnapshot.data() ?? {};
          cancelledTrainingName = LocalizedFirestoreText.resolve(
            trainingTypeData,
            field: 'name',
            localizedField: 'nameLocalized',
            fallback: AppTexts.unknownTraining,
          );
          cancelledTrainingNameLocalized = LocalizedFirestoreText.map(
            trainingTypeData['nameLocalized'],
          );
        }
      }

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

    if (cancelledTrainingStartTime != null) {
      await _createScheduleSystemMessage(
        currentUser: currentUser,
        sourceAction: 'training_session_cancelled',
        textLocalized: ScheduleSystemMessageLocalizer.trainingSessionCancelled(
          trainingNameLocalized: cancelledTrainingNameLocalized,
          fallbackTrainingName: cancelledTrainingName,
          date: _formatDate(cancelledTrainingStartTime!),
          time: _formatTime(cancelledTrainingStartTime!),
        ),
        text: AppTexts.scheduleMessageTrainingSessionCancelled(
          trainingName: cancelledTrainingName,
          date: _formatDate(cancelledTrainingStartTime!),
          time: _formatTime(cancelledTrainingStartTime!),
        ),
      );

      await _createScheduleAuditLog(
        currentUser: currentUser,
        action: 'training_session_cancelled',
        targetType: 'training_session',
        targetId: sessionId,
        title: AppTexts.auditTrainingSessionCancelledTitle,
        description: AppTexts.auditTrainingSessionCancelledDescription(
          cancelledTrainingName,
        ),
        changes: {
          'status': {'oldValue': 'scheduled', 'newValue': 'cancelled'},
          'isActive': {'oldValue': true, 'newValue': false},
        },
      );
    }
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

  Future<void> _checkTrainingSessionTemplateOverlap({
    required DateTime startTime,
    required DateTime endTime,
    String? ignoredTemplateId,
  }) async {
    final weekday = startTime.weekday;
    final newStartMinutes = startTime.hour * 60 + startTime.minute;
    final newEndMinutes = endTime.hour * 60 + endTime.minute;

    final templatesSnapshot = await _firestore
        .collection('scheduleTemplates')
        .where('weekday', isEqualTo: weekday)
        .where('isActive', isEqualTo: true)
        .get();

    final hasOverlap = templatesSnapshot.docs.any((document) {
      if (ignoredTemplateId != null && document.id == ignoredTemplateId) {
        return false;
      }

      final data = document.data();

      if (!_isTemplateValidForDate(data, startTime)) {
        return false;
      }

      final existingStartHour = data['startHour'] as int? ?? 0;
      final existingStartMinute = data['startMinute'] as int? ?? 0;
      final existingDurationMinutes = data['durationMinutes'] as int? ?? 0;

      final existingStartMinutes = existingStartHour * 60 + existingStartMinute;
      final existingEndMinutes = existingStartMinutes + existingDurationMinutes;

      return existingStartMinutes < newEndMinutes &&
          existingEndMinutes > newStartMinutes;
    });

    if (hasOverlap) {
      throw Exception('training-session-overlap');
    }
  }

  bool _isTemplateValidForDate(
    Map<String, dynamic> templateData,
    DateTime date,
  ) {
    final validFrom = (templateData['validFrom'] as Timestamp?)?.toDate();
    final validUntil = (templateData['validUntil'] as Timestamp?)?.toDate();

    final selectedDate = DateTime(date.year, date.month, date.day);

    if (validFrom != null) {
      final validFromDate = DateTime(
        validFrom.year,
        validFrom.month,
        validFrom.day,
      );

      if (selectedDate.isBefore(validFromDate)) {
        return false;
      }
    }

    if (validUntil != null) {
      final validUntilDate = DateTime(
        validUntil.year,
        validUntil.month,
        validUntil.day,
      );

      if (selectedDate.isAfter(validUntilDate)) {
        return false;
      }
    }

    return true;
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

  Future<void> _createScheduleSystemMessage({
    required User currentUser,
    required String text,
    required Map<String, String> textLocalized,
    required String sourceAction,
  }) async {
    await _firestore.collection('public_messages').add({
      'text': text,
      'textLocalized': textLocalized,
      'authorId': currentUser.uid,
      'authorName': AppTexts.appName,
      'authorRole': '',
      'type': 'system',
      'source': 'schedule',
      'sourceAction': sourceAction,
      'createdBy': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day.$month.$year';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatTemplateTime({
    required int startHour,
    required int startMinute,
  }) {
    final hour = startHour.toString().padLeft(2, '0');
    final minute = startMinute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _weekdayLabel(int weekday) {
    if (weekday < 1 || weekday > AppTexts.weekdays.length) {
      return '';
    }

    return AppTexts.weekdays[weekday - 1].toLowerCase();
  }

  Future<void> _createScheduleAuditLog({
    required User currentUser,
    required String action,
    required String targetType,
    required String targetId,
    required String title,
    required String description,
    Map<String, dynamic> changes = const {},
  }) async {
    await _auditLogService.createLogWithUsers(
      category: 'schedule',
      action: action,
      targetType: targetType,
      targetId: targetId,
      targetUserId: '',
      actor: currentUser,
      title: title,
      description: description,
      changes: changes,
    );
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
