import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
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
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.palette_outlined),
                      title: Text(AppTexts.appearance),
                      subtitle: Text(
                        AppTexts.appearanceDescription,
                        textAlign: TextAlign.justify,
                      ),
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
              const SizedBox(height: AppSpacing.cardGap),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.language_outlined),
                  title: Text(AppTexts.language),
                  subtitle: Text(
                    AppTexts.languageComingSoon,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.cardGap),
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.touch_app_outlined),
                      title: Text(AppTexts.menuPosition),
                      subtitle: Text(
                        AppTexts.menuPositionDescription,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SwitchListTile(
                      value: settingsService.isRightHanded,
                      title: Text(
                        settingsService.isRightHanded
                            ? AppTexts.rightHanded
                            : AppTexts.leftHanded,
                      ),
                      subtitle: Text(
                        settingsService.isRightHanded
                            ? AppTexts.menuRightPositionDescription
                            : AppTexts.menuLeftPositionDescription,
                      ),
                      secondary: Icon(
                        settingsService.isRightHanded
                            ? Icons.keyboard_arrow_right
                            : Icons.keyboard_arrow_left,
                      ),
                      onChanged: settingsService.setIsRightHanded,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
