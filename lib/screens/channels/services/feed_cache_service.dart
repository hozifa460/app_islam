import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/screens/channels/helpers/cache_compression_helper.dart';
import 'package:islamic_app/screens/channels/helpers/youtube_video_codec.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class FeedCacheService {
  static const String _feedKey = 'cached_feed_videos_v3';
  static const String _shortsKey = 'cached_feed_shorts_v3';
  static const String _timestampKey = 'cached_feed_timestamp_v3';
  static const String _showingRecentKey = 'cached_feed_showing_recent_v3';

  static const Duration _cacheValidity = Duration(hours: 2);
  static const int _maxFeedVideos = 140;
  static const int _maxShortsVideos = 60;

  static Future<void> saveFeed({
    required List<YoutubeVideo> videos,
    required List<YoutubeVideo> shorts,
    bool showingRecent = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final feedCompact = videos
          .take(_maxFeedVideos)
          .map(YoutubeVideoCodec.toCompactList)
          .toList();

      final shortsCompact = shorts
          .take(_maxShortsVideos)
          .map(YoutubeVideoCodec.toCompactList)
          .toList();

      await prefs.setString(
        _feedKey,
        CacheCompressionHelper.encodeCompactList(
          feedCompact,
          compress: true,
        ),
      );

      await prefs.setString(
        _shortsKey,
        CacheCompressionHelper.encodeCompactList(
          shortsCompact,
          compress: true,
        ),
      );

      await prefs.setString(_timestampKey, DateTime.now().toIso8601String());
      await prefs.setBool(_showingRecentKey, showingRecent);

      debugPrint(
        '💾 Feed cache saved: ${feedCompact.length} videos, ${shortsCompact.length} shorts',
      );
    } catch (e) {
      debugPrint('❌ Feed cache save error: $e');
    }
  }

  static Future<
      ({List<YoutubeVideo> videos, List<YoutubeVideo> shorts, bool showingRecent})?>
  loadFeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final timestampStr = prefs.getString(_timestampKey);
      if (timestampStr == null) return null;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return null;

      if (DateTime.now().difference(timestamp) > _cacheValidity) {
        debugPrint('⏰ Feed cache expired');
        return null;
      }

      final feedStr = prefs.getString(_feedKey);
      final shortsStr = prefs.getString(_shortsKey);

      if (feedStr == null || shortsStr == null) return null;

      final feedDecoded = _decodeFeedList(feedStr);
      final shortsDecoded = _decodeFeedList(shortsStr);

      final videos = feedDecoded
          .whereType<List>()
          .map((e) => YoutubeVideoCodec.fromCompactList(List.from(e)))
          .whereType<YoutubeVideo>()
          .toList();

      final shorts = shortsDecoded
          .whereType<List>()
          .map((e) => YoutubeVideoCodec.fromCompactList(List.from(e)))
          .whereType<YoutubeVideo>()
          .toList();

      final showingRecent = prefs.getBool(_showingRecentKey) ?? true;

      debugPrint(
        '⚡ Feed cache loaded: ${videos.length} videos, ${shorts.length} shorts',
      );

      return (
      videos: videos,
      shorts: shorts,
      showingRecent: showingRecent,
      );
    } catch (e) {
      debugPrint('❌ Feed cache load error: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_feedKey);
      await prefs.remove(_shortsKey);
      await prefs.remove(_timestampKey);
      await prefs.remove(_showingRecentKey);
      debugPrint('🗑️ Feed cache cleared');
    } catch (e) {
      debugPrint('❌ Feed cache clear error: $e');
    }
  }

  static List<dynamic> _decodeFeedList(String raw) {
    try {
      return CacheCompressionHelper.decodeCompactList(raw);
    } catch (_) {
      try {
        final decoded = CacheCompressionHelper.decodeJson(raw);
        if (decoded is List) return decoded;
      } catch (_) {}
      return const [];
    }
  }
}