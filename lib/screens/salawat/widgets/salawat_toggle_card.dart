import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import 'salawat_theme.dart';
import 'salawat_glass_card.dart';

class SalawatToggleCard extends StatelessWidget {
  final SalawatTheme theme;
  final bool enabled;
  final bool isDownloading;
  final ValueChanged<bool>? onChanged;

  const SalawatToggleCard({
    super.key,
    required this.theme,
    required this.enabled,
    required this.isDownloading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SalawatGlassCard(
      theme: theme,
      child: Row(
        children: [
          // Icon
          Container(
            width: SalawatTheme.iconContainerSize,
            height: SalawatTheme.iconContainerSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: enabled
                    ? [theme.deepGreen, theme.deepGreen.withValues(alpha: 0.7)]
                    : [Colors.grey.shade400, Colors.grey.shade300],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled
                  ? [
                BoxShadow(
                  color: theme.deepGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [],
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.enableSalawatReminder,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                Text(
                  enabled ? context.tr.salawatReminderActiveLabel : context.tr.tapToEnable,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: enabled ? theme.deepGreen : theme.subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Switch
          Transform.scale(
            scale: 1.1,
            child: Switch.adaptive(
              value: enabled,
              activeColor: theme.deepGreen,
              activeTrackColor: theme.deepGreen.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
              onChanged: isDownloading ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }
}