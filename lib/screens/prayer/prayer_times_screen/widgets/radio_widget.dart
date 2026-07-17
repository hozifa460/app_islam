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
    final bgColor = isDark ? const Color(0xFF1C293A) : const Color(0xFFE9DEC9);
    final textColor = isDark ? Colors.white : const Color(0xFF211C16);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF534A3D);
    final borderColor = gold.withValues(
      alpha: isDark ? 0.3 : 0.6,
    ); // ط­ط¯ظˆط¯ ط£ظˆط¶ط­ ظپظٹ ط§ظ„ظˆط¶ط¹ ط§ظ„ظپط§طھط­

    return ValueListenableBuilder<bool>(
      valueListenable: RadioService.isLoading,
      builder: (context, loading, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: RadioService.lastError,
          builder: (context, error, _) {
            return StreamBuilder<bool>(
              stream: RadioService.player.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [const Color(0xFF26354A), bgColor]
                              : [const Color(0xFFF5EDDD), bgColor],
                    ),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withValues(alpha: 0.18)
                                : const Color(
                                  0xFF7D6540,
                                ).withValues(alpha: 0.15),
                        blurRadius: 13,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isPlaying
                                ? Colors.red.shade700
                                : const Color(0xFF806638),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                    title: Text(
                      context
                          .tr
                          .quranRadioTitle, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط© ظ‡ظ†ط§
                      style: GoogleFonts.cairo(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      loading
                          ? 'جارٍ الاتصال بإذاعة القرآن...'
                          : error ??
                              (isPlaying
                                  ? context.tr.radioLiveBroadcasting
                                  : context.tr.radioTapToListen),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: subTextColor,
                        fontSize: 13,
                      ),
                    ),
                    trailing:
                        error != null && !loading
                            ? IconButton(
                              tooltip: 'إعادة المحاولة',
                              icon: Icon(Icons.refresh_rounded, color: gold),
                              onPressed: RadioService.toggleRadio,
                            )
                            : loading
                            ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: gold,
                              ),
                            )
                            : null,
                    onTap: RadioService.toggleRadio,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
