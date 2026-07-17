// ✅ في quran_text_service.dart — استبدل الدوال المتأثرة:

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranTextService {
  static const String _kFileName = 'quran_full_text_v2.json';
  static const String _kReadyKey = 'quran_text_ready_v2';

  static final Map<int, List<Map<String, dynamic>>> _pageCache = {};
  static final Map<int, List<Map<String, dynamic>>> _surahCache = {};
  static bool _isLoaded = false;

  static bool get isLoaded => _isLoaded;

  /// ─── مسار الملف المحلي ───
  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_kFileName');
  }

  /// ─── تحميل كل القرآن ───
  static Future<bool> downloadFullQuran({
    Function(double progress, String msg)? onProgress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_kReadyKey) == true) {
        if (await _loadFromLocal()) return true;
        await _invalidateLocalCache(prefs);
      }

      onProgress?.call(0.05, 'جاري تحميل نص القرآن...');

      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani'))
          .timeout(const Duration(seconds: 90));

      if (response.statusCode != 200) return false;

      onProgress?.call(0.4, 'جاري المعالجة...');

      final data = json.decode(response.body);
      final surahs = data['data']['surahs'] as List;

      List<Map<String, dynamic>> allSurahs = [];

      for (int i = 0; i < surahs.length; i++) {
        final s = surahs[i];
        allSurahs.add({
          'number': s['number'],
          'name': s['name'],
          'englishName': s['englishName'],
          'revelationType': s['revelationType'],
          'ayahs':
              (s['ayahs'] as List)
                  .map(
                    (a) => {
                      'number': a['number'],
                      'numberInSurah': a['numberInSurah'],
                      'text': a['text'],
                      'page': a['page'],
                      'juz': a['juz'],
                      'hizbQuarter': a['hizbQuarter'],
                    },
                  )
                  .toList(),
        });

        if (i % 10 == 0) {
          onProgress?.call(0.4 + (i / 114) * 0.5, 'سورة ${s['name']}...');
        }
      }

      // ✅ حفظ في ملف بدلاً من SharedPreferences
      final file = await _getLocalFile();
      final jsonStr = json.encode(allSurahs);
      await file.writeAsString(jsonStr, flush: true);

      // ✅ حذف البيانات القديمة من SharedPreferences إن وجدت
      await prefs.remove('quran_full_text_v2');

      _processIntoCache(allSurahs);
      if (!_hasCompleteQuran) {
        await _invalidateLocalCache(prefs);
        return false;
      }
      await prefs.setBool(_kReadyKey, true);
      onProgress?.call(1.0, 'تم!');

      return true;
    } catch (e) {
      debugPrint('QuranTextService download error: $e');
      return false;
    }
  }

  /// ─── تحميل من الملف المحلي ───
  static Future<bool> _loadFromLocal() async {
    if (_isLoaded) return true;

    try {
      final file = await _getLocalFile();

      if (!await file.exists()) {
        // ✅ محاولة الترحيل من SharedPreferences القديم
        final prefs = await SharedPreferences.getInstance();
        final oldData = prefs.getString('quran_full_text_v2');
        if (oldData != null) {
          await file.writeAsString(oldData, flush: true);
          await prefs.remove('quran_full_text_v2'); // حذف من الذاكرة
          debugPrint('✅ تم ترحيل البيانات من SharedPreferences إلى ملف');
        } else {
          return false;
        }
      }

      final jsonStr = await file.readAsString();
      final List<dynamic> surahs = json.decode(jsonStr);
      _processIntoCache(
        surahs.map((s) => Map<String, dynamic>.from(s)).toList(),
      );
      return _hasCompleteQuran;
    } catch (e) {
      debugPrint('Load from local error: $e');
      return false;
    }
  }

  /// ─── تحميل سريع ───
  static Future<bool> ensureLoaded() async {
    if (_isLoaded) return true;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kReadyKey) == true) {
      if (await _loadFromLocal()) return true;
      await _invalidateLocalCache(prefs);
    }
    return false;
  }

  static bool get _hasCompleteQuran {
    if (!_isLoaded || _surahCache.length != 114) return false;
    if ((_surahCache[1]?.length ?? 0) != 7) return false;
    if ((_pageCache[1]?.length ?? 0) != 7) return false;
    final ayahCount = _surahCache.values.fold<int>(
      0,
      (total, ayahs) => total + ayahs.length,
    );
    return ayahCount == 6236;
  }

  static Future<void> _invalidateLocalCache(SharedPreferences prefs) async {
    _isLoaded = false;
    _pageCache.clear();
    _surahCache.clear();
    await prefs.remove(_kReadyKey);
    final file = await _getLocalFile();
    if (await file.exists()) await file.delete();
  }

  /// ─── معالجة البيانات ───
  static void _processIntoCache(List<Map<String, dynamic>> surahs) {
    _pageCache.clear();
    _surahCache.clear();

    for (final surah in surahs) {
      final surahNum = surah['number'] as int;
      final ayahs =
          (surah['ayahs'] as List)
              .map(
                (a) =>
                    Map<String, dynamic>.from(a)
                      ..['surahNumber'] = surahNum
                      ..['surahName'] = surah['name'],
              )
              .toList();

      _surahCache[surahNum] = ayahs;

      for (final ayah in ayahs) {
        final page = ayah['page'] as int;
        _pageCache.putIfAbsent(page, () => []);
        _pageCache[page]!.add(ayah);
      }
    }

    _isLoaded = true;
  }

  // ═══ باقي الدوال بدون تغيير ═══

  static List<Map<String, dynamic>> getPageAyahs(int page) {
    return _pageCache[page] ?? [];
  }

  static List<Map<String, dynamic>> getSurahAyahs(int surahNumber) {
    return _surahCache[surahNumber] ?? [];
  }

  static String? getAyahText(int surahNumber, int ayahNumber) {
    final ayahs = _surahCache[surahNumber];
    if (ayahs == null) return null;
    for (final a in ayahs) {
      if (a['numberInSurah'] == ayahNumber) return a['text'];
    }
    return null;
  }

  static List<Map<String, dynamic>> search(String query) {
    if (query.length < 2 || !_isLoaded) return [];
    final normalized = _normalize(query);
    final results = <Map<String, dynamic>>[];
    for (final entry in _surahCache.entries) {
      for (final ayah in entry.value) {
        if (_normalize(ayah['text'] ?? '').contains(normalized)) {
          results.add(ayah);
          if (results.length >= 80) return results;
        }
      }
    }
    return results;
  }

  static String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ٱ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .trim();
  }

  static int getGlobalAyahNumber(int surahNumber, int ayahInSurah) {
    const counts = [
      7,
      286,
      200,
      176,
      120,
      165,
      206,
      75,
      129,
      109,
      123,
      111,
      43,
      52,
      99,
      128,
      111,
      110,
      98,
      135,
      112,
      78,
      118,
      64,
      77,
      227,
      93,
      88,
      69,
      60,
      34,
      30,
      73,
      54,
      45,
      83,
      182,
      88,
      75,
      85,
      54,
      53,
      89,
      59,
      37,
      35,
      38,
      29,
      18,
      45,
      60,
      49,
      62,
      55,
      78,
      96,
      29,
      22,
      24,
      13,
      14,
      11,
      11,
      18,
      12,
      12,
      30,
      52,
      52,
      44,
      28,
      28,
      20,
      56,
      40,
      31,
      50,
      40,
      46,
      42,
      29,
      19,
      36,
      25,
      22,
      17,
      19,
      26,
      30,
      20,
      15,
      21,
      11,
      8,
      8,
      19,
      5,
      8,
      8,
      11,
      11,
      8,
      3,
      9,
      5,
      4,
      7,
      3,
      6,
      3,
      5,
      4,
      5,
      6,
    ];
    int total = 0;
    for (int i = 0; i < surahNumber - 1; i++) {
      total += counts[i];
    }
    return total + ayahInSurah;
  }
}
