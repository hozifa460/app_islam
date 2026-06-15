import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/screens/channels/helpers/youtube_video_codec.dart';
import '../services/youtube_service.dart';

class FavoritesManager extends ChangeNotifier {
  static FavoritesManager? _instance;
  static SharedPreferences? _prefs;

  static const String _keyFavoriteVideos = 'favorite_videos';
  static const String _keyFavoriteChannels = 'favorite_channels';
  static const String _keyWatchLater = 'watch_later';
  static const String _keyWatchHistory = 'watch_history';

  List<Map<String, dynamic>> _favoriteVideos = [];
  List<Map<String, dynamic>> _favoriteChannels = [];
  List<Map<String, dynamic>> _watchLater = [];
  List<Map<String, dynamic>> _watchHistory = [];

  List<Map<String, dynamic>> get favoriteVideos => List.unmodifiable(_favoriteVideos);
  List<Map<String, dynamic>> get favoriteChannels => List.unmodifiable(_favoriteChannels);
  List<Map<String, dynamic>> get watchLater => List.unmodifiable(_watchLater);
  List<Map<String, dynamic>> get watchHistory => List.unmodifiable(_watchHistory);

  int get favoriteVideosCount => _favoriteVideos.length;
  int get watchLaterCount => _watchLater.length;

  FavoritesManager._();

  static Future<FavoritesManager> getInstance() async {
    if (_instance == null) {
      _instance = FavoritesManager._();
      _prefs = await SharedPreferences.getInstance();
      await _instance!._loadAll();
    }
    return _instance!;
  }

  Future<void> _loadAll() async {
    _favoriteVideos = _loadList(_keyFavoriteVideos);
    _favoriteChannels = _loadList(_keyFavoriteChannels);
    _watchLater = _loadList(_keyWatchLater);
    _watchHistory = _loadList(_keyWatchHistory);

    debugPrint(
      '📚 Loaded: ${_favoriteVideos.length} favorites, ${_watchLater.length} watch later',
    );
  }

  List<Map<String, dynamic>> _loadList(String key) {
    try {
      final jsonStr = _prefs?.getString(key);
      if (jsonStr == null) return [];
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('❌ Load error for $key: $e');
      return [];
    }
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> list) async {
    try {
      await _prefs?.setString(key, json.encode(list));
    } catch (e) {
      debugPrint('❌ Save error for $key: $e');
    }
  }

  bool isVideoFavorite(String videoId) {
    return _favoriteVideos.any((v) => v['id'] == videoId);
  }

  Future<void> toggleVideoFavorite(YoutubeVideo video) async {
    final videoMap = _videoToMap(video);

    if (isVideoFavorite(video.id)) {
      _favoriteVideos.removeWhere((v) => v['id'] == video.id);
      debugPrint('💔 Removed from favorites: ${video.title}');
    } else {
      videoMap['addedAt'] = DateTime.now().toIso8601String();
      _favoriteVideos.insert(0, videoMap);
      debugPrint('❤️ Added to favorites: ${video.title}');
    }

    await _saveList(_keyFavoriteVideos, _favoriteVideos);
    notifyListeners();
  }

  Future<void> addVideoToFavorites(YoutubeVideo video) async {
    if (isVideoFavorite(video.id)) return;

    final videoMap = _videoToMap(video);
    videoMap['addedAt'] = DateTime.now().toIso8601String();
    _favoriteVideos.insert(0, videoMap);

    await _saveList(_keyFavoriteVideos, _favoriteVideos);
    notifyListeners();
  }

  Future<void> removeVideoFromFavorites(String videoId) async {
    _favoriteVideos.removeWhere((v) => v['id'] == videoId);
    await _saveList(_keyFavoriteVideos, _favoriteVideos);
    notifyListeners();
  }

  bool isInWatchLater(String videoId) {
    return _watchLater.any((v) => v['id'] == videoId);
  }

  Future<void> toggleWatchLater(YoutubeVideo video) async {
    final videoMap = _videoToMap(video);

    if (isInWatchLater(video.id)) {
      _watchLater.removeWhere((v) => v['id'] == video.id);
      debugPrint('📤 Removed from watch later: ${video.title}');
    } else {
      videoMap['addedAt'] = DateTime.now().toIso8601String();
      _watchLater.insert(0, videoMap);
      debugPrint('📥 Added to watch later: ${video.title}');
    }

    await _saveList(_keyWatchLater, _watchLater);
    notifyListeners();
  }

  Future<void> removeFromWatchLater(String videoId) async {
    _watchLater.removeWhere((v) => v['id'] == videoId);
    await _saveList(_keyWatchLater, _watchLater);
    notifyListeners();
  }

  Future<void> clearWatchLater() async {
    _watchLater.clear();
    await _saveList(_keyWatchLater, _watchLater);
    notifyListeners();
  }

  bool isChannelFavorite(String channelId) {
    return _favoriteChannels.any((c) => c['id'] == channelId);
  }

  Future<void> toggleChannelFavorite(Map<String, dynamic> channel) async {
    final channelId = channel['id'] ?? channel['channelId'] ?? '';

    if (isChannelFavorite(channelId)) {
      _favoriteChannels.removeWhere(
            (c) => c['id'] == channelId || c['channelId'] == channelId,
      );
      debugPrint('💔 Removed channel from favorites');
    } else {
      final channelMap = Map<String, dynamic>.from(channel);
      channelMap['addedAt'] = DateTime.now().toIso8601String();
      _favoriteChannels.insert(0, channelMap);
      debugPrint('❤️ Added channel to favorites');
    }

    await _saveList(_keyFavoriteChannels, _favoriteChannels);
    notifyListeners();
  }

  Future<void> addToHistory(YoutubeVideo video, {Duration? watchedDuration}) async {
    _watchHistory.removeWhere((v) => v['id'] == video.id);

    final videoMap = _videoToMap(video);
    videoMap['watchedAt'] = DateTime.now().toIso8601String();
    if (watchedDuration != null) {
      videoMap['watchedDuration'] = watchedDuration.inSeconds;
    }

    _watchHistory.insert(0, videoMap);

    if (_watchHistory.length > 100) {
      _watchHistory = _watchHistory.take(100).toList();
    }

    await _saveList(_keyWatchHistory, _watchHistory);
    notifyListeners();
  }

  Future<void> removeFromHistory(String videoId) async {
    _watchHistory.removeWhere((v) => v['id'] == videoId);
    await _saveList(_keyWatchHistory, _watchHistory);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _watchHistory.clear();
    await _saveList(_keyWatchHistory, _watchHistory);
    notifyListeners();
  }

  double? getWatchProgress(String videoId) {
    final video = _watchHistory.firstWhere(
          (v) => v['id'] == videoId,
      orElse: () => {},
    );

    if (video.isEmpty) return null;

    final watchedSeconds = video['watchedDuration'] as int?;
    final durationStr = video['duration'] as String?;

    if (watchedSeconds == null || durationStr == null) return null;

    final parts = durationStr.split(':');
    int totalSeconds = 0;

    if (parts.length == 2) {
      totalSeconds =
          (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    } else if (parts.length == 3) {
      totalSeconds = (int.tryParse(parts[0]) ?? 0) * 3600 +
          (int.tryParse(parts[1]) ?? 0) * 60 +
          (int.tryParse(parts[2]) ?? 0);
    }

    if (totalSeconds == 0) return null;
    return (watchedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  Map<String, dynamic> _videoToMap(YoutubeVideo video) {
    return YoutubeVideoCodec.toMap(video);
  }

  YoutubeVideo mapToVideo(Map<String, dynamic> map) {
    return YoutubeVideoCodec.fromMap(map) ??
        YoutubeVideo(
          id: '',
          title: '',
          description: '',
          thumbnail: '',
          channelTitle: '',
          publishedAt: DateTime.now(),
          viewCount: '0',
          likeCount: '0',
          duration: '',
          url: '',
        );
  }

  Map<String, dynamic> exportData() {
    return {
      'favoriteVideos': _favoriteVideos,
      'favoriteChannels': _favoriteChannels,
      'watchLater': _watchLater,
      'watchHistory': _watchHistory,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    if (data['favoriteVideos'] != null) {
      _favoriteVideos = List<Map<String, dynamic>>.from(
        (data['favoriteVideos'] as List)
            .map((e) => Map<String, dynamic>.from(e)),
      );
      await _saveList(_keyFavoriteVideos, _favoriteVideos);
    }

    if (data['favoriteChannels'] != null) {
      _favoriteChannels = List<Map<String, dynamic>>.from(
        (data['favoriteChannels'] as List)
            .map((e) => Map<String, dynamic>.from(e)),
      );
      await _saveList(_keyFavoriteChannels, _favoriteChannels);
    }

    if (data['watchLater'] != null) {
      _watchLater = List<Map<String, dynamic>>.from(
        (data['watchLater'] as List)
            .map((e) => Map<String, dynamic>.from(e)),
      );
      await _saveList(_keyWatchLater, _watchLater);
    }

    notifyListeners();
  }

  Future<void> clearAll() async {
    _favoriteVideos.clear();
    _favoriteChannels.clear();
    _watchLater.clear();
    _watchHistory.clear();

    await _prefs?.remove(_keyFavoriteVideos);
    await _prefs?.remove(_keyFavoriteChannels);
    await _prefs?.remove(_keyWatchLater);
    await _prefs?.remove(_keyWatchHistory);

    notifyListeners();
    debugPrint('🗑️ All favorites data cleared');
  }
}