import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// BooksTheme - المسؤول عن جميع الألوان والتدرجات والأنماط البصرية
/// ═══════════════════════════════════════════════════════════════════════════
class BooksTheme {
  BooksTheme._();

  // ═══════════════════════════════════════════
  // الألوان الأساسية
  // ═══════════════════════════════════════════
  static const Color gold = Color(0xFFE6B325);
  static const Color bgDark = Color(0xFF0A0E17);
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color cardDark = Color(0xFF151B26);
  static const Color cardLight = Colors.white;
  static const Color textDark = Colors.white;
  static const Color textLight = Color(0xFF1A1A1A);
  static const Color subtextDark = Colors.white70;
  static const Color subtextLight = Colors.black54;
  static const Color pdfBg = Color(0xFFFDF8EE);

  // ═══════════════════════════════════════════
  // الحصول على لون الخلفية
  // ═══════════════════════════════════════════
  static Color getBackgroundColor(bool isDark) {
    return isDark ? bgDark : bgLight;
  }

  static Color getCardColor(bool isDark) {
    return isDark ? cardDark : cardLight;
  }

  static Color getTextColor(bool isDark) {
    return isDark ? textDark : textLight;
  }

  static Color getSubTextColor(bool isDark) {
    return isDark ? subtextDark : subtextLight;
  }

  // ═══════════════════════════════════════════
  // تنسيقات البطاقات
  // ═══════════════════════════════════════════
  static BoxDecoration getCardDecoration(bool isDark) {
    return BoxDecoration(
      color: getCardColor(isDark),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: gold.withOpacity(0.18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق شريط البحث
  // ═══════════════════════════════════════════
  static BoxDecoration getSearchBarDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.1) : gold.withOpacity(0.2),
      ),
      boxShadow: isDark
          ? []
          : [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق الفلاتر
  // ═══════════════════════════════════════════
  static BoxDecoration getFilterChipDecoration({
    required bool isSelected,
    required bool isDark,
  }) {
    return BoxDecoration(
      color: isSelected
          ? gold.withOpacity(isDark ? 0.2 : 0.8)
          : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSelected
            ? gold.withOpacity(isDark ? 0.5 : 1.0)
            : (isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.3)),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق البانر اليومي
  // ═══════════════════════════════════════════
  static BoxDecoration getBannerDecoration(
      List<Color> gradientColors,
      bool isDark,
      ) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق أيقونة التحميل
  // ═══════════════════════════════════════════
  static BoxDecoration getDownloadIconDecoration(Color statusColor) {
    return BoxDecoration(
      color: statusColor.withOpacity(0.9),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    );
  }

  // ═══════════════════════════════════════════
  // ألوان حالة التحميل
  // ═══════════════════════════════════════════
  static Color downloadStatusColor(String status) {
    switch (status) {
      case 'full':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.black.withOpacity(0.7);
    }
  }

  static IconData downloadStatusIcon(String status) {
    switch (status) {
      case 'full':
        return Icons.check;
      case 'partial':
        return Icons.downloading_rounded;
      default:
        return Icons.cloud_download;
    }
  }

  static String downloadStatusLabel(String status) {
    switch (status) {
      case 'full':
        return 'محمّل بالكامل';
      case 'partial':
        return 'محمّل جزئيًا';
      default:
        return 'غير محمّل';
    }
  }

  static Color downloadStatusLabelColor(String status) {
    switch (status) {
      case 'full':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ═══════════════════════════════════════════
  // تنسيق الهيدر المتدرج
  // ═══════════════════════════════════════════
  static BoxDecoration getGradientHeaderDecoration(Color primaryColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.78),
        ],
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.18),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق زر الرجوع
  // ═══════════════════════════════════════════
  static BoxDecoration getBackButtonDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : gold.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق شريط التقدم
  // ═══════════════════════════════════════════
  static BoxDecoration getProgressContainerDecoration(
      bool isDark,
      Color borderColor,
      ) {
    return BoxDecoration(
      color: getCardColor(isDark),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق شارة العدد
  // ═══════════════════════════════════════════
  static BoxDecoration getBadgeDecoration(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.20)),
    );
  }

  // ═══════════════════════════════════════════
  // تنسيق أزرار التحكم في القارئ
  // ═══════════════════════════════════════════
  static BoxDecoration getLockButtonDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300, width: 1),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// BooksSizes - المقاسات والأبعاد المتجاوبة
/// ═══════════════════════════════════════════════════════════════════════════
class BooksSizes {
  final Size screenSize;

  BooksSizes(this.screenSize);

  bool get isSmall => screenSize.width < 360;
  double get bookWidth => isSmall ? 104.0 : 118.0;
  double get bookHeight => isSmall ? 210.0 : 228.0;
  double get coverHeight => 155.0;

  int get gridCrossAxisCount => screenSize.width < 430 ? 2 : 3;
  double get gridChildAspectRatio => isSmall ? 0.68 : 0.75;
  double get gridSpacing => isSmall ? 10.0 : 12.0;
}