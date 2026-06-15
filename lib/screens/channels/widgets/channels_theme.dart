import 'package:flutter/material.dart';

class ChannelsTheme {
  final bool isDark;
  ChannelsTheme({required this.isDark});


  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„ط£ظ„ظˆط§ظ† ط§ظ„ط£ط³ط§ط³ظٹط© - ظ…ط­ط³ظ‘ظ†ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get scaffoldBg =>
      isDark ? const Color(0xFF0A0E14) : const Color(0xFFF8FAFC);

  List<Color> get bgGradient => isDark
      ? [const Color(0xFF0A0E14), const Color(0xFF131920), const Color(0xFF0A0E14)]
      : [const Color(0xFFF8FAFC), const Color(0xFFEFF4F8), const Color(0xFFF8FAFC)];

  Color get primaryColor =>
      isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0D9488);
  Color get primaryDark =>
      isDark ? const Color(0xFF14B8A6) : const Color(0xFF0F766E);
  Color get primaryLight => isDark
      ? const Color(0xFF5EEAD4).withValues(alpha: 0.15)
      : const Color(0xFF0D9488).withValues(alpha: 0.08);

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„ط¨ط·ط§ظ‚ط§طھ - ظ…ط­ط³ظ‘ظ†ط© ظ…ط¹ طھط£ط«ظٹط±ط§طھ ط¬ط¯ظٹط¯ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get cardBg => isDark ? const Color(0xFF151B23) : Colors.white;
  Color get cardBgHover => isDark ? const Color(0xFF1C242E) : const Color(0xFFF8FAFC);

  Color get cardBorder => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFFE2E8F0);

  Color get cardBorderFocused => isDark
      ? primaryColor.withValues(alpha: 0.4)
      : primaryColor.withValues(alpha: 0.3);

  List<BoxShadow> get cardShadow => isDark
      ? [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.05),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ]
      : [
    BoxShadow(
      color: const Color(0xFF64748B).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.04),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ];

  // طھط£ط«ظٹط± ط§ظ„ط¶ط؛ط· ط¹ظ„ظ‰ ط§ظ„ط¨ط·ط§ظ‚ط§طھ
  List<BoxShadow> get cardShadowPressed => isDark
      ? [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ]
      : [
    BoxShadow(
      color: const Color(0xFF64748B).withValues(alpha: 0.12),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„ظ†طµظˆطµ - طھط­ط³ظٹظ† ط§ظ„طھط¨ط§ظٹظ†
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get textColor =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get subtitleColor =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get captionColor =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط¹ظ†ط§طµط± ط§ظ„طھظپط§ط¹ظ„
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get dividerColor => isDark
      ? Colors.white.withValues(alpha: 0.06)
      : const Color(0xFFF1F5F9);

  Color get chipBg =>
      isDark ? const Color(0xFF1E2530) : const Color(0xFFF1F5F9);
  Color get chipSelectedBg => primaryColor;
  Color get chipText => subtitleColor;
  Color get chipSelectedText =>
      isDark ? const Color(0xFF0A0E14) : Colors.white;
  Color get chipBorder => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : const Color(0xFFE2E8F0);

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„ط¨ط­ط« - ظ…ط­ط³ظ‘ظ†
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get searchBg =>
      isDark ? const Color(0xFF1E2530) : Colors.white;
  Color get searchBgFocused =>
      isDark ? const Color(0xFF252D3A) : const Color(0xFFF8FAFC);
  Color get searchBorder => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : const Color(0xFFE2E8F0);
  Color get searchBorderFocused => primaryColor.withValues(alpha: 0.5);
  Color get searchHint => captionColor;

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„طµظˆط± ط§ظ„ط±ظ…ط²ظٹط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  List<Color> get avatarRingGradient => isDark
      ? [
    const Color(0xFF5EEAD4),
    const Color(0xFF14B8A6),
    const Color(0xFF0D9488),
    const Color(0xFF5EEAD4),
  ]
      : [
    const Color(0xFF0D9488),
    const Color(0xFF14B8A6),
    const Color(0xFF5EEAD4),
    const Color(0xFF0D9488),
  ];

  // طھط£ط«ظٹط± طھظˆظ‡ط¬ ظ„ظ„طµظˆط±
  List<BoxShadow> get avatarGlow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: isDark ? 0.4 : 0.25),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  Color get headerIconBg => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFFF1F5F9);

  Color get emptyIconBg => isDark
      ? Colors.white.withValues(alpha: 0.05)
      : const Color(0xFFF1F5F9);

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط£ظ„ظˆط§ظ† ط§ظ„ظ…ظ†طµط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get liveColor => const Color(0xFFEF4444);
  Color get liveColorGlow => const Color(0xFFEF4444).withValues(alpha: 0.4);

  Color get youtubeColor => const Color(0xFFFF0000);
  Color get youtubeColorDark => const Color(0xFFCC0000);

  Color get tiktokBg => isDark ? Colors.white : const Color(0xFF010101);
  Color get tiktokText => isDark ? Colors.black : Colors.white;
  Color get tiktokPink => const Color(0xFFEE1D52);
  Color get tiktokCyan => const Color(0xFF69C9D0);

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„طھط¨ظˆظٹط¨ط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get activeTabBg => primaryColor;
  Color get inactiveTabBg => chipBg;
  Color get activeTabText => chipSelectedText;
  Color get inactiveTabText => chipText;

  Color get videoDurationBg => Colors.black.withValues(alpha: 0.85);

  Color get sectionTitleColor => textColor;

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط£ظ„ظˆط§ظ† ط¥ط¶ط§ظپظٹط© ظ„ظ„ظ€ Glassmorphism
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get glassColor => isDark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.7);

  Color get glassBorder => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.5);

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط£ظ„ظˆط§ظ† ط§ظ„ط¥ط´ط¹ط§ط±ط§طھ ظˆط§ظ„ط­ط§ظ„ط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Color get successColor => const Color(0xFF10B981);
  Color get warningColor => const Color(0xFFF59E0B);
  Color get errorColor => const Color(0xFFEF4444);
  Color get infoColor => const Color(0xFF3B82F6);

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  Gradients ظ…ط­ط³ظ‘ظ†ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      primaryColor,
      primaryDark,
    ],
  );

  LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [
      const Color(0xFF151B23),
      const Color(0xFF1C242E),
    ]
        : [
      Colors.white,
      const Color(0xFFF8FAFC),
    ],
  );

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  Border Radius ظ…ظˆط­ظ‘ط¯ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  Spacing ظ…ظˆط­ظ‘ط¯ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ظ…ط¯ط¯ ط§ظ„ط­ط±ظƒط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
}

