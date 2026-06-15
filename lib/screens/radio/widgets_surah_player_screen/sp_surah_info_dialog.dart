// lib/screens/radio/widgets_surah_player/sp_surah_info_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/surah_model.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// حوار معلومات السورة
/// ══════════════════════════════════════════════════════════════
class SpSurahInfoDialog extends StatelessWidget {
  final SurahModel surah;
  final bool isDark;
  final Color primary;
  final bool isOnline;

  const SpSurahInfoDialog({
    super.key,
    required this.surah,
    required this.isDark,
    required this.primary,
    required this.isOnline,
  });

  static Future<void> show({
    required BuildContext context,
    required SurahModel surah,
    required bool isDark,
    required Color primary,
    required bool isOnline,
  }) {
    return showDialog(
      context: context,
      builder: (_) => SpSurahInfoDialog(
        surah: surah,
        isDark: isDark,
        primary: primary,
        isOnline: isOnline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: isDark ? SpColors.darkSheet : Colors.white,
      title: Text(
        'سورة ${surah.name}',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w800,
          color: SpColors.textPrimary(isDark),
        ),
        textDirection: TextDirection.rtl,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InfoRow(
            label: 'رقم السورة',
            value: '${surah.number}',
            isDark: isDark,
            primary: primary,
          ),
          _InfoRow(
            label: 'عدد الآيات',
            value: '${surah.versesCount}',
            isDark: isDark,
            primary: primary,
          ),
          _InfoRow(
            label: 'الجزء',
            value: '${surah.juzNumber}',
            isDark: isDark,
            primary: primary,
          ),
          _InfoRow(
            label: 'النوع',
            value: surah.isMakki ? 'مكية' : 'مدنية',
            isDark: isDark,
            primary: primary,
          ),
          _InfoRow(
            label: 'وضع التشغيل',
            value: isOnline ? 'أونلاين' : 'أوفلاين',
            isDark: isDark,
            primary: primary,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إغلاق',
            style: GoogleFonts.cairo(color: primary),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  final Color primary;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: SpColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}