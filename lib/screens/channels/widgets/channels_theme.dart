import 'package:flutter/material.dart';

class ChannelsTheme {
  final bool isDark;
  ChannelsTheme({required this.isDark});


  // ═══════════════════════════════════════════
  //  الألوان الأساسية - محسّنة
  // ═══════════════════════════════════════════

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
      ? const Color(0xFF5EEAD4).withOpacity(0.15)
      : const Color(0xFF0D9488).withOpacity(0.08);

  // ═══════════════════════════════════════════
  //  البطاقات - محسّنة مع تأثيرات جديدة
  // ═══════════════════════════════════════════

  Color get cardBg => isDark ? const Color(0xFF151B23) : Colors.white;
  Color get cardBgHover => isDark ? const Color(0xFF1C242E) : const Color(0xFFF8FAFC);

  Color get cardBorder => isDark
      ? Colors.white.withOpacity(0.08)
      : const Color(0xFFE2E8F0);

  Color get cardBorderFocused => isDark
      ? primaryColor.withOpacity(0.4)
      : primaryColor.withOpacity(0.3);

  List<BoxShadow> get cardShadow => isDark
      ? [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: primaryColor.withOpacity(0.05),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ]
      : [
    BoxShadow(
      color: const Color(0xFF64748B).withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: primaryColor.withOpacity(0.04),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ];

  // تأثير الضغط على البطاقات
  List<BoxShadow> get cardShadowPressed => isDark
      ? [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ]
      : [
    BoxShadow(
      color: const Color(0xFF64748B).withOpacity(0.12),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════
  //  النصوص - تحسين التباين
  // ═══════════════════════════════════════════

  Color get textColor =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get subtitleColor =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get captionColor =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // ═══════════════════════════════════════════
  //  عناصر التفاعل
  // ═══════════════════════════════════════════

  Color get dividerColor => isDark
      ? Colors.white.withOpacity(0.06)
      : const Color(0xFFF1F5F9);

  Color get chipBg =>
      isDark ? const Color(0xFF1E2530) : const Color(0xFFF1F5F9);
  Color get chipSelectedBg => primaryColor;
  Color get chipText => subtitleColor;
  Color get chipSelectedText =>
      isDark ? const Color(0xFF0A0E14) : Colors.white;
  Color get chipBorder => isDark
      ? Colors.white.withOpacity(0.1)
      : const Color(0xFFE2E8F0);

  // ═══════════════════════════════════════════
  //  البحث - محسّن
  // ═══════════════════════════════════════════

  Color get searchBg =>
      isDark ? const Color(0xFF1E2530) : Colors.white;
  Color get searchBgFocused =>
      isDark ? const Color(0xFF252D3A) : const Color(0xFFF8FAFC);
  Color get searchBorder => isDark
      ? Colors.white.withOpacity(0.1)
      : const Color(0xFFE2E8F0);
  Color get searchBorderFocused => primaryColor.withOpacity(0.5);
  Color get searchHint => captionColor;

  // ═══════════════════════════════════════════
  //  الصور الرمزية
  // ═══════════════════════════════════════════

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

  // تأثير توهج للصور
  List<BoxShadow> get avatarGlow => [
    BoxShadow(
      color: primaryColor.withOpacity(isDark ? 0.4 : 0.25),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  Color get headerIconBg => isDark
      ? Colors.white.withOpacity(0.08)
      : const Color(0xFFF1F5F9);

  Color get emptyIconBg => isDark
      ? Colors.white.withOpacity(0.05)
      : const Color(0xFFF1F5F9);

  // ═══════════════════════════════════════════
  //  ألوان المنصات
  // ═══════════════════════════════════════════

  Color get liveColor => const Color(0xFFEF4444);
  Color get liveColorGlow => const Color(0xFFEF4444).withOpacity(0.4);

  Color get youtubeColor => const Color(0xFFFF0000);
  Color get youtubeColorDark => const Color(0xFFCC0000);

  Color get tiktokBg => isDark ? Colors.white : const Color(0xFF010101);
  Color get tiktokText => isDark ? Colors.black : Colors.white;
  Color get tiktokPink => const Color(0xFFEE1D52);
  Color get tiktokCyan => const Color(0xFF69C9D0);

  // ═══════════════════════════════════════════
  //  التبويبات
  // ═══════════════════════════════════════════

  Color get activeTabBg => primaryColor;
  Color get inactiveTabBg => chipBg;
  Color get activeTabText => chipSelectedText;
  Color get inactiveTabText => chipText;

  Color get videoDurationBg => Colors.black.withOpacity(0.85);

  Color get sectionTitleColor => textColor;

  // ═══════════════════════════════════════════
  //  ألوان إضافية للـ Glassmorphism
  // ═══════════════════════════════════════════

  Color get glassColor => isDark
      ? Colors.white.withOpacity(0.05)
      : Colors.white.withOpacity(0.7);

  Color get glassBorder => isDark
      ? Colors.white.withOpacity(0.1)
      : Colors.white.withOpacity(0.5);

  // ═══════════════════════════════════════════
  //  ألوان الإشعارات والحالات
  // ═══════════════════════════════════════════

  Color get successColor => const Color(0xFF10B981);
  Color get warningColor => const Color(0xFFF59E0B);
  Color get errorColor => const Color(0xFFEF4444);
  Color get infoColor => const Color(0xFF3B82F6);

  // ═══════════════════════════════════════════
  //  Gradients محسّنة
  // ═══════════════════════════════════════════

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

  // ═══════════════════════════════════════════
  //  Border Radius موحّدة
  // ═══════════════════════════════════════════

  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // ═══════════════════════════════════════════
  //  Spacing موحّدة
  // ═══════════════════════════════════════════

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // ═══════════════════════════════════════════
  //  مدد الحركات
  // ═══════════════════════════════════════════

  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
}

