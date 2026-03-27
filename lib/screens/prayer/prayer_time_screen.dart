import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../data/prayer/iqama_catalog.dart';
import '../../data/prayer/muezzin_catalog.dart';
import '../../services/adahn_audio_services.dart';
import '../../services/muazzin_store.dart';
import '../../services/adahn_notification.dart';
import '../../services/native_adhan_bridge.dart';
import '../../services/prayer_times_refresh_service.dart';
import '../../utils/radio_widget.dart';
import 'adhan_player_screen.dart';
import 'muzzin_settings.dart';
import 'package:provider/provider.dart';
import '../../controllers/prayer_times_controller.dart';

class PrayerTimesScreen extends StatefulWidget {
  final Color primaryColor;
  final Map<String, String>? prayerTimes;
  final String? cityName;
  final Future<void> Function()? onRefreshLocation;
  final Future<Map<String, String>?> Function(String methodKey)?
  onApplyCalculationMethod;
  final Future<void> Function(int offset)? onReminderOffsetChanged;

  const PrayerTimesScreen({
    super.key,
    required this.primaryColor,
    this.prayerTimes,
    this.cityName,
    this.onRefreshLocation,
    this.onApplyCalculationMethod,
    this.onReminderOffsetChanged,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);
  Map<String, String> _livePrayerTimes = {};
  late final Future<Map<String, String>?> Function(String methodKey)?
  onApplyCalculationMethod;
  final Map<String, PrayerCustomization> _prayerCustomizations = {};

  bool _autoReminderEnabled = false;
  bool _autoIqamaEnabled = false;
  bool _loading = true;
  bool _adhanEnabled = false;
  bool _isWaitingForSettingsReturn = false;
  String _currentCalculationMethod = 'umm_al_qura';
  final AudioPlayer _previewPlayer = AudioPlayer();

  MuezzinInfo? _defaultMuezzin;
  final Map<String, MuezzinInfo> _effective = {};

  late List<_PrayerRow> _rows;
  int _currentIndex = -1;
  int _nextIndex = -1;

  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _isWaitingForSettingsReturn) {
      _isWaitingForSettingsReturn = false;
      _verifyPermissionsAfterReturn();
    }
  }

  String _iqamaSoundUrl(String soundId) {
    final sound = iqamaCatalog.firstWhere(
      (s) => s.id == soundId,
      orElse: () => iqamaCatalog.first,
    );
    return sound.url;
  }

  Future<String?> _downloadIqamaSoundIfNeeded(String soundId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory('${dir.path}/iqama_sounds');

      if (!await soundsDir.exists()) {
        await soundsDir.create(recursive: true);
      }

      final filePath = '${soundsDir.path}/$soundId.mp3';
      final file = File(filePath);

      if (await file.exists()) {
        return file.path;
      }

      final url = _iqamaSoundUrl(soundId);
      debugPrint('Downloading iqama sound from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        debugPrint('Failed to download iqama: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Iqama download error: $e');
      return null;
    }
  }

  Future<String?> _getIqamaLocalPath(String prayerKey, String soundId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPathKey = 'prayer_${prayerKey}_iqama_local_path';
    final savedPath = prefs.getString(savedPathKey);

    if (savedPath != null && File(savedPath).existsSync()) {
      return savedPath;
    }

    final downloadedPath = await _downloadIqamaSoundIfNeeded(soundId);
    if (downloadedPath != null) {
      await prefs.setString(savedPathKey, downloadedPath);
      return downloadedPath;
    }

    return null;
  }

  Future<void> _previewIqamaSound(String soundId) async {
    try {
      final url = _iqamaSoundUrl(soundId);
      await _previewPlayer.stop();
      await _previewPlayer.setUrl(url);
      await _previewPlayer.play();
    } catch (e) {
      debugPrint('Preview iqama error: $e');
    }
  }

  String _reminderSoundUrl(String soundName) {
    return 'https://raw.githubusercontent.com/hozifa460/islamic-audios/main/tazkeer_salat/$soundName.mp3';
  }

  Future<String?> _downloadReminderSoundIfNeeded(String soundName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory('${dir.path}/prayer_reminder_sounds');

      if (!await soundsDir.exists()) {
        await soundsDir.create(recursive: true);
      }

      final filePath = '${soundsDir.path}/$soundName.mp3';
      final file = File(filePath);

      if (await file.exists()) {
        return file.path;
      }

      final url = _reminderSoundUrl(soundName);
      debugPrint('Downloading reminder sound from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        debugPrint('Failed to download reminder sound: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Reminder sound download error: $e');
      return null;
    }
  }

  Future<String?> _getReminderLocalPath(
    String prayerKey,
    String soundName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPathKey = 'prayer_${prayerKey}_reminder_local_path';
    final savedPath = prefs.getString(savedPathKey);

    if (savedPath != null && File(savedPath).existsSync()) {
      return savedPath;
    }

    final downloadedPath = await _downloadReminderSoundIfNeeded(soundName);

    if (downloadedPath != null) {
      await prefs.setString(savedPathKey, downloadedPath);
      return downloadedPath;
    }

    return null;
  }

  Future<void> _previewReminderSound(String soundName) async {
    try {
      final url = _reminderSoundUrl(soundName);
      debugPrint('Trying preview reminder sound url: $url');

      await _previewPlayer.stop();
      await _previewPlayer.setUrl(url);
      await _previewPlayer.play();
    } catch (e) {
      debugPrint('Preview sound error for $soundName: $e');
    }
  }

  Color _getPrayerCardAccentColor({
    required bool isDefaultMuezzin,
    required bool isDark,
  }) {
    if (!isDefaultMuezzin) {
      return _gold.withOpacity(isDark ? 0.16 : 0.9);
    }
    return Colors.transparent;
  }

  bool _isPrayerUsingDefaultMuezzin(String prayerKey) {
    final effective = _effectiveForKey(prayerKey);
    final defaultM = _defaultMuezzin ?? muezzinCatalog.first.items.first;
    return effective.id == defaultM.id;
  }

  Future<void> _loadCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCalculationMethod = prefs.getString('calc_method') ?? 'umm_al_qura';
  }

  Future<void> _bootstrap() async {
    await _loadCalculationMethod();
    await _loadDefaultAndEffective();
    await _loadPrayerCustomizations();

    final prayerController = context.read<PrayerTimesController>();

    _livePrayerTimes = Map<String, String>.from(
      prayerController.prayerTimes.isNotEmpty
          ? prayerController.prayerTimes
          : {
            'Fajr': '05:30',
            'Sunrise': '06:45',
            'Dhuhr': '12:15',
            'Asr': '15:45',
            'Maghrib': '18:20',
            'Isha': '19:45',
          },
    );

    _buildPrayerRows();
    await _loadAdhanEnabled();

    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _computeCurrentNext();
      });
    });

    setState(() => _loading = false);
  }

  Future<void> _fixReminderSoundPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    const validSounds = ['hayalaaslah', 'prayfajr'];

    for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      final saved = prefs.getString('prayer_${key}_reminder_sound');

      if (saved == null || !validSounds.contains(saved)) {
        await prefs.setString('prayer_${key}_reminder_sound', 'hayalaaslah');
        await prefs.remove('prayer_${key}_reminder_local_path');
      }
    }
  }

  PrayerCustomization _customizationFor(String key) {
    return _prayerCustomizations[key] ?? PrayerCustomization.defaults();
  }

  Future<void> _loadAdhanEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    _adhanEnabled = prefs.getBool('adhan_enabled') ?? false;
  }

  Future<void> _loadDefaultAndEffective() async {
    _defaultMuezzin = await MuezzinStore.getDefault();

    _effective.clear();
    for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      _effective[key] = await MuezzinStore.getEffectiveForPrayer(key);
    }
  }

  Future<bool> _ensureSelectedMuezzinsDownloaded() async {
    for (final row in _rows) {
      if (row.noAdhan == true) continue;

      final m = _effectiveForKey(row.key);

      if (m.isBuiltIn) continue;

      final local = await AdhanAudioService.instance.getLocalPath(m.id);

      if (local == null || local.isEmpty) {
        debugPrint(
          'Muezzin ${m.name} is not downloaded, fallback will be used.',
        );
      }
    }
    return true;
  }

  Future<void> _verifyPermissionsAfterReturn() async {
    final prefs = await SharedPreferences.getInstance();

    final hasNotification = await Permission.notification.isGranted;
    final hasExactAlarm = await Permission.scheduleExactAlarm.isGranted;

    final downloadedOk = await _ensureSelectedMuezzinsDownloaded();

    if (hasNotification && hasExactAlarm && downloadedOk) {
      if (mounted) setState(() => _adhanEnabled = true);
      await prefs.setBool('adhan_enabled', true);
      await _scheduleAllAdhans();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ تم تفعيل الأذان بنجاح',
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      if (mounted) setState(() => _adhanEnabled = false);
      await prefs.setBool('adhan_enabled', false);
      _showErrorSnackBar('لم تكتمل الشروط اللازمة لتفعيل الأذان');
    }
  }

  Future<void> _loadPrayerCustomizations() async {
    await _fixReminderSoundPrefs();

    final prefs = await SharedPreferences.getInstance();

    for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      final adhanEnabled = prefs.getBool('prayer_${key}_adhan_enabled') ?? true;
      final reminderEnabled =
          prefs.getBool('prayer_${key}_reminder_enabled') ?? true;
      final reminderOffset =
          prefs.getInt('prayer_${key}_reminder_offset') ?? 10;
      final reminderSound =
          prefs.getString('prayer_${key}_reminder_sound') ?? 'hayalaaslah';
      final iqamaEnabled =
          prefs.getBool('prayer_${key}_iqama_enabled') ?? false;
      final iqamaDelay = prefs.getInt('prayer_${key}_iqama_delay') ?? 10;
      final iqamaSound =
          prefs.getString('prayer_${key}_iqama_sound') ?? 'iqama1';

      _prayerCustomizations[key] = PrayerCustomization(
        adhanEnabled: adhanEnabled,
        reminderEnabled: reminderEnabled,
        reminderOffset: reminderOffset,
        reminderSound: reminderSound,
        iqamaEnabled: iqamaEnabled,
        iqamaDelay: iqamaDelay,
        iqamaSound: iqamaSound,
      );
    }
    // تحميل حالة التفعيل التلقائي
    _autoReminderEnabled = prefs.getBool('auto_reminder_enabled') ?? false;
    _autoIqamaEnabled = prefs.getBool('auto_iqama_enabled') ?? false;
  }

  Future<void> _toggleAutoReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() => _autoReminderEnabled = value);
    await prefs.setBool('auto_reminder_enabled', value);

    if (value) {
      // تحميل أول صوت تنبيه
      final downloadedPath = await _downloadReminderSoundIfNeeded('hayalaaslah');

      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final current = _customizationFor(key);

        // فقط إذا لم يكن المستخدم قد خصص هذه الصلاة مسبقاً
        if (!current.reminderEnabled) {
          final updated = current.copyWith(
            reminderEnabled: true,
            reminderOffset: 10,
            reminderSound: 'hayalaaslah',
          );

          await _savePrayerCustomization(key, updated);
        }
      }

      if (_adhanEnabled) {
        await _scheduleAllAdhans();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تفعيل التنبيه القبلي لجميع الصلوات',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final current = _customizationFor(key);
        final updated = current.copyWith(reminderEnabled: false);
        await _savePrayerCustomization(key, updated);
      }

      const ids = {
        'Fajr': 100,
        'Dhuhr': 101,
        'Asr': 102,
        'Maghrib': 103,
        'Isha': 104,
      };

      for (final id in ids.values) {
        await NativeAdhanBridge.cancelReminder(id + 1000);
      }

      if (_adhanEnabled) {
        await _scheduleAllAdhans();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إيقاف التنبيه القبلي لجميع الصلوات',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    setState(() {});
  }

  Future<void> _toggleAutoIqama(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() => _autoIqamaEnabled = value);
    await prefs.setBool('auto_iqama_enabled', value);

    if (value) {
      // تحميل أول صوت إقامة
      final downloadedPath = await _downloadIqamaSoundIfNeeded(iqamaCatalog.first.id);

      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final current = _customizationFor(key);

        if (!current.iqamaEnabled) {
          final updated = current.copyWith(
            iqamaEnabled: true,
            iqamaDelay: 10,
            iqamaSound: iqamaCatalog.first.id,
          );

          await _savePrayerCustomization(key, updated);
        }
      }

      if (_adhanEnabled) {
        await _scheduleAllAdhans();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تفعيل الإقامة لجميع الصلوات',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final current = _customizationFor(key);
        final updated = current.copyWith(iqamaEnabled: false);
        await _savePrayerCustomization(key, updated);
      }

      const ids = {
        'Fajr': 100,
        'Dhuhr': 101,
        'Asr': 102,
        'Maghrib': 103,
        'Isha': 104,
      };

      for (final id in ids.values) {
        await NativeAdhanBridge.cancelIqama(id + 2000);
      }

      if (_adhanEnabled) {
        await _scheduleAllAdhans();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إيقاف الإقامة لجميع الصلوات',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    setState(() {});
  }

  Future<void> _savePrayerCustomization(
    String key,
    PrayerCustomization config,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('prayer_${key}_adhan_enabled', config.adhanEnabled);
    await prefs.setBool(
      'prayer_${key}_reminder_enabled',
      config.reminderEnabled,
    );
    await prefs.setInt('prayer_${key}_reminder_offset', config.reminderOffset);
    await prefs.setString('prayer_${key}_reminder_sound', config.reminderSound);
    await prefs.setBool('prayer_${key}_iqama_enabled', config.iqamaEnabled);
    await prefs.setInt('prayer_${key}_iqama_delay', config.iqamaDelay);
    await prefs.setString('prayer_${key}_iqama_sound', config.iqamaSound);

    if (config.reminderEnabled) {
      final localPath = await _downloadReminderSoundIfNeeded(
        config.reminderSound,
      );
      if (localPath != null) {
        await prefs.setString('prayer_${key}_reminder_local_path', localPath);
      }
    }

    if (config.iqamaEnabled) {
      final localPath = await _downloadIqamaSoundIfNeeded(config.iqamaSound);
      if (localPath != null) {
        await prefs.setString('prayer_${key}_iqama_local_path', localPath);
      }
    }

    _prayerCustomizations[key] = config;
  }

  void _buildPrayerRows() {
    final times =
        _livePrayerTimes.isNotEmpty
            ? _livePrayerTimes
            : {
              'Fajr': '05:30',
              'Sunrise': '06:45',
              'Dhuhr': '12:15',
              'Asr': '15:45',
              'Maghrib': '18:20',
              'Isha': '19:45',
            };

    final now = DateTime.now();

    _rows = [
      _PrayerRow(
        key: 'Fajr',
        name: 'الفجر',
        time: times['Fajr'] ?? '05:30',
        icon: Icons.wb_twilight,
      ),
      _PrayerRow(
        key: 'Sunrise',
        name: 'الشروق',
        time: times['Sunrise'] ?? '06:45',
        icon: Icons.wb_sunny_outlined,
        noAdhan: true,
      ),
      _PrayerRow(
        key: 'Dhuhr',
        name: 'الظهر',
        time: times['Dhuhr'] ?? '12:15',
        icon: Icons.sunny,
      ),
      _PrayerRow(
        key: 'Asr',
        name: 'العصر',
        time: times['Asr'] ?? '15:45',
        icon: Icons.filter_drama,
      ),
      _PrayerRow(
        key: 'Maghrib',
        name: 'المغرب',
        time: times['Maghrib'] ?? '18:20',
        icon: Icons.nights_stay,
      ),
      _PrayerRow(
        key: 'Isha',
        name: 'العشاء',
        time: times['Isha'] ?? '19:45',
        icon: Icons.star_rounded,
      ),
    ];

    for (final r in _rows) {
      r.dateTime = _parseTimeToday(r.time, now);
    }

    _computeCurrentNext();
  }

  DateTime _parseTimeToday(String timeStr, DateTime now) {
    final clean = timeStr.split(' ').first;
    final parts = clean.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return DateTime(now.year, now.month, now.day, h, m);
  }

  void _computeCurrentNext() {
    final now = DateTime.now();

    _currentIndex = -1;
    _nextIndex = -1;

    for (final r in _rows) {
      r.isPast = now.isAfter(r.dateTime);
      r.isCurrent = false;
      r.isNext = false;
      r.isTomorrow = false;
    }

    for (int i = 0; i < _rows.length; i++) {
      final t = _rows[i].dateTime;
      if (now.isBefore(t) || now.isAtSameMomentAs(t)) {
        _nextIndex = i;
        _rows[i].isNext = true;
        if (i > 0) {
          _currentIndex = i - 1;
          _rows[i - 1].isCurrent = true;
        }
        return;
      }
    }

    if (_rows.isNotEmpty) {
      _currentIndex = _rows.length - 1;
      _rows[_currentIndex].isCurrent = true;

      _nextIndex = 0;
      _rows[0].isNext = true;
      _rows[0].isTomorrow = true;
    }
  }

  Duration _remainingToNext() {
    if (_nextIndex < 0) return Duration.zero;
    final now = DateTime.now();
    final nextRow = _rows[_nextIndex];
    var target = nextRow.dateTime;
    if (nextRow.isTomorrow == true || now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }
    final d = target.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  String _fmtRemain(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _runAdhanDiagnostic() async {
    final hasNotification = await Permission.notification.isGranted;
    final hasExactAlarm = await Permission.scheduleExactAlarm.isGranted;
    final ignoresBattery =
        await Permission.ignoreBatteryOptimizations.isGranted;

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF151B26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'فحص جاهزية الأذان',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDiagnosticItem(
                  'إذن الإشعارات',
                  hasNotification,
                  () => openAppSettings(),
                ),
                _buildDiagnosticItem(
                  'المنبهات الدقيقة (أندرويد 12+)',
                  hasExactAlarm,
                  () => Permission.scheduleExactAlarm.request(),
                ),
                _buildDiagnosticItem(
                  'استثناء البطارية',
                  ignoresBattery,
                  () => Permission.ignoreBatteryOptimizations.request(),
                ),
                const SizedBox(height: 15),
                Text(
                  '⚠️ ملاحظة: إذا كنت تستخدم شاومي/ريدمي، يرجى تفعيل "التشغيل التلقائي" (Autostart) من إعدادات التطبيق في الهاتف يدوياً.',
                  style: GoogleFonts.cairo(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إغلاق', style: GoogleFonts.cairo(color: _gold)),
              ),
            ],
          ),
    );
  }

  Widget _buildDiagnosticItem(String title, bool isOk, VoidCallback fixAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.error,
            color: isOk ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            ),
          ),
          if (!isOk)
            TextButton(
              onPressed: fixAction,
              child: Text(
                'إصلاح',
                style: GoogleFonts.cairo(color: _gold, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _showAdhanSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String currentMethod = _currentCalculationMethod;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bg = isDark ? const Color(0xFF151B26) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
            final subColor = isDark ? Colors.white54 : Colors.black54;
            final cardBg = isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade50;
            final borderCol = isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _gold.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // المقبض
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // العنوان
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.settings, color: _gold, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إعدادات الصلاة التلقائية',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'تحكم بالأذان والتنبيه والإقامة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: subColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // المحتوى القابل للتمرير
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // ═══════ 1. الأذان ═══════
                            _buildSettingsCard(
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              icon: Icons.mosque_rounded,
                              iconColor: _gold,
                              title: 'الأذان التلقائي',
                              subtitle: 'تشغيل الأذان عند كل صلاة',
                              textColor: textColor,
                              subColor: subColor,
                              trailing: Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: _adhanEnabled,
                                  activeColor: _gold,
                                  onChanged: (bool value) {
                                    Navigator.pop(context);
                                    _toggleAdhan(value);
                                  },
                                ),
                              ),
                              statusText: _adhanEnabled ? 'مفعّل' : 'معطّل',
                              statusColor:
                              _adhanEnabled ? Colors.green : Colors.grey,
                            ),

                            const SizedBox(height: 10),

                            // ═══════ 2. التنبيه القبلي ═══════
                            _buildSettingsCard(
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              icon: Icons.notifications_active_rounded,
                              iconColor: Colors.blue,
                              title: 'التنبيه القبلي التلقائي',
                              subtitle:
                              'تنبيه قبل الأذان بـ 10 دقائق لكل صلاة',
                              textColor: textColor,
                              subColor: subColor,
                              trailing: Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: _autoReminderEnabled,
                                  activeColor: Colors.blue,
                                  onChanged: (bool value) {
                                    setModalState(() {});
                                    _toggleAutoReminder(value);
                                  },
                                ),
                              ),
                              statusText: _autoReminderEnabled
                                  ? 'مفعّل'
                                  : 'معطّل',
                              statusColor: _autoReminderEnabled
                                  ? Colors.blue
                                  : Colors.grey,
                            ),

                            const SizedBox(height: 10),

                            // ═══════ 3. الإقامة ═══════
                            _buildSettingsCard(
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              icon: Icons.timer_rounded,
                              iconColor: Colors.purple,
                              title: 'الإقامة التلقائية',
                              subtitle:
                              'تشغيل الإقامة بعد الأذان بـ 10 دقائق',
                              textColor: textColor,
                              subColor: subColor,
                              trailing: Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: _autoIqamaEnabled,
                                  activeColor: Colors.purple,
                                  onChanged: (bool value) {
                                    setModalState(() {});
                                    _toggleAutoIqama(value);
                                  },
                                ),
                              ),
                              statusText:
                              _autoIqamaEnabled ? 'مفعّل' : 'معطّل',
                              statusColor: _autoIqamaEnabled
                                  ? Colors.purple
                                  : Colors.grey,
                            ),

                            const SizedBox(height: 16),
                            Divider(color: borderCol, height: 1),
                            const SizedBox(height: 16),

                            // ═══════ 4. طريقة الحساب ═══════
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: borderCol),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _gold.withOpacity(0.12),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.calculate_rounded,
                                          color: _gold,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'طريقة الحساب',
                                        style: GoogleFonts.cairo(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    dropdownColor: bg,
                                    value: currentMethod,
                                    style: GoogleFonts.cairo(
                                      color: textColor,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.white.withOpacity(0.04)
                                          : Colors.white,
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _gold.withOpacity(0.15),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _gold.withOpacity(0.15),
                                        ),
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'umm_al_qura',
                                        child: Text(
                                          'أم القرى (مكة المكرمة)',
                                          style: GoogleFonts.cairo(
                                              fontSize: 13),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'egyptian',
                                        child: Text(
                                          'الهيئة العامة المصرية',
                                          style: GoogleFonts.cairo(
                                              fontSize: 13),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'mwl',
                                        child: Text(
                                          'رابطة العالم الإسلامي',
                                          style: GoogleFonts.cairo(
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        setModalState(
                                                () => currentMethod = newValue);

                                        setState(() {
                                          _currentCalculationMethod =
                                              newValue;
                                        });

                                        final newTimes = await context
                                            .read<PrayerTimesController>()
                                            .applyCalculationMethod(
                                            newValue);

                                        if (newTimes != null && mounted) {
                                          setState(() {
                                            _livePrayerTimes =
                                            Map<String, String>.from(
                                                newTimes);
                                            _buildPrayerRows();
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'تم تحديث المواقيت',
                                                style: GoogleFonts.cairo(),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ═══════ 5. فحص الجاهزية ═══════
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(bottomSheetContext);
                                _runAdhanDiagnostic();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(
                                      isDark ? 0.08 : 0.05),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.blueAccent
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent
                                            .withOpacity(0.12),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.health_and_safety_rounded,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'فحص جاهزية الهاتف',
                                            style: GoogleFonts.cairo(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'اكتشف لماذا لا يعمل الأذان',
                                            style: GoogleFonts.cairo(
                                              color: subColor,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.blueAccent
                                          .withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ═══════ ملاحظة ═══════
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.orange
                                    .withOpacity(isDark ? 0.08 : 0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                  Colors.orange.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'يمكنك تخصيص كل صلاة على حدة بالضغط عليها من القائمة الرئيسية',
                                      style: GoogleFonts.cairo(
                                        color: Colors.orange
                                            .withOpacity(0.9),
                                        fontSize: 11.5,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subColor,
    required Widget trailing,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: subColor,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.cairo(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  MuezzinInfo _effectiveForKey(String key) {
    if (key == 'Sunrise') {
      return _defaultMuezzin ?? muezzinCatalog.first.items.first;
    }
    return _effective[key] ??
        _defaultMuezzin ??
        muezzinCatalog.first.items.first;
  }

  Future<void> _openCustomizeForPrayer(_PrayerRow row) async {
    if (row.noAdhan == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الشروق ليس له أذان', style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    PrayerCustomization config = _customizationFor(row.key);

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentMuezzin = _effectiveForKey(row.key);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bg = isDark ? const Color(0xFF151B26) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
            final subColor = isDark ? Colors.white60 : Colors.black54;

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _gold.withOpacity(0.2)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'تخصيص صلاة ${row.name}',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        row.time,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: subColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _settingsSectionTitle('المؤذن الحالي', textColor),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _gold.withOpacity(0.18)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_rounded, color: _gold),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                currentMuezzin.name,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final selected =
                                    await showModalBottomSheet<MuezzinInfo?>(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder:
                                          (ctx) => _MuezzinPickerSheet(
                                            gold: _gold,
                                            bg:
                                                isDark
                                                    ? const Color(0xFF151B26)
                                                    : Colors.white,
                                            title:
                                                'تخصيص مؤذن لصلاة ${row.name}',
                                            currentId: currentMuezzin.id,
                                          ),
                                    );

                                if (selected == null) return;

                                if (selected.id == '__DEFAULT__') {
                                  await MuezzinStore.clearCustomForPrayer(
                                    row.key,
                                  );
                                } else {
                                  await MuezzinStore.setCustomForPrayer(
                                    row.key,
                                    selected,
                                  );
                                }

                                await _loadDefaultAndEffective();
                                setModalState(() {});
                                setState(() {});
                              },
                              child: Text(
                                'تغيير',
                                style: GoogleFonts.cairo(
                                  color: _gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      _settingsSectionTitle('إعدادات الأذان', textColor),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: config.adhanEnabled,
                        activeColor: _gold,
                        title: Text(
                          'تفعيل الأذان لهذه الصلاة',
                          style: GoogleFonts.cairo(color: textColor),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            config = config.copyWith(adhanEnabled: val);
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'عدد دقائق التنبيه',
                              style: GoogleFonts.cairo(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value:
                                config.reminderEnabled
                                    ? config.reminderOffset
                                    : 0,
                            dropdownColor: bg,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  isDark
                                      ? Colors.white.withOpacity(0.04)
                                      : Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: _gold.withOpacity(0.15),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: _gold.withOpacity(0.15),
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('إيقاف التنبيه القبلي'),
                              ),
                              DropdownMenuItem(
                                value: 5,
                                child: Text('5 دقائق'),
                              ),
                              DropdownMenuItem(
                                value: 10,
                                child: Text('10 دقائق'),
                              ),
                              DropdownMenuItem(
                                value: 15,
                                child: Text('15 دقيقة'),
                              ),
                              DropdownMenuItem(
                                value: 20,
                                child: Text('20 دقيقة'),
                              ),
                            ],
                            onChanged: (val) async {
                              if (val != null) {
                                setModalState(() {
                                  config = config.copyWith(
                                    reminderEnabled: val > 0,
                                    reminderOffset: val == 0 ? 10 : val,
                                  );
                                });

                                if (val > 0) {
                                  await _previewReminderSound(
                                    config.reminderSound,
                                  );
                                }
                              }
                            },
                          ),

                          if (config.reminderEnabled) ...[
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'صوت التنبيه القبلي',
                                style: GoogleFonts.cairo(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value:
                                  [
                                        'hayalaaslah',
                                        'prayfajr',
                                      ].contains(config.reminderSound)
                                      ? config.reminderSound
                                      : 'hayalaaslah',
                              dropdownColor: bg,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    isDark
                                        ? Colors.white.withOpacity(0.04)
                                        : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: _gold.withOpacity(0.15),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: _gold.withOpacity(0.15),
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'hayalaaslah',
                                  child: Text('حي على الصلاة'),
                                ),
                                DropdownMenuItem(
                                  value: 'prayfajr',
                                  child: Text('الصلاة خير من النوم'),
                                ),
                              ],
                              onChanged: (val) async {
                                if (val != null) {
                                  setModalState(() {
                                    config = config.copyWith(
                                      reminderSound: val,
                                    );
                                  });

                                  await _previewReminderSound(val);
                                }
                              },
                            ),
                          ],
                        ],
                      ),

                      // ========== الإقامة ==========
                      const SizedBox(height: 18),
                      _settingsSectionTitle('الإقامة', textColor),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'وقت الإقامة بعد الأذان',
                          style: GoogleFonts.cairo(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: config.iqamaEnabled ? config.iqamaDelay : 0,
                        dropdownColor: bg,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                            BorderSide(color: _gold.withOpacity(0.15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                            BorderSide(color: _gold.withOpacity(0.15)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('إيقاف الإقامة')),
                          DropdownMenuItem(value: 5, child: Text('5 دقائق بعد الأذان')),
                          DropdownMenuItem(value: 10, child: Text('10 دقائق بعد الأذان')),
                          DropdownMenuItem(value: 15, child: Text('15 دقيقة بعد الأذان')),
                          DropdownMenuItem(value: 20, child: Text('20 دقيقة بعد الأذان')),
                          DropdownMenuItem(value: 25, child: Text('25 دقيقة بعد الأذان')),
                          DropdownMenuItem(value: 30, child: Text('30 دقيقة بعد الأذان')),
                        ],
                        onChanged: (val) async {
                          if (val != null) {
                            setModalState(() {
                              config = config.copyWith(
                                iqamaEnabled: val > 0,
                                iqamaDelay: val == 0 ? 10 : val,
                              );
                            });
                            if (val > 0) {
                              await _previewIqamaSound(config.iqamaSound);
                            }
                          }
                        },
                      ),

                      if (config.iqamaEnabled) ...[
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'صوت الإقامة',
                            style: GoogleFonts.cairo(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: iqamaCatalog.any((s) => s.id == config.iqamaSound)
                              ? config.iqamaSound
                              : iqamaCatalog.first.id,
                          dropdownColor: bg,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withOpacity(0.04)
                                : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                              BorderSide(color: _gold.withOpacity(0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                              BorderSide(color: _gold.withOpacity(0.15)),
                            ),
                          ),
                          items: iqamaCatalog
                              .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ))
                              .toList(),
                          onChanged: (val) async {
                            if (val != null) {
                              setModalState(() {
                                config = config.copyWith(iqamaSound: val);
                              });
                              await _previewIqamaSound(val);
                            }
                          },
                        ),
                      ],

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.red.withOpacity(0.35),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                final defaultConfig =
                                    PrayerCustomization.defaults();
                                await _savePrayerCustomization(
                                  row.key,
                                  defaultConfig,
                                );
                                await _previewPlayer.stop();

                                setModalState(() {
                                  config = defaultConfig;
                                });
                                setState(() {});
                              },
                              child: Text(
                                'إعادة الافتراضي',
                                style: GoogleFonts.cairo(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                await _savePrayerCustomization(row.key, config);

                                if (_adhanEnabled) {
                                  await _scheduleAllAdhans();
                                }

                                await _previewPlayer.stop();

                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم حفظ تخصيص صلاة ${row.name}',
                                        style: GoogleFonts.cairo(),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }

                                setState(() {});
                              },
                              child: Text(
                                'حفظ',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    await _previewPlayer.stop();
  }

  Widget _settingsSectionTitle(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> _openDefaultMuezzinSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MuezzinSettingsScreen(primaryColor: widget.primaryColor),
      ),
    );

    await _loadDefaultAndEffective();
    setState(() {});

    if (_adhanEnabled) {
      final downloadedOk = await _ensureSelectedMuezzinsDownloaded();
      if (downloadedOk) {
        await _scheduleAllAdhans();
      } else {
        setState(() => _adhanEnabled = false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('adhan_enabled', false);
      }
    }
  }

  Future<void> _toggleAdhan(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      final downloadedOk = await _ensureSelectedMuezzinsDownloaded();
      if (!downloadedOk) {
        if (mounted) setState(() => _adhanEnabled = false);
        await prefs.setBool('adhan_enabled', false);
        return;
      }

      final hasNotification = await Permission.notification.isGranted;
      final hasExactAlarm = await Permission.scheduleExactAlarm.isGranted;
      final ignoresBattery =
          await Permission.ignoreBatteryOptimizations.isGranted;

      if (hasNotification && hasExactAlarm) {
        if (mounted) setState(() => _adhanEnabled = true);
        await prefs.setBool('adhan_enabled', true);
        await _scheduleAllAdhans();
        _showSuccessMessage();
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                backgroundColor: _bgCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _gold.withOpacity(0.3), width: 1),
                ),
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: _gold),
                    const SizedBox(width: 10),
                    Text(
                      'صلاحيات ناقصة',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لضمان عمل الأذان، يرجى تفعيل الآتي في الإعدادات:',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!ignoresBattery)
                        _buildInstructionRow('1', 'استثناء البطارية (مستحسن)'),
                      if (!hasExactAlarm)
                        _buildInstructionRow('2', 'المنبهات والتذكيرات'),
                      if (!hasNotification)
                        _buildInstructionRow('3', 'السماح بالإشعارات'),
                      const SizedBox(height: 10),
                      Text(
                        'ملاحظة: لشاومي وأوبو يُفضل تفعيل (التشغيل التلقائي) و(الظهور على شاشة القفل).',
                        style: GoogleFonts.cairo(
                          color: Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      if (mounted) setState(() => _adhanEnabled = false);
                      await prefs.setBool('adhan_enabled', false);
                    },
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _gold),
                    onPressed: () async {
                      Navigator.pop(ctx);

                      _isWaitingForSettingsReturn = true;

                      if (!hasNotification)
                        await Permission.notification.request();
                      if (!hasExactAlarm)
                        await Permission.scheduleExactAlarm.request();
                      if (!ignoresBattery) {
                        await Permission.ignoreBatteryOptimizations.request();
                      }

                      await openAppSettings();
                    },
                    child: Text(
                      'الذهاب للإعدادات',
                      style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    } else {
      if (mounted) setState(() => _adhanEnabled = false);
      await prefs.setBool('adhan_enabled', false);

      await AdahnNotification.instance.cancelAll();

      const ids = {
        'Fajr': 100,
        'Dhuhr': 101,
        'Asr': 102,
        'Maghrib': 103,
        'Isha': 104,
      };

      for (final id in ids.values) {
        await NativeAdhanBridge.cancelAdhan(id);
        await NativeAdhanBridge.cancelReminder(id + 1000);
        await NativeAdhanBridge.cancelIqama(id + 2000);
      }

      _showErrorSnackBar('تم إيقاف الأذان التلقائي', isOrange: true);
    }
  }

  void _showSuccessMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ تم تفعيل وجدولة الأذان بنجاح',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message, {bool isOrange = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.cairo()),
          backgroundColor: isOrange ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _scheduleAllAdhans() async {
    const ids = {
      'Fajr': 100,
      'Dhuhr': 101,
      'Asr': 102,
      'Maghrib': 103,
      'Isha': 104,
    };

    // إلغاء كل شيء أولاً
    for (final id in ids.values) {
      await NativeAdhanBridge.cancelAdhan(id);
      await NativeAdhanBridge.cancelReminder(id + 1000);
      await NativeAdhanBridge.cancelIqama(id + 2000);
    }

    final now = DateTime.now();

    for (final row in _rows) {
      if (row.noAdhan == true) continue;

      final config = _customizationFor(row.key);

      debugPrint(
        '=== ${row.name} === adhan=${config.adhanEnabled} | reminder=${config.reminderEnabled}/${config.reminderOffset}min | iqama=${config.iqamaEnabled}/${config.iqamaDelay}min',
      );

      if (!config.adhanEnabled) continue;

      final m = _effectiveForKey(row.key);
      final local =
          m.isBuiltIn
              ? null
              : await AdhanAudioService.instance.getLocalPath(m.id);

      var prayerTime = row.dateTime;
      if (now.isAfter(prayerTime)) {
        prayerTime = prayerTime.add(const Duration(days: 1));
      }

      final adhanSound =
          m.localSoundName.isNotEmpty ? m.localSoundName : 'makkah';

      // ✅ 1. جدولة الأذان
      debugPrint('>> Adhan: ${row.name} at $prayerTime');
      await NativeAdhanBridge.scheduleAdhan(
        time: prayerTime,
        prayerName: row.name,
        requestCode: ids[row.key]!,
        soundName: adhanSound,
        localPath: local,
      );

      // ✅ 2. جدولة التنبيه القبلي
      if (config.reminderEnabled && config.reminderOffset > 0) {
        final reminderTime = prayerTime.subtract(
          Duration(minutes: config.reminderOffset),
        );

        if (reminderTime.isAfter(now)) {
          final reminderLocalPath = await _getReminderLocalPath(
            row.key,
            config.reminderSound,
          );

          debugPrint(
            '>> Reminder: ${row.name} at $reminderTime | sound=${config.reminderSound} | path=$reminderLocalPath',
          );

          await NativeAdhanBridge.scheduleReminder(
            time: reminderTime,
            prayerName: row.name,
            requestCode: ids[row.key]! + 1000,
            soundName: config.reminderSound,
            localPath: reminderLocalPath,
          );
        } else {
          debugPrint('>> Reminder SKIPPED: ${row.name} (time passed)');
        }
      }

      // ✅ 3. جدولة الإقامة
      if (config.iqamaEnabled && config.iqamaDelay > 0) {
        final iqamaTime = prayerTime.add(Duration(minutes: config.iqamaDelay));

        if (iqamaTime.isAfter(now)) {
          final iqamaLocalPath = await _getIqamaLocalPath(
            row.key,
            config.iqamaSound,
          );

          debugPrint(
            '>> Iqama: ${row.name} at $iqamaTime | sound=${config.iqamaSound} | path=$iqamaLocalPath',
          );

          await NativeAdhanBridge.scheduleIqama(
            time: iqamaTime,
            prayerName: row.name,
            requestCode: ids[row.key]! + 2000,
            soundName: config.iqamaSound,
            localPath: iqamaLocalPath,
          );
        } else {
          debugPrint('>> Iqama SKIPPED: ${row.name} (time passed)');
        }
      }
    }

    debugPrint('=== All scheduling complete ===');
  }

  Future<void> _playNextAdhanPreview() async {
    if (_nextIndex < 0) return;
    final row = _rows[_nextIndex];

    if (row.noAdhan == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الشروق ليس له أذان', style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final m = _effectiveForKey(row.key);
    final local = await AdhanAudioService.instance.getLocalPath(m.id);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AdhanPlayerScreen(
              primaryColor: widget.primaryColor,
              prayerName: row.name,
              muezzinName: m.name,
              url: m.url,
              localPath: local,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = const Color(0xFFE6B325);

    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    final listCardGradient =
        isDark
            ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
            : [Colors.white, Colors.white];

    final listCardBorder =
        isDark ? Colors.white.withOpacity(0.1) : gold.withOpacity(0.2);

    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: gold)),
      );
    }

    final nextRemain = _fmtRemain(_remainingToNext());
    final nextRow = _nextIndex >= 0 ? _rows[_nextIndex] : null;
    final nextM = nextRow == null ? null : _effectiveForKey(nextRow.key);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.watch<PrayerTimesController>().cityName.isNotEmpty
              ? context.watch<PrayerTimesController>().cityName
              : 'مواقيت الصلاة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: gold),
            tooltip: 'تحديث الموقع',
            onPressed: () async {
              await context
                  .read<PrayerTimesController>()
                  .refreshLocationAndPrayerTimes();

              if (!mounted) return;
              setState(() {
                _livePrayerTimes = Map<String, String>.from(
                  context.read<PrayerTimesController>().prayerTimes,
                );
                _buildPrayerRows();
              });
            },
          ),
          IconButton(
            icon: Icon(
              _adhanEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color:
                  _adhanEnabled
                      ? gold
                      : (isDark ? Colors.white54 : Colors.black45),
            ),
            onPressed: _showAdhanSettings,
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.settings_voice, color: gold),
              onPressed: _openDefaultMuezzinSettings,
            ),
          ),
        ],
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDark ? Colors.white.withOpacity(0.1) : gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gold.withOpacity(0.2), gold.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: gold.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: gold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: gold.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                'الصلاة القادمة',
                                style: GoogleFonts.cairo(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              nextRow?.name ?? '--',
                              style: GoogleFonts.amiri(
                                fontSize: 36,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextRow?.time ?? '--:--',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (nextM != null)
                              Text(
                                'المؤذن: ${nextM.name}',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: gold.withOpacity(0.9),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: gold, width: 3),
                          color: cardColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              nextRemain,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'متبقي',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _playNextAdhanPreview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold.withOpacity(0.2),
                            foregroundColor: gold,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: gold.withOpacity(0.3)),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            'استمع للأذان',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RadioMiniPlayer(gold: gold),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'جدول المواقيت',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                if (nextRow != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gold.withOpacity(0.35)),
                    ),
                    child: Text(
                      'التالية: ${nextRow.name}',
                      style: GoogleFonts.cairo(
                        color: gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ..._rows.map((row) {
              final isCurrent = row.isCurrent;
              final isNext = row.isNext;
              final isPast = row.isPast;
              final m = _effectiveForKey(row.key);
              final isDefaultMuezzin = _isPrayerUsingDefaultMuezzin(row.key);
              final config = _customizationFor(row.key);

              return GestureDetector(
                onTap: () => _openCustomizeForPrayer(row),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isCurrent
                              ? [gold.withOpacity(0.15), gold.withOpacity(0.05)]
                              : isNext
                              ? [gold.withOpacity(0.10), gold.withOpacity(0.03)]
                              : listCardGradient,
                    ),
                    color: _getPrayerCardAccentColor(
                      isDefaultMuezzin: isDefaultMuezzin,
                      isDark: isDark,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isCurrent
                              ? gold.withOpacity(0.9)
                              : !isDefaultMuezzin
                              ? gold.withOpacity(0.45)
                              : isNext
                              ? gold.withOpacity(0.55)
                              : listCardBorder,
                      width: isCurrent ? 2.0 : (!isDefaultMuezzin ? 1.4 : 1.0),
                    ),
                    boxShadow:
                        isNext
                            ? [
                              BoxShadow(
                                color: gold.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                            : [
                              BoxShadow(
                                color:
                                    isDark
                                        ? Colors.black.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  isPast
                                      ? Colors.grey.withOpacity(0.2)
                                      : gold.withOpacity(
                                        isCurrent || isNext ? 0.25 : 0.10,
                                      ),
                              borderRadius: BorderRadius.circular(15),
                              border:
                                  (isCurrent || isNext)
                                      ? Border.all(
                                        color: gold.withOpacity(0.8),
                                        width: 1.5,
                                      )
                                      : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  row.icon,
                                  color:
                                      isPast
                                          ? Colors.grey
                                          : (isCurrent || isNext
                                              ? gold
                                              : subTextColor),
                                  size: 24,
                                ),
                                if (isNext)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: gold,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: gold.withOpacity(0.8),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      row.name,
                                      style: GoogleFonts.amiri(
                                        fontSize: 22,
                                        color:
                                            isPast
                                                ? subTextColor.withOpacity(0.5)
                                                : textColor,
                                        fontWeight:
                                            isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    if (isCurrent)
                                      _badge(
                                        'الآن',
                                        bg: gold,
                                        fg: Colors.black,
                                      ),
                                    if (isNext && !isCurrent)
                                      _badge(
                                        'التالية',
                                        bg: gold.withOpacity(0.2),
                                        fg: gold,
                                        border: gold.withOpacity(0.5),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  row.noAdhan == true
                                      ? 'هذه الصلاة لا تحتوي على أذان'
                                      : 'اضغط لتخصيص الصلاة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    color:
                                        row.noAdhan == true
                                            ? Colors.orange
                                            : subTextColor.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  row.time,
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    color:
                                        isPast
                                            ? subTextColor.withOpacity(0.4)
                                            : (isCurrent || isNext
                                                ? gold
                                                : textColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (row.noAdhan == true)
                                Text(
                                  'بدون أذان',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: subTextColor.withOpacity(0.5),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 18,
                              color: row.noAdhan == true ? Colors.grey : _gold,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                row.noAdhan == true
                                    ? 'لا يمكن تخصيص الشروق'
                                    : 'المؤذن الحالي: ${m.name}',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color:
                                      row.noAdhan == true
                                          ? subTextColor.withOpacity(0.6)
                                          : _gold.withOpacity(0.95),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (row.noAdhan != true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _gold.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'تخصيص',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: _gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (row.noAdhan != true) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _muezzinTypeBadge(isDefault: isDefaultMuezzin),
                            _statusMiniBadge(
                              label: 'الأذان',
                              color:
                                  config.adhanEnabled
                                      ? Colors.green
                                      : Colors.red,
                              active: config.adhanEnabled,
                            ),
                            _statusMiniBadge(
                              label:
                                  config.reminderEnabled
                                      ? 'تنبيه ${config.reminderOffset}د'
                                      : 'التنبيه',
                              color:
                                  config.reminderEnabled
                                      ? Colors.blue
                                      : Colors.grey,
                              active: config.reminderEnabled,
                            ),
                            _statusMiniBadge(
                              label: config.iqamaEnabled
                                  ? 'إقامة ${config.iqamaDelay}د'
                                  : 'الإقامة',
                              color: config.iqamaEnabled ? Colors.purple : Colors.grey,
                              active: config.iqamaEnabled,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: _gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(
    String text, {
    required Color bg,
    required Color fg,
    Color? border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _muezzinTypeBadge({required bool isDefault}) {
    if (isDefault) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.25)),
        ),
        child: Text(
          'افتراضي',
          style: GoogleFonts.cairo(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withOpacity(0.30)),
      ),
      child: Text(
        'مخصص',
        style: GoogleFonts.cairo(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: _gold,
        ),
      ),
    );
  }

  Widget _statusMiniBadge({
    required String label,
    required Color color,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              active ? color.withOpacity(0.30) : Colors.grey.withOpacity(0.20),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: active ? color : Colors.grey,
        ),
      ),
    );
  }
}

class _PrayerRow {
  final String key;
  final String name;
  String time;
  final IconData icon;
  final bool? noAdhan;

  late DateTime dateTime;

  bool isPast = false;
  bool isCurrent = false;
  bool isNext = false;
  bool isTomorrow = false;

  _PrayerRow({
    required this.key,
    required this.name,
    required this.time,
    required this.icon,
    this.noAdhan,
  });
}

class _MuezzinPickerSheet extends StatelessWidget {
  final Color gold;
  final Color bg;
  final String title;
  final String currentId;

  const _MuezzinPickerSheet({
    required this.gold,
    required this.bg,
    required this.title,
    required this.currentId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final cardColor =
        isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50;
    final borderColor =
        isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white54 : Colors.black54;

    final all = <_PickItem>[];

    all.add(
      _PickItem(
        isHeader: false,
        categoryName: '',
        m: MuezzinInfo(
          id: '__DEFAULT__',
          name: 'استخدام المؤذن الافتراضي',
          url: '',
          description: 'إلغاء التخصيص لهذه الصلاة',
          imageUrl: '',
          localSoundName: 'makkah',
        ),
      ),
    );

    for (final cat in muezzinCatalog) {
      all.add(_PickItem(isHeader: true, categoryName: cat.name, m: null));
      for (final m in cat.items) {
        all.add(_PickItem(isHeader: false, categoryName: cat.name, m: m));
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Icon(Icons.record_voice_over_rounded, color: gold, size: 26),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اختر مؤذنًا مختلفًا لهذه الصلاة',
                    style: GoogleFonts.cairo(color: subColor, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.withOpacity(0.15), height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                physics: const BouncingScrollPhysics(),
                itemCount: all.length,
                itemBuilder: (context, i) {
                  final it = all[i];

                  if (it.isHeader) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            it.categoryName,
                            style: GoogleFonts.cairo(
                              color: gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final m = it.m!;
                  final isDefaultOption = m.id == '__DEFAULT__';
                  final isSel = (!isDefaultOption && m.id == currentId);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSel ? gold.withOpacity(0.6) : borderColor,
                        width: isSel ? 1.8 : 1,
                      ),
                      boxShadow:
                          isSel
                              ? [
                                BoxShadow(
                                  color: gold.withOpacity(0.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : [],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: gold.withOpacity(0.22)),
                        ),
                        child: Icon(
                          isDefaultOption
                              ? Icons.restore_rounded
                              : Icons.person_rounded,
                          color: gold,
                        ),
                      ),
                      title: Text(
                        m.name,
                        style: GoogleFonts.cairo(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        isDefaultOption
                            ? m.description
                            : '${it.categoryName} • ${m.description}',
                        style: GoogleFonts.cairo(color: subColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing:
                          isSel
                              ? Icon(Icons.check_circle_rounded, color: gold)
                              : Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: subColor,
                              ),
                      onTap: () => Navigator.pop(context, m),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickItem {
  final bool isHeader;
  final String categoryName;
  final MuezzinInfo? m;

  _PickItem({
    required this.isHeader,
    required this.categoryName,
    required this.m,
  });
}

class PrayerCustomization {
  final bool adhanEnabled;
  final bool reminderEnabled;
  final int reminderOffset;
  final String reminderSound;
  final bool iqamaEnabled;
  final int iqamaDelay;
  final String iqamaSound;

  const PrayerCustomization({
    required this.adhanEnabled,
    required this.reminderEnabled,
    required this.reminderOffset,
    required this.reminderSound,
    required this.iqamaEnabled,
    required this.iqamaDelay,
    required this.iqamaSound,
  });

  factory PrayerCustomization.defaults() {
    return const PrayerCustomization(
      adhanEnabled: true,
      reminderEnabled: true,
      reminderOffset: 10,
      reminderSound: 'hayalaaslah',
      iqamaEnabled: false,
      iqamaDelay: 10,
      iqamaSound: 'iqama1',
    );
  }

  PrayerCustomization copyWith({
    bool? adhanEnabled,
    bool? reminderEnabled,
    int? reminderOffset,
    String? reminderSound,
    bool? iqamaEnabled,
    int? iqamaDelay,
    String? iqamaSound,
  }) {
    return PrayerCustomization(
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderOffset: reminderOffset ?? this.reminderOffset,
      reminderSound: reminderSound ?? this.reminderSound,
      iqamaEnabled: iqamaEnabled ?? this.iqamaEnabled,
      iqamaDelay: iqamaDelay ?? this.iqamaDelay,
      iqamaSound: iqamaSound ?? this.iqamaSound,
    );
  }
}
