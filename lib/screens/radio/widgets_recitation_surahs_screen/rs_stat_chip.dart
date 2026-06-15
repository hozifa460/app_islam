// lib/screens/radio/widgets_surahs/rs_stat_chip.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// شريحة إحصائية صغيرة
/// ══════════════════════════════════════════════════════════════
class RsStatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const RsStatChip({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: RsShapes.statChip(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ══ القيمة ══
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: RsSizes.statChipSize,
              fontWeight: FontWeight.w800,
              color: color, // ✅ لون primary المُمرَّر
            ),
          ),

          const SizedBox(width: 3),

          // ══ التسمية ══
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: RsSizes.statChipSize,
              fontWeight: FontWeight.w600,
              color: RsColors.textMuted(context), // ✅ من RsColors
            ),
          ),
        ],
      ),
    );
  }
}