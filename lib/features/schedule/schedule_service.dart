import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule_item.dart';
import 'training_session.dart';
import 'training_type.dart';
/*Načítava dáta z Firestore z kolekcií trainingSessions, trainingTypes a users
 a skladá ich do zoznamu položiek rozvrhu.*/
class ScheduleService {
  ScheduleService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ScheduleItem>> watchScheduleItems() {
    return _firestore
        .collection('trainingSessions')
        .orderBy('startTime')
        .snapshots()
        .asyncMap((sessionsSnapshot) async {
      final typesSnapshot = await _firestore.collection('trainingTypes').get();
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

        final trainerName =
            trainerData?['displayName'] as String? ?? 'Neznámy tréner';

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
}