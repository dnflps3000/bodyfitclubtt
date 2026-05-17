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
      appBar: AppBar(title: Text(AppTexts.settings)),
      body: AnimatedBuilder(
        animation: settingsService,
        builder: (context, _) {
          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
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
                      child: Column(
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
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.touch_app_outlined),
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
              const SizedBox(height: AppSpacing.cardGap),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: Text(AppTexts.language),
                      subtitle: Text(
                        AppTexts.languageDescription,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    RadioGroup<String>(
                      groupValue: settingsService.languageCode,
                      onChanged: (value) {
                        if (value == null) return;
                        settingsService.setLanguageCode(value);
                      },
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'en',
                            title: Text(AppTexts.languageEnglish),
                          ),
                          RadioListTile<String>(
                            value: 'cs',
                            title: Text(AppTexts.languageCzech),
                          ),
                          RadioListTile<String>(
                            value: 'fr',
                            title: Text(AppTexts.languageFrench),
                          ),
                          RadioListTile<String>(
                            value: 'hu',
                            title: Text(AppTexts.languageHungarian),
                          ),
                          RadioListTile<String>(
                            value: 'de',
                            title: Text(AppTexts.languageGerman),
                          ),
                          RadioListTile<String>(
                            value: 'pl',
                            title: Text(AppTexts.languagePolish),
                          ),
                          RadioListTile<String>(
                            value: 'ru',
                            title: Text(AppTexts.languageRussian),
                          ),
                          RadioListTile<String>(
                            value: 'sk',
                            title: Text(AppTexts.languageSlovak),
                          ),
                          RadioListTile<String>(
                            value: 'sr',
                            title: Text(AppTexts.languageSerbian),
                          ),
                          RadioListTile<String>(
                            value: 'uk',
                            title: Text(AppTexts.languageUkrainian),
                          ),
                        ],
                      ),
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
