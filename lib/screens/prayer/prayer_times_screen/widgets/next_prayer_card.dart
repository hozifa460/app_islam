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
    final textColor = isDark ? Colors.white : const Color(0xFF1C1915);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF514A40);
    final cardColor =
        isDark ? const Color(0xFF182235) : const Color(0xFFFFFBF2);
    final buttonColor =
        isDark ? const Color(0xFF31394A) : const Color(0xFFE4D8C0);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? [const Color(0xFF1A263A), const Color(0xFF121B2A)]
                  : [const Color(0xFFFFFCF5), const Color(0xFFF9F0DF)],
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: gold.withValues(alpha: 0.72), width: 2),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : const Color(0xFF7D6540).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 12),
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
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFE9E0D0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.tr.theNextPrayerCardTitle,
                        style: GoogleFonts.cairo(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      prayerName ?? '--',
                      style: GoogleFonts.amiri(
                        fontSize: 42,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      prayerTime ?? '--:--',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (muezzinName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: gold.withValues(alpha: 0.24),
                              child: Icon(
                                Icons.person_rounded,
                                size: 21,
                                color: isDark ? gold : const Color(0xFF56452F),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.tr.muezzinLabel(muezzinName!),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: subTextColor,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 102,
                height: 102,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [gold, const Color(0xFF6F5224)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.35),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardColor,
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        remainingTime,
                        style: GoogleFonts.cairo(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        context.tr.remainingLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isDark ? gold : const Color(0xFF80683B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onListenAdhan,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: textColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: const Color(0xFF9C8661).withValues(alpha: 0.65),
                  ),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 27),
              label: Text(
                context.tr.listenToAdhan,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
