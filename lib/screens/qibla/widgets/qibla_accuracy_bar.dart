import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

class QiblaAccuracyBar extends StatelessWidget {
  final QiblaTheme theme;
  final int accuracy;
  final bool isFacing;
  final Color guidance;

  const QiblaAccuracyBar({
    super.key,
    required this.theme,
    required this.accuracy,
    required this.isFacing,
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
        decoration: BoxDecoration(
          color: theme.cardBg,
          borderRadius: BorderRadius.circular(QiblaTheme.accuracyBarRadius),
          border: Border.all(color: theme.cardBorder),
          boxShadow: theme.accuracyShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.gps_fixed_rounded, color: guidance, size: 15),
                  const SizedBox(width: 6),
                  Text('دقة الاتجاه',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: theme.textColor,
                      )),
                ]),
                Text('$accuracy%',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: guidance,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: accuracy / 100,
                backgroundColor: theme.isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.withOpacity(0.13),
                valueColor: AlwaysStoppedAnimation<Color>(guidance),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              QiblaTheme.getAccuracyText(accuracy),
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                color: theme.textColor.withOpacity(0.52),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}