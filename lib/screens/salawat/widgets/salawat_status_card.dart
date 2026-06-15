import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import 'salawat_theme.dart';

class SalawatStatusCard extends StatelessWidget {
  final SalawatTheme theme;
  final bool enabled;
  final int minutes;

  const SalawatStatusCard({
    super.key,
    required this.theme,
    required this.enabled,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: enabled ? theme.enabledStatusGradient : null,
        color: enabled ? null : theme.cardColor,
        borderRadius: BorderRadius.circular(SalawatTheme.cardRadius),
        border: Border.all(
          color: enabled
              ? theme.activeBorderColor
              : theme.inactiveBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: enabled
                ? theme.deepGreen.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: SalawatTheme.statusIconSize,
            height: SalawatTheme.statusIconSize,
            decoration: BoxDecoration(
              color: enabled
                  ? theme.deepGreen.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              enabled
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: enabled ? theme.deepGreen : theme.subtitleColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  enabled ? context.tr.reminderIsActive : context.tr.reminderIsInactive,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: enabled
                        ? theme.deepGreen
                        : theme.subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? context.tr.willBeRemindedEveryX(minutes)
                      : context.tr.enableToGetReminded,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: theme.subtitleColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}