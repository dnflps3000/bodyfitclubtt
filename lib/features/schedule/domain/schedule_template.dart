import 'package:cloud_firestore/cloud_firestore.dart';

/*  Reprezentuje pravidelnú týždennú šablónu rozvrhu z kolekcie scheduleTemplates,
 z ktorej sa neskôr budú automaticky generovať konkrétne tréningové termíny.*/
class ScheduleTemplate {
  const ScheduleTemplate({
    required this.id,
    required this.trainingTypeId,
    required this.trainerId,
    required this.weekday,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
    required this.capacity,
    required this.isActive,
    required this.validFrom,
    required this.validUntil,
  });

  final String id;
  final String trainingTypeId;
  final String trainerId;
  final int weekday;
  final int startHour;
  final int startMinute;
  final int durationMinutes;
  final int capacity;
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validUntil;

  factory ScheduleTemplate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return ScheduleTemplate(
      id: document.id,
      trainingTypeId: data['trainingTypeId'] as String? ?? '',
      trainerId: data['trainerId'] as String? ?? '',
      weekday: data['weekday'] as int? ?? 1,
      startHour: data['startHour'] as int? ?? 0,
      startMinute: data['startMinute'] as int? ?? 0,
      durationMinutes: data['durationMinutes'] as int? ?? 60,
      capacity: data['capacity'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      validFrom: (data['validFrom'] as Timestamp?)?.toDate(),
      validUntil: (data['validUntil'] as Timestamp?)?.toDate(),
    );
  }
}
