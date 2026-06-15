// services/fatwa_search_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/fatwa_model.dart';

class FatwaSearchService {
  // الخيار 1: باستخدام Backend خاص بك
  static const String _baseUrl = 'https://your-server.com';

  // الخيار 2: باستخدام OpenAI API مباشرة
  static const String _openAiKey = 'YOUR_API_KEY';

  /// بحث ذكي باستخدام Backend
  static Future<List<FatwaSearchResult>> searchWithBackend(
      String query, {
        int topK = 10,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/smart-search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'top_k': topK,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List).map((r) {
          return FatwaSearchResult(
            fatwa: Fatwa.fromJson(r['fatwa']),
            relevanceScore: r['score'],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  /// بحث باستخدام OpenAI Embeddings
  static Future<List<double>> getEmbedding(String text) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/embeddings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAiKey',
      },
      body: jsonEncode({
        'input': text,
        'model': 'text-embedding-3-small',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data['data'][0]['embedding']);
    }
    throw Exception('Failed to get embedding');
  }

  /// بحث محلي محسّن (بدون انترنت)
  static Future<List<FatwaSearchResult>> searchLocally(
      String query,
      List<Fatwa> allFatawa,
      ) async {
    final normalizedQuery = _normalizeArabic(query.toLowerCase());
    final queryWords = _tokenize(normalizedQuery);

    List<FatwaSearchResult> results = [];

    for (var fatwa in allFatawa) {
      double score = 0;

      final normalizedQuestion = _normalizeArabic(fatwa.question.toLowerCase());
      final normalizedAnswer = _normalizeArabic(fatwa.answer.toLowerCase());
      final allText = '$normalizedQuestion $normalizedAnswer';

      // 1. تطابق كامل للعبارة
      if (allText.contains(normalizedQuery)) {
        score += 10.0;
      }

      // 2. تطابق الكلمات المفردة مع وزن
      for (var word in queryWords) {
        if (word.length < 2) continue;

        // بحث بجذر الكلمة
        final stems = _getArabicStems(word);
        for (var stem in stems) {
          if (normalizedQuestion.contains(stem)) {
            score += 3.0; // وزن أعلى للسؤال
          }
          if (normalizedAnswer.contains(stem)) {
            score += 1.5;
          }
        }

        // بحث بالكلمة كاملة
        if (normalizedQuestion.contains(word)) {
          score += 5.0;
        }
        if (normalizedAnswer.contains(word)) {
          score += 2.0;
        }
      }

      // 3. تطابق الكلمات المفتاحية
      for (var keyword in fatwa.keywords) {
        final normalizedKeyword = _normalizeArabic(keyword.toLowerCase());
        for (var queryWord in queryWords) {
          if (normalizedKeyword.contains(queryWord) ||
              queryWord.contains(normalizedKeyword)) {
            score += 4.0;
          }
        }
      }

      // 4. تطابق التصنيف
      if (_normalizeArabic(fatwa.category.toLowerCase())
          .contains(normalizedQuery)) {
        score += 3.0;
      }

      // 5. بحث بالمرادفات
      score += _synonymScore(queryWords, allText);

      if (score > 0) {
        results.add(FatwaSearchResult(
          fatwa: fatwa,
          relevanceScore: score,
        ));
      }
    }

    // ترتيب حسب الصلة
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return results.take(20).toList();
  }

  /// تنظيف النص العربي
  static String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '') // إزالة التشكيل
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// تقسيم النص إلى كلمات
  static List<String> _tokenize(String text) {
    const stopWords = {
      'في', 'من', 'الى', 'على', 'عن', 'مع', 'هل', 'ما', 'هو',
      'هي', 'ان', 'كان', 'لا', 'لم', 'قد', 'او',
      'ثم', 'هذا', 'هذه', 'ذلك', 'التي', 'الذي',
      'الله', 'رسول', 'النبي', 'صلى', 'عليه', 'وسلم',
    };

    return text
        .split(RegExp(r'[\s،؟!.,؛:()]+'))
        .map((w) => w.trim())
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toList();
  }

  /// استخراج جذور الكلمة العربية (مبسط)
  static List<String> _getArabicStems(String word) {
    List<String> stems = [word];

    // إزالة ال التعريف
    if (word.startsWith('ال')) {
      stems.add(word.substring(2));
    }

    // إزالة اللواحق
    final suffixes = ['ون', 'ين', 'ات', 'ان', 'ها', 'هم', 'هن', 'ية', 'وا'];
    for (var suffix in suffixes) {
      if (word.endsWith(suffix) && word.length > suffix.length + 2) {
        stems.add(word.substring(0, word.length - suffix.length));
      }
    }

    // إزالة البادئات
    final prefixes = ['ال', 'و', 'ب', 'ف', 'ك', 'ل'];
    for (var prefix in prefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length + 2) {
        stems.add(word.substring(prefix.length));
      }
    }

    return stems;
  }

  /// بحث بالمرادفات
  static double _synonymScore(List<String> queryWords, String text) {
    double score = 0;

    final synonymGroups = [
      // العبادات
      ['صلاه', 'صلاة', 'يصلي', 'صلى', 'مصلي', 'اصلي', 'نصلي'],
      ['زكاه', 'زكاة', 'صدقه', 'صدقة', 'تزكيه'],
      ['صيام', 'صوم', 'يصوم', 'صائم', 'افطار', 'سحور'],
      ['حج', 'عمره', 'عمرة', 'حاج', 'مناسك', 'احرام'],
      ['وضوء', 'طهاره', 'طهارة', 'يتوضا', 'غسل', 'تيمم'],

      // الأحكام
      ['حرام', 'محرم', 'يحرم', 'لايجوز', 'ممنوع', 'منهي'],
      ['حلال', 'جائز', 'يجوز', 'مباح', 'يباح', 'مشروع'],
      ['مكروه', 'يكره', 'كراهه', 'كراهة'],
      ['واجب', 'فرض', 'يجب', 'لازم', 'وجوب'],
      ['سنه', 'سنة', 'مستحب', 'يستحب', 'مندوب'],

      // المواضيع
      ['مريض', 'مرض', 'عله', 'علة', 'سقم', 'عاجز'],
      ['سفر', 'مسافر', 'يسافر', 'رحله', 'رحلة'],
      ['نكاح', 'زواج', 'يتزوج', 'عرس', 'زوج', 'زوجه'],
      ['طلاق', 'يطلق', 'طالق', 'خلع', 'فسخ'],
      ['ميراث', 'ارث', 'تركه', 'تركة', 'وراثه', 'ورثه'],
      ['بيع', 'شراء', 'تجاره', 'تجارة', 'ربا', 'معامله'],
      ['دعاء', 'ذكر', 'اذكار', 'استغفار', 'تسبيح'],
      ['موت', 'وفاه', 'وفاة', 'جنازه', 'جنازة', 'دفن', 'قبر'],
    ];

    for (var queryWord in queryWords) {
      for (var group in synonymGroups) {
        if (group.any((syn) =>
        _normalizeArabic(syn).contains(queryWord) ||
            queryWord.contains(_normalizeArabic(syn)))) {
          for (var syn in group) {
            if (text.contains(_normalizeArabic(syn))) {
              score += 2.0;
              break;
            }
          }
        }
      }
    }

    return score;
  }
}

class FatwaSearchResult {
  final Fatwa fatwa;
  final double relevanceScore;
  final List<String> matchedParts;

  FatwaSearchResult({
    required this.fatwa,
    required this.relevanceScore,
    this.matchedParts = const [],
  });
}