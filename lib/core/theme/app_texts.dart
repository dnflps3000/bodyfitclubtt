/// Centrálne texty aplikácie.
/// Neskôr by sa mohli pridať aj preklady (EN/SK).
class AppTexts {
  // Aplikácia / všeobecné
  static const String appName = 'Body Fit Club TT';
  static const String loading = 'Načítavam...';
  static const String ok = 'OK';
  static const String save = 'Uložiť';
  static const String delete = 'Vymazať';
  static const String cancel = 'Zrušiť';
  static const String back = 'Späť';
  static const String today = 'Dnes';
  static const String tomorrow = 'Zajtra';
  static const String todayLower = 'dnes';
  static const String tomorrowLower = 'zajtra';
  static const String minutes = 'min.';
  static const String role = 'Rola';
  static const String refresh = 'Aktualizovať';
  static const String yesterday = 'Včera';
  static const String last7Days = 'Posledných 7 dní';
  static const String last30Days = 'Posledných 30 dní';
  static const String allTime = 'Celé obdobie';

  // Role
  static const String roleUser = 'Používateľ';
  static const String roleTrainer = 'Tréner';
  static const String roleAdmin = 'Administrátor';
  static const String roleUnknown = 'Neznáma rola';

  // Hlavná navigácia
  static const String home = 'Domov';
  static const String schedule = 'Rozvrh';
  static const String reservations = 'Rezervácie';
  static const String management = 'Správa';
  static const String profile = 'Profil';

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
  static const String logoutTooltip = 'Odhlásiť';
  static const String noAccountRegister = 'Nemáš účet? Registrovať';
  static const String hasAccountLogin = 'Už máš účet? Prihlásiť';
  static const String authError = 'Chyba prihlásenia';

  // Validácia auth
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
  static const String inactiveAccount =
      'Váš účet je deaktivovaný. Kontaktujte administrátora.';

  // Overenie e-mailu
  static const String verificationEmailSent =
      'Registrácia prebehla úspešne. Poslali sme vám overovací e-mail. '
      'Ak ho nevidíte v doručenej pošte, skontrolujte aj priečinok Spam.';
  static const String emailNotVerified =
      'Najskôr potvrďte registráciu kliknutím na odkaz v e-maile.';
  static const String verificationEmailSentAgain =
      'Overovací e-mail sme vám poslali opäť. '
      'Ak ho nevidíte v doručenej pošte, skontrolujte aj priečinok Spam.';

  // Complete profile / profil
  static const String completeProfileTitle = 'Doplnenie profilu';
  static const String editProfile = 'Upraviť profil';
  static const String firstName = 'Meno';
  static const String lastName = 'Priezvisko';
  static const String publicName = 'Zobrazované meno';
  static const String publicNameHint = 'Napr. Barbora, Katka, Aďo';
  static const String firstNameRequired = 'Zadajte meno.';
  static const String lastNameRequired = 'Zadajte priezvisko.';
  static const String publicNameRequired = 'Zadajte zobrazované meno.';
  static const String profileSaved = 'Profil bol uložený.';
  static const String profileSaveError = 'Profil sa nepodarilo uložiť.';
  static const String emailNotProvided = 'E-mail nebol poskytnutý';
  static const String loggedInUser = 'Prihlásený používateľ';
  static const String completeEmailTitle = 'Doplnenie e-mailu';
  static const String completeEmailDescription =
      'Pre používanie aplikácie potrebujeme vašu e-mailovú adresu. '
      'Použijeme ju ako kontaktný e-mail k vášmu účtu.';
  static const String emailSaved = 'E-mail bol uložený.';
  static const String emailSaveError = 'E-mail sa nepodarilo uložiť.';

  // Profilová fotka
  static const String changeProfilePhoto = 'Zmeniť profilovú fotku';
  static const String chooseFromGallery = 'Vybrať z galérie';
  static const String takePhoto = 'Odfotiť';
  static const String removePhoto = 'Odstrániť fotku';
  static const String editPhoto = 'Upraviť fotku';
  static const String cropProfilePhoto = 'Orezať profilovú fotku';
  static const String profilePhotoUpdated = 'Profilová fotka bola uložená.';
  static const String profilePhotoUpdateError =
      'Profilovú fotku sa nepodarilo uložiť.';
  static const String profilePhotoRemoveError =
      'Profilovú fotku sa nepodarilo odstrániť.';

  // Home obrazovka
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
  static const String nearestReservations = 'Najbližšie rezervácie';
  static const String noNearestReservations =
      'Nemáte žiadne najbližšie rezervácie.';
  static const String showReservationQrCode = 'Zobraziť QR kód';

  // Novinky / verejné správy
  static const String news = 'Novinky';
  static const String noPublicMessages = 'Zatiaľ nie sú žiadne správy.';
  static const String writeMessage = 'Napísať správu';
  static const String writeMessageShort = 'Napísať';
  static const String editMessage = 'Upraviť správu';
  static const String deleteMessage = 'Vymazať správu';
  static const String deleteMessageQuestion =
      'Naozaj chcete vymazať túto správu?';
  static const String messageText = 'Text správy';
  static const String messageHint = 'Napíš správu...';
  static const String sendMessage = 'Poslať';
  static const String updateMessage = 'Uložiť zmeny';
  static const String messageSaved = 'Správa bola uložená.';
  static const String messageDeleted = 'Správa bola vymazaná.';
  static const String messageSaveError = 'Správu sa nepodarilo uložiť.';
  static const String messageDeleteError = 'Správu sa nepodarilo vymazať.';
  static const String editedBy = 'Upravené';
  static const String editedByAdmin = 'Upravené administrátorom';
  static const String editedByTrainer = 'Upravené trénerom';
  static const String userFallback = 'Používateľ';

  // Verejné / placeholder texty
  static const String membershipStatus = 'Stav permanentky';
  static const String remainingEntries = 'Zostávajúce vstupy';
  static const String upcomingTraining = 'Najbližšie dnešné cvičenie';
  static const String schedulePlaceholder = 'Tu bude rozvrh tréningov.';
  static const String reservationsPlaceholder = 'Tu budú rezervácie.';
  static const String newsPlaceholder =
      'Tu sa budú zobrazovať novinky a správy od trénerov.';

  // Rozvrh tréningov
  static const String noTrainings =
      'Momentálne nie sú dostupné žiadne tréningy.';
  static const String noTrainingsForSelectedDay =
      'V tento deň nie sú naplánované žiadne tréningy.';
  static const String trainer = 'Tréner';
  static const String freeSpots = 'Voľné miesta';
  static const String reserve = 'Rezervovať';
  static const String reserved = 'Rezervované';
  static const String fullCapacity = 'Obsadené';
  static const String trainingsLoadError =
      'Nepodarilo sa načítať rozvrh tréningov.';
  static const String unknownTraining = 'Neznámy tréning';
  static const String unknownTrainer = 'Neznámy tréner';
  static const String unknownUser = 'Neznámy používateľ';
  static const String trainingSessionFinished = 'Prebehlo';
  static const String trainingSessionTooFarInFuture =
      'Termín je príliš ďaleko v budúcnosti. Manuálne môžete pridať cvičenie iba do obdobia zobrazeného v rozvrhu.';
  static const List<String> shortWeekdays = [
    'Po',
    'Ut',
    'St',
    'Št',
    'Pi',
    'So',
    'Ne',
  ];
  static String scheduleMessageTrainingSessionCreated({
    required String trainingName,
    required String date,
    required String time,
  }) {
    return 'Do rozvrhu bol pridaný nový tréning:\n'
        '$trainingName – $date o $time.';
  }

  static String scheduleMessageTrainingSessionCancelled({
    required String trainingName,
    required String date,
    required String time,
  }) {
    return 'Tréning bol zrušený:\n'
        '$trainingName – $date o $time.\n'
        'Aktívne rezervácie boli zrušené a alokované vstupy boli uvoľnené.';
  }

  static String scheduleMessageTrainingSessionTimeChanged({
    required String trainingName,
    required String oldDate,
    required String oldTime,
    required String newDate,
    required String newTime,
  }) {
    return 'Termín tréningu bol zmenený:\n'
        '$trainingName bol presunutý z $oldDate o $oldTime '
        'na $newDate o $newTime.\n'
        'Pôvodné rezervácie boli zrušené a alokované vstupy boli uvoľnené.';
  }

  static String scheduleMessageTrainingSessionUpdated({
    required String trainingName,
    required String date,
    required String time,
  }) {
    return 'Termín tréningu bol upravený:\n'
        '$trainingName – $date o $time.';
  }

  static String scheduleMessageTemplateCreated({
    required String trainingName,
    required String weekday,
    required String time,
  }) {
    return 'Pravidelný týždenný rozvrh bol upravený:\n'
        'Pribudol pravidelný tréning:\n'
        '$trainingName – $weekday o $time.';
  }

  static String scheduleMessageTemplateUpdated({
    required String trainingName,
    required String oldSchedule,
    required String newSchedule,
  }) {
    return 'Pravidelný týždenný rozvrh bol upravený:\n'
        '$trainingName bol upravený.\n'
        'Pôvodne: $oldSchedule.\n'
        'Nový rozvrh: $newSchedule.';
  }

  static String scheduleMessageTemplateDeactivated({
    required String trainingName,
    required String weekday,
    required String time,
  }) {
    return 'Pravidelný týždenný rozvrh bol upravený:\n'
        'Z pravidelného rozvrhu bol odstránený tréning:\n'
        '$trainingName – $weekday o $time.';
  }

  // Správa
  static const String managementDescription =
      'Tu môžete spravovať termíny cvičení, dochádzku, permanentky a používateľov.';
  static const String scheduleManagement = 'Správa rozvrhu';
  static const String scheduleManagementDescription =
      'Správa typov cvičení, šablón rozvrhu a konkrétnych tréningových termínov.';
  static const String attendanceManagement = 'Správa dochádzky';
  static const String usersManagement = 'Správa používateľov';
  static const String usersManagementComingSoon =
      'Správa používateľov bude doplnená neskôr.';
  static const String scheduleTemplatesManagement = 'Správa šablón rozvrhu';
  static const String reactivateUser = 'Aktivovať používateľa';
  static const String reactivateUserQuestion =
      'Naozaj chcete znovu aktivovať tohto používateľa?';
  static const String userReactivated = 'Používateľ bol znovu aktivovaný.';

  // Správa typov cvičení
  static const String trainingTypesManagement = 'Správa typov cvičení';
  static const String addTrainingType = 'Pridať typ cvičenia';
  static const String editTrainingType = 'Upraviť typ cvičenia';
  static const String deleteTrainingType = 'Vymazať typ cvičenia';
  static const String trainingType = 'Typ cvičenia';
  static const String selectTrainingType = 'Vyberte typ cvičenia';
  static const String trainingName = 'Názov cvičenia';
  static const String description = 'Popis';
  static const String defaultDuration = 'Predvolené trvanie';
  static const String defaultCapacity = 'Predvolená kapacita';
  static const String noTrainingTypes =
      'Momentálne nie sú vytvorené žiadne typy cvičení.';
  static const String trainingTypesLoadError =
      'Nepodarilo sa načítať typy cvičení.';
  static const String trainingTypeCreated = 'Typ cvičenia bol vytvorený.';
  static const String trainingTypeUpdated = 'Typ cvičenia bol upravený.';
  static const String trainingTypeDeleted = 'Typ cvičenia bol vymazaný.';
  static const String trainingTypeDeleteQuestion =
      'Naozaj chcete vymazať tento typ cvičenia? Nebude sa už ponúkať pri nových termínoch.';
  static const String trainingTypeAlreadyExists =
      'Typ cvičenia s týmto názvom už existuje.';
  static const String trainingTypeUsedByTemplate =
      'Typ cvičenia nie je možné vymazať, pretože sa používa v aktívnej šablóne rozvrhu.';
  static const String trainingTypeUsedBySession =
      'Typ cvičenia nie je možné vymazať, pretože sa používa v budúcom termíne cvičenia.';

  // Správa konkrétnych termínov cvičení
  static const String addTrainingSession = 'Pridať termín cvičenia';
  static const String editTrainingSession = 'Upraviť detaily cvičenia';
  static const String trainingSessionCreated = 'Termín tréningu bol vytvorený.';
  static const String trainingSessionUpdated = 'Termín cvičenia bol upravený.';
  static const String updateTrainingSessionError =
      'Termín cvičenia sa nepodarilo upraviť.';
  static const String trainingSessionInPast =
      'Termín tréningu nemôže byť v minulosti.';
  static const String trainingSessionOverlap =
      'V tomto čase už je naplánovaný iný tréning.';
  static const String capacityLowerThanReservations =
      'Kapacita nemôže byť nižšia ako počet existujúcich rezervácií.';
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

  // Formuláre rozvrhu
  static const String date = 'Dátum';
  static const String startTime = 'Začiatok';
  static const String duration = 'Trvanie';
  static const String capacity = 'Kapacita';
  static const String selectDate = 'Vyberte dátum';
  static const String selectTrainer = 'Vyberte trénera';
  static const String trainersLoadError = 'Nepodarilo sa načítať trénerov.';
  static const String fillAllFields = 'Vyplňte všetky povinné údaje.';
  static const String invalidCapacity = 'Kapacita musí byť väčšia ako 0.';
  static const String invalidDuration = 'Trvanie musí byť väčšie ako 0.';
  static const String saveError = 'Uloženie sa nepodarilo.';

  // Šablóny rozvrhu
  static const String addScheduleTemplate = 'Pridať šablónu rozvrhu';
  static const String editScheduleTemplate = 'Upraviť šablónu rozvrhu';
  static const String deleteScheduleTemplate = 'Vymazať šablónu rozvrhu';
  static const String noScheduleTemplates =
      'Momentálne nie sú vytvorené žiadne šablóny rozvrhu.';
  static const String weekday = 'Deň v týždni';
  static const String selectWeekday = 'Vyberte deň v týždni';
  static const String scheduleTemplateCreated =
      'Šablóna rozvrhu bola vytvorená.';
  static const String scheduleTemplateUpdated =
      'Šablóna rozvrhu bola upravená.';
  static const String scheduleTemplateDeleted =
      'Šablóna rozvrhu bola vymazaná.';
  static const String scheduleTemplateDeleteQuestion =
      'Naozaj chcete vymazať túto šablónu rozvrhu? Nebude sa už používať pri generovaní nových termínov.';
  static const String scheduleTemplateAlreadyExists =
      'Takáto šablóna rozvrhu už existuje.';
  static const String scheduleTemplateLoadError =
      'Nepodarilo sa načítať šablóny rozvrhu.';
  static const String scheduleTemplateOverlap =
      'V tomto čase už existuje iná šablóna rozvrhu.';

  static const List<String> weekdays = [
    'Pondelok',
    'Utorok',
    'Streda',
    'Štvrtok',
    'Piatok',
    'Sobota',
    'Nedeľa',
  ];

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
  static const String cancelReservation = 'Zrušiť rezerváciu';
  static const String cancelReservationTitle = 'Zrušiť rezerváciu';
  static const String cancelReservationQuestion =
      'Naozaj chcete zrušiť túto rezerváciu?';
  static const String reservationCancelled = 'Rezervácia bola zrušená.';
  static const String reservationCancelError =
      'Rezerváciu sa nepodarilo zrušiť.';
  static const String reservationsLoadError =
      'Rezervácie sa nepodarilo načítať.';

  // Permanentky
  static const String memberships = 'Permanentky';
  static const String assignMembership = 'Priradiť permanentku';
  static const String selectUser = 'Vyberte používateľa';
  static const String selectMembershipPlan = 'Vyberte typ permanentky';
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
  static const String membershipsManagement = 'Správa permanentiek';
  static const String membershipDetail = 'Detail permanentky';
  static const String noMemberships =
      'Momentálne nie sú dostupné žiadne permanentky.';
  static const String status = 'Stav';
  static const String validFrom = 'Platná od';
  static const String entriesTotal = 'Celkový počet vstupov';
  static const String entriesRemaining = 'Zostávajúce vstupy';
  static const String entriesReserved = 'Alokované v rezerváciách';
  static const String entriesAvailable = 'Dostupné vstupy';
  static const String adminMembershipEdit = 'Administrátorská úprava';
  static const String membershipStatusActive = 'Aktívna';
  static const String membershipStatusInactive = 'Neaktívna';
  static const String membershipStatusCancelled = 'Zrušená';
  static const String membershipStatusExpired = 'Expirovaná';
  static const String membershipStatusUsedUp = 'Minutá';
  static const String membershipUpdated = 'Permanentka bola upravená.';
  static const String membershipUpdateError =
      'Permanentku sa nepodarilo upraviť.';
  static const String invalidRemainingEntries =
      'Zadajte platný počet zostávajúcich vstupov.';
  static const String allocatedReservations = 'Alokované rezervácie';
  static const String cancelAllocatedReservations =
      'Zrušiť alokované rezervácie';
  static const String cancelAllocatedReservationsQuestion =
      'Naozaj chcete zrušiť aktívne rezervácie naviazané na túto permanentku? Alokované vstupy sa uvoľnia.';
  static const String cancelReservations = 'Zrušiť rezervácie';
  static const String cancelAllReservations = 'Zrušiť všetky rezervácie';
  static const String cancelAllocatedReservationsError =
      'Alokované rezervácie sa nepodarilo zrušiť.';
  static const String usedEntries = 'Použité vstupy';
  static const String noAllocatedReservations =
      'Na túto permanentku nie sú aktuálne alokované žiadne rezervácie.';
  static const String noUsedEntries =
      'Z tejto permanentky zatiaľ nebol použitý žiadny vstup.';
  static const String membershipUsageLoadError =
      'Históriu permanentky sa nepodarilo načítať.';
  static const String searchMemberships =
      'Hľadať podľa používateľa alebo permanentky';
  static const String allMembershipStatuses = 'Všetky stavy';
  static const String membershipStatusNotYetValid = 'Ešte neplatná';
  static const String membershipStatusUsable = 'Aktívna';
  static const String invalidRemainingEntriesHigherThanTotal =
      'Zostávajúce vstupy nemôžu byť vyššie ako celkový počet vstupov.';
  static const String invalidRemainingEntriesLowerThanReserved =
      'Zostávajúce vstupy nemôžu byť nižšie ako počet alokovaných vstupov.';
  static const String cancelReservationsBeforeDeactivation =
      'Pred deaktiváciou alebo zrušením permanentky najskôr zrušte alokované rezervácie.';
  static const String cancelReservationForMembership = 'Zrušiť túto rezerváciu';
  static const String cancelReservationForMembershipQuestion =
      'Naozaj chcete zrušiť túto rezerváciu naviazanú na permanentku? Alokovaný vstup sa uvoľní.';
  static const String reservationForMembershipCancelled =
      'Rezervácia bola zrušená a alokovaný vstup bol uvoľnený.';

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

  // Správa používateľov
  static const String usersLoadError = 'Nepodarilo sa načítať používateľov.';
  static const String allRoles = 'Všetky role';
  static const String searchUsers = 'Hľadať používateľa';
  static const String noUsersFound = 'Nenašli sa žiadni používatelia.';
  static const String editUser = 'Upraviť používateľa';
  static const String userUpdated = 'Používateľ bol upravený.';
  static const String userUpdateError = 'Používateľa sa nepodarilo upraviť.';
  static const String cannotChangeOwnRole = 'Nemôžete zmeniť vlastnú rolu.';
  static const String changeRoleWarning =
      'Pri zmene roly používateľa sa môžu zmeniť jeho oprávnenia v aplikácii.';
  static const String deactivateUser = 'Deaktivovať používateľa';
  static const String userDeactivated = 'Používateľ bol deaktivovaný.';
  static const String deactivateUserQuestion =
      'Naozaj chcete deaktivovať tohto používateľa? Nebude sa môcť ďalej používať v správe aplikácie.';
  static const String cannotDeactivateYourself =
      'Nemôžete deaktivovať vlastný účet.';
  static const String userUsedByTemplate =
      'Používateľa nie je možné deaktivovať alebo zmeniť na bežného používateľa, pretože je priradený v aktívnej šablóne rozvrhu.';
  static const String userUsedByFutureSession =
      'Používateľa nie je možné deaktivovať alebo zmeniť na bežného používateľa, pretože je priradený k budúcemu cvičeniu.';
  static const String userHasActiveReservations =
      'Používateľa nie je možné deaktivovať, pretože má aktívne rezervácie.';
  static const String userHasActiveMemberships =
      'Používateľa nie je možné deaktivovať, pretože má aktívne permanentky.';
  static const String inactiveUser = 'Neaktívny používateľ';
  static const String userCannotBeDeactivated =
      'Používateľa nemožno deaktivovať';
  static const String userCannotBeDeactivatedDescription =
      'Pred deaktiváciou je potrebné najskôr vyriešiť jeho aktívne rezervácie alebo permanentky.';
  static const String userHasBlockingItems = 'Používateľ má:';
  static const String activeReservationsCount = 'Aktívne rezervácie';
  static const String showMemberships = 'Zobraziť permanentky';

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

  // História zásahov
  static const String auditLogs = 'História zásahov';
  static const String auditLogsDescription =
      'Prehľad dôležitých zásahov v aplikácii.';
  static const String auditLogsLoadError =
      'Históriu zásahov sa nepodarilo načítať.';
  static const String noAuditLogs = 'Nenašli sa žiadne zásahy.';
  static const String searchAuditLogs =
      'Hľadať podľa používateľa, e-mailu alebo popisu';
  static const String auditCategory = 'Kategória';
  static const String auditAction = 'Akcia';
  static const String auditActor = 'Vykonal';
  static const String auditActorRole = 'Rola vykonávateľa';
  static const String auditPeriod = 'Obdobie';
  static const String auditAllCategories = 'Všetky kategórie';
  static const String auditCategoryMemberships = 'Permanentky';
  static const String auditCategoryReservations = 'Rezervácie';
  static const String auditCategoryAttendance = 'Dochádzka';
  static const String auditCategoryUsers = 'Používatelia';
  static const String auditCategorySchedule = 'Rozvrh';
  static const String auditCategoryMessages = 'Správy';
  static const String auditCategoryPayments = 'Platby';
  static const String auditCategoryProfile = 'Profil';
  static const String auditAllActions = 'Všetky akcie';
  static const String auditActionCreated = 'Vytvorenie';
  static const String auditActionUpdated = 'Úprava';
  static const String auditActionCancelled = 'Zrušenie';
  static const String auditActionDeactivated = 'Deaktivácia';
  static const String auditActionActivated = 'Aktivácia';
  static const String auditActionAssigned = 'Priradenie';
  static const String auditActionPurchased = 'Nákup';
  static const String auditActionPaymentSucceeded = 'Platba úspešná';
  static const String auditActionPaymentFailed = 'Platba zlyhala';
  static const String auditActionAttendanceMarked = 'Dochádzka';
  static const String auditActionQrChecked = 'QR kontrola';
  static const String auditAllActorRoles = 'Všetky role';
  static const String auditReservationCreatedTitle = 'Vytvorenie rezervácie';
  static const String auditReservationCreatedDescription =
      'Používateľ vytvoril rezerváciu na tréning.';
  static const String auditReservationCancelledTitle = 'Zrušenie rezervácie';
  static const String auditReservationCancelledDescription =
      'Rezervácia používateľa bola zrušená.';
  static const String auditAttendanceAttendedTitle = 'Označená účasť';
  static const String auditAttendanceAttendedDescription =
      'Používateľ bol označený ako prítomný na tréningu.';
  static const String auditAttendanceNoShowTitle = 'Označená neúčasť';
  static const String auditAttendanceNoShowDescription =
      'Používateľ bol označený ako neprítomný na tréningu.';
  static const String auditTrainingTypeCreatedTitle =
      'Vytvorenie typu cvičenia';
  static const String auditTrainingTypeUpdatedTitle = 'Úprava typu cvičenia';
  static const String auditTrainingTypeDeactivatedTitle =
      'Deaktivácia typu cvičenia';
  static const String auditTrainingSessionCreatedTitle = 'Vytvorenie termínu';
  static const String auditTrainingSessionUpdatedTitle = 'Úprava termínu';
  static const String auditTrainingSessionTimeChangedTitle =
      'Zmena času termínu';
  static const String auditTrainingSessionCancelledTitle = 'Zrušenie termínu';
  static const String auditScheduleTemplateCreatedTitle =
      'Vytvorenie šablóny rozvrhu';
  static const String auditScheduleTemplateUpdatedTitle =
      'Úprava šablóny rozvrhu';
  static const String auditScheduleTemplateDeactivatedTitle =
      'Deaktivácia šablóny rozvrhu';
  static String auditTrainingTypeCreatedDescription(String trainingName) {
    return 'Bol vytvorený typ cvičenia $trainingName.';
  }

  static String auditTrainingTypeUpdatedDescription(String trainingName) {
    return 'Bol upravený typ cvičenia $trainingName.';
  }

  static String auditTrainingTypeDeactivatedDescription(String trainingName) {
    return 'Bol deaktivovaný typ cvičenia $trainingName.';
  }

  static String auditTrainingSessionCreatedDescription(String trainingName) {
    return 'Bol vytvorený konkrétny termín cvičenia $trainingName.';
  }

  static String auditTrainingSessionUpdatedDescription(String trainingName) {
    return 'Bol upravený konkrétny termín cvičenia $trainingName.';
  }

  static String auditTrainingSessionTimeChangedDescription(
    String trainingName,
  ) {
    return 'Bol zmenený čas konkrétneho termínu cvičenia $trainingName.';
  }

  static String auditTrainingSessionCancelledDescription(String trainingName) {
    return 'Bol zrušený konkrétny termín cvičenia $trainingName.';
  }

  static String auditScheduleTemplateCreatedDescription(String trainingName) {
    return 'Bola vytvorená šablóna pravidelného rozvrhu pre cvičenie $trainingName.';
  }

  static String auditScheduleTemplateUpdatedDescription(String trainingName) {
    return 'Bola upravená šablóna pravidelného rozvrhu pre cvičenie $trainingName.';
  }

  static String auditScheduleTemplateDeactivatedDescription(
    String trainingName,
  ) {
    return 'Bola deaktivovaná šablóna pravidelného rozvrhu pre cvičenie $trainingName.';
  }

  static const String auditUserUpdatedTitle = 'Úprava používateľa';
  static const String auditUserUpdatedDescription =
      'Administrátor upravil údaje používateľa.';
  static const String auditUserRoleChangedTitle = 'Zmena roly používateľa';
  static const String auditUserRoleChangedDescription =
      'Administrátor zmenil rolu používateľa.';
  static const String auditUserDeactivatedTitle = 'Deaktivácia používateľa';
  static const String auditUserDeactivatedDescription =
      'Administrátor deaktivoval používateľa.';
  static const String auditUserDeactivationBlockedTitle =
      'Neúspešná deaktivácia používateľa';
  static const String auditUserDeactivationBlockedDescription =
      'Deaktivácia používateľa bola zablokovaná kontrolou aktívnych väzieb.';
  static const String auditPublicMessageCreatedTitle = 'Vytvorenie novinky';
  static const String auditPublicMessageCreatedDescription =
      'Bola vytvorená verejná novinka.';
  static const String auditPublicMessageUpdatedTitle = 'Úprava novinky';
  static const String auditPublicMessageUpdatedDescription =
      'Bola upravená verejná novinka.';
  static const String auditPublicMessageDeletedTitle = 'Vymazanie novinky';
  static const String auditPublicMessageDeletedDescription =
      'Verejná novinka bola vymazaná.';
  static const String auditProfileCompletedTitle = 'Doplnenie profilu';
  static const String auditProfileCompletedDescription =
      'Používateľ doplnil základné údaje profilu.';
  static const String auditProfileUpdatedTitle = 'Úprava profilu';
  static const String auditProfileUpdatedDescription =
      'Používateľ upravil údaje profilu.';
  static const String auditProfilePhotoUpdatedTitle = 'Úprava profilovej fotky';
  static const String auditProfilePhotoUpdatedDescription =
      'Používateľ upravil profilovú fotku.';
  static const String auditProfilePhotoRemovedTitle =
      'Odstránenie profilovej fotky';
  static const String auditProfilePhotoRemovedDescription =
      'Používateľ odstránil manuálne nastavenú profilovú fotku.';
  static const String auditPaymentStartedTitle = 'Spustenie platby';
  static const String auditPaymentStartedDescription =
      'Používateľ spustil platbu za permanentku.';
  static const String auditPaymentSucceededTitle = 'Úspešná platba';
  static const String auditPaymentSucceededDescription =
      'Platba za permanentku bola úspešne dokončená.';
  static const String auditPaymentFailedTitle = 'Neúspešná platba';
  static const String auditPaymentFailedDescription =
      'Platba za permanentku zlyhala alebo bola zrušená.';
  static const String auditMembershipUpdatedTitle = 'Úprava permanentky';
  static const String auditMembershipUpdatedDescription =
      'Administrátor upravil permanentku používateľa.';
  static const String auditMembershipStatusChangedTitle =
      'Zmena stavu permanentky';
  static const String auditMembershipStatusChangedDescription =
      'Administrátor zmenil stav permanentky používateľa.';
  static const String auditMembershipEntriesChangedTitle =
      'Zmena počtu vstupov permanentky';
  static const String auditMembershipEntriesChangedDescription =
      'Administrátor zmenil počet zostávajúcich vstupov permanentky.';
  static const String auditMembershipReservationCancelledTitle =
      'Zrušenie alokovanej rezervácie';
  static const String auditMembershipReservationCancelledDescription =
      'Administrátor zrušil alokovanú rezerváciu naviazanú na permanentku.';
  static const String auditMembershipAllReservationsCancelledTitle =
      'Zrušenie všetkých alokovaných rezervácií';
  static const String auditMembershipAllReservationsCancelledDescription =
      'Administrátor zrušil všetky alokované rezervácie naviazané na permanentku.';
  static const String auditMembershipAssignedTitle = 'Priradenie permanentky';
  static const String auditMembershipAssignedDescription =
      'Používateľovi bola manuálne priradená permanentka.';
  static const String auditMembershipPurchasedTitle = 'Nákup permanentky';
  static const String auditMembershipPurchasedDescription =
      'Používateľ si zakúpil permanentku.';
  static const String auditActionMembershipAssigned = 'Priradenie permanentky';
  static const String auditActionMembershipPurchased = 'Nákup permanentky';
  static const String auditActionMembershipUpdated = 'Úprava permanentky';
  static const String auditActionMembershipStatusChanged =
      'Zmena stavu permanentky';
  static const String auditActionMembershipEntriesChanged =
      'Zmena vstupov permanentky';
  static const String auditActionMembershipReservationCancelled =
      'Zrušenie jednej alokovanej rezervácie';
  static const String auditActionMembershipAllReservationsCancelled =
      'Zrušenie všetkých alokovaných rezervácií';
  static const String auditActionReservationCreated = 'Vytvorenie rezervácie';
  static const String auditActionReservationCancelled = 'Zrušenie rezervácie';
  static const String auditActionAttendanceAttended = 'Označená účasť';
  static const String auditActionAttendanceNoShow = 'Označená neúčasť';
  static const String auditActionTrainingTypeCreated =
      'Vytvorenie typu cvičenia';
  static const String auditActionTrainingTypeUpdated = 'Úprava typu cvičenia';
  static const String auditActionTrainingTypeDeactivated =
      'Deaktivácia typu cvičenia';
  static const String auditActionTrainingSessionCreated = 'Vytvorenie termínu';
  static const String auditActionTrainingSessionUpdated = 'Úprava termínu';
  static const String auditActionTrainingSessionTimeChanged =
      'Zmena času termínu';
  static const String auditActionTrainingSessionCancelled = 'Zrušenie termínu';
  static const String auditActionScheduleTemplateCreated = 'Vytvorenie šablóny';
  static const String auditActionScheduleTemplateUpdated = 'Úprava šablóny';
  static const String auditActionScheduleTemplateDeactivated =
      'Deaktivácia šablóny';
  static const String auditActionUserUpdated = 'Úprava používateľa';
  static const String auditActionUserRoleChanged = 'Zmena roly';
  static const String auditActionUserDeactivationBlocked =
      'Blokovaná deaktivácia';
  static const String auditActionUserDeactivated = 'Deaktivácia používateľa';
  static const String auditActionPublicMessageCreated = 'Vytvorenie novinky';
  static const String auditActionPublicMessageUpdated = 'Úprava novinky';
  static const String auditActionPublicMessageDeleted = 'Vymazanie novinky';
  static const String auditActionProfileCompleted = 'Doplnenie profilu';
  static const String auditActionProfileUpdated = 'Úprava profilu';
  static const String auditActionProfilePhotoUpdated =
      'Úprava profilovej fotky';
  static const String auditActionProfilePhotoRemoved =
      'Odstránenie profilovej fotky';
  static const String auditActionPaymentStarted = 'Spustenie platby';
  static const String auditUserEmailCompletedTitle = 'Doplnenie e-mailu';
  static const String auditUserEmailCompletedDescription =
      'Používateľ doplnil chýbajúci e-mail k účtu.';

  static const String auditUserEmailUpdatedTitle = 'Úprava e-mailu používateľa';
  static const String auditUserEmailUpdatedDescription =
      'Administrátor upravil kontaktný e-mail používateľa.';

  static const String auditUserReactivatedTitle = 'Aktivácia používateľa';
  static const String auditUserReactivatedDescription =
      'Administrátor znovu aktivoval používateľa.';
  static const String auditActionUserEmailCompleted = 'Doplnenie e-mailu';
  static const String auditActionUserEmailUpdated =
      'Úprava e-mailu používateľa';
  static const String auditActionUserReactivated = 'Aktivácia používateľa';

  static String allocatedReservationsCancelled(int count) {
    if (count == 1) {
      return 'Bola zrušená 1 rezervácia.';
    }

    if (count >= 2 && count <= 4) {
      return 'Boli zrušené $count rezervácie.';
    }

    return 'Bolo zrušených $count rezervácií.';
  }

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
}
