/// Centrálne texty aplikácie.
/// Neskôr by sa mohli pridať aj preklady (EN/SK).
class AppTexts {
  static const String appName = 'BodyFitClubTT';
  static const String firebaseWorks = 'Firebase funguje';
  // Home obrazovka
  static const String logoutTooltip = 'Odhlásiť';
  static const String loginTooltip = 'Prihlásiť';
  static const String loggedInUser = 'Prihlásený používateľ';
  // Auth obrazovka
  static const String loginTitle = 'Prihlásenie';
  static const String registerTitle = 'Registrácia';
  static const String continueWithGoogle = 'Pokračovať cez Google';
  static const String continueWithFacebook = 'Pokračovať cez Facebook';
  static const String or = 'alebo';
  static const String email = 'E-mail';
  static const String password = 'Heslo';
  static const String login = 'Prihlásiť';
  static const String register = 'Registrovať';
  static const String noAccountRegister = 'Nemáš účet? Registrovať';
  static const String hasAccountLogin = 'Už máš účet? Prihlásiť';
  static const String authError = 'Chyba prihlásenia';
      // Complete profile obrazovka
  static const String completeProfileTitle = 'Doplnenie profilu';
  static const String firstName = 'Meno';
  static const String lastName = 'Priezvisko';
  static const String save = 'Uložiť';
    // Validácia
  static const String fillEmailPassword = 'Vyplň e-mail aj heslo.';
  static const String invalidEmailFormat = 'Zadaj platný e-mail.';
  static const String passwordTooShort = 'Heslo musí mať aspoň 6 znakov.';
  // Firebase Auth chyby
  static const String wrongEmailOrPassword = 'Zadaný e-mail alebo heslo nie je správne.';
  static const String userAlreadyExists = 'Používateľ s týmto e-mailom už existuje.';
  static const String weakPassword = 'Zadané heslo je príliš slabé.';
  static const String tooManyRequests = 'Príliš veľa pokusov. Skús to neskôr.';
  static const String networkError = 'Skontroluj internetové pripojenie.';
  static const String signInCancelled = 'Prihlásenie bolo zrušené.';
  static const String facebookLoginFailed = 'Prihlásenie cez Facebook sa nepodarilo.';
  static const String unknownAuthError = 'Nastala neznáma chyba pri prihlásení.';
  // Overenie e-mailu
  static const String verificationEmailSent = 'Registrácia prebehla úspešne. Poslali sme ti overovací e-mail.';
  static const String emailNotVerified = 'Najskôr potvrď registráciu kliknutím na odkaz v e-maile.';
  static const String verificationEmailSentAgain = 'Overovací e-mail sme poslali znova.';
}