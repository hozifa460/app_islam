import 'package:flutter/material.dart';
import 'localization_loader.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _strings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
        context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('it'),
    Locale('pt'),
    Locale('nl'),
    Locale('ru'),
    Locale('tr'),
    Locale('ur'),
    Locale('id'),
    Locale('ms'),
    Locale('hi'),
    Locale('ja'),
    Locale('zh'),
    Locale('uz'),
    Locale('sw'),
    Locale('ha'),
    Locale('am'),
    Locale('so'),
  ];


  // ═══ قائمة اللغات المدعومة مع الأعلام ═══
  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage(code: 'ar', nativeName: 'العربية', flag: '🇸🇦'),
    SupportedLanguage(code: 'en', nativeName: 'English', flag: '🇺🇸'),
    SupportedLanguage(code: 'fr', nativeName: 'Français', flag: '🇫🇷'),
    SupportedLanguage(code: 'de', nativeName: 'Deutsch', flag: '🇩🇪'),
    SupportedLanguage(code: 'es', nativeName: 'Español', flag: '🇪🇸'),
    SupportedLanguage(code: 'it', nativeName: 'Italiano', flag: '🇮🇹'),
    SupportedLanguage(code: 'pt', nativeName: 'Português', flag: '🇧🇷'),
    SupportedLanguage(code: 'nl', nativeName: 'Nederlands', flag: '🇳🇱'),
    SupportedLanguage(code: 'ru', nativeName: 'Русский', flag: '🇷🇺'),
    SupportedLanguage(code: 'tr', nativeName: 'Türkçe', flag: '🇹🇷'),
    SupportedLanguage(code: 'ur', nativeName: 'اردو', flag: '🇵🇰'),
    SupportedLanguage(code: 'id', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    SupportedLanguage(code: 'ms', nativeName: 'Bahasa Melayu', flag: '🇲🇾'),
    SupportedLanguage(code: 'hi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    SupportedLanguage(code: 'ja', nativeName: '日本語', flag: '🇯🇵'),
    SupportedLanguage(code: 'zh', nativeName: '中文', flag: '🇨🇳'),
    SupportedLanguage(code: 'uz', nativeName: 'Oʻzbekcha', flag: '🇺🇿'),
    SupportedLanguage(code: 'sw', nativeName: 'Kiswahili', flag: '🇹🇿'),
    SupportedLanguage(code: 'ha', nativeName: 'Hausa', flag: '🇳🇬'),
    SupportedLanguage(code: 'am', nativeName: 'አማርኛ', flag: '🇪🇹'),
    SupportedLanguage(code: 'so', nativeName: 'Soomaali', flag: '🇸🇴'),
  ];


Future<void> load() async {
    _strings =
    await LocalizationLoader.load(locale.languageCode);
  }

  String t(String key) {
    return _strings[key] ??
        key; // لو المفتاح غير موجود يعرضه بدل كراش
  }



  // أضف هذا داخل class AppLocalizations بعد دالة t(key)

  // ═══════════════════════════════════════════════════
  //  Auth Screen
  // ═══════════════════════════════════════════════════
  String get authQuote => t('authQuote');

  // ═══════════════════════════════════════════════════
  //  Verify Email Screen
  // ═══════════════════════════════════════════════════
  String get verifyEmail => t('verifyEmail');
  String get verifyEmailDesc => t('verifyEmailDesc');
  String get verificationSent => t('verificationSent');
  String get checkEmailStatus => t('checkEmailStatus');
  String get resendVerification => t('resendVerification');
  String get changeEmailOrMethod => t('changeEmailOrMethod');
  String get verifyQuote => t('verifyQuote');

  // دالة مع متغير
  String resendIn(int seconds) => t('resendIn').replaceAll('{seconds}', '$seconds');

  // ═══════════════════════════════════════════════════
  //  Social Login Section
  // ═══════════════════════════════════════════════════
  String get orLoginWith => t('orLoginWith');
  String get loginAsGuest => t('loginAsGuest');
  String get appleComingSoon => t('appleComingSoon');
  String get error => t('error');

  // ═══════════════════════════════════════════════════
  //  Signup Form
  // ═══════════════════════════════════════════════════
  String get fullName => t('fullName');
  String get enterYourName => t('enterYourName');
  String get nameRequired => t('nameRequired');
  String get email => t('email');
  String get emailHint => t('emailHint');
  String get emailRequired => t('emailRequired');
  String get emailInvalid => t('emailInvalid');
  String get password => t('password');
  String get passwordRequired => t('passwordRequired');
  String get passwordMinLength => t('passwordMinLength');
  String get confirmPassword => t('confirmPassword');
  String get confirmPasswordHint => t('confirmPasswordHint');
  String get confirmRequired => t('confirmRequired');
  String get passwordsNotMatch => t('passwordsNotMatch');
  String get createAccount => t('createAccount');

  // ═══════════════════════════════════════════════════
  //  Login Form (لو تحتاجها)
  // ═══════════════════════════════════════════════════
  String get login => t('login');
  String get forgotPassword => t('forgotPassword');
  String get rememberMe => t('rememberMe');

  // ═══════════════════════════════════════════════════
  //  Auth Header & Tabs
  // ═══════════════════════════════════════════════════
  String get welcomeBack => t('welcomeBack');
  String get createNewAccount => t('createNewAccount');
  String get loginTab => t('loginTab');
  String get signupTab => t('signupTab');

  // في class AppLocalizations

  // ═══ Home Screen ═══
  String get fajr => t('fajr');
  String get sunrise => t('sunrise');
  String get dhuhr => t('dhuhr');
  String get asr => t('asr');
  String get maghrib => t('maghrib');
  String get isha => t('isha');
  String get prayerTimes => t('prayerTimes');
  String get locating => t('locating');
  String get nextPrayerLabel => t('nextPrayerLabel');
  String get hoursAnd => t('hoursAnd');
  String get minuteShort => t('minuteShort');
  String get minuteWord => t('minuteWord');
  String get adhanRescheduled => t('adhanRescheduled');
  String get locationUpdated => t('locationUpdated');

  String get verseOfDay => t('verseOfDay');
  String get readWithReflection => t('readWithReflection');
  String get hadithOfDay => t('hadithOfDay');
  String get prophetSaid => t('prophetSaid');

  String get morningAzkarShort => t('morningAzkarShort');
  String get eveningAzkarShort => t('eveningAzkarShort');
  String get loadingAzkar => t('loadingAzkar');
  String get read => t('read');

  String get sunnahOfTime => t('sunnahOfTime');
  String get completedAllSunnah => t('completedAllSunnah');
  String get oneLeft => t('oneLeft');
  String remainingSunnah(int count) => '$count ${t('oneLeft')}';
  String get motiveOneSunnah => t('motiveOneSunnah');
  String get motiveAlmostDone => t('motiveAlmostDone');
  String get motiveKeepGoing => t('motiveKeepGoing');
  String get motiveGoodStart => t('motiveGoodStart');
  String get motiveStartNow => t('motiveStartNow');
  String get noSunnahNow => t('noSunnahNow');
  String get browseAllSunnah => t('browseAllSunnah');
  String get nextSunnahLabel => t('nextSunnahLabel'); // ← أضف هذا
  String get viewAllSunnah => t('viewAllSunnah');
  String get viewDetailsAndMore => t('viewDetailsAndMore');
  String get rakaatLabel => t('rakaatLabel');
  String get confirmed => t('confirmed');
  String get recommended => t('recommended');
  String get undoAction => t('undoAction');
  String get completeAction => t('completeAction');

  String get quickQuran => t('quickQuran');
  String get quickHadith => t('quickHadith');
  String get quickAzkar => t('quickAzkar');
  String get quickQibla => t('quickQibla');
  String get quickAsmaAllah => t('quickAsmaAllah');
  String get quickTasbih => t('quickTasbih');

  String get greatOfIslam => t('greatOfIslam');
  String get noData => t('noData');

  // ═══ Features List (dynamic) ═══
  List<Map<String, String>> get featuresList => [
    {'title': t('feature_quran_title'), 'subtitle': t('feature_quran_subtitle')},
    {'title': t('feature_prayer_title'), 'subtitle': t('feature_prayer_subtitle')},
    {'title': t('feature_azkar_title'), 'subtitle': t('feature_azkar_subtitle')},
    {'title': t('feature_tasbih_title'), 'subtitle': t('feature_tasbih_subtitle')},
    {'title': t('feature_hadith_title'), 'subtitle': t('feature_hadith_subtitle')},
    {'title': t('feature_hasanat_title'), 'subtitle': t('feature_hasanat_subtitle')},
    {'title': t('feature_khatma_title'), 'subtitle': t('feature_khatma_subtitle')},
    {'title': t('feature_channels_title'), 'subtitle': t('feature_channels_subtitle')},
    {'title': t('feature_qibla_title'), 'subtitle': t('feature_qibla_subtitle')},
    {'title': t('feature_dua_title'), 'subtitle': t('feature_dua_subtitle')},
    {'title': t('feature_books_title'), 'subtitle': t('feature_books_subtitle')},
    {'title': t('feature_muezzin_title'), 'subtitle': t('feature_muezzin_subtitle')},
    {'title': t('feature_asma_title'), 'subtitle': t('feature_asma_subtitle')},
    {'title': t('feature_miracles_title'), 'subtitle': t('feature_miracles_subtitle')},
    {'title': t('feature_great_title'), 'subtitle': t('feature_great_subtitle')},
    {'title': t('feature_settings_title'), 'subtitle': t('feature_settings_subtitle')},
  ];

  // في class AppLocalizations

  // ═══ Settings Screen ═══
  String get appearance => t('appearance');
  String get language => t('language');
  String get appColor => t('appColor');
  String get appColorDesc => t('appColorDesc');
  String get theApp => t('theApp');
  String get contactSupport => t('contactSupport');
  String get darkMode => t('darkMode');
  String get lightMode => t('lightMode');
  String get selectLanguage => t('selectLanguage');

  // ═══ Footer & Developer ═══
  String get verseRememberAllah => t('verseRememberAllah');
  String get allRightsReserved2026 => t('allRightsReserved2026');
  String get developerLabel => t('developerLabel');
  String get worshipCompanion => t('worshipCompanion');

  String get developer => t('developer');
  String get developerName => t('developerName');
  String versionWithNumber(String version) => t('versionWithNumber').replaceAll('{version}', version);
  String lastUpdateYear(String year) => t('lastUpdateYear').replaceAll('{year}', year);

  // ═══ Color Preview ═══
  String get currentColorLabel => t('currentColorLabel');
  String get previewButtons => t('previewButtons');
  String get previewCards => t('previewCards');
  String get previewIcons => t('previewIcons');
  String get previewBar => t('previewBar');

  // ═══ App Actions ═══
  String get rateAppTitle => t('rateAppTitle');
  String get rateAppSub => t('rateAppSub');
  String get shareAppTitle => t('shareAppTitle');
  String get shareAppSub => t('shareAppSub');
  String get reportBugTitle => t('reportBugTitle');
  String get reportBugSub => t('reportBugSub');

  // ═══ Settings Title ═══
  String get settingsTitle => t('settingsTitle');
  String get settingsSubtitle => t('settingsSubtitle');

  // ═══ Theme Settings ═══
  String get darkModeLabel => t('darkModeLabel');
  String get lightModeLabel => t('lightModeLabel');
  String get darkModeDesc => t('darkModeDesc');
  String get lightModeDesc => t('lightModeDesc');
  String get previewCurrentMode => t('previewCurrentMode');
  String get darkLabel => t('darkLabel');
  String get lightLabel => t('lightLabel');

  // ═══ Color Names (dynamic list) ═══
  List<String> get colorNames => [
    t('color_teal'),
    t('color_blue'),
    t('color_indigo'),
    t('color_purple'),
    t('color_pink'),
    t('color_red'),
    t('color_orange'),
    t('color_amber'),
    t('color_green'),
    t('color_lightGreen'),
    t('color_lime'),
    t('color_brown'),
    t('color_blueGrey'),
    t('color_cyan'),
  ];

  // ═══ Main Shell (NavBar) ═══
  String get navHome => t('navHome');
  String get navKhatma => t('navKhatma');
  String get navPrayer => t('navPrayer');
  String get navLibrary => t('navLibrary');
  String get navMore => t('navMore');

  String get more => t('more');
  String get moreQuran => t('moreQuran');
  String get moreAzkar => t('moreAzkar');
  String get moreHasanat => t('moreHasanat');
  String get moreSalawat => t('moreSalawat');
  String get moreDua => t('moreDua');
  String get moreKhatma => t('moreKhatma');
  String get moreQibla => t('moreQibla');
  String get moreHadith => t('moreHadith');
  String get moreHijri => t('moreHijri');
  String get moreAsmaAllah => t('moreAsmaAllah');
  String get moreSettings => t('moreSettings');
  String get moreBooks => t('moreBooks');
  String get moreMiracles => t('moreMiracles');
  String get moreProphetSunnah => t('moreProphetSunnah');
  String get moreInheritance => t('moreInheritance');
  String get moreChannels => t('moreChannels');
  String get moreGreatMuslims => t('moreGreatMuslims');
  String get moreSunnahTracker => t('moreSunnahTracker');
  String get moreradio => t('moreradio');

  // ═══ Profile Screen ═══
  String get profile => t('profile');
  String get account => t('account');
  String get settings => t('settings');

  String get editName => t('editName');
  String get changePhoto => t('changePhoto');
  String get changePhotoSubtitle => t('changePhotoSubtitle');
  String get resetPassword => t('resetPassword');
  String get resetPasswordSubtitle => t('resetPasswordSubtitle');
  String get accountStatus => t('accountStatus');

  String get notifications => t('notifications');
  String get manageAlerts => t('manageAlerts');

  String get aboutApp => t('aboutApp');
  String versionNumber(String version) =>
      t('versionNumber').replaceAll('{version}', version);
  String get rateApp => t('rateApp');
  String get shareApp => t('shareApp');

  String get signOut => t('signOut');
  String get quoteVerse => t('quoteVerse');

  String get enterNewName => t('enterNewName');
  String get nameUpdated => t('nameUpdated');
  String get cancel => t('cancel');
  String get save => t('save');
  String get send => t('send');
  String get ok => t('ok');

  String resetPasswordEmailMsg(String email) =>
      t('resetPasswordEmailMsg').replaceAll('{email}', email);
  String get resetPasswordSent => t('resetPasswordSent');

  String get appTitle => t('appTitle');
  String get appDescription => t('appDescription');

  String get signOutConfirm => t('signOutConfirm');

  String get loggedWithGoogle => t('loggedWithGoogle');
  String get loggedWithApple => t('loggedWithApple');
  String get loggedWithEmail => t('loggedWithEmail');
  String get guest => t('guest');
  String get verified => t('verified');

  // ═══ Guest Banner Screen ═══
  String get guestProfileTitle => t('guestProfileTitle');
  String get guestProfileDesc => t('guestProfileDesc');
  String get guestLogin => t('guestLogin');
  String get guestQuote => t('guestQuote');
  String get guestFeature1 => t('guestFeature1');
  String get guestFeature2 => t('guestFeature2');
  String get guestFeature3 => t('guestFeature3');
  String get guestFeature4 => t('guestFeature4');

  // ═══ قائمة المميزات (للاستخدام الديناميكي) ═══
  List<String> get guestFeatures => [
    guestFeature1,
    guestFeature2,
    guestFeature3,
    guestFeature4,
  ];

  // ═══ Splash Screen ═══
  String get splashTitle => t('splashTitle');
  String get splashSubtitle => t('splashSubtitle');
  String get splashVerse => t('splashVerse');

  // ═══ Khatma Screen ═══
  String get khatmaSetupTitle => t('khatmaSetupTitle');
  String get khatmaSetupSubtitle => t('khatmaSetupSubtitle');
  String get khatmaQuickPlans => t('khatmaQuickPlans');
  String get khatmaCustomize => t('khatmaCustomize');
  String get kharmaPagesDaily => t('kharmaPagesDaily');
  String get khatmaPlanSummary => t('khatmaPlanSummary');
  String get khatmaDuration => t('khatmaDuration');
  String get khatmaDailyTime => t('khatmaDailyTime');
  String get khatmaTotalPages => t('khatmaTotalPages');
  String get khatmaStartNow => t('khatmaStartNow');

  // Presets
  String get khatmaPreset1 => t('khatmaPreset1');
  String get khatmaPreset2 => t('khatmaPreset2');
  String get khatmaPreset3 => t('khatmaPreset3');
  String get khatmaPreset4 => t('khatmaPreset4');
  String khatmaPagesPerDay(int pages) => t('khatmaPagesPerDay').replaceAll('{pages}', '$pages');
  String khatmaDays(int days) => t('khatmaDays').replaceAll('{days}', '$days');
  String khatmaMinutes(int min) => t('khatmaMinutes').replaceAll('{min}', '$min');
  String get khatma604Pages => t('khatma604Pages');

  // Dashboard
  String get khatmaTodayWird => t('khatmaTodayWird');
  String get khatmaStart => t('khatmaStart');
  String get khatmaEnd => t('khatmaEnd');
  String get khatmaReadWird => t('khatmaReadWird');
  String get khatmaReadFromMushaf => t('khatmaReadFromMushaf');
  String get khatmaUndoLast => t('khatmaUndoLast');
  String get khatmaStats => t('khatmaStats');
  String get khatmaCurrentPage => t('khatmaCurrentPage');
  String get khatmaCurrentJuz => t('khatmaCurrentJuz');
  String get khatmaCurrentSurah => t('khatmaCurrentSurah');
  String get khatmaDaysRemaining => t('khatmaDaysRemaining');
  String get khatmaCompleted => t('khatmaCompleted');
  String get khatmaRemaining => t('khatmaRemaining');
  String get khatmaDaysLeft => t('khatmaDaysLeft');
  String get khatmaPage => t('khatmaPage');
  String get khatmaPagesRemaining => t('khatmaPagesRemaining');
  String khatmaJuzOf30(int current) => t('khatmaJuzOf30').replaceAll('{current}', '$current');
  String khatmaPageOf604(int current) => t('khatmaPageOf604').replaceAll('{current}', '$current');

  // Actions
  String get khatmaDailyReminder => t('khatmaDailyReminder');
  String get khatmaResetKhatma => t('khatmaResetKhatma');
  String get khatmaSelectTime => t('khatmaSelectTime');
  String khatmaReminderSet(String time) => t('khatmaReminderSet').replaceAll('{time}', time);
  String get khatmaReminderTitle => t('khatmaReminderTitle');
  String get khatmaReminderBody => t('khatmaReminderBody');

  // Dialogs
  String get khatmaCongratsTitle => t('khatmaCongratsTitle');
  String get khatmaCongratsMsg => t('khatmaCongratsMsg');
  String get khatmaStartNew => t('khatmaStartNew');
  String get khatmaLater => t('khatmaLater');
  String get khatmaConfirmReset => t('khatmaConfirmReset');
  String get khatmaResetWarning => t('khatmaResetWarning');
  String get khatmaCancel => t('khatmaCancel');
  String get khatmaReset => t('khatmaReset');

  // Snackbars
  String get khatmaWirdDone => t('khatmaWirdDone');
  String get khatmaKeepGoing => t('khatmaKeepGoing');
  String get khatmaUndone => t('khatmaUndone');

  // Save
  String get khatmaSave => t('khatmaSave');
  String get khatmaConfirm => t('khatmaConfirm');

  // ═══ قائمة الخطط السريعة (dynamic) ═══
  List<Map<String, String>> get khatmaPresets => [
    {'days': '30', 'pages': '20', 'label': khatmaPreset1},
    {'days': '15', 'pages': '40', 'label': khatmaPreset2},
    {'days': '10', 'pages': '60', 'label': khatmaPreset3},
    {'days': '7', 'pages': '86', 'label': khatmaPreset4},
  ];

  // ═══════════════════════════════════════════════════
  //  Prayer Times Screen (شاشة مواقيت الصلاة والإعدادات)
  // ═══════════════════════════════════════════════════

  // أسماء الصلوات
  String get prayerFajr => t('prayerFajr');
  String get prayerSunrise => t('prayerSunrise');
  String get prayerDhuhr => t('prayerDhuhr');
  String get prayerAsr => t('prayerAsr');
  String get prayerMaghrib => t('prayerMaghrib');
  String get prayerIsha => t('prayerIsha');

  // إعدادات الصلاة
  String get autoPrayerSettings => t('autoPrayerSettings');
  String get controlAdhanReminderIqama => t('controlAdhanReminderIqama');
  String get autoAdhan => t('autoAdhan');
  String get playAdhanEveryPrayer => t('playAdhanEveryPrayer');
  String get statusEnabled => t('statusEnabled');
  String get statusDisabled => t('statusDisabled');
  String get autoPreReminder => t('autoPreReminder');
  String get alert10MinBefore => t('alert10MinBefore');
  String get autoIqama => t('autoIqama');
  String get playIqama10MinAfter => t('playIqama10MinAfter');

  // طرق الحساب
  String get calculationMethod => t('calculationMethod');
  String get calcUmmAlQura => t('calcUmmAlQura');
  String get calcEgyptian => t('calcEgyptian');
  String get calcMwl => t('calcMwl');

  // الفحص والملاحظات
  String get checkPhoneReadiness => t('checkPhoneReadiness');
  String get discoverWhyAdhanNotWorking => t('discoverWhyAdhanNotWorking');
  String get customizeEachPrayerNote => t('customizeEachPrayerNote');

  // دوال بمتغيرات (لتمرير اسم الصلاة)
  String customizeMuezzinFor(String prayerName) => t('customizeMuezzinFor').replaceAll('{prayerName}', prayerName);
  String customizationSavedFor(String prayerName) => t('customizationSavedFor').replaceAll('{prayerName}', prayerName);

  // حوار الصلاحيات
  String get missingPermissions => t('missingPermissions');
  String get enableFollowingSettings => t('enableFollowingSettings');
  String get batteryOptimizationExclusion => t('batteryOptimizationExclusion');
  String get alarmsAndReminders => t('alarmsAndReminders');
  String get allowNotifications => t('allowNotifications');
  String get xiaomiOppoNote => t('xiaomiOppoNote');
  String get dialogCancel => t('dialogCancel');
  String get goToSettings => t('goToSettings');

  // رسائل التنبيهات (السناك بار)
  String get prayerTimesUpdatedAuto => t('prayerTimesUpdatedAuto');
  String get muezzinSoundsNotDownloaded => t('muezzinSoundsNotDownloaded');
  String get adhanEnabledSuccessfully => t('adhanEnabledSuccessfully');
  String get conditionsNotMetForAdhan => t('conditionsNotMetForAdhan');
  String get preReminderEnabled => t('preReminderEnabled');
  String get preReminderDisabledAll => t('preReminderDisabledAll');
  String get iqamaEnabled => t('iqamaEnabled');
  String get iqamaDisabledAll => t('iqamaDisabledAll');
  String get prayerTimesUpdated => t('prayerTimesUpdated');
  String get sunriseNoAdhan => t('sunriseNoAdhan');
  String get adhanScheduledSuccessfully => t('adhanScheduledSuccessfully');
  String get autoAdhanDisabled => t('autoAdhanDisabled');

  // ═══ Prayer Components ═══
  String get prayerScheduleTable => t('prayerScheduleTable');
  String upNextPrayer(String prayerName) => t('upNextPrayer').replaceAll('{prayerName}', prayerName);
  String get prayerNow => t('prayerNow');
  String get prayerNext => t('prayerNext');
  String get thisPrayerHasNoAdhan => t('thisPrayerHasNoAdhan');
  String get tapToCustomizePrayer => t('tapToCustomizePrayer');
  String get noAdhan => t('noAdhan');
  String get cannotCustomizeSunrise => t('cannotCustomizeSunrise');
  String currentMuezzinLabel(String name) => t('currentMuezzinLabel').replaceAll('{name}', name);
  String get customize => t('customize');
  String get adhanLabel => t('adhanLabel');
  String reminderWithMins(int mins) => t('reminderWithMins').replaceAll('{mins}', '$mins');
  String get reminderLabel => t('reminderLabel');
  String iqamaWithMins(int mins) => t('iqamaWithMins').replaceAll('{mins}', '$mins');
  String get iqamaLabel => t('iqamaLabel');
  String get defaultMuezzinBadge => t('defaultMuezzinBadge');
  String get customMuezzinBadge => t('customMuezzinBadge');

  // ═══ Diagnostic Dialog ═══
  String get adhanDiagnosticTitle => t('adhanDiagnosticTitle');
  String get notificationPermission => t('notificationPermission');
  String get exactAlarmPermission => t('exactAlarmPermission');
  String get batteryExclusion => t('batteryExclusion');
  String get xiaomiDiagnosticNote => t('xiaomiDiagnosticNote');
  String get closeDialog => t('closeDialog');
  String get fixPermission => t('fixPermission');

  // ═══ Customize Sheet ═══
  String customizePrayerTitle(String prayerName) => t('customizePrayerTitle').replaceAll('{prayerName}', prayerName);
  String get currentMuezzinSettingsTitle => t('currentMuezzinSettingsTitle');
  String get changeMuezzin => t('changeMuezzin');
  String get adhanSettingsTitle => t('adhanSettingsTitle');
  String get enableAdhanForThisPrayer => t('enableAdhanForThisPrayer');
  String get reminderMinutesAmount => t('reminderMinutesAmount');
  String get disablePreReminder => t('disablePreReminder');
  String xMinutes(int x) => t('xMinutes').replaceAll('{x}', '$x');
  String get preReminderSound => t('preReminderSound');
  String get soundHayyaAlasalah => t('soundHayyaAlasalah');
  String get soundPrayFajr => t('soundPrayFajr');
  String get iqamaTimeAfterAdhan => t('iqamaTimeAfterAdhan');
  String get disableIqama => t('disableIqama');
  String xMinutesAfterAdhan(int x) => t('xMinutesAfterAdhan').replaceAll('{x}', '$x');
  String get iqamaSound => t('iqamaSound');
  String get resetToDefault => t('resetToDefault');
  String get saveCustomization => t('saveCustomization');
  String get useDefaultMuezzin => t('useDefaultMuezzin');
  String get cancelCustomization => t('cancelCustomization');
  String get chooseDifferentMuezzin => t('chooseDifferentMuezzin');

  // ═══ AppBar & Next Card ═══
  String get updateLocationTooltip => t('updateLocationTooltip');
  String get theNextPrayerCardTitle => t('theNextPrayerCardTitle');
  String muezzinLabel(String name) => t('muezzinLabel').replaceAll('{name}', name);
  String get remainingLabel => t('remainingLabel');
  String get listenToAdhan => t('listenToAdhan');

  // ═══ Muezzin Selection Screen ═══
  String get chooseMuezzinTitle => t('chooseMuezzinTitle');
  String get chooseCategorySubtitle => t('chooseCategorySubtitle');
  String get sheikhsBadge => t('sheikhsBadge');

  // ═══ Muezzin List & Downloads ═══
  String downloadSuccess(String name) => t('downloadSuccess').replaceAll('{name}', name);
  String downloadFailed(String name) => t('downloadFailed').replaceAll('{name}', name);
  String deleteSuccess(String name) => t('deleteSuccess').replaceAll('{name}', name);
  String get previewFailed => t('previewFailed');
  String setAsDefaultSuccess(String name) => t('setAsDefaultSuccess').replaceAll('{name}', name);
  String get selectButton => t('selectButton');
  String get previewTooltip => t('previewTooltip');
  String get readyStatus => t('readyStatus');
  String get offlineStatus => t('offlineStatus');
  String get downloadTooltip => t('downloadTooltip');

  // ═══ Iqama Sounds ═══
  String get iqamaName1 => t('iqamaName1');
  String get iqamaDesc1 => t('iqamaDesc1');
  String get iqamaName2 => t('iqamaName2');
  String get iqamaDesc2 => t('iqamaDesc2');
  String get iqamaName3 => t('iqamaName3');
  String get iqamaDesc3 => t('iqamaDesc3');

  // ═══ Muezzin Catalogs ═══
  String get catHaramainName => t('catHaramainName');
  String get catHaramainDesc => t('catHaramainDesc');
  String get makkahDefault => t('makkahDefault');
  String get makkahAdhan => t('makkahAdhan');
  String get madinahAdhan => t('madinahAdhan');
  String get madinahAdhanDesc => t('madinahAdhanDesc');
  String get sheikhHamad => t('sheikhHamad');
  String get makkahHaramAdhan => t('makkahHaramAdhan');
  String get sheikhAbdulmajeed => t('sheikhAbdulmajeed');

  String get catEgyptName => t('catEgyptName');
  String get catEgyptDesc => t('catEgyptDesc');
  String get sheikhMenshawy => t('sheikhMenshawy');
  String get sheikhAbdalbaset => t('sheikhAbdalbaset');
  String get sheikhRifaat => t('sheikhRifaat');
  String get sheikhMustafaIsmail => t('sheikhMustafaIsmail');
  String get sheikhAlhosary => t('sheikhAlhosary');
  String get sheikhNeana => t('sheikhNeana');

  String get catSheikhsName => t('catSheikhsName');
  String get catSheikhsDesc => t('catSheikhsDesc');

  // ═══ Sheikhs Data ═══
  String get sheikhAlafasy => t('sheikhAlafasy');
  String get sheikhNasser => t('sheikhNasser');

  // ═══ Adhan Player ═══
  String get playAudioFailed => t('playAudioFailed');
  String adhanOfPrayer(String prayerName) => t('adhanOfPrayer').replaceAll('{prayerName}', prayerName);
  String get stopAudio => t('stopAudio');

  // ═══ Radio Player ═══
  String get quranRadioTitle => t('quranRadioTitle');
  String get radioLiveBroadcasting => t('radioLiveBroadcasting');
  String get radioTapToListen => t('radioTapToListen');

  // ═══ Salawat Reminder ═══
  String get previewSalawatFailed => t('previewSalawatFailed');
  String get downloadSalawatFailed => t('downloadSalawatFailed');
  String salawatReminderActivated(int mins) => t('salawatReminderActivated').replaceAll('{mins}', '$mins');
  String get salawatReminderDeactivated => t('salawatReminderDeactivated');
  String salawatIntervalUpdated(int mins) => t('salawatIntervalUpdated').replaceAll('{mins}', '$mins');
  String get downloadNewSoundFailed => t('downloadNewSoundFailed');
  String get salawatSoundChangedSuccess => t('salawatSoundChangedSuccess');

  String get enableSalawatReminder => t('enableSalawatReminder');
  String get salawatReminderActiveLabel => t('salawatReminderActiveLabel');
  String get tapToEnable => t('tapToEnable');

  String get reminderIsActive => t('reminderIsActive');
  String get reminderIsInactive => t('reminderIsInactive');
  String willBeRemindedEveryX(int mins) => t('willBeRemindedEveryX').replaceAll('{mins}', '$mins');
  String get enableToGetReminded => t('enableToGetReminded');

  String get repeatInterval => t('repeatInterval');
  String get every10Mins => t('every10Mins');
  String get every15Mins => t('every15Mins');
  String get every30Mins => t('every30Mins');
  String get every1Hour => t('every1Hour');

  String get reminderSound => t('reminderSound');
  String get soundSalyOnProphet => t('soundSalyOnProphet');
  String get shortAudioReminder => t('shortAudioReminder');
  String get soundOhAllahBless => t('soundOhAllahBless');
  String get specialAudioReminder => t('specialAudioReminder');

  String get prayingOnProphetTitle => t('prayingOnProphetTitle');
  String get ohAllahBlessProphet => t('ohAllahBlessProphet');

  String get salawatHadithText => t('salawatHadithText');
  String get narratedByMuslim => t('narratedByMuslim');

  String get downloadingAudio => t('downloadingAudio');

  // ═══ Asma Allah Circle ═══
  String get asmaAllahTitle => t('asmaAllahTitle');
  String get ninetyNineNames => t('ninetyNineNames');
  String get showAllNames => t('showAllNames');
  String get tapToSeeMeaning => t('tapToSeeMeaning');
  String get pinchToZoom => t('pinchToZoom');
  String get allahWord => t('allahWord');

  // ═══ Asma Allah All Names ═══
  String get searchNameOrMeaningHint => t('searchNameOrMeaningHint');
  String resultsCount(int count) => t('resultsCount').replaceAll('{count}', '$count');
  String namesCount(int count) => t('namesCount').replaceAll('{count}', '$count');
  String get clearFilter => t('clearFilter');
  String get loadingNames => t('loadingNames');
  String get noMatchingResults => t('noMatchingResults');
  String get tryAnotherSearch => t('tryAnotherSearch');

  // ═══ Asma Allah Detail ═══
  String shareAsmaFormat(String name, String meaning) =>
      t('shareAsmaFormat').replaceAll('{name}', name).replaceAll('{meaning}', meaning);
  String get defaultReflection => t('defaultReflection');
  String nameOfTotalNames(int order) => t('nameOfTotalNames').replaceAll('{order}', '$order');
  String get meaningTitle => t('meaningTitle');
  String get reflectOnName => t('reflectOnName');
  String get reflectionAndDua => t('reflectionAndDua');

  // ═══ Navigation ═══
  String get btnPrevious => t('btnPrevious');
  String get btnNext => t('btnNext');

  // ═══ Azkar Header ═══
  String get azkarTitle => t('azkarTitle');
  String get azkarQuranVerse => t('azkarQuranVerse');
  String azkarCategoriesCount(int count) => t('azkarCategoriesCount').replaceAll('{count}', '$count');

  // ═══ Hasanat Screen ═══
  String get hasanatHarvestTitle => t('hasanatHarvestTitle');
  String get resetTooltip => t('resetTooltip');
  String get deedsAndRewards => t('deedsAndRewards');
  String azkarCount(int count) => t('azkarCount').replaceAll('{count}', '$count');

  // ═══ Hasanat Card ═══
  String get progressLabel => t('progressLabel');
  String get addButton => t('addButton');

  // ═══ Hasanat Dialogs ═══
  String get resetCountersTitle => t('resetCountersTitle');
  String get resetCountersMsg => t('resetCountersMsg');
  String get resetBtn => t('resetBtn');

  // ═══ Hasanat Stats ═══
  String get statPalmTrees => t('statPalmTrees');
  String get statPalaces => t('statPalaces');
  String get statTreasures => t('statTreasures');
  String get statLights => t('statLights');
  String get statDoors => t('statDoors');
  String get statShields => t('statShields');
  String get statScales => t('statScales');
  String get statHasanat => t('statHasanat');

  // ═══ Hijri Calendar ═══
  String get didYouKnow => t('didYouKnow');
  String get backToToday => t('backToToday');
  String get todaysEvent => t('todaysEvent');
  String get dayLabel => t('dayLabel');
  String get monthLabel => t('monthLabel');
  String get yearLabel => t('yearLabel');
  String shareFactTitle(String fact) => t('shareFactTitle').replaceAll('{fact}', fact);
  String shareEventFormat(String title, String desc, String date) =>
      t('shareEventFormat').replaceAll('{title}', title).replaceAll('{desc}', desc).replaceAll('{date}', date);

  // ═══ Full Week Days ═══
  String get dayMonday => t('dayMonday');
  String get dayTuesday => t('dayTuesday');
  String get dayWednesday => t('dayWednesday');
  String get dayThursday => t('dayThursday');
  String get dayFriday => t('dayFriday');
  String get daySaturday => t('daySaturday');
  String get daySunday => t('daySunday');

  // ═══════════════════════════════════════════════════
  //  Inheritance Calculator Screen (شاشة حاسبة المواريث)
  // ═══════════════════════════════════════════════════

  // ═══ Header ═══
  String get inheritanceCalculatorTitle => t('inheritanceCalculatorTitle');
  String get islamicInheritanceCalc => t('islamicInheritanceCalc');
  String get bismillahFull => t('bismillahFull');
  String get inheritanceVerse => t('inheritanceVerse');
  String get inheritanceVerseRef => t('inheritanceVerseRef');
  String get distributionAccordingSharia => t('distributionAccordingSharia');

  // ═══ Deceased Gender ═══
  String get deceasedGender => t('deceasedGender');
  String get selectDeceasedGender => t('selectDeceasedGender');
  String get male => t('male');
  String get female => t('female');

  // ═══ Estate Type ═══
  String get estateType => t('estateType');
  String get selectEstateType => t('selectEstateType');
  String get moneyEstate => t('moneyEstate');
  String get landEstate => t('landEstate');
  String get landEstateShort => t('landEstateShort');
  String get bothEstates => t('bothEstates');
  String get bothEstatesShort => t('bothEstatesShort');

  // ═══ Estate Input ═══
  String get cashMoney => t('cashMoney');
  String get afterDebtsAndWills => t('afterDebtsAndWills');
  String get enterTotalAmount => t('enterTotalAmount');
  String get landArea => t('landArea');
  String get landUnitsInfo => t('landUnitsInfo');
  String get feddan => t('feddan');
  String get qirat => t('qirat');
  String get sahm => t('sahm');
  String get feddanHint => t('feddanHint');
  String get qiratHint => t('qiratHint');
  String get sahmHint => t('sahmHint');
  String get liveConversion => t('liveConversion');
  String get inQirats => t('inQirats');
  String get inSahms => t('inSahms');
  String get inMeters => t('inMeters');
  String get inFeddan => t('inFeddan');

  // ═══ Heirs Selection ═══
  String get selectHeirs => t('selectHeirs');
  String get clickToSelectHeirs => t('clickToSelectHeirs');
  String get heirsCategories => t('heirsCategories');
  String get spouseCategory => t('spouseCategory');
  String get parentsCategory => t('parentsCategory');
  String get childrenCategory => t('childrenCategory');
  String get siblingsCategory => t('siblingsCategory');
  String get otherRelativesCategory => t('otherRelativesCategory');

  // ═══ Heir Names ═══
  String get husband => t('husband');
  String get wife => t('wife');
  String get mother => t('mother');
  String get father => t('father');
  String get grandmother => t('grandmother');
  String get grandfather => t('grandfather');
  String get son => t('son');
  String get daughter => t('daughter');
  String get sonOfSon => t('sonOfSon');
  String get sonsDaughter => t('sonsDaughter');
  String get brother => t('brother');
  String get sister => t('sister');
  String get halfBrotherFather => t('halfBrotherFather');
  String get halfSisterFather => t('halfSisterFather');
  String get halfBrotherMother => t('halfBrotherMother');
  String get halfSisterMother => t('halfSisterMother');
  String get sonOfBrother => t('sonOfBrother');
  String get sonOfHalfBrotherFather => t('sonOfHalfBrotherFather');
  String get uncle => t('uncle');
  String get halfUncleFather => t('halfUncleFather');
  String get sonOfUncle => t('sonOfUncle');
  String get sonOfHalfUncleFather => t('sonOfHalfUncleFather');

  // ═══ Calculate Button ═══
  String get calculateInheritance => t('calculateInheritance');
  String get pleaseSelectHeirs => t('pleaseSelectHeirs');
  String get pleaseEnterMoneyAmount => t('pleaseEnterMoneyAmount');
  String get pleaseEnterEstateValue => t('pleaseEnterEstateValue');

  // ═══ Results - Case Type ═══
  String get caseType => t('caseType');
  String get normalCase => t('normalCase');
  String get awlCase => t('awlCase');
  String get raddCase => t('raddCase');
  String get baseDenominator => t('baseDenominator');

  // ═══ Results - Distribution ═══
  String get moneyDistribution => t('moneyDistribution');
  String get totalAmount => t('totalAmount');
  String get landDistribution => t('landDistribution');
  String get sharePerPerson => t('sharePerPerson');
  String get blockedHeirs => t('blockedHeirs');
  String get blocked => t('blocked');

  // ═══ Unit Conversion ═══
  String get unitConversionTitle => t('unitConversionTitle');
  String get unitConversionDesc => t('unitConversionDesc');
  String get feddanUnit => t('feddanUnit');
  String get feddanDef => t('feddanDef');
  String get qiratUnit => t('qiratUnit');
  String get qiratDef => t('qiratDef');
  String get sahmUnit => t('sahmUnit');
  String get sahmDef => t('sahmDef');
  String get meterUnit => t('meterUnit');
  String get meterDef => t('meterDef');
  String get conversionExamples => t('conversionExamples');
  String get example1Feddan => t('example1Feddan');
  String get example1Result => t('example1Result');
  String get exampleHalfFeddan => t('exampleHalfFeddan');
  String get exampleHalfResult => t('exampleHalfResult');
  String get exampleQuarterFeddan => t('exampleQuarterFeddan');
  String get exampleQuarterResult => t('exampleQuarterResult');

  // ═══ Sharia Warnings ═══
  String get shariaWarningsTitle => t('shariaWarningsTitle');
  String get shariaWarningsCount => t('shariaWarningsCount');
  String get warning1Title => t('warning1Title');
  String get warning1Content => t('warning1Content');
  String get warning2Title => t('warning2Title');
  String get warning2Content => t('warning2Content');
  String get warning3Title => t('warning3Title');
  String get warning3Content => t('warning3Content');
  String get warning4Title => t('warning4Title');
  String get warning4Content => t('warning4Content');
  String get warning5Title => t('warning5Title');
  String get warning5Content => t('warning5Content');
  String get warning6Title => t('warning6Title');
  String get warning6Content => t('warning6Content');
  String get warning7Title => t('warning7Title');
  String get warning7Content => t('warning7Content');
  String get warning8Title => t('warning8Title');
  String get warning8Content => t('warning8Content');
  String get warning9Title => t('warning9Title');
  String get warning9Content => t('warning9Content');
  String get warning10Title => t('warning10Title');
  String get warning10Content => t('warning10Content');

  String get inheritanceBlockersTitle => t('inheritanceBlockersTitle');
  String get blocker1 => t('blocker1');
  String get blocker1Desc => t('blocker1Desc');
  String get blocker2 => t('blocker2');
  String get blocker2Desc => t('blocker2Desc');
  String get blocker3 => t('blocker3');
  String get blocker3Desc => t('blocker3Desc');
  String get blockersPoem => t('blockersPoem');

  String get inheritanceConditionsTitle => t('inheritanceConditionsTitle');
  String get condition1 => t('condition1');
  String get condition1Desc => t('condition1Desc');
  String get condition2 => t('condition2');
  String get condition2Desc => t('condition2Desc');
  String get condition3 => t('condition3');
  String get condition3Desc => t('condition3Desc');
  String get condition4 => t('condition4');
  String get condition4Desc => t('condition4Desc');
  String get inheritanceCausesTitle => t('inheritanceCausesTitle');
  String get cause1 => t('cause1');
  String get cause2 => t('cause2');
  String get cause3 => t('cause3');

  // ═══ References ═══
  String get referencesTitle => t('referencesTitle');
  String get referencesSubtitle => t('referencesSubtitle');
  String get quranReferencesTitle => t('quranReferencesTitle');
  String get quranRef1 => t('quranRef1');
  String get quranRef2 => t('quranRef2');
  String get quranRef3 => t('quranRef3');
  String get quranRef4 => t('quranRef4');
  String get sunnahReferencesTitle => t('sunnahReferencesTitle');
  String get sunnahRef1 => t('sunnahRef1');
  String get sunnahRef2 => t('sunnahRef2');
  String get sunnahRef3 => t('sunnahRef3');
  String get sunnahRef4 => t('sunnahRef4');
  String get sunnahRef5 => t('sunnahRef5');
  String get fiqhReferencesTitle => t('fiqhReferencesTitle');
  String get fiqhRef1 => t('fiqhRef1');
  String get fiqhRef2 => t('fiqhRef2');
  String get fiqhRef3 => t('fiqhRef3');
  String get fiqhRef4 => t('fiqhRef4');
  String get fiqhRef5 => t('fiqhRef5');
  String get fiqhRef6 => t('fiqhRef6');

// في الإنجليزية
  String get willStartAt => t('willStartAt');
  String get minutesBefore => t('minutesBefore');
  String get currentMuezzin => t('currentMuezzin');


  // اختصار
  String call(String key) => t(key);

  // اتجاه النص
  TextDirection get textDirection {
    return locale.languageCode == 'ar' ||
        locale.languageCode == 'ur'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_) => false;
}

extension LocalizationExt on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this);
}

// ═══ Model للغة ═══
class SupportedLanguage {
  final String code;
  final String nativeName;
  final String flag;

  const SupportedLanguage({
    required this.code,
    required this.nativeName,
    required this.flag,
  });
}