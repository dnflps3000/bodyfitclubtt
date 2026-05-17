class ScheduleSystemMessageLocalizer {
  const ScheduleSystemMessageLocalizer._();

  static const List<String> _messageLanguageCodes = [
    'sk',
    'en',
    'cs',
    'de',
    'fr',
    'pl',
    'hu',
    'uk',
    'ru',
    'sr',
  ];

  static String _localizedValue(
    Map<String, String> values,
    String languageCode,
    String fallback,
  ) {
    final selected = values[languageCode];

    if (selected != null && selected.trim().isNotEmpty) {
      return selected;
    }

    final slovak = values['sk'];

    if (slovak != null && slovak.trim().isNotEmpty) {
      return slovak;
    }

    final english = values['en'];

    if (english != null && english.trim().isNotEmpty) {
      return english;
    }

    return fallback;
  }

  static String _weekdayLabelForLanguage(int weekday, String languageCode) {
    final labels = <String, List<String>>{
      'sk': [
        'pondelok',
        'utorok',
        'streda',
        'štvrtok',
        'piatok',
        'sobota',
        'nedeľa',
      ],
      'en': [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
      'cs': [
        'pondělí',
        'úterý',
        'středa',
        'čtvrtek',
        'pátek',
        'sobota',
        'neděle',
      ],
      'de': [
        'Montag',
        'Dienstag',
        'Mittwoch',
        'Donnerstag',
        'Freitag',
        'Samstag',
        'Sonntag',
      ],
      'fr': [
        'lundi',
        'mardi',
        'mercredi',
        'jeudi',
        'vendredi',
        'samedi',
        'dimanche',
      ],
      'pl': [
        'poniedziałek',
        'wtorek',
        'środa',
        'czwartek',
        'piątek',
        'sobota',
        'niedziela',
      ],
      'hu': [
        'hétfő',
        'kedd',
        'szerda',
        'csütörtök',
        'péntek',
        'szombat',
        'vasárnap',
      ],
      'uk': [
        'понеділок',
        'вівторок',
        'середа',
        'четвер',
        'пʼятниця',
        'субота',
        'неділя',
      ],
      'ru': [
        'понедельник',
        'вторник',
        'среда',
        'четверг',
        'пятница',
        'суббота',
        'воскресенье',
      ],
      'sr': [
        'ponedeljak',
        'utorak',
        'sreda',
        'četvrtak',
        'petak',
        'subota',
        'nedelja',
      ],
    };

    final localizedLabels = labels[languageCode] ?? labels['sk']!;

    if (weekday < 1 || weekday > localizedLabels.length) {
      return '';
    }

    return localizedLabels[weekday - 1];
  }

  static String _scheduleTimeLabelForLanguage({
    required int weekday,
    required String time,
    required String languageCode,
  }) {
    final weekdayLabel = _weekdayLabelForLanguage(weekday, languageCode);

    switch (languageCode) {
      case 'en':
        return '$weekdayLabel at $time';
      case 'de':
        return '$weekdayLabel um $time';
      case 'fr':
        return '$weekdayLabel à $time';
      case 'hu':
        return '$weekdayLabel, $time';
      case 'uk':
        return '$weekdayLabel о $time';
      case 'ru':
        return '$weekdayLabel в $time';
      case 'sr':
        return '$weekdayLabel u $time';
      case 'cs':
        return '$weekdayLabel v $time';
      case 'pl':
      case 'sk':
      default:
        return '$weekdayLabel o $time';
    }
  }

  static Map<String, String> trainingSessionCreated({
    required Map<String, String> trainingNameLocalized,
    required String fallbackTrainingName,
    required String date,
    required String time,
  }) {
    return {
      for (final languageCode in _messageLanguageCodes)
        languageCode: switch (languageCode) {
          'en' =>
            'A new training session has been added to the schedule:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date at $time.',
          'cs' =>
            'Do rozvrhu byl přidán nový trénink:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date v $time.',
          'de' =>
            'Eine neue Trainingseinheit wurde zum Zeitplan hinzugefügt:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date um $time.',
          'fr' =>
            'Un nouvel entraînement a été ajouté au planning :\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date à $time.',
          'pl' =>
            'Do harmonogramu dodano nowy trening:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date o $time.',
          'hu' =>
            'Új edzés került az órarendbe:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date, $time.',
          'uk' =>
            'До розкладу додано нове тренування:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date о $time.',
          'ru' =>
            'В расписание добавлена новая тренировка:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date в $time.',
          'sr' =>
            'U raspored je dodat novi trening:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date u $time.',
          _ =>
            'Do rozvrhu bol pridaný nový tréning:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date o $time.',
        },
    };
  }

  static Map<String, String> trainingSessionCancelled({
    required Map<String, String> trainingNameLocalized,
    required String fallbackTrainingName,
    required String date,
    required String time,
  }) {
    return {
      for (final languageCode in _messageLanguageCodes)
        languageCode: switch (languageCode) {
          'en' =>
            'The training session has been cancelled:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date at $time.\n'
                'Active reservations have been cancelled and allocated entries have been released.',
          'cs' =>
            'Trénink byl zrušen:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date v $time.\n'
                'Aktivní rezervace byly zrušeny a alokované vstupy byly uvolněny.',
          'de' =>
            'Die Trainingseinheit wurde abgesagt:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date um $time.\n'
                'Aktive Reservierungen wurden storniert und reservierte Eintritte wurden freigegeben.',
          'fr' =>
            'L’entraînement a été annulé :\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date à $time.\n'
                'Les réservations actives ont été annulées et les entrées allouées ont été libérées.',
          'pl' =>
            'Trening został anulowany:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date o $time.\n'
                'Aktywne rezerwacje zostały anulowane, a przydzielone wejścia zwolnione.',
          'hu' =>
            'Az edzés törölve lett:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date, $time.\n'
                'Az aktív foglalások törölve lettek, a lefoglalt belépések pedig felszabadultak.',
          'uk' =>
            'Тренування було скасовано:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date о $time.\n'
                'Активні бронювання були скасовані, а зарезервовані входи звільнені.',
          'ru' =>
            'Тренировка была отменена:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date в $time.\n'
                'Активные бронирования отменены, зарезервированные входы освобождены.',
          'sr' =>
            'Trening je otkazan:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date u $time.\n'
                'Aktivne rezervacije su otkazane, a rezervisani ulasci oslobođeni.',
          _ =>
            'Tréning bol zrušený:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date o $time.\n'
                'Aktívne rezervácie boli zrušené a alokované vstupy boli uvoľnené.',
        },
    };
  }

  static Map<String, String> trainingSessionUpdated({
    required Map<String, String> trainingNameLocalized,
    required String fallbackTrainingName,
    required String date,
    required String time,
  }) {
    return {
      for (final languageCode in _messageLanguageCodes)
        languageCode: switch (languageCode) {
          'en' =>
            'The training session has been updated:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date at $time.',
          'cs' =>
            'Termín tréninku byl upraven:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date v $time.',
          'de' =>
            'Der Trainingstermin wurde aktualisiert:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date um $time.',
          'fr' =>
            'Le créneau d’entraînement a été modifié :\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date à $time.',
          'pl' =>
            'Termin treningu został zaktualizowany:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date o $time.',
          'hu' =>
            'Az edzésidőpont módosítva lett:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date, $time.',
          'uk' =>
            'Термін тренування було оновлено:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date о $time.',
          'ru' =>
            'Тренировка была обновлена:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date в $time.',
          'sr' =>
            'Termin treninga je izmenjen:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date u $time.',
          _ =>
            'Termín tréningu bol upravený:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – $date o $time.',
        },
    };
  }

  static Map<String, String> trainingSessionTimeChanged({
    required Map<String, String> trainingNameLocalized,
    required String fallbackTrainingName,
    required String oldDate,
    required String oldTime,
    required String newDate,
    required String newTime,
  }) {
    return {
      for (final languageCode in _messageLanguageCodes)
        languageCode: switch (languageCode) {
          'en' =>
            'The training session time has been changed:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} was moved from $oldDate at $oldTime to $newDate at $newTime.\n'
                'Original reservations have been cancelled and allocated entries have been released.',
          'cs' =>
            'Termín tréninku byl změněn:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} byl přesunut z $oldDate v $oldTime na $newDate v $newTime.\n'
                'Původní rezervace byly zrušeny a alokované vstupy byly uvolněny.',
          'de' =>
            'Der Trainingstermin wurde geändert:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} wurde von $oldDate um $oldTime auf $newDate um $newTime verschoben.\n'
                'Ursprüngliche Reservierungen wurden storniert und reservierte Eintritte wurden freigegeben.',
          'fr' =>
            'L’heure de l’entraînement a été modifiée :\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} a été déplacé de $oldDate à $oldTime au $newDate à $newTime.\n'
                'Les réservations initiales ont été annulées et les entrées allouées ont été libérées.',
          'pl' =>
            'Termin treningu został zmieniony:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} został przeniesiony z $oldDate o $oldTime na $newDate o $newTime.\n'
                'Pierwotne rezerwacje zostały anulowane, a przydzielone wejścia zwolnione.',
          'hu' =>
            'Az edzés időpontja módosult:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} átkerült erről: $oldDate $oldTime erre: $newDate $newTime.\n'
                'Az eredeti foglalások törölve lettek, a lefoglalt belépések pedig felszabadultak.',
          'uk' =>
            'Термін тренування було змінено:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} перенесено з $oldDate о $oldTime на $newDate о $newTime.\n'
                'Початкові бронювання були скасовані, а зарезервовані входи звільнені.',
          'ru' =>
            'Время тренировки было изменено:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} перенесена с $oldDate в $oldTime на $newDate в $newTime.\n'
                'Первоначальные бронирования отменены, зарезервированные входы освобождены.',
          'sr' =>
            'Termin treninga je promenjen:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} je premešten sa $oldDate u $oldTime na $newDate u $newTime.\n'
                'Prvobitne rezervacije su otkazane, a rezervisani ulasci oslobođeni.',
          _ =>
            'Termín tréningu bol zmenený:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} bol presunutý z $oldDate o $oldTime na $newDate o $newTime.\n'
                'Pôvodné rezervácie boli zrušené a alokované vstupy boli uvoľnené.',
        },
    };
  }

  static Map<String, String> templateCreated({
    required Map<String, String> trainingNameLocalized,
    required String fallbackTrainingName,
    required int weekday,
    required String time,
  }) {
    return {
      for (final languageCode in _messageLanguageCodes)
        languageCode: switch (languageCode) {
          'en' =>
            'The regular weekly schedule has been updated:\n'
                'A regular training session has been added:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'cs' =>
            'Pravidelný týdenní rozvrh byl upraven:\n'
                'Byl přidán pravidelný trénink:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'de' =>
            'Der regelmäßige Wochenplan wurde aktualisiert:\n'
                'Eine regelmäßige Trainingseinheit wurde hinzugefügt:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'fr' =>
            'Le planning hebdomadaire régulier a été modifié :\n'
                'Un entraînement régulier a été ajouté :\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'pl' =>
            'Regularny harmonogram tygodniowy został zaktualizowany:\n'
                'Dodano regularny trening:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'hu' =>
            'A rendszeres heti órarend módosítva lett:\n'
                'Új rendszeres edzés lett hozzáadva:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'uk' =>
            'Регулярний тижневий розклад було оновлено:\n'
                'Додано регулярне тренування:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'ru' =>
            'Регулярное недельное расписание было обновлено:\n'
                'Добавлена регулярная тренировка:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'sr' =>
            'Redovni nedeljni raspored je izmenjen:\n'
                'Dodat je redovni trening:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          _ =>
            'Pravidelný týždenný rozvrh bol upravený:\n'
                'Pribudol pravidelný tréning:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
        },
    };
  }

  static Map<String, String> templateUpdated({
    required Map<String, String> trainingNameLocalized,
    required String fallbackTrainingName,
    required int oldWeekday,
    required String oldTime,
    required int newWeekday,
    required String newTime,
  }) {
    return {
      for (final languageCode in _messageLanguageCodes)
        languageCode: switch (languageCode) {
          'en' =>
            'The regular weekly schedule has been updated:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} has been updated.\n'
                'Original schedule: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'New schedule: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          'cs' =>
            'Pravidelný týdenní rozvrh byl upraven:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} byl upraven.\n'
                'Původně: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Nový rozvrh: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          'de' =>
            'Der regelmäßige Wochenplan wurde aktualisiert:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} wurde bearbeitet.\n'
                'Ursprünglich: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Neuer Zeitplan: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          'fr' =>
            'Le planning hebdomadaire régulier a été modifié :\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} a été modifié.\n'
                'Planning initial : ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Nouveau planning : ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          'pl' =>
            'Regularny harmonogram tygodniowy został zaktualizowany:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} został zaktualizowany.\n'
                'Poprzednio: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Nowy harmonogram: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          'hu' =>
            'A rendszeres heti órarend módosítva lett:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} módosítva lett.\n'
                'Eredetileg: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Új órarend: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          'uk' =>
            'Регулярний тижневий розклад було оновлено:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} було змінено.\n'
                'Попередньо: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Новий розклад: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          'ru' =>
            'Регулярное недельное расписание было обновлено:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} была изменена.\n'
                'Ранее: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Новое расписание: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          'sr' =>
            'Redovni nedeljni raspored je izmenjen:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} je izmenjen.\n'
                'Prethodno: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Novi raspored: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
          _ =>
            'Pravidelný týždenný rozvrh bol upravený:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} bol upravený.\n'
                'Pôvodne: ${_scheduleTimeLabelForLanguage(weekday: oldWeekday, time: oldTime, languageCode: languageCode)}.\n'
                'Nový rozvrh: ${_scheduleTimeLabelForLanguage(weekday: newWeekday, time: newTime, languageCode: languageCode)}.',
        },
    };
  }

  static Map<String, String> templateDeactivated({
    required Map<String, String> trainingNameLocalized,
    required String fallbackTrainingName,
    required int weekday,
    required String time,
  }) {
    return {
      for (final languageCode in _messageLanguageCodes)
        languageCode: switch (languageCode) {
          'en' =>
            'The regular weekly schedule has been updated:\n'
                'A training session has been removed from the regular schedule:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'cs' =>
            'Pravidelný týdenní rozvrh byl upraven:\n'
                'Z pravidelného rozvrhu byl odstraněn trénink:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'de' =>
            'Der regelmäßige Wochenplan wurde aktualisiert:\n'
                'Eine Trainingseinheit wurde aus dem regelmäßigen Plan entfernt:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'fr' =>
            'Le planning hebdomadaire régulier a été modifié :\n'
                'Un entraînement a été supprimé du planning régulier :\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'pl' =>
            'Regularny harmonogram tygodniowy został zaktualizowany:\n'
                'Usunięto trening z regularnego harmonogramu:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'hu' =>
            'A rendszeres heti órarend módosítva lett:\n'
                'Egy edzés el lett távolítva a rendszeres órarendből:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'uk' =>
            'Регулярний тижневий розклад було оновлено:\n'
                'З регулярного розкладу видалено тренування:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'ru' =>
            'Регулярное недельное расписание было обновлено:\n'
                'Из регулярного расписания удалена тренировка:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          'sr' =>
            'Redovni nedeljni raspored je izmenjen:\n'
                'Iz redovnog rasporeda je uklonjen trening:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
          _ =>
            'Pravidelný týždenný rozvrh bol upravený:\n'
                'Z pravidelného rozvrhu bol odstránený tréning:\n'
                '${_localizedValue(trainingNameLocalized, languageCode, fallbackTrainingName)} – ${_scheduleTimeLabelForLanguage(weekday: weekday, time: time, languageCode: languageCode)}.',
        },
    };
  }
}
