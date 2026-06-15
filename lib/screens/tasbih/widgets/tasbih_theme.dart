import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// âœ… ظˆظٹط¯ط¬طھ ظ…ط±ظƒط²ظٹ ظ„ظ„طھط­ظƒظ… ظپظٹ ط£ظ„ظˆط§ظ† ظˆط£ط´ظƒط§ظ„ ط´ط§ط´ط© ط§ظ„طھط³ط¨ظٹط­
class TasbihTheme {
  // ==============================
  // ًںژ¨ ط§ظ„ط£ظ„ظˆط§ظ†
  // ==============================
  static const Color gradientTop = Color(0xFF1B5E20);
  static const Color gradientMid = Color(0xFF66BB6A);
  static const Color gradientBottom = Color(0xFFF7FBF7);

  static const Color cardBackground = Colors.white;
  static const Color dhikrBackground = Color(0xFFF5EEE6);
  static const Color beadInactive = Color(0xFFD8D8D8);
  static const Color stringColor = Color(0xFFBDBDBD);

  static Color mosqueOverlay = Colors.white.withValues(alpha: 0.08);
  static Color mosqueOverlay2 = Colors.white.withValues(alpha: 0.06);

  static Color chipSelected = Colors.white;
  static Color chipUnselected = Colors.white.withValues(alpha: 0.18);
  static Color chipBorderSelected = Colors.white;
  static Color chipBorderUnselected = Colors.white.withValues(alpha: 0.25);
  static Color chipTextSelected = const Color(0xFF1B5E20);
  static Color chipTextUnselected = Colors.white;

  static Color totalBarBg = Colors.white.withValues(alpha: 0.85);
  static Color totalBarBorder = Colors.white.withValues(alpha: 0.7);

  // ==============================
  // ًں“گ ط§ظ„ط£ط¨ط¹ط§ط¯
  // ==============================
  static const double cardRadius = 22.0;
  static const double chipRadius = 18.0;
  static const double chipHeight = 52.0;
  static const double dhikrRadius = 16.0;
  static const double beadRadius = 18.0;
  static const double totalBarRadius = 18.0;

  static const double beadSize = 12.0;
  static const int beadCount = 16;
  static const double beadAreaHeight = 90.0;

  static const double progressBarHeight = 8.0;
  static const double progressBarWidth = 120.0;

  // ==============================
  // ًں”¤ ط£ظ†ظ…ط§ط· ط§ظ„ظ†طµظˆطµ
  // ==============================
  static TextStyle appBarTitle = GoogleFonts.cairo(
    fontWeight: FontWeight.w900,
  );

  static TextStyle headerTitle = GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  static TextStyle headerSubtitle = GoogleFonts.cairo(
    fontSize: 13,
    color: Colors.white.withValues(alpha: 0.85),
  );

  static TextStyle dhikrText = GoogleFonts.amiri(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.7,
  );

  static TextStyle translationText = GoogleFonts.cairo(
    fontSize: 13,
    color: Colors.black87,
    height: 1.5,
  );

  static TextStyle transliterationText = GoogleFonts.cairo(
    fontSize: 12,
    color: Colors.grey.shade700,
  );

  static TextStyle counterText = GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.w900,
  );

  static TextStyle roundText = GoogleFonts.cairo(
    fontSize: 12,
    color: Colors.grey.shade700,
    fontWeight: FontWeight.bold,
  );

  static TextStyle chipText(bool isSelected) => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: isSelected ? chipTextSelected : chipTextUnselected,
  );

  static TextStyle tapHint = GoogleFonts.cairo(
    fontSize: 13,
    color: Colors.grey.shade700,
    fontWeight: FontWeight.bold,
  );

  static TextStyle totalLabel = GoogleFonts.cairo(
    fontWeight: FontWeight.bold,
  );

  static TextStyle totalValue(Color primary) => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: primary,
  );

  // ==============================
  // ًںژ­ ط§ظ„طھط¯ط±ط¬ط§طھ
  // ==============================
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientMid, gradientBottom],
  );

  // ==============================
  // ًں“¦ ط§ظ„ط¸ظ„ط§ظ„
  // ==============================
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 18,
      offset: Offset(0, 10),
    ),
  ];

  // ==============================
  // ًںژ¯ ط§ظ„ط¯ظٹظƒظˆط±
  // ==============================
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: cardShadow,
  );

  static BoxDecoration get dhikrDecoration => BoxDecoration(
    color: dhikrBackground,
    borderRadius: BorderRadius.circular(dhikrRadius),
  );

  static BoxDecoration beadAreaDecoration(Color borderColor) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(beadRadius),
    border: Border.all(color: borderColor),
  );

  static BoxDecoration get totalBarDecoration => BoxDecoration(
    color: totalBarBg,
    borderRadius: BorderRadius.circular(totalBarRadius),
    border: Border.all(color: totalBarBorder),
  );

  static BoxDecoration chipDecoration(bool isSelected) => BoxDecoration(
    color: isSelected ? chipSelected : chipUnselected,
    borderRadius: BorderRadius.circular(chipRadius),
    border: Border.all(
      color: isSelected ? chipBorderSelected : chipBorderUnselected,
      width: 1,
    ),
  );
}