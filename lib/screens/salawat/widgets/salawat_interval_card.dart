import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import 'salawat_theme.dart';
import 'salawat_glass_card.dart';
import 'salawat_interval_chip.dart';

class SalawatIntervalCard extends StatelessWidget {
  final SalawatTheme theme;
  final int selectedMinutes;
  final bool isDownloading;
  final ValueChanged<int> onIntervalChanged;

  const SalawatIntervalCard({
    super.key,
    required this.theme,
    required this.selectedMinutes,
    required this.isDownloading,
    required this.onIntervalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SalawatGlassCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: SalawatTheme.smallIconSize,
                height: SalawatTheme.smallIconSize,
                decoration: BoxDecoration(
                  color: theme.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: theme.accentGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr.repeatInterval,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SalawatIntervalChip(
                theme: theme,
                value: 10,
                label: context.tr.every10Mins,
                isSelected: selectedMinutes == 10,
                isDownloading: isDownloading,
                onTap: () => onIntervalChanged(10),
              ),
              const SizedBox(width: 8),
              SalawatIntervalChip(
                theme: theme,
                value: 15,
                label: context.tr.every15Mins,
                isSelected: selectedMinutes == 15,
                isDownloading: isDownloading,
                onTap: () => onIntervalChanged(15),
              ),
              const SizedBox(width: 8),
              SalawatIntervalChip(
                theme: theme,
                value: 30,
                label: context.tr.every30Mins,
                isSelected: selectedMinutes == 30,
                isDownloading: isDownloading,
                onTap: () => onIntervalChanged(30),
              ),
              const SizedBox(width: 8),
              SalawatIntervalChip(
                theme: theme,
                value: 60,
                label: context.tr.every1Hour,
                isSelected: selectedMinutes == 60,
                isDownloading: isDownloading,
                onTap: () => onIntervalChanged(60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}