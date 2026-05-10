import 'package:flutter/material.dart';

import '../../../core/theme/app_texts.dart';
import '../data/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.settings)),
      body: AnimatedBuilder(
        animation: settingsService,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.palette_outlined),
                      title: Text(AppTexts.appearance),
                      subtitle: Text(AppTexts.appearanceDescription),
                    ),
                    RadioGroup<ThemeMode>(
                      groupValue: settingsService.themeMode,
                      onChanged: (value) {
                        if (value == null) return;
                        settingsService.setThemeMode(value);
                      },
                      child: const Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.system,
                            title: Text(AppTexts.themeSystem),
                          ),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.light,
                            title: Text(AppTexts.themeLight),
                          ),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.dark,
                            title: Text(AppTexts.themeDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.language_outlined),
                  title: Text(AppTexts.language),
                  subtitle: Text(AppTexts.languageComingSoon),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
