import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';

class NextPrayerCard extends StatelessWidget {
  final String? prayerName;
  final String? prayerTime;
  final String? muezzinName;
  final String remainingTime;
  final bool isDark;
  final Color gold;
  final VoidCallback onListenAdhan;

  const NextPrayerCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.muezzinName,
    required this.remainingTime,
    required this.isDark,
    required this.gold,
    required this.onListenAdhan,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gold.withOpacity(0.2), gold.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: gold.withOpacity(0.4)),
                      ),
                      child: Text(
                        context.tr.theNextPrayerCardTitle,
                        style: GoogleFonts.cairo(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      prayerName ?? '--',
                      style: GoogleFonts.amiri(
                        fontSize: 36,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prayerTime ?? '--:--',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (muezzinName != null)
                      Text
                        (context.tr.muezzinLabel(muezzinName!),
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: gold.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 3),
                  color: cardColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      remainingTime,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      context.tr.remainingLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onListenAdhan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold.withOpacity(0.2),
                    foregroundColor: gold,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: gold.withOpacity(0.3)),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    context.tr.listenToAdhan,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}