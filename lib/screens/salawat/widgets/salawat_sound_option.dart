import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'salawat_theme.dart';

class SalawatSoundOption extends StatelessWidget {
  final SalawatTheme theme;
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDownloading;
  final VoidCallback onTap;

  const SalawatSoundOption({
    super.key,
    required this.theme,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isDownloading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDownloading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: theme.soundOptionGradient(isSelected),
          color: isSelected ? null : theme.soundOptionBg(false),
          borderRadius: BorderRadius.circular(SalawatTheme.smallRadius),
          border: Border.all(
            color: theme.soundOptionBorder(isSelected),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: SalawatTheme.smallIconSize,
              height: SalawatTheme.smallIconSize,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.deepGreen.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? theme.deepGreen : theme.subtitleColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                      isSelected ? theme.deepGreen : theme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: theme.subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? theme.deepGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? theme.deepGreen
                      : theme.subtitleColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}