import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiracleColorPreset {
  final String name;
  final String nameEn;
  final Color  primary;
  final Color  bg1;
  final Color  bg2;
  final Color  bg3;
  final Color  neonAccent;
  final String emoji;

  const MiracleColorPreset({
    required this.name,
    required this.nameEn,
    required this.primary,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.neonAccent,
    required this.emoji,
  });
}

const List<MiracleColorPreset> kMiracleColorPresets = [
  MiracleColorPreset(
    name:       'الأزرق الكوني',
    nameEn:     'Cosmic Blue',
    emoji:      '🌌',
    primary:    Color(0xFF00D4FF),
    bg1:        Color(0xFF020818),
    bg2:        Color(0xFF071228),
    bg3:        Color(0xFF0D1F3C),
    neonAccent: Color(0xFF00D4FF),
  ),
  MiracleColorPreset(
    name:       'الأزرق الملكي',
    nameEn:     'Royal Blue',
    emoji:      '👑',
    primary:    Color(0xFF4169E1),
    bg1:        Color(0xFF05071A),
    bg2:        Color(0xFF0A0F2E),
    bg3:        Color(0xFF0F1845),
    neonAccent: Color(0xFF6B8CFF),
  ),
  MiracleColorPreset(
    name:       'السماوي',
    nameEn:     'Sky Cyan',
    emoji:      '🌊',
    primary:    Color(0xFF00BCD4),
    bg1:        Color(0xFF020D14),
    bg2:        Color(0xFF051820),
    bg3:        Color(0xFF082530),
    neonAccent: Color(0xFF00E5FF),
  ),
  MiracleColorPreset(
    name:       'البنفسجي',
    nameEn:     'Nebula Purple',
    emoji:      '🔮',
    primary:    Color(0xFF9C27B0),
    bg1:        Color(0xFF0D0514),
    bg2:        Color(0xFF180A24),
    bg3:        Color(0xFF220F33),
    neonAccent: Color(0xFFCE93D8),
  ),
  MiracleColorPreset(
    name:       'الزمردي',
    nameEn:     'Emerald',
    emoji:      '💎',
    primary:    Color(0xFF00BFA5),
    bg1:        Color(0xFF021410),
    bg2:        Color(0xFF04201A),
    bg3:        Color(0xFF063028),
    neonAccent: Color(0xFF1DE9B6),
  ),
  MiracleColorPreset(
    name:       'الذهبي',
    nameEn:     'Golden',
    emoji:      '⭐',
    primary:    Color(0xFFFFD740),
    bg1:        Color(0xFF141006),
    bg2:        Color(0xFF221A08),
    bg3:        Color(0xFF30240C),
    neonAccent: Color(0xFFFFE57F),
  ),
  MiracleColorPreset(
    name:       'الوردي',
    nameEn:     'Rose Galaxy',
    emoji:      '🌸',
    primary:    Color(0xFFE91E8C),
    bg1:        Color(0xFF14020E),
    bg2:        Color(0xFF230519),
    bg3:        Color(0xFF320826),
    neonAccent: Color(0xFFFF80AB),
  ),
  MiracleColorPreset(
    name:       'البرتقالي',
    nameEn:     'Solar Orange',
    emoji:      '🌅',
    primary:    Color(0xFFFF6D00),
    bg1:        Color(0xFF140800),
    bg2:        Color(0xFF221200),
    bg3:        Color(0xFF301A00),
    neonAccent: Color(0xFFFFAB40),
  ),
];

class MiracleColorProvider extends ChangeNotifier {
  static const _prefKeyIndex      = 'miracle_color_preset_index';
  static const _prefKeyBrightness = 'miracle_color_brightness';

  int    _selectedIndex   = 0;
  double _brightnessShift = 0.5;

  int    get selectedIndex   => _selectedIndex;
  double get brightnessShift => _brightnessShift;

  MiracleColorPreset get current =>
      kMiracleColorPresets[_selectedIndex];

  // ══════════════════════════════════════════════
  //  الألوان الفعلية
  // ══════════════════════════════════════════════
  Color get effectivePrimary =>
      _adjustAccentColor(current.primary, _brightnessShift);

  Color get effectiveNeonAccent =>
      _adjustAccentColor(current.neonAccent, _brightnessShift);

  Color get effectiveBg1 =>
      _adjustBgColor(current.bg1, current.primary, _brightnessShift);

  Color get effectiveBg2 =>
      _adjustBgColor(current.bg2, current.primary, _brightnessShift);

  Color get effectiveBg3 =>
      _adjustBgColor(current.bg3, current.primary, _brightnessShift);

  MiracleColorProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final prefs           = await SharedPreferences.getInstance();
      final savedIndex      = prefs.getInt(_prefKeyIndex) ?? 0;
      final savedBrightness = prefs.getDouble(_prefKeyBrightness) ?? 0.5;

      if (savedIndex >= 0 && savedIndex < kMiracleColorPresets.length) {
        _selectedIndex   = savedIndex;
        _brightnessShift = savedBrightness.clamp(0.0, 1.0);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> selectPreset(int index) async {
    if (index < 0 || index >= kMiracleColorPresets.length) return;
    _selectedIndex = index;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyIndex, index);
    } catch (_) {}
  }

  // ← هذا يُستدعى في onChanged (أثناء السحب) - يُحدّث فوراً
  void setBrightnessShiftImmediate(double value) {
    _brightnessShift = value.clamp(0.0, 1.0);
    notifyListeners(); // ← يُخبر كل الـ widgets بالتغيير فوراً
  }

  // ← هذا يُستدعى في onChangeEnd (عند الانتهاء) - يحفظ فقط
  Future<void> saveBrightnessShift(double value) async {
    _brightnessShift = value.clamp(0.0, 1.0);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKeyBrightness, _brightnessShift);
    } catch (_) {}
  }

  // ── للتوافق مع الكود القديم ──
  Future<void> setBrightnessShift(double value) =>
      saveBrightnessShift(value);

  // ══════════════════════════════════════════════
  //  ACCENT COLOR ADJUSTMENT
  // ══════════════════════════════════════════════
  Color _adjustAccentColor(Color base, double shift) {
    final hsl = HSLColor.fromColor(base);

    if (shift < 0.5) {
      final factor = shift / 0.5;
      // أداكن: نقلل lightness بشكل واضح
      final darkest = hsl
          .withLightness((hsl.lightness * 0.25).clamp(0.02, 0.5))
          .withSaturation((hsl.saturation * 0.6).clamp(0.0, 1.0))
          .toColor();
      return Color.lerp(darkest, base, factor)!;

    } else if (shift > 0.5) {
      final factor = (shift - 0.5) / 0.5;
      // أفتح: نزيد lightness بشكل واضح
      final lightest = hsl
          .withLightness((hsl.lightness + 0.3).clamp(0.0, 0.95))
          .withSaturation((hsl.saturation * 0.8).clamp(0.0, 1.0))
          .toColor();
      return Color.lerp(base, lightest, factor)!;

    } else {
      return base;
    }
  }

  // ══════════════════════════════════════════════
  //  BG COLOR ADJUSTMENT
  // ══════════════════════════════════════════════
  Color _adjustBgColor(Color base, Color primary, double shift) {
    final primaryHsl = HSLColor.fromColor(primary);

    if (shift < 0.5) {
      // ── داكن جداً ──
      // shift=0.0 → أسود تقريباً مع hint خفيف من primary
      // shift=0.5 → اللون الأصلي للخلفية
      final factor = shift / 0.5; // 0.0 → 0.0, 0.5 → 1.0

      // أداكن نسخة: أسود مع hint من primary
      final darkest = primaryHsl
          .withSaturation(0.5)
          .withLightness(0.03) // ← داكن جداً لكن ليس أسود كامل
          .toColor();

      return Color.lerp(darkest, base, factor)!;

    } else if (shift > 0.5) {
      // ── فاتح ──
      // shift=0.5 → اللون الأصلي
      // shift=1.0 → أفتح بوضوح
      final factor = (shift - 0.5) / 0.5; // 0.5 → 0.0, 1.0 → 1.0

      // أفتح نسخة: نفس hue لكن lightness أعلى
      final lightest = primaryHsl
          .withSaturation(0.35)
          .withLightness(0.25) // ← أفتح بوضوح
          .toColor();

      return Color.lerp(base, lightest, factor)!;

    } else {
      // shift == 0.5 → اللون الأصلي بدون تغيير
      return base;
    }
  }
}