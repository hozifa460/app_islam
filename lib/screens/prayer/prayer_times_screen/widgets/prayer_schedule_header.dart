import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';

class PrayerScheduleHeader extends StatelessWidget {
  final String? nextPrayerName;
  final bool isDark;
  final Color gold;

  const PrayerScheduleHeader({
    super.key,
    required this.nextPrayerName,
    required this.isDark,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.tr.prayerScheduleTable,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const Spacer(),
        if (nextPrayerName != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withOpacity(0.35)),
            ),
            child: Text(
              context.tr.upNextPrayer(nextPrayerName!),
              style: GoogleFonts.cairo(
                color: gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}