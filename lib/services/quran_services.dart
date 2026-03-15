import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QuranService {
  static const String _fileName = 'quran_data.json';
  static Map<String, dynamic>? _cachedData;

  // ✅ طريقة جديدة للتحقق من الإنترنت
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  static Future<bool> isDataDownloaded() async {
    try {
      final file = await _getLocalFile();
      final exists = await file.exists();
      if (exists) {
        final contents = await file.readAsString();
        final data = json.decode(contents);
        return data['surahs'] != null && (data['surahs'] as List).length == 114;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> downloadAndSaveQuran({
    Function(int current, int total)? onProgress,
  }) async {
    try {
      List<Map<String, dynamic>> allSurahs = [];

      for (int i = 1; i <= 114; i++) {
        if (onProgress != null) {
          onProgress(i, 114);
        }

        final response = await http.get(
          Uri.parse('https://api.alquran.cloud/v1/surah/$i'),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final surahData = data['data'];

          allSurahs.add({
            'number': surahData['number'],
            'name': surahData['name'],
            'englishName': surahData['englishName'],
            'revelationType': surahData['revelationType'],
            'numberOfAyahs': surahData['numberOfAyahs'],
            'ayahs': (surahData['ayahs'] as List).map((ayah) {
              return {
                'number': ayah['numberInSurah'],
                'text': ayah['text'],
                'juz': ayah['juz'],
                'page': ayah['page'],
              };
            }).toList(),
          });
        } else {
          throw Exception('فشل تحميل سورة $i');
        }

        await Future.delayed(const Duration(milliseconds: 50));
      }

      final quranData = {
        'downloadDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'surahs': allSurahs,
      };

      final file = await _getLocalFile();
      await file.writeAsString(json.encode(quranData));

      _cachedData = quranData;
      return quranData;
    } catch (e) {
      print('خطأ في تحميل القرآن: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> loadLocalData() async {
    try {
      if (_cachedData != null) {
        return _cachedData;
      }

      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        _cachedData = json.decode(contents);
        return _cachedData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSurah(int surahNumber) async {
    final data = await loadLocalData();
    if (data != null) {
      final surahs = data['surahs'] as List;
      try {
        return Map<String, dynamic>.from(
          surahs.firstWhere((s) => s['number'] == surahNumber),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllSurahsList() async {
    final data = await loadLocalData();
    if (data != null) {
      return List<Map<String, dynamic>>.from(data['surahs']);
    }
    return [];
  }
}