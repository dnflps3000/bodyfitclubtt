import 'package:cloud_firestore/cloud_firestore.dart';

/* Reprezentuje rezerváciu používateľa na konkrétny tréningový termín
   z kolekcie reservations. */
class Reservation {
  const Reservation({
    required this.id,
    required this.userId,
    required this.trainingSessionId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String trainingSessionId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == 'active';

  factory Reservation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Reservation(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      trainingSessionId: data['trainingSessionId'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
