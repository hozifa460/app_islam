import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hijri_theme.dart';

class HijriNoteCard extends StatelessWidget {
  final Map<String, String> note;
  final HijriTheme theme;
  final bool compact;

  const HijriNoteCard({
    super.key,
    required this.note,
    required this.theme,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  note['title']!,
                  style: GoogleFonts.cairo(
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  note['desc']!,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: compact ? 11 : 12,
                    height: 1.8,
                    color: theme.isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.primaryColor.withOpacity(0.12),
                theme.primaryColor.withOpacity(0.04),
              ]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: theme.primaryColor,
              size: compact ? 20 : 22,
            ),
          ),
        ],
      ),
    );
  }
}