import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

class QiblaInfoCards extends StatelessWidget {
  final QiblaTheme theme;
  final double qiblaAngle;
  final double compassHeading;
  final double deviation;
  final Color guidance;

  const QiblaInfoCards({
    super.key,
    required this.theme,
    required this.qiblaAngle,
    required this.compassHeading,
    required this.deviation,
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
      label: 'ط§ظ„ظ‚ط¨ظ„ط©\nظ…ظ† ط§ظ„ط´ظ…ط§ظ„',
      value: '${qiblaAngle.toStringAsFixed(1)}آ°',
      icon: Icons.explore_rounded,
      color: QiblaTheme.gold,
      ),
      (
      label: 'ط§طھط¬ط§ظ‡\nظ‡ط§طھظپظƒ',
      value: '${compassHeading.toStringAsFixed(1)}آ°',
      icon: Icons.screen_rotation_rounded,
      color: QiblaTheme.blue,
      ),
      (
      label: 'ط§ظ„ط§ظ†ط­ط±ط§ظپ\nط¹ظ† ط§ظ„ظ‚ط¨ظ„ط©',
      value: '${deviation.abs().toStringAsFixed(1)}آ°',
      icon: Icons.swap_horiz_rounded,
      color: guidance,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: cards.map((c) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding:
              const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
              decoration: BoxDecoration(
                color: theme.cardBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: c.color.withValues(alpha: 0.2)),
                boxShadow: theme.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.color.withValues(alpha: 0.11),
                    ),
                    child: Icon(c.icon, color: c.color, size: 17),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    child: Text(c.value,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: theme.textColor,
                        )),
                  ),
                  const SizedBox(height: 2),
                  Text(c.label,
                      style: GoogleFonts.cairo(
                        fontSize: 9.5,
                        color: theme.textColor.withValues(alpha: 0.48),
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}