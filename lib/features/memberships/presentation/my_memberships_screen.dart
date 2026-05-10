import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../data/membership_service.dart';
import '../domain/membership.dart';
import 'membership_detail_screen.dart';

class MyMembershipsScreen extends StatelessWidget {
  const MyMembershipsScreen({super.key});

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day.$month.$year';
  }

  String _membershipStateLabel(Membership membership) {
    if (membership.status != 'active') {
      return AppTexts.membershipStatusInactive;
    }

    if (!membership.isValidNow) {
      return AppTexts.membershipStatusExpired;
    }

    if (!membership.hasRemainingEntries) {
      return AppTexts.membershipStatusUsedUp;
    }

    return AppTexts.membershipStatusActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Membership>>(
        stream: MembershipService().watchMyMemberships(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppTexts.membershipLoadError));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final memberships = snapshot.data ?? [];

          if (memberships.isEmpty) {
            return const Center(child: Text(AppTexts.noMemberships));
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: memberships.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final membership = memberships[index];
              final isCurrent =
                  membership.isActive &&
                  membership.isValidNow &&
                  membership.hasRemainingEntries;

              return Opacity(
                opacity: isCurrent ? 1 : 0.55,
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.card_membership),
                    title: Text(membership.planName),
                    subtitle: Text(
                      '${AppTexts.status}: ${_membershipStateLabel(membership)}\n'
                      '${AppTexts.validUntil}: ${_formatDate(membership.validUntil)}\n'
                      '${AppTexts.entriesRemaining}: ${membership.entriesRemaining ?? '-'}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MembershipDetailScreen(
                            membership: membership,
                            isAdmin: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
