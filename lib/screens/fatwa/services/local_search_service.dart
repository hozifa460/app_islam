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
      // ═══════════════════════════════════════
      // 1. محاولة قراءة الفهرس
      // ═══════════════════════════════════════
      try {
        final indexJson = await rootBundle.loadString(
          'assets/fatawa/fatawa_index.json',
        );
        final indexData = jsonDecode(indexJson);
        final files = List<String>.from(indexData['files']);

        print('📂 تم العثور على ${files.length} ملف فتاوى');

        // ═══════════════════════════════════════
        // 2. قراءة كل ملف
        // ═══════════════════════════════════════
        for (final fileName in files) {
          try {
            final filePath = 'assets/fatawa/$fileName';
            final fileJson = await rootBundle.loadString(filePath);
            final fileData = jsonDecode(fileJson);

            // ═══════════════════════════════════════
            // 3. دعم شكلين من البيانات
            // الشكل 1: {"fatawa": [...], "source": "..."}
            // الشكل 2: مصفوفة مباشرة [...]
            // ═══════════════════════════════════════
            List rawFatawa;
            String defaultSource;
            String defaultScholar;

            if (fileData is List) {
              // الملف عبارة عن مصفوفة مباشرة
              rawFatawa = fileData;
              defaultSource = fileName.replaceAll('.json', '').replaceAll('fatawa_', '');
              defaultScholar = defaultSource;
            } else if (fileData is Map) {
              // الملف عبارة عن كائن فيه مصفوفة fatawa
              rawFatawa = fileData['fatawa'] as List? ?? [];
              defaultSource = fileData['source']?.toString() ?? fileName;
              defaultScholar = fileData['scholar']?.toString() ?? defaultSource;
            } else {
              print('  ⚠️ شكل غير معروف في $fileName');
              continue;
            }

            // ═══════════════════════════════════════
            // 4. تحويل كل فتوى وإضافة القيم الافتراضية
            // ═══════════════════════════════════════
            int count = 0;
            for (final rawFatwa in rawFatawa) {
              if (rawFatwa is! Map<String, dynamic>) continue;

              // إضافة المصدر الافتراضي إذا غير موجود
              if (rawFatwa['source'] == null ||
                  rawFatwa['source'].toString().isEmpty) {
                rawFatwa['source'] = defaultSource;
              }

              // إضافة العالم الافتراضي إذا غير موجود
              if (rawFatwa['scholar'] == null ||
                  rawFatwa['scholar'].toString().isEmpty) {
                rawFatwa['scholar'] = defaultScholar;
              }

              // إضافة الكتاب الافتراضي إذا غير موجود
              if (rawFatwa['book'] == null ||
                  rawFatwa['book'].toString().isEmpty) {
                rawFatwa['book'] = defaultSource;
              }

              // تحويل link إلى url إذا لم يكن url موجوداً
              if ((rawFatwa['url'] == null ||
                  rawFatwa['url'].toString().isEmpty) &&
                  rawFatwa['link'] != null) {
                rawFatwa['url'] = rawFatwa['link'];
              }

              // تحويل title إلى question إذا لم يكن question موجوداً
              if ((rawFatwa['question'] == null ||
                  rawFatwa['question'].toString().isEmpty) &&
                  rawFatwa['title'] != null) {
                rawFatwa['question'] = rawFatwa['title'];
              }

              // استخراج category من categories إذا لم يكن موجوداً
              if ((rawFatwa['category'] == null ||
                  rawFatwa['category'].toString().isEmpty) &&
                  rawFatwa['categories'] != null) {
                final cats = rawFatwa['categories'];
                if (cats is List && cats.isNotEmpty) {
                  rawFatwa['category'] = cats.first.toString();
                }
              }

              // ═══════════════════════════════════════
              // 5. تحويل إلى كائن Fatwa
              // ═══════════════════════════════════════
              try {
                final fatwa = Fatwa.fromJson(rawFatwa);

                // تجاهل الفتاوى الفارغة أو القصيرة جداً
                if (fatwa.question.length > 5 && fatwa.answer.length > 20) {
                  _fatawa.add(fatwa);
                  count++;
                }
              } catch (e) {
                // تجاهل الفتوى التي فشل تحويلها
                continue;
              }
            }

            print('  ✅ $fileName: $count فتوى ($defaultSource)');
          } catch (e) {
            print('  ⚠️ تعذر قراءة $fileName: $e');
          }
        }

        _loaded = true;
        print('📊 إجمالي الفتاوى المحملة: ${_fatawa.length}');
        return;
      } catch (e) {
        print('⚠️ لم يتم العثور على fatawa_index.json: $e');
      }

      // ═══════════════════════════════════════
      // 6. Fallback: قراءة الملف القديم الموحد
      // ═══════════════════════════════════════
      try {
        print('🔄 محاولة تحميل fatawa.json القديم...');
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

          // نفس التحويلات
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
        print('📊 Fallback: ${_fatawa.length} فتوى');
      } catch (e) {
        print('❌ فشل تحميل fatawa.json: $e');
      }
    } catch (e) {
      print('❌ خطأ عام في loadFatawa: $e');
    }
  }

  static Future<ChatMessage> search(String userQuestion) async {
    await loadFatawa();

    if (_fatawa.isEmpty) {
      return ChatMessage.fromAssistantText('لم يتم تحميل قاعدة الفتاوى.');
    }

    final queries = await GeminiService.generateSearchQueries(userQuestion);
    final results = _searchLocal(queries);

    if (results.isEmpty) {
      return ChatMessage.fromAssistantText(
        'لم أجد فتوى مطابقة لسؤالك.\n\n'
            '💡 جرب صياغة مختلفة أو اسأل أهل العلم.\n\nجزاك الله خيراً 🤲',
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

    // تطابق العبارة الكاملة
    if (q.contains(fullQuery)) score += 25;
    if (t.contains(fullQuery)) score += 20;

    for (final w in words) {
      if (w.length < 2) continue;
      bool found = false;

      // السؤال (أهم شيء)
      if (q.contains(w)) { score += 8; found = true; }

      // العنوان
      if (t.contains(w)) { score += 7; found = true; }

      // التصنيفات
      if (c.contains(w)) { score += 6; found = true; }

      // الكلمات المفتاحية
      if (k.contains(w)) { score += 5; found = true; }

      // الجواب
      if (a.contains(w)) { score += 3; found = true; }

      // بحث بالجذر
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

    // مكافأة نسبة التطابق
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
      introText: 'وجدت لك الجواب من ${option.sourceName}:\n\n📖 ${option.title}',
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
      .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه').replaceAll('ى', 'ي').replaceAll('ؤ', 'و')
      .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ').toLowerCase().trim();

  static List<String> _tokenize(String t) {
    const stop = {'هل','ما','من','في','على','عن','يجوز','حكم','كيف',
      'هو','هي','ان','كان','لا','لم','قد','الله','رسول','النبي',
      'صلى','عليه','وسلم','الى','مع','هذا','هذه','بين','عند'};
    return _normalize(t).split(RegExp(r'[\s،؟!.,]+'))
        .where((w) => w.length > 2 && !stop.contains(w)).toList();
  }
}

class _Scored {
  final Fatwa fatwa;
  final double score;
  const _Scored({required this.fatwa, required this.score});
}