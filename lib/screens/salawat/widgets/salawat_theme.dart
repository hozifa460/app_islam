import 'package:flutter/material.dart';

class SalawatTheme {
  final bool isDark;
  final Color primaryColor;

  late final Color bgColor;
  late final Color cardColor;
  late final Color textColor;
  late final Color subtitleColor;
  late final Color accentGold;
  late final Color deepGreen;

  // Border & Shadow
  late final Color cardBorderColor;
  late final Color activeBorderColor;
  late final Color inactiveBorderColor;
  late final List<BoxShadow> cardShadow;

  // Gradients
  late final LinearGradient headerGradient;
  late final LinearGradient enabledStatusGradient;
  late final LinearGradient hadithGradient;

  // Sizes
  static const double cardRadius = 20.0;
  static const double smallRadius = 14.0;
  static const double iconContainerSize = 52.0;
  static const double smallIconSize = 40.0;
  static const double statusIconSize = 48.0;

  // Spacing
  static const double sectionSpacing = 16.0;
  static const double innerPadding = 18.0;
  static const double horizontalPadding = 20.0;

  SalawatTheme({
    required this.isDark,
    required this.primaryColor,
  }) {
    bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F3EE);
    cardColor = isDark ? const Color(0xFF141C2B) : Colors.white;
    textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    subtitleColor =
    isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF7A7A7A);
    accentGold = const Color(0xFFD4A847);
    deepGreen = primaryColor;

    cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.withValues(alpha: 0.12);

    activeBorderColor = deepGreen.withValues(alpha: 0.3);
    inactiveBorderColor = cardBorderColor;

    cardShadow = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.04),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];

    headerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        deepGreen,
        deepGreen.withValues(alpha: 0.85),
        const Color(0xFF0D3B2E),
      ],
    );

    enabledStatusGradient = LinearGradient(
      colors: [
        deepGreen.withValues(alpha: 0.15),
        accentGold.withValues(alpha: 0.08),
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    hadithGradient = LinearGradient(
      colors: [
        accentGold.withValues(alpha: 0.1),
        accentGold.withValues(alpha: 0.03),
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
  }

  // â”€â”€â”€ Helper: chip colors â”€â”€â”€
  Color chipBgColor(bool isSelected) {
    if (isSelected) return deepGreen;
    return isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.08);
  }

  Color chipBorderColor(bool isSelected) {
    if (isSelected) return deepGreen;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.15);
  }

  Color chipTextColor(bool isSelected) {
    if (isSelected) return Colors.white;
    return textColor.withValues(alpha: 0.7);
  }

  // â”€â”€â”€ Helper: sound option colors â”€â”€â”€
  Color soundOptionBg(bool isSelected) {
    if (isSelected) return deepGreen.withValues(alpha: 0.1);
    return isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.grey.withValues(alpha: 0.05);
  }

  Color soundOptionBorder(bool isSelected) {
    if (isSelected) return deepGreen.withValues(alpha: 0.4);
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.withValues(alpha: 0.1);
  }

  // â”€â”€â”€ Convenience: gradient for selected chip â”€â”€â”€
  LinearGradient? chipGradient(bool isSelected) {
    if (!isSelected) return null;
    return LinearGradient(
      colors: [deepGreen, deepGreen.withValues(alpha: 0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient? soundOptionGradient(bool isSelected) {
    if (!isSelected) return null;
    return LinearGradient(
      colors: [
        deepGreen.withValues(alpha: 0.1),
        deepGreen.withValues(alpha: 0.03),
      ],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    );
  }
}