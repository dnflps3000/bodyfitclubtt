import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../schedule/training_session.dart';
import 'reservation.dart';

/* Obsahuje logiku rezervovania tréningov a načítania rezervácií
   prihláseného používateľa. */
class ReservationService {
  ReservationService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Reservation>> watchMyReservations() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('reservations')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final reservations =
          snapshot.docs.map(Reservation.fromFirestore).toList();

      reservations.sort((a, b) {
        final firstCreatedAt = a.createdAt;
        final secondCreatedAt = b.createdAt;

        if (firstCreatedAt == null && secondCreatedAt == null) {
          return 0;
        }

        if (firstCreatedAt == null) {
          return 1;
        }

        if (secondCreatedAt == null) {
          return -1;
        }

        return secondCreatedAt.compareTo(firstCreatedAt);
      });

      return reservations;
    });
  }

  Future<void> reserveTrainingSession({
    required TrainingSession session,
    required User currentUser,
  }) async {
    final sessionRef =
        _firestore.collection('trainingSessions').doc(session.id);

    final userRef = _firestore.collection('users').doc(currentUser.uid);

    final reservationId = '${session.id}_${currentUser.uid}';
    final reservationRef =
        _firestore.collection('reservations').doc(reservationId);

    await _firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);
      final reservationSnapshot = await transaction.get(reservationRef);

      if (!sessionSnapshot.exists) {
        throw Exception('training-session-not-found');
      }

      final sessionData = sessionSnapshot.data() ?? {};

      final isActive = sessionData['isActive'] as bool? ?? false;
      final status = sessionData['status'] as String? ?? '';
      final capacity = sessionData['capacity'] as int? ?? 0;
      final reservedCount = sessionData['reservedCount'] as int? ?? 0;
      final trainerId = sessionData['trainerId'] as String? ?? '';

      if (trainerId == currentUser.uid) {
        throw Exception('trainer-cannot-reserve-own-session');
      }

      if (!isActive || status != 'scheduled') {
        throw Exception('training-session-not-available');
      }

      if (reservedCount >= capacity) {
        throw Exception('training-session-full');
      }

      if (reservationSnapshot.exists) {
        final reservationData = reservationSnapshot.data() ?? {};
        final reservationStatus =
            reservationData['status'] as String? ?? 'active';

        if (reservationStatus == 'active') {
          throw Exception('reservation-already-exists');
        }
      }

      transaction.set(
        reservationRef,
        {
          'userId': currentUser.uid,
          'userRef': userRef,
          'trainingSessionId': session.id,
          'trainingSessionRef': sessionRef,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.update(sessionRef, {
        'reservedCount': reservedCount + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}