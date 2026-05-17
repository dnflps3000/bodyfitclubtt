import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  static const String _themeModeKey = 'theme_mode';
  static const String _menuPositionKey = 'menu_position';
  static const String _languageCodeKey = 'language_code';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _isRightHanded = true;
  bool get isRightHanded => _isRightHanded;

  String _languageCode = 'sk';
  String get languageCode => _languageCode;

  Locale get locale {
    switch (_languageCode) {
      case 'en':
        return const Locale('en', 'GB');
      case 'de':
        return const Locale('de', 'DE');
      case 'fr':
        return const Locale('fr', 'FR');
      case 'pl':
        return const Locale('pl', 'PL');
      case 'hu':
        return const Locale('hu', 'HU');
      case 'uk':
        return const Locale('uk', 'UA');
      case 'ru':
        return const Locale('ru', 'RU');
      case 'sr':
        return const Locale('sr', 'RS');
      case 'cs':
        return const Locale('cs', 'CZ');
      case 'sk':
      default:
        return const Locale('sk', 'SK');
    }
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedThemeMode = preferences.getString(_themeModeKey);
    final savedMenuPosition = preferences.getBool(_menuPositionKey);
    final savedLanguageCode = preferences.getString(_languageCodeKey);

    _themeMode = _themeModeFromString(savedThemeMode);
    _isRightHanded = savedMenuPosition ?? true;
    _languageCode = _supportedLanguageCode(savedLanguageCode);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, _themeModeToString(themeMode));
  }

  Future<void> setIsRightHanded(bool value) async {
    _isRightHanded = value;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_menuPositionKey, value);
  }

  Future<void> setLanguageCode(String value) async {
    final supportedValue = _supportedLanguageCode(value);

    _languageCode = supportedValue;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageCodeKey, supportedValue);
  }

  String _supportedLanguageCode(String? value) {
    switch (value) {
      case 'en':
      case 'de':
      case 'fr':
      case 'pl':
      case 'hu':
      case 'uk':
      case 'ru':
      case 'sr':
      case 'cs':
      case 'sk':
        return value!;
      default:
        return 'sk';
    }
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
