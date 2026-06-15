import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'salawat_theme.dart';

class SalawatIntervalChip extends StatelessWidget {
  final SalawatTheme theme;
  final int value;
  final String label;
  final bool isSelected;
  final bool isDownloading;
  final VoidCallback onTap;

  const SalawatIntervalChip({
    super.key,
    required this.theme,
    required this.value,
    required this.label,
    required this.isSelected,
    required this.isDownloading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: isDownloading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            gradient: theme.chipGradient(isSelected),
            color: isSelected ? null : theme.chipBgColor(false),
            borderRadius:
            BorderRadius.circular(SalawatTheme.smallRadius),
            border: Border.all(
              color: theme.chipBorderColor(isSelected),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: theme.deepGreen.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.w500,
                color: theme.chipTextColor(isSelected),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }
}