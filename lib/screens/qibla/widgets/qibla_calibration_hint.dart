import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

class QiblaCalibrationHint extends StatelessWidget {
  final QiblaTheme theme;
  const QiblaCalibrationHint({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: QiblaTheme.orange.withValues(alpha: theme.isDark ? 0.07 : 0.06),
          borderRadius: BorderRadius.circular(QiblaTheme.calibrationRadius),
          border: Border.all(color: QiblaTheme.orange.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 17),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'إذا كانت النتيجة غير دقيقة: حرّك هاتفك على شكل ∞ عدة مرات، ثم ابتعد عن الأجسام المعدنية والكهربائية',
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  color: theme.isDark ? Colors.orange.shade200 : Colors.orange.shade800,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}