import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QuranMushafPageService {
  static final Map<int, List<Map<String, dynamic>>> _memoryCache = {};
  static final Map<int, Future<List<Map<String, dynamic>>>> _pending = {};

  static Future<List<Map<String, dynamic>>> getPageWords(int page) {
    final cached = _memoryCache[page];
    if (cached != null) return Future.value(cached);
    return _pending.putIfAbsent(page, () => _loadPage(page));
  }

  static List<Map<String, dynamic>>? getCachedPageWords(int page) {
    return _memoryCache[page];
  }

  static Future<List<Map<String, dynamic>>> _loadPage(int page) async {
    try {
      final file = await _pageFile(page);
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        final words = _decodeWords(decoded);
        if (_isValid(words)) {
          _memoryCache[page] = words;
          return words;
        }
      }

      final response = await http
          .get(Uri.parse('https://www.ummahapi.com/api/quran/page/$page'))
          .timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) return const [];

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final words = _decodeWords(decoded);
      if (!_isValid(words)) return const [];

      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(decoded), flush: true);
      _memoryCache[page] = words;
      return words;
    } catch (error) {
      debugPrint('Mushaf page $page layout error: $error');
      return const [];
    } finally {
      _pending.remove(page);
    }
  }

  static List<Map<String, dynamic>> _decodeWords(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return const [];
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) return const [];
    final rawWords = data['words'];
    if (rawWords is! List) return const [];
    return rawWords
        .whereType<Map>()
        .map((word) {
          final normalized = Map<String, dynamic>.from(word);
          final text = normalized['text_uthmani'];
          if (text is String) {
            normalized['has_quarter_mark'] = text.contains(
              String.fromCharCode(0x06DE),
            );
            normalized['has_sajda_mark'] = text.contains(
              String.fromCharCode(0x06E9),
            );
            normalized['text_uthmani'] = _withoutInlineAnnotations(text);
          }
          return normalized;
        })
        .toList(growable: false);
  }

  // U+06D6–U+06ED are Qur'anic annotation characters. This font renders a
  // number of them as filled circular ornaments inside ordinary words.
  static String _withoutInlineAnnotations(String text) {
    return String.fromCharCodes(
      text.runes.where((rune) => rune < 0x06D6 || rune > 0x06ED),
    ).trim();
  }

  static bool _isValid(List<Map<String, dynamic>> words) {
    if (words.isEmpty) return false;
    return words.every((word) {
      final line = word['line_number'];
      return line is int && line >= 1 && line <= 15;
    });
  }

  static Future<File> _pageFile(int page) async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/mushaf_line_pages/$page.json');
  }

  static void prefetchAround(int page) {
    for (final nearby in [page - 2, page - 1, page + 1, page + 2]) {
      if (nearby >= 1 && nearby <= 604) getPageWords(nearby);
    }
  }
}
