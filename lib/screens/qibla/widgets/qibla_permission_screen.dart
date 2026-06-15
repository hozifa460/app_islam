import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

class QiblaPermissionScreen extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRequestPermission;

  const QiblaPermissionScreen({
    super.key,
    required this.isDark,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86, height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QiblaTheme.gold.withValues(alpha: 0.1),
                border: Border.all(color: QiblaTheme.gold.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.location_off_rounded, color: QiblaTheme.gold, size: 40),
            ),
            const SizedBox(height: 18),
            Text('ط§ظ„ظ…ظˆظ‚ط¹ ظ…ط·ظ„ظˆط¨',
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
            const SizedBox(height: 8),
            Text('ظٹظڈط±ط¬ظ‰ طھظپط¹ظٹظ„ ط®ط¯ظ…ط© ط§ظ„ظ…ظˆظ‚ط¹ ظ„طھط­ط¯ظٹط¯ ط§طھط¬ط§ظ‡ ط§ظ„ظ‚ط¨ظ„ط© ط¨ط¯ظ‚ط©',
                style: GoogleFonts.cairo(fontSize: 13.5, color: textColor.withValues(alpha: 0.58), height: 1.6),
                textAlign: TextAlign.center),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: QiblaTheme.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: onRequestPermission,
              icon: const Icon(Icons.location_on_rounded, size: 17),
              label: Text('ط§ظ„ط³ظ…ط§ط­ ط¨ط§ظ„ظ…ظˆظ‚ط¹', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}