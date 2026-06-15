import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationLoader {
  static final Map<String, Map<String, String>> _cache = {};

  static const String _fallbackLang = 'ar';

  static Future<Map<String, String>> load(String langCode) async {
    // لو موجود في الكاش رجعه فوراً
    if (_cache.containsKey(langCode)) {
      return _cache[langCode]!;
    }

    try {
      final jsonString =
      await rootBundle.loadString('assets/translations/$langCode.json');

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final map = jsonMap.map(
            (key, value) => MapEntry(key, value.toString()),
      );

      _cache[langCode] = map;
      return map;
    } catch (_) {
      // لو فشل تحميل اللغة → fallback للعربية
      if (langCode != _fallbackLang) {
        return load(_fallbackLang);
      }

      // في أسوأ الأحوال
      return {};
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}