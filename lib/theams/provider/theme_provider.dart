// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // â”€â”€â”€ ط§ظ„ط£ظ„ظˆط§ظ† ط§ظ„ظ…طھط§ط­ط© â”€â”€â”€
  static const List<Color> appColors = [
    Color(0xFF1B5E20), // ط£ط®ط¶ط± ط¥ط³ظ„ط§ظ…ظٹ
    Color(0xFF0D47A1), // ط£ط²ط±ظ‚ ط³ظ…ط§ظˆظٹ
    Color(0xFF4A148C), // ط¨ظ†ظپط³ط¬ظٹ
    Color(0xFF880E4F), // ظˆط±ط¯ظٹ
    Color(0xFF006064), // طھظٹظ„
    Color(0xFFE65100), // ط¨ط±طھظ‚ط§ظ„ظٹ
    Color(0xFF1A237E), // ظ†ظٹظ„ظٹ
    Color(0xFF3E2723), // ط¨ظ†ظٹ
    Color(0xFF263238), // ط±ظ…ط§ط¯ظٹ
    Color(0xFFB71C1C), // ط£ط­ظ…ط±
    Color(0xFF00695C), // ط£ط®ط¶ط± ط²ظ…ط±ط¯ظٹ
    Color(0xFF4E342E), // ط¨ظ†ظٹ ط´ظˆظƒظˆظ„ط§طھط©
  ];

  static const List<String> colorNames = [
    'أخضر إسلامي',
    'أزرق سماوي',
    'بنفسجي',
    'وردي',
    'تيل',
    'برتقالي',
    'نيلي',
    'بني',
    'رمادي',
    'أحمر',
    'أخضر زمردي',
    'بني شوكولاتة',
  ];

  static const List<IconData> colorIcons = [
    Icons.mosque_rounded,
    Icons.cloud_rounded,
    Icons.auto_awesome_rounded,
    Icons.favorite_rounded,
    Icons.water_rounded,
    Icons.wb_sunny_rounded,
    Icons.nights_stay_rounded,
    Icons.landscape_rounded,
    Icons.filter_drama_rounded,
    Icons.local_fire_department_rounded,
    Icons.park_rounded,
    Icons.coffee_rounded,
  ];

  // â”€â”€â”€ ط§ظ„ط®ظ„ظپظٹط§طھ â”€â”€â”€
  static const Color bgDark = Color(0xFF0A0E17);
  static const Color bgLight = Color(0xFFF0F4FF);
  static const Color cardDark = Color(0xFF111827);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A2332);
  static const Color surfaceLight = Color(0xFFF8FAFF);

  // â”€â”€â”€ ط§ظ„ط­ط§ظ„ط© â”€â”€â”€
  bool _isDarkMode = true;
  int _selectedColorIndex = 0;
  bool _isLoaded = false;

  // â”€â”€â”€ Getters â”€â”€â”€
  bool get isDarkMode => _isDarkMode;
  int get selectedColorIndex => _selectedColorIndex;
  bool get isLoaded => _isLoaded;

  Color get primaryColor => appColors[_selectedColorIndex];
  String get primaryColorName => colorNames[_selectedColorIndex];
  IconData get primaryColorIcon => colorIcons[_selectedColorIndex];

  Color get backgroundColor => _isDarkMode ? bgDark : bgLight;
  Color get cardColor => _isDarkMode ? cardDark : cardLight;
  Color get surfaceColor => _isDarkMode ? surfaceDark : surfaceLight;

  Color get textPrimary =>
      _isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
  Color get textSecondary =>
      _isDarkMode ? Colors.white70 : const Color(0xFF4A4A6A);
  Color get textHint =>
      _isDarkMode ? Colors.white38 : const Color(0xFF9E9E9E);

  Color get dividerColor =>
      _isDarkMode ? Colors.white12 : Colors.black12;

  Color get primaryLight => primaryColor.withValues(alpha: 0.15);
  Color get primaryMedium => primaryColor.withValues(alpha: 0.3);

  // â”€â”€â”€ ط£ظ„ظˆط§ظ† ظ…ط´طھظ‚ط© ظ…ظپظٹط¯ط© â”€â”€â”€
  Color get successColor => const Color(0xFF4CAF50);
  Color get warningColor => const Color(0xFFFFA726);
  Color get errorColor => const Color(0xFFEF5350);
  Color get infoColor => const Color(0xFF42A5F5);

  // â”€â”€â”€ Gradient ط§ظ„ط±ط¦ظٹط³ظٹ â”€â”€â”€
  LinearGradient get primaryGradient => LinearGradient(
    colors: [
      primaryColor,
      Color.lerp(primaryColor, Colors.black, 0.3)!,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get cardGradient => LinearGradient(
    colors: _isDarkMode
        ? [
      primaryColor.withValues(alpha: 0.08),
      primaryColor.withValues(alpha: 0.02),
    ]
        : [
      primaryColor.withValues(alpha: 0.06),
      primaryColor.withValues(alpha: 0.01),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get headerGradient => LinearGradient(
    colors: [
      primaryColor,
      Color.lerp(primaryColor, Colors.purple, 0.3)!,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // â”€â”€â”€ BoxDecoration ط¬ط§ظ‡ط²ط© â”€â”€â”€
  BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: primaryColor.withValues(alpha: _isDarkMode ? 0.1 : 0.08),
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withValues(alpha: _isDarkMode ? 0.05 : 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  BoxDecoration get elevatedCardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: primaryColor.withValues(alpha: 0.15),
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  BoxDecoration get glassDecoration => BoxDecoration(
    color: (_isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color:
      (_isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
    ),
  );

  // â”€â”€â”€ TextStyles ط¬ط§ظ‡ط²ط© â”€â”€â”€
  TextStyle get titleLarge => TextStyle(
    color: textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  TextStyle get titleMedium => TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  TextStyle get titleSmall => TextStyle(
    color: textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  TextStyle get bodyLarge => TextStyle(
    color: textSecondary,
    fontSize: 16,
  );

  TextStyle get bodyMedium => TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  TextStyle get bodySmall => TextStyle(
    color: textHint,
    fontSize: 12,
  );

  TextStyle get accentText => TextStyle(
    color: primaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // â”€â”€â”€ طھط­ظ…ظٹظ„ ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ â”€â”€â”€
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _selectedColorIndex = (prefs.getInt('colorIndex') ?? 0)
        .clamp(0, appColors.length - 1);
    _isLoaded = true;
    notifyListeners();
  }

  // â”€â”€â”€ ط­ظپط¸ ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ â”€â”€â”€
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('colorIndex', _selectedColorIndex);
  }

  // â”€â”€â”€ طھط؛ظٹظٹط± ط§ظ„ظˆط¶ط¹ â”€â”€â”€
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _savePreferences();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    _savePreferences();
    notifyListeners();
  }

  // â”€â”€â”€ طھط؛ظٹظٹط± ط§ظ„ظ„ظˆظ† â”€â”€â”€
  void setColorIndex(int index) {
    if (index < 0 || index >= appColors.length) return;
    if (_selectedColorIndex == index) return;
    _selectedColorIndex = index;
    _savePreferences();
    notifyListeners();
  }

  // â”€â”€â”€ ThemeData ظ„ظ„طھط·ط¨ظٹظ‚ â”€â”€â”€
  ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: bgLight,
    useMaterial3: true,
  );

  ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: bgDark,
    useMaterial3: true,
  );
}