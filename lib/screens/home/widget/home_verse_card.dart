import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';

/// ══ FIX #4: إزالة BackdropFilter — استبداله بـ Container عادي ══
/// BackdropFilter يسبب rasterization كل frame أثناء السكرول
class HomeVerseCard extends StatelessWidget {
  final Color gold;
  final Color cardColor;
  final bool isDark;
  final Map<String, String> verse;

  const HomeVerseCard({
    super.key,
    required this.gold,
    required this.cardColor,
    required this.isDark,
    required this.verse,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final small = width < 360;

      // ══ FIX #13: كاش ألوان ══
      final bgColor = isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.white.withOpacity(0.85);
      final borderColor = gold.withOpacity(0.18);
      final shadowColor = Colors.black.withOpacity(isDark ? 0.08 : 0.03);
      final textColor = isDark ? Colors.white : const Color(0xFF2E2415);
      final subColor = isDark ? Colors.white60 : Colors.black54;

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
          padding: EdgeInsets.all(small ? 14 : 16),
          child: Stack(
            children: [
              Positioned(
                top: -6,
                left: -6,
                child: Icon(
                  Icons.auto_awesome,
                  size: 42,
                  color: gold.withOpacity(0.10),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.auto_awesome, color: gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        tr.verseOfDay,
                        style: GoogleFonts.cairo(
                          fontSize: small ? 15 : 16,
                          fontWeight: FontWeight.bold,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (verse['surah']!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        verse['surah']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: small ? 11 : 12,
                          color: gold,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    verse['verse']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: small ? 22 : 26,
                      height: small ? 1.9 : 2.0,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr.readWithReflection,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: small ? 11 : 12,
                      color: subColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}