// lib/screens/radio/widgets_surah_player/sp_options_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/models/surah_model.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_surah_info_dialog.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// Bottom Sheet الخيارات
/// ══════════════════════════════════════════════════════════════
class SpOptionsSheet extends StatelessWidget {
  final bool isDark;
  final bool isOnline;
  final SurahModel surah;
  final Color primary;
  final VoidCallback onRestart;
  final VoidCallback? onDownload;

  const SpOptionsSheet({
    super.key,
    required this.isDark,
    required this.isOnline,
    required this.surah,
    required this.primary,
    required this.onRestart,
    this.onDownload,
  });

  static Future<void> show({
    required BuildContext context,
    required bool isDark,
    required bool isOnline,
    required SurahModel surah,
    required Color primary,
    required VoidCallback onRestart,
    VoidCallback? onDownload,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SpOptionsSheet(
        isDark: isDark,
        isOnline: isOnline,
        surah: surah,
        primary: primary,
        onRestart: onRestart,
        onDownload: onDownload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SpShapes.optionsSheet(isDark),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ══ مقبض ══
          Container(width: 40, height: 4, decoration: SpShapes.sheetHandle()),
          const SizedBox(height: 16),

          // ══ العنوان ══
          Text(
            'سورة ${surah.name}',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: SpColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 16),

          // ══ معلومات السورة ══
          _OptionItem(
            icon: Icons.info_outline_rounded,
            label: 'معلومات السورة',
            isDark: isDark,
            primary: primary,
            onTap: () {
              Navigator.pop(context);
              SpSurahInfoDialog.show(
                context: context,
                surah: surah,
                isDark: isDark,
                primary: primary,
                isOnline: isOnline,
              );
            },
          ),
          const SizedBox(height: 8),

          // ══ إعادة من البداية ══
          _OptionItem(
            icon: Icons.replay_rounded,
            label: 'إعادة من البداية',
            isDark: isDark,
            primary: primary,
            onTap: () {
              Navigator.pop(context);
              onRestart();
            },
          ),
          const SizedBox(height: 8),

          // ══ تحميل (أونلاين فقط) ══
          if (isOnline && onDownload != null)
            _OptionItem(
              icon: Icons.download_rounded,
              label: 'تحميل سورة ${surah.name}',
              isDark: isDark,
              primary: primary,
              color: primary,
              onTap: () {
                Navigator.pop(context);
                onDownload!();
              },
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color primary;
  final Color? color;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.primary,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: SpShapes.optionItem(itemColor),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 20),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SpColors.textPrimary(isDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}