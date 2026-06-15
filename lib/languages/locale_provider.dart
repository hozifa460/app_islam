import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_locale';
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  // ═══ اتجاه النص ═══
  // في locale_provider.dart
  TextDirection get textDirection {
    final rtlLanguages = [
      'ar', 'he', 'fa', 'ur', 'ps', 'sd', 'ug', 'yi', 'ku', 'dv'
    ];
    return rtlLanguages.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  // في class LocaleProvider

  // ═══ العلم الحالي ═══
  String get currentFlag {
    const flags = {
      'ar': '🇸🇦', 'en': '🇺🇸', 'fr': '🇫🇷', 'de': '🇩🇪',
      'es': '🇪🇸', 'it': '🇮🇹', 'pt': '🇧🇷', 'nl': '🇳🇱',
      'ru': '🇷🇺', 'tr': '🇹🇷', 'ur': '🇵🇰', 'id': '🇮🇩',
      'ms': '🇲🇾', 'hi': '🇮🇳', 'ja': '🇯🇵', 'zh': '🇨🇳',
      'uz': '🇺🇿', 'sw': '🇹🇿', 'ha': '🇳🇬', 'am': '🇪🇹', 'so': '🇸🇴',
    };
    return flags[_locale.languageCode] ?? '🌐';
  }

  // ═══ اسم اللغة الحالية ═══
  String get currentLangName {
    const names = {
      'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'de': 'Deutsch',
      'es': 'Español', 'it': 'Italiano', 'pt': 'Português', 'nl': 'Nederlands',
      'ru': 'Русский', 'tr': 'Türkçe', 'ur': 'اردو', 'id': 'Bahasa Indonesia',
      'ms': 'Bahasa Melayu', 'hi': 'हिन्दी', 'ja': '日本語', 'zh': '中文',
      'uz': 'Oʻzbekcha', 'sw': 'Kiswahili', 'ha': 'Hausa', 'am': 'አማርኛ', 'so': 'Soomaali',
    };
    return names[_locale.languageCode] ?? 'Unknown';
  }

  // ═══ هل اللغة من اليمين لليسار ═══
  bool get isRtl => textDirection == TextDirection.rtl;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'ar';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (_locale.languageCode == code) return;
    _locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    notifyListeners();
  }
}