import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodyfitclubtt/features/payment/presentation/payment_screen.dart';
import '../../core/theme/app_texts.dart';
import '../../core/constants/membership_constants.dart';
import '../memberships/membership.dart';
import '../memberships/membership_service.dart';
import '../../core/constants/app_roles.dart';
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
  StreamBuilder<List<Membership>>(
    stream: MembershipService().watchMyActiveMemberships(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Card(
          child: ListTile(
            leading: Icon(Icons.card_membership),
            title: Text(AppTexts.membershipStatus),
            subtitle: Text(AppTexts.membershipLoadError),
          ),
        );
      }

      final memberships = [...snapshot.data ?? []];

      memberships.sort((a, b) {
        final priorityCompare =
            _membershipPriority(a).compareTo(_membershipPriority(b));

        if (priorityCompare != 0) {
          return priorityCompare;
        }

        final firstValidUntil = a.validUntil;
        final secondValidUntil = b.validUntil;

        if (firstValidUntil == null && secondValidUntil == null) {
          return 0;
        }

        if (firstValidUntil == null) {
          return 1;
        }

        if (secondValidUntil == null) {
          return -1;
        }

        return firstValidUntil.compareTo(secondValidUntil);
      });

      if (memberships.isEmpty) {
        return const Card(
          child: ListTile(
            leading: Icon(Icons.card_membership),
            title: Text(AppTexts.membershipStatus),
            subtitle: Text(AppTexts.noActiveMembership),
          ),
        );
      }

      return Column(
        children: [
          for (final membership in memberships)
            Card(
              child: ListTile(
                leading: const Icon(Icons.card_membership),
                title: Text(membership.planName),
                subtitle: Text(_membershipSubtitle(membership)),
              ),
            ),
        ],
      );
    },
  ),
  const SizedBox(height: 12),

  const Card(
    child: ListTile(
      leading: Icon(Icons.event_available),
      title: Text(AppTexts.upcomingTraining),
      subtitle: Text(AppTexts.noUpcomingTraining),
    ),
  ),
  const SizedBox(height: 12),

  const Card(
    child: ListTile(
      leading: Icon(Icons.campaign_outlined),
      title: Text(AppTexts.news),
      subtitle: Text(AppTexts.newsPlaceholder),
    ),
  ),

  const SizedBox(height: 20),

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseAuth.instance.currentUser == null
        ? const Stream.empty()
        : FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
    builder: (context, snapshot) {
      final data = snapshot.data?.data();
      final role = data?['role'] as String? ?? AppRoles.user;

      if (role != AppRoles.user) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentScreen(
                    purchaseCategory: MembershipPurchaseCategories.membership,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.card_membership),
            label: const Text(AppTexts.buyMembership),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentScreen(
                    purchaseCategory: MembershipPurchaseCategories.singleEntry,
                    preselectedPlanId: MembershipPlanIds.singleEntry,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.confirmation_number_outlined),
            label: const Text(AppTexts.buySingleEntry),
          ),
        ],
      );
    },
  ),
  ],
    );
  }

    String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day.$month.$year';
  }

  int _membershipPriority(Membership membership) {
    if (membership.planId == MembershipPlanIds.sameDayNextEntry) {
      return 3;
    }

    if (membership.planId == MembershipPlanIds.singleEntry ||
        membership.planId == MembershipPlanIds.singleEntryDiscount) {
      return 2;
    }

    return 1;
  }

  String _membershipSubtitle(Membership membership) {
    final validUntil = membership.validUntil;

    if (membership.isDailyMembership) {
      final entriesPerDay = membership.entriesPerDay ?? 1;

      if (validUntil == null) {
        return '$entriesPerDay vstup denne';
      }

      return '$entriesPerDay vstup denne · ${AppTexts.validUntil}: '
          '${_formatDate(validUntil)}';
    }

    final total = membership.entriesTotal ?? 0;
    final available = membership.availableEntries;
    final reserved = membership.entriesReserved ?? 0;

    final reservedText = reserved > 0 ? ' · Alokované: $reserved' : '';

    if (validUntil == null) {
      return 'Zostáva: $available / $total$reservedText';
    }

    return 'Zostáva: $available / $total$reservedText · '
        '${AppTexts.validUntil}: ${_formatDate(validUntil)}';
  }
}