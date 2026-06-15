import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../more/services/radio_services.dart';

// طھط£ظƒط¯ ظ…ظ† ط§ظ„ظ…ط³ط§ط± ط§ظ„طµط­ظٹط­ ظ„ظ…ظ„ظپ ط§ظ„طھط±ط¬ظ…ط©
import '../../../../../languages/app_localizations.dart';

class RadioMiniPlayer extends StatelessWidget {
  final Color gold;
  const RadioMiniPlayer({super.key, required this.gold});

  @override
  Widget build(BuildContext context) {
    // âœ… ظƒط´ظپ ط§ظ„ظˆط¶ط¹ ط§ظ„ط­ط§ظ„ظٹ
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // âœ… ط£ظ„ظˆط§ظ† ط¯ظٹظ†ط§ظ…ظٹظƒظٹط©
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final borderColor = gold.withValues(alpha: isDark ? 0.3 : 0.6); // ط­ط¯ظˆط¯ ط£ظˆط¶ط­ ظپظٹ ط§ظ„ظˆط¶ط¹ ط§ظ„ظپط§طھط­

    return StreamBuilder<bool>(
      stream: RadioService.player.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: ListTile(
            leading: isPlaying
                ? const Icon(Icons.stop_circle, color: Colors.red, size: 32)
                : Icon(Icons.play_circle_fill, color: gold, size: 32),
            title: Text(
              context.tr.quranRadioTitle, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط© ظ‡ظ†ط§
              style: GoogleFonts.cairo(
                color: textColor, // ظ†طµ ط¯ظٹظ†ط§ظ…ظٹظƒظٹ
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              isPlaying
                  ? context.tr.radioLiveBroadcasting
                  : context.tr.radioTapToListen, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط© ظ‡ظ†ط§
              style: GoogleFonts.cairo(
                color: subTextColor, // ظ†طµ ط«ط§ظ†ظˆظٹ ط¯ظٹظ†ط§ظ…ظٹظƒظٹ
                fontSize: 12,
              ),
            ),
            onTap: () => RadioService.toggleRadio(),
          ),
        );
      },
    );
  }
}