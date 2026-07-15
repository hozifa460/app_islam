import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';

class HijriTheme {
  final bool isDark;
  final Color primaryColor;

  HijriTheme({required this.isDark, required this.primaryColor});

  // ==============================
  // ًںژ¨ Colors
  // ==============================
  static const Color gold = Color(0xFFD4A843);

  Color get bg => isDark ? const Color(0xFF080C14) : const Color(0xFFF5F3EE);
  Color get card => isDark ? const Color(0xFF131A27) : Colors.white;
  Color get text => isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get subText => isDark ? Colors.white60 : Colors.black45;

  Color get cardBorder => isDark ? Colors.white10 : primaryColor.withValues(alpha: 0.06);

  // ==============================
  // ًں“گ Dimensions
  // ==============================
  static const double cardRadius = 22.0;
  static const double infoCardRadius = 18.0;
  static const double badgeRadius = 10.0;

  // ==============================
  // ًں“گ Responsive Helpers
  // ==============================
  double padH(double w) {
    if (w < 360) return 12.0;
    if (w > 600) return 28.0;
    return 16.0;
  }

  bool isCompact(double w) => w < 360;
  bool isTablet(double w) => w > 600;

  // ==============================
  // ًں“¦ Shadows
  // ==============================
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: isDark ? 0.08 : 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  List<BoxShadow> get calendarShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // ==============================
  // ًںژ­ Gradients
  // ==============================
  LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryColor,
      Color.lerp(primaryColor, const Color(0xFF0A0E17), 0.3)!,
      Color.lerp(primaryColor, const Color(0xFF0A0E17), 0.5)!,
    ],
  );

  // ==============================
  // ًں”¤ Text Styles
  // ==============================
  TextStyle hijriDateStyle(bool compact, bool tablet) => GoogleFonts.amiri(
    color: Colors.white,
    fontSize: compact ? 26 : tablet ? 38 : 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  TextStyle infoTitleStyle(bool compact) => GoogleFonts.cairo(
    fontSize: compact ? 9 : 10,
    color: subText,
    fontWeight: FontWeight.w600,
  );

  TextStyle infoValueStyle(bool compact) => GoogleFonts.cairo(
    fontSize: compact ? 13 : 16,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  // ==============================
  // ًں”§ Helpers
  // ==============================
  static String formatNum(int n, BuildContext context) {
    // ط¥ط°ط§ ظ„ظ… طھظƒظ† ط§ظ„ظ„ط؛ط© ط¹ط±ط¨ظٹط©طŒ ط£ط±ط¬ط¹ ط§ظ„ط£ط±ظ‚ط§ظ… ط§ظ„ط¥ظ†ط¬ظ„ظٹط²ظٹط© ط§ظ„ط¹ط§ط¯ظٹط©
    if (context.tr.locale.languageCode != 'ar') return n.toString();

    const nums = {
      '0': '٠', '1': 'ظ،', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
    };
    return n.toString().split('').map((e) => nums[e] ?? e).join();
  }

  static String getWeekday(DateTime date, BuildContext context) { // ًں‘ˆ طھظ…طھ ط¥ط¶ط§ظپط© context ظ‡ظ†ط§
    final days = [
      context.tr.dayMonday,
      context.tr.dayTuesday,
      context.tr.dayWednesday,
      context.tr.dayThursday,
      context.tr.dayFriday,
      context.tr.daySaturday,
      context.tr.daySunday
    ];
    return days[(date.weekday - 1) % 7];
  }
}