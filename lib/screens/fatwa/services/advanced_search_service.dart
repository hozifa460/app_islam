import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/fatwa_model.dart';
import 'fatwa_search_service.dart';

/// بحث محلي دقيق ومحايد للمصادر.
///
/// الحساب الثقيل يجري عبر [compute] حتى لا يتسبب فحص قواعد الفتاوى الكبيرة
/// في توقف واجهة Flutter. لا يدخل اسم الملف أو المصدر في حساب الدرجة مطلقاً.
class AdvancedSearchService {
  static Future<List<FatwaSearchResult>> search(
    String query,
    List<Fatwa> fatawa, {
    String? scholarFilter,
    String? categoryFilter,
    int? topK = 20,
  }) async {
    if (query.trim().isEmpty || fatawa.isEmpty) return const [];

    final snapshot = List<Fatwa>.of(fatawa, growable: false);
    final matches = await compute(
      _runAdvancedSearch,
      _SearchRequest(
        query: query,
        fatawa: snapshot,
        scholarFilter: scholarFilter,
        categoryFilter: categoryFilter,
        limit: topK,
      ),
      debugLabel: 'fatwa-precision-search',
    );

    return matches
        .map(
          (match) => FatwaSearchResult(
            fatwa: snapshot[match.index],
            relevanceScore: match.score,
            matchedParts: match.matchedParts,
          ),
        )
        .toList(growable: false);
  }
}

class _SearchRequest {
  final String query;
  final List<Fatwa> fatawa;
  final String? scholarFilter;
  final String? categoryFilter;
  final int? limit;

  const _SearchRequest({
    required this.query,
    required this.fatawa,
    required this.scholarFilter,
    required this.categoryFilter,
    required this.limit,
  });
}

class _SearchMatch {
  final int index;
  final double score;
  final double coverage;
  final int phraseRank;
  final int questionLength;
  final int tieBreaker;
  final List<String> matchedParts;

  const _SearchMatch({
    required this.index,
    required this.score,
    required this.coverage,
    required this.phraseRank,
    required this.questionLength,
    required this.tieBreaker,
    required this.matchedParts,
  });
}

List<_SearchMatch> _runAdvancedSearch(_SearchRequest request) {
  final normalizedQuery = _normalizeArabic(request.query);
  if (normalizedQuery.isEmpty) return const [];

  var queryTokens = _importantTokens(normalizedQuery);
  if (queryTokens.isEmpty) queryTokens = _allTokens(normalizedQuery);
  queryTokens = _uniqueInOrder(queryTokens);
  if (queryTokens.isEmpty) return const [];

  final results = <_SearchMatch>[];
  for (var index = 0; index < request.fatawa.length; index++) {
    final fatwa = request.fatawa[index];
    if (request.scholarFilter != null &&
        fatwa.scholar != request.scholarFilter) {
      continue;
    }
    if (request.categoryFilter != null &&
        fatwa.category != request.categoryFilter) {
      continue;
    }

    final match = _scoreFatwa(
      index: index,
      fatwa: fatwa,
      query: normalizedQuery,
      queryTokens: queryTokens,
    );
    if (match != null) results.add(match);
  }

  results.sort((a, b) {
    var comparison = b.score.compareTo(a.score);
    if (comparison != 0) return comparison;
    comparison = b.coverage.compareTo(a.coverage);
    if (comparison != 0) return comparison;
    comparison = b.phraseRank.compareTo(a.phraseRank);
    if (comparison != 0) return comparison;
    comparison = a.questionLength.compareTo(b.questionLength);
    if (comparison != 0) return comparison;
    // كسر تعادل مبني على النص، وليس على ترتيب الملف أو اسم المصدر.
    return a.tieBreaker.compareTo(b.tieBreaker);
  });

  final limit = request.limit;
  if (limit != null && limit > 0 && results.length > limit) {
    return results.take(limit).toList(growable: false);
  }
  return results;
}

_SearchMatch? _scoreFatwa({
  required int index,
  required Fatwa fatwa,
  required String query,
  required List<String> queryTokens,
}) {
  final question = _normalizeArabic(fatwa.question);
  final title = _normalizeArabic(fatwa.title);
  final answer = _normalizeArabic(fatwa.answer);
  final metadata = _normalizeArabic(
    '${fatwa.keywords.join(' ')} ${fatwa.category} '
    '${fatwa.categories.join(' ')}',
  );

  final questionTokens = _allTokens(question);
  final titleTokens = title == question ? questionTokens : _allTokens(title);
  final metadataTokens = _allTokens(metadata);
  final paddedAnswer = ' $answer ';

  var score = 0.0;
  var phraseRank = 0;
  if (question == query) {
    score += 180;
    phraseRank = 5;
  } else if (question.startsWith(query)) {
    score += 135;
    phraseRank = 4;
  } else if (question.contains(query)) {
    score += 115;
    phraseRank = 3;
  } else if (title == query || title.contains(query)) {
    score += title == query ? 150 : 95;
    phraseRank = title == query ? 4 : 3;
  } else if (answer.contains(query)) {
    score += 28;
    phraseRank = 2;
  }

  var covered = 0.0;
  var questionCovered = 0.0;
  final matchedParts = <String>[];

  for (final token in queryTokens) {
    final specificity = 1 + min(0.45, max(0, token.length - 4) * 0.07);
    final questionQuality = _bestTokenMatch(
      token,
      questionTokens,
      allowFuzzy: true,
    );
    final titleQuality = _bestTokenMatch(token, titleTokens, allowFuzzy: true);
    final metadataQuality = _bestTokenMatch(
      token,
      metadataTokens,
      allowFuzzy: false,
    );
    final answerQuality = _answerMatchQuality(token, paddedAnswer);

    var bestQuality = max(
      max(questionQuality, titleQuality),
      max(metadataQuality, answerQuality),
    );

    if (questionQuality > 0) {
      score += 25 * questionQuality * specificity;
      questionCovered += questionQuality;
    }
    if (titleQuality > questionQuality) {
      score += 18 * titleQuality * specificity;
    }
    if (metadataQuality > 0) {
      score += 10 * metadataQuality * specificity;
    }
    if (answerQuality > 0) {
      // وجود الكلمة في جواب طويل مفيد، لكنه لا يتغلب على سؤال قريب.
      score += 3.5 * answerQuality * specificity;
    }

    if (bestQuality == 0) {
      final synonymQuality = _synonymMatchQuality(
        token,
        questionTokens: questionTokens,
        titleTokens: titleTokens,
        metadataTokens: metadataTokens,
        paddedAnswer: paddedAnswer,
      );
      if (synonymQuality > 0) {
        bestQuality = synonymQuality;
        score += 8 * synonymQuality * specificity;
      }
    }

    covered += bestQuality;
    if (bestQuality >= 0.7) matchedParts.add(token);
  }

  final coverage = covered / queryTokens.length;
  final questionCoverage = questionCovered / queryTokens.length;
  final proximity = _orderedProximity(queryTokens, questionTokens);
  if (proximity > 0) score += 52 * proximity;

  if (coverage >= 0.99) {
    score += 65;
  } else if (coverage >= 0.8) {
    score += 38;
  } else if (coverage >= 0.6) {
    score += 18;
  }
  if (questionCoverage >= 0.99) {
    score += 38;
  } else if (questionCoverage >= 0.75) {
    score += 18;
  }

  // انخفاض التغطية يجب أن يخفض النتيجة بوضوح، ولا تعوضه إجابة طويلة.
  score *= 0.22 + (0.78 * pow(coverage, 1.7));

  final minimumCoverage = queryTokens.length == 1 ? 0.7 : 0.58;
  if (coverage < minimumCoverage && phraseRank < 2) return null;
  if (score < 12) return null;

  return _SearchMatch(
    index: index,
    score: score,
    coverage: coverage,
    phraseRank: phraseRank,
    questionLength: fatwa.question.length,
    tieBreaker: _stableTextHash(
      '$question ${answer.substring(0, min(96, answer.length))}',
    ),
    matchedParts: matchedParts,
  );
}

double _bestTokenMatch(
  String queryToken,
  List<String> documentTokens, {
  required bool allowFuzzy,
}) {
  var best = 0.0;
  final queryStem = _lightStem(queryToken);
  for (final documentToken in documentTokens) {
    if (queryToken == documentToken) return 1;
    if (queryStem.length >= 3 && queryStem == _lightStem(documentToken)) {
      best = max(best, 0.88);
      continue;
    }
    if (allowFuzzy &&
        queryToken.length >= 4 &&
        (queryToken.length - documentToken.length).abs() <= 2) {
      final allowedDistance = queryToken.length >= 7 ? 2 : 1;
      if (_boundedEditDistance(queryToken, documentToken, allowedDistance) <=
          allowedDistance) {
        best = max(best, queryToken.length >= 7 ? 0.76 : 0.72);
      }
    }
  }
  return best;
}

double _answerMatchQuality(String token, String paddedAnswer) {
  if (_containsWholeToken(paddedAnswer, token)) return 1;
  final stem = _lightStem(token);
  if (stem != token &&
      stem.length >= 4 &&
      _containsWholeToken(paddedAnswer, stem)) {
    return 0.7;
  }
  return 0;
}

double _synonymMatchQuality(
  String token, {
  required List<String> questionTokens,
  required List<String> titleTokens,
  required List<String> metadataTokens,
  required String paddedAnswer,
}) {
  final synonyms = _synonymsFor(token);
  for (final synonym in synonyms) {
    if (_bestTokenMatch(synonym, questionTokens, allowFuzzy: false) > 0 ||
        _bestTokenMatch(synonym, titleTokens, allowFuzzy: false) > 0 ||
        _bestTokenMatch(synonym, metadataTokens, allowFuzzy: false) > 0) {
      return 0.5;
    }
  }
  for (final synonym in synonyms) {
    if (_containsWholeToken(paddedAnswer, synonym)) return 0.4;
  }
  return 0;
}

double _orderedProximity(
  List<String> queryTokens,
  List<String> documentTokens,
) {
  if (queryTokens.length < 2 || documentTokens.isEmpty) return 0;
  var bestSpan = 1 << 30;
  for (var start = 0; start < documentTokens.length; start++) {
    if (_bestTokenMatch(queryTokens.first, [
          documentTokens[start],
        ], allowFuzzy: true) <
        0.7) {
      continue;
    }
    var position = start;
    var matched = true;
    for (var queryIndex = 1; queryIndex < queryTokens.length; queryIndex++) {
      var next = -1;
      for (var i = position + 1; i < documentTokens.length; i++) {
        if (_bestTokenMatch(queryTokens[queryIndex], [
              documentTokens[i],
            ], allowFuzzy: true) >=
            0.7) {
          next = i;
          break;
        }
      }
      if (next < 0) {
        matched = false;
        break;
      }
      position = next;
    }
    if (matched) bestSpan = min(bestSpan, position - start + 1);
  }
  if (bestSpan == 1 << 30) return 0;
  return (queryTokens.length / bestSpan).clamp(0.0, 1.0);
}

bool _containsWholeToken(String paddedText, String token) =>
    paddedText.contains(' $token ');

String _normalizeArabic(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll(RegExp(r'[ًٌٍَُِّْـٰ]'), '')
      .replaceAll(
        RegExp(r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF0-9\s]'),
        ' ',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

List<String> _allTokens(String normalizedText) => normalizedText
    .split(' ')
    .where((token) => token.length > 1)
    .toList(growable: false);

List<String> _importantTokens(String normalizedText) => _allTokens(
  normalizedText,
).where((token) => !_stopWords.contains(token)).toList(growable: false);

List<String> _uniqueInOrder(List<String> tokens) {
  final seen = <String>{};
  return [
    for (final token in tokens)
      if (seen.add(token)) token,
  ];
}

String _lightStem(String token) {
  var value = token;
  const prefixes = ['وال', 'فال', 'بال', 'كال', 'لل', 'ال'];
  for (final prefix in prefixes) {
    if (value.startsWith(prefix) && value.length - prefix.length >= 3) {
      value = value.substring(prefix.length);
      break;
    }
  }
  const suffixes = [
    'يات',
    'يون',
    'يين',
    'تين',
    'تان',
    'ات',
    'ون',
    'ين',
    'ان',
    'هما',
    'كم',
    'كن',
    'هم',
    'هن',
    'نا',
  ];
  for (final suffix in suffixes) {
    if (value.endsWith(suffix) && value.length - suffix.length >= 3) {
      value = value.substring(0, value.length - suffix.length);
      break;
    }
  }
  return value;
}

int _boundedEditDistance(String a, String b, int limit) {
  if ((a.length - b.length).abs() > limit) return limit + 1;
  var previous = List<int>.generate(b.length + 1, (index) => index);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    var rowMinimum = current[0];
    for (var j = 1; j <= b.length; j++) {
      final substitutionCost =
          a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = min(
        min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + substitutionCost,
      );
      rowMinimum = min(rowMinimum, current[j]);
    }
    if (rowMinimum > limit) return limit + 1;
    previous = current;
  }
  return previous[b.length];
}

Set<String> _synonymsFor(String token) {
  final stem = _lightStem(token);
  for (final group in _synonymGroups) {
    if (group.any((entry) => entry == token || _lightStem(entry) == stem)) {
      return group.difference({token});
    }
  }
  return const {};
}

int _stableTextHash(String value) {
  var hash = 0x811C9DC5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return hash;
}

const Set<String> _stopWords = {
  'في',
  'من',
  'الى',
  'على',
  'عن',
  'مع',
  'هل',
  'ما',
  'هو',
  'هي',
  'ان',
  'كان',
  'لا',
  'لم',
  'قد',
  'او',
  'ثم',
  'هذا',
  'هذه',
  'ذلك',
  'الذي',
  'التي',
  'حكم',
  'يجوز',
  'جائز',
  'الله',
  'رسول',
  'النبي',
  'صلي',
  'عليه',
  'وسلم',
};

const List<Set<String>> _synonymGroups = [
  {'صلاه', 'يصلي', 'صلي', 'مصلي'},
  {'وضوء', 'يتوضا', 'توضا', 'طهاره'},
  {'صيام', 'صوم', 'صائم', 'يصوم'},
  {'افطار', 'يفطر', 'مفطر', 'فطر'},
  {'زكاه', 'صدقه', 'نصاب'},
  {'حرام', 'يحرم', 'محرم', 'ممنوع'},
  {'حلال', 'يجوز', 'جائز', 'مباح'},
  {'واجب', 'فرض', 'يجب', 'فريضه'},
  {'سنه', 'مستحب', 'مندوب', 'نافله'},
  {'مريض', 'مرض', 'عاجز'},
  {'مسافر', 'سفر', 'يسافر'},
  {'امراه', 'زوجه', 'نساء'},
  {'طفل', 'اطفال', 'صبي', 'صغير'},
  {'فجر', 'صبح'},
  {'اكل', 'طعام', 'ياكل'},
  {'خمر', 'مسكر', 'كحول'},
];
