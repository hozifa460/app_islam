import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class AdhanAlarmScreen extends StatefulWidget {
  final String prayerName;
  final String muezzinId;
  final String muezzinName;
  final String? audioPath; // Local downloaded file
  final String? muezzinUrl; // Online URL

  const AdhanAlarmScreen({
    super.key,
    required this.prayerName,
    required this.muezzinId,
    required this.muezzinName,
    this.audioPath,
    this.muezzinUrl, // Online URL as fallback
  });

  @override
  State<AdhanAlarmScreen> createState() => _AdhanAlarmScreenState();
}

class _AdhanAlarmScreenState extends State<AdhanAlarmScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  late AnimationController _pulseController;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _playAdhan();
    _startAutoCloseTimer();
  }

  Future<void> _playAdhan() async {
    try {
      // Priority: 1. Local file, 2. Online URL
      if (widget.audioPath != null && widget.audioPath!.isNotEmpty) {
        // Play local downloaded file
        await _player.setFilePath(widget.audioPath!);
      } else if (widget.muezzinUrl != null && widget.muezzinUrl!.isNotEmpty) {
        // Play from online URL (streaming)
        await _player.setUrl(widget.muezzinUrl!);
      } else {
        // No audio source available
        debugPrint('Error: No audio source available');
        return;
      }

      await _player.play();
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('Error playing adhan: $e');
    }
  }

  void _startAutoCloseTimer() {
    // Auto-close after 3 minutes
    _autoCloseTimer = Timer(const Duration(minutes: 3), () {
      if (mounted) _stopAndClose();
    });
  }

  void _stopAndClose() {
    _player.stop();
    _player.dispose();
    _pulseController.dispose();
    _autoCloseTimer?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE6B325).withOpacity(0.2),
              const Color(0xFF0A0E17),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Pulse animation around icon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 200 + (_pulseController.value * 20),
                    height: 200 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE6B325)
                          .withOpacity(0.2 - (_pulseController.value * 0.1)),
                      border: Border.all(
                        color: const Color(0xFFE6B325).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFE6B325), Color(0xFFD4AF37)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFE6B325),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mosque,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Prayer name
              Text(
                'حان وقت صلاة',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.prayerName,
                style: GoogleFonts.amiri(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Muezzin name
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: const Color(0xFFE6B325).withOpacity(0.3)),
                ),
                child: Text(
                  'المؤذن: ${widget.muezzinName}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: const Color(0xFFE6B325),
                  ),
                ),
              ),

              const Spacer(),

              // Control buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Stop button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _stopAndClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                        icon: const Icon(Icons.stop),
                        label: Text(
                          'إيقاف الأذان',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Snooze button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _player.pause();
                          Future.delayed(const Duration(minutes: 10), () {
                            if (mounted) _player.play();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.snooze),
                        label: Text(
                          'تأجيل 10 دق',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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