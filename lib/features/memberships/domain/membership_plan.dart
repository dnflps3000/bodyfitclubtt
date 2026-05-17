import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/membership_constants.dart';
import '../../../core/utils/localized_firestore_text.dart';

/* Reprezentuje typ permanentky alebo vstupu z kolekcie membershipPlans. */
class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.nameLocalized,
    required this.descriptionLocalized,
    required this.price,
    required this.currency,
    required this.entriesTotal,
    required this.entriesPerDay,
    required this.validityDays,
    required this.isActive,
    required this.purchaseCategory,
    required this.audience,
  });

  final String id;
  final String name;
  final String description;
  final Map<String, String> nameLocalized;
  final Map<String, String> descriptionLocalized;
  final num price;
  final String currency;
  final int? entriesTotal;
  final int? entriesPerDay;
  final int validityDays;
  final bool isActive;
  final String purchaseCategory;
  final String audience;

  bool get isEntryBased => entriesTotal != null;
  bool get isDailyLimitBased => entriesPerDay != null;

  bool get isSameDayNextEntry => id == MembershipPlanIds.sameDayNextEntry;
  bool get isDiscountOnly => audience == 'discount';
  bool get isNormalOnly => audience == 'normal';
  bool get isForEveryone => audience == 'all';

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

  factory MembershipPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    final rawAudience = data['audience'] as String?;

    final fallbackAudience =
        document.id == MembershipPlanIds.sameDayNextEntry ||
            document.id == MembershipPlanIds.monthlyOneEntryPerDay
        ? 'all'
        : document.id == MembershipPlanIds.singleEntryDiscount
        ? 'discount'
        : 'normal';

    return MembershipPlan(
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
      price: data['price'] as num? ?? 0,
      currency: data['currency'] as String? ?? 'EUR',
      entriesTotal: data['entriesTotal'] as int?,
      entriesPerDay: data['entriesPerDay'] as int?,
      validityDays: data['validityDays'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? false,
      purchaseCategory: data['purchaseCategory'] as String? ?? '',
      audience: rawAudience ?? fallbackAudience,
    );
  }
}
