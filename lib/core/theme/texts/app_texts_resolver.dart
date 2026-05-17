import '../../../features/settings/data/settings_service.dart';
import 'app_texts_sk.dart';
import 'app_texts_en.dart';
import 'app_texts_de.dart';
import 'app_texts_pl.dart';
import 'app_texts_hu.dart';
import 'app_texts_uk.dart';
import 'app_texts_ru.dart';
import 'app_texts_sr.dart';
import 'app_texts_fr.dart';
import 'app_texts_cs.dart';

class AppTextsResolver {
  static String get languageCode => SettingsService.instance.languageCode;

  static Map<String, String> get _currentTexts {
    switch (languageCode) {
      case 'en':
        return appTextsEn;
      case 'de':
        return appTextsDe;
      case 'fr':
        return appTextsFr;
      case 'pl':
        return appTextsPl;
      case 'hu':
        return appTextsHu;
      case 'uk':
        return appTextsUk;
      case 'ru':
        return appTextsRu;
      case 'sr':
        return appTextsSr;
      case 'cs':
        return appTextsCs;
      case 'sk':
      default:
        return appTextsSk;
    }
  }

  static Map<String, List<String>> get _currentLists {
    switch (languageCode) {
      case 'en':
        return appTextListsEn;
      case 'de':
        return appTextListsDe;
      case 'fr':
        return appTextListsFr;
      case 'pl':
        return appTextListsPl;
      case 'hu':
        return appTextListsHu;
      case 'uk':
        return appTextListsUk;
      case 'ru':
        return appTextListsRu;
      case 'sr':
        return appTextListsSr;
      case 'cs':
        return appTextListsCs;
      case 'sk':
      default:
        return appTextListsSk;
    }
  }

  static String text(String key) {
    return _currentTexts[key] ?? appTextsSk[key] ?? key;
  }

  static List<String> list(String key) {
    return _currentLists[key] ?? appTextListsSk[key] ?? const <String>[];
  }

  static bool get isEnglish => languageCode == 'en';

  static bool get isGerman => languageCode == 'de';

  static bool get isFrench => languageCode == 'fr';

  static bool get isPolish => languageCode == 'pl';

  static bool get isHungarian => languageCode == 'hu';

  static bool get isUkrainian => languageCode == 'uk';

  static bool get isRussian => languageCode == 'ru';

  static bool get isSerbian => languageCode == 'sr';

  static bool get isCzech => languageCode == 'cs';
}
