// lib/screens/radio/widgets_surahs/rs_fab.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// زر تحميل التلاوات (FAB)
/// ══════════════════════════════════════════════════════════════
class RsFab extends StatelessWidget {
  final Color primary;
  final VoidCallback onTap;

  const RsFab({
    super.key,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: RsShapes.fab(primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ══ أيقونة التحميل ══
            Icon(
              Icons.download_rounded,
              color: Colors.white, // ✅ أبيض دائماً على خلفية primary
              size: 20,
            ),
            const SizedBox(width: 8),

            // ══ نص الزر ══
            Text(
              'تحميل تلاوات',
              style: GoogleFonts.cairo(
                fontSize: RsSizes.fabLabelSize,
                fontWeight: FontWeight.w700,
                color: Colors.white, // ✅ أبيض دائماً على خلفية primary
              ),
            ),
          ],
        ),
      ),
    );
  }
}