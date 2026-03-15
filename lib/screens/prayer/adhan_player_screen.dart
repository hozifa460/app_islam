import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../utils/radio_widget.dart';

class AdhanPlayerScreen extends StatefulWidget {
  final Color primaryColor;
  final String prayerName;

  final String muezzinName;
  final String url;         // online
  final String? localPath;  // optional offline

  const AdhanPlayerScreen({
    super.key,
    required this.primaryColor,
    required this.prayerName,
    required this.muezzinName,
    required this.url,
    this.localPath,
  });

  @override
  State<AdhanPlayerScreen> createState() => _AdhanPlayerScreenState();
}

class _AdhanPlayerScreenState extends State<AdhanPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _loading = true;
  bool _error = false;

  final _bgDark = const Color(0xFF0A0E17);
  final _gold = const Color(0xFFE6B325);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      // local first if exists
      if (widget.localPath != null && await File(widget.localPath!).exists()) {
        await _player.setFilePath(widget.localPath!);
      } else {
        await _player.setUrl(widget.url);
      }
      await _player.play();
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.muezzinName, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator(color: _gold)
            : _error
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 12),
            Text('فشل تشغيل الصوت.\nتأكد أن الرابط مباشر mp3.', textAlign: TextAlign.center, style: GoogleFonts.cairo(color: Colors.white70)),
          ],
        )
            : StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snap) {
            final playing = snap.data?.playing ?? false;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('أذان ${widget.prayerName}', style: GoogleFonts.amiri(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(widget.muezzinName, style: GoogleFonts.cairo(color: _gold)),
                const SizedBox(height: 20),
                IconButton(
                  iconSize: 72,
                  onPressed: () => playing ? _player.pause() : _player.play(),
                  icon: Icon(playing ? Icons.pause_circle : Icons.play_circle, color: _gold),
                ),
                TextButton(
                  onPressed: () => _player.stop(),
                  child: Text('إيقاف', style: GoogleFonts.cairo(color: Colors.white70)),
                ),

                RadioMiniPlayer(gold: _gold,)
              ],
            );
          },
        ),
      ),
    );
  }
}