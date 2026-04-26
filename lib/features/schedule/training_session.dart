import 'package:cloud_firestore/cloud_firestore.dart';
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

  int get freeSpots => capacity - reservedCount;

  bool get hasFreeSpots => freeSpots > 0;

  bool get isScheduled => status == 'scheduled';

  factory TrainingSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return TrainingSession(
      id: document.id,
      trainingTypeId: data['trainingTypeId'] as String? ?? '',
      trainerId: data['trainerId'] as String? ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      capacity: data['capacity'] as int? ?? 0,
      reservedCount: data['reservedCount'] as int? ?? 0,
      status: data['status'] as String? ?? 'scheduled',
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}