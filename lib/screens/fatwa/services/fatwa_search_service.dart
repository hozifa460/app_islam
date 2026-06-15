// services/fatwa_search_service.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/fatwa_model.dart';

class FatwaSearchService {
  // ط§ظ„ط®ظٹط§ط± 1: ط¨ط§ط³طھط®ط¯ط§ظ… Backend ط®ط§طµ ط¨ظƒ
  static const String _baseUrl = String.fromEnvironment('FATWA_BACKEND_URL', defaultValue: '');

  // ط§ظ„ط®ظٹط§ط± 2: ط¨ط§ط³طھط®ط¯ط§ظ… OpenAI API ظ…ط¨ط§ط´ط±ط©
  static const String _openAiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  /// ط¨ط­ط« ط°ظƒظٹ ط¨ط§ط³طھط®ط¯ط§ظ… Backend
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
      debugPrint('Search error: $e');
      return [];
    }
  }

  /// ط¨ط­ط« ط¨ط§ط³طھط®ط¯ط§ظ… OpenAI Embeddings
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

  /// ط¨ط­ط« ظ…ط­ظ„ظٹ ظ…ط­ط³ظ‘ظ† (ط¨ط¯ظˆظ† ط§ظ†طھط±ظ†طھ)
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

      // 1. طھط·ط§ط¨ظ‚ ظƒط§ظ…ظ„ ظ„ظ„ط¹ط¨ط§ط±ط©
      if (allText.contains(normalizedQuery)) {
        score += 10.0;
      }

      // 2. طھط·ط§ط¨ظ‚ ط§ظ„ظƒظ„ظ…ط§طھ ط§ظ„ظ…ظپط±ط¯ط© ظ…ط¹ ظˆط²ظ†
      for (var word in queryWords) {
        if (word.length < 2) continue;

        // ط¨ط­ط« ط¨ط¬ط°ط± ط§ظ„ظƒظ„ظ…ط©
        final stems = _getArabicStems(word);
        for (var stem in stems) {
          if (normalizedQuestion.contains(stem)) {
            score += 3.0; // ظˆط²ظ† ط£ط¹ظ„ظ‰ ظ„ظ„ط³ط¤ط§ظ„
          }
          if (normalizedAnswer.contains(stem)) {
            score += 1.5;
          }
        }

        // ط¨ط­ط« ط¨ط§ظ„ظƒظ„ظ…ط© ظƒط§ظ…ظ„ط©
        if (normalizedQuestion.contains(word)) {
          score += 5.0;
        }
        if (normalizedAnswer.contains(word)) {
          score += 2.0;
        }
      }

      // 3. طھط·ط§ط¨ظ‚ ط§ظ„ظƒظ„ظ…ط§طھ ط§ظ„ظ…ظپطھط§ط­ظٹط©
      for (var keyword in fatwa.keywords) {
        final normalizedKeyword = _normalizeArabic(keyword.toLowerCase());
        for (var queryWord in queryWords) {
          if (normalizedKeyword.contains(queryWord) ||
              queryWord.contains(normalizedKeyword)) {
            score += 4.0;
          }
        }
      }

      // 4. طھط·ط§ط¨ظ‚ ط§ظ„طھطµظ†ظٹظپ
      if (_normalizeArabic(fatwa.category.toLowerCase())
          .contains(normalizedQuery)) {
        score += 3.0;
      }

      // 5. ط¨ط­ط« ط¨ط§ظ„ظ…ط±ط§ط¯ظپط§طھ
      score += _synonymScore(queryWords, allText);

      if (score > 0) {
        results.add(FatwaSearchResult(
          fatwa: fatwa,
          relevanceScore: score,
        ));
      }
    }

    // طھط±طھظٹط¨ ط­ط³ط¨ ط§ظ„طµظ„ط©
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return results.take(20).toList();
  }

  /// طھظ†ط¸ظٹظپ ط§ظ„ظ†طµ ط§ظ„ط¹ط±ط¨ظٹ
  static String _normalizeArabic(String text) {
    return text
        .replaceAll('ط£', 'ط§')
        .replaceAll('ط¥', 'ط§')
        .replaceAll('ط¢', 'ط§')
        .replaceAll('ط©', 'ظ‡')
        .replaceAll('ظ‰', 'ظٹ')
        .replaceAll(RegExp(r'[ظ‹ظŒظچظژظڈظگظ‘ظ’]'), '') // ط¥ط²ط§ظ„ط© ط§ظ„طھط´ظƒظٹظ„
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// طھظ‚ط³ظٹظ… ط§ظ„ظ†طµ ط¥ظ„ظ‰ ظƒظ„ظ…ط§طھ
  static List<String> _tokenize(String text) {
    const stopWords = {
      'ظپظٹ', 'ظ…ظ†', 'ط§ظ„ظ‰', 'ط¹ظ„ظ‰', 'ط¹ظ†', 'ظ…ط¹', 'ظ‡ظ„', 'ظ…ط§', 'ظ‡ظˆ',
      'ظ‡ظٹ', 'ط§ظ†', 'ظƒط§ظ†', 'ظ„ط§', 'ظ„ظ…', 'ظ‚ط¯', 'ط§ظˆ',
      'ط«ظ…', 'ظ‡ط°ط§', 'ظ‡ط°ظ‡', 'ط°ظ„ظƒ', 'ط§ظ„طھظٹ', 'ط§ظ„ط°ظٹ',
      'ط§ظ„ظ„ظ‡', 'ط±ط³ظˆظ„', 'ط§ظ„ظ†ط¨ظٹ', 'طµظ„ظ‰', 'ط¹ظ„ظٹظ‡', 'ظˆط³ظ„ظ…',
    };

    return text
        .split(RegExp(r'[\sطŒطں!.,ط›:()]+'))
        .map((w) => w.trim())
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toList();
  }

  /// ط§ط³طھط®ط±ط§ط¬ ط¬ط°ظˆط± ط§ظ„ظƒظ„ظ…ط© ط§ظ„ط¹ط±ط¨ظٹط© (ظ…ط¨ط³ط·)
  static List<String> _getArabicStems(String word) {
    List<String> stems = [word];

    // ط¥ط²ط§ظ„ط© ط§ظ„ ط§ظ„طھط¹ط±ظٹظپ
    if (word.startsWith('ط§ظ„')) {
      stems.add(word.substring(2));
    }

    // ط¥ط²ط§ظ„ط© ط§ظ„ظ„ظˆط§ط­ظ‚
    final suffixes = ['ظˆظ†', 'ظٹظ†', 'ط§طھ', 'ط§ظ†', 'ظ‡ط§', 'ظ‡ظ…', 'ظ‡ظ†', 'ظٹط©', 'ظˆط§'];
    for (var suffix in suffixes) {
      if (word.endsWith(suffix) && word.length > suffix.length + 2) {
        stems.add(word.substring(0, word.length - suffix.length));
      }
    }

    // ط¥ط²ط§ظ„ط© ط§ظ„ط¨ط§ط¯ط¦ط§طھ
    final prefixes = ['ط§ظ„', 'ظˆ', 'ط¨', 'ظپ', 'ظƒ', 'ظ„'];
    for (var prefix in prefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length + 2) {
        stems.add(word.substring(prefix.length));
      }
    }

    return stems;
  }

  /// ط¨ط­ط« ط¨ط§ظ„ظ…ط±ط§ط¯ظپط§طھ
  static double _synonymScore(List<String> queryWords, String text) {
    double score = 0;

    final synonymGroups = [
      // ط§ظ„ط¹ط¨ط§ط¯ط§طھ
      ['طµظ„ط§ظ‡', 'طµظ„ط§ط©', 'ظٹطµظ„ظٹ', 'طµظ„ظ‰', 'ظ…طµظ„ظٹ', 'ط§طµظ„ظٹ', 'ظ†طµظ„ظٹ'],
      ['ط²ظƒط§ظ‡', 'ط²ظƒط§ط©', 'طµط¯ظ‚ظ‡', 'طµط¯ظ‚ط©', 'طھط²ظƒظٹظ‡'],
      ['طµظٹط§ظ…', 'طµظˆظ…', 'ظٹطµظˆظ…', 'طµط§ط¦ظ…', 'ط§ظپط·ط§ط±', 'ط³ط­ظˆط±'],
      ['ط­ط¬', 'ط¹ظ…ط±ظ‡', 'ط¹ظ…ط±ط©', 'ط­ط§ط¬', 'ظ…ظ†ط§ط³ظƒ', 'ط§ط­ط±ط§ظ…'],
      ['ظˆط¶ظˆط،', 'ط·ظ‡ط§ط±ظ‡', 'ط·ظ‡ط§ط±ط©', 'ظٹطھظˆط¶ط§', 'ط؛ط³ظ„', 'طھظٹظ…ظ…'],

      // ط§ظ„ط£ط­ظƒط§ظ…
      ['ط­ط±ط§ظ…', 'ظ…ط­ط±ظ…', 'ظٹط­ط±ظ…', 'ظ„ط§ظٹط¬ظˆط²', 'ظ…ظ…ظ†ظˆط¹', 'ظ…ظ†ظ‡ظٹ'],
      ['ط­ظ„ط§ظ„', 'ط¬ط§ط¦ط²', 'ظٹط¬ظˆط²', 'ظ…ط¨ط§ط­', 'ظٹط¨ط§ط­', 'ظ…ط´ط±ظˆط¹'],
      ['ظ…ظƒط±ظˆظ‡', 'ظٹظƒط±ظ‡', 'ظƒط±ط§ظ‡ظ‡', 'ظƒط±ط§ظ‡ط©'],
      ['ظˆط§ط¬ط¨', 'ظپط±ط¶', 'ظٹط¬ط¨', 'ظ„ط§ط²ظ…', 'ظˆط¬ظˆط¨'],
      ['ط³ظ†ظ‡', 'ط³ظ†ط©', 'ظ…ط³طھط­ط¨', 'ظٹط³طھط­ط¨', 'ظ…ظ†ط¯ظˆط¨'],

      // ط§ظ„ظ…ظˆط§ط¶ظٹط¹
      ['ظ…ط±ظٹط¶', 'ظ…ط±ط¶', 'ط¹ظ„ظ‡', 'ط¹ظ„ط©', 'ط³ظ‚ظ…', 'ط¹ط§ط¬ط²'],
      ['ط³ظپط±', 'ظ…ط³ط§ظپط±', 'ظٹط³ط§ظپط±', 'ط±ط­ظ„ظ‡', 'ط±ط­ظ„ط©'],
      ['ظ†ظƒط§ط­', 'ط²ظˆط§ط¬', 'ظٹطھط²ظˆط¬', 'ط¹ط±ط³', 'ط²ظˆط¬', 'ط²ظˆط¬ظ‡'],
      ['ط·ظ„ط§ظ‚', 'ظٹط·ظ„ظ‚', 'ط·ط§ظ„ظ‚', 'ط®ظ„ط¹', 'ظپط³ط®'],
      ['ظ…ظٹط±ط§ط«', 'ط§ط±ط«', 'طھط±ظƒظ‡', 'طھط±ظƒط©', 'ظˆط±ط§ط«ظ‡', 'ظˆط±ط«ظ‡'],
      ['ط¨ظٹط¹', 'ط´ط±ط§ط،', 'طھط¬ط§ط±ظ‡', 'طھط¬ط§ط±ط©', 'ط±ط¨ط§', 'ظ…ط¹ط§ظ…ظ„ظ‡'],
      ['ط¯ط¹ط§ط،', 'ط°ظƒط±', 'ط§ط°ظƒط§ط±', 'ط§ط³طھط؛ظپط§ط±', 'طھط³ط¨ظٹط­'],
      ['ظ…ظˆطھ', 'ظˆظپط§ظ‡', 'ظˆظپط§ط©', 'ط¬ظ†ط§ط²ظ‡', 'ط¬ظ†ط§ط²ط©', 'ط¯ظپظ†', 'ظ‚ط¨ط±'],
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