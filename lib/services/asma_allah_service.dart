// lib/services/asma_allah_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';

class AsmaAllahService {
  static final Map<String, List<Map<String, dynamic>>> _cachedData = {};

  // ═══ دوال مساعدة للتعرف على نوع النص ═══

  static bool _hasArabic(String text) =>
      RegExp(r'[؀-ۿ]').hasMatch(text);

  static bool _hasLatin(String text) =>
      RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(text);

  static bool _hasAsian(String text) =>
      RegExp(r'[\u3000-\u9fff\uac00-\ud7af]').hasMatch(text);

  /// هل النص اسم منقحر مثل Ar-Rahman, Al-Malik
  static bool _isTransliteration(String text) {
    text = text.trim();
    // يبدأ بـ Al- أو Ar- أو As- إلخ
    if (RegExp(r'^(Al|Ar|As|Az|Ad|At|An|Ath|Adh)-',
        caseSensitive: false)
        .hasMatch(text)) return true;
    // أو نص إنجليزي قصير جداً مثل "Allah"
    if (RegExp(r'^[A-Z][a-z]+$').hasMatch(text)) return true;
    return false;
  }

  /// اختصار النص
  static String _shorten(String text, {int maxWords = 2}) {
    text = text.trim();
    // للغات الآسيوية
    if (_hasAsian(text)) {
      return text.length > 7 ? '${text.substring(0, 6)}..' : text;
    }
    // اختصر بالكلمات
    final words = text.trim().split(RegExp(r'[\s/]+'));
    if (words.length <= maxWords) return text.trim();
    return words.take(maxWords).join(' ');
  }

  /// استخراج الاسم للعرض في الدوائر
  static String extractDisplayName(String fullName, String langCode) {

    // ═══ اللغة العربية ═══
    if (langCode == 'ar') return fullName;

    final trimmed = fullName.trim();

    // ═══ الخطوة 1: استخرج ما قبل القوس ═══
    String beforeParen = '';
    String insideParen = '';

    if (trimmed.contains('(') && trimmed.contains(')')) {
      beforeParen = trimmed.split('(').first.trim();
      final start = trimmed.indexOf('(') + 1;
      final end = trimmed.lastIndexOf(')');
      if (end > start) {
        insideParen = trimmed.substring(start, end).trim();
      }
    }

    // ═══ الخطوة 2: هل ما قبل القوس هو الترجمة المحلية؟ ═══
    if (beforeParen.isNotEmpty) {
      // إذا لم يكن اسماً منقحراً ولا عربياً = ترجمة محلية ✅
      if (!_isTransliteration(beforeParen) && !_hasArabic(beforeParen)) {
        return _shorten(beforeParen);
      }
      // إذا كان عربياً = اللغة أردو (الترجمة بعد الشرطة)
      if (_hasArabic(beforeParen) && !_hasLatin(beforeParen)) {
        // ابحث عن الترجمة بعد " - "
        if (trimmed.contains(' - ')) {
          final afterDash = trimmed.split(' - ').last.trim();
          if (afterDash.isNotEmpty && !_hasArabic(afterDash)) {
            return _shorten(afterDash);
          }
        }
      }
    }

    // ═══ الخطوة 3: إذا كان فيه " - " ═══
    if (trimmed.contains(' - ')) {
      final parts = trimmed.split(' - ');
      final afterDash = parts.last.trim();
      final firstPart = parts.first.trim();

      // الترجمة دائماً بعد الشرطة إذا لم تكن عربية
      if (afterDash.isNotEmpty && !_hasArabic(afterDash)) {
        return _shorten(afterDash);
      }

      // إذا كان ما قبل الشرطة ليس منقحراً
      if (!_isTransliteration(firstPart) && !_hasArabic(firstPart)) {
        return _shorten(firstPart);
      }
    }

    // ═══ الخطوة 4: داخل القوس ═══
    if (insideParen.isNotEmpty && insideParen.contains(' - ')) {
      // مثال داخل القوس: "Ar-Rashid - الرشيد"
      // الجزء الأخير هو العربي، الأول هو الإنجليزي
      // لا نريد أياً منهما هنا
    }

    // ═══ الخطوة 5: خذ ما قبل القوس إذا كان موجوداً ═══
    if (beforeParen.isNotEmpty && !_hasArabic(beforeParen)) {
      return _shorten(beforeParen);
    }

    // ═══ الخطوة 6: اختصر النص الكامل ═══
    if (trimmed.length <= 15) return trimmed;
    return _shorten(trimmed);
  }

  /// استخراج الاسم العربي
  static String extractArabicName(String fullName) {
    // البحث عن نص بين قوسين
    if (fullName.contains('(') && fullName.contains(')')) {
      final start = fullName.indexOf('(') + 1;
      final end = fullName.lastIndexOf(')');
      if (end > start) {
        final inside = fullName.substring(start, end).trim();

        // داخل القوس فيه " - " مثل "Ar-Rashid - الرشيد"
        if (inside.contains(' - ')) {
          final arabicPart = inside.split(' - ').last.trim();
          if (_hasArabic(arabicPart)) return arabicPart;
        }

        // داخل القوس عربي فقط مثل "الرحمن"
        if (_hasArabic(inside) && !_hasLatin(inside)) {
          return inside.trim();
        }

        // استخرج الكلمات العربية فقط
        final arabicWords = RegExp(r'[؀-ۿ\s]+')
            .allMatches(inside)
            .map((m) => m.group(0)!.trim())
            .where((w) => w.isNotEmpty)
            .join(' ');
        if (arabicWords.isNotEmpty) return arabicWords.trim();
      }
    }

    // ابحث في النص الكامل
    final arabicWords = RegExp(r'[؀-ۿ]+')
        .allMatches(fullName)
        .map((m) => m.group(0)!)
        .join(' ');
    if (arabicWords.isNotEmpty) return arabicWords.trim();

    return '';
  }

  static Future<List<Map<String, dynamic>>> loadAsmaAllah(
      String langCode) async {
    if (_cachedData.containsKey(langCode)) {
      return _cachedData[langCode]!;
    }

    String jsonString;
    try {
      jsonString = await rootBundle
          .loadString('assets/asmaaAllah/asmaa_$langCode.json');
    } catch (_) {
      jsonString = await rootBundle
          .loadString('assets/asmaaAllah/asmaa_ar.json');
    }

    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final list = List<Map<String, dynamic>>.from(jsonData['asma_allah']);

    _cachedData[langCode] = list;
    return list;
  }

  static Future<Map<String, dynamic>> getNameByOrder(
      int order, String langCode) async {
    final data = await loadAsmaAllah(langCode);
    final item = data.firstWhere(
          (item) => item['id'] == order,
      orElse: () => data.first,
    );

    final fullName = item['name'] as String;
    return {
      ...item,
      'fullName': fullName,
      'displayName': extractDisplayName(fullName, langCode),
      'arabicName': extractArabicName(fullName),
    };
  }

  static Future<List<Map<String, String>>> getNamesSimple(
      String langCode) async {
    final data = await loadAsmaAllah(langCode);
    return data.map<Map<String, String>>((item) {
      final fullName = (item['name'] ?? '') as String;
      return {
        'name': fullName,
        'displayName': extractDisplayName(fullName, langCode),
        'arabicName': extractArabicName(fullName),
        'meaning': (item['meaning'] ?? '') as String,
      };
    }).toList();
  }

  static void clearCache() {
    _cachedData.clear();
  }
}