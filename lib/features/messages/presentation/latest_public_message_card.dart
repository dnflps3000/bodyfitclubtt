import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import 'public_messages_screen.dart';

class LatestPublicMessageCard extends StatelessWidget {
  const LatestPublicMessageCard({super.key});

  String _cleanAuthorName(String name) {
    var cleanedName = name.trim();

    final prefixes = [
      'Admin - ',
      '${AppTexts.roleAdmin} - ',
      '${AppTexts.roleTrainer} - ',
    ];

    for (final prefix in prefixes) {
      if (cleanedName.startsWith(prefix)) {
        cleanedName = cleanedName.replaceFirst(prefix, '').trim();
      }
    }

    return cleanedName;
  }

  String _authorLabel(Map<String, dynamic> data) {
    final storedAuthorName =
        data['authorName'] as String? ?? AppTexts.userFallback;
    final authorName = _cleanAuthorName(storedAuthorName);
    final authorRole = data['authorRole'] as String? ?? '';

    if (authorRole == AppRoles.admin) {
      return '${AppTexts.roleAdmin} - $authorName';
    }

    if (authorRole == AppRoles.trainer) {
      return '${AppTexts.roleTrainer} - $authorName';
    }

    return authorName;
  }

  void _openMessages(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PublicMessagesScreen()));
  }

  Widget _buildContent({
    required BuildContext context,
    required String subtitle,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardInnerRadius),
        onTap: () => _openMessages(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.campaign_outlined),
              const SizedBox(width: AppSpacing.iconTextGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.news,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RichText(
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: subtitle.split('\n').first,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                '\n${subtitle.split('\n').skip(1).join('\n')}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('public_messages')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.docs.isEmpty) {
          return _buildContent(
            context: context,
            subtitle: AppTexts.noPublicMessages,
          );
        }

        final data = snapshot.data!.docs.first.data();
        final text = data['text'] as String? ?? '';
        final authorLabel = _authorLabel(data);

        return _buildContent(context: context, subtitle: '$authorLabel\n$text');
      },
    );
  }
}
