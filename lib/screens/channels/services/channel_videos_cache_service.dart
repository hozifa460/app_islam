import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/screens/channels/helpers/cache_compression_helper.dart';
import 'package:islamic_app/screens/channels/helpers/youtube_video_codec.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class ChannelVideosCacheService {
  static const int _maxLatestVideosPerType = 60;
  static const int _maxArchiveVideosPerType = 240;
  static const Duration _cacheAge = Duration(hours: 12);

  static String _videosKey(String channelId) => 'channel_videos_$channelId';
  static String _shortsKey(String channelId) => 'channel_shorts_$channelId';
  static String _liveKey(String channelId) => 'channel_live_$channelId';

  static String _latestVideosKey(String channelId) =>
      'channel_latest_videos_$channelId';
  static String _latestShortsKey(String channelId) =>
      'channel_latest_shorts_$channelId';
  static String _latestLiveKey(String channelId) =>
      'channel_latest_live_$channelId';

  static String _archiveVideosKey(String channelId) =>
      'channel_archive_videos_$channelId';
  static String _archiveShortsKey(String channelId) =>
      'channel_archive_shorts_$channelId';
  static String _archiveLiveKey(String channelId) =>
      'channel_archive_live_$channelId';

  static String _metaKey(String channelId) => 'channel_meta_$channelId';

  static Future<void> saveChannelData({
    required String channelId,
    required List<YoutubeVideo> regularVideos,
    required List<YoutubeVideo> shortsVideos,
    required List<YoutubeVideo> liveVideos,
    String? latestVideoId,
    bool reachedEnd = false,
    int loadMoreRound = 0,
    int emptyLoadMoreHits = 0,
  }) async {
    final latestRegular = regularVideos.take(30).toList();
    final latestShorts = shortsVideos.take(30).toList();
    final latestLive = liveVideos.take(20).toList();

    final archiveRegular =
    regularVideos.skip(30).take(_maxArchiveVideosPerType).toList();
    final archiveShorts =
    shortsVideos.skip(30).take(_maxArchiveVideosPerType).toList();
    final archiveLive =
    liveVideos.skip(20).take(_maxArchiveVideosPerType).toList();

    await saveChannelDataSegmented(
      channelId: channelId,
      latestRegularVideos: latestRegular,
      latestShortsVideos: latestShorts,
      latestLiveVideos: latestLive,
      archiveRegularVideos: archiveRegular,
      archiveShortsVideos: archiveShorts,
      archiveLiveVideos: archiveLive,
      latestVideoId: latestVideoId,
      reachedEnd: reachedEnd,
      loadMoreRound: loadMoreRound,
      emptyLoadMoreHits: emptyLoadMoreHits,
    );
  }

  static Future<void> saveChannelDataSegmented({
    required String channelId,
    required List<YoutubeVideo> latestRegularVideos,
    required List<YoutubeVideo> latestShortsVideos,
    required List<YoutubeVideo> latestLiveVideos,
    required List<YoutubeVideo> archiveRegularVideos,
    required List<YoutubeVideo> archiveShortsVideos,
    required List<YoutubeVideo> archiveLiveVideos,
    String? latestVideoId,
    bool reachedEnd = false,
    int loadMoreRound = 0,
    int emptyLoadMoreHits = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final latestRegularCompact = latestRegularVideos
          .take(_maxLatestVideosPerType)
          .map(YoutubeVideoCodec.toCompactList)
          .toList();

      final latestShortsCompact = latestShortsVideos
          .take(_maxLatestVideosPerType)
          .map(YoutubeVideoCodec.toCompactList)
          .toList();

      final latestLiveCompact = latestLiveVideos
          .take(_maxLatestVideosPerType)
          .map(YoutubeVideoCodec.toCompactList)
          .toList();

      final archiveRegularCompact = archiveRegularVideos
          .take(_maxArchiveVideosPerType)
          .map(YoutubeVideoCodec.toCompactList)
          .toList();

      final archiveShortsCompact = archiveShortsVideos
          .take(_maxArchiveVideosPerType)
          .map(YoutubeVideoCodec.toCompactList)
          .toList();

      final archiveLiveCompact = archiveLiveVideos
          .take(_maxArchiveVideosPerType)
          .map(YoutubeVideoCodec.toCompactList)
          .toList();

      await prefs.setString(
        _latestVideosKey(channelId),
        CacheCompressionHelper.encodeCompactList(
          latestRegularCompact,
          compress: false,
        ),
      );

      await prefs.setString(
        _latestShortsKey(channelId),
        CacheCompressionHelper.encodeCompactList(
          latestShortsCompact,
          compress: false,
        ),
      );

      await prefs.setString(
        _latestLiveKey(channelId),
        CacheCompressionHelper.encodeCompactList(
          latestLiveCompact,
          compress: false,
        ),
      );

      await prefs.setString(
        _archiveVideosKey(channelId),
        CacheCompressionHelper.encodeCompactList(
          archiveRegularCompact,
          compress: true,
        ),
      );

      await prefs.setString(
        _archiveShortsKey(channelId),
        CacheCompressionHelper.encodeCompactList(
          archiveShortsCompact,
          compress: true,
        ),
      );

      await prefs.setString(
        _archiveLiveKey(channelId),
        CacheCompressionHelper.encodeCompactList(
          archiveLiveCompact,
          compress: true,
        ),
      );

      await prefs.setString(
        _metaKey(channelId),
        jsonEncode({
          'updatedAt': DateTime.now().toIso8601String(),
          'latestVideoId': latestVideoId ?? '',
          'reachedEnd': reachedEnd,
          'loadMoreRound': loadMoreRound,
          'emptyLoadMoreHits': emptyLoadMoreHits,
          'segmented': true,
          'compressedArchive': true,
        }),
      );

      debugPrint('💾 Saved segmented+compressed channel cache: $channelId');
    } catch (e) {
      debugPrint('❌ saveChannelDataSegmented error: $e');
    }
  }

  static Future<ChannelCacheData?> loadChannelData(String channelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final latestRegularStr = prefs.getString(_latestVideosKey(channelId));
      final latestShortsStr = prefs.getString(_latestShortsKey(channelId));
      final latestLiveStr = prefs.getString(_latestLiveKey(channelId));

      final archiveRegularStr = prefs.getString(_archiveVideosKey(channelId));
      final archiveShortsStr = prefs.getString(_archiveShortsKey(channelId));
      final archiveLiveStr = prefs.getString(_archiveLiveKey(channelId));

      final oldRegularStr = prefs.getString(_videosKey(channelId));
      final oldShortsStr = prefs.getString(_shortsKey(channelId));
      final oldLiveStr = prefs.getString(_liveKey(channelId));

      final metaStr = prefs.getString(_metaKey(channelId));

      if (latestRegularStr == null &&
          latestShortsStr == null &&
          latestLiveStr == null &&
          oldRegularStr == null &&
          oldShortsStr == null &&
          oldLiveStr == null) {
        return null;
      }

      Map<String, dynamic> meta = {};
      if (metaStr != null) {
        meta = Map<String, dynamic>.from(jsonDecode(metaStr));
      }

      final updatedAt = DateTime.tryParse(meta['updatedAt']?.toString() ?? '');
      final expired =
          updatedAt == null || DateTime.now().difference(updatedAt) > _cacheAge;

      final latestRegularVideos = latestRegularStr == null
          ? (oldRegularStr == null ? <YoutubeVideo>[] : _decodeLegacyList(oldRegularStr))
          : _decodeCompressedCompactList(latestRegularStr);

      final latestShortsVideos = latestShortsStr == null
          ? (oldShortsStr == null ? <YoutubeVideo>[] : _decodeLegacyList(oldShortsStr))
          : _decodeCompressedCompactList(latestShortsStr);

      final latestLiveVideos = latestLiveStr == null
          ? (oldLiveStr == null ? <YoutubeVideo>[] : _decodeLegacyList(oldLiveStr))
          : _decodeCompressedCompactList(latestLiveStr);

      final archiveRegularVideos = archiveRegularStr == null
          ? <YoutubeVideo>[]
          : _decodeCompressedCompactList(archiveRegularStr);

      final archiveShortsVideos = archiveShortsStr == null
          ? <YoutubeVideo>[]
          : _decodeCompressedCompactList(archiveShortsStr);

      final archiveLiveVideos = archiveLiveStr == null
          ? <YoutubeVideo>[]
          : _decodeCompressedCompactList(archiveLiveStr);

      final regularVideos = _mergeUnique(latestRegularVideos, archiveRegularVideos);
      final shortsVideos = _mergeUnique(latestShortsVideos, archiveShortsVideos);
      final liveVideos = _mergeUnique(latestLiveVideos, archiveLiveVideos);

      return ChannelCacheData(
        regularVideos: regularVideos,
        shortsVideos: shortsVideos,
        liveVideos: liveVideos,
        latestRegularVideos: latestRegularVideos,
        latestShortsVideos: latestShortsVideos,
        latestLiveVideos: latestLiveVideos,
        archiveRegularVideos: archiveRegularVideos,
        archiveShortsVideos: archiveShortsVideos,
        archiveLiveVideos: archiveLiveVideos,
        latestVideoId: meta['latestVideoId']?.toString(),
        reachedEnd: meta['reachedEnd'] == true,
        updatedAt: updatedAt,
        expired: expired,
        loadMoreRound: int.tryParse('${meta['loadMoreRound'] ?? 0}') ?? 0,
        emptyLoadMoreHits:
        int.tryParse('${meta['emptyLoadMoreHits'] ?? 0}') ?? 0,
      );
    } catch (e) {
      debugPrint('❌ loadChannelData error: $e');
      return null;
    }
  }

  static bool shouldSave({
    required List<YoutubeVideo> oldRegular,
    required List<YoutubeVideo> oldShorts,
    required List<YoutubeVideo> oldLive,
    required List<YoutubeVideo> newRegular,
    required List<YoutubeVideo> newShorts,
    required List<YoutubeVideo> newLive,
  }) {
    bool sameList(List<YoutubeVideo> a, List<YoutubeVideo> b) {
      if (a.length != b.length) return false;
      if (a.isEmpty && b.isEmpty) return true;
      if (a.isEmpty || b.isEmpty) return false;

      final firstSame = a.first.id == b.first.id;
      final lastSame = a.last.id == b.last.id;
      return firstSame && lastSame;
    }

    return !(sameList(oldRegular, newRegular) &&
        sameList(oldShorts, newShorts) &&
        sameList(oldLive, newLive));
  }

  static Future<void> clearChannel(String channelId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_videosKey(channelId));
    await prefs.remove(_shortsKey(channelId));
    await prefs.remove(_liveKey(channelId));

    await prefs.remove(_latestVideosKey(channelId));
    await prefs.remove(_latestShortsKey(channelId));
    await prefs.remove(_latestLiveKey(channelId));

    await prefs.remove(_archiveVideosKey(channelId));
    await prefs.remove(_archiveShortsKey(channelId));
    await prefs.remove(_archiveLiveKey(channelId));

    await prefs.remove(_metaKey(channelId));
  }

  static List<YoutubeVideo> _mergeUnique(
      List<YoutubeVideo> latest,
      List<YoutubeVideo> archive,
      ) {
    final out = <YoutubeVideo>[];
    final seen = <String>{};

    for (final v in [...latest, ...archive]) {
      if (seen.add(v.id)) {
        out.add(v);
      }
    }

    return out;
  }

  static List<YoutubeVideo> _decodeLegacyList(String raw) {
    return (jsonDecode(raw) as List)
        .map((e) => YoutubeVideoCodec.fromMap(Map<String, dynamic>.from(e)))
        .whereType<YoutubeVideo>()
        .toList();
  }

  static List<YoutubeVideo> _decodeCompressedCompactList(String raw) {
    try {
      final decoded = CacheCompressionHelper.decodeCompactList(raw);
      return decoded
          .map((e) => YoutubeVideoCodec.fromCompactList(List.from(e)))
          .whereType<YoutubeVideo>()
          .toList();
    } catch (_) {
      try {
        final decoded = CacheCompressionHelper.decodeJson(raw);
        if (decoded is List) {
          return decoded
              .map((e) => YoutubeVideoCodec.fromCompactList(List.from(e)))
              .whereType<YoutubeVideo>()
              .toList();
        }
      } catch (_) {}
      return <YoutubeVideo>[];
    }
  }
}

class ChannelCacheData {
  final List<YoutubeVideo> regularVideos;
  final List<YoutubeVideo> shortsVideos;
  final List<YoutubeVideo> liveVideos;

  final List<YoutubeVideo> latestRegularVideos;
  final List<YoutubeVideo> latestShortsVideos;
  final List<YoutubeVideo> latestLiveVideos;

  final List<YoutubeVideo> archiveRegularVideos;
  final List<YoutubeVideo> archiveShortsVideos;
  final List<YoutubeVideo> archiveLiveVideos;

  final String? latestVideoId;
  final bool reachedEnd;
  final DateTime? updatedAt;
  final bool expired;
  final int loadMoreRound;
  final int emptyLoadMoreHits;

  ChannelCacheData({
    required this.regularVideos,
    required this.shortsVideos,
    required this.liveVideos,
    required this.latestRegularVideos,
    required this.latestShortsVideos,
    required this.latestLiveVideos,
    required this.archiveRegularVideos,
    required this.archiveShortsVideos,
    required this.archiveLiveVideos,
    required this.latestVideoId,
    required this.reachedEnd,
    required this.updatedAt,
    required this.expired,
    required this.loadMoreRound,
    required this.emptyLoadMoreHits,
  });
}