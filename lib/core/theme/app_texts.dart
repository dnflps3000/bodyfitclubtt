/// Centrálne texty aplikácie.
/// Neskôr by sa mohli pridať aj preklady (EN/SK).
class AppTexts {
  static const String appName = 'Body Fit Club TT';
  static const String firebaseWorks = 'Firebase funguje';
  // Home obrazovka
  static const String logoutTooltip = 'Odhlásiť';
  static const String loggedInUser = 'Prihlásený používateľ';
  // Hlavná navigácia
  static const String home = 'Domov';
  static const String schedule = 'Rozvrh';
  static const String reservations = 'Rezervácie';
  static const String profile = 'Profil';
  // Placeholder obrazovky
  static const String membershipStatus = 'Stav permanentky';
  static const String remainingEntries = 'Zostávajúce vstupy';
  static const String upcomingTraining = 'Najbližšie cvičenie';
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
  // Validácia
  static const String fillEmailPassword = 'Vyplň e-mail aj heslo.';
  static const String invalidEmailFormat = 'Zadaj platný e-mail.';
  static const String passwordTooShort = 'Heslo musí mať aspoň 6 znakov.';
  // Firebase Auth chyby
  static const String wrongEmailOrPassword = 'Zadaný e-mail alebo heslo nie je správne.';
  static const String userAlreadyExists = 'Používateľ s týmto e-mailom už existuje.';
  static const String weakPassword = 'Zadané heslo je príliš slabé.';
  static const String tooManyRequests = 'Príliš veľa pokusov. Skúste to neskôr.';
  static const String networkError = 'Skontrolujte internetové pripojenie.';
  static const String signInCancelled = 'Prihlásenie bolo zrušené.';
  static const String facebookLoginFailed = 'Prihlásenie cez Facebook sa nepodarilo.';
  static const String unknownAuthError = 'Nastala neznáma chyba pri prihlásení.';
  // Overenie e-mailu
  static const String verificationEmailSent =
    'Registrácia prebehla úspešne. Poslali sme vám overovací e-mail. '
    'Ak ho nevidíte v doručenej pošte, skontrolujte aj priečinok Spam.';
  static const String emailNotVerified = 'Najskôr potvrďte registráciu kliknutím na odkaz v e-maile.';
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
  static const String noTrainings = 'Momentálne nie sú dostupné žiadne tréningy.';
  static const String trainer = 'Tréner';
  static const String freeSpots = 'Voľné miesta';
  static const String minutes = 'min.';
  static const String reserve = 'Rezervovať';
  static const String fullCapacity = 'Obsadené';
  static const String trainingsLoadError = 'Nepodarilo sa načítať rozvrh tréningov.';
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
  static const String trainingTypesLoadError = 'Nepodarilo sa načítať typy cvičení.';
  static const String saveError = 'Uloženie sa nepodarilo.';
  static const String trainingSessionOverlap = 'V tomto čase už je naplánovaný iný tréning.';
  static const String deleteTrainingSession = 'Vymazať termín';
  static const String deleteTrainingSessionTitle = 'Vymazať termín tréningu';
  static const String deleteTrainingSessionQuestion = 'Naozaj chcete vymazať tento termín tréningu?';
  static const String trainingSessionDeleted = 'Termín tréningu bol vymazaný.';
  static const String deleteError = 'Vymazanie sa nepodarilo.';
  static const String delete = 'Vymazať';
  static const String cancel = 'Zrušiť';
  static const String today = 'Dnes';
  static const String tomorrow = 'Zajtra';
  static const String noTrainingsForSelectedDay = 'V tento deň nie sú naplánované žiadne tréningy.';
  static const List<String> shortWeekdays = ['Po', 'Ut', 'St', 'Št', 'Pi', 'So','Ne'];
  static const String scheduleManagement = 'Správa rozvrhu';
  static const String scheduleManagementDescription = 'Správa typov cvičení, šablón rozvrhu a konkrétnych tréningových termínov.';
  static const String trainingSessionInPast = 'Termín tréningu nemôže byť v minulosti.';
  // Šablóny rozvrhu
  static const String addScheduleTemplate = 'Pridať šablónu rozvrhu';
  static const String weekday = 'Deň v týždni';
  static const String selectWeekday = 'Vyberte deň v týždni';
  static const String scheduleTemplateCreated = 'Šablóna rozvrhu bola vytvorená.';
  static const String scheduleTemplateAlreadyExists = 'Takáto šablóna rozvrhu už existuje.';
  static const String scheduleTemplateLoadError = 'Nepodarilo sa načítať šablóny rozvrhu.';
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
  static const String scheduleTemplateOverlap = 'V tomto čase už existuje iná šablóna rozvrhu.';
  // Rezervácie
  static const String reservationCreated = 'Rezervácia bola vytvorená.';
  static const String reservationAlreadyExists = 'Na tento tréning už máte vytvorenú rezerváciu.';
  static const String reservationTrainingFull = 'Tento tréning je už obsadený.';
  static const String reservationTrainingNotAvailable = 'Tento tréning už nie je dostupný na rezerváciu.';
  static const String reservationTrainingAlreadyStarted = 'Na tento tréning sa už nedá rezervovať.';
  static const String reservationError = 'Rezerváciu sa nepodarilo vytvoriť.';
  static const String myReservations = 'Moje rezervácie';
  static const String noReservations = 'Momentálne nemáte žiadne rezervácie.';
  static const String reserved = 'Rezervované';
  static const String cancelReservation = 'Zrušiť rezerváciu';
  static const String cancelReservationTitle = 'Zrušiť rezerváciu';
  static const String cancelReservationQuestion = 'Naozaj chcete zrušiť túto rezerváciu?';
  static const String reservationCancelled = 'Rezervácia bola zrušená.';
  static const String reservationCancelError = 'Rezerváciu sa nepodarilo zrušiť.';
// Permanentky
  static const String assignMembership = 'Priradiť permanentku';
  static const String selectUser = 'Vyberte používateľa';
  static const String selectMembershipPlan = 'Vyberte typ permanentky';
  static const String usersLoadError = 'Nepodarilo sa načítať používateľov.';
  static const String membershipPlansLoadError = 'Nepodarilo sa načítať typy permanentiek.';
  static const String membershipAssigned = 'Permanentka bola priradená.';
  static const String membershipAssignError = 'Permanentku sa nepodarilo priradiť.';
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
  static const String membershipLoadError = 'Permanentku sa nepodarilo načítať.';
  static const String noAvailableEntries = 'Nemáte dostupný vstup na rezerváciu.';
  static const String noUpcomingTraining = 'Zatiaľ nemáte rezervované žiadne cvičenie.';
  static const String newsPlaceholder = 'Tu sa budú zobrazovať novinky a správy od trénerov.';
}
