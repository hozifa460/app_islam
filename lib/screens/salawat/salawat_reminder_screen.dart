import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../services/native_adhan_bridge.dart';

class SalawatReminderScreen extends StatefulWidget {
  final Color primaryColor;

  const SalawatReminderScreen({
    super.key,
    required this.primaryColor,
  });

  @override
  State<SalawatReminderScreen> createState() => _SalawatReminderScreenState();
}

class _SalawatReminderScreenState extends State<SalawatReminderScreen> {
  bool _enabled = false;
  int _minutes = 30;
  final AudioPlayer _previewPlayer = AudioPlayer();
  String _selectedSound = 'saly';
  String? _localSoundPath;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
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

    if (_localSoundPath == null || !File(_localSoundPath!).existsSync()) {
      final downloadedPath = await _downloadSoundIfNeeded(_selectedSound);
      if (downloadedPath != null) {
        setState(() {
          _localSoundPath = downloadedPath;
        });
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

      if (await file.exists()) {
        return file.path;
      }

      final url =
          'https://raw.githubusercontent.com/hozifa460/islamic-audios/main/salah_ala_alnby/$soundName.mp3';

      if (mounted) {
        setState(() {
          _isDownloading = true;
        });
      }

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
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
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
            content: Text(
              'تعذر تشغيل المعاينة الصوتية',
              style: GoogleFonts.cairo(),
            ),
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
        setState(() {
          _localSoundPath = path;
        });
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
      await _savePrefs();

      final downloadedPath = await _downloadSoundIfNeeded(_selectedSound);

      if (downloadedPath == null) {
        setState(() => _enabled = false);
        await _savePrefs();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'فشل تحميل صوت التذكير. تأكد من الإنترنت ثم حاول مرة أخرى',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _localSoundPath = downloadedPath;
      });
      await _savePrefs();

      await _scheduleReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تفعيل التذكير كل $_minutes دقيقة',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() => _enabled = false);
      await _savePrefs();

      await NativeAdhanBridge.cancelSalawatReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إيقاف التذكير',
              style: GoogleFonts.cairo(),
            ),
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
            content: Text(
              'تم تحديث التكرار إلى كل $_minutes دقيقة',
              style: GoogleFonts.cairo(),
            ),
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
            content: Text(
              'فشل تحميل الصوت الجديد',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _localSoundPath = downloadedPath;
    });
    await _savePrefs();

    if (_enabled) {
      await NativeAdhanBridge.cancelSalawatReminder();
      await _scheduleReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تغيير صوت التذكير بنجاح',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF7F6F2);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: widget.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الصلاة على النبي ﷺ',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'فعّل التذكير بالصلاة على النبي ﷺ',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      value: _enabled,
                      activeColor: widget.primaryColor,
                      title: Text(
                        'تفعيل التذكير',
                        style: GoogleFonts.cairo(color: textColor),
                      ),
                      onChanged: _isDownloading ? null : _toggleReminder,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: _minutes,
                      decoration: InputDecoration(
                        labelText: 'التكرار',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 10, child: Text('كل 10 دقائق')),
                        DropdownMenuItem(value: 15, child: Text('كل 15 دقيقة')),
                        DropdownMenuItem(value: 30, child: Text('كل 30 دقيقة')),
                        DropdownMenuItem(value: 60, child: Text('كل ساعة')),
                      ],
                      onChanged: _isDownloading
                          ? null
                          : (val) {
                        if (val != null) {
                          _updateInterval(val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _selectedSound,
                      decoration: InputDecoration(
                        labelText: 'صوت التذكير',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'saly',
                          child: Text('صلي على النبي'),
                        ),
                        DropdownMenuItem(
                          value: 'saly2',
                          child: Text('اللهم صل على نبينا محمد'),
                        ),
                      ],
                      onChanged: _isDownloading
                          ? null
                          : (val) async {
                        if (val != null) {
                          await _changeSound(val);
                        }
                      },
                    ),
                    if (_isDownloading) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'جاري تحميل الصوت...',
                            style: GoogleFonts.cairo(color: textColor),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}