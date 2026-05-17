import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/info/presentation/about_app_screen.dart';
import '../../features/info/presentation/about_us_screen.dart';
import '../../features/info/presentation/price_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

enum AppMenuAction {
  login,
  settings,
  priceList,
  aboutUs,
  aboutApp,
  logout,
  close,
}

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({
    super.key,
    required this.showLogin,
    required this.showLogout,
    this.onLogout,
  });

  final bool showLogin;
  final bool showLogout;
  final FutureOr<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppMenuAction>(
      tooltip: AppTexts.menu,
      icon: const Icon(Icons.menu),
      iconColor: Theme.of(context).appBarTheme.foregroundColor,
      color: Theme.of(context).cardColor,
      onSelected: (value) async {
        if (value == AppMenuAction.close) {
          return;
        }

        if (value == AppMenuAction.login) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
        }

        if (value == AppMenuAction.settings) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }

        if (value == AppMenuAction.priceList) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PriceListScreen()));
        }

        if (value == AppMenuAction.aboutUs) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AboutUsScreen()));
        }

        if (value == AppMenuAction.aboutApp) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AboutAppScreen()));
        }

        if (value == AppMenuAction.logout) {
          await onLogout?.call();
        }
      },
      itemBuilder: (context) => [
        if (showLogin)
          _menuItem(
            context: context,
            value: AppMenuAction.login,
            icon: Icons.login,
            text: AppTexts.login,
          ),
        _menuItem(
          context: context,
          value: AppMenuAction.settings,
          icon: Icons.settings_outlined,
          text: AppTexts.settings,
        ),
        _menuItem(
          context: context,
          value: AppMenuAction.priceList,
          icon: Icons.euro_outlined,
          text: AppTexts.priceList,
        ),
        _menuItem(
          context: context,
          value: AppMenuAction.aboutUs,
          icon: Icons.groups_outlined,
          text: AppTexts.aboutUs,
        ),
        _menuItem(
          context: context,
          value: AppMenuAction.aboutApp,
          icon: Icons.info_outline,
          text: AppTexts.aboutApp,
        ),
        if (showLogout)
          _menuItem(
            context: context,
            value: AppMenuAction.logout,
            icon: Icons.logout,
            text: AppTexts.logout,
          ),
        _menuItem(
          context: context,
          value: AppMenuAction.close,
          icon: Icons.close,
          text: AppTexts.close,
        ),
      ],
    );
  }

  PopupMenuItem<AppMenuAction> _menuItem({
    required BuildContext context,
    required AppMenuAction value,
    required IconData icon,
    required String text,
  }) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(text),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
