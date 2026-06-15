import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';

/// â•گâ•گ FIX #4: ط¥ط²ط§ظ„ط© BackdropFilter â•گâ•گ
class HomeHadithCard extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final Map<String, String> hadith;

  const HomeHadithCard({
    super.key,
    required this.primary,
    required this.isDark,
    required this.hadith,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.85);
    final borderColor = primary.withValues(alpha: 0.18);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.08 : 0.03);
    final iconColor = isDark ? Colors.white70 : primary;
    final textColor = isDark ? Colors.white : const Color(0xFF2E2415);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Positioned(
              top: -6,
              left: -6,
              child: Icon(
                Icons.format_quote_rounded,
                size: 44,
                color: iconColor.withValues(alpha: 0.10),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.lightbulb_outline, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      tr.hadithOfDay,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    tr.prophetSaid,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hadith['text']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 21,
                    height: 1.9,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                if (hadith['source']!.isNotEmpty)
                  Text(
                    hadith['source']!,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}