import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../languages/app_localizations.dart';
import 'widgets/radio_widget.dart';
import '../features/prayer_os/presentation/screens/prayer_os_screen.dart';
import '../more/controllers/prayer_times_controller.dart';
import '../more/data/iqama_catalog.dart';
import '../more/data/muezzin_catalog.dart';
import '../more/services/adahn_audio_services.dart';
import '../more/services/adahn_notification.dart';
import '../more/services/muazzin_store.dart';
import '../../../services/native_adhan_bridge.dart';
import '../core/prayer_time_core.dart';

import '../adhan_player_screen/adhan_player_screen.dart';
import '../muzzin_settings/muzzin_settings.dart';

import 'widgets/prayer_models.dart';
import 'widgets/prayer_app_bar.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_schedule_header.dart';
import 'widgets/prayer_row_card.dart';
import 'widgets/prayer_settings_card.dart';
import 'widgets/prayer_diagnostic_dialog.dart';
import 'widgets/muezzin_picker_sheet.dart';
import 'widgets/prayer_customize_sheet.dart';

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
  final Color _bgCard = const Color(0xFF151B26);
  Map<String, String> _livePrayerTimes = {};
  Future<Map<String, String>?> Function(String methodKey)?
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

  late List<PrayerRow> _rows;
  int _currentIndex = -1;
  int _nextIndex = -1;
  Map<String, String> _tomorrowPrayerTimes = {};
  String _timeZoneId = '';
  String _prayerDate = '';
  bool _hasResolvedLocation = false;
  PrayerTimesController? _boundController;
  String _lastControllerSignature = '';
  bool _syncInProgress = false;
  bool _scheduleRunInProgress = false;

  Timer? _tick;

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Lifecycle
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onApplyCalculationMethod = widget.onApplyCalculationMethod;
    _bootstrap();
    _checkScheduleNeedsUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _boundController?.removeListener(_onControllerChanged);
    _tick?.cancel();
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<PrayerTimesController>();
    if (!identical(_boundController, controller)) {
      _boundController?.removeListener(_onControllerChanged);
      _boundController = controller;
      _boundController!.addListener(_onControllerChanged);
    }
    // ظ‡ط°ظ‡ ط§ظ„ط¯ط§ظ„ط© طھط¹ظ…ظ„ طھظ„ظ‚ط§ط¦ظٹط§ظ‹ ظپظˆط±ط§ظ‹ ط¹ظ†ط¯ طھط؛ظٹظٹط± ظ„ط؛ط© ط§ظ„طھط·ط¨ظٹظ‚
    if (!_loading && _rows.isNotEmpty) {
      setState(() {
        _buildPrayerRows(); // ط£ط¹ط¯ ط¨ظ†ط§ط، ط§ظ„طµظ„ظˆط§طھ ط¨ط§ظ„ظ„ط؛ط© ط§ظ„ط¬ط¯ظٹط¯ط©
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_isWaitingForSettingsReturn) {
        _isWaitingForSettingsReturn = false;
        _verifyPermissionsAfterReturn();
      }
      _refreshPrayerData();
    }
  }

  void _onControllerChanged() {
    if (!mounted || _loading || _syncInProgress || _boundController == null) {
      return;
    }
    final controller = _boundController!;
    final signature =
        '${controller.prayerDate}|${controller.timeZoneId}|'
        '${controller.calculationMethod}|${controller.prayerTimes.entries.join(';')}|'
        '${controller.tomorrowPrayerTimes.entries.join(';')}';
    if (signature == _lastControllerSignature) return;
    _lastControllerSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncFromController();
    });
  }

  Future<void> _refreshPrayerData() async {
    if (_syncInProgress || !mounted) return;
    _syncInProgress = true;
    try {
      await context
          .read<PrayerTimesController>()
          .refreshLocationAndPrayerTimes();
      if (mounted) _syncFromController();
    } finally {
      _syncInProgress = false;
    }
  }

  void _syncFromController() {
    final controller = context.read<PrayerTimesController>();
    _hasResolvedLocation =
        controller.hasLocation && controller.prayerTimes.isNotEmpty;
    if (controller.prayerTimes.isEmpty) {
      _livePrayerTimes = {};
      _tomorrowPrayerTimes = {};
      _timeZoneId = controller.timeZoneId;
      _prayerDate = controller.prayerDate;
      _buildPrayerRows();
      if (mounted) setState(() {});
      return;
    }
    _livePrayerTimes =
        controller.hasLocation
            ? Map<String, String>.from(controller.prayerTimes)
            : {};
    _tomorrowPrayerTimes = Map<String, String>.from(
      controller.tomorrowPrayerTimes,
    );
    _timeZoneId = controller.timeZoneId;
    _prayerDate = controller.prayerDate;
    _currentCalculationMethod = controller.calculationMethod;
    _buildPrayerRows();
    if (mounted) setState(() {});
    if (_adhanEnabled) unawaited(_checkAndCompleteScheduling());
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // All business logic methods unchanged
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

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
      if (await file.exists()) return file.path;
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
    if (savedPath != null && File(savedPath).existsSync()) return savedPath;
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
      if (await file.exists()) return file.path;
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
    if (savedPath != null && File(savedPath).existsSync()) return savedPath;
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

  Future<void> _saveCustomizationQuick(
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
    _prayerCustomizations[key] = config;
    debugPrint('✅ Quick save: $key');
  }

  void _scheduleInBackground() {
    if (_scheduleRunInProgress) return;
    _scheduleRunInProgress = true;
    Future(() async {
      debugPrint('🔄 Background scheduling started...');
      final prefs = await SharedPreferences.getInstance();
      try {
        for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
          final config = _customizationFor(key);
          if (config.reminderEnabled) {
            final path = await _downloadReminderSoundIfNeeded(
              config.reminderSound,
            );
            if (path != null) {
              await prefs.setString('prayer_${key}_reminder_local_path', path);
            }
          }
          if (config.iqamaEnabled) {
            final path = await _downloadIqamaSoundIfNeeded(config.iqamaSound);
            if (path != null) {
              await prefs.setString('prayer_${key}_iqama_local_path', path);
            }
          }
        }
        final schedule = await _calculateNext14DaysWithCustomization();
        if (schedule.isNotEmpty) {
          await NativeAdhanBridge.savePrayerSchedule(schedule: schedule);
          await prefs.setBool('full_schedule_saved', true);
          await prefs.remove('prayer_schedule_needs_update');
          debugPrint('✅ Full ${schedule.length}-day schedule saved!');
        } else {
          await prefs.setBool('full_schedule_saved', false);
          debugPrint('⚠️ Schedule calculation failed, will retry later');
        }
      } catch (e) {
        await prefs.setBool('full_schedule_saved', false);
        debugPrint('❌ Background scheduling error: $e');
      } finally {
        _scheduleRunInProgress = false;
      }
    });
  }

  bool _isPrayerUsingDefaultMuezzin(String prayerKey) {
    final effective = _effectiveForKey(prayerKey);
    final defaultM = _defaultMuezzin ?? muezzinCatalog.first.items.first;
    return effective.id == defaultM.id;
  }

  /// âœ… طھط­ط¯ظٹط¯ ط·ط±ظٹظ‚ط© ط§ظ„ط­ط³ط§ط¨ ط¨ط­ط³ط¨ ط§ظ„ظ…ظˆظ‚ط¹
  Future<void> _bootstrap() async {
    final prayerController = context.read<PrayerTimesController>();
    await prayerController.initialize();
    if (!mounted) return;
    _currentCalculationMethod = prayerController.calculationMethod;

    await _loadDefaultAndEffective();
    if (!mounted) return;
    await _loadPrayerCustomizations();
    if (!mounted) return;

    // âœ… ط§ط³طھط®ط¯ظ… ط§ظ„ط£ظˆظ‚ط§طھ ط§ظ„ظ…ط­ط³ظˆط¨ط© ط§ظ„ط¬ط¯ظٹط¯ط© ط¥ط°ط§ طھظˆظپط±طھ
    _syncFromController();
    await _loadAdhanEnabled();
    if (!mounted) return;

    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final currentDate = PrayerClock.dateKey(DateTime.now(), _timeZoneId);
      if (_prayerDate.isNotEmpty && currentDate != _prayerDate) {
        _refreshPrayerData();
        return;
      }
      setState(() => _computeCurrentNext());
    });

    setState(() => _loading = false);

    if (_adhanEnabled) {
      await _checkAndCompleteScheduling();
    }
  }

  Future<void> _checkAndCompleteScheduling() async {
    final prefs = await SharedPreferences.getInstance();
    final fullScheduleSaved = prefs.getBool('full_schedule_saved') ?? false;
    final needsUpdate = prefs.getBool('prayer_schedule_needs_update') ?? false;
    if (!fullScheduleSaved || needsUpdate) {
      debugPrint('📌 Schedule incomplete, completing now...');
      await _rescheduleConfiguredPrayers();
    } else {
      debugPrint('✅ Full schedule already saved');
    }
  }

  Future<void> _checkScheduleNeedsUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final needsUpdate = prefs.getBool('prayer_schedule_needs_update') ?? false;
    if (needsUpdate && _adhanEnabled) {
      debugPrint('⚠️ Schedule needs update, recalculating...');
      await Future.delayed(const Duration(seconds: 2));
      await _scheduleAllAdhans();
      await prefs.remove('prayer_schedule_needs_update');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr.prayerTimesUpdatedAuto,
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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
    bool allReady = true;
    for (final row in _rows) {
      if (row.noAdhan == true) continue;
      final m = _effectiveForKey(row.key);
      if (m.isBuiltIn) continue;
      final local = await AdhanAudioService.instance.getLocalPath(m.id);
      if (local == null || local.isEmpty) {
        debugPrint('⬇️ Downloading muezzin: ${m.name}...');
        try {
          final downloaded = await AdhanAudioService.instance.downloadAndSave(
            m.id,
            m.url,
          );
          if (downloaded != null && downloaded.isNotEmpty) {
            debugPrint('✅ Downloaded: ${m.name}');
          } else {
            debugPrint('❌ Failed to download: ${m.name}, will use fallback');
            allReady = false;
          }
        } catch (e) {
          debugPrint('❌ Download error for ${m.name}: $e');
          allReady = false;
        }
      }
    }
    if (!allReady && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr.muezzinSoundsNotDownloaded,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    return allReady;
  }

  Future<void> _verifyPermissionsAfterReturn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasNotification = await Permission.notification.isGranted;
    final hasExactAlarm = await Permission.scheduleExactAlarm.isGranted;
    final downloadedOk = await _ensureSelectedMuezzinsDownloaded();
    if (!mounted) return;
    if (hasNotification && hasExactAlarm && downloadedOk) {
      setState(() => _adhanEnabled = true);
      await prefs.setBool('adhan_enabled', true);
      await _scheduleAllAdhans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr.adhanEnabledSuccessfully,
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      setState(() => _adhanEnabled = false);
      await prefs.setBool('adhan_enabled', false);
      if (!mounted) return;
      _showErrorSnackBar(context.tr.conditionsNotMetForAdhan);
    }
  }

  Future<void> _loadPrayerCustomizations() async {
    await _fixReminderSoundPrefs();
    final prefs = await SharedPreferences.getInstance();
    for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      _prayerCustomizations[key] = PrayerCustomization(
        adhanEnabled: prefs.getBool('prayer_${key}_adhan_enabled') ?? true,
        reminderEnabled:
            prefs.getBool('prayer_${key}_reminder_enabled') ?? false,
        reminderOffset: prefs.getInt('prayer_${key}_reminder_offset') ?? 10,
        reminderSound:
            prefs.getString('prayer_${key}_reminder_sound') ?? 'hayalaaslah',
        iqamaEnabled: prefs.getBool('prayer_${key}_iqama_enabled') ?? false,
        iqamaDelay: prefs.getInt('prayer_${key}_iqama_delay') ?? 10,
        iqamaSound: prefs.getString('prayer_${key}_iqama_sound') ?? 'iqama1',
      );
      debugPrint(
        '📌 Loaded $key: adhan=${_prayerCustomizations[key]!.adhanEnabled}',
      );
    }
    _autoReminderEnabled = prefs.getBool('auto_reminder_enabled') ?? false;
    _autoIqamaEnabled = prefs.getBool('auto_iqama_enabled') ?? false;
  }

  Future<void> _toggleAutoReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _autoReminderEnabled = value);
    await prefs.setBool('auto_reminder_enabled', value);
    if (value) {
      await _downloadReminderSoundIfNeeded('hayalaaslah');
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final current = _customizationFor(key);
        if (!current.reminderEnabled) {
          final updated = current.copyWith(
            reminderEnabled: true,
            reminderOffset: 10,
            reminderSound: 'hayalaaslah',
          );
          await _saveCustomizationQuick(key, updated);
        }
      }
      if (_adhanEnabled) {
        await _rescheduleConfiguredPrayers();
      }
      // ظ„ظ„ط±ط³ط§ظ„ط© ط§ظ„ط®ط¶ط±ط§ط،
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr.preReminderEnabled,
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
      if (_adhanEnabled) {
        await _rescheduleConfiguredPrayers();
      }
      // ظ„ظ„ط±ط³ط§ظ„ط© ط§ظ„ط¨ط±طھظ‚ط§ظ„ظٹط© (ظپظٹ ظ‚ط³ظ… else)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr.preReminderDisabledAll,
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
      await _downloadIqamaSoundIfNeeded(iqamaCatalog.first.id);
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final current = _customizationFor(key);
        if (!current.iqamaEnabled) {
          final updated = current.copyWith(
            iqamaEnabled: true,
            iqamaDelay: 10,
            iqamaSound: iqamaCatalog.first.id,
          );
          await _saveCustomizationQuick(key, updated);
        }
      }
      if (_adhanEnabled) {
        await _rescheduleConfiguredPrayers();
      }
      // ظ„ظ„ط±ط³ط§ظ„ط© ط§ظ„ط®ط¶ط±ط§ط،
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.iqamaEnabled, style: GoogleFonts.cairo()),
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
      if (_adhanEnabled) {
        await _rescheduleConfiguredPrayers();
      }
      // ظ„ظ„ط±ط³ط§ظ„ط© ط§ظ„ط¨ط±طھظ‚ط§ظ„ظٹط© (ظپظٹ ظ‚ط³ظ… else)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr.iqamaDisabledAll,
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
    debugPrint('✅ Saved customization for $key: $config');
  }

  void _buildPrayerRows() {
    final times =
        _hasResolvedLocation ? _livePrayerTimes : const <String, String>{};
    final now = PrayerClock.nowAt(_timeZoneId);
    _rows = [
      PrayerRow(
        key: 'Fajr',
        name: context.tr.prayerFajr,
        time: times['Fajr'] ?? '—',
        icon: Icons.wb_twilight,
      ),
      PrayerRow(
        key: 'Sunrise',
        name: context.tr.prayerSunrise,
        time: times['Sunrise'] ?? '—',
        icon: Icons.wb_sunny_outlined,
        noAdhan: true,
      ),
      PrayerRow(
        key: 'Dhuhr',
        name: context.tr.prayerDhuhr,
        time: times['Dhuhr'] ?? '—',
        icon: Icons.sunny,
      ),
      PrayerRow(
        key: 'Asr',
        name: context.tr.prayerAsr,
        time: times['Asr'] ?? '—',
        icon: Icons.filter_drama,
      ),
      PrayerRow(
        key: 'Maghrib',
        name: context.tr.prayerMaghrib,
        time: times['Maghrib'] ?? '—',
        icon: Icons.nights_stay,
      ),
      PrayerRow(
        key: 'Isha',
        name: context.tr.prayerIsha,
        time: times['Isha'] ?? '—',
        icon: Icons.star_rounded,
      ),
    ];
    for (final r in _rows) {
      r.dateTime = r.time == '—' ? now : _parseTimeToday(r.time, now);
    }
    if (_hasResolvedLocation) {
      _computeCurrentNext();
    } else {
      _currentIndex = -1;
      _nextIndex = -1;
    }
  }

  DateTime _parseTimeToday(String timeStr, DateTime now) {
    return PrayerClock.wallTime(
      date: now,
      time: timeStr,
      timeZoneId: _timeZoneId,
    );
  }

  void _computeCurrentNext() {
    final now = PrayerClock.nowAt(_timeZoneId);
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
      final localNow = PrayerClock.nowAt(_timeZoneId);
      final tomorrow = DateTime(
        localNow.year,
        localNow.month,
        localNow.day + 1,
      );
      final tomorrowTime = _tomorrowPrayerTimes[nextRow.key] ?? nextRow.time;
      target = PrayerClock.wallTime(
        date: tomorrow,
        time: tomorrowTime,
        timeZoneId: _timeZoneId,
      );
    }
    final d = target.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  String _fmtRemain(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  MuezzinInfo _effectiveForKey(String key) {
    if (key == 'Sunrise') {
      return _defaultMuezzin ?? muezzinCatalog.first.items.first;
    }
    return _effective[key] ??
        _defaultMuezzin ??
        muezzinCatalog.first.items.first;
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
          (ctx) => PrayerDiagnosticDialog(
            hasNotification: hasNotification,
            hasExactAlarm: hasExactAlarm,
            ignoresBattery: ignoresBattery,
            gold: _gold,
            onFixNotification: () => openAppSettings(),
            onFixExactAlarm: () => Permission.scheduleExactAlarm.request(),
            onFixBattery: () => Permission.ignoreBatteryOptimizations.request(),
          ),
    );
  }

  void _showAdhanSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String currentMethod =
        prefs.getString('calc_method_manual') ??
        PrayerMethodCatalog.automaticKey;
    if (!mounted) return;

    final prayerTimesController = context.read<PrayerTimesController>();

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
            final cardBg =
                isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50;
            final borderCol =
                isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _gold.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
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
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.15),
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
                                  context.tr.autoPrayerSettings,
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  context.tr.controlAdhanReminderIqama,
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
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            PrayerSettingsCard(
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              icon: Icons.mosque_rounded,
                              iconColor: _gold,
                              title: context.tr.autoAdhan,
                              subtitle: context.tr.playAdhanEveryPrayer,
                              textColor: textColor,
                              subColor: subColor,
                              trailing: Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: _adhanEnabled,
                                  activeThumbColor: _gold,
                                  onChanged: (bool value) {
                                    Navigator.pop(context);
                                    _toggleAdhan(value);
                                  },
                                ),
                              ),
                              statusText:
                                  _adhanEnabled
                                      ? context.tr.statusEnabled
                                      : context.tr.statusDisabled,
                              statusColor:
                                  _adhanEnabled ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            PrayerSettingsCard(
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              icon: Icons.notifications_active_rounded,
                              iconColor: Colors.blue,
                              title: context.tr.autoPreReminder,
                              subtitle: context.tr.alert10MinBefore,
                              textColor: textColor,
                              subColor: subColor,
                              trailing: Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: _autoReminderEnabled,
                                  activeThumbColor: Colors.blue,
                                  onChanged: (bool value) {
                                    setModalState(() {});
                                    _toggleAutoReminder(value);
                                  },
                                ),
                              ),
                              statusText:
                                  _autoReminderEnabled
                                      ? context.tr.statusEnabled
                                      : context.tr.statusDisabled,
                              statusColor:
                                  _autoReminderEnabled
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            PrayerSettingsCard(
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              icon: Icons.timer_rounded,
                              iconColor: Colors.purple,
                              title: context.tr.autoIqama,
                              subtitle: context.tr.playIqama10MinAfter,
                              textColor: textColor,
                              subColor: subColor,
                              trailing: Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: _autoIqamaEnabled,
                                  activeThumbColor: Colors.purple,
                                  onChanged: (bool value) {
                                    setModalState(() {});
                                    _toggleAutoIqama(value);
                                  },
                                ),
                              ),
                              statusText:
                                  _autoIqamaEnabled
                                      ? context.tr.statusEnabled
                                      : context.tr.statusDisabled,
                              statusColor:
                                  _autoIqamaEnabled
                                      ? Colors.purple
                                      : Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Divider(color: borderCol, height: 1),
                            const SizedBox(height: 16),

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
                                          color: _gold.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.calculate_rounded,
                                          color: _gold,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        context.tr.calculationMethod,
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
                                    key: ValueKey<String>(currentMethod),
                                    isExpanded: true,
                                    dropdownColor: bg,
                                    initialValue: currentMethod,
                                    style: GoogleFonts.cairo(
                                      color: textColor,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          isDark
                                              ? Colors.white.withValues(
                                                alpha: 0.04,
                                              )
                                              : Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _gold.withValues(alpha: 0.15),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _gold.withValues(alpha: 0.15),
                                        ),
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: PrayerMethodCatalog.automaticKey,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.my_location_rounded,
                                              color: _gold,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                PrayerMethodCatalog.displayName(
                                                  PrayerMethodCatalog
                                                      .automaticKey,
                                                ),
                                                style: GoogleFonts.cairo(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًں•Œ ط§ظ„ط¬ط²ظٹط±ط© ط§ظ„ط¹ط±ط¨ظٹط© ظˆط§ظ„ط®ظ„ظٹط¬
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_gulf__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.mosque_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'الجزيرة العربية والخليج',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'umm_al_qura',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'أم القرى - السعودية واليمن',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'dubai',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'هيئة الشؤون الإسلامية - الإمارات',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'kuwait',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'وزارة الأوقاف - الكويت',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'qatar',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'قطر',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'gulf',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'منطقة الخليج - عُمان والبحرين',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒ™ ط´ظ…ط§ظ„ ط£ظپط±ظٹظ‚ظٹط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_africa__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.wb_sunny_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'شمال أفريقيا',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'egyptian',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'الهيئة المصرية - مصر والسودان وليبيا',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'morocco',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'وزارة الأوقاف - المغرب',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'algeria',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'وزارة الشؤون الدينية - الجزائر',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'tunisia',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'وزارة الشؤون الدينية - تونس',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // âکھï¸ڈ ط§ظ„ظ…ط´ط±ظ‚ ط§ظ„ط¹ط±ط¨ظٹ
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_levant__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'المشرق العربي',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'jordan',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'وزارة الأوقاف - الأردن وفلسطين',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'mwl',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'رابطة العالم الإسلامي - سوريا ولبنان والعراق',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒچ طھط±ظƒظٹط§ ظˆط¥ظٹط±ط§ظ†
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_turkey_iran__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'تركيا وإيران',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'turkey',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'الديانة التركية - Diyanet',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'tehran',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'معهد الجيوفيزياء - طهران',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًں•Œ ط¬ظ†ظˆط¨ ط¢ط³ظٹط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_south_asia__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.public_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'جنوب آسيا',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'karachi',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'جامعة كراتشي - باكستان والهند وأفغانستان',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒڈ ط¬ظ†ظˆط¨ ط´ط±ظ‚ ط¢ط³ظٹط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_sea__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.travel_explore_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'جنوب شرق آسيا',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'jakim',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'JAKIM - ماليزيا',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'kemenag',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'وزارة الشؤون الدينية - إندونيسيا',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'singapore',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'MUIS - سنغافورة وبروناي',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًں‡ھًں‡؛ ط£ظˆط±ظˆط¨ط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_europe__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.euro_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'أوروبا',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'france',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'الاتحاد الإسلامي الفرنسي - فرنسا',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'portugal',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'المجتمع الإسلامي - البرتغال',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'russia',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'الإدارة الدينية - روسيا وشرق أوروبا',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒژ ط£ظ…ط±ظٹظƒط§ ظˆط£ظˆظ‚ظٹط§ظ†ظˆط³ظٹط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_americas__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.language_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'أمريكا وأوقيانوسيا',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'isna',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'ISNA - أمريكا الشمالية وكندا',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒگ ط¹ط§ظ„ظ…ظٹ
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_global__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: _gold.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.hub_rounded,
                                                color: _gold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'عالمي',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _gold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'moonsighting',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            'لجنة رؤية الهلال - دقة عالية',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final updatedMessage =
                                            context.tr.prayerTimesUpdated;
                                        final failedMessage =
                                            'تعذر تحديث المواقيت. تحقق من الموقع والاتصال ثم حاول مرة أخرى.';
                                        setModalState(
                                          () => currentMethod = newValue,
                                        );
                                        final newTimes =
                                            await prayerTimesController
                                                .applyCalculationMethod(
                                                  newValue,
                                                );
                                        if (!mounted || !context.mounted) {
                                          return;
                                        }

                                        if (newTimes != null) {
                                          final resolvedMethod =
                                              prayerTimesController
                                                  .calculationMethod;
                                          setState(() {
                                            _currentCalculationMethod =
                                                resolvedMethod;
                                            _livePrayerTimes =
                                                Map<String, String>.from(
                                                  newTimes,
                                                );
                                            _buildPrayerRows();
                                          });
                                          if (_adhanEnabled) {
                                            await _rescheduleConfiguredPrayers();
                                          }
                                          setModalState(() {
                                            currentMethod =
                                                newValue ==
                                                        PrayerMethodCatalog
                                                            .automaticKey
                                                    ? PrayerMethodCatalog
                                                        .automaticKey
                                                    : resolvedMethod;
                                          });
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                updatedMessage,
                                                style: GoogleFonts.cairo(),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (context.mounted) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                failedMessage,
                                                style: GoogleFonts.cairo(),
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: _gold,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          PrayerMethodCatalog.explanation(
                                            currentMethod,
                                          ),
                                          style: GoogleFonts.cairo(
                                            color: subColor,
                                            fontSize: 11.5,
                                            height: 1.45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            GestureDetector(
                              onTap: () {
                                Navigator.pop(bottomSheetContext);
                                _runAdhanDiagnostic();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(
                                    alpha: isDark ? 0.08 : 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.blueAccent.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
                                            context.tr.checkPhoneReadiness,
                                            style: GoogleFonts.cairo(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            context
                                                .tr
                                                .discoverWhyAdhanNotWorking,
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
                                      color: Colors.blueAccent.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(
                                  alpha: isDark ? 0.08 : 0.05,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      context.tr.customizeEachPrayerNote,
                                      style: GoogleFonts.cairo(
                                        color: Colors.orange.withValues(
                                          alpha: 0.9,
                                        ),
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

  Future<void> _openCustomizeForPrayer(PrayerRow row) async {
    if (row.noAdhan == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr.sunriseNoAdhan, style: GoogleFonts.cairo()),
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
        return PrayerCustomizeSheet(
          row: row,
          initialConfig: config,
          currentMuezzinName: context.tr.t(_effectiveForKey(row.key).name),
          gold: _gold,

          // âœ… ط§ظ„ط¯ط§ظ„ط© ط§ظ„ظ…ط¹ط¯ظ‘ظ„ط© - طھطھط­ظ‚ظ‚ ظ…ظ† ط§ظ„طھط­ظ…ظٹظ„ ظ‚ط¨ظ„ ط§ظ„ط­ظپط¸
          // âœ… ط¨ط¹ط¯ - ظ†ظپط³ ط§ظ„ظ…ظ†ط·ظ‚ طھظ…ط§ظ…ط§ظ‹ ظ„ظƒظ† ظٹظڈط¹ظٹط¯ String?
          onChangeMuezzin: () async {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final selected = await showModalBottomSheet<MuezzinInfo?>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder:
                  (ctx) => MuezzinPickerSheet(
                    gold: _gold,
                    bg: isDark ? const Color(0xFF151B26) : Colors.white,
                    title: context.tr.customizeMuezzinFor(row.name),
                    currentId: _effectiveForKey(row.key).id,
                  ),
            );
            if (selected == null) return null; // âœ… ظپظ‚ط· null ط¨ط¯ظ„ return
            if (selected.id == '__DEFAULT__') {
              await MuezzinStore.clearCustomForPrayer(row.key);
            } else {
              await MuezzinStore.setCustomForPrayer(row.key, selected);
            }
            await _loadDefaultAndEffective();
            if (!mounted) return null;
            setState(() {});
            // âœ… ط£ط¹ط¯ ط§ظ„ط§ط³ظ… ط§ظ„ط¬ط¯ظٹط¯ ظپظˆط±ط§ظ‹
            return context.tr.t(_effectiveForKey(row.key).name);
          },

          onPreviewReminder: (soundName) => _previewReminderSound(soundName),
          onPreviewIqama: (soundId) => _previewIqamaSound(soundId),
          onSave: (newConfig) async {
            await _saveCustomizationQuick(row.key, newConfig);
            await _previewPlayer.stop();
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr.customizationSavedFor(row.name),
                          style: GoogleFonts.cairo(),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
            setState(() {});
            if (_adhanEnabled) {
              await _rescheduleConfiguredPrayers();
            }
          },
          onResetDefault: () async {
            final defaultConfig = PrayerCustomization.defaults();
            await _savePrayerCustomization(row.key, defaultConfig);
            await _previewPlayer.stop();
            setState(() {});
            if (_adhanEnabled) {
              await _rescheduleConfiguredPrayers();
            }
          },
        );
      },
    );
    await _previewPlayer.stop();
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
        await _rescheduleConfiguredPrayers();
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
                  side: BorderSide(
                    color: _gold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: _gold),
                    const SizedBox(width: 10),
                    Text(
                      context.tr.missingPermissions,
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
                        context.tr.enableFollowingSettings,
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!ignoresBattery)
                        _buildInstructionRow(
                          '1',
                          context.tr.batteryOptimizationExclusion,
                        ),
                      if (!hasExactAlarm)
                        _buildInstructionRow(
                          '2',
                          context.tr.alarmsAndReminders,
                        ),
                      if (!hasNotification)
                        _buildInstructionRow(
                          '3',
                          context.tr.allowNotifications,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr.xiaomiOppoNote,
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
                      context.tr.dialogCancel,
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _gold),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      _isWaitingForSettingsReturn = true;
                      if (!hasNotification) {
                        await Permission.notification.request();
                      }
                      if (!hasExactAlarm) {
                        await Permission.scheduleExactAlarm.request();
                      }
                      if (!ignoresBattery) {
                        await Permission.ignoreBatteryOptimizations.request();
                      }
                      await openAppSettings();
                    },
                    child: Text(
                      context.tr.goToSettings,
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
      await NativeAdhanBridge.cancelAllAlarms();
      await AdahnNotification.instance.cancelAll();
      if (!mounted) return;
      _showErrorSnackBar(context.tr.autoAdhanDisabled, isOrange: true);
    }
  }

  Future<void> _rescheduleConfiguredPrayers() async {
    if (!_adhanEnabled) return;
    await _scheduleAllAdhans();
    _scheduleInBackground();
  }

  void _showSuccessMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr.adhanScheduledSuccessfully,
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
    final schedule = await _calculateNext14DaysWithCustomization();
    if (schedule.isEmpty) {
      debugPrint('❌ Failed to calculate schedule');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('full_schedule_saved', false);
      return;
    }
    await NativeAdhanBridge.savePrayerSchedule(schedule: schedule);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('full_schedule_saved', true);
    await prefs.remove('prayer_schedule_needs_update');
    debugPrint('=== Scheduled ${schedule.length} days ===');
  }

  Future<List<Map<String, dynamic>>>
  _calculateNext14DaysWithCustomization() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_lat');
    final long = prefs.getDouble('last_long');
    if (lat == null || long == null) {
      debugPrint('❌ No location available');
      return [];
    }
    final methodId = PrayerMethodCatalog.apiId(_currentCalculationMethod);
    final List<Map<String, dynamic>> schedule = [];
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = PrayerClock.nowAt(_timeZoneId);
    const maxDays = 14;
    for (int monthOffset = 0; monthOffset < 2; monthOffset++) {
      final targetDate = DateTime(now.year, now.month + monthOffset, 1);
      try {
        final url = Uri.https(
          'api.aladhan.com',
          '/v1/calendar/${targetDate.year}/${targetDate.month}',
          {
            'latitude': '$lat',
            'longitude': '$long',
            'method': '$methodId',
            'school': '0',
            if (_timeZoneId.trim().isNotEmpty)
              'timezonestring': _timeZoneId.trim(),
          },
        );
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final days = data['data'] as List;
          for (final dayData in days) {
            final timings = Map<String, String>.from(dayData['timings']);
            final dateStr = dayData['date']['gregorian']['date'] as String;
            final parts = dateStr.split('-');
            final date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            if (date.isBefore(DateTime(now.year, now.month, now.day))) continue;
            final lastAllowedDate = DateTime(
              now.year,
              now.month,
              now.day + maxDays - 1,
            );
            if (date.isAfter(lastAllowedDate)) continue;
            schedule.add({
              'date': dateFormat.format(date),
              'fajr': await _buildPrayerCustomization(
                date,
                timings['Fajr']!,
                'Fajr',
              ),
              'sunrise': await _buildPrayerCustomization(
                date,
                timings['Sunrise']!,
                'Sunrise',
              ),
              'dhuhr': await _buildPrayerCustomization(
                date,
                timings['Dhuhr']!,
                'Dhuhr',
              ),
              'asr': await _buildPrayerCustomization(
                date,
                timings['Asr']!,
                'Asr',
              ),
              'maghrib': await _buildPrayerCustomization(
                date,
                timings['Maghrib']!,
                'Maghrib',
              ),
              'isha': await _buildPrayerCustomization(
                date,
                timings['Isha']!,
                'Isha',
              ),
            });
          }
        }
      } catch (e) {
        debugPrint('❌ Error fetching month ${targetDate.month}: $e');
      }
      if (schedule.length >= maxDays) break;
    }

    // Keep alarms available without a paid service and during API outages.
    // API results remain preferred; only missing dates are calculated locally.
    final scheduledDates = schedule.map((day) => day['date'] as String).toSet();
    for (var dayOffset = 0; dayOffset < maxDays; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      final dateKey = dateFormat.format(date);
      if (scheduledDates.contains(dateKey)) continue;
      try {
        final timings = PrayerMethodCatalog.calculateDay(
          latitude: lat,
          longitude: long,
          day: date,
          method: _currentCalculationMethod,
          timeZoneId: _timeZoneId,
        );
        schedule.add({
          'date': dateKey,
          'fajr': await _buildPrayerCustomization(
            date,
            timings['Fajr']!,
            'Fajr',
          ),
          'sunrise': await _buildPrayerCustomization(
            date,
            timings['Sunrise']!,
            'Sunrise',
          ),
          'dhuhr': await _buildPrayerCustomization(
            date,
            timings['Dhuhr']!,
            'Dhuhr',
          ),
          'asr': await _buildPrayerCustomization(date, timings['Asr']!, 'Asr'),
          'maghrib': await _buildPrayerCustomization(
            date,
            timings['Maghrib']!,
            'Maghrib',
          ),
          'isha': await _buildPrayerCustomization(
            date,
            timings['Isha']!,
            'Isha',
          ),
        });
      } catch (e) {
        debugPrint('❌ Local schedule calculation failed for $dateKey: $e');
      }
    }
    schedule.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );
    final trimmed = schedule.take(maxDays).toList();
    debugPrint('📅 Calculated ${trimmed.length} days');
    return trimmed;
  }

  Future<Map<String, dynamic>> _buildPrayerCustomization(
    DateTime date,
    String timeStr,
    String prayerKey,
  ) async {
    final config = _customizationFor(prayerKey);
    final muezzin = _effectiveForKey(prayerKey);
    final muezzinLocalPath =
        muezzin.isBuiltIn
            ? null
            : await AdhanAudioService.instance.getLocalPath(muezzin.id);
    return {
      'time': _parseToMillis(date, timeStr),
      'muezzinSound':
          muezzin.localSoundName.isNotEmpty ? muezzin.localSoundName : 'makkah',
      'muezzinLocalPath': muezzinLocalPath,
      'reminderEnabled': config.reminderEnabled,
      'reminderOffset': config.reminderOffset,
      'reminderSound': config.reminderSound,
      'reminderLocalPath': await _getReminderLocalPath(
        prayerKey,
        config.reminderSound,
      ),
      'iqamaEnabled': config.iqamaEnabled,
      'iqamaDelay': config.iqamaDelay,
      'iqamaSound': config.iqamaSound,
      'iqamaLocalPath': await _getIqamaLocalPath(prayerKey, config.iqamaSound),
    };
  }

  int _parseToMillis(DateTime date, String timeStr) {
    return PrayerClock.wallTime(
      date: date,
      time: timeStr,
      timeZoneId: _timeZoneId,
    ).millisecondsSinceEpoch;
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

  Widget _buildInstructionRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.2),
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

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // BUILD - Now uses extracted widgets
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = const Color(0xFFE6B325);
    final prayerController = context.watch<PrayerTimesController>();
    final cityName = prayerController.cityName;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F5F5);

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
      appBar: PrayerAppBar(
        cityName: cityName,
        adhanEnabled: _adhanEnabled,
        isDark: isDark,
        gold: gold,
        onRefreshLocation: () async {
          await context
              .read<PrayerTimesController>()
              .refreshLocationAndPrayerTimes(forceLocation: true);
          if (!mounted) return;
          _syncFromController();
        },
        onAdhanSettings: _showAdhanSettings,
        onMuezzinSettings: _openDefaultMuezzinSettings,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),

            if (!_hasResolvedLocation)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: gold.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'لم يتم تحديد موقع صالح بعد. فعّل إذن الموقع أو اضغط تحديث الموقع لعرض المواقيت الدقيقة.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ),

            if (!_hasResolvedLocation) const SizedBox(height: 16),

            // â•گâ•گâ•گ ط¨ط·ط§ظ‚ط© ط§ظ„طµظ„ط§ط© ط§ظ„ظ‚ط§ط¯ظ…ط© â•گâ•گâ•گ
            NextPrayerCard(
              prayerName: nextRow?.name,
              prayerTime: nextRow?.time,
              muezzinName: nextM == null ? null : context.tr.t(nextM.name),
              remainingTime: nextRemain,
              isDark: isDark,
              gold: gold,
              onListenAdhan: _playNextAdhanPreview,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrayerOSScreen(primary: Color(0xFFE6B325)),
                  ),
                );
              },
              child: Text("Prayer OS"),
            ),

            const SizedBox(height: 20),
            RadioMiniPlayer(gold: gold),
            const SizedBox(height: 20),

            // â•گâ•گâ•گ ط¹ظ†ظˆط§ظ† ط§ظ„ط¬ط¯ظˆظ„ â•گâ•گâ•گ
            PrayerScheduleHeader(
              nextPrayerName: nextRow?.name,
              isDark: isDark,
              gold: gold,
            ),

            const SizedBox(height: 16),

            // â•گâ•گâ•گ ظ‚ط§ط¦ظ…ط© ط§ظ„طµظ„ظˆط§طھ â•گâ•گâ•گ
            ..._rows.map((row) {
              final m = _effectiveForKey(row.key);
              final isDefaultMuezzin = _isPrayerUsingDefaultMuezzin(row.key);
              final config = _customizationFor(row.key);

              return PrayerRowCard(
                row: row,
                muezzinName: context.tr.t(m.name),
                isDefaultMuezzin: isDefaultMuezzin,
                config: config,
                isDark: isDark,
                gold: gold,
                onTap: () => _openCustomizeForPrayer(row),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
