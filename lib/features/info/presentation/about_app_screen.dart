import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.aboutApp)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Text(
                  AppTexts.aboutAppDescription,
                  textAlign: TextAlign.start,
                  style: textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.description_outlined),
                    title: Text(AppTexts.legalDocuments),
                  ),
                  _LegalLinkRow(
                    icon: Icons.article_outlined,
                    title: AppTexts.businessTerms,
                    subtitle: AppTexts.legalDocumentsInfo,
                    onTap: () => _openUrl(AppTexts.bodyFitClubWebsite),
                  ),
                  _LegalLinkRow(
                    icon: Icons.privacy_tip_outlined,
                    title: AppTexts.privacyPolicy,
                    subtitle: AppTexts.legalDocumentsInfo,
                    onTap: () => _openUrl(AppTexts.bodyFitClubWebsite),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalLinkRow extends StatelessWidget {
  const _LegalLinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: AppSpacing.iconTextGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
