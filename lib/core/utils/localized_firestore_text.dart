import '../../features/settings/data/settings_service.dart';

class LocalizedFirestoreText {
  const LocalizedFirestoreText._();

  static String resolve(
    Map<String, dynamic> data, {
    required String field,
    required String localizedField,
    String fallback = '',
  }) {
    final languageCode = SettingsService.instance.languageCode;
    final localizedValue = data[localizedField];

    if (localizedValue is Map) {
      final selected = localizedValue[languageCode];

      if (selected is String && selected.trim().isNotEmpty) {
        return selected;
      }

      final slovak = localizedValue['sk'];

      if (slovak is String && slovak.trim().isNotEmpty) {
        return slovak;
      }

      final english = localizedValue['en'];

      if (english is String && english.trim().isNotEmpty) {
        return english;
      }
    }

    final baseValue = data[field];

    if (baseValue is String && baseValue.trim().isNotEmpty) {
      return baseValue;
    }

    return fallback;
  }

  static Map<String, String> map(dynamic value) {
    if (value is! Map) {
      return {};
    }

    return value.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  }
}
