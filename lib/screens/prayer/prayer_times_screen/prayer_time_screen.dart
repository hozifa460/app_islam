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

  late List<PrayerRow> _rows;
  int _currentIndex = -1;
  int _nextIndex = -1;

  Timer? _tick;

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Lifecycle
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
    _checkScheduleNeedsUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    if (state == AppLifecycleState.resumed && _isWaitingForSettingsReturn) {
      _isWaitingForSettingsReturn = false;
      _verifyPermissionsAfterReturn();
    }
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
      String prayerKey, String soundName) async {
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
      String key, PrayerCustomization config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_${key}_adhan_enabled', config.adhanEnabled);
    await prefs.setBool('prayer_${key}_reminder_enabled', config.reminderEnabled);
    await prefs.setInt('prayer_${key}_reminder_offset', config.reminderOffset);
    await prefs.setString('prayer_${key}_reminder_sound', config.reminderSound);
    await prefs.setBool('prayer_${key}_iqama_enabled', config.iqamaEnabled);
    await prefs.setInt('prayer_${key}_iqama_delay', config.iqamaDelay);
    await prefs.setString('prayer_${key}_iqama_sound', config.iqamaSound);
    _prayerCustomizations[key] = config;
    debugPrint('✅ Quick save: $key');
  }

  void _scheduleInBackground() {
    Future(() async {
      debugPrint('🔄 Background scheduling started...');
      final prefs = await SharedPreferences.getInstance();
      try {
        for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
          if (!mounted) {
            debugPrint('⚠️ Widget disposed, stopping background scheduling');
            return;
          }
          final config = _customizationFor(key);
          if (config.reminderEnabled) {
            final path =
            await _downloadReminderSoundIfNeeded(config.reminderSound);
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
        if (!mounted) return;
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
      }
    });
  }

  bool _isPrayerUsingDefaultMuezzin(String prayerKey) {
    final effective = _effectiveForKey(prayerKey);
    final defaultM = _defaultMuezzin ?? muezzinCatalog.first.items.first;
    return effective.id == defaultM.id;
  }

  /// âœ… طھط­ط¯ظٹط¯ ط·ط±ظٹظ‚ط© ط§ظ„ط­ط³ط§ط¨ ط¨ط­ط³ط¨ ط§ظ„ظ…ظˆظ‚ط¹
  String _getMethodByLocation(double lat, double lng) {
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط§ظ„ط¯ظˆظ„ ط§ظ„طµط؛ظٹط±ط© ط£ظˆظ„ط§ظ‹ (ظ„ظ…ظ†ط¹ ط§ظ„طھط¯ط§ط®ظ„)
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    // ط§ظ„ط¨ط­ط±ظٹظ†
    if (lat >= 25.5 && lat <= 26.4 && lng >= 50.3 && lng <= 50.9) {
      return 'gulf';
    }
    // ظ‚ط·ط±
    if (lat >= 24.4 && lat <= 26.3 && lng >= 50.7 && lng <= 51.7) {
      return 'qatar';
    }
    // ط³ظ†ط؛ط§ظپظˆط±ط©
    if (lat >= 1.15 && lat <= 1.48 && lng >= 103.6 && lng <= 104.1) {
      return 'singapore';
    }
    // ط¨ط±ظˆظ†ط§ظٹ
    if (lat >= 4.0 && lat <= 5.1 && lng >= 114.0 && lng <= 115.4) {
      return 'singapore';
    }
    // ظ„ط¨ظ†ط§ظ†
    if (lat >= 33.0 && lat <= 34.7 && lng >= 35.1 && lng <= 36.7) {
      return 'mwl';
    }
    // ظپظ„ط³ط·ظٹظ†
    if (lat >= 29.5 && lat <= 33.4 && lng >= 34.2 && lng <= 35.9) {
      return 'jordan';
    }
    // ط§ظ„ط£ط±ط¯ظ†
    if (lat >= 29.0 && lat <= 33.4 && lng >= 34.9 && lng <= 39.3) {
      return 'jordan';
    }
    // ط§ظ„ظƒظˆظٹطھ
    if (lat >= 28.5 && lat <= 30.1 && lng >= 46.5 && lng <= 48.5) {
      return 'kuwait';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط§ظ„ط¥ظ…ط§ط±ط§طھ (ظ‚ط¨ظ„ ط§ظ„ط³ط¹ظˆط¯ظٹط© ظ„ظ…ظ†ط¹ ط§ظ„طھط¯ط§ط®ظ„)
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= 22.5 && lat <= 26.5 && lng >= 51.0 && lng <= 56.5) {
      return 'dubai';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط§ظ„ط³ط¹ظˆط¯ظٹط©
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= 16.0 && lat <= 32.5 && lng >= 36.5 && lng <= 55.7) {
      return 'umm_al_qura';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط¹ظڈظ…ط§ظ† ظˆط§ظ„ظٹظ…ظ†
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // ط¹ظڈظ…ط§ظ†
    if (lat >= 16.5 && lat <= 26.4 && lng >= 52.0 && lng <= 60.0) {
      return 'gulf';
    }
    // ط§ظ„ظٹظ…ظ†
    if (lat >= 12.0 && lat <= 19.0 && lng >= 42.5 && lng <= 54.5) {
      return 'umm_al_qura';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط´ظ…ط§ظ„ ط£ظپط±ظٹظ‚ظٹط§ (ظ…ظ† ط§ظ„ط£طµط؛ط± ظ„ظ„ط£ظƒط¨ط±)
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    // طھظˆظ†ط³
    if (lat >= 30.2 && lat <= 37.4 && lng >= 7.5 && lng <= 11.6) {
      return 'tunisia';
    }
    // ظ…طµط±
    if (lat >= 22.0 && lat <= 31.7 && lng >= 24.7 && lng <= 36.9) {
      return 'egyptian';
    }
    // ظ„ظٹط¨ظٹط§
    if (lat >= 19.5 && lat <= 33.2 && lng >= 9.3 && lng <= 25.2) {
      return 'egyptian';
    }
    // ط§ظ„ط³ظˆط¯ط§ظ†
    if (lat >= 8.5 && lat <= 22.2 && lng >= 21.8 && lng <= 38.6) {
      return 'egyptian';
    }
    // ط§ظ„ظ…ط؛ط±ط¨
    if (lat >= 27.5 && lat <= 36.0 && lng >= -13.2 && lng <= -1.0) {
      return 'morocco';
    }
    // ط§ظ„ط¬ط²ط§ط¦ط±
    if (lat >= 18.5 && lat <= 37.5 && lng >= -8.7 && lng <= 12.0) {
      return 'algeria';
    }
    // ظ…ظˆط±ظٹطھط§ظ†ظٹط§
    if (lat >= 14.5 && lat <= 27.3 && lng >= -17.1 && lng <= -4.8) {
      return 'mwl';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط§ظ„ظ…ط´ط±ظ‚ ط§ظ„ط¹ط±ط¨ظٹ
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    // ط³ظˆط±ظٹط§
    if (lat >= 32.3 && lat <= 37.4 && lng >= 35.7 && lng <= 42.4) {
      return 'mwl';
    }
    // ط§ظ„ط¹ط±ط§ظ‚
    if (lat >= 29.0 && lat <= 37.4 && lng >= 38.8 && lng <= 48.6) {
      return 'mwl';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… طھط±ظƒظٹط§
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= 35.8 && lat <= 42.1 && lng >= 25.7 && lng <= 44.8) {
      return 'turkey';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط¥ظٹط±ط§ظ†
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= 25.0 && lat <= 39.8 && lng >= 44.0 && lng <= 63.4) {
      return 'tehran';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط¬ظ†ظˆط¨ ط¢ط³ظٹط§
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    // ط£ظپط؛ط§ظ†ط³طھط§ظ†
    if (lat >= 29.3 && lat <= 38.5 && lng >= 60.5 && lng <= 75.0) {
      return 'karachi';
    }
    // ط¨ط§ظƒط³طھط§ظ†
    if (lat >= 23.5 && lat <= 37.1 && lng >= 60.9 && lng <= 77.8) {
      return 'karachi';
    }
    // ط¨ظ†ط؛ظ„ط§ط¯ظٹط´
    if (lat >= 20.6 && lat <= 26.7 && lng >= 88.0 && lng <= 92.7) {
      return 'karachi';
    }
    // ط§ظ„ظ‡ظ†ط¯ ظˆط³ط±ظٹظ„ط§ظ†ظƒط§ ظˆظ†ظٹط¨ط§ظ„
    if (lat >= 6.7 && lat <= 35.7 && lng >= 68.1 && lng <= 97.4) {
      return 'karachi';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط¬ظ†ظˆط¨ ط´ط±ظ‚ ط¢ط³ظٹط§
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    // ظ…ط§ظ„ظٹط²ظٹط§
    if (lat >= 0.8 && lat <= 7.4 && lng >= 99.6 && lng <= 119.3) {
      return 'jakim';
    }
    // ط¥ظ†ط¯ظˆظ†ظٹط³ظٹط§
    if (lat >= -11.1 && lat <= 6.1 && lng >= 95.0 && lng <= 141.1) {
      return 'kemenag';
    }
    // ط§ظ„ظپظ„ط¨ظٹظ†
    if (lat >= 4.5 && lat <= 21.2 && lng >= 116.9 && lng <= 126.7) {
      return 'mwl';
    }
    // طھط§ظٹظ„ط§ظ†ط¯ ظˆظ…ظٹط§ظ†ظ…ط§ط± ظˆظƒظ…ط¨ظˆط¯ظٹط§ ظˆظپظٹطھظ†ط§ظ… ظˆظ„ط§ظˆط³
    if (lat >= 5.5 && lat <= 28.5 && lng >= 92.2 && lng <= 109.5) {
      return 'mwl';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ظˆط³ط· ط¢ط³ظٹط§ ظˆط§ظ„ظ‚ظˆظ‚ط§ط²
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    // ط£ط°ط±ط¨ظٹط¬ط§ظ†
    if (lat >= 38.4 && lat <= 41.9 && lng >= 44.8 && lng <= 50.4) {
      return 'russia';
    }
    // ظƒط§ط²ط§ط®ط³طھط§ظ† ظˆط£ظˆط²ط¨ظƒط³طھط§ظ† ظˆطھط±ظƒظ…ط§ظ†ط³طھط§ظ† ظˆط·ط§ط¬ظٹظƒط³طھط§ظ† ظˆظ‚ط±ط؛ظٹط²ط³طھط§ظ†
    if (lat >= 35.1 && lat <= 55.5 && lng >= 46.5 && lng <= 87.4) {
      return 'mwl';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط£ظˆط±ظˆط¨ط§ (ظ…ظ† ط§ظ„ط£طµط؛ط± ظ„ظ„ط£ظƒط¨ط±)
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

    // ط§ظ„ط¨ط±طھط؛ط§ظ„
    if (lat >= 36.9 && lat <= 42.2 && lng >= -9.5 && lng <= -6.2) {
      return 'portugal';
    }
    // ظپط±ظ†ط³ط§
    if (lat >= 41.3 && lat <= 51.1 && lng >= -5.2 && lng <= 9.6) {
      return 'france';
    }
    // ط§ظ„ط¨ظˆط³ظ†ط© ظˆظƒظˆط³ظˆظپظˆ ظˆط£ظ„ط¨ط§ظ†ظٹط§ ظˆظ…ظ‚ط¯ظˆظ†ظٹط§
    if (lat >= 39.6 && lat <= 45.3 && lng >= 13.4 && lng <= 22.0) {
      return 'mwl';
    }
    // ط±ظˆط³ظٹط§ ظˆط£ظˆظƒط±ط§ظ†ظٹط§ ظˆط¨ظٹظ„ط§ط±ظˆط³ظٹط§
    if (lat >= 44.0 && lat <= 71.5 && lng >= 22.0 && lng <= 180.0) {
      return 'russia';
    }
    // ط¨ط§ظ‚ظٹ ط£ظˆط±ظˆط¨ط§
    if (lat >= 35.0 && lat <= 71.5 && lng >= -25.0 && lng <= 45.0) {
      return 'mwl';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط£ظ…ط±ظٹظƒط§ ط§ظ„ط´ظ…ط§ظ„ظٹط© ظˆط§ظ„ظˆط³ط·ظ‰
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= 7.0 && lat <= 84.0 && lng >= -170.0 && lng <= -52.0) {
      return 'isna';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط£ظ…ط±ظٹظƒط§ ط§ظ„ط¬ظ†ظˆط¨ظٹط©
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= -56.0 && lat <= 13.0 && lng >= -82.0 && lng <= -34.0) {
      return 'mwl';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط£ظپط±ظٹظ‚ظٹط§ ط¬ظ†ظˆط¨ ط§ظ„طµط­ط±ط§ط،
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= -35.0 && lat <= 18.0 && lng >= -18.0 && lng <= 52.0) {
      return 'egyptian';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط£ظˆظ‚ظٹط§ظ†ظˆط³ظٹط§ (ط£ط³طھط±ط§ظ„ظٹط§ ظˆظ†ظٹظˆط²ظٹظ„ظ†ط¯ط§)
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= -48.0 && lat <= -10.0 && lng >= 113.0 && lng <= 179.0) {
      return 'mwl';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط§ظ„طµظٹظ† ظˆط§ظ„ظٹط§ط¨ط§ظ† ظˆظƒظˆط±ظٹط§ ظˆظ…ظ†ط؛ظˆظ„ظٹط§
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    if (lat >= 18.0 && lat <= 55.0 && lng >= 73.5 && lng <= 146.0) {
      return 'mwl';
    }

    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    // âœ… ط§ظ„ط§ظپطھط±ط§ط¶ظٹ
    // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
    return 'mwl';
  }

  Future<void> _loadCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();

    final manualMethod = prefs.getString('calc_method_manual');

    if (manualMethod != null) {
      _currentCalculationMethod = manualMethod;
    } else {
      final lat = prefs.getDouble('last_lat');
      final lng = prefs.getDouble('last_long');

      if (lat != null && lng != null) {
        _currentCalculationMethod = _getMethodByLocation(lat, lng);
      } else {
        _currentCalculationMethod = 'umm_al_qura';
      }

      await prefs.setString('calc_method', _currentCalculationMethod);
    }
  }

  Future<void> _bootstrap() async {
    await _loadCalculationMethod();

    // âœ… ط·ط¨ظ‘ظ‚ ط·ط±ظٹظ‚ط© ط§ظ„ط­ط³ط§ط¨ ط¹ظ„ظ‰ ط§ظ„ظ€ controller ظپظˆط±ط§ظ‹
    final prayerController = context.read<PrayerTimesController>();
    final newTimes = await prayerController
        .applyCalculationMethod(_currentCalculationMethod);

    await _loadDefaultAndEffective();
    await _loadPrayerCustomizations();

    // âœ… ط§ط³طھط®ط¯ظ… ط§ظ„ط£ظˆظ‚ط§طھ ط§ظ„ظ…ط­ط³ظˆط¨ط© ط§ظ„ط¬ط¯ظٹط¯ط© ط¥ط°ط§ طھظˆظپط±طھ
    if (newTimes != null) {
      _livePrayerTimes = Map<String, String>.from(newTimes);
    } else {
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
    }

    _buildPrayerRows();
    await _loadAdhanEnabled();

    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
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
      await _scheduleTodayImmediately();
      _scheduleInBackground();
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
            content: Text(context.tr.prayerTimesUpdatedAuto, style: GoogleFonts.cairo()),
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
          final downloaded =
          await AdhanAudioService.instance.downloadAndSave(m.id, m.url);
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
          content: Text(context.tr.muezzinSoundsNotDownloaded, style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
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
            content: Text(context.tr.adhanEnabledSuccessfully, style: GoogleFonts.cairo(fontSize: 13)),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      if (mounted) setState(() => _adhanEnabled = false);
      await prefs.setBool('adhan_enabled', false);
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
        prefs.getBool('prayer_${key}_reminder_enabled') ?? true,
        reminderOffset: prefs.getInt('prayer_${key}_reminder_offset') ?? 10,
        reminderSound:
        prefs.getString('prayer_${key}_reminder_sound') ?? 'hayalaaslah',
        iqamaEnabled: prefs.getBool('prayer_${key}_iqama_enabled') ?? false,
        iqamaDelay: prefs.getInt('prayer_${key}_iqama_delay') ?? 10,
        iqamaSound:
        prefs.getString('prayer_${key}_iqama_sound') ?? 'iqama1',
      );
      debugPrint(
          '📌 Loaded $key: adhan=${_prayerCustomizations[key]!.adhanEnabled}');
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
              reminderSound: 'hayalaaslah');
          await _saveCustomizationQuick(key, updated);
        }
      }
      if (_adhanEnabled) {
        await _scheduleTodayImmediately();
        _scheduleInBackground();
      }
      // ظ„ظ„ط±ط³ط§ظ„ط© ط§ظ„ط®ط¶ط±ط§ط،
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.tr.preReminderEnabled, style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ));
      }
    } else {
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final current = _customizationFor(key);
        final updated = current.copyWith(reminderEnabled: false);
        await _savePrayerCustomization(key, updated);
      }
      if (_adhanEnabled) {
        await _scheduleTodayImmediately();
        _scheduleInBackground();
      }
      // ظ„ظ„ط±ط³ط§ظ„ط© ط§ظ„ط¨ط±طھظ‚ط§ظ„ظٹط© (ظپظٹ ظ‚ط³ظ… else)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.tr.preReminderDisabledAll, style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ));
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
              iqamaSound: iqamaCatalog.first.id);
          await _saveCustomizationQuick(key, updated);
        }
      }
      if (_adhanEnabled) {
        await _scheduleTodayImmediately();
        _scheduleInBackground();
      }
      // ظ„ظ„ط±ط³ط§ظ„ط© ط§ظ„ط®ط¶ط±ط§ط،
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.tr.iqamaEnabled, style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ));
      }
    } else {
      for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final current = _customizationFor(key);
        final updated = current.copyWith(iqamaEnabled: false);
        await _savePrayerCustomization(key, updated);
      }
      if (_adhanEnabled) {
        await _scheduleTodayImmediately();
        _scheduleInBackground();
      }
      // ظ„ظ„ط±ط³ط§ظ„ط© ط§ظ„ط¨ط±طھظ‚ط§ظ„ظٹط© (ظپظٹ ظ‚ط³ظ… else)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.tr.iqamaDisabledAll, style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ));
      }
    }
    setState(() {});
  }

  Future<void> _savePrayerCustomization(
      String key, PrayerCustomization config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_${key}_adhan_enabled', config.adhanEnabled);
    await prefs.setBool(
        'prayer_${key}_reminder_enabled', config.reminderEnabled);
    await prefs.setInt('prayer_${key}_reminder_offset', config.reminderOffset);
    await prefs.setString(
        'prayer_${key}_reminder_sound', config.reminderSound);
    await prefs.setBool('prayer_${key}_iqama_enabled', config.iqamaEnabled);
    await prefs.setInt('prayer_${key}_iqama_delay', config.iqamaDelay);
    await prefs.setString('prayer_${key}_iqama_sound', config.iqamaSound);
    if (config.reminderEnabled) {
      final localPath =
      await _downloadReminderSoundIfNeeded(config.reminderSound);
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
    final times = _livePrayerTimes.isNotEmpty
        ? _livePrayerTimes
        : {
      'Fajr': '05:30', 'Sunrise': '06:45', 'Dhuhr': '12:15',
      'Asr': '15:45', 'Maghrib': '18:20', 'Isha': '19:45',
    };
    final now = DateTime.now();
    _rows = [
      PrayerRow(key: 'Fajr', name: context.tr.prayerFajr, time: times['Fajr'] ?? '05:30', icon: Icons.wb_twilight),
      PrayerRow(key: 'Sunrise', name: context.tr.prayerSunrise, time: times['Sunrise'] ?? '06:45', icon: Icons.wb_sunny_outlined, noAdhan: true),
      PrayerRow(key: 'Dhuhr', name: context.tr.prayerDhuhr, time: times['Dhuhr'] ?? '12:15', icon: Icons.sunny),
      PrayerRow(key: 'Asr', name: context.tr.prayerAsr, time: times['Asr'] ?? '15:45', icon: Icons.filter_drama),
      PrayerRow(key: 'Maghrib', name: context.tr.prayerMaghrib, time: times['Maghrib'] ?? '18:20', icon: Icons.nights_stay),
      PrayerRow(key: 'Isha', name: context.tr.prayerIsha, time: times['Isha'] ?? '19:45', icon: Icons.star_rounded),
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
      builder: (ctx) => PrayerDiagnosticDialog(
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
    String currentMethod = _currentCalculationMethod;
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
            final cardBg = isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50;
            final borderCol = isDark
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
                                  activeColor: _gold,
                                  onChanged: (bool value) {
                                    Navigator.pop(context);
                                    _toggleAdhan(value);
                                  },
                                ),
                              ),
                              statusText: _adhanEnabled
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
                                  activeColor: Colors.blue,
                                  onChanged: (bool value) {
                                    setModalState(() {});
                                    _toggleAutoReminder(value);
                                  },
                                ),
                              ),
                              statusText: _autoReminderEnabled
                                  ? context.tr.statusEnabled
                                  : context.tr.statusDisabled,
                              statusColor:
                              _autoReminderEnabled ? Colors.blue : Colors.grey,
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
                                  activeColor: Colors.purple,
                                  onChanged: (bool value) {
                                    setModalState(() {});
                                    _toggleAutoIqama(value);
                                  },
                                ),
                              ),
                              statusText: _autoIqamaEnabled
                                  ? context.tr.statusEnabled
                                  : context.tr.statusDisabled,
                              statusColor: _autoIqamaEnabled
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
                                          borderRadius: BorderRadius.circular(10),
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
                                    isExpanded: true,
                                    dropdownColor: bg,
                                    value: currentMethod,
                                    style: GoogleFonts.cairo(color: textColor, fontSize: 13),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: _gold.withValues(alpha: 0.15)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: _gold.withValues(alpha: 0.15)),
                                      ),
                                    ),
                                    items: [
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًں•Œ ط§ظ„ط¬ط²ظٹط±ط© ط§ظ„ط¹ط±ط¨ظٹط© ظˆط§ظ„ط®ظ„ظٹط¬
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_gulf__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.mosque_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('أم القرى - السعودية واليمن',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'dubai',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('هيئة الشؤون الإسلامية - الإمارات',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'kuwait',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('وزارة الأوقاف - الكويت',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'qatar',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('قطر',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'gulf',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('منطقة الخليج - عُمان والبحرين',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒ™ ط´ظ…ط§ظ„ ط£ظپط±ظٹظ‚ظٹط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_africa__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.wb_sunny_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('الهيئة المصرية - مصر والسودان وليبيا',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'morocco',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('وزارة الأوقاف - المغرب',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'algeria',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('وزارة الشؤون الدينية - الجزائر',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'tunisia',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('وزارة الشؤون الدينية - تونس',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // âکھï¸ڈ ط§ظ„ظ…ط´ط±ظ‚ ط§ظ„ط¹ط±ط¨ظٹ
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_levant__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('وزارة الأوقاف - الأردن وفلسطين',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'mwl',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('رابطة العالم الإسلامي - سوريا ولبنان والعراق',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒچ طھط±ظƒظٹط§ ظˆط¥ظٹط±ط§ظ†
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_turkey_iran__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.location_on_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('الديانة التركية - Diyanet',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'tehran',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('معهد الجيوفيزياء - طهران',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًں•Œ ط¬ظ†ظˆط¨ ط¢ط³ظٹط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_south_asia__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.public_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('جامعة كراتشي - باكستان والهند وأفغانستان',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒڈ ط¬ظ†ظˆط¨ ط´ط±ظ‚ ط¢ط³ظٹط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_sea__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.travel_explore_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('JAKIM - ماليزيا',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'kemenag',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('وزارة الشؤون الدينية - إندونيسيا',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'singapore',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('MUIS - سنغافورة وبروناي',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًں‡ھًں‡؛ ط£ظˆط±ظˆط¨ط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_europe__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.euro_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('الاتحاد الإسلامي الفرنسي - فرنسا',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'portugal',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('المجتمع الإسلامي - البرتغال',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'russia',
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('الإدارة الدينية - روسيا وشرق أوروبا',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒژ ط£ظ…ط±ظٹظƒط§ ظˆط£ظˆظ‚ظٹط§ظ†ظˆط³ظٹط§
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_americas__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.language_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('ISNA - أمريكا الشمالية وكندا',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),

                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      // ًںŒگ ط¹ط§ظ„ظ…ظٹ
                                      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                                      DropdownMenuItem(
                                        enabled: false,
                                        value: '__header_global__',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: _gold.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.hub_rounded, color: _gold, size: 14),
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
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Text('لجنة رؤية الهلال - دقة عالية',
                                              style: GoogleFonts.cairo(fontSize: 13)),
                                        ),
                                      ),
                                    ],
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        setModalState(() => currentMethod = newValue);
                                        setState(() => _currentCalculationMethod = newValue);
                                        await prefs.setString('calc_method_manual', newValue);
                                        await prefs.setString('calc_method', newValue);

                                        final newTimes = await prayerTimesController
                                            .applyCalculationMethod(newValue);

                                        if (newTimes != null && mounted) {
                                          setState(() {
                                            _livePrayerTimes = Map<String, String>.from(newTimes);
                                            _buildPrayerRows();
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(context.tr.prayerTimesUpdated,
                                                  style: GoogleFonts.cairo()),
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

                            GestureDetector(
                              onTap: () {
                                Navigator.pop(bottomSheetContext);
                                _runAdhanDiagnostic();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(alpha: 
                                      isDark ? 0.08 : 0.05),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.blueAccent.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withValues(alpha: 0.12),
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
                                            context.tr.discoverWhyAdhanNotWorking,
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
                                      color: Colors.blueAccent.withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 
                                    isDark ? 0.08 : 0.05),
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
                                        color: Colors.orange.withValues(alpha: 0.9),
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
              builder: (ctx) => MuezzinPickerSheet(
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
            setState(() {});
            // âœ… ط£ط¹ط¯ ط§ظ„ط§ط³ظ… ط§ظ„ط¬ط¯ظٹط¯ ظپظˆط±ط§ظ‹
            return context.tr.t(_effectiveForKey(row.key).name);
          },

          onPreviewReminder: (soundName) => _previewReminderSound(soundName),
          onPreviewIqama: (soundId) => _previewIqamaSound(soundId),
          onSave: (newConfig) async {
            await _saveCustomizationQuick(row.key, newConfig);
            await _previewPlayer.stop();
            if (mounted) Navigator.pop(ctx);
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
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
            setState(() {});
            if (_adhanEnabled) {
              await _scheduleTodayImmediately();
              _scheduleInBackground();
            }
          },
          onResetDefault: () async {
            final defaultConfig = PrayerCustomization.defaults();
            await _savePrayerCustomization(row.key, defaultConfig);
            await _previewPlayer.stop();
            setState(() {});
          },
        );
      },
    );
    await _previewPlayer.stop();
  }

  void _showMuezzinNotDownloadedDialog(MuezzinInfo muezzin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF151B26) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: _gold.withValues(alpha: 0.3)),
        ),
        // âœ… ط§ظ„ط£ظٹظ‚ظˆظ†ط©
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.download_rounded,
            color: Colors.orange,
            size: 40,
          ),
        ),
        // âœ… ط§ظ„ط¹ظ†ظˆط§ظ†
        title: Text(
          'المؤذن غير محمّل',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        // âœ… ط§ظ„ظ…ط­طھظˆظ‰
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ط§ط³ظ… ط§ظ„ظ…ط¤ط°ظ†
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _gold.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_rounded,
                      color: _gold, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      muezzin.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _gold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ط§ظ„ط±ط³ط§ظ„ط©
            Text(
              'يجب تحميل هذا المؤذن أولاً من شاشة إعدادات الأذان قبل أن تتمكن من تخصيصه لصلاة معينة.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 12),

            // ط®ط·ظˆط§طھ
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  _buildStep(
                    '1',
                    'اذهب إلى إعدادات الأذان',
                    Icons.settings_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildStep(
                    '2',
                    'اختر الفئة ثم المؤذن',
                    Icons.category_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildStep(
                    '3',
                    'اضغط زر التحميل',
                    Icons.download_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildStep(
                    '4',
                    'ارجع وخصّصه للصلاة',
                    Icons.check_circle_rounded,
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
        // âœ… ط§ظ„ط£ط²ط±ط§ط±
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // ط²ط± ط¥ظ„ط؛ط§ط،
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ط²ط± ط§ظ„ط°ظ‡ط§ط¨ ظ„ط¥ط¹ط¯ط§ط¯ط§طھ ط§ظ„ط£ط°ط§ظ†
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _openDefaultMuezzinSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.settings_rounded, size: 18),
            label: Text(
              'إعدادات الأذان',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

// âœ… ط®ط·ظˆط© ظپظٹ ط§ظ„طھط¹ظ„ظٹظ…ط§طھ
  Widget _buildStep(
      String number, String text, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _gold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: _gold.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openDefaultMuezzinSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MuezzinSettingsScreen(primaryColor: widget.primaryColor),
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
        await _scheduleTodayImmediately();
        _showSuccessMessage();
        _scheduleInBackground();
        return;
      }
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: _bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _gold.withValues(alpha: 0.3), width: 1),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: _gold),
                const SizedBox(width: 10),
                Text(
                  context.tr.missingPermissions,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  if (!ignoresBattery)
                    _buildInstructionRow('1', context.tr.batteryOptimizationExclusion),
                  if (!hasExactAlarm)
                    _buildInstructionRow('2', context.tr.alarmsAndReminders),
                  if (!hasNotification)
                    _buildInstructionRow('3', context.tr.allowNotifications),
                  const SizedBox(height: 10),
                  Text(
                    context.tr.xiaomiOppoNote,
                    style: GoogleFonts.cairo(color: Colors.orange, fontSize: 11),
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
                child: Text(context.tr.dialogCancel, style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              ElevatedButton(
                style:
                ElevatedButton.styleFrom(backgroundColor: _gold),
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
                    await Permission.ignoreBatteryOptimizations
                        .request();
                  }
                  await openAppSettings();
                },
                child: Text(
                  context.tr.goToSettings,
                  style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold),
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
      _showErrorSnackBar(context.tr.autoAdhanDisabled, isOrange: true);
    }
  }

  Future<void> _scheduleTodayImmediately() async {
    debugPrint('⚡ Scheduling TODAY immediately...');
    final now = DateTime.now();
    const int todayDayIndex = 0;
    for (final row in _rows) {
      if (row.noAdhan == true) continue;
      final config = _customizationFor(row.key);
      if (!config.adhanEnabled) continue;
      final prayerIndex = NativeAdhanBridge.prayerIndices[row.key] ?? 0;
      final prayerTime = row.dateTime;
      if (now.isAfter(prayerTime)) {
        debugPrint('⏭️ Skipping ${row.name} - passed');
        continue;
      }
      final m = _effectiveForKey(row.key);
      final local = m.isBuiltIn
          ? null
          : await AdhanAudioService.instance.getLocalPath(m.id);
      final adhanSound =
      m.localSoundName.isNotEmpty ? m.localSoundName : 'makkah';
      final adhanCode = NativeAdhanBridge.generateRequestCode(
          todayDayIndex, prayerIndex, 0);
      final reminderCode = NativeAdhanBridge.generateRequestCode(
          todayDayIndex, prayerIndex, 1);
      final iqamaCode = NativeAdhanBridge.generateRequestCode(
          todayDayIndex, prayerIndex, 2);
      debugPrint('📢 Adhan: ${row.name} at $prayerTime (code=$adhanCode)');
      await NativeAdhanBridge.scheduleAdhan(
        time: prayerTime,
        prayerName: row.name,
        requestCode: adhanCode,
        soundName: adhanSound,
        localPath: local,
      );
      if (config.reminderEnabled && config.reminderOffset > 0) {
        final reminderTime =
        prayerTime.subtract(Duration(minutes: config.reminderOffset));
        if (reminderTime.isAfter(now)) {
          final reminderLocalPath = await _getReminderLocalPath(
              row.key, config.reminderSound);
          debugPrint(
              '🔔 Reminder: ${row.name} at $reminderTime (code=$reminderCode)');
          await NativeAdhanBridge.scheduleReminder(
            time: reminderTime,
            prayerName: row.name,
            requestCode: reminderCode,
            soundName: config.reminderSound,
            localPath: reminderLocalPath,
          );
        }
      }
      if (config.iqamaEnabled && config.iqamaDelay > 0) {
        final iqamaTime =
        prayerTime.add(Duration(minutes: config.iqamaDelay));
        if (iqamaTime.isAfter(now)) {
          final iqamaLocalPath =
          await _getIqamaLocalPath(row.key, config.iqamaSound);
          debugPrint(
              '🕌 Iqama: ${row.name} at $iqamaTime (code=$iqamaCode)');
          await NativeAdhanBridge.scheduleIqama(
            time: iqamaTime,
            prayerName: row.name,
            requestCode: iqamaCode,
            soundName: config.iqamaSound,
            localPath: iqamaLocalPath,
          );
        }
      }
    }
    debugPrint('✅ Today scheduled!');
  }

  void _showSuccessMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr.adhanScheduledSuccessfully, style: GoogleFonts.cairo()),
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
      return;
    }
    await NativeAdhanBridge.savePrayerSchedule(schedule: schedule);
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
    int methodId = 4;
    switch (_currentCalculationMethod) {
      case 'umm_al_qura': methodId = 4;  break;
      case 'egyptian':    methodId = 5;  break;
      case 'mwl':         methodId = 3;  break;
      case 'isna':        methodId = 2;  break;
      case 'karachi':     methodId = 1;  break;
      case 'tehran':      methodId = 7;  break;
      case 'gulf':        methodId = 8;  break;
      case 'kuwait':      methodId = 9;  break;
      case 'qatar':       methodId = 10; break;
      case 'singapore':   methodId = 11; break;
      case 'france':      methodId = 12; break;
      case 'turkey':      methodId = 13; break;
      case 'russia':      methodId = 14; break;
      case 'moonsighting':methodId = 15; break;
      case 'dubai':       methodId = 16; break;
      case 'jakim':       methodId = 17; break;
      case 'tunisia':     methodId = 18; break;
      case 'algeria':     methodId = 19; break;
      case 'kemenag':     methodId = 20; break;
      case 'morocco':     methodId = 21; break;
      case 'portugal':    methodId = 22; break;
      case 'jordan':      methodId = 23; break;
      default:            methodId = 3;  break;
    }
    final List<Map<String, dynamic>> schedule = [];
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    const maxDays = 14;
    for (int monthOffset = 0; monthOffset < 2; monthOffset++) {
      final targetDate =
      DateTime(now.year, now.month + monthOffset, 1);
      try {
        final url = Uri.parse(
            'https://api.aladhan.com/v1/calendar/${targetDate.year}/${targetDate.month}?latitude=$lat&longitude=$long&method=$methodId');
        final response =
        await http.get(url).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final days = data['data'] as List;
          for (final dayData in days) {
            final timings =
            Map<String, String>.from(dayData['timings']);
            final dateStr =
            dayData['date']['gregorian']['date'] as String;
            final parts = dateStr.split('-');
            final date = DateTime(int.parse(parts[2]),
                int.parse(parts[1]), int.parse(parts[0]));
            if (date.isBefore(
                DateTime(now.year, now.month, now.day))) continue;
            if (date.difference(now).inDays > maxDays) continue;
            schedule.add({
              'date': dateFormat.format(date),
              'fajr': await _buildPrayerCustomization(
                  date, timings['Fajr']!, 'Fajr'),
              'sunrise': await _buildPrayerCustomization(
                  date, timings['Sunrise']!, 'Sunrise'),
              'dhuhr': await _buildPrayerCustomization(
                  date, timings['Dhuhr']!, 'Dhuhr'),
              'asr': await _buildPrayerCustomization(
                  date, timings['Asr']!, 'Asr'),
              'maghrib': await _buildPrayerCustomization(
                  date, timings['Maghrib']!, 'Maghrib'),
              'isha': await _buildPrayerCustomization(
                  date, timings['Isha']!, 'Isha'),
            });
          }
        }
      } catch (e) {
        debugPrint('❌ Error fetching month ${targetDate.month}: $e');
      }
      if (schedule.length >= maxDays) break;
    }
    schedule.sort(
            (a, b) => (a['date'] as String).compareTo(b['date'] as String));
    final trimmed = schedule.take(maxDays).toList();
    debugPrint('📅 Calculated ${trimmed.length} days');
    return trimmed;
  }

  Future<Map<String, dynamic>> _buildPrayerCustomization(
      DateTime date, String timeStr, String prayerKey) async {
    final config = _customizationFor(prayerKey);
    final muezzin = _effectiveForKey(prayerKey);
    final muezzinLocalPath = muezzin.isBuiltIn
        ? null
        : await AdhanAudioService.instance.getLocalPath(muezzin.id);
    return {
      'time': _parseToMillis(date, timeStr),
      'muezzinSound': muezzin.localSoundName.isNotEmpty
          ? muezzin.localSoundName
          : 'makkah',
      'muezzinLocalPath': muezzinLocalPath,
      'reminderEnabled': config.reminderEnabled,
      'reminderOffset': config.reminderOffset,
      'reminderSound': config.reminderSound,
      'reminderLocalPath':
      await _getReminderLocalPath(prayerKey, config.reminderSound),
      'iqamaEnabled': config.iqamaEnabled,
      'iqamaDelay': config.iqamaDelay,
      'iqamaSound': config.iqamaSound,
      'iqamaLocalPath':
      await _getIqamaLocalPath(prayerKey, config.iqamaSound),
    };
  }

  int _parseToMillis(DateTime date, String timeStr) {
    final clean = timeStr.split(' ').first;
    final parts = clean.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, h, m)
        .millisecondsSinceEpoch;
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
        builder: (_) => AdhanPlayerScreen(
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
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style:
                GoogleFonts.cairo(color: Colors.white, fontSize: 14)),
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
    final bgColor =
    isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F5F5);

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
              .refreshLocationAndPrayerTimes();
          if (!mounted) return;
          setState(() {
            _livePrayerTimes = Map<String, String>.from(
              context.read<PrayerTimesController>().prayerTimes,
            );
            _buildPrayerRows();
          });
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
                    builder: (_) => PrayerOSScreen(primary: Color(0xFFE6B325,),
                  ),
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
              final isDefaultMuezzin =
              _isPrayerUsingDefaultMuezzin(row.key);
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