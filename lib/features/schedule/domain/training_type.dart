import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/localized_firestore_text.dart';

/* Reprezentuje šablónu/druh cvičenia z kolekcie trainingTypes, 
 * napríklad TRX, Joga alebo Tabata.*/
class TrainingType {
  const TrainingType({
    required this.id,
    required this.name,
    required this.description,
    required this.nameLocalized,
    required this.descriptionLocalized,
    required this.defaultDurationMinutes,
    required this.defaultCapacity,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final Map<String, String> nameLocalized;
  final Map<String, String> descriptionLocalized;
  final int defaultDurationMinutes;
  final int defaultCapacity;
  final bool isActive;

  Map<String, String> get effectiveNameLocalized {
    if (nameLocalized.isNotEmpty) {
      return nameLocalized;
    }

    return {'sk': name};
  }

  Map<String, String> get effectiveDescriptionLocalized {
    if (descriptionLocalized.isNotEmpty) {
      return descriptionLocalized;
    }

    return {'sk': description};
  }

  factory TrainingType.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return TrainingType(
      id: document.id,
      name: LocalizedFirestoreText.resolve(
        data,
        field: 'name',
        localizedField: 'nameLocalized',
      ),
      description: LocalizedFirestoreText.resolve(
        data,
        field: 'description',
        localizedField: 'descriptionLocalized',
      ),
      nameLocalized: LocalizedFirestoreText.map(data['nameLocalized']),
      descriptionLocalized: LocalizedFirestoreText.map(
        data['descriptionLocalized'],
      ),
      defaultDurationMinutes: data['defaultDurationMinutes'] as int? ?? 60,
      defaultCapacity: data['defaultCapacity'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}
