import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// ═══════════════════════════════════════════════════════════════
///  مدير الكاش المركزي للتطبيق
/// ═══════════════════════════════════════════════════════════════
class CacheManager {
  static CacheManager? _instance;
  static SharedPreferences? _prefs;

  // مدة صلاحية الكاش (بالدقائق)
  static const int _videoCacheMinutes = 30;
  static const int _channelCacheMinutes = 60;
  static const int _searchCacheMinutes = 15;

  // مفاتيح الكاش
  static const String _keyVideosPrefix = 'cache_videos_';
  static const String _keyChannelPrefix = 'cache_channel_';
  static const String _keySearchPrefix = 'cache_search_';
  static const String _keyTimestampSuffix = '_timestamp';

  CacheManager._();

  static Future<CacheManager> getInstance() async {
    if (_instance == null) {
      _instance = CacheManager._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ═══════════════════════════════════════════
  //  كاش الفيديوهات
  // ═══════════════════════════════════════════

  /// حفظ فيديوهات قناة في الكاش
  Future<void> cacheChannelVideos(String channelId, List<Map<String, dynamic>> videos) async {
    try {
      final key = '$_keyVideosPrefix$channelId';
      final jsonStr = json.encode(videos);
      await _prefs?.setString(key, jsonStr);
      await _prefs?.setInt('$key$_keyTimestampSuffix', DateTime.now().millisecondsSinceEpoch);
      debugPrint('💾 Cached ${videos.length} videos for $channelId');
    } catch (e) {
      debugPrint('❌ Cache save error: $e');
    }
  }

  /// جلب فيديوهات قناة من الكاش
  List<Map<String, dynamic>>? getCachedChannelVideos(String channelId) {
    try {
      final key = '$_keyVideosPrefix$channelId';
      final timestamp = _prefs?.getInt('$key$_keyTimestampSuffix') ?? 0;

      // التحقق من صلاحية الكاش
      if (!_isValid(timestamp, _videoCacheMinutes)) {
        debugPrint('⏰ Cache expired for $channelId');
        return null;
      }

      final jsonStr = _prefs?.getString(key);
      if (jsonStr == null) return null;

      final List<dynamic> decoded = json.decode(jsonStr);
      debugPrint('📦 Retrieved ${decoded.length} cached videos for $channelId');
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  //  كاش معلومات القنوات
  // ═══════════════════════════════════════════

  Future<void> cacheChannelInfo(String channelId, Map<String, dynamic> info) async {
    try {
      final key = '$_keyChannelPrefix$channelId';
      await _prefs?.setString(key, json.encode(info));
      await _prefs?.setInt('$key$_keyTimestampSuffix', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('❌ Channel cache error: $e');
    }
  }

  Map<String, dynamic>? getCachedChannelInfo(String channelId) {
    try {
      final key = '$_keyChannelPrefix$channelId';
      final timestamp = _prefs?.getInt('$key$_keyTimestampSuffix') ?? 0;

      if (!_isValid(timestamp, _channelCacheMinutes)) return null;

      final jsonStr = _prefs?.getString(key);
      if (jsonStr == null) return null;

      return Map<String, dynamic>.from(json.decode(jsonStr));
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════
  //  كاش نتائج البحث
  // ═══════════════════════════════════════════

  Future<void> cacheSearchResults(String query, List<Map<String, dynamic>> results) async {
    try {
      final key = '$_keySearchPrefix${query.hashCode}';
      await _prefs?.setString(key, json.encode(results));
      await _prefs?.setInt('$key$_keyTimestampSuffix', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('❌ Search cache error: $e');
    }
  }

  List<Map<String, dynamic>>? getCachedSearchResults(String query) {
    try {
      final key = '$_keySearchPrefix${query.hashCode}';
      final timestamp = _prefs?.getInt('$key$_keyTimestampSuffix') ?? 0;

      if (!_isValid(timestamp, _searchCacheMinutes)) return null;

      final jsonStr = _prefs?.getString(key);
      if (jsonStr == null) return null;

      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════
  //  أدوات مساعدة
  // ═══════════════════════════════════════════

  bool _isValid(int timestamp, int validMinutes) {
    if (timestamp == 0) return false;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    return age < (validMinutes * 60 * 1000);
  }

  /// مسح كل الكاش
  Future<void> clearAll() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await _prefs?.remove(key);
      }
    }
    debugPrint('🗑️ All cache cleared');
  }

  /// مسح الكاش المنتهي الصلاحية
  Future<void> clearExpired() async {
    final keys = _prefs?.getKeys().toList() ?? [];
    int cleared = 0;

    for (final key in keys) {
      if (key.endsWith(_keyTimestampSuffix)) {
        final timestamp = _prefs?.getInt(key) ?? 0;
        final dataKey = key.replaceAll(_keyTimestampSuffix, '');

        int validMinutes = _videoCacheMinutes;
        if (dataKey.startsWith(_keyChannelPrefix)) {
          validMinutes = _channelCacheMinutes;
        } else if (dataKey.startsWith(_keySearchPrefix)) {
          validMinutes = _searchCacheMinutes;
        }

        if (!_isValid(timestamp, validMinutes)) {
          await _prefs?.remove(key);
          await _prefs?.remove(dataKey);
          cleared++;
        }
      }
    }

    if (cleared > 0) {
      debugPrint('🧹 Cleared $cleared expired cache entries');
    }
  }

  /// حجم الكاش التقريبي
  int getCacheSize() {
    int size = 0;
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        final value = _prefs?.getString(key);
        if (value != null) {
          size += value.length;
        }
      }
    }
    return size;
  }
}