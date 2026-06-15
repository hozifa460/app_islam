import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import 'salawat_theme.dart';

class SalawatHadithCard extends StatelessWidget {
  final SalawatTheme theme;

  const SalawatHadithCard({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SalawatTheme.innerPadding),
      decoration: BoxDecoration(
        gradient: theme.hadithGradient,
        borderRadius: BorderRadius.circular(SalawatTheme.cardRadius),
        border: Border.all(
          color: theme.accentGold.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: theme.accentGold,
            size: 26,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.tr.salawatHadithText,
              style: GoogleFonts.amiri(
                fontSize: 16,
                color: theme.textColor,
                fontWeight: FontWeight.w600,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr.narratedByMuslim,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: theme.accentGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}