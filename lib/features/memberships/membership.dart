import 'package:cloud_firestore/cloud_firestore.dart';

/* Reprezentuje konkrétnu permanentku priradenú používateľovi
   z kolekcie memberships. */
class Membership {
  const Membership({
    required this.id,
    required this.userId,
    required this.planId,
    required this.entriesTotal,
    required this.entriesRemaining,
    required this.entriesPerDay,
    required this.validFrom,
    required this.validUntil,
    required this.status,
  });

  final String id;
  final String userId;
  final String planId;
  final int? entriesTotal;
  final int? entriesRemaining;
  final int? entriesPerDay;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String status;

  bool get isActive => status == 'active';

  bool get isValidNow {
    final now = DateTime.now();

    if (!isActive || validFrom == null || validUntil == null) {
      return false;
    }

    return !now.isBefore(validFrom!) && !now.isAfter(validUntil!);
  }

  bool get hasRemainingEntries {
    if (entriesTotal == null) {
      return true;
    }

    return (entriesRemaining ?? 0) > 0;
  }

  factory Membership.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Membership(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      planId: data['planId'] as String? ?? '',
      entriesTotal: data['entriesTotal'] as int?,
      entriesRemaining: data['entriesRemaining'] as int?,
      entriesPerDay: data['entriesPerDay'] as int?,
      validFrom: (data['validFrom'] as Timestamp?)?.toDate(),
      validUntil: (data['validUntil'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'active',
    );
  }
}