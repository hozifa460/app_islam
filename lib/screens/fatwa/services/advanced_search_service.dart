// services/advanced_search_service.dart
import 'dart:math';

import '../models/fatwa_model.dart';
import 'fatwa_search_service.dart';

class AdvancedSearchService {

  // ══════════════════════════════════════
  // البحث الرئيسي المحسّن
  // ══════════════════════════════════════
  static Future<List<FatwaSearchResult>> search(
      String query,
      List<Fatwa> fatawa, {
        String? scholarFilter,
        String? categoryFilter,
        int topK = 20,
      }) async {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = _normalize(query);
    final queryTokens = _tokenize(normalizedQuery);
    final expandedTokens = _expandWithSynonyms(queryTokens);

    List<FatwaSearchResult> results = [];

    for (var fatwa in fatawa) {
      if (scholarFilter != null && fatwa.scholar != scholarFilter) continue;
      if (categoryFilter != null && fatwa.category != categoryFilter) continue;

      final score = _calculateScore(
        query: normalizedQuery,
        tokens: expandedTokens,
        fatwa: fatwa,
      );

      if (score > 0.1) {
        results.add(FatwaSearchResult(
          fatwa: fatwa,
          relevanceScore: score,
          matchedParts: _findMatchedParts(normalizedQuery, fatwa),
        ));
      }
    }

    results.sort((a, b) {
      int cmp = b.relevanceScore.compareTo(a.relevanceScore);
      if (cmp != 0) return cmp;
      return a.fatwa.question.length.compareTo(b.fatwa.question.length);
    });

    // ✅ فلتر صارم: احذف أي نتيجة أقل من 5 نقاط
    results = results.where((r) => r.relevanceScore >= 5.0).toList();

    // ✅ فلتر إضافي: يجب أن تحتوي الفتوى على كلمة واحدة على الأقل من السؤال
    if (queryTokens.isNotEmpty) {
      results = results.where((r) {
        final fatwaText = _normalize(
            '${r.fatwa.question} ${r.fatwa.answer}'
        );
        return queryTokens.any((token) =>
        token.length > 2 && fatwaText.contains(token)
        );
      }).toList();
    }

    return results.take(topK).toList();
  }

  // ══════════════════════════════════════
  // حساب نقطة التطابق
  // ══════════════════════════════════════
  static double _calculateScore({
    required String query,
    required List<String> tokens,
    required Fatwa fatwa,
  }) {
    double score = 0;

    final normQuestion = _normalize(fatwa.question);
    final normAnswer = _normalize(fatwa.answer);
    final normKeywords = fatwa.keywords
        .map((k) => _normalize(k))
        .join(' ');

    // ═══ 1. تطابق عبارة كاملة ═══
    if (normQuestion.contains(query)) score += 15.0;
    if (normAnswer.contains(query)) score += 8.0;

    // داخل دالة _calculateScore
// زد وزن الكلمات النادرة وقلل وزن الكلمات الشائعة

    for (var token in tokens) {
      // إذا كانت الكلمة (حكم، صلاة، ما، هل) أعطها وزن 1 فقط
      double weight = 1.0;
      if (['عطس', 'عاطس', 'عطس في الصلاة'].contains(token)) {
        weight = 10.0; // وزن كبير جداً للكلمة المفتاحية
      }

      if (normQuestion.contains(token)) {
        score += (weight * 15.0); // البحث في السؤال أهم من الجواب
      }
    }

    // ═══ 2. تطابق TF-IDF مبسط ═══
    for (var token in tokens) {
      if (token.length < 2) continue;

      // في السؤال (أهم)
      final qFreq = _countOccurrences(normQuestion, token);
      score += qFreq * 5.0;

      // في الجواب
      final aFreq = _countOccurrences(normAnswer, token);
      score += aFreq * 2.0;

      // في الكلمات المفتاحية
      if (normKeywords.contains(token)) score += 4.0;

      // في التصنيف
      if (_normalize(fatwa.category).contains(token)) score += 3.0;
    }

    // ═══ 3. بحث بالجذر ═══
    for (var token in tokens) {
      final stems = _getStems(token);
      for (var stem in stems) {
        if (stem.length < 3) continue;
        if (normQuestion.contains(stem)) score += 2.0;
        if (normAnswer.contains(stem)) score += 1.0;
      }
    }

    // ═══ 4. BM25 مبسط (مكافأة للنصوص القصيرة) ═══
    final lengthPenalty = min(
      1.0,
      100.0 / max(fatwa.question.length, 10),
    );
    score *= (1 + lengthPenalty * 0.3);

    // ═══ 5. مكافأة اكتمال الاستعلام ═══
    final coveredTokens = tokens
        .where((t) => normQuestion.contains(t) || normAnswer.contains(t))
        .length;
    if (tokens.isNotEmpty) {
      final coverage = coveredTokens / tokens.length;
      score *= (0.5 + coverage * 0.5);
    }

    return score;
  }

  // ══════════════════════════════════════
  // توسيع الاستعلام بالمرادفات
  // ══════════════════════════════════════
  static List<String> _expandWithSynonyms(List<String> tokens) {
    final expanded = <String>{...tokens};

    final synonymMap = {
      // الطهارة والصلاة
      'صلاة': ['صلى', 'يصلي', 'مصلي', 'اصلي', 'نصلي', 'تصلي'],
      'وضوء': ['يتوضأ', 'توضأ', 'ناقض', 'طهارة', 'متطهر'],
      'غسل': ['اغتسل', 'يغتسل', 'جنابة', 'طهارة'],

      // الصيام
      'صيام': ['صوم', 'صائم', 'يصوم', 'صيام', 'افطر', 'سحر'],
      'افطار': ['يفطر', 'مفطر', 'مفطرات', 'فطر', 'فطور'],
      'رمضان': ['شهر رمضان', 'الشهر الكريم', 'شهر الصوم'],

      // الزكاة
      'زكاة': ['صدقة', 'عشر', 'نصاب', 'اخرج', 'زكى'],
      'نصاب': ['مقدار', 'حد', 'قدر'],

      // الأحكام
      'حرام': ['يحرم', 'لايجوز', 'محرم', 'ممنوع', 'منهي عنه'],
      'حلال': ['يجوز', 'جائز', 'مباح', 'مشروع', 'يباح'],
      'مكروه': ['يكره', 'كراهة', 'خلاف الاولى'],
      'واجب': ['فرض', 'يجب', 'لازم', 'وجوب', 'فريضة'],
      'سنة': ['مستحب', 'يستحب', 'مندوب', 'نافلة'],

      // المواضيع الشائعة
      'مريض': ['مرض', 'علة', 'عاجز', 'ضعيف', 'يتالم'],
      'مسافر': ['سفر', 'يسافر', 'في الطريق', 'غريب', 'رحلة'],
      'امراة': ['زوجة', 'انثى', 'بنت', 'مراة', 'نساء'],
      'رجل': ['ذكر', 'زوج', 'ابو'],
      'اطفال': ['ولد', 'طفل', 'صبي', 'صغير'],

      // الصلوات
      'فجر': ['صبح', 'صلاة الصبح', 'صلاة الفجر'],
      'ظهر': ['صلاة الظهر', 'وقت الظهر'],
      'عصر': ['صلاة العصر'],
      'مغرب': ['صلاة المغرب'],
      'عشاء': ['صلاة العشاء'],
      'جمعة': ['يوم الجمعة', 'صلاة الجمعة', 'خطبة'],

      // الأطعمة
      'اكل': ['طعام', 'غذاء', 'يأكل', 'مأكول'],
      'لحم': ['ذبيحة', 'ذبح', 'لحوم', 'لحم'],
      'خمر': ['مسكر', 'كحول', 'شراب محرم'],
    };

    for (var token in tokens) {
      final normalized = _normalize(token);
      for (var entry in synonymMap.entries) {
        if (normalized.contains(entry.key) ||
            entry.key.contains(normalized)) {
          expanded.addAll(entry.value);
        }
        for (var syn in entry.value) {
          if (normalized.contains(syn) || syn.contains(normalized)) {
            expanded.add(entry.key);
            expanded.addAll(entry.value);
          }
        }
      }
    }

    return expanded.toList();
  }

  // ══════════════════════════════════════
  // استخراج جذور الكلمة
  // ══════════════════════════════════════
  static List<String> _getStems(String word) {
    List<String> stems = [word];

    if (word.length < 4) return stems;

    // إزالة ال التعريف
    if (word.startsWith('ال') && word.length > 4) {
      stems.add(word.substring(2));
      word = word.substring(2);
    }

    // إزالة البادئات
    final prefixes = ['و', 'ف', 'ب', 'ل', 'ك', 'سي', 'مست'];
    for (var prefix in prefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length + 2) {
        stems.add(word.substring(prefix.length));
      }
    }

    // إزالة اللواحق
    final suffixes = [
      'ون', 'ين', 'ات', 'ان', 'تان', 'تين',
      'ها', 'هم', 'هن', 'كم', 'كن', 'نا',
      'ية', 'وا', 'تم', 'ته', 'تها',
      'ني', 'ك', 'ه', 'ي',
    ];
    for (var suffix in suffixes) {
      if (word.endsWith(suffix) && word.length > suffix.length + 2) {
        stems.add(word.substring(0, word.length - suffix.length));
      }
    }

    return stems.toSet().toList();
  }

  // ══════════════════════════════════════
  // إيجاد الأجزاء المتطابقة للتمييز
  // ══════════════════════════════════════
  static List<String> _findMatchedParts(String query, Fatwa fatwa) {
    final matched = <String>[];
    final tokens = _tokenize(query);

    for (var token in tokens) {
      if (fatwa.question.contains(token)) matched.add(token);
      if (fatwa.answer.contains(token) && !matched.contains(token)) {
        matched.add(token);
      }
    }

    return matched;
  }

  // ══════════════════════════════════════
  // تطبيع النص العربي
  // ══════════════════════════════════════
  static String _normalize(String text) {
    return text
        .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه').replaceAll('ى', 'ي').replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll(RegExp(r'[ًٌٍَُِّْٰ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ══════════════════════════════════════
  // تقسيم إلى كلمات مع إزالة حروف الجر
  // ══════════════════════════════════════
  static List<String> _tokenize(String text) {
    const stopWords = {
      'في', 'من', 'الى', 'على', 'عن', 'مع', 'هل', 'ما', 'هو',
      'هي', 'ان', 'أن', 'كان', 'لا', 'لم', 'قد', 'و', 'او',
      'ثم', 'هذا', 'هذه', 'ذلك', 'التي', 'الذي', 'ومن', 'وفي',
      'الله', 'رسول', 'النبي', 'صلى', 'عليه', 'وسلم',
    };

    return text
        .split(RegExp(r'[\s،؟!.,؛:()]+'))
        .map((w) => w.trim())
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toList();
  }

  static int _countOccurrences(String text, String pattern) {
    if (pattern.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = text.indexOf(pattern, index)) != -1) {
      count++;
      index += pattern.length;
    }
    return count;
  }
}