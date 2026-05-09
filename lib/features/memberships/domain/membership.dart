import 'package:cloud_firestore/cloud_firestore.dart';

/* Reprezentuje konkrétnu permanentku alebo vstup priradený používateľovi
   z kolekcie memberships. */
class Membership {
  const Membership({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.entriesTotal,
    required this.entriesRemaining,
    required this.entriesReserved,
    required this.entriesPerDay,
    required this.validFrom,
    required this.validUntil,
    required this.status,
  });

  final String id;
  final String userId;
  final String planId;
  final String planName;
  final int? entriesTotal;
  final int? entriesRemaining;
  final int? entriesReserved;
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

  bool get isDailyMembership {
    return entriesTotal == null && entriesPerDay != null;
  }

  bool get isEntryBasedMembership {
    return entriesTotal != null;
  }

  int get availableEntries {
    final remaining = entriesRemaining ?? 0;
    final reserved = entriesReserved ?? 0;
    final available = remaining - reserved;

    return available < 0 ? 0 : available;
  }

  bool get hasRemainingEntries {
    if (isDailyMembership) {
      return true;
    }

    return availableEntries > 0;
  }

  factory Membership.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Membership(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      planId: data['planId'] as String? ?? '',
      planName: data['planName'] as String? ?? '',
      entriesTotal: data['entriesTotal'] as int?,
      entriesRemaining: data['entriesRemaining'] as int?,
      entriesReserved: data['entriesReserved'] as int? ?? 0,
      entriesPerDay: data['entriesPerDay'] as int?,
      validFrom: (data['validFrom'] as Timestamp?)?.toDate(),
      validUntil: (data['validUntil'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'active',
    );
  }
}
