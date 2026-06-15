import '../cache/cache_manager.dart';
import '../helpers/youtube_video_codec.dart';
import '../services/youtube_service.dart';

class VideoCacheHelper {
  static Map<String, dynamic> videoToMap(YoutubeVideo video) {
    return YoutubeVideoCodec.toMap(video);
  }

  static YoutubeVideo mapToVideo(Map<String, dynamic> map) {
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

  static Future<void> cacheVideos(
      String channelId, List<YoutubeVideo> videos) async {
    final cache = await CacheManager.getInstance();
    final maps = videos.map(YoutubeVideoCodec.toMap).toList();
    await cache.cacheChannelVideos(channelId, maps);
  }

  static Future<List<YoutubeVideo>?> getCachedVideos(String channelId) async {
    final cache = await CacheManager.getInstance();
    final maps = cache.getCachedChannelVideos(channelId);
    if (maps == null) return null;
    return maps.map((e) => YoutubeVideoCodec.fromMap(e)).whereType<YoutubeVideo>().toList();
  }

  static Future<void> cacheSearchResults(
      String query, List<YoutubeVideo> videos) async {
    final cache = await CacheManager.getInstance();
    final maps = videos.map(YoutubeVideoCodec.toMap).toList();
    await cache.cacheSearchResults(query, maps);
  }

  static Future<List<YoutubeVideo>?> getCachedSearchResults(String query) async {
    final cache = await CacheManager.getInstance();
    final maps = cache.getCachedSearchResults(query);
    if (maps == null) return null;
    return maps.map((e) => YoutubeVideoCodec.fromMap(e)).whereType<YoutubeVideo>().toList();
  }
}