import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import 'salawat_theme.dart';
import 'salawat_glass_card.dart';
import 'salawat_sound_option.dart';

class SalawatSoundCard extends StatelessWidget {
  final SalawatTheme theme;
  final String selectedSound;
  final bool isDownloading;
  final ValueChanged<String> onSoundChanged;

  const SalawatSoundCard({
    super.key,
    required this.theme,
    required this.selectedSound,
    required this.isDownloading,
    required this.onSoundChanged,
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
                  color: theme.deepGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: theme.deepGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr.reminderSound,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SalawatSoundOption(
            theme: theme,
            value: 'saly',
            title: context.tr.soundSalyOnProphet,
            subtitle: context.tr.shortAudioReminder,
            icon: Icons.graphic_eq_rounded,
            isSelected: selectedSound == 'saly',
            isDownloading: isDownloading,
            onTap: () => onSoundChanged('saly'),
          ),
          const SizedBox(height: 10),
          SalawatSoundOption(
            theme: theme,
            value: 'saly2',
            title: context.tr.soundOhAllahBless,
            subtitle: context.tr.specialAudioReminder,
            icon: Icons.equalizer_rounded,
            isSelected: selectedSound == 'saly2',
            isDownloading: isDownloading,
            onTap: () => onSoundChanged('saly2'),
          ),
        ],
      ),
    );
  }
}