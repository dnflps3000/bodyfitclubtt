import 'training_session.dart';
import 'training_type.dart';

/* Spája konkrétny termín tréningu s jeho typom cvičenia a 
 menom trénera, aby sa to dalo jednoducho zobraziť v UI.*/
class ScheduleItem {
  const ScheduleItem({
    required this.session,
    required this.trainingType,
    required this.trainerName,
  });

  final TrainingSession session;
  final TrainingType trainingType;
  final String trainerName;
}
