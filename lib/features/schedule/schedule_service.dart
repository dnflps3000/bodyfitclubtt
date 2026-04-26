import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'schedule_item.dart';
import 'training_session.dart';
import 'training_type.dart';

/* Načítava dáta z Firestore z kolekcií trainingSessions, trainingTypes a users
   a skladá ich do zoznamu položiek rozvrhu. */
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

  Stream<List<TrainingType>> watchTrainingTypes() {
    return _firestore
        .collection('trainingTypes')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final trainingTypes =
          snapshot.docs.map(TrainingType.fromFirestore).toList();

      trainingTypes.sort((a, b) => a.name.compareTo(b.name));
      return trainingTypes;
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

    final existingTrainingType =
        await _firestore.collection('trainingTypes').doc(trainingTypeId).get();

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
    required DateTime startTime,
    required int durationMinutes,
    required int capacity,
  }) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    final currentUserRef = _firestore.collection('users').doc(currentUser.uid);
    final trainingTypeRef =
        _firestore.collection('trainingTypes').doc(trainingType.id);

    final overlappingSessions = await _firestore
        .collection('trainingSessions')
        .where('startTime', isLessThan: Timestamp.fromDate(endTime))
        .get();

    final hasOverlap = overlappingSessions.docs.any((document) {
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

    await _firestore.collection('trainingSessions').add({
      'trainingTypeId': trainingType.id,
      'trainingTypeRef': trainingTypeRef,
      'trainerId': currentUser.uid,
      'trainerRef': currentUserRef,
      'createdBy': currentUser.uid,
      'createdByRef': currentUserRef,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'capacity': capacity,
      'reservedCount': 0,
      'status': 'scheduled',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTrainingSession(String sessionId) async {
    await _firestore.collection('trainingSessions').doc(sessionId).update({
      'isActive': false,
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
}