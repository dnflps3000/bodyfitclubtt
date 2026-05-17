import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/localized_firestore_text.dart';

/*Reprezentuje konkrétny termín v rozvrhu z kolekcie trainingSessions, 
  teda dátum, čas, trénera, kapacitu a stav tréningu*/
class TrainingSession {
  const TrainingSession({
    required this.id,
    required this.trainingTypeId,
    required this.trainerId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.reservedCount,
    required this.status,
    required this.isActive,
    required this.trainingName,
    required this.trainingDescription,
    required this.trainingNameLocalized,
    required this.trainingDescriptionLocalized,
    required this.trainerName,
    required this.trainerRole,
    required this.durationMinutes,
  });

  final String id;
  final String trainingTypeId;
  final String trainerId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int reservedCount;
  final String status;
  final bool isActive;
  final String trainingName;
  final String trainingDescription;
  final Map<String, String> trainingNameLocalized;
  final Map<String, String> trainingDescriptionLocalized;
  final String trainerName;
  final String trainerRole;
  final int durationMinutes;

  int get freeSpots => capacity - reservedCount;

  bool get hasFreeSpots => freeSpots > 0;

  bool get isScheduled => status == 'scheduled';

  bool get hasDenormalizedScheduleData {
    return trainingName.trim().isNotEmpty && trainerName.trim().isNotEmpty;
  }

  factory TrainingSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final startTime = (data['startTime'] as Timestamp?)?.toDate();
    final endTime = (data['endTime'] as Timestamp?)?.toDate();

    final resolvedStartTime = startTime ?? DateTime.now();
    final resolvedEndTime = endTime ?? resolvedStartTime;

    final storedDurationMinutes = data['durationMinutes'] as int?;
    final calculatedDurationMinutes = resolvedEndTime
        .difference(resolvedStartTime)
        .inMinutes;

    return TrainingSession(
      id: document.id,
      trainingTypeId: data['trainingTypeId'] as String? ?? '',
      trainerId: data['trainerId'] as String? ?? '',
      startTime: resolvedStartTime,
      endTime: resolvedEndTime,
      capacity: data['capacity'] as int? ?? 0,
      reservedCount: data['reservedCount'] as int? ?? 0,
      status: data['status'] as String? ?? 'scheduled',
      isActive: data['isActive'] as bool? ?? true,
      trainingName: LocalizedFirestoreText.resolve(
        data,
        field: 'trainingName',
        localizedField: 'trainingNameLocalized',
      ),
      trainingDescription: LocalizedFirestoreText.resolve(
        data,
        field: 'trainingDescription',
        localizedField: 'trainingDescriptionLocalized',
      ),
      trainingNameLocalized: LocalizedFirestoreText.map(
        data['trainingNameLocalized'],
      ),
      trainingDescriptionLocalized: LocalizedFirestoreText.map(
        data['trainingDescriptionLocalized'],
      ),
      trainerName: data['trainerName'] as String? ?? '',
      trainerRole: data['trainerRole'] as String? ?? '',
      durationMinutes: storedDurationMinutes ?? calculatedDurationMinutes,
    );
  }
}
