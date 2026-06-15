import 'dart:convert';

import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePreviewCacheService {
  static const String _cachedPreviewKey = 'home_cached_preview_video_v1';
  static const String _cachedPreviewTimeKey = 'home_cached_preview_time_v1';
  static const String _lastVideoKey = 'home_preview_last_video_id';
  static const String _sessionVideoKey = 'home_preview_session_video_id';
  static const String _thumbnailLocalPathKey =
      'home_cached_preview_thumbnail_local_path_v1';

  static const Duration cacheDuration = Duration(hours: 6);

  static Future<void> savePreviewVideo(
      YoutubeVideo video, {
        String? thumbnailLocalPath,
      }) async {
    final prefs = await SharedPreferences.getInstance();

    final map = {
      'id': video.id,
      'title': video.title,
      'description': video.description,
      'thumbnail': video.thumbnail,
      'channelTitle': video.channelTitle,
      'channelId': video.channelId,
      'publishedAt': video.publishedAt.toIso8601String(),
      'viewCount': video.viewCount,
      'likeCount': video.likeCount,
      'commentCount': video.commentCount,
      'duration': video.duration,
      'url': video.url,
      'type': video.type.index,
    };

    await prefs.setString(_cachedPreviewKey, jsonEncode(map));
    await prefs.setString(
      _cachedPreviewTimeKey,
      DateTime.now().toIso8601String(),
    );

    if (thumbnailLocalPath != null && thumbnailLocalPath.isNotEmpty) {
      await prefs.setString(_thumbnailLocalPathKey, thumbnailLocalPath);
    }
  }

  static Future<YoutubeVideo?> getCachedPreviewVideo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString(_cachedPreviewKey);
      final timeRaw = prefs.getString(_cachedPreviewTimeKey);

      if (raw == null || timeRaw == null) return null;

      final savedAt = DateTime.tryParse(timeRaw);
      if (savedAt == null) return null;

      if (DateTime.now().difference(savedAt) > cacheDuration) {
        return null;
      }

      final map = Map<String, dynamic>.from(jsonDecode(raw));
      return _mapToVideo(map);
    } catch (_) {
      return null;
    }
  }

  static Future<YoutubeVideo?> getAnyCachedPreviewVideo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString(_cachedPreviewKey);
      if (raw == null || raw.isEmpty) return null;

      final map = Map<String, dynamic>.from(jsonDecode(raw));
      return _mapToVideo(map);
    } catch (_) {
      return null;
    }
  }

  static YoutubeVideo _mapToVideo(Map<String, dynamic> map) {
    return YoutubeVideo(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      channelTitle: map['channelTitle'] ?? '',
      channelId: map['channelId'] ?? '',
      publishedAt: DateTime.tryParse(map['publishedAt'] ?? '') ?? DateTime.now(),
      viewCount: map['viewCount'] ?? '0',
      likeCount: map['likeCount'] ?? '0',
      commentCount: map['commentCount'] ?? '0',
      duration: map['duration'] ?? '',
      url: map['url'] ?? '',
      type: VideoType.values[
      ((map['type'] ?? 0) as int).clamp(0, VideoType.values.length - 1)],
    );
  }

  static Future<void> setLastVideoId(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastVideoKey, videoId);
  }

  static Future<String?> getLastVideoId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastVideoKey);
  }

  static Future<void> setSessionVideoId(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionVideoKey, videoId);
  }

  static Future<String?> getSessionVideoId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionVideoKey);
  }

  static Future<void> clearSessionVideo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionVideoKey);
  }

  static Future<void> setThumbnailLocalPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_thumbnailLocalPathKey, path);
  }

  static Future<String?> getThumbnailLocalPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_thumbnailLocalPathKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedPreviewKey);
    await prefs.remove(_cachedPreviewTimeKey);
    await prefs.remove(_lastVideoKey);
    await prefs.remove(_sessionVideoKey);
    await prefs.remove(_thumbnailLocalPathKey);
  }
}