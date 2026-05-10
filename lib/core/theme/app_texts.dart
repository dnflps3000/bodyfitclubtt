/// Centrálne texty aplikácie.
/// Neskôr by sa mohli pridať aj preklady (EN/SK).
class AppTexts {
  static const String appName = 'Body Fit Club TT';
  static const String firebaseWorks = 'Firebase funguje';
  // Home obrazovka
  static const String logoutTooltip = 'Odhlásiť';
  static const String loggedInUser = 'Prihlásený používateľ';
  static const String loading = 'Načítavam...';
  static const String todayReservations = 'Dnešné rezervácie';
  static const String noTodayReservations =
      'Dnes nemáte rezervované žiadne cvičenie.';
  static const String nearestTraining = 'Najbližšie cvičenie';
  static const String nearestTrainings = 'Najbližšie cvičenia';
  static const String noNearestTraining =
      'Nie je naplánované žiadne najbližšie cvičenie.';
  static const String todaysTrainings = 'Dnešné cvičenia';
  static const String noTodaysTrainings =
      'Dnes nie sú naplánované žiadne cvičenia.';
  static const String myMemberships = 'Moje permanentky';
  static const String activeMembershipsCount = 'Aktívne permanentky';
  static const String availableEntriesSummary = 'Dostupné vstupy';
  static const String reservedEntriesSummary = 'Alokované vstupy';
  static const String dailyMembershipsSummary = 'Denné permanentky';
  static const String tapToShowQrCode = 'Kliknutím zobrazíte QR kód.';
  // Hlavná navigácia
  static const String home = 'Domov';
  static const String schedule = 'Rozvrh';
  static const String reservations = 'Rezervácie';
  static const String profile = 'Profil';
  // Placeholder obrazovky
  static const String membershipStatus = 'Stav permanentky';
  static const String remainingEntries = 'Zostávajúce vstupy';
  static const String upcomingTraining = 'Najbližšie dnešné cvičenie';
  static const String news = 'Novinky';
  static const String schedulePlaceholder = 'Tu bude rozvrh tréningov.';
  static const String reservationsPlaceholder = 'Tu budú rezervácie.';
  static const String emailNotProvided = 'E-mail nebol poskytnutý';
  static const String role = 'Rola';
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
  static const String editProfile = 'Upraviť profil';
  // Správa profilu
  static const String profileSaved = 'Profil bol uložený.';
  static const String profileSaveError = 'Profil sa nepodarilo uložiť.';
  static const String firstNameRequired = 'Zadajte meno.';
  static const String lastNameRequired = 'Zadajte priezvisko.';
  static const String changeProfilePhoto = 'Zmeniť profilovú fotku';
  static const String chooseFromGallery = 'Vybrať z galérie';
  static const String takePhoto = 'Odfotiť';
  static const String removePhoto = 'Odstrániť fotku';
  static const String profilePhotoUpdated = 'Profilová fotka bola uložená.';
  static const String cropProfilePhoto = 'Orezať profilovú fotku';
  static const String profilePhotoUpdateError =
      'Profilovú fotku sa nepodarilo uložiť.';
  static const String profilePhotoRemoveError =
      'Profilovú fotku sa nepodarilo odstrániť.';
  static const String publicName = 'Zobrazované meno';
  static const String publicNameHint = 'Napr. Barbora, Katka, Aďo';
  static const String publicNameRequired = 'Zadajte zobrazované meno.';
  // Validácia
  static const String fillEmailPassword = 'Vyplň e-mail aj heslo.';
  static const String invalidEmailFormat = 'Zadaj platný e-mail.';
  static const String passwordTooShort = 'Heslo musí mať aspoň 6 znakov.';
  // Firebase Auth chyby
  static const String wrongEmailOrPassword =
      'Zadaný e-mail alebo heslo nie je správne.';
  static const String userAlreadyExists =
      'Používateľ s týmto e-mailom už existuje.';
  static const String weakPassword = 'Zadané heslo je príliš slabé.';
  static const String tooManyRequests =
      'Príliš veľa pokusov. Skúste to neskôr.';
  static const String networkError = 'Skontrolujte internetové pripojenie.';
  static const String signInCancelled = 'Prihlásenie bolo zrušené.';
  static const String facebookLoginFailed =
      'Prihlásenie cez Facebook sa nepodarilo.';
  static const String unknownAuthError =
      'Nastala neznáma chyba pri prihlásení.';
  // Overenie e-mailu
  static const String verificationEmailSent =
      'Registrácia prebehla úspešne. Poslali sme vám overovací e-mail. '
      'Ak ho nevidíte v doručenej pošte, skontrolujte aj priečinok Spam.';
  static const String emailNotVerified =
      'Najskôr potvrďte registráciu kliknutím na odkaz v e-maile.';
  static const String verificationEmailSentAgain =
      'Overovací e-mail sme vám poslali opäť. '
      'Ak ho nevidíte v doručenej pošte, skontrolujte aj priečinok Spam.';
  static const String ok = 'OK';
  // Zobrazované názvy rolí
  static const String roleUser = 'Používateľ';
  static const String roleTrainer = 'Tréner';
  static const String roleAdmin = 'Administrátor';
  static const String roleUnknown = 'Neznáma rola';
  // Rozvrh tréningov
  static const String noTrainings =
      'Momentálne nie sú dostupné žiadne tréningy.';
  static const String trainer = 'Tréner';
  static const String freeSpots = 'Voľné miesta';
  static const String minutes = 'min.';
  static const String reserve = 'Rezervovať';
  static const String fullCapacity = 'Obsadené';
  static const String trainingsLoadError =
      'Nepodarilo sa načítať rozvrh tréningov.';
  // Správa rozvrhu
  static const String addTrainingType = 'Pridať typ cvičenia';
  static const String addTrainingSession = 'Pridať termín';
  static const String trainingType = 'Typ cvičenia';
  static const String selectTrainingType = 'Vyberte typ cvičenia';
  static const String trainingName = 'Názov cvičenia';
  static const String description = 'Popis';
  static const String defaultDuration = 'Predvolené trvanie';
  static const String defaultCapacity = 'Predvolená kapacita';
  static const String date = 'Dátum';
  static const String startTime = 'Začiatok';
  static const String duration = 'Trvanie';
  static const String capacity = 'Kapacita';
  static const String trainingTypeCreated = 'Typ cvičenia bol vytvorený.';
  static const String trainingSessionCreated = 'Termín tréningu bol vytvorený.';
  static const String fillAllFields = 'Vyplňte všetky povinné údaje.';
  static const String invalidCapacity = 'Kapacita musí byť väčšia ako 0.';
  static const String invalidDuration = 'Trvanie musí byť väčšie ako 0.';
  static const String trainingTypesLoadError =
      'Nepodarilo sa načítať typy cvičení.';
  static const String saveError = 'Uloženie sa nepodarilo.';
  static const String trainingSessionOverlap =
      'V tomto čase už je naplánovaný iný tréning.';
  static const String delete = 'Vymazať';
  static const String cancel = 'Zrušiť';
  static const String today = 'Dnes';
  static const String tomorrow = 'Zajtra';
  static const String noTrainingsForSelectedDay =
      'V tento deň nie sú naplánované žiadne tréningy.';
  static const List<String> shortWeekdays = [
    'Po',
    'Ut',
    'St',
    'Št',
    'Pi',
    'So',
    'Ne',
  ];
  static const String scheduleManagement = 'Správa rozvrhu';
  static const String scheduleManagementDescription =
      'Správa typov cvičení, šablón rozvrhu a konkrétnych tréningových termínov.';
  static const String trainingSessionInPast =
      'Termín tréningu nemôže byť v minulosti.';
  static const String selectDate = 'Vyberte dátum';
  static const String cancelTrainingSession = 'Zrušiť termín';
  static const String cancelTrainingSessionTitle = 'Zrušiť termín tréningu';
  static const String cancelTrainingSessionQuestion =
      'Naozaj chcete zrušiť tento termín tréningu? Aktívne rezervácie budú zrušené a alokované vstupy sa používateľom uvoľnia. Ak už bol vstup použitý, bude používateľovi vrátený.';
  static const String cancelTrainingSessionConfirm = 'Zrušiť termín';
  static const String trainingSessionCancelled = 'Termín tréningu bol zrušený.';
  static const String cancelTrainingSessionError =
      'Termín tréningu sa nepodarilo zrušiť.';
  static const String trainerCanCancelOnlyOwnSession =
      'Tréner môže zrušiť iba vlastný termín.';
  static const String trainerCannotCancelStartedSession =
      'Tréner nemôže zrušiť termín, ktorý už začal alebo prebehol.';
  // Šablóny rozvrhu
  static const String addScheduleTemplate = 'Pridať šablónu rozvrhu';
  static const String weekday = 'Deň v týždni';
  static const String selectWeekday = 'Vyberte deň v týždni';
  static const String scheduleTemplateCreated =
      'Šablóna rozvrhu bola vytvorená.';
  static const String scheduleTemplateAlreadyExists =
      'Takáto šablóna rozvrhu už existuje.';
  static const String scheduleTemplateLoadError =
      'Nepodarilo sa načítať šablóny rozvrhu.';
  static const List<String> weekdays = [
    'Pondelok',
    'Utorok',
    'Streda',
    'Štvrtok',
    'Piatok',
    'Sobota',
    'Nedeľa',
  ];
  static const String selectTrainer = 'Vyberte trénera';
  static const String trainersLoadError = 'Nepodarilo sa načítať trénerov.';
  static const String scheduleTemplateOverlap =
      'V tomto čase už existuje iná šablóna rozvrhu.';
  // Rezervácie
  static const String reservationCreated = 'Rezervácia bola vytvorená.';
  static const String reservationAlreadyExists =
      'Na tento tréning už máte vytvorenú rezerváciu.';
  static const String reservationTrainingFull = 'Tento tréning je už obsadený.';
  static const String reservationTrainingNotAvailable =
      'Tento tréning už nie je dostupný na rezerváciu.';
  static const String reservationTrainingAlreadyStarted =
      'Na tento tréning sa už nedá rezervovať.';
  static const String reservationError = 'Rezerváciu sa nepodarilo vytvoriť.';
  static const String myReservations = 'Moje rezervácie';
  static const String noReservations = 'Momentálne nemáte žiadne rezervácie.';
  static const String reserved = 'Rezervované';
  static const String cancelReservation = 'Zrušiť rezerváciu';
  static const String cancelReservationTitle = 'Zrušiť rezerváciu';
  static const String cancelReservationQuestion =
      'Naozaj chcete zrušiť túto rezerváciu?';
  static const String reservationCancelled = 'Rezervácia bola zrušená.';
  static const String reservationCancelError =
      'Rezerváciu sa nepodarilo zrušiť.';
  static const String trainingSessionHasReservations =
      'Termín má rezervácie, preto ho nie je možné vymazať.';
  // Permanentky
  static const String assignMembership = 'Priradiť permanentku';
  static const String selectUser = 'Vyberte používateľa';
  static const String selectMembershipPlan = 'Vyberte typ permanentky';
  static const String usersLoadError = 'Nepodarilo sa načítať používateľov.';
  static const String membershipPlansLoadError =
      'Nepodarilo sa načítať typy permanentiek.';
  static const String membershipAssigned = 'Permanentka bola priradená.';
  static const String membershipAssignError =
      'Permanentku sa nepodarilo priradiť.';
  static const String membershipPlan = 'Typ permanentky';
  static const String client = 'Používateľ';
  static const String buyMembership = 'Kúpiť permanentku';
  static const String buySingleEntry = 'Kúpiť jednorázový vstup';
  static const String chooseMembership = 'Vyberte permanentku';
  static const String payment = 'Platba';
  static const String pay = 'Zaplatiť';
  static const String paymentSuccessful = 'Platba úspešná.';
  static const String paymentFailed = 'Platba zlyhala.';
  static const String activeMembership = 'Aktívna permanentka';
  static const String noActiveMembership = 'Nemáte aktívnu permanentku.';
  static const String validUntil = 'Platná do';
  static const String membershipLoadError =
      'Permanentku sa nepodarilo načítať.';
  static const String noAvailableEntries =
      'Nemáte dostupný vstup na rezerváciu.';
  static const String noUpcomingTraining =
      'Dnes nemáte rezervované žiadne cvičenie.';
  static const String newsPlaceholder =
      'Tu sa budú zobrazovať novinky a správy od trénerov.';
  // Dochádzka
  static const String attendance = 'Dochádzka';
  static const String attendanceLoadError = 'Nepodarilo sa načítať dochádzku.';
  static const String noActiveReservationsForAttendance =
      'Momentálne nie sú žiadne aktívne rezervácie na označenie dochádzky.';
  static const String attended = 'Prišiel';
  static const String noShow = 'Neprišiel';
  static const String markAttendedTitle = 'Označiť účasť';
  static const String markNoShowTitle = 'Označiť neúčasť';
  static const String markAttendedQuestion =
      'Naozaj chcete označiť používateľa ako prítomného?';
  static const String markNoShowQuestion =
      'Naozaj chcete označiť používateľa ako neprítomného?';
  static const String attendanceMarked = 'Dochádzka bola uložená.';
  static const String attendanceMarkError = 'Dochádzku sa nepodarilo uložiť.';
  // QR dochádzka
  static const String reservationQrCode = 'QR kód rezervácie';
  static const String showQrCode = 'QR kód';
  static const String showQrToTrainer =
      'Ukážte tento QR kód trénerovi pri príchode na tréning.';
  static const String scanQrCode = 'Skenovať QR kód';
  static const String scanQrCodes = 'Skenovať QR kódy';
  static const String scanQrCodeHint =
      'Namierte kameru na QR kód rezervácie používateľa.';
  static const String invalidQrCode = 'Neplatný QR kód rezervácie.';
  static const String qrCodeScanned = 'QR kód bol naskenovaný.';
  static const String qrScanSuccessful =
      'QR kód bol naskenovaný. Môžete skenovať ďalšieho používateľa.';
  static const String trainerQrScanTooEarly =
      'QR kód je možné naskenovať najskôr 30 minút pred začiatkom cvičenia.';

  static String trainingCount(int count) {
    if (count == 1) {
      return '1 cvičenie';
    }

    if (count >= 2 && count <= 4) {
      return '$count cvičenia';
    }

    return '$count cvičení';
  }

  static String reservationCount(int count) {
    if (count == 1) {
      return '1 rezervácia';
    }

    if (count >= 2 && count <= 4) {
      return '$count rezervácie';
    }

    return '$count rezervácií';
  }

  // Nastavenia
  static const String settings = 'Nastavenia';
  static const String appearance = 'Vzhľad';
  static const String appearanceDescription =
      'Vyberte svetlý, tmavý alebo systémový režim.';
  static const String themeSystem = 'Podľa systému';
  static const String themeLight = 'Svetlý režim';
  static const String themeDark = 'Tmavý režim';
  static const String language = 'Jazyk';
  static const String languageComingSoon =
      'Prepínanie jazyka pripravíme neskôr.';
}
