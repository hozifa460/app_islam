import 'package:flutter/material.dart';
import 'miracle_color_provider.dart';

class MiracleTheme {
  // ── ثوابت مشتركة ──
  static const neonBlue   = Color(0xFF00D4FF);
  static const neonPurple = Color(0xFF7B2FBE);
  static const neonGold   = Color(0xFFFFD740);
  static const neonGreen  = Color(0xFF69F0AE);
  static const neonRed    = Color(0xFFFF5370);

  static MiracleThemeColors of(
      bool isDark, {
        MiracleColorProvider? provider,
        MiracleColorPreset?   preset,
      }) {
    Color primary, neonAccent, bg1, bg2, bg3;
    MiracleColorPreset p;

    if (provider != null) {
      // ← نأخذ الألوان الفعلية مباشرة من provider
      // بدون أي خلط إضافي - provider يتحكم بكل شيء
      primary    = provider.effectivePrimary;
      neonAccent = provider.effectiveNeonAccent;
      bg1        = provider.effectiveBg1;
      bg2        = provider.effectiveBg2;
      bg3        = provider.effectiveBg3;
      p          = provider.current;
    } else if (preset != null) {
      primary    = preset.primary;
      neonAccent = preset.neonAccent;
      bg1        = preset.bg1;
      bg2        = preset.bg2;
      bg3        = preset.bg3;
      p          = preset;
    } else {
      final def  = kMiracleColorPresets[0];
      primary    = def.primary;
      neonAccent = def.neonAccent;
      bg1        = def.bg1;
      bg2        = def.bg2;
      bg3        = def.bg3;
      p          = def;
    }

    // ← كلا الوضعين يستخدمان نفس الألوان بدون خلط
    // الفرق الوحيد: starOpacityFactor و nebulaOpacityFactor
    return MiracleThemeColors(
      bg1:                bg1,
      bg2:                bg2,
      bg3:                bg3,
      glass:              isDark
          ? const Color(0x18FFFFFF)
          : const Color(0x22FFFFFF),
      glassBorder:        isDark
          ? const Color(0x30FFFFFF)
          : const Color(0x44FFFFFF),
      text:               Colors.white,
      subText:            const Color(0xCCFFFFFF),
      mutedText:          const Color(0x99FFFFFF),
      cardColor:          bg2,
      neonBlue:           primary,
      neonAccent:         neonAccent,
      isDark:             isDark,
      // النجوم أخف قليلاً في الوضع الفاتح لكن الألوان نفسها
      starOpacityFactor:  isDark ? 1.0 : 0.7,
      nebulaOpacityFactor: isDark ? 1.0 : 0.6,
      preset:             p,
    );
  }
}

class MiracleThemeColors {
  final Color bg1, bg2, bg3;
  final Color glass, glassBorder;
  final Color text, subText, mutedText;
  final Color cardColor;
  final Color neonBlue;
  final Color neonAccent;
  final bool  isDark;
  final double starOpacityFactor;
  final double nebulaOpacityFactor;
  final MiracleColorPreset preset;

  // ── ثوابت مشتركة ──
  static const neonGold  = Color(0xFFFFD740);
  static const neonGreen = Color(0xFF69F0AE);
  static const neonRed   = Color(0xFFFF5370);

  const MiracleThemeColors({
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.glass,
    required this.glassBorder,
    required this.text,
    required this.subText,
    required this.mutedText,
    required this.cardColor,
    required this.neonBlue,
    required this.neonAccent,
    required this.isDark,
    required this.starOpacityFactor,
    required this.nebulaOpacityFactor,
    required this.preset,
  });
}