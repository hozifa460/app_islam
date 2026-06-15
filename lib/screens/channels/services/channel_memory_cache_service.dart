import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class ChannelMemoryCacheService {
  static final Map<String, _ChannelMemoryEntry> _cache = {};
  static const Duration _validDuration = Duration(minutes: 5);
  static const int _maxChannels = 20;

  static ChannelMemoryData? get(String channelId) {
    final entry = _cache[channelId];
    if (entry == null) return null;

    final isExpired =
        DateTime.now().difference(entry.savedAt) > _validDuration;

    if (isExpired) {
      _cache.remove(channelId);
      return null;
    }

    entry.lastAccessed = DateTime.now();

    return ChannelMemoryData(
      regularVideos: List.from(entry.regularVideos),
      shortsVideos: List.from(entry.shortsVideos),
      liveVideos: List.from(entry.liveVideos),
      channelInfo: entry.channelInfo,
      reachedEnd: entry.reachedEnd,
      shortsLoadedOnce: entry.shortsLoadedOnce,
      liveLoadedOnce: entry.liveLoadedOnce,
      loadMoreRound: entry.loadMoreRound,
      emptyLoadMoreHits: entry.emptyLoadMoreHits,
    );
  }

  static void save({
    required String channelId,
    required List<YoutubeVideo> regularVideos,
    required List<YoutubeVideo> shortsVideos,
    required List<YoutubeVideo> liveVideos,
    required ChannelInfo? channelInfo,
    required bool reachedEnd,
    required bool shortsLoadedOnce,
    required bool liveLoadedOnce,
    required int loadMoreRound,
    required int emptyLoadMoreHits,
  }) {
    _cleanupIfNeeded();

    _cache[channelId] = _ChannelMemoryEntry(
      regularVideos: List.from(regularVideos),
      shortsVideos: List.from(shortsVideos),
      liveVideos: List.from(liveVideos),
      channelInfo: channelInfo,
      reachedEnd: reachedEnd,
      shortsLoadedOnce: shortsLoadedOnce,
      liveLoadedOnce: liveLoadedOnce,
      loadMoreRound: loadMoreRound,
      emptyLoadMoreHits: emptyLoadMoreHits,
      savedAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
  }

  static void remove(String channelId) {
    _cache.remove(channelId);
  }

  static void clearAll() {
    _cache.clear();
  }

  static void _cleanupIfNeeded() {
    _cache.removeWhere((key, value) {
      return DateTime.now().difference(value.savedAt) > _validDuration;
    });

    if (_cache.length >= _maxChannels) {
      final sortedEntries = _cache.entries.toList()
        ..sort((a, b) =>
            a.value.lastAccessed.compareTo(b.value.lastAccessed));

      final toRemoveCount = _cache.length - _maxChannels + 1;
      for (int i = 0; i < toRemoveCount; i++) {
        _cache.remove(sortedEntries[i].key);
      }
    }
  }
}

class ChannelMemoryData {
  final List<YoutubeVideo> regularVideos;
  final List<YoutubeVideo> shortsVideos;
  final List<YoutubeVideo> liveVideos;
  final ChannelInfo? channelInfo;
  final bool reachedEnd;
  final bool shortsLoadedOnce;
  final bool liveLoadedOnce;
  final int loadMoreRound;
  final int emptyLoadMoreHits;

  ChannelMemoryData({
    required this.regularVideos,
    required this.shortsVideos,
    required this.liveVideos,
    required this.channelInfo,
    required this.reachedEnd,
    required this.shortsLoadedOnce,
    required this.liveLoadedOnce,
    required this.loadMoreRound,
    required this.emptyLoadMoreHits,
  });
}

class _ChannelMemoryEntry {
  final List<YoutubeVideo> regularVideos;
  final List<YoutubeVideo> shortsVideos;
  final List<YoutubeVideo> liveVideos;
  final ChannelInfo? channelInfo;
  final bool reachedEnd;
  final bool shortsLoadedOnce;
  final bool liveLoadedOnce;
  final int loadMoreRound;
  final int emptyLoadMoreHits;
  final DateTime savedAt;
  DateTime lastAccessed;

  _ChannelMemoryEntry({
    required this.regularVideos,
    required this.shortsVideos,
    required this.liveVideos,
    required this.channelInfo,
    required this.reachedEnd,
    required this.shortsLoadedOnce,
    required this.liveLoadedOnce,
    required this.loadMoreRound,
    required this.emptyLoadMoreHits,
    required this.savedAt,
    required this.lastAccessed,
  });
}