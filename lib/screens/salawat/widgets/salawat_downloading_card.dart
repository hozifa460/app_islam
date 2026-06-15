import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import 'salawat_theme.dart';
import 'salawat_glass_card.dart';

class SalawatDownloadingCard extends StatelessWidget {
  final SalawatTheme theme;

  const SalawatDownloadingCard({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SalawatGlassCard(
      theme: theme,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.deepGreen,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            context.tr.downloadingAudio,
            style: GoogleFonts.cairo(
              color: theme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}