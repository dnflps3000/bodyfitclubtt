import 'texts/app_texts_resolver.dart';

/// Centrálne texty aplikácie.
/// Neskôr by sa mohli pridať aj preklady (EN/SK).
class AppTexts {
  // Aplikácia / všeobecné
  static String get appName => AppTextsResolver.text('appName');
  static String get loading => AppTextsResolver.text('loading');
  static String get ok => AppTextsResolver.text('ok');
  static String get save => AppTextsResolver.text('save');
  static String get delete => AppTextsResolver.text('delete');
  static String get cancel => AppTextsResolver.text('cancel');
  static String get back => AppTextsResolver.text('back');
  static String get today => AppTextsResolver.text('today');
  static String get tomorrow => AppTextsResolver.text('tomorrow');
  static String get todayLower => AppTextsResolver.text('todayLower');
  static String get tomorrowLower => AppTextsResolver.text('tomorrowLower');
  static String get minutes => AppTextsResolver.text('minutes');
  static String get refresh => AppTextsResolver.text('refresh');
  static String get yesterday => AppTextsResolver.text('yesterday');
  static String get last7Days => AppTextsResolver.text('last7Days');
  static String get last30Days => AppTextsResolver.text('last30Days');
  static String get allTime => AppTextsResolver.text('allTime');
  static String get close => AppTextsResolver.text('close');
  static String get reason => AppTextsResolver.text('reason');
  static String get unknownDate => AppTextsResolver.text('unknownDate');
  static String get notSet => AppTextsResolver.text('notSet');
  static String get confirm => AppTextsResolver.text('confirm');

  // Navigácia / menu
  static String get menu => AppTextsResolver.text('menu');
  static String get home => AppTextsResolver.text('home');
  static String get schedule => AppTextsResolver.text('schedule');
  static String get reservations => AppTextsResolver.text('reservations');
  static String get management => AppTextsResolver.text('management');
  static String get profile => AppTextsResolver.text('profile');

  // Nastavenia
  static String get settings => AppTextsResolver.text('settings');
  static String get appearance => AppTextsResolver.text('appearance');
  static String get appearanceDescription =>
      AppTextsResolver.text('appearanceDescription');
  static String get themeSystem => AppTextsResolver.text('themeSystem');
  static String get themeLight => AppTextsResolver.text('themeLight');
  static String get themeDark => AppTextsResolver.text('themeDark');
  static String get menuPosition => AppTextsResolver.text('menuPosition');
  static String get menuPositionDescription =>
      AppTextsResolver.text('menuPositionDescription');
  static String get rightHanded => AppTextsResolver.text('rightHanded');
  static String get leftHanded => AppTextsResolver.text('leftHanded');
  static String get menuRightPositionDescription =>
      AppTextsResolver.text('menuRightPositionDescription');
  static String get menuLeftPositionDescription =>
      AppTextsResolver.text('menuLeftPositionDescription');

  // Jazyky
  static String get language => AppTextsResolver.text('language');
  static String get languageDescription =>
      AppTextsResolver.text('languageDescription');
  static String get languageSlovak => AppTextsResolver.text('languageSlovak');
  static String get languageEnglish => AppTextsResolver.text('languageEnglish');
  static String get languageGerman => AppTextsResolver.text('languageGerman');
  static String get languageFrench => AppTextsResolver.text('languageFrench');
  static String get languagePolish => AppTextsResolver.text('languagePolish');
  static String get languageHungarian =>
      AppTextsResolver.text('languageHungarian');
  static String get languageUkrainian =>
      AppTextsResolver.text('languageUkrainian');
  static String get languageRussian => AppTextsResolver.text('languageRussian');
  static String get languageSerbian => AppTextsResolver.text('languageSerbian');
  static String get languageCzech => AppTextsResolver.text('languageCzech');

  // Role
  static String get role => AppTextsResolver.text('role');
  static String get roleUser => AppTextsResolver.text('roleUser');
  static String get roleTrainer => AppTextsResolver.text('roleTrainer');
  static String get roleAdmin => AppTextsResolver.text('roleAdmin');
  static String get roleUnknown => AppTextsResolver.text('roleUnknown');

  // Auth / registrácia / prihlásenie
  static String get privacyPolicy => AppTextsResolver.text('privacyPolicy');
  static String get emailContact => AppTextsResolver.text('emailContact');
  static String get loginTitle => AppTextsResolver.text('loginTitle');
  static String get registerTitle => AppTextsResolver.text('registerTitle');
  static String get continueWithGoogle =>
      AppTextsResolver.text('continueWithGoogle');
  static String get continueWithFacebook =>
      AppTextsResolver.text('continueWithFacebook');
  static String get or => AppTextsResolver.text('or');
  static String get email => AppTextsResolver.text('email');
  static String get password => AppTextsResolver.text('password');
  static String get login => AppTextsResolver.text('login');
  static String get register => AppTextsResolver.text('register');
  static String get logout => AppTextsResolver.text('logout');
  static String get noAccountRegister =>
      AppTextsResolver.text('noAccountRegister');
  static String get hasAccountLogin => AppTextsResolver.text('hasAccountLogin');
  static String get authError => AppTextsResolver.text('authError');
  static String get acceptTerms => AppTextsResolver.text('acceptTerms');
  static String get acceptPrivacy => AppTextsResolver.text('acceptPrivacy');
  static String get termsConsentRequired =>
      AppTextsResolver.text('termsConsentRequired');
  static String get privacyConsentRequired =>
      AppTextsResolver.text('privacyConsentRequired');
  static String get openTerms => AppTextsResolver.text('openTerms');
  static String get openPrivacy => AppTextsResolver.text('openPrivacy');
  static String get termsVersion => AppTextsResolver.text('termsVersion');
  static String get privacyVersion => AppTextsResolver.text('privacyVersion');
  static String get continueWithoutAccount =>
      AppTextsResolver.text('continueWithoutAccount');
  static String get completeEmailOrLogout =>
      AppTextsResolver.text('completeEmailOrLogout');
  static String get fillEmailPassword =>
      AppTextsResolver.text('fillEmailPassword');
  static String get invalidEmailFormat =>
      AppTextsResolver.text('invalidEmailFormat');
  static String get passwordTooShort =>
      AppTextsResolver.text('passwordTooShort');
  static String get wrongEmailOrPassword =>
      AppTextsResolver.text('wrongEmailOrPassword');
  static String get userAlreadyExists =>
      AppTextsResolver.text('userAlreadyExists');
  static String get weakPassword => AppTextsResolver.text('weakPassword');
  static String get tooManyRequests => AppTextsResolver.text('tooManyRequests');
  static String get networkError => AppTextsResolver.text('networkError');
  static String get signInCancelled => AppTextsResolver.text('signInCancelled');
  static String get facebookLoginFailed =>
      AppTextsResolver.text('facebookLoginFailed');
  static String get unknownAuthError =>
      AppTextsResolver.text('unknownAuthError');
  static String get inactiveAccount => AppTextsResolver.text('inactiveAccount');
  static String get verificationEmailSent =>
      AppTextsResolver.text('verificationEmailSent');
  static String get emailNotVerified =>
      AppTextsResolver.text('emailNotVerified');
  static String get verificationEmailSentAgain =>
      AppTextsResolver.text('verificationEmailSentAgain');
  static String get forgotPassword => AppTextsResolver.text('forgotPassword');
  static String get resetPasswordTitle =>
      AppTextsResolver.text('resetPasswordTitle');
  static String get sendResetEmail => AppTextsResolver.text('sendResetEmail');
  static String get passwordResetEmailSent =>
      AppTextsResolver.text('passwordResetEmailSent');
  static String get emailRequired => AppTextsResolver.text('emailRequired');
  static String get emailNotProvided =>
      AppTextsResolver.text('emailNotProvided');
  static String get emailSaved => AppTextsResolver.text('emailSaved');
  static String get emailSaveError => AppTextsResolver.text('emailSaveError');
  static String get emailChangeVerificationSent =>
      AppTextsResolver.text('emailChangeVerificationSent');
  static String get emailChangeRequestError =>
      AppTextsResolver.text('emailChangeRequestError');
  static String get emailChangeNotAvailable =>
      AppTextsResolver.text('emailChangeNotAvailable');

  // Profil / účet
  static String get completeProfileTitle =>
      AppTextsResolver.text('completeProfileTitle');
  static String get editProfile => AppTextsResolver.text('editProfile');
  static String get firstName => AppTextsResolver.text('firstName');
  static String get lastName => AppTextsResolver.text('lastName');
  static String get publicName => AppTextsResolver.text('publicName');
  static String get publicNameHint => AppTextsResolver.text('publicNameHint');
  static String get firstNameRequired =>
      AppTextsResolver.text('firstNameRequired');
  static String get lastNameRequired =>
      AppTextsResolver.text('lastNameRequired');
  static String get publicNameRequired =>
      AppTextsResolver.text('publicNameRequired');
  static String get profileSaved => AppTextsResolver.text('profileSaved');
  static String get profileSaveError =>
      AppTextsResolver.text('profileSaveError');
  static String get loggedInUser => AppTextsResolver.text('loggedInUser');
  static String get completeEmailTitle =>
      AppTextsResolver.text('completeEmailTitle');
  static String get completeEmailDescription =>
      AppTextsResolver.text('completeEmailDescription');
  static String get deleteAccountRequest =>
      AppTextsResolver.text('deleteAccountRequest');
  static String get deleteAccountRequestTitle =>
      AppTextsResolver.text('deleteAccountRequestTitle');
  static String get deleteAccountRequestDescription =>
      AppTextsResolver.text('deleteAccountRequestDescription');
  static String get deleteAccountReason =>
      AppTextsResolver.text('deleteAccountReason');
  static String get deleteAccountConfirm =>
      AppTextsResolver.text('deleteAccountConfirm');
  static String get deleteAccountRequestSent =>
      AppTextsResolver.text('deleteAccountRequestSent');
  static String get deleteAccountRequestError =>
      AppTextsResolver.text('deleteAccountRequestError');
  static String get deleteAccountBlockedActiveReservations =>
      AppTextsResolver.text('deleteAccountBlockedActiveReservations');
  static String get accountDeletionRequests =>
      AppTextsResolver.text('accountDeletionRequests');
  static String get accountDeletionRequestsWithCount =>
      AppTextsResolver.text('accountDeletionRequestsWithCount');
  static String get accountDeletionRequestsLoadError =>
      AppTextsResolver.text('accountDeletionRequestsLoadError');
  static String get noAccountDeletionRequests =>
      AppTextsResolver.text('noAccountDeletionRequests');
  static String get completeAccountDeletion =>
      AppTextsResolver.text('completeAccountDeletion');
  static String get completeAccountDeletionTitle =>
      AppTextsResolver.text('completeAccountDeletionTitle');
  static String get completeAccountDeletionQuestion =>
      AppTextsResolver.text('completeAccountDeletionQuestion');
  static String get accountDeletionCompleted =>
      AppTextsResolver.text('accountDeletionCompleted');
  static String get accountDeletionCompleteError =>
      AppTextsResolver.text('accountDeletionCompleteError');
  static String get requestedAt => AppTextsResolver.text('requestedAt');
  static String get accountDeletionRequestsWaiting =>
      AppTextsResolver.text('accountDeletionRequestsWaiting');
  static String get changeEmail => AppTextsResolver.text('changeEmail');
  static String get changeEmailTitle =>
      AppTextsResolver.text('changeEmailTitle');
  static String get changeEmailDescription =>
      AppTextsResolver.text('changeEmailDescription');
  static String get changeEmailProfileHint =>
      AppTextsResolver.text('changeEmailProfileHint');
  static String get newEmail => AppTextsResolver.text('newEmail');
  static String get currentPassword => AppTextsResolver.text('currentPassword');
  static String get sendVerificationEmail =>
      AppTextsResolver.text('sendVerificationEmail');
  static String get wrongCurrentPassword =>
      AppTextsResolver.text('wrongCurrentPassword');
  static String get requiresRecentLogin =>
      AppTextsResolver.text('requiresRecentLogin');
  static String get changeProfilePhoto =>
      AppTextsResolver.text('changeProfilePhoto');
  static String get chooseFromGallery =>
      AppTextsResolver.text('chooseFromGallery');
  static String get takePhoto => AppTextsResolver.text('takePhoto');
  static String get removePhoto => AppTextsResolver.text('removePhoto');
  static String get editPhoto => AppTextsResolver.text('editPhoto');
  static String get cropProfilePhoto =>
      AppTextsResolver.text('cropProfilePhoto');
  static String get profilePhotoUpdated =>
      AppTextsResolver.text('profilePhotoUpdated');
  static String get profilePhotoUpdateError =>
      AppTextsResolver.text('profilePhotoUpdateError');
  static String get profilePhotoRemoveError =>
      AppTextsResolver.text('profilePhotoRemoveError');

  // Zľavy
  static String get requestDiscount => AppTextsResolver.text('requestDiscount');
  static String get discountStatus => AppTextsResolver.text('discountStatus');
  static String get discountStatusNone =>
      AppTextsResolver.text('discountStatusNone');
  static String get discountStatusPending =>
      AppTextsResolver.text('discountStatusPending');
  static String get discountStatusApproved =>
      AppTextsResolver.text('discountStatusApproved');
  static String get discountStatusRejected =>
      AppTextsResolver.text('discountStatusRejected');
  static String get discountStatusExpired =>
      AppTextsResolver.text('discountStatusExpired');
  static String get discountType => AppTextsResolver.text('discountType');
  static String get discountTypeNormal =>
      AppTextsResolver.text('discountTypeNormal');
  static String get discountTypeStudent =>
      AppTextsResolver.text('discountTypeStudent');
  static String get discountTypeSenior =>
      AppTextsResolver.text('discountTypeSenior');
  static String get discountTypeZtp => AppTextsResolver.text('discountTypeZtp');
  static String get discountTypeIndividual =>
      AppTextsResolver.text('discountTypeIndividual');
  static String get discountRequestDescription =>
      AppTextsResolver.text('discountRequestDescription');
  static String get discountRequestNote =>
      AppTextsResolver.text('discountRequestNote');
  static String get discountRequestSent =>
      AppTextsResolver.text('discountRequestSent');
  static String get discountRequestError =>
      AppTextsResolver.text('discountRequestError');
  static String get discountRequestAlreadyPending =>
      AppTextsResolver.text('discountRequestAlreadyPending');
  static String get discountRequestPending =>
      AppTextsResolver.text('discountRequestPending');
  static String get sendRequest => AppTextsResolver.text('sendRequest');
  static String get discountDocument =>
      AppTextsResolver.text('discountDocument');
  static String get discountDocumentDescription =>
      AppTextsResolver.text('discountDocumentDescription');
  static String get chooseDiscountDocument =>
      AppTextsResolver.text('chooseDiscountDocument');
  static String get discountDocumentRequired =>
      AppTextsResolver.text('discountDocumentRequired');
  static String get discountDocumentSelected =>
      AppTextsResolver.text('discountDocumentSelected');
  static String get takeDiscountDocumentPhoto =>
      AppTextsResolver.text('takeDiscountDocumentPhoto');
  static String get chooseDiscountDocumentFromGallery =>
      AppTextsResolver.text('chooseDiscountDocumentFromGallery');
  static String get discountRequests =>
      AppTextsResolver.text('discountRequests');
  static String get discountRequestsDescription =>
      AppTextsResolver.text('discountRequestsDescription');
  static String get discountRequestsLoadError =>
      AppTextsResolver.text('discountRequestsLoadError');
  static String get noDiscountRequests =>
      AppTextsResolver.text('noDiscountRequests');
  static String get approveDiscount => AppTextsResolver.text('approveDiscount');
  static String get rejectDiscount => AppTextsResolver.text('rejectDiscount');
  static String get discountApproved =>
      AppTextsResolver.text('discountApproved');
  static String get discountRejected =>
      AppTextsResolver.text('discountRejected');
  static String get discountDecisionError =>
      AppTextsResolver.text('discountDecisionError');
  static String get discountValidUntilRequired =>
      AppTextsResolver.text('discountValidUntilRequired');
  static String get discountAdminNote =>
      AppTextsResolver.text('discountAdminNote');
  static String get selectDiscountValidUntil =>
      AppTextsResolver.text('selectDiscountValidUntil');
  static String get discountDocumentPreview =>
      AppTextsResolver.text('discountDocumentPreview');

  // Home obrazovka
  static String get todayReservations =>
      AppTextsResolver.text('todayReservations');
  static String get noTodayReservations =>
      AppTextsResolver.text('noTodayReservations');
  static String get nearestTraining => AppTextsResolver.text('nearestTraining');
  static String get nearestTrainings =>
      AppTextsResolver.text('nearestTrainings');
  static String get noNearestTraining =>
      AppTextsResolver.text('noNearestTraining');
  static String get todaysTrainings => AppTextsResolver.text('todaysTrainings');
  static String get noTodaysTrainings =>
      AppTextsResolver.text('noTodaysTrainings');
  static String get myMemberships => AppTextsResolver.text('myMemberships');
  static String get activeMembershipsCount =>
      AppTextsResolver.text('activeMembershipsCount');
  static String get availableEntriesSummary =>
      AppTextsResolver.text('availableEntriesSummary');
  static String get reservedEntriesSummary =>
      AppTextsResolver.text('reservedEntriesSummary');
  static String get dailyMembershipsSummary =>
      AppTextsResolver.text('dailyMembershipsSummary');
  static String get tapToShowQrCode => AppTextsResolver.text('tapToShowQrCode');
  static String get nearestReservations =>
      AppTextsResolver.text('nearestReservations');
  static String get noNearestReservations =>
      AppTextsResolver.text('noNearestReservations');
  static String get qrShort => AppTextsResolver.text('qrShort');
  static String get membershipStatus =>
      AppTextsResolver.text('membershipStatus');
  static String get remainingEntries =>
      AppTextsResolver.text('remainingEntries');
  static String get upcomingTraining =>
      AppTextsResolver.text('upcomingTraining');
  static String get schedulePlaceholder =>
      AppTextsResolver.text('schedulePlaceholder');
  static String get reservationsPlaceholder =>
      AppTextsResolver.text('reservationsPlaceholder');
  static String get newsPlaceholder => AppTextsResolver.text('newsPlaceholder');

  // Info obrazovky
  static String get aboutApp => AppTextsResolver.text('aboutApp');
  static String get aboutUs => AppTextsResolver.text('aboutUs');
  static String get aboutAppDescription =>
      AppTextsResolver.text('aboutAppDescription');
  static String get aboutUsDescription =>
      AppTextsResolver.text('aboutUsDescription');
  static String get bodyFitClubWebsite =>
      AppTextsResolver.text('bodyFitClubWebsite');
  static String get openWebsite => AppTextsResolver.text('openWebsite');
  static String get businessTerms => AppTextsResolver.text('businessTerms');
  static String get legalDocumentsInfo =>
      AppTextsResolver.text('legalDocumentsInfo');
  static String get contacts => AppTextsResolver.text('contacts');
  static String get billingDetails => AppTextsResolver.text('billingDetails');
  static String get address => AppTextsResolver.text('address');
  static String get phone => AppTextsResolver.text('phone');
  static String get website => AppTextsResolver.text('website');
  static String get socialNetworks => AppTextsResolver.text('socialNetworks');
  static String get openMap => AppTextsResolver.text('openMap');
  static String get openFacebook => AppTextsResolver.text('openFacebook');
  static String get openInstagram => AppTextsResolver.text('openInstagram');
  static String get multisport => AppTextsResolver.text('multisport');
  static String get multisportInfo => AppTextsResolver.text('multisportInfo');
  static String get bodyFitClubCompanyName =>
      AppTextsResolver.text('bodyFitClubCompanyName');
  static String get bodyFitClubOperationAddress =>
      AppTextsResolver.text('bodyFitClubOperationAddress');
  static String get bodyFitClubBillingAddress =>
      AppTextsResolver.text('bodyFitClubBillingAddress');
  static String get bodyFitClubPhonePrimary =>
      AppTextsResolver.text('bodyFitClubPhonePrimary');
  static String get bodyFitClubPhoneSecondary =>
      AppTextsResolver.text('bodyFitClubPhoneSecondary');
  static String get bodyFitClubEmail =>
      AppTextsResolver.text('bodyFitClubEmail');
  static String get bodyFitClubIco => AppTextsResolver.text('bodyFitClubIco');
  static String get ico => AppTextsResolver.text('ico');
  static String get companySeat => AppTextsResolver.text('companySeat');
  static String get operation => AppTextsResolver.text('operation');
  static String get bodyFitClubFacebookUrl =>
      AppTextsResolver.text('bodyFitClubFacebookUrl');
  static String get bodyFitClubInstagramUrl =>
      AppTextsResolver.text('bodyFitClubInstagramUrl');
  static String get bodyFitClubMapUrl =>
      AppTextsResolver.text('bodyFitClubMapUrl');
  static String get bodyFitClubMultiSportUrl =>
      AppTextsResolver.text('bodyFitClubMultiSportUrl');
  static String get multisportInfo2 => AppTextsResolver.text('multisportInfo2');
  static String get bodyFitClubWebsiteLabel =>
      AppTextsResolver.text('bodyFitClubWebsiteLabel');
  static String get dic => AppTextsResolver.text('dic');
  static String get bodyFitClubDic => AppTextsResolver.text('bodyFitClubDic');
  static String get notVatPayer => AppTextsResolver.text('notVatPayer');
  static String get legalDocuments => AppTextsResolver.text('legalDocuments');

  // Cenník
  static String get priceList => AppTextsResolver.text('priceList');
  static String get priceListAudience =>
      AppTextsResolver.text('priceListAudience');
  static String get priceListAudienceNormal =>
      AppTextsResolver.text('priceListAudienceNormal');
  static String get priceListAudienceDiscount =>
      AppTextsResolver.text('priceListAudienceDiscount');
  static String get priceListAudienceAll =>
      AppTextsResolver.text('priceListAudienceAll');
  static String get price => AppTextsResolver.text('price');
  static String get singleEntries => AppTextsResolver.text('singleEntries');
  static String get priceListMemberships =>
      AppTextsResolver.text('priceListMemberships');
  static String get chooseEntry => AppTextsResolver.text('chooseEntry');
  static String get noAvailablePlans =>
      AppTextsResolver.text('noAvailablePlans');

  // Novinky / verejné správy
  static String get news => AppTextsResolver.text('news');
  static String get noPublicMessages =>
      AppTextsResolver.text('noPublicMessages');
  static String get writeMessage => AppTextsResolver.text('writeMessage');
  static String get writeMessageShort =>
      AppTextsResolver.text('writeMessageShort');
  static String get editMessage => AppTextsResolver.text('editMessage');
  static String get deleteMessage => AppTextsResolver.text('deleteMessage');
  static String get deleteMessageQuestion =>
      AppTextsResolver.text('deleteMessageQuestion');
  static String get messageText => AppTextsResolver.text('messageText');
  static String get messageHint => AppTextsResolver.text('messageHint');
  static String get sendMessage => AppTextsResolver.text('sendMessage');
  static String get updateMessage => AppTextsResolver.text('updateMessage');
  static String get messageSaved => AppTextsResolver.text('messageSaved');
  static String get messageDeleted => AppTextsResolver.text('messageDeleted');
  static String get messageSaveError =>
      AppTextsResolver.text('messageSaveError');
  static String get messageDeleteError =>
      AppTextsResolver.text('messageDeleteError');
  static String get editedBy => AppTextsResolver.text('editedBy');
  static String get editedByAdmin => AppTextsResolver.text('editedByAdmin');
  static String get editedByTrainer => AppTextsResolver.text('editedByTrainer');
  static String get userFallback => AppTextsResolver.text('userFallback');

  // Rozvrh tréningov
  static String get noTrainings => AppTextsResolver.text('noTrainings');
  static String get noTrainingsForSelectedDay =>
      AppTextsResolver.text('noTrainingsForSelectedDay');
  static String get trainer => AppTextsResolver.text('trainer');
  static String get freeSpots => AppTextsResolver.text('freeSpots');
  static String get reserve => AppTextsResolver.text('reserve');
  static String get reserved => AppTextsResolver.text('reserved');
  static String get fullCapacity => AppTextsResolver.text('fullCapacity');
  static String get trainingsLoadError =>
      AppTextsResolver.text('trainingsLoadError');
  static String get unknownTraining => AppTextsResolver.text('unknownTraining');
  static String get unknownTrainer => AppTextsResolver.text('unknownTrainer');
  static String get unknownUser => AppTextsResolver.text('unknownUser');
  static String get trainingSessionFinished =>
      AppTextsResolver.text('trainingSessionFinished');
  static String get trainingSessionTooFarInFuture =>
      AppTextsResolver.text('trainingSessionTooFarInFuture');
  static List<String> get shortWeekdays =>
      AppTextsResolver.list('shortWeekdays');
  static String scheduleMessageTrainingSessionCreated({
    required String trainingName,
    required String date,
    required String time,
  }) {
    if (AppTextsResolver.isEnglish) {
      return 'A new training session has been added to the schedule:\n'
          '$trainingName – $date at $time.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Eine neue Trainingseinheit wurde zum Zeitplan hinzugefügt:\n'
          '$trainingName – $date um $time.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Un nouvel entraînement a été ajouté au planning :\n'
          '$trainingName – $date à $time.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'До розкладу додано нове тренування:\n'
          '$trainingName – $date о $time.';
    }
    if (AppTextsResolver.isRussian) {
      return 'В расписание добавлена новая тренировка:\n'
          '$trainingName – $date в $time.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'U raspored je dodat novi trening:\n'
          '$trainingName – $date u $time.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Új edzés került az órarendbe:\n'
          '$trainingName – $date, $time.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Do harmonogramu dodano nowy trening:\n'
          '$trainingName – $date o $time.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Do rozvrhu byl přidán nový trénink:\n'
          '$trainingName – $date v $time.';
    }
    return 'Do rozvrhu bol pridaný nový tréning:\n'
        '$trainingName – $date o $time.';
  }

  static String scheduleMessageTrainingSessionCancelled({
    required String trainingName,
    required String date,
    required String time,
  }) {
    if (AppTextsResolver.isEnglish) {
      return 'The training session has been cancelled:\n'
          '$trainingName – $date at $time.\n'
          'Active reservations have been cancelled and allocated entries have been released.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Die Trainingseinheit wurde abgesagt:\n'
          '$trainingName – $date um $time.\n'
          'Aktive Reservierungen wurden storniert und reservierte Eintritte wurden freigegeben.';
    }
    if (AppTextsResolver.isFrench) {
      return 'L’entraînement a été annulé :\n'
          '$trainingName – $date à $time.\n'
          'Les réservations actives ont été annulées et les entrées allouées ont été libérées.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Тренування було скасовано:\n'
          '$trainingName – $date о $time.\n'
          'Активні бронювання були скасовані, а зарезервовані входи звільнені.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Тренировка была отменена:\n'
          '$trainingName – $date в $time.\n'
          'Активные бронирования отменены, зарезервированные входы освобождены.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Trening je otkazan:\n'
          '$trainingName – $date u $time.\n'
          'Aktivne rezervacije su otkazane, a rezervisani ulasci oslobođeni.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Az edzés törölve lett:\n'
          '$trainingName – $date, $time.\n'
          'Az aktív foglalások törölve lettek, a lefoglalt belépések pedig felszabadultak.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Trening został anulowany:\n'
          '$trainingName – $date o $time.\n'
          'Aktywne rezerwacje zostały anulowane, a przydzielone wejścia zwolnione.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Trénink byl zrušen:\n'
          '$trainingName – $date v $time.\n'
          'Aktivní rezervace byly zrušeny a alokované vstupy byly uvolněny.';
    }
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
    if (AppTextsResolver.isEnglish) {
      return 'The training session time has been changed:\n'
          '$trainingName was moved from $oldDate at $oldTime '
          'to $newDate at $newTime.\n'
          'Original reservations have been cancelled and allocated entries have been released.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Der Trainingstermin wurde geändert:\n'
          '$trainingName wurde von $oldDate um $oldTime '
          'auf $newDate um $newTime verschoben.\n'
          'Ursprüngliche Reservierungen wurden storniert und reservierte Eintritte wurden freigegeben.';
    }
    if (AppTextsResolver.isFrench) {
      return 'L’heure de l’entraînement a été modifiée :\n'
          '$trainingName a été déplacé de $oldDate à $oldTime '
          'au $newDate à $newTime.\n'
          'Les réservations initiales ont été annulées et les entrées allouées ont été libérées.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Термін тренування було змінено:\n'
          '$trainingName перенесено з $oldDate о $oldTime '
          'на $newDate о $newTime.\n'
          'Початкові бронювання були скасовані, а зарезервовані входи звільнені.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Время тренировки было изменено:\n'
          '$trainingName перенесена с $oldDate в $oldTime '
          'на $newDate в $newTime.\n'
          'Первоначальные бронирования отменены, зарезервированные входы освобождены.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Termin treninga je promenjen:\n'
          '$trainingName je premešten sa $oldDate u $oldTime '
          'na $newDate u $newTime.\n'
          'Prvobitne rezervacije su otkazane, a rezervisani ulasci oslobođeni.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Az edzés időpontja módosult:\n'
          '$trainingName átkerült erről: $oldDate $oldTime '
          'erre: $newDate $newTime.\n'
          'Az eredeti foglalások törölve lettek, a lefoglalt belépések pedig felszabadultak.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Termin treningu został zmieniony:\n'
          '$trainingName został przeniesiony z $oldDate o $oldTime '
          'na $newDate o $newTime.\n'
          'Pierwotne rezerwacje zostały anulowane, a przydzielone wejścia zwolnione.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Termín tréninku byl změněn:\n'
          '$trainingName byl přesunut z $oldDate v $oldTime '
          'na $newDate v $newTime.\n'
          'Původní rezervace byly zrušeny a alokované vstupy byly uvolněny.';
    }
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
    if (AppTextsResolver.isEnglish) {
      return 'The training session has been updated:\n'
          '$trainingName – $date at $time.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Der Trainingstermin wurde aktualisiert:\n'
          '$trainingName – $date um $time.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Le créneau d’entraînement a été modifié :\n'
          '$trainingName – $date à $time.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Термін тренування було оновлено:\n'
          '$trainingName – $date о $time.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Тренировка была обновлена:\n'
          '$trainingName – $date в $time.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Termin treninga je izmenjen:\n'
          '$trainingName – $date u $time.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Az edzésidőpont módosítva lett:\n'
          '$trainingName – $date, $time.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Termin treningu został zaktualizowany:\n'
          '$trainingName – $date o $time.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Termín tréninku byl upraven:\n'
          '$trainingName – $date v $time.';
    }
    return 'Termín tréningu bol upravený:\n'
        '$trainingName – $date o $time.';
  }

  static String scheduleMessageTemplateCreated({
    required String trainingName,
    required String weekday,
    required String time,
  }) {
    if (AppTextsResolver.isEnglish) {
      return 'The regular weekly schedule has been updated:\n'
          'A regular training session has been added:\n'
          '$trainingName – $weekday at $time.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Der regelmäßige Wochenplan wurde aktualisiert:\n'
          'Eine regelmäßige Trainingseinheit wurde hinzugefügt:\n'
          '$trainingName – $weekday um $time.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Le planning hebdomadaire régulier a été modifié :\n'
          'Un entraînement régulier a été ajouté :\n'
          '$trainingName – $weekday à $time.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Регулярний тижневий розклад було оновлено:\n'
          'Додано регулярне тренування:\n'
          '$trainingName – $weekday о $time.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Регулярное недельное расписание было обновлено:\n'
          'Добавлена регулярная тренировка:\n'
          '$trainingName – $weekday в $time.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Redovni nedeljni raspored je izmenjen:\n'
          'Dodat je redovni trening:\n'
          '$trainingName – $weekday u $time.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'A rendszeres heti órarend módosítva lett:\n'
          'Új rendszeres edzés lett hozzáadva:\n'
          '$trainingName – $weekday, $time.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Regularny harmonogram tygodniowy został zaktualizowany:\n'
          'Dodano regularny trening:\n'
          '$trainingName – $weekday o $time.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Pravidelný týdenní rozvrh byl upraven:\n'
          'Byl přidán pravidelný trénink:\n'
          '$trainingName – $weekday v $time.';
    }
    return 'Pravidelný týždenný rozvrh bol upravený:\n'
        'Pribudol pravidelný tréning:\n'
        '$trainingName – $weekday o $time.';
  }

  static String scheduleMessageTemplateUpdated({
    required String trainingName,
    required String oldSchedule,
    required String newSchedule,
  }) {
    if (AppTextsResolver.isEnglish) {
      return 'The regular weekly schedule has been updated:\n'
          '$trainingName has been updated.\n'
          'Original schedule: $oldSchedule.\n'
          'New schedule: $newSchedule.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Der regelmäßige Wochenplan wurde aktualisiert:\n'
          '$trainingName wurde bearbeitet.\n'
          'Ursprünglich: $oldSchedule.\n'
          'Neuer Zeitplan: $newSchedule.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Le planning hebdomadaire régulier a été modifié :\n'
          '$trainingName a été modifié.\n'
          'Planning initial : $oldSchedule.\n'
          'Nouveau planning : $newSchedule.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Регулярний тижневий розклад було оновлено:\n'
          '$trainingName було змінено.\n'
          'Попередньо: $oldSchedule.\n'
          'Новий розклад: $newSchedule.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Регулярное недельное расписание было обновлено:\n'
          '$trainingName была изменена.\n'
          'Ранее: $oldSchedule.\n'
          'Новое расписание: $newSchedule.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Redovni nedeljni raspored je izmenjen:\n'
          '$trainingName je izmenjen.\n'
          'Prethodno: $oldSchedule.\n'
          'Novi raspored: $newSchedule.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'A rendszeres heti órarend módosítva lett:\n'
          '$trainingName módosítva lett.\n'
          'Eredetileg: $oldSchedule.\n'
          'Új órarend: $newSchedule.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Regularny harmonogram tygodniowy został zaktualizowany:\n'
          '$trainingName został zaktualizowany.\n'
          'Poprzednio: $oldSchedule.\n'
          'Nowy harmonogram: $newSchedule.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Pravidelný týdenní rozvrh byl upraven:\n'
          '$trainingName byl upraven.\n'
          'Původně: $oldSchedule.\n'
          'Nový rozvrh: $newSchedule.';
    }
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
    if (AppTextsResolver.isEnglish) {
      return 'The regular weekly schedule has been updated:\n'
          'A training session has been removed from the regular schedule:\n'
          '$trainingName – $weekday at $time.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Der regelmäßige Wochenplan wurde aktualisiert:\n'
          'Eine Trainingseinheit wurde aus dem regelmäßigen Plan entfernt:\n'
          '$trainingName – $weekday um $time.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Le planning hebdomadaire régulier a été modifié :\n'
          'Un entraînement a été supprimé du planning régulier :\n'
          '$trainingName – $weekday à $time.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Регулярний тижневий розклад було оновлено:\n'
          'З регулярного розкладу видалено тренування:\n'
          '$trainingName – $weekday о $time.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Регулярное недельное расписание было обновлено:\n'
          'Из регулярного расписания удалена тренировка:\n'
          '$trainingName – $weekday в $time.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Redovni nedeljni raspored je izmenjen:\n'
          'Iz redovnog rasporeda je uklonjen trening:\n'
          '$trainingName – $weekday u $time.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'A rendszeres heti órarend módosítva lett:\n'
          'Egy edzés el lett távolítva a rendszeres órarendből:\n'
          '$trainingName – $weekday, $time.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Regularny harmonogram tygodniowy został zaktualizowany:\n'
          'Usunięto trening z regularnego harmonogramu:\n'
          '$trainingName – $weekday o $time.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Pravidelný týdenní rozvrh byl upraven:\n'
          'Z pravidelného rozvrhu byl odstraněn trénink:\n'
          '$trainingName – $weekday v $time.';
    }
    return 'Pravidelný týždenný rozvrh bol upravený:\n'
        'Z pravidelného rozvrhu bol odstránený tréning:\n'
        '$trainingName – $weekday o $time.';
  }

  // Správa rozvrhu
  static String get managementDescription =>
      AppTextsResolver.text('managementDescription');
  static String get scheduleManagement =>
      AppTextsResolver.text('scheduleManagement');
  static String get scheduleManagementDescription =>
      AppTextsResolver.text('scheduleManagementDescription');
  static String get attendanceManagement =>
      AppTextsResolver.text('attendanceManagement');
  static String get usersManagement => AppTextsResolver.text('usersManagement');
  static String get usersManagementComingSoon =>
      AppTextsResolver.text('usersManagementComingSoon');
  static String get scheduleTemplatesManagement =>
      AppTextsResolver.text('scheduleTemplatesManagement');
  static String get reactivateUser => AppTextsResolver.text('reactivateUser');
  static String get reactivateUserQuestion =>
      AppTextsResolver.text('reactivateUserQuestion');
  static String get userReactivated => AppTextsResolver.text('userReactivated');
  static String get trainingTypesManagement =>
      AppTextsResolver.text('trainingTypesManagement');
  static String get addTrainingType => AppTextsResolver.text('addTrainingType');
  static String get editTrainingType =>
      AppTextsResolver.text('editTrainingType');
  static String get deleteTrainingType =>
      AppTextsResolver.text('deleteTrainingType');
  static String get trainingType => AppTextsResolver.text('trainingType');
  static String get selectTrainingType =>
      AppTextsResolver.text('selectTrainingType');
  static String get trainingName => AppTextsResolver.text('trainingName');
  static String get description => AppTextsResolver.text('description');
  static String get defaultDuration => AppTextsResolver.text('defaultDuration');
  static String get defaultCapacity => AppTextsResolver.text('defaultCapacity');
  static String get noTrainingTypes => AppTextsResolver.text('noTrainingTypes');
  static String get trainingTypesLoadError =>
      AppTextsResolver.text('trainingTypesLoadError');
  static String get trainingTypeCreated =>
      AppTextsResolver.text('trainingTypeCreated');
  static String get trainingTypeUpdated =>
      AppTextsResolver.text('trainingTypeUpdated');
  static String get trainingTypeDeleted =>
      AppTextsResolver.text('trainingTypeDeleted');
  static String get trainingTypeDeleteQuestion =>
      AppTextsResolver.text('trainingTypeDeleteQuestion');
  static String get trainingTypeAlreadyExists =>
      AppTextsResolver.text('trainingTypeAlreadyExists');
  static String get trainingTypeUsedByTemplate =>
      AppTextsResolver.text('trainingTypeUsedByTemplate');
  static String get trainingTypeUsedBySession =>
      AppTextsResolver.text('trainingTypeUsedBySession');
  static String get addTrainingSession =>
      AppTextsResolver.text('addTrainingSession');
  static String get editTrainingSession =>
      AppTextsResolver.text('editTrainingSession');
  static String get trainingSessionCreated =>
      AppTextsResolver.text('trainingSessionCreated');
  static String get trainingSessionUpdated =>
      AppTextsResolver.text('trainingSessionUpdated');
  static String get updateTrainingSessionError =>
      AppTextsResolver.text('updateTrainingSessionError');
  static String get trainingSessionInPast =>
      AppTextsResolver.text('trainingSessionInPast');
  static String get trainingSessionOverlap =>
      AppTextsResolver.text('trainingSessionOverlap');
  static String get capacityLowerThanReservations =>
      AppTextsResolver.text('capacityLowerThanReservations');
  static String get cancelTrainingSession =>
      AppTextsResolver.text('cancelTrainingSession');
  static String get cancelTrainingSessionTitle =>
      AppTextsResolver.text('cancelTrainingSessionTitle');
  static String get cancelTrainingSessionQuestion =>
      AppTextsResolver.text('cancelTrainingSessionQuestion');
  static String get cancelTrainingSessionConfirm =>
      AppTextsResolver.text('cancelTrainingSessionConfirm');
  static String get trainingSessionCancelled =>
      AppTextsResolver.text('trainingSessionCancelled');
  static String get cancelTrainingSessionError =>
      AppTextsResolver.text('cancelTrainingSessionError');
  static String get trainerCanCancelOnlyOwnSession =>
      AppTextsResolver.text('trainerCanCancelOnlyOwnSession');
  static String get trainerCannotCancelStartedSession =>
      AppTextsResolver.text('trainerCannotCancelStartedSession');
  static String get date => AppTextsResolver.text('date');
  static String get startTime => AppTextsResolver.text('startTime');
  static String get duration => AppTextsResolver.text('duration');
  static String get capacity => AppTextsResolver.text('capacity');
  static String get selectDate => AppTextsResolver.text('selectDate');
  static String get selectTrainer => AppTextsResolver.text('selectTrainer');
  static String get trainersLoadError =>
      AppTextsResolver.text('trainersLoadError');
  static String get fillAllFields => AppTextsResolver.text('fillAllFields');
  static String get invalidCapacity => AppTextsResolver.text('invalidCapacity');
  static String get invalidDuration => AppTextsResolver.text('invalidDuration');
  static String get saveError => AppTextsResolver.text('saveError');
  static String get addScheduleTemplate =>
      AppTextsResolver.text('addScheduleTemplate');
  static String get editScheduleTemplate =>
      AppTextsResolver.text('editScheduleTemplate');
  static String get deleteScheduleTemplate =>
      AppTextsResolver.text('deleteScheduleTemplate');
  static String get noScheduleTemplates =>
      AppTextsResolver.text('noScheduleTemplates');
  static String get weekday => AppTextsResolver.text('weekday');
  static String get selectWeekday => AppTextsResolver.text('selectWeekday');
  static String get scheduleTemplateCreated =>
      AppTextsResolver.text('scheduleTemplateCreated');
  static String get scheduleTemplateUpdated =>
      AppTextsResolver.text('scheduleTemplateUpdated');
  static String get scheduleTemplateDeleted =>
      AppTextsResolver.text('scheduleTemplateDeleted');
  static String get scheduleTemplateDeleteQuestion =>
      AppTextsResolver.text('scheduleTemplateDeleteQuestion');
  static String get scheduleTemplateAlreadyExists =>
      AppTextsResolver.text('scheduleTemplateAlreadyExists');
  static String get scheduleTemplateLoadError =>
      AppTextsResolver.text('scheduleTemplateLoadError');
  static String get scheduleTemplateOverlap =>
      AppTextsResolver.text('scheduleTemplateOverlap');
  static List<String> get weekdays => AppTextsResolver.list('weekdays');
  static String get capacityLabel => AppTextsResolver.text('capacityLabel');

  // Rezervácie
  static String get reservationCreated =>
      AppTextsResolver.text('reservationCreated');
  static String get reservationAlreadyExists =>
      AppTextsResolver.text('reservationAlreadyExists');
  static String get reservationTrainingFull =>
      AppTextsResolver.text('reservationTrainingFull');
  static String get reservationTrainingNotAvailable =>
      AppTextsResolver.text('reservationTrainingNotAvailable');
  static String get reservationTrainingAlreadyStarted =>
      AppTextsResolver.text('reservationTrainingAlreadyStarted');
  static String get reservationError =>
      AppTextsResolver.text('reservationError');
  static String get myReservations => AppTextsResolver.text('myReservations');
  static String get noReservations => AppTextsResolver.text('noReservations');
  static String get cancelReservation =>
      AppTextsResolver.text('cancelReservation');
  static String get cancelReservationTitle =>
      AppTextsResolver.text('cancelReservationTitle');
  static String get cancelReservationQuestion =>
      AppTextsResolver.text('cancelReservationQuestion');
  static String get reservationCancelled =>
      AppTextsResolver.text('reservationCancelled');
  static String get reservationCancelError =>
      AppTextsResolver.text('reservationCancelError');
  static String get reservationsLoadError =>
      AppTextsResolver.text('reservationsLoadError');
  static String get cancelReservations =>
      AppTextsResolver.text('cancelReservations');
  static String get cancelReservationsBeforeDeactivation =>
      AppTextsResolver.text('cancelReservationsBeforeDeactivation');
  static String get cancelReservationForMembership =>
      AppTextsResolver.text('cancelReservationForMembership');
  static String get cancelReservationForMembershipQuestion =>
      AppTextsResolver.text('cancelReservationForMembershipQuestion');
  static String get reservationForMembershipCancelled =>
      AppTextsResolver.text('reservationForMembershipCancelled');
  static String get noReservationsForTrainingHistory =>
      AppTextsResolver.text('noReservationsForTrainingHistory');
  static String get reservationQrCode =>
      AppTextsResolver.text('reservationQrCode');

  // Permanentky / platby
  static String get memberships => AppTextsResolver.text('memberships');
  static String get assignMembership =>
      AppTextsResolver.text('assignMembership');
  static String get selectUser => AppTextsResolver.text('selectUser');
  static String get selectMembershipPlan =>
      AppTextsResolver.text('selectMembershipPlan');
  static String get membershipPlansLoadError =>
      AppTextsResolver.text('membershipPlansLoadError');
  static String get membershipAssigned =>
      AppTextsResolver.text('membershipAssigned');
  static String get membershipAssignError =>
      AppTextsResolver.text('membershipAssignError');
  static String get membershipPlan => AppTextsResolver.text('membershipPlan');
  static String get client => AppTextsResolver.text('client');
  static String get buyMembership => AppTextsResolver.text('buyMembership');
  static String get buySingleEntry => AppTextsResolver.text('buySingleEntry');
  static String get chooseMembership =>
      AppTextsResolver.text('chooseMembership');
  static String get payment => AppTextsResolver.text('payment');
  static String get pay => AppTextsResolver.text('pay');
  static String get paymentSuccessful =>
      AppTextsResolver.text('paymentSuccessful');
  static String get paymentFailed => AppTextsResolver.text('paymentFailed');
  static String get activeMembership =>
      AppTextsResolver.text('activeMembership');
  static String get noActiveMembership =>
      AppTextsResolver.text('noActiveMembership');
  static String get validUntil => AppTextsResolver.text('validUntil');
  static String get membershipLoadError =>
      AppTextsResolver.text('membershipLoadError');
  static String get noAvailableEntries =>
      AppTextsResolver.text('noAvailableEntries');
  static String get noUpcomingTraining =>
      AppTextsResolver.text('noUpcomingTraining');
  static String get membershipsManagement =>
      AppTextsResolver.text('membershipsManagement');
  static String get membershipDetail =>
      AppTextsResolver.text('membershipDetail');
  static String get noMemberships => AppTextsResolver.text('noMemberships');
  static String get status => AppTextsResolver.text('status');
  static String get validFrom => AppTextsResolver.text('validFrom');
  static String get entriesTotal => AppTextsResolver.text('entriesTotal');
  static String get entriesRemaining =>
      AppTextsResolver.text('entriesRemaining');
  static String get entriesReserved => AppTextsResolver.text('entriesReserved');
  static String get entriesAvailable =>
      AppTextsResolver.text('entriesAvailable');
  static String get adminMembershipEdit =>
      AppTextsResolver.text('adminMembershipEdit');
  static String get membershipStatusActive =>
      AppTextsResolver.text('membershipStatusActive');
  static String get membershipStatusInactive =>
      AppTextsResolver.text('membershipStatusInactive');
  static String get membershipStatusCancelled =>
      AppTextsResolver.text('membershipStatusCancelled');
  static String get membershipStatusExpired =>
      AppTextsResolver.text('membershipStatusExpired');
  static String get membershipStatusUsedUp =>
      AppTextsResolver.text('membershipStatusUsedUp');
  static String get membershipUpdated =>
      AppTextsResolver.text('membershipUpdated');
  static String get membershipUpdateError =>
      AppTextsResolver.text('membershipUpdateError');
  static String get invalidRemainingEntries =>
      AppTextsResolver.text('invalidRemainingEntries');
  static String get allocatedReservations =>
      AppTextsResolver.text('allocatedReservations');
  static String get cancelAllocatedReservations =>
      AppTextsResolver.text('cancelAllocatedReservations');
  static String get cancelAllocatedReservationsQuestion =>
      AppTextsResolver.text('cancelAllocatedReservationsQuestion');
  static String get cancelAllReservations =>
      AppTextsResolver.text('cancelAllReservations');
  static String get cancelAllocatedReservationsError =>
      AppTextsResolver.text('cancelAllocatedReservationsError');
  static String get usedEntries => AppTextsResolver.text('usedEntries');
  static String get noAllocatedReservations =>
      AppTextsResolver.text('noAllocatedReservations');
  static String get noUsedEntries => AppTextsResolver.text('noUsedEntries');
  static String get membershipUsageLoadError =>
      AppTextsResolver.text('membershipUsageLoadError');
  static String get searchMemberships =>
      AppTextsResolver.text('searchMemberships');
  static String get allMembershipStatuses =>
      AppTextsResolver.text('allMembershipStatuses');
  static String get membershipStatusNotYetValid =>
      AppTextsResolver.text('membershipStatusNotYetValid');
  static String get membershipStatusUsable =>
      AppTextsResolver.text('membershipStatusUsable');
  static String get invalidRemainingEntriesHigherThanTotal =>
      AppTextsResolver.text('invalidRemainingEntriesHigherThanTotal');
  static String get invalidRemainingEntriesLowerThanReserved =>
      AppTextsResolver.text('invalidRemainingEntriesLowerThanReserved');
  static String get membershipPrefix =>
      AppTextsResolver.text('membershipPrefix');
  static String get statusPrefix => AppTextsResolver.text('statusPrefix');

  // Dochádzka / QR
  static String get attendance => AppTextsResolver.text('attendance');
  static String get attendanceLoadError =>
      AppTextsResolver.text('attendanceLoadError');
  static String get noActiveReservationsForAttendance =>
      AppTextsResolver.text('noActiveReservationsForAttendance');
  static String get attended => AppTextsResolver.text('attended');
  static String get noShow => AppTextsResolver.text('noShow');
  static String get markAttendedTitle =>
      AppTextsResolver.text('markAttendedTitle');
  static String get markNoShowTitle => AppTextsResolver.text('markNoShowTitle');
  static String get markAttendedQuestion =>
      AppTextsResolver.text('markAttendedQuestion');
  static String get markNoShowQuestion =>
      AppTextsResolver.text('markNoShowQuestion');
  static String get attendanceMarked =>
      AppTextsResolver.text('attendanceMarked');
  static String get attendanceMarkError =>
      AppTextsResolver.text('attendanceMarkError');
  static String get attendedStatus => AppTextsResolver.text('attendedStatus');
  static String get noShowStatus => AppTextsResolver.text('noShowStatus');
  static String get attendedCountLabel =>
      AppTextsResolver.text('attendedCountLabel');
  static String get noShowCountLabel =>
      AppTextsResolver.text('noShowCountLabel');
  static String get attendanceActionDone =>
      AppTextsResolver.text('attendanceActionDone');
  static String get attendanceActionError =>
      AppTextsResolver.text('attendanceActionError');
  static String get showQrCode => AppTextsResolver.text('showQrCode');
  static String get showQrToTrainer => AppTextsResolver.text('showQrToTrainer');
  static String get scanQrCode => AppTextsResolver.text('scanQrCode');
  static String get scanQrCodes => AppTextsResolver.text('scanQrCodes');
  static String get scanQrCodeHint => AppTextsResolver.text('scanQrCodeHint');
  static String get invalidQrCode => AppTextsResolver.text('invalidQrCode');
  static String get qrCodeScanned => AppTextsResolver.text('qrCodeScanned');
  static String get qrScanSuccessful =>
      AppTextsResolver.text('qrScanSuccessful');
  static String get trainerQrScanTooEarly =>
      AppTextsResolver.text('trainerQrScanTooEarly');

  // História tréningov
  static String get trainingHistory => AppTextsResolver.text('trainingHistory');
  static String get trainingHistoryDetail =>
      AppTextsResolver.text('trainingHistoryDetail');
  static String get trainingHistoryLoadError =>
      AppTextsResolver.text('trainingHistoryLoadError');
  static String get trainingHistoryReservationsLoadError =>
      AppTextsResolver.text('trainingHistoryReservationsLoadError');
  static String get noTrainingHistoryInSelectedPeriod =>
      AppTextsResolver.text('noTrainingHistoryInSelectedPeriod');
  static String get fromDatePrefix => AppTextsResolver.text('fromDatePrefix');
  static String get toDatePrefix => AppTextsResolver.text('toDatePrefix');
  static String get planned => AppTextsResolver.text('planned');
  static String get cancelled => AppTextsResolver.text('cancelled');
  static String get finished => AppTextsResolver.text('finished');
  static String get reservedStatus => AppTextsResolver.text('reservedStatus');
  static String get reservedCountLabel =>
      AppTextsResolver.text('reservedCountLabel');
  static String get cancelledCountLabel =>
      AppTextsResolver.text('cancelledCountLabel');
  static String get markedAtPrefix => AppTextsResolver.text('markedAtPrefix');
  static String get markAsAttended => AppTextsResolver.text('markAsAttended');
  static String get markAsNoShow => AppTextsResolver.text('markAsNoShow');
  static String get revertAttendance =>
      AppTextsResolver.text('revertAttendance');
  static String get revertNoShow => AppTextsResolver.text('revertNoShow');
  static String get markAsAttendedQuestion =>
      AppTextsResolver.text('markAsAttendedQuestion');
  static String get markAsNoShowQuestion =>
      AppTextsResolver.text('markAsNoShowQuestion');
  static String get revertAttendanceQuestion =>
      AppTextsResolver.text('revertAttendanceQuestion');
  static String get revertNoShowQuestion =>
      AppTextsResolver.text('revertNoShowQuestion');
  static String get addTrainingAttendance =>
      AppTextsResolver.text('addTrainingAttendance');
  static String get selectAttendanceUser =>
      AppTextsResolver.text('selectAttendanceUser');
  static String get selectAttendanceMembership =>
      AppTextsResolver.text('selectAttendanceMembership');
  static String get noUsersForAttendance =>
      AppTextsResolver.text('noUsersForAttendance');
  static String get noUsableMembershipsForAttendance =>
      AppTextsResolver.text('noUsableMembershipsForAttendance');
  static String get addTrainingAttendanceQuestion =>
      AppTextsResolver.text('addTrainingAttendanceQuestion');
  static String get trainingAttendanceAdded =>
      AppTextsResolver.text('trainingAttendanceAdded');
  static String get trainingAttendanceAddError =>
      AppTextsResolver.text('trainingAttendanceAddError');
  static String get userAlreadyHasReservationForTraining =>
      AppTextsResolver.text('userAlreadyHasReservationForTraining');

  // Správa používateľov
  static String get usersLoadError => AppTextsResolver.text('usersLoadError');
  static String get allRoles => AppTextsResolver.text('allRoles');
  static String get searchUsers => AppTextsResolver.text('searchUsers');
  static String get noUsersFound => AppTextsResolver.text('noUsersFound');
  static String get editUser => AppTextsResolver.text('editUser');
  static String get userUpdated => AppTextsResolver.text('userUpdated');
  static String get userUpdateError => AppTextsResolver.text('userUpdateError');
  static String get cannotChangeOwnRole =>
      AppTextsResolver.text('cannotChangeOwnRole');
  static String get changeRoleWarning =>
      AppTextsResolver.text('changeRoleWarning');
  static String get deactivateUser => AppTextsResolver.text('deactivateUser');
  static String get deactivationReason =>
      AppTextsResolver.text('deactivationReason');
  static String get userDeactivated => AppTextsResolver.text('userDeactivated');
  static String get deactivateUserQuestion =>
      AppTextsResolver.text('deactivateUserQuestion');
  static String get cannotDeactivateYourself =>
      AppTextsResolver.text('cannotDeactivateYourself');
  static String get userUsedByTemplate =>
      AppTextsResolver.text('userUsedByTemplate');
  static String get userUsedByFutureSession =>
      AppTextsResolver.text('userUsedByFutureSession');
  static String get userHasActiveReservations =>
      AppTextsResolver.text('userHasActiveReservations');
  static String get userHasActiveMemberships =>
      AppTextsResolver.text('userHasActiveMemberships');
  static String get inactiveUser => AppTextsResolver.text('inactiveUser');
  static String get userCannotBeDeactivated =>
      AppTextsResolver.text('userCannotBeDeactivated');
  static String get userCannotBeDeactivatedDescription =>
      AppTextsResolver.text('userCannotBeDeactivatedDescription');
  static String get userHasBlockingItems =>
      AppTextsResolver.text('userHasBlockingItems');
  static String get activeReservationsCount =>
      AppTextsResolver.text('activeReservationsCount');
  static String get showMemberships => AppTextsResolver.text('showMemberships');

  // História zásahov / audit logy
  static String get auditLogs => AppTextsResolver.text('auditLogs');
  static String get auditLogsDescription =>
      AppTextsResolver.text('auditLogsDescription');
  static String get auditLogsLoadError =>
      AppTextsResolver.text('auditLogsLoadError');
  static String get noAuditLogs => AppTextsResolver.text('noAuditLogs');
  static String get searchAuditLogs => AppTextsResolver.text('searchAuditLogs');
  static String get auditCategory => AppTextsResolver.text('auditCategory');
  static String get auditAction => AppTextsResolver.text('auditAction');
  static String get auditActor => AppTextsResolver.text('auditActor');
  static String get auditActorRole => AppTextsResolver.text('auditActorRole');
  static String get auditPeriod => AppTextsResolver.text('auditPeriod');
  static String get auditAllCategories =>
      AppTextsResolver.text('auditAllCategories');
  static String get auditCategoryMemberships =>
      AppTextsResolver.text('auditCategoryMemberships');
  static String get auditCategoryReservations =>
      AppTextsResolver.text('auditCategoryReservations');
  static String get auditCategoryAttendance =>
      AppTextsResolver.text('auditCategoryAttendance');
  static String get auditCategoryUsers =>
      AppTextsResolver.text('auditCategoryUsers');
  static String get auditCategorySchedule =>
      AppTextsResolver.text('auditCategorySchedule');
  static String get auditCategoryMessages =>
      AppTextsResolver.text('auditCategoryMessages');
  static String get auditCategoryPayments =>
      AppTextsResolver.text('auditCategoryPayments');
  static String get auditCategoryProfile =>
      AppTextsResolver.text('auditCategoryProfile');
  static String get auditAllActions => AppTextsResolver.text('auditAllActions');
  static String get auditActionCreated =>
      AppTextsResolver.text('auditActionCreated');
  static String get auditActionUpdated =>
      AppTextsResolver.text('auditActionUpdated');
  static String get auditActionCancelled =>
      AppTextsResolver.text('auditActionCancelled');
  static String get auditActionDeactivated =>
      AppTextsResolver.text('auditActionDeactivated');
  static String get auditActionActivated =>
      AppTextsResolver.text('auditActionActivated');
  static String get auditActionAssigned =>
      AppTextsResolver.text('auditActionAssigned');
  static String get auditActionPurchased =>
      AppTextsResolver.text('auditActionPurchased');
  static String get auditActionPaymentSucceeded =>
      AppTextsResolver.text('auditActionPaymentSucceeded');
  static String get auditActionPaymentFailed =>
      AppTextsResolver.text('auditActionPaymentFailed');
  static String get auditActionAttendanceMarked =>
      AppTextsResolver.text('auditActionAttendanceMarked');
  static String get auditActionQrChecked =>
      AppTextsResolver.text('auditActionQrChecked');
  static String get auditAllActorRoles =>
      AppTextsResolver.text('auditAllActorRoles');
  static String get auditReservationCreatedTitle =>
      AppTextsResolver.text('auditReservationCreatedTitle');
  static String get auditReservationCreatedDescription =>
      AppTextsResolver.text('auditReservationCreatedDescription');
  static String get auditReservationCancelledTitle =>
      AppTextsResolver.text('auditReservationCancelledTitle');
  static String get auditReservationCancelledDescription =>
      AppTextsResolver.text('auditReservationCancelledDescription');
  static String get auditAttendanceAttendedTitle =>
      AppTextsResolver.text('auditAttendanceAttendedTitle');
  static String get auditAttendanceAttendedDescription =>
      AppTextsResolver.text('auditAttendanceAttendedDescription');
  static String get auditAttendanceNoShowTitle =>
      AppTextsResolver.text('auditAttendanceNoShowTitle');
  static String get auditAttendanceNoShowDescription =>
      AppTextsResolver.text('auditAttendanceNoShowDescription');
  static String get auditTrainingTypeCreatedTitle =>
      AppTextsResolver.text('auditTrainingTypeCreatedTitle');
  static String get auditTrainingTypeUpdatedTitle =>
      AppTextsResolver.text('auditTrainingTypeUpdatedTitle');
  static String get auditTrainingTypeDeactivatedTitle =>
      AppTextsResolver.text('auditTrainingTypeDeactivatedTitle');
  static String get auditTrainingSessionCreatedTitle =>
      AppTextsResolver.text('auditTrainingSessionCreatedTitle');
  static String get auditTrainingSessionUpdatedTitle =>
      AppTextsResolver.text('auditTrainingSessionUpdatedTitle');
  static String get auditTrainingSessionTimeChangedTitle =>
      AppTextsResolver.text('auditTrainingSessionTimeChangedTitle');
  static String get auditTrainingSessionCancelledTitle =>
      AppTextsResolver.text('auditTrainingSessionCancelledTitle');
  static String get auditScheduleTemplateCreatedTitle =>
      AppTextsResolver.text('auditScheduleTemplateCreatedTitle');
  static String get auditScheduleTemplateUpdatedTitle =>
      AppTextsResolver.text('auditScheduleTemplateUpdatedTitle');
  static String get auditScheduleTemplateDeactivatedTitle =>
      AppTextsResolver.text('auditScheduleTemplateDeactivatedTitle');
  static String auditTrainingTypeCreatedDescription(String trainingName) {
    if (AppTextsResolver.isEnglish) {
      return 'The training type $trainingName was created.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Der Trainingstyp $trainingName wurde erstellt.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Le type d’entraînement $trainingName a été créé.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було створено тип тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Был создан тип занятия $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Kreiran je tip treninga $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Létre lett hozva a(z) $trainingName edzéstípus.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Utworzono typ zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byl vytvořen typ cvičení $trainingName.';
    }
    return 'Bol vytvorený typ cvičenia $trainingName.';
  }

  static String auditTrainingTypeUpdatedDescription(String trainingName) {
    if (AppTextsResolver.isEnglish) {
      return 'The training type $trainingName was updated.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Der Trainingstyp $trainingName wurde aktualisiert.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Le type d’entraînement $trainingName a été modifié.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було змінено тип тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Был изменён тип занятия $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Izmenjen je tip treninga $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Módosítva lett a(z) $trainingName edzéstípus.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Zaktualizowano typ zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byl upraven typ cvičení $trainingName.';
    }
    return 'Bol upravený typ cvičenia $trainingName.';
  }

  static String auditTrainingTypeDeactivatedDescription(String trainingName) {
    if (AppTextsResolver.isEnglish) {
      return 'The training type $trainingName was deactivated.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Der Trainingstyp $trainingName wurde deaktiviert.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Le type d’entraînement $trainingName a été désactivé.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було деактивовано тип тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Был деактивирован тип занятия $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Deaktiviran je tip treninga $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Deaktiválva lett a(z) $trainingName edzéstípus.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Dezaktywowano typ zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byl deaktivován typ cvičení $trainingName.';
    }
    return 'Bol deaktivovaný typ cvičenia $trainingName.';
  }

  static String auditTrainingSessionCreatedDescription(String trainingName) {
    if (AppTextsResolver.isEnglish) {
      return 'A specific training session for $trainingName was created.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Ein konkreter Trainingstermin für $trainingName wurde erstellt.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Un créneau concret pour l’entraînement $trainingName a été créé.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було створено конкретний термін тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Была создана конкретная тренировка $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Kreiran je konkretan termin treninga $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Létre lett hozva a(z) $trainingName konkrét edzésidőpontja.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Utworzono konkretny termin zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byl vytvořen konkrétní termín cvičení $trainingName.';
    }
    return 'Bol vytvorený konkrétny termín cvičenia $trainingName.';
  }

  static String auditTrainingSessionUpdatedDescription(String trainingName) {
    if (AppTextsResolver.isEnglish) {
      return 'A specific training session for $trainingName was updated.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Ein konkreter Trainingstermin für $trainingName wurde aktualisiert.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Un créneau concret pour l’entraînement $trainingName a été modifié.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було змінено конкретний термін тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Была изменена конкретная тренировка $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Izmenjen je konkretan termin treninga $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Módosítva lett a(z) $trainingName konkrét edzésidőpontja.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Zaktualizowano konkretny termin zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byl upraven konkrétní termín cvičení $trainingName.';
    }
    return 'Bol upravený konkrétny termín cvičenia $trainingName.';
  }

  static String auditTrainingSessionTimeChangedDescription(
    String trainingName,
  ) {
    if (AppTextsResolver.isEnglish) {
      return 'The time of a specific training session for $trainingName was changed.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Die Zeit eines konkreten Trainingstermins für $trainingName wurde geändert.';
    }
    if (AppTextsResolver.isFrench) {
      return 'L’heure d’un créneau concret pour l’entraînement $trainingName a été modifiée.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було змінено час конкретного терміну тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Было изменено время конкретной тренировки $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Promenjeno je vreme konkretnog termina treninga $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Módosítva lett a(z) $trainingName konkrét edzésidőpontjának ideje.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Zmieniono czas konkretnego terminu zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byl změněn čas konkrétního termínu cvičení $trainingName.';
    }
    return 'Bol zmenený čas konkrétneho termínu cvičenia $trainingName.';
  }

  static String auditTrainingSessionCancelledDescription(String trainingName) {
    if (AppTextsResolver.isEnglish) {
      return 'A specific training session for $trainingName was cancelled.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Ein konkreter Trainingstermin für $trainingName wurde abgesagt.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Un créneau concret pour l’entraînement $trainingName a été annulé.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було скасовано конкретний термін тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Была отменена конкретная тренировка $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Otkazan je konkretan termin treninga $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Törölve lett a(z) $trainingName konkrét edzésidőpontja.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Anulowano konkretny termin zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byl zrušen konkrétní termín cvičení $trainingName.';
    }
    return 'Bol zrušený konkrétny termín cvičenia $trainingName.';
  }

  static String auditScheduleTemplateCreatedDescription(String trainingName) {
    if (AppTextsResolver.isEnglish) {
      return 'A regular schedule template for $trainingName was created.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Eine Vorlage für den regelmäßigen Zeitplan für $trainingName wurde erstellt.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Un modèle de planning régulier a été créé pour l’entraînement $trainingName.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було створено шаблон регулярного розкладу для тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Был создан шаблон регулярного расписания для занятия $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Kreiran je šablon redovnog rasporeda za trening $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Létre lett hozva a(z) $trainingName rendszeres órarend-sablonja.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Utworzono szablon regularnego harmonogramu dla zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byla vytvořena šablona pravidelného rozvrhu pro cvičení $trainingName.';
    }
    return 'Bola vytvorená šablóna pravidelného rozvrhu pre cvičenie $trainingName.';
  }

  static String auditScheduleTemplateUpdatedDescription(String trainingName) {
    if (AppTextsResolver.isEnglish) {
      return 'A regular schedule template for $trainingName was updated.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Eine Vorlage für den regelmäßigen Zeitplan für $trainingName wurde aktualisiert.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Un modèle de planning régulier a été modifié pour l’entraînement $trainingName.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було змінено шаблон регулярного розкладу для тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Был изменён шаблон регулярного расписания для занятия $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Izmenjen je šablon redovnog rasporeda za trening $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Módosítva lett a(z) $trainingName rendszeres órarend-sablonja.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Zaktualizowano szablon regularnego harmonogramu dla zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byla upravena šablona pravidelného rozvrhu pro cvičení $trainingName.';
    }
    return 'Bola upravená šablóna pravidelného rozvrhu pre cvičenie $trainingName.';
  }

  static String auditScheduleTemplateDeactivatedDescription(
    String trainingName,
  ) {
    if (AppTextsResolver.isEnglish) {
      return 'A regular schedule template for $trainingName was deactivated.';
    }
    if (AppTextsResolver.isGerman) {
      return 'Eine Vorlage für den regelmäßigen Zeitplan für $trainingName wurde deaktiviert.';
    }
    if (AppTextsResolver.isFrench) {
      return 'Un modèle de planning régulier a été désactivé pour l’entraînement $trainingName.';
    }
    if (AppTextsResolver.isUkrainian) {
      return 'Було деактивовано шаблон регулярного розкладу для тренування $trainingName.';
    }
    if (AppTextsResolver.isRussian) {
      return 'Был деактивирован шаблон регулярного расписания для занятия $trainingName.';
    }
    if (AppTextsResolver.isSerbian) {
      return 'Deaktiviran je šablon redovnog rasporeda za trening $trainingName.';
    }
    if (AppTextsResolver.isHungarian) {
      return 'Deaktiválva lett a(z) $trainingName rendszeres órarend-sablonja.';
    }
    if (AppTextsResolver.isPolish) {
      return 'Dezaktywowano szablon regularnego harmonogramu dla zajęć $trainingName.';
    }
    if (AppTextsResolver.isCzech) {
      return 'Byla deaktivována šablona pravidelného rozvrhu pro cvičení $trainingName.';
    }
    return 'Bola deaktivovaná šablóna pravidelného rozvrhu pre cvičenie $trainingName.';
  }

  static String get auditUserUpdatedTitle =>
      AppTextsResolver.text('auditUserUpdatedTitle');
  static String get auditUserUpdatedDescription =>
      AppTextsResolver.text('auditUserUpdatedDescription');
  static String get auditUserRoleChangedTitle =>
      AppTextsResolver.text('auditUserRoleChangedTitle');
  static String get auditUserRoleChangedDescription =>
      AppTextsResolver.text('auditUserRoleChangedDescription');
  static String get auditUserDeactivatedTitle =>
      AppTextsResolver.text('auditUserDeactivatedTitle');
  static String get auditUserDeactivatedDescription =>
      AppTextsResolver.text('auditUserDeactivatedDescription');
  static String get auditUserDeactivationBlockedTitle =>
      AppTextsResolver.text('auditUserDeactivationBlockedTitle');
  static String get auditUserDeactivationBlockedDescription =>
      AppTextsResolver.text('auditUserDeactivationBlockedDescription');
  static String get auditPublicMessageCreatedTitle =>
      AppTextsResolver.text('auditPublicMessageCreatedTitle');
  static String get auditPublicMessageCreatedDescription =>
      AppTextsResolver.text('auditPublicMessageCreatedDescription');
  static String get auditPublicMessageUpdatedTitle =>
      AppTextsResolver.text('auditPublicMessageUpdatedTitle');
  static String get auditPublicMessageUpdatedDescription =>
      AppTextsResolver.text('auditPublicMessageUpdatedDescription');
  static String get auditPublicMessageDeletedTitle =>
      AppTextsResolver.text('auditPublicMessageDeletedTitle');
  static String get auditPublicMessageDeletedDescription =>
      AppTextsResolver.text('auditPublicMessageDeletedDescription');
  static String get auditProfileCompletedTitle =>
      AppTextsResolver.text('auditProfileCompletedTitle');
  static String get auditProfileCompletedDescription =>
      AppTextsResolver.text('auditProfileCompletedDescription');
  static String get auditProfileUpdatedTitle =>
      AppTextsResolver.text('auditProfileUpdatedTitle');
  static String get auditProfileUpdatedDescription =>
      AppTextsResolver.text('auditProfileUpdatedDescription');
  static String get auditProfilePhotoUpdatedTitle =>
      AppTextsResolver.text('auditProfilePhotoUpdatedTitle');
  static String get auditProfilePhotoUpdatedDescription =>
      AppTextsResolver.text('auditProfilePhotoUpdatedDescription');
  static String get auditProfilePhotoRemovedTitle =>
      AppTextsResolver.text('auditProfilePhotoRemovedTitle');
  static String get auditProfilePhotoRemovedDescription =>
      AppTextsResolver.text('auditProfilePhotoRemovedDescription');
  static String get auditPaymentStartedTitle =>
      AppTextsResolver.text('auditPaymentStartedTitle');
  static String get auditPaymentStartedDescription =>
      AppTextsResolver.text('auditPaymentStartedDescription');
  static String get auditPaymentSucceededTitle =>
      AppTextsResolver.text('auditPaymentSucceededTitle');
  static String get auditPaymentSucceededDescription =>
      AppTextsResolver.text('auditPaymentSucceededDescription');
  static String get auditPaymentFailedTitle =>
      AppTextsResolver.text('auditPaymentFailedTitle');
  static String get auditPaymentFailedDescription =>
      AppTextsResolver.text('auditPaymentFailedDescription');
  static String get auditMembershipUpdatedTitle =>
      AppTextsResolver.text('auditMembershipUpdatedTitle');
  static String get auditMembershipUpdatedDescription =>
      AppTextsResolver.text('auditMembershipUpdatedDescription');
  static String get auditMembershipStatusChangedTitle =>
      AppTextsResolver.text('auditMembershipStatusChangedTitle');
  static String get auditMembershipStatusChangedDescription =>
      AppTextsResolver.text('auditMembershipStatusChangedDescription');
  static String get auditMembershipEntriesChangedTitle =>
      AppTextsResolver.text('auditMembershipEntriesChangedTitle');
  static String get auditMembershipEntriesChangedDescription =>
      AppTextsResolver.text('auditMembershipEntriesChangedDescription');
  static String get auditMembershipReservationCancelledTitle =>
      AppTextsResolver.text('auditMembershipReservationCancelledTitle');
  static String get auditMembershipReservationCancelledDescription =>
      AppTextsResolver.text('auditMembershipReservationCancelledDescription');
  static String get auditMembershipAllReservationsCancelledTitle =>
      AppTextsResolver.text('auditMembershipAllReservationsCancelledTitle');
  static String get auditMembershipAllReservationsCancelledDescription =>
      AppTextsResolver.text(
        'auditMembershipAllReservationsCancelledDescription',
      );
  static String get auditMembershipAssignedTitle =>
      AppTextsResolver.text('auditMembershipAssignedTitle');
  static String get auditMembershipAssignedDescription =>
      AppTextsResolver.text('auditMembershipAssignedDescription');
  static String get auditMembershipPurchasedTitle =>
      AppTextsResolver.text('auditMembershipPurchasedTitle');
  static String get auditMembershipPurchasedDescription =>
      AppTextsResolver.text('auditMembershipPurchasedDescription');
  static String get auditActionMembershipAssigned =>
      AppTextsResolver.text('auditActionMembershipAssigned');
  static String get auditActionMembershipPurchased =>
      AppTextsResolver.text('auditActionMembershipPurchased');
  static String get auditActionMembershipUpdated =>
      AppTextsResolver.text('auditActionMembershipUpdated');
  static String get auditActionMembershipStatusChanged =>
      AppTextsResolver.text('auditActionMembershipStatusChanged');
  static String get auditActionMembershipEntriesChanged =>
      AppTextsResolver.text('auditActionMembershipEntriesChanged');
  static String get auditActionMembershipReservationCancelled =>
      AppTextsResolver.text('auditActionMembershipReservationCancelled');
  static String get auditActionMembershipAllReservationsCancelled =>
      AppTextsResolver.text('auditActionMembershipAllReservationsCancelled');
  static String get auditActionReservationCreated =>
      AppTextsResolver.text('auditActionReservationCreated');
  static String get auditActionReservationCancelled =>
      AppTextsResolver.text('auditActionReservationCancelled');
  static String get auditActionAttendanceAttended =>
      AppTextsResolver.text('auditActionAttendanceAttended');
  static String get auditActionAttendanceNoShow =>
      AppTextsResolver.text('auditActionAttendanceNoShow');
  static String get auditActionTrainingTypeCreated =>
      AppTextsResolver.text('auditActionTrainingTypeCreated');
  static String get auditActionTrainingTypeUpdated =>
      AppTextsResolver.text('auditActionTrainingTypeUpdated');
  static String get auditActionTrainingTypeDeactivated =>
      AppTextsResolver.text('auditActionTrainingTypeDeactivated');
  static String get auditActionTrainingSessionCreated =>
      AppTextsResolver.text('auditActionTrainingSessionCreated');
  static String get auditActionTrainingSessionUpdated =>
      AppTextsResolver.text('auditActionTrainingSessionUpdated');
  static String get auditActionTrainingSessionTimeChanged =>
      AppTextsResolver.text('auditActionTrainingSessionTimeChanged');
  static String get auditActionTrainingSessionCancelled =>
      AppTextsResolver.text('auditActionTrainingSessionCancelled');
  static String get auditActionScheduleTemplateCreated =>
      AppTextsResolver.text('auditActionScheduleTemplateCreated');
  static String get auditActionScheduleTemplateUpdated =>
      AppTextsResolver.text('auditActionScheduleTemplateUpdated');
  static String get auditActionScheduleTemplateDeactivated =>
      AppTextsResolver.text('auditActionScheduleTemplateDeactivated');
  static String get auditActionUserUpdated =>
      AppTextsResolver.text('auditActionUserUpdated');
  static String get auditActionUserRoleChanged =>
      AppTextsResolver.text('auditActionUserRoleChanged');
  static String get auditActionUserDeactivationBlocked =>
      AppTextsResolver.text('auditActionUserDeactivationBlocked');
  static String get auditActionUserDeactivated =>
      AppTextsResolver.text('auditActionUserDeactivated');
  static String get auditActionPublicMessageCreated =>
      AppTextsResolver.text('auditActionPublicMessageCreated');
  static String get auditActionPublicMessageUpdated =>
      AppTextsResolver.text('auditActionPublicMessageUpdated');
  static String get auditActionPublicMessageDeleted =>
      AppTextsResolver.text('auditActionPublicMessageDeleted');
  static String get auditActionProfileCompleted =>
      AppTextsResolver.text('auditActionProfileCompleted');
  static String get auditActionProfileUpdated =>
      AppTextsResolver.text('auditActionProfileUpdated');
  static String get auditActionProfilePhotoUpdated =>
      AppTextsResolver.text('auditActionProfilePhotoUpdated');
  static String get auditActionProfilePhotoRemoved =>
      AppTextsResolver.text('auditActionProfilePhotoRemoved');
  static String get auditActionPaymentStarted =>
      AppTextsResolver.text('auditActionPaymentStarted');
  static String get auditUserEmailCompletedTitle =>
      AppTextsResolver.text('auditUserEmailCompletedTitle');
  static String get auditUserEmailCompletedDescription =>
      AppTextsResolver.text('auditUserEmailCompletedDescription');
  static String get currentUserShort =>
      AppTextsResolver.text('currentUserShort');
  static String get auditUserEmailUpdatedTitle =>
      AppTextsResolver.text('auditUserEmailUpdatedTitle');
  static String get auditUserEmailUpdatedDescription =>
      AppTextsResolver.text('auditUserEmailUpdatedDescription');
  static String get auditUserReactivatedTitle =>
      AppTextsResolver.text('auditUserReactivatedTitle');
  static String get auditUserReactivatedDescription =>
      AppTextsResolver.text('auditUserReactivatedDescription');
  static String get auditActionUserEmailCompleted =>
      AppTextsResolver.text('auditActionUserEmailCompleted');
  static String get auditActionUserEmailUpdated =>
      AppTextsResolver.text('auditActionUserEmailUpdated');
  static String get auditActionUserReactivated =>
      AppTextsResolver.text('auditActionUserReactivated');
  static String get auditCategoryDiscounts =>
      AppTextsResolver.text('auditCategoryDiscounts');
  static String get auditDiscountRequestedTitle =>
      AppTextsResolver.text('auditDiscountRequestedTitle');
  static String get auditDiscountRequestedDescription =>
      AppTextsResolver.text('auditDiscountRequestedDescription');
  static String get auditDiscountApprovedTitle =>
      AppTextsResolver.text('auditDiscountApprovedTitle');
  static String get auditDiscountApprovedDescription =>
      AppTextsResolver.text('auditDiscountApprovedDescription');
  static String get auditDiscountRejectedTitle =>
      AppTextsResolver.text('auditDiscountRejectedTitle');
  static String get auditDiscountRejectedDescription =>
      AppTextsResolver.text('auditDiscountRejectedDescription');
  static String get auditAccountDeletionRequestedTitle =>
      AppTextsResolver.text('auditAccountDeletionRequestedTitle');
  static String get auditAccountDeletionRequestedDescription =>
      AppTextsResolver.text('auditAccountDeletionRequestedDescription');
  static String get auditEmailChangeRequestedTitle =>
      AppTextsResolver.text('auditEmailChangeRequestedTitle');
  static String get auditEmailChangeRequestedDescription =>
      AppTextsResolver.text('auditEmailChangeRequestedDescription');
  static String get auditEmailChangeCompletedTitle =>
      AppTextsResolver.text('auditEmailChangeCompletedTitle');
  static String get auditEmailChangeCompletedDescription =>
      AppTextsResolver.text('auditEmailChangeCompletedDescription');
  static String get auditPasswordResetRequestedTitle =>
      AppTextsResolver.text('auditPasswordResetRequestedTitle');
  static String get auditPasswordResetRequestedDescription =>
      AppTextsResolver.text('auditPasswordResetRequestedDescription');
  static String get auditActionDiscountRequested =>
      AppTextsResolver.text('auditActionDiscountRequested');
  static String get auditActionDiscountApproved =>
      AppTextsResolver.text('auditActionDiscountApproved');
  static String get auditActionDiscountRejected =>
      AppTextsResolver.text('auditActionDiscountRejected');
  static String get auditActionAccountDeletionRequested =>
      AppTextsResolver.text('auditActionAccountDeletionRequested');
  static String get auditActionEmailChangeRequested =>
      AppTextsResolver.text('auditActionEmailChangeRequested');
  static String get auditActionEmailChangeCompleted =>
      AppTextsResolver.text('auditActionEmailChangeCompleted');
  static String get auditActionPasswordResetRequested =>
      AppTextsResolver.text('auditActionPasswordResetRequested');

  // Pomocné textové metódy
  static String allocatedReservationsCancelled(int count) {
    if (AppTextsResolver.isUkrainian) {
      if (count == 1) {
        return 'Скасовано 1 бронювання.';
      }
      if (count >= 2 && count <= 4) {
        return 'Скасовано $count бронювання.';
      }
      return 'Скасовано $count бронювань.';
    }
    if (AppTextsResolver.isRussian) {
      if (count == 1) {
        return 'Отменено 1 бронирование.';
      }
      if (count >= 2 && count <= 4) {
        return 'Отменено $count бронирования.';
      }
      return 'Отменено $count бронирований.';
    }
    if (AppTextsResolver.isSerbian) {
      if (count == 1) {
        return 'Otkazana je 1 rezervacija.';
      }
      return 'Otkazano je $count rezervacija.';
    }
    if (AppTextsResolver.isEnglish) {
      if (count == 1) {
        return '1 reservation has been cancelled.';
      }
      return '$count reservations have been cancelled.';
    }
    if (AppTextsResolver.isGerman) {
      if (count == 1) {
        return '1 Reservierung wurde storniert.';
      }
      return '$count Reservierungen wurden storniert.';
    }
    if (AppTextsResolver.isFrench) {
      if (count == 1) {
        return '1 réservation a été annulée.';
      }
      return '$count réservations ont été annulées.';
    }
    if (AppTextsResolver.isHungarian) {
      return '$count foglalás törölve lett.';
    }
    if (AppTextsResolver.isPolish) {
      if (count == 1) {
        return 'Anulowano 1 rezerwację.';
      }
      if (count >= 2 && count <= 4) {
        return 'Anulowano $count rezerwacje.';
      }
      return 'Anulowano $count rezerwacji.';
    }
    if (AppTextsResolver.isCzech) {
      if (count == 1) {
        return 'Byla zrušena 1 rezervace.';
      }
      if (count >= 2 && count <= 4) {
        return 'Byly zrušeny $count rezervace.';
      }
      return 'Bylo zrušeno $count rezervací.';
    }
    if (count == 1) {
      return 'Bola zrušená 1 rezervácia.';
    }
    if (count >= 2 && count <= 4) {
      return 'Boli zrušené $count rezervácie.';
    }
    return 'Bolo zrušených $count rezervácií.';
  }

  static String trainingCount(int count) {
    if (AppTextsResolver.isUkrainian) {
      if (count == 1) {
        return '1 тренування';
      }
      if (count >= 2 && count <= 4) {
        return '$count тренування';
      }
      return '$count тренувань';
    }
    if (AppTextsResolver.isRussian) {
      if (count == 1) {
        return '1 тренировка';
      }
      if (count >= 2 && count <= 4) {
        return '$count тренировки';
      }
      return '$count тренировок';
    }
    if (AppTextsResolver.isSerbian) {
      if (count == 1) {
        return '1 trening';
      }
      return '$count treninga';
    }
    if (AppTextsResolver.isEnglish) {
      return count == 1 ? '1 training session' : '$count training sessions';
    }
    if (AppTextsResolver.isGerman) {
      if (count == 1) {
        return '1 Trainingseinheit';
      }
      return '$count Trainingseinheiten';
    }
    if (AppTextsResolver.isFrench) {
      if (count == 1) {
        return '1 entraînement';
      }
      return '$count entraînements';
    }
    if (AppTextsResolver.isHungarian) {
      return '$count edzés';
    }
    if (AppTextsResolver.isPolish) {
      if (count == 1) {
        return '1 trening';
      }
      if (count >= 2 && count <= 4) {
        return '$count treningi';
      }
      return '$count treningów';
    }
    if (AppTextsResolver.isCzech) {
      if (count == 1) {
        return '1 cvičení';
      }
      if (count >= 2 && count <= 4) {
        return '$count cvičení';
      }
      return '$count cvičení';
    }
    if (count == 1) {
      return '1 cvičenie';
    }
    if (count >= 2 && count <= 4) {
      return '$count cvičenia';
    }
    return '$count cvičení';
  }

  static String reservationCount(int count) {
    if (AppTextsResolver.isUkrainian) {
      if (count == 1) {
        return '1 бронювання';
      }
      if (count >= 2 && count <= 4) {
        return '$count бронювання';
      }
      return '$count бронювань';
    }
    if (AppTextsResolver.isRussian) {
      if (count == 1) {
        return '1 бронирование';
      }
      if (count >= 2 && count <= 4) {
        return '$count бронирования';
      }
      return '$count бронирований';
    }
    if (AppTextsResolver.isSerbian) {
      if (count == 1) {
        return '1 rezervacija';
      }
      return '$count rezervacija';
    }
    if (AppTextsResolver.isEnglish) {
      return count == 1 ? '1 reservation' : '$count reservations';
    }
    if (AppTextsResolver.isGerman) {
      if (count == 1) {
        return '1 Reservierung';
      }
      return '$count Reservierungen';
    }
    if (AppTextsResolver.isFrench) {
      if (count == 1) {
        return '1 réservation';
      }
      return '$count réservations';
    }
    if (AppTextsResolver.isHungarian) {
      return '$count foglalás';
    }
    if (AppTextsResolver.isPolish) {
      if (count == 1) {
        return '1 rezerwacja';
      }
      if (count >= 2 && count <= 4) {
        return '$count rezerwacje';
      }
      return '$count rezerwacji';
    }
    if (AppTextsResolver.isCzech) {
      if (count == 1) {
        return '1 rezervace';
      }
      if (count >= 2 && count <= 4) {
        return '$count rezervace';
      }
      return '$count rezervací';
    }
    if (count == 1) {
      return '1 rezervácia';
    }
    if (count >= 2 && count <= 4) {
      return '$count rezervácie';
    }
    return '$count rezervácií';
  }

  static String monthCount(int count) {
    if (AppTextsResolver.isEnglish) {
      return count == 1 ? '1 month' : '$count months';
    }
    if (AppTextsResolver.isGerman) {
      return count == 1 ? '1 Monat' : '$count Monate';
    }
    if (AppTextsResolver.isFrench) {
      return count == 1 ? '1 mois' : '$count mois';
    }
    if (AppTextsResolver.isHungarian) {
      return '$count hónap';
    }
    if (AppTextsResolver.isPolish) {
      if (count == 1) return '1 miesiąc';
      if (count >= 2 && count <= 4) return '$count miesiące';
      return '$count miesięcy';
    }
    if (AppTextsResolver.isUkrainian) {
      final mod10 = count % 10;
      final mod100 = count % 100;
      if (mod10 == 1 && mod100 != 11) return '$count місяць';
      if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
        return '$count місяці';
      }
      return '$count місяців';
    }
    if (AppTextsResolver.isRussian) {
      final mod10 = count % 10;
      final mod100 = count % 100;
      if (mod10 == 1 && mod100 != 11) return '$count месяц';
      if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
        return '$count месяца';
      }
      return '$count месяцев';
    }
    if (AppTextsResolver.isSerbian) {
      if (count == 1) return '1 mesec';
      if (count >= 2 && count <= 4) return '$count meseca';
      return '$count meseci';
    }
    if (AppTextsResolver.isCzech) {
      if (count == 1) return '1 měsíc';
      if (count >= 2 && count <= 4) return '$count měsíce';
      return '$count měsíců';
    }

    if (count == 1) return '1 mesiac';
    if (count >= 2 && count <= 4) return '$count mesiace';
    return '$count mesiacov';
  }

  static String dayCount(int count) {
    if (AppTextsResolver.isEnglish) {
      return count == 1 ? '1 day' : '$count days';
    }
    if (AppTextsResolver.isGerman) {
      return count == 1 ? '1 Tag' : '$count Tage';
    }
    if (AppTextsResolver.isFrench) {
      return count == 1 ? '1 jour' : '$count jours';
    }
    if (AppTextsResolver.isHungarian) {
      return '$count nap';
    }
    if (AppTextsResolver.isPolish) {
      return count == 1 ? '1 dzień' : '$count dni';
    }
    if (AppTextsResolver.isUkrainian) {
      final mod10 = count % 10;
      final mod100 = count % 100;
      if (mod10 == 1 && mod100 != 11) return '$count день';
      if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
        return '$count дні';
      }
      return '$count днів';
    }
    if (AppTextsResolver.isRussian) {
      final mod10 = count % 10;
      final mod100 = count % 100;
      if (mod10 == 1 && mod100 != 11) return '$count день';
      if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
        return '$count дня';
      }
      return '$count дней';
    }
    if (AppTextsResolver.isSerbian) {
      if (count == 1) return '1 dan';
      return '$count dana';
    }
    if (AppTextsResolver.isCzech) {
      if (count == 1) return '1 den';
      if (count >= 2 && count <= 4) return '$count dny';
      return '$count dní';
    }

    if (count == 1) return '1 deň';
    if (count >= 2 && count <= 4) return '$count dni';
    return '$count dní';
  }

  static String scheduleTimeLabel({
    required String weekday,
    required String time,
  }) {
    if (AppTextsResolver.isEnglish) {
      return '$weekday at $time';
    }
    if (AppTextsResolver.isGerman) {
      return '$weekday um $time';
    }
    if (AppTextsResolver.isFrench) {
      return '$weekday à $time';
    }
    if (AppTextsResolver.isHungarian) {
      return '$weekday, $time';
    }
    if (AppTextsResolver.isPolish) {
      return '$weekday o $time';
    }
    if (AppTextsResolver.isUkrainian) {
      return '$weekday о $time';
    }
    if (AppTextsResolver.isRussian) {
      return '$weekday в $time';
    }
    if (AppTextsResolver.isSerbian) {
      return '$weekday u $time';
    }
    if (AppTextsResolver.isCzech) {
      return '$weekday v $time';
    }

    return '$weekday o $time';
  }
}
