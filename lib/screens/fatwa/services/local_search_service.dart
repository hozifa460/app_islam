import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../models/fatwa_model.dart';
import 'gemini_service.dart';

class LocalSearchService {
  static List<Fatwa> _fatawa = [];
  static bool _loaded = false;
  static List<Fatwa> get allFatawa => List.unmodifiable(_fatawa);

  static Future<void> loadFatawa() async {
    if (_loaded) return;

    try {
      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
      // 1. ظ…ط­ط§ظˆظ„ط© ظ‚ط±ط§ط،ط© ط§ظ„ظپظ‡ط±ط³
      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
      try {
        final indexJson = await rootBundle.loadString(
          'assets/fatawa/fatawa_index.json',
        );
        final indexData = jsonDecode(indexJson);
        final files = List<String>.from(indexData['files']);

        debugPrint('ًں“‚ طھظ… ط§ظ„ط¹ط«ظˆط± ط¹ظ„ظ‰ ${files.length} ظ…ظ„ظپ ظپطھط§ظˆظ‰');

        // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
        // 2. ظ‚ط±ط§ط،ط© ظƒظ„ ظ…ظ„ظپ
        // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
        for (final fileName in files) {
          try {
            final filePath = 'assets/fatawa/$fileName';
            final fileJson = await rootBundle.loadString(filePath);
            final fileData = jsonDecode(fileJson);

            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            // 3. ط¯ط¹ظ… ط´ظƒظ„ظٹظ† ظ…ظ† ط§ظ„ط¨ظٹط§ظ†ط§طھ
            // ط§ظ„ط´ظƒظ„ 1: {"fatawa": [...], "source": "..."}
            // ط§ظ„ط´ظƒظ„ 2: ظ…طµظپظˆظپط© ظ…ط¨ط§ط´ط±ط© [...]
            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            List rawFatawa;
            String defaultSource;
            String defaultScholar;

            if (fileData is List) {
              // ط§ظ„ظ…ظ„ظپ ط¹ط¨ط§ط±ط© ط¹ظ† ظ…طµظپظˆظپط© ظ…ط¨ط§ط´ط±ط©
              rawFatawa = fileData;
              defaultSource = fileName.replaceAll('.json', '').replaceAll('fatawa_', '');
              defaultScholar = defaultSource;
            } else if (fileData is Map) {
              // ط§ظ„ظ…ظ„ظپ ط¹ط¨ط§ط±ط© ط¹ظ† ظƒط§ط¦ظ† ظپظٹظ‡ ظ…طµظپظˆظپط© fatawa
              rawFatawa = fileData['fatawa'] as List? ?? [];
              defaultSource = fileData['source']?.toString() ?? fileName;
              defaultScholar = fileData['scholar']?.toString() ?? defaultSource;
            } else {
              debugPrint('  âڑ ï¸ڈ ط´ظƒظ„ ط؛ظٹط± ظ…ط¹ط±ظˆظپ ظپظٹ $fileName');
              continue;
            }

            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            // 4. طھط­ظˆظٹظ„ ظƒظ„ ظپطھظˆظ‰ ظˆط¥ط¶ط§ظپط© ط§ظ„ظ‚ظٹظ… ط§ظ„ط§ظپطھط±ط§ط¶ظٹط©
            // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
            int count = 0;
            for (final rawFatwa in rawFatawa) {
              if (rawFatwa is! Map<String, dynamic>) continue;

              // ط¥ط¶ط§ظپط© ط§ظ„ظ…طµط¯ط± ط§ظ„ط§ظپطھط±ط§ط¶ظٹ ط¥ط°ط§ ط؛ظٹط± ظ…ظˆط¬ظˆط¯
              if (rawFatwa['source'] == null ||
                  rawFatwa['source'].toString().isEmpty) {
                rawFatwa['source'] = defaultSource;
              }

              // ط¥ط¶ط§ظپط© ط§ظ„ط¹ط§ظ„ظ… ط§ظ„ط§ظپطھط±ط§ط¶ظٹ ط¥ط°ط§ ط؛ظٹط± ظ…ظˆط¬ظˆط¯
              if (rawFatwa['scholar'] == null ||
                  rawFatwa['scholar'].toString().isEmpty) {
                rawFatwa['scholar'] = defaultScholar;
              }

              // ط¥ط¶ط§ظپط© ط§ظ„ظƒطھط§ط¨ ط§ظ„ط§ظپطھط±ط§ط¶ظٹ ط¥ط°ط§ ط؛ظٹط± ظ…ظˆط¬ظˆط¯
              if (rawFatwa['book'] == null ||
                  rawFatwa['book'].toString().isEmpty) {
                rawFatwa['book'] = defaultSource;
              }

              // طھط­ظˆظٹظ„ link ط¥ظ„ظ‰ url ط¥ط°ط§ ظ„ظ… ظٹظƒظ† url ظ…ظˆط¬ظˆط¯ط§ظ‹
              if ((rawFatwa['url'] == null ||
                  rawFatwa['url'].toString().isEmpty) &&
                  rawFatwa['link'] != null) {
                rawFatwa['url'] = rawFatwa['link'];
              }

              // طھط­ظˆظٹظ„ title ط¥ظ„ظ‰ question ط¥ط°ط§ ظ„ظ… ظٹظƒظ† question ظ…ظˆط¬ظˆط¯ط§ظ‹
              if ((rawFatwa['question'] == null ||
                  rawFatwa['question'].toString().isEmpty) &&
                  rawFatwa['title'] != null) {
                rawFatwa['question'] = rawFatwa['title'];
              }

              // ط§ط³طھط®ط±ط§ط¬ category ظ…ظ† categories ط¥ط°ط§ ظ„ظ… ظٹظƒظ† ظ…ظˆط¬ظˆط¯ط§ظ‹
              if ((rawFatwa['category'] == null ||
                  rawFatwa['category'].toString().isEmpty) &&
                  rawFatwa['categories'] != null) {
                final cats = rawFatwa['categories'];
                if (cats is List && cats.isNotEmpty) {
                  rawFatwa['category'] = cats.first.toString();
                }
              }

              // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
              // 5. طھط­ظˆظٹظ„ ط¥ظ„ظ‰ ظƒط§ط¦ظ† Fatwa
              // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
              try {
                final fatwa = Fatwa.fromJson(rawFatwa);

                // طھط¬ط§ظ‡ظ„ ط§ظ„ظپطھط§ظˆظ‰ ط§ظ„ظپط§ط±ط؛ط© ط£ظˆ ط§ظ„ظ‚طµظٹط±ط© ط¬ط¯ط§ظ‹
                if (fatwa.question.length > 5 && fatwa.answer.length > 20) {
                  _fatawa.add(fatwa);
                  count++;
                }
              } catch (e) {
                // طھط¬ط§ظ‡ظ„ ط§ظ„ظپطھظˆظ‰ ط§ظ„طھظٹ ظپط´ظ„ طھط­ظˆظٹظ„ظ‡ط§
                continue;
              }
            }

            debugPrint('  âœ… $fileName: $count ظپطھظˆظ‰ ($defaultSource)');
          } catch (e) {
            debugPrint('  âڑ ï¸ڈ طھط¹ط°ط± ظ‚ط±ط§ط،ط© $fileName: $e');
          }
        }

        _loaded = true;
        debugPrint('ًں“ٹ ط¥ط¬ظ…ط§ظ„ظٹ ط§ظ„ظپطھط§ظˆظ‰ ط§ظ„ظ…ط­ظ…ظ„ط©: ${_fatawa.length}');
        return;
      } catch (e) {
        debugPrint('âڑ ï¸ڈ ظ„ظ… ظٹطھظ… ط§ظ„ط¹ط«ظˆط± ط¹ظ„ظ‰ fatawa_index.json: $e');
      }

      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
      // 6. Fallback: ظ‚ط±ط§ط،ط© ط§ظ„ظ…ظ„ظپ ط§ظ„ظ‚ط¯ظٹظ… ط§ظ„ظ…ظˆط­ط¯
      // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
      try {
        debugPrint('ًں”„ ظ…ط­ط§ظˆظ„ط© طھط­ظ…ظٹظ„ fatawa.json ط§ظ„ظ‚ط¯ظٹظ…...');
        final json = await rootBundle.loadString('assets/fatawa/fatawa_main.json');
        final data = jsonDecode(json);

        List rawList;
        if (data is List) {
          rawList = data;
        } else if (data is Map) {
          rawList = data['fatawa'] as List? ?? [];
        } else {
          rawList = [];
        }

        for (final rawFatwa in rawList) {
          if (rawFatwa is! Map<String, dynamic>) continue;

          // ظ†ظپط³ ط§ظ„طھط­ظˆظٹظ„ط§طھ
          if ((rawFatwa['url'] == null ||
              rawFatwa['url'].toString().isEmpty) &&
              rawFatwa['link'] != null) {
            rawFatwa['url'] = rawFatwa['link'];
          }
          if ((rawFatwa['question'] == null ||
              rawFatwa['question'].toString().isEmpty) &&
              rawFatwa['title'] != null) {
            rawFatwa['question'] = rawFatwa['title'];
          }
          if ((rawFatwa['category'] == null ||
              rawFatwa['category'].toString().isEmpty) &&
              rawFatwa['categories'] != null) {
            final cats = rawFatwa['categories'];
            if (cats is List && cats.isNotEmpty) {
              rawFatwa['category'] = cats.first.toString();
            }
          }

          try {
            final fatwa = Fatwa.fromJson(rawFatwa);
            if (fatwa.question.length > 5 && fatwa.answer.length > 20) {
              _fatawa.add(fatwa);
            }
          } catch (_) {
            continue;
          }
        }

        _loaded = true;
        debugPrint('ًں“ٹ Fallback: ${_fatawa.length} ظپطھظˆظ‰');
      } catch (e) {
        debugPrint('â‌Œ ظپط´ظ„ طھط­ظ…ظٹظ„ fatawa.json: $e');
      }
    } catch (e) {
      debugPrint('â‌Œ ط®ط·ط£ ط¹ط§ظ… ظپظٹ loadFatawa: $e');
    }
  }

  static Future<ChatMessage> search(String userQuestion) async {
    await loadFatawa();

    if (_fatawa.isEmpty) {
      return ChatMessage.fromAssistantText('ظ„ظ… ظٹطھظ… طھط­ظ…ظٹظ„ ظ‚ط§ط¹ط¯ط© ط§ظ„ظپطھط§ظˆظ‰.');
    }

    final queries = await GeminiService.generateSearchQueries(userQuestion);
    final results = _searchLocal(queries);

    if (results.isEmpty) {
      return ChatMessage.fromAssistantText(
        'ظ„ظ… ط£ط¬ط¯ ظپطھظˆظ‰ ظ…ط·ط§ط¨ظ‚ط© ظ„ط³ط¤ط§ظ„ظƒ.\n\n'
            'ًں’، ط¬ط±ط¨ طµظٹط§ط؛ط© ظ…ط®طھظ„ظپط© ط£ظˆ ط§ط³ط£ظ„ ط£ظ‡ظ„ ط§ظ„ط¹ظ„ظ….\n\nط¬ط²ط§ظƒ ط§ظ„ظ„ظ‡ ط®ظٹط±ط§ظ‹ ًں¤²',
      );
    }

    final bySource = _groupBySource(results);

    if (bySource.length == 1) {
      return await _buildResponse(userQuestion, bySource.first, []);
    }

    return ChatMessage.chooseSource(sources: bySource);
  }

  static List<_Scored> _searchLocal(List<String> queries) {
    final scores = <String, _Scored>{};

    for (final query in queries) {
      final words = _tokenize(query);
      final normalized = _normalize(query);

      for (final fatwa in _fatawa) {
        final score = _calcScore(fatwa, words, normalized);
        if (score > 5) {
          if (!scores.containsKey(fatwa.id) || score > scores[fatwa.id]!.score) {
            scores[fatwa.id] = _Scored(fatwa: fatwa, score: score);
          }
        }
      }
    }

    return scores.values.toList()..sort((a, b) => b.score.compareTo(a.score));
  }

  static double _calcScore(Fatwa fatwa, List<String> words, String fullQuery) {
    final q = _normalize(fatwa.question);
    final t = _normalize(fatwa.title);
    final a = _normalize(fatwa.answer);
    final k = fatwa.keywords.map(_normalize).join(' ');
    final c = fatwa.categories.map(_normalize).join(' ');
    double score = 0;
    int matched = 0;

    // طھط·ط§ط¨ظ‚ ط§ظ„ط¹ط¨ط§ط±ط© ط§ظ„ظƒط§ظ…ظ„ط©
    if (q.contains(fullQuery)) score += 25;
    if (t.contains(fullQuery)) score += 20;

    for (final w in words) {
      if (w.length < 2) continue;
      bool found = false;

      // ط§ظ„ط³ط¤ط§ظ„ (ط£ظ‡ظ… ط´ظٹط،)
      if (q.contains(w)) { score += 8; found = true; }

      // ط§ظ„ط¹ظ†ظˆط§ظ†
      if (t.contains(w)) { score += 7; found = true; }

      // ط§ظ„طھطµظ†ظٹظپط§طھ
      if (c.contains(w)) { score += 6; found = true; }

      // ط§ظ„ظƒظ„ظ…ط§طھ ط§ظ„ظ…ظپطھط§ط­ظٹط©
      if (k.contains(w)) { score += 5; found = true; }

      // ط§ظ„ط¬ظˆط§ط¨
      if (a.contains(w)) { score += 3; found = true; }

      // ط¨ط­ط« ط¨ط§ظ„ط¬ط°ط±
      if (!found && w.length >= 4) {
        final root = w.substring(0, 4);
        if (q.contains(root) || t.contains(root)) {
          score += 3;
          found = true;
        } else if (a.contains(root)) {
          score += 1;
          found = true;
        }
      }

      if (found) matched++;
    }

    // ظ…ظƒط§ظپط£ط© ظ†ط³ط¨ط© ط§ظ„طھط·ط§ط¨ظ‚
    if (words.isNotEmpty) {
      final ratio = matched / words.length;
      if (ratio >= 0.8) score += 15;
      else if (ratio >= 0.6) score += 10;
      else if (ratio >= 0.4) score += 5;
      else if (ratio < 0.2) score -= 5;
    }

    return score;
  }

  static List<SourceOption> _groupBySource(List<_Scored> results) {
    final map = <String, _Scored>{};
    for (final r in results.take(15)) {
      final src = r.fatwa.book;
      if (!map.containsKey(src) || r.score > map[src]!.score) {
        map[src] = r;
      }
    }

    return map.entries.map((e) {
      final f = e.value.fatwa;
      return SourceOption(
        sourceName: f.book,
        title: f.question,
        answer: f.answer,
        url: f.id,
        relevance: e.value.score,
        fatwa: f,
      );
    }).toList()..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  static Future<ChatMessage> _buildResponse(
      String question, SourceOption option, List<SourceOption> others,
      ) async {
    String answer = option.answer;
    try {
      answer = await GeminiService.summarizeFatwa(
        userQuestion: question,
        fatwaText: option.answer,
        source: option.sourceName,
      );
    } catch (_) {}

    return ChatMessage.fromAssistantWithSource(
      introText: 'ظˆط¬ط¯طھ ظ„ظƒ ط§ظ„ط¬ظˆط§ط¨ ظ…ظ† ${option.sourceName}:\n\nًں“– ${option.title}',
      fatwa: option.fatwa,
      extractedAnswer: answer,
      confidence: AnswerConfidence.high,
      otherSources: others,
    );
  }

  static Future<ChatMessage> onSourceSelected(
      String question, SourceOption selected, List<SourceOption> all,
      ) async {
    final others = all.where((o) => o.sourceName != selected.sourceName).toList();
    return await _buildResponse(question, selected, others);
  }

  static String _normalize(String t) => t
      .replaceAll('ط£', 'ط§').replaceAll('ط¥', 'ط§').replaceAll('ط¢', 'ط§')
      .replaceAll('ط©', 'ظ‡').replaceAll('ظ‰', 'ظٹ').replaceAll('ط¤', 'ظˆ')
      .replaceAll(RegExp(r'[ظ‹ظŒظچظژظڈظگظ‘ظ’]'), '')
      .replaceAll(RegExp(r'\s+'), ' ').toLowerCase().trim();

  static List<String> _tokenize(String t) {
    const stop = {'ظ‡ظ„','ظ…ط§','ظ…ظ†','ظپظٹ','ط¹ظ„ظ‰','ط¹ظ†','ظٹط¬ظˆط²','ط­ظƒظ…','ظƒظٹظپ',
      'ظ‡ظˆ','ظ‡ظٹ','ط§ظ†','ظƒط§ظ†','ظ„ط§','ظ„ظ…','ظ‚ط¯','ط§ظ„ظ„ظ‡','ط±ط³ظˆظ„','ط§ظ„ظ†ط¨ظٹ',
      'طµظ„ظ‰','ط¹ظ„ظٹظ‡','ظˆط³ظ„ظ…','ط§ظ„ظ‰','ظ…ط¹','ظ‡ط°ط§','ظ‡ط°ظ‡','ط¨ظٹظ†','ط¹ظ†ط¯'};
    return _normalize(t).split(RegExp(r'[\sطŒطں!.,]+'))
        .where((w) => w.length > 2 && !stop.contains(w)).toList();
  }
}

class _Scored {
  final Fatwa fatwa;
  final double score;
  const _Scored({required this.fatwa, required this.score});
}