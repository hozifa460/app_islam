import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AzkarTheme - المسؤول عن جميع الألوان والتدرجات والأنماط البصرية
/// ═══════════════════════════════════════════════════════════════════════════
class AzkarTheme {
  AzkarTheme._();

  // ═══════════════════════════════════════════
  // الألوان الأساسية
  // ═══════════════════════════════════════════
  static const Color gold = Color(0xFFE6B325);
  static const Color bgDark = Color(0xFF0A0E17);
  static const Color bgLight = Color(0xFFF0F4FF);
  static const Color success = Color(0xFF2ECC71);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textLight = Colors.white;

  // ═══════════════════════════════════════════
  // تدرجات الهيدر
  // ═══════════════════════════════════════════
  static List<Color> headerGradientDark = const [
    Color(0xFF0D1420),
    Color(0xFF1A2744),
    Color(0xFF0F1B35),
  ];

  static List<Color> headerGradientLight = const [
    Color(0xFF1A2744),
    Color(0xFF2D4A8A),
    Color(0xFF1E3A6E),
  ];

  // ═══════════════════════════════════════════
  // تدرجات البطاقات
  // ═══════════════════════════════════════════
  static const List<List<Color>> cardGradientsDark = [
    [Color(0xFF1A3A5C), Color(0xFF0D1F33)],
    [Color(0xFF2D1B4E), Color(0xFF160D26)],
    [Color(0xFF1A3D2E), Color(0xFF0D1F17)],
    [Color(0xFF3D2010), Color(0xFF1F1008)],
    [Color(0xFF1A2D4E), Color(0xFF0D1726)],
    [Color(0xFF3D1A2E), Color(0xFF1F0D17)],
  ];

  static const List<Color> cardAccents = [
    Color(0xFF4A9EFF),
    Color(0xFF9B6FFF),
    Color(0xFF4AFF9E),
    Color(0xFFFFB84A),
    Color(0xFF4ADEFF),
    Color(0xFFFF4A9E),
  ];

  // ═══════════════════════════════════════════
  // الحصول على لون الخلفية
  // ═══════════════════════════════════════════
  static Color getBackgroundColor(bool isDark) {
    return isDark ? bgDark : bgLight;
  }

  // ═══════════════════════════════════════════
  // الحصول على لون النص الرئيسي
  // ═══════════════════════════════════════════
  static Color getTextColor(bool isDark) {
    return isDark ? textLight : textDark;
  }

  // ═══════════════════════════════════════════
  // الحصول على تدرج الهيدر
  // ═══════════════════════════════════════════
  static LinearGradient getHeaderGradient(bool isDark) {
    return LinearGradient(
      colors: isDark ? headerGradientDark : headerGradientLight,
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
  }

  // ═══════════════════════════════════════════
  // الحصول على تدرج البطاقة
  // ═══════════════════════════════════════════
  static LinearGradient getCardGradient(int index, bool isDark, Color accent) {
    final gradientDark = cardGradientsDark[index % cardGradientsDark.length];
    return LinearGradient(
      colors: isDark
          ? gradientDark
          : [Colors.white, accent.withOpacity(0.04)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
  }

  // ═══════════════════════════════════════════
  // الحصول على لون التمييز للبطاقة
  // ═══════════════════════════════════════════
  static Color getCardAccent(int index) {
    return cardAccents[index % cardAccents.length];
  }

  // ═══════════════════════════════════════════
  // الحصول على تدرجات البطاقة الداكنة
  // ═══════════════════════════════════════════
  static List<Color> getCardGradientDark(int index) {
    return cardGradientsDark[index % cardGradientsDark.length];
  }

  // ═══════════════════════════════════════════
  // تنسيق البطاقة
  // ═══════════════════════════════════════════
  static BoxDecoration getCardDecoration({
    required int index,
    required bool isDark,
    required Color accent,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: getCardGradient(index, isDark, accent),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: accent.withOpacity(isDark ? 0.22 : 0.18),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withOpacity(isDark ? 0.1 : 0.07),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق حاوية الأيقونة
  // ═══════════════════════════════════════════
  static BoxDecoration getIconContainerDecoration(Color accent) {
    return BoxDecoration(
      color: accent.withOpacity(0.12),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: accent.withOpacity(0.28),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withOpacity(0.12),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق زر الرجوع
  // ═══════════════════════════════════════════
  static BoxDecoration getBackButtonDecoration(bool isDark) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.25)),
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق بطاقة الذكر المكتمل
  // ═══════════════════════════════════════════
  static BoxDecoration getCompletedZekrDecoration(bool isDark, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          success.withOpacity(isDark ? 0.15 : 0.08),
          success.withOpacity(isDark ? 0.05 : 0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: success.withOpacity(0.4),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: success.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق بطاقة الذكر غير المكتمل
  // ═══════════════════════════════════════════
  static BoxDecoration getActiveZekrDecoration(bool isDark, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          isDark ? const Color(0xFF1E2533) : Colors.white,
          isDark ? const Color(0xFF151B26) : const Color(0xFFFAFAFA),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : gold.withOpacity(0.15),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق صندوق المعلومات
  // ═══════════════════════════════════════════
  static BoxDecoration getInfoBoxDecoration(Color color, bool isDark) {
    return BoxDecoration(
      color: color.withOpacity(isDark ? 0.1 : 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(isDark ? 0.2 : 0.15)),
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق العداد الدائري
  // ═══════════════════════════════════════════
  static BoxDecoration getCounterDecoration(bool isDark) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: isDark ? const Color(0xFF1E2533) : Colors.white,
      border: Border.all(color: gold.withOpacity(0.3), width: 2),
      boxShadow: [
        BoxShadow(
          color: gold.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق شارة الإكتمال
  // ═══════════════════════════════════════════
  static BoxDecoration getCompletedBadgeDecoration() {
    return BoxDecoration(
      color: success.withOpacity(0.15),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: success, width: 2),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// AzkarSizes - المقاسات والأبعاد المتجاوبة
/// ═══════════════════════════════════════════════════════════════════════════
class AzkarSizes {
  final Size screenSize;

  AzkarSizes(this.screenSize);

  double get cardHeight => (screenSize.width * 0.28).clamp(90.0, 120.0);
  double get iconContainerSize => (screenSize.width * 0.15).clamp(48.0, 64.0);
  double get iconSize => (screenSize.width * 0.08).clamp(24.0, 36.0);
  double get titleFontSize => (screenSize.width * 0.044).clamp(14.0, 20.0);
  double get subFontSize => (screenSize.width * 0.03).clamp(10.0, 13.0);
  double get headerExpandedHeight => (screenSize.height * 0.24).clamp(160.0, 240.0);
  double get basePadding => (screenSize.width * 0.045).clamp(14.0, 24.0);
  double get headerIconSize => (screenSize.width * 0.16).clamp(52.0, 80.0);
  double get counterSize => (screenSize.width * 0.22).clamp(60.0, 90.0);
  double get arrowContainerSize => (screenSize.width * 0.085).clamp(26.0, 38.0);
  double get arrowIconSize => (screenSize.width * 0.038).clamp(11.0, 17.0);
}