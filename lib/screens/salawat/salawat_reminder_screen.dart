import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../languages/app_localizations.dart';
import '../../services/native_adhan_bridge.dart';

import 'widgets/salawat_theme.dart';
import 'widgets/salawat_sliver_header.dart';
import 'widgets/salawat_toggle_card.dart';
import 'widgets/salawat_interval_card.dart';
import 'widgets/salawat_sound_card.dart';
import 'widgets/salawat_downloading_card.dart';
import 'widgets/salawat_status_card.dart';
import 'widgets/salawat_hadith_card.dart';

class SalawatReminderScreen extends StatefulWidget {
  final Color primaryColor;

  const SalawatReminderScreen({
    super.key,
    required this.primaryColor,
  });

  @override
  State<SalawatReminderScreen> createState() => _SalawatReminderScreenState();
}

class _SalawatReminderScreenState extends State<SalawatReminderScreen>
    with TickerProviderStateMixin {
  bool _enabled = false;
  int _minutes = 30;
  final AudioPlayer _previewPlayer = AudioPlayer();
  String _selectedSound = 'saly';
  String? _localSoundPath;
  bool _isDownloading = false;

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _loadPrefs();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }

  void _updatePulseAnimation() {
    if (_enabled) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('salawat_enabled') ?? false;
    final minutes = prefs.getInt('salawat_interval_minutes') ?? 30;
    final selectedSound = prefs.getString('salawat_sound') ?? 'saly';
    final localPath = prefs.getString('salawat_local_path');

    setState(() {
      _enabled = enabled;
      _minutes = minutes;
      _selectedSound = selectedSound;
      _localSoundPath = localPath;
    });

    _updatePulseAnimation();

    if (_localSoundPath == null || !File(_localSoundPath!).existsSync()) {
      final downloadedPath = await _downloadSoundIfNeeded(_selectedSound);
      if (downloadedPath != null) {
        setState(() => _localSoundPath = downloadedPath);
        await _savePrefs();
      }
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('salawat_enabled', _enabled);
    await prefs.setInt('salawat_interval_minutes', _minutes);
    await prefs.setString('salawat_sound', _selectedSound);
    if (_localSoundPath != null) {
      await prefs.setString('salawat_local_path', _localSoundPath!);
    } else {
      await prefs.remove('salawat_local_path');
    }
  }

  Future<String?> _downloadSoundIfNeeded(String soundName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory('${dir.path}/salawat_sounds');
      if (!await soundsDir.exists()) {
        await soundsDir.create(recursive: true);
      }
      final filePath = '${soundsDir.path}/$soundName.mp3';
      final file = File(filePath);
      if (await file.exists()) return file.path;

      final url =
          'https://raw.githubusercontent.com/hozifa460/islamic-audios/main/salah_ala_alnby/$soundName.mp3';

      if (mounted) setState(() => _isDownloading = true);

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        debugPrint('فشل تحميل الصوت: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('خطأ أثناء تحميل صوت التذكير: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _previewReminderSound(String soundName) async {
    try {
      final url =
          'https://raw.githubusercontent.com/hozifa460/islamic-audios/main/salah_ala_alnby/$soundName.mp3';
      await _previewPlayer.stop();
      await _previewPlayer.setUrl(url);
      await _previewPlayer.play();
    } catch (e) {
      debugPrint('Salawat preview sound error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.previewSalawatFailed, style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scheduleReminder() async {
    String? path = _localSoundPath;
    if (path == null || !File(path).existsSync()) {
      path = await _downloadSoundIfNeeded(_selectedSound);
      if (path != null) {
        setState(() => _localSoundPath = path);
        await _savePrefs();
      }
    }
    await NativeAdhanBridge.scheduleSalawatReminder(
      startTime: DateTime.now().add(Duration(minutes: _minutes)),
      interval: Duration(minutes: _minutes),
      soundName: _selectedSound,
      localPath: _localSoundPath,
    );
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      setState(() => _enabled = true);
      _updatePulseAnimation();
      await _savePrefs();

      final downloadedPath = await _downloadSoundIfNeeded(_selectedSound);
      if (downloadedPath == null) {
        setState(() => _enabled = false);
        _updatePulseAnimation();
        await _savePrefs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr.downloadSalawatFailed, style: GoogleFonts.cairo()),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() => _localSoundPath = downloadedPath);
      await _savePrefs();
      await _scheduleReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.salawatReminderActivated(_minutes), style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() => _enabled = false);
      _updatePulseAnimation();
      await _savePrefs();
      await NativeAdhanBridge.cancelSalawatReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.salawatReminderDeactivated, style: GoogleFonts.cairo()),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _updateInterval(int minutes) async {
    setState(() => _minutes = minutes);
    await _savePrefs();

    if (_enabled) {
      await NativeAdhanBridge.cancelSalawatReminder();
      await _scheduleReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.salawatIntervalUpdated(_minutes), style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _changeSound(String val) async {
    setState(() {
      _selectedSound = val;
      _localSoundPath = null;
    });
    await _savePrefs();
    await _previewReminderSound(val);

    final downloadedPath = await _downloadSoundIfNeeded(val);
    if (downloadedPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.downloadNewSoundFailed, style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _localSoundPath = downloadedPath);
    await _savePrefs();

    if (_enabled) {
      await NativeAdhanBridge.cancelSalawatReminder();
      await _scheduleReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.salawatSoundChangedSuccess, style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════
  // BUILD — uses extracted widgets
  // ══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final theme = SalawatTheme(
      isDark: isDark,
      primaryColor: widget.primaryColor,
    );

    return Directionality(
      textDirection: context.tr.textDirection,
      child: Scaffold(
        backgroundColor: theme.bgColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ───
            SalawatSliverHeader(
              theme: theme,
              enabled: _enabled,
              pulseAnimation: _pulseAnimation,
              glowAnimation: _glowAnimation,
              floatAnimation: _floatAnimation,
            ),

            // ─── Body Content ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SalawatTheme.horizontalPadding,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    // ═══ Toggle Card ═══
                    SalawatToggleCard(
                      theme: theme,
                      enabled: _enabled,
                      isDownloading: _isDownloading,
                      onChanged: _toggleReminder,
                    ),

                    const SizedBox(height: SalawatTheme.sectionSpacing),

                    // ═══ Interval Card ═══
                    SalawatIntervalCard(
                      theme: theme,
                      selectedMinutes: _minutes,
                      isDownloading: _isDownloading,
                      onIntervalChanged: _updateInterval,
                    ),

                    const SizedBox(height: SalawatTheme.sectionSpacing),

                    // ═══ Sound Card ═══
                    SalawatSoundCard(
                      theme: theme,
                      selectedSound: _selectedSound,
                      isDownloading: _isDownloading,
                      onSoundChanged: _changeSound,
                    ),

                    // ═══ Downloading indicator ═══
                    if (_isDownloading) ...[
                      const SizedBox(
                          height: SalawatTheme.sectionSpacing),
                      SalawatDownloadingCard(theme: theme),
                    ],

                    const SizedBox(height: SalawatTheme.sectionSpacing),

                    // ═══ Status Card ═══
                    SalawatStatusCard(
                      theme: theme,
                      enabled: _enabled,
                      minutes: _minutes,
                    ),

                    const SizedBox(height: 24),

                    // ═══ Hadith Card ═══
                    SalawatHadithCard(theme: theme),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}