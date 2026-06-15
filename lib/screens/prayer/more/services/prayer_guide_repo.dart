import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PrayerGuideRepo {
  // ضع رابط ملفك هنا (Raw)
  static const String guideUrl =
      'https://raw.githubusercontent.com/hozifa460/islamic-content2/refs/heads/main/prayer_guide.json';

  static Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/prayer_guide_cache_v1.json');
  }

  /// تحميل من الإنترنت وتحديث الكاش
  static Future<Map<String, dynamic>> fetchOnlineAndCache() async {
    final res = await http.get(Uri.parse(guideUrl)).timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('Failed to load guide');
    }

    final file = await _cacheFile();
    await file.writeAsBytes(res.bodyBytes);
    return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// تحميل من الكاش (بدون إنترنت)
  static Future<Map<String, dynamic>> fetchFromCache() async {
    final file = await _cacheFile();
    if (!await file.exists()) {
      throw Exception('No cache');
    }
    final text = await file.readAsString();
    return json.decode(text) as Map<String, dynamic>;
  }

  /// تحميل ذكي: جرّب أونلاين، إذا فشل افتح من الكاش
  static Future<Map<String, dynamic>> fetchSmart() async {
    try {
      return await fetchOnlineAndCache();
    } catch (_) {
      return await fetchFromCache();
    }
  }
}