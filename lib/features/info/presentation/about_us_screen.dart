import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const LatLng _bodyFitClubLocation = LatLng(48.3799985, 17.596876);

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openEmail() async {
    final uri = Uri(scheme: 'mailto', path: AppTexts.bodyFitClubEmail);

    await launchUrl(uri);
  }

  Future<void> _openPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(' ', ''));

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.aboutUs)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Text(
                  AppTexts.aboutUsDescription,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card_outlined),
                title: Text(AppTexts.multisport),
                subtitle: Text(
                  AppTexts.multisportInfo,
                  textAlign: TextAlign.start,
                ),
                onTap: () => _openUrl(AppTexts.bodyFitClubMultiSportUrl),
              ),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.contact_phone_outlined),
                    title: Text(AppTexts.contacts),
                  ),
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    text: AppTexts.bodyFitClubPhonePrimary,
                    onTap: () => _openPhone(AppTexts.bodyFitClubPhonePrimary),
                  ),
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    text: AppTexts.bodyFitClubPhoneSecondary,
                    onTap: () => _openPhone(AppTexts.bodyFitClubPhoneSecondary),
                  ),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    text: AppTexts.bodyFitClubEmail,
                    onTap: _openEmail,
                  ),
                  _ContactRow(
                    icon: Icons.language_outlined,
                    text: AppTexts.bodyFitClubWebsiteLabel,
                    onTap: () => _openUrl(AppTexts.bodyFitClubWebsite),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIconButton(
                          assetPath: 'assets/auth/facebook.png',
                          tooltip: AppTexts.openFacebook,
                          onTap: () =>
                              _openUrl(AppTexts.bodyFitClubFacebookUrl),
                        ),
                        const SizedBox(width: AppSpacing.iconTextGap),
                        _SocialIconButton(
                          assetPath: 'assets/contacts/instagram.png',
                          tooltip: AppTexts.openInstagram,
                          onTap: () =>
                              _openUrl(AppTexts.bodyFitClubInstagramUrl),
                        ),
                      ],
                    ),
                  ),
                  _ContactRow(
                    icon: Icons.location_on_outlined,
                    text: AppTexts.bodyFitClubOperationAddress,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.cardPadding,
                      0,
                      AppSpacing.cardPadding,
                      AppSpacing.cardPadding,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.mediumRadius,
                      ),
                      child: SizedBox(
                        height: 240,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _bodyFitClubLocation,
                            zoom: 16,
                          ),
                          gestureRecognizers: {
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          },
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                          tiltGesturesEnabled: true,
                          markers: {
                            Marker(
                              markerId: MarkerId('bodyfitclub'),
                              position: _bodyFitClubLocation,
                              infoWindow: InfoWindow(
                                title: AppTexts.bodyFitClubCompanyName,
                                snippet: AppTexts.bodyFitClubOperationAddress,
                              ),
                            ),
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.receipt_long_outlined),
                    title: Text(AppTexts.billingDetails),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.cardPadding,
                      AppSpacing.md,
                      AppSpacing.cardPadding,
                      AppSpacing.cardPadding,
                    ),
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyMedium!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTexts.bodyFitClubCompanyName),
                          SizedBox(height: AppSpacing.sm),
                          Text(AppTexts.bodyFitClubBillingAddress),
                          SizedBox(height: AppSpacing.sm),
                          Text('${AppTexts.ico}${AppTexts.bodyFitClubIco}'),
                          SizedBox(height: AppSpacing.sm),
                          Text('${AppTexts.dic}${AppTexts.bodyFitClubDic}'),
                          SizedBox(height: AppSpacing.sm),
                          Text(AppTexts.notVatPayer),
                        ],
                      ),
                    ),
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: AppSpacing.iconTextGap),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.assetPath,
    required this.tooltip,
    required this.onTap,
  });

  final String assetPath;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Image.asset(assetPath, width: 40, height: 40),
        ),
      ),
    );
  }
}
