// lib/screens/radio/widgets_surah_player/sp_extra_controls.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// أزرار إضافية (تحميل، معلومات، راديو)
/// ══════════════════════════════════════════════════════════════
class SpExtraControls extends StatelessWidget {
  final bool isDark;
  final bool isTablet;
  final bool isOnline;
  final Color primary;
  final VoidCallback? onDownload;
  final VoidCallback onShowInfo;
  final VoidCallback? onRadioMode;

  const SpExtraControls({
    super.key,
    required this.isDark,
    required this.isTablet,
    required this.isOnline,
    required this.primary,
    this.onDownload,
    required this.onShowInfo,
    this.onRadioMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SpSizes.horizontalPadding(isTablet),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (isOnline)
            _ExtraButton(
              icon: Icons.download_rounded,
              label: 'تحميل السورة',
              isActive: false,
              isDark: isDark,
              isTablet: isTablet,
              color: primary,
              onTap: onDownload ?? () {},
            ),

          _ExtraButton(
            icon: Icons.info_outline_rounded,
            label: 'معلومات',
            isActive: false,
            isDark: isDark,
            isTablet: isTablet,
            onTap: onShowInfo,
          ),

          if (!isOnline && onRadioMode != null)
            _ExtraButton(
              icon: Icons.radio_rounded,
              label: 'وضع الراديو',
              isActive: false,
              isDark: isDark,
              isTablet: isTablet,
              onTap: onRadioMode!,
            ),
        ],
      ),
    );
  }
}

class _ExtraButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final bool isTablet;
  final Color? color;
  final VoidCallback onTap;

  const _ExtraButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.isTablet,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor =
        color ?? (isDark ? Colors.white54 : Colors.black45);
    final btnSize = SpSizes.extraBtnSize(isTablet);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: btnSize,
            height: btnSize,
            decoration: SpShapes.extraBtn(
              isActive: isActive,
              primary: color ?? Colors.grey,
              isDark: isDark,
            ),
            child: Icon(
              icon,
              size: SpSizes.extraIconSize(isTablet),
              color: isActive ? (color ?? btnColor) : btnColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: SpSizes.extraLabelSize(isTablet),
              color: isActive ? (color ?? btnColor) : btnColor,
              fontWeight:
              isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}