// lib/screens/radio/widgets_surah_player/sp_album_art.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/surah_model.dart';
import '../sp_equalizer.dart';
import 'sp_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// غلاف الألبوم الدائري
/// ══════════════════════════════════════════════════════════════
class SpAlbumArt extends StatelessWidget {
  final AnimationController albumArtController;
  final AnimationController equalizerController;
  final SurahModel surah;
  final bool isPlaying;
  final bool isTablet;
  final Color primary;
  final String stationEmoji;

  const SpAlbumArt({
    super.key,
    required this.albumArtController,
    required this.equalizerController,
    required this.surah,
    required this.isPlaying,
    required this.isTablet,
    required this.primary,
    required this.stationEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final artSize = SpSizes.albumArtSize(screenW, isTablet);

    return AnimatedBuilder(
      animation: albumArtController,
      builder: (_, __) {
        final rotation =
        isPlaying ? albumArtController.value * 2 * pi * 0.02 : 0.0;

        return Transform.rotate(
          angle: rotation,
          child: Container(
            width: artSize,
            height: artSize,
            decoration: SpShapes.albumArt(
              primary: primary,
              isPlaying: isPlaying,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ══ دوائر زخرفية ══
                ...List.generate(3, (i) {
                  final ratio = 0.38 + i * 0.18;
                  return Container(
                    width: artSize * ratio,
                    height: artSize * ratio,
                    decoration: SpShapes.albumDecorCircle(primary, i),
                  );
                }),

                // ══ المحتوى المركزي ══
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      surah.name,
                      style: GoogleFonts.amiriQuran(
                        fontSize: artSize * 0.1,
                        color: primary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stationEmoji,
                      style: TextStyle(fontSize: artSize * 0.13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${surah.versesCount} آية',
                      style: GoogleFonts.cairo(
                        fontSize: artSize * 0.055,
                        color: primary.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // ══ Equalizer ══
                if (isPlaying)
                  Positioned(
                    bottom: artSize * 0.1,
                    child: SpEqualizer(
                      controller: equalizerController,
                      primary: primary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}