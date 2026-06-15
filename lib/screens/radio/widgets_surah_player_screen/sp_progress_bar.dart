// lib/screens/radio/widgets_surah_player/sp_progress_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// شريط التقدم مع الوقت
/// ══════════════════════════════════════════════════════════════
class SpProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isDark;
  final bool isTablet;
  final bool isOnline;
  final Color primary;
  final ValueChanged<Duration> onSeek;

  const SpProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.isDark,
    required this.isTablet,
    required this.isOnline,
    required this.primary,
    required this.onSeek,
  });

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final timeStyle = GoogleFonts.poppins(
      fontSize: SpSizes.timeSize(isTablet),
      color: SpColors.textTertiary(isDark),
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SpSizes.progressPadding(isTablet),
      ),
      child: Column(
        children: [
          // ══ Slider ══
          SliderTheme(
            data: SliderThemeData(
              trackHeight: SpSizes.trackHeight(isTablet),
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: SpSizes.thumbRadius(isTablet),
              ),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: SpSizes.overlayRadius(isTablet),
              ),
              activeTrackColor: primary,
              inactiveTrackColor: primary.withOpacity(0.18),
              thumbColor: primary,
              overlayColor: primary.withOpacity(0.15),
            ),
            child: Slider(
              value: progress,
              onChanged: (v) {
                final newPos = Duration(
                  milliseconds: (v * duration.inMilliseconds).toInt(),
                );
                onSeek(newPos);
              },
            ),
          ),

          // ══ الوقت ══
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_format(position), style: timeStyle),
                if (isOnline) _buildOnlineIndicator(),
                Text(_format(duration), style: timeStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.wifi_rounded,
          size: 12,
          color: Colors.blue.withOpacity(0.5),
        ),
        const SizedBox(width: 3),
        Text(
          'مباشر',
          style: GoogleFonts.cairo(
            fontSize: 10,
            color: Colors.blue.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}