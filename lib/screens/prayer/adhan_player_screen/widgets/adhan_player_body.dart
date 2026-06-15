import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../languages/app_localizations.dart';
import '../../prayer_times_screen/widgets/radio_widget.dart';

class AdhanPlayerBody extends StatelessWidget {
  final String prayerName;
  final String muezzinName;
  final AudioPlayer player;
  final Color gold;

  const AdhanPlayerBody({
    super.key,
    required this.prayerName,
    required this.muezzinName,
    required this.player,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snap) {
        final playing = snap.data?.playing ?? false;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr.adhanOfPrayer(prayerName),
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              muezzinName,
              style: GoogleFonts.cairo(color: gold),
            ),
            const SizedBox(height: 20),
            IconButton(
              iconSize: 72,
              onPressed: () =>
              playing ? player.pause() : player.play(),
              icon: Icon(
                playing ? Icons.pause_circle : Icons.play_circle,
                color: gold,
              ),
            ),
            TextButton(
              onPressed: () => player.stop(),
              child: Text(
                  context.tr.stopAudio,
                  style: GoogleFonts.cairo(color: Colors.white70)),
            ),
            RadioMiniPlayer(gold: gold),
          ],
        );
      },
    );
  }
}