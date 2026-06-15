import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../languages/app_localizations.dart';
import 'widgets/adhan_player_body.dart';

class AdhanPlayerScreen extends StatefulWidget {
  final Color primaryColor;
  final String prayerName;
  final String muezzinName;
  final String url;
  final String? localPath;

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
      if (widget.localPath != null &&
          await File(widget.localPath!).exists()) {
        await _player.setFilePath(widget.localPath!);
      } else {
        await _player.setUrl(widget.url);
      }
      await _player.play();
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
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
        title: Text(
          widget.muezzinName,
          style: GoogleFonts.cairo(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white),
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
            const Icon(Icons.error_outline,
                color: Colors.red, size: 60),
            const SizedBox(height: 12),
            Text(
              context.tr.playAudioFailed,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                  color: Colors.white70),
            ),
          ],
        )
            : AdhanPlayerBody(
          prayerName: widget.prayerName,
          muezzinName: widget.muezzinName,
          player: _player,
          gold: _gold,
        ),
      ),
    );
  }
}