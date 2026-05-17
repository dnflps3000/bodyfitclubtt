import 'package:flutter/material.dart';

import '../../../core/constants/membership_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../memberships/data/membership_service.dart';
import '../../memberships/domain/membership_plan.dart';

class PriceListScreen extends StatelessWidget {
  const PriceListScreen({super.key});

  String _formatPrice(MembershipPlan plan) {
    return '${plan.price.toStringAsFixed(2)} ${plan.currency}';
  }

  String _audienceLabel(String audience) {
    switch (audience) {
      case 'normal':
        return AppTexts.priceListAudienceNormal;
      case 'discount':
        return AppTexts.priceListAudienceDiscount;
      case 'all':
        return AppTexts.priceListAudienceAll;
      default:
        return audience;
    }
  }

  String _validityLabel(MembershipPlan plan) {
    if (plan.id == MembershipPlanIds.monthlyOneEntryPerDay) {
      return AppTexts.monthCount(1);
    }

    if (plan.validityDays >= 30 && plan.validityDays % 30 == 0) {
      final months = plan.validityDays ~/ 30;
      return AppTexts.monthCount(months);
    }

    if (plan.validityDays <= 0) {
      return AppTexts.notSet;
    }

    return AppTexts.dayCount(plan.validityDays);
  }

  Widget _buildPlanCard(BuildContext context, MembershipPlan plan) {
    final details = <String>[
      '${AppTexts.price}: ${_formatPrice(plan)}',
      '${AppTexts.priceListAudience}: ${_audienceLabel(plan.audience)}',
    ];

    if (plan.purchaseCategory == MembershipPurchaseCategories.membership) {
      details.add('${AppTexts.validUntil}: ${_validityLabel(plan)}');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final detail in details)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(detail),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<MembershipPlan> plans,
  }) {
    if (plans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        for (final plan in plans) ...[
          _buildPlanCard(context, plan),
          const SizedBox(height: AppSpacing.cardGap),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.priceList)),
      body: StreamBuilder<List<MembershipPlan>>(
        stream: MembershipService().watchActiveMembershipPlans(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(AppTexts.membershipPlansLoadError));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = snapshot.data ?? [];

          if (plans.isEmpty) {
            return Center(child: Text(AppTexts.noMemberships));
          }

          final singleEntryPlans = plans.where((plan) {
            return plan.purchaseCategory ==
                MembershipPurchaseCategories.singleEntry;
          }).toList();

          final membershipPlans = plans.where((plan) {
            return plan.purchaseCategory ==
                MembershipPurchaseCategories.membership;
          }).toList();

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              _buildSection(
                context: context,
                title: AppTexts.singleEntries,
                plans: singleEntryPlans,
              ),
              if (singleEntryPlans.isNotEmpty && membershipPlans.isNotEmpty)
                const SizedBox(height: AppSpacing.sectionGap),
              _buildSection(
                context: context,
                title: AppTexts.priceListMemberships,
                plans: membershipPlans,
              ),
            ],
          );
        },
      ),
    );
  }
}
