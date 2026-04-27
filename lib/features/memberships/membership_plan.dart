import 'package:cloud_firestore/cloud_firestore.dart';

/* Reprezentuje typ permanentky alebo vstupu z kolekcie membershipPlans. */
class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.entriesTotal,
    required this.entriesPerDay,
    required this.validityDays,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final num price;
  final String currency;
  final int? entriesTotal;
  final int? entriesPerDay;
  final int validityDays;
  final bool isActive;

  bool get isEntryBased => entriesTotal != null;
  bool get isDailyLimitBased => entriesPerDay != null;

  factory MembershipPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return MembershipPlan(
      id: document.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: data['price'] as num? ?? 0,
      currency: data['currency'] as String? ?? 'EUR',
      entriesTotal: data['entriesTotal'] as int?,
      entriesPerDay: data['entriesPerDay'] as int?,
      validityDays: data['validityDays'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? false,
    );
  }
}