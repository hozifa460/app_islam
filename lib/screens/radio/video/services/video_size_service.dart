// lib/screens/radio/video/video_size_service.dart

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VideoSizeService {
  static final VideoSizeService _instance = VideoSizeService._internal();
  factory VideoSizeService() => _instance;
  VideoSizeService._internal();

  final Map<String, int> _cache = {};
  final Set<String> _loading = {};

  /// جلب الحجم بالبايتات
  Future<int?> getSize(String url) async {
    if (url.isEmpty) return null;

    final key = url.hashCode.abs().toString();

    // ✅ من الكاش
    if (_cache.containsKey(key)) return _cache[key];

    // ✅ من التخزين المحلي
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt('vsize_$key');
      if (saved != null && saved > 0) {
        _cache[key] = saved;
        return saved;
      }
    } catch (_) {}

    // ✅ جاري التحميل
    if (_loading.contains(key)) return null;
    _loading.add(key);

    try {
      final response = await http.head(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 8));

      final contentLength = response.headers['content-length'];
      if (contentLength != null) {
        final bytes = int.tryParse(contentLength);
        if (bytes != null && bytes > 0) {
          _cache[key] = bytes;

          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('vsize_$key', bytes);
          } catch (_) {}

          return bytes;
        }
      }
    } catch (e) {
      debugPrint('⚠️ VideoSizeService: $e');
    } finally {
      _loading.remove(key);
    }

    return null;
  }

  /// تنسيق الحجم
  static String formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}