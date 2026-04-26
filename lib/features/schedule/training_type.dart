import 'package:cloud_firestore/cloud_firestore.dart';
/* Reprezentuje šablónu/druh cvičenia z kolekcie trainingTypes, 
 * napríklad TRX, Joga alebo Tabata.*/
class TrainingType {
  const TrainingType({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultDurationMinutes,
    required this.defaultCapacity,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final int defaultDurationMinutes;
  final int defaultCapacity;
  final bool isActive;

  factory TrainingType.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return TrainingType(
      id: document.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      defaultDurationMinutes: data['defaultDurationMinutes'] as int? ?? 60,
      defaultCapacity: data['defaultCapacity'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}