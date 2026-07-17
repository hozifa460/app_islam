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
          width: 5,
          height: 34,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          context.tr.prayerScheduleTable,
          style: GoogleFonts.cairo(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const Spacer(),
        if (nextPrayerName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? gold.withValues(alpha: 0.15)
                      : const Color(0xFFE8DECB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withValues(alpha: 0.35)),
            ),
            child: Text(
              context.tr.upNextPrayer(nextPrayerName!),
              style: GoogleFonts.cairo(
                color: isDark ? gold : const Color(0xFF59482F),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
