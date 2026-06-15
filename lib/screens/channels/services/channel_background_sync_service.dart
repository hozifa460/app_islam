import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/channel_videos_cache_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class ChannelBackgroundSyncService {
  static final Set<String> _queued = {};
  static final Map<String, DateTime> _lastSyncAt = {};
  static final Queue<_ChannelSyncJob> _queue = Queue<_ChannelSyncJob>();

  static bool _running = false;
  static bool _initialized = false;

  static const int _maxConcurrent = 2;
  static const Duration _minIntervalPerChannel = Duration(minutes: 45);
  static const Duration _queueGap = Duration(milliseconds: 350);

  static int _activeCount = 0;

  static Future<void> init() async {
    if (_initialized) return;
    await ChannelUsageService.init();
    _initialized = true;
  }

  static Future<void> enqueueChannels(
      List<ChannelSyncRequest> channels, {
        bool prioritizeByUsage = true,
      }) async {
    await init();

    final items = List<ChannelSyncRequest>.from(channels);

    if (prioritizeByUsage) {
      items.sort((a, b) {
        final aScore = ChannelUsageService.getPriorityScore(a.priorityKey);
        final bScore = ChannelUsageService.getPriorityScore(b.priorityKey);
        return bScore.compareTo(aScore);
      });
    }

    for (final item in items) {
      await enqueueChannel(item);
    }

    _pump();
  }

  static Future<void> enqueueChannel(ChannelSyncRequest request) async {
    await init();

    if (request.channelId.isEmpty || request.channelUrl.isEmpty) return;

    final last = _lastSyncAt[request.channelId];
    if (last != null &&
        DateTime.now().difference(last) < _minIntervalPerChannel &&
        !request.force) {
      return;
    }

    final queueKey = '${request.channelId}_${request.mode.name}_${request.maxResults}';
    if (_queued.contains(queueKey)) return;

    _queued.add(queueKey);
    _queue.add(
      _ChannelSyncJob(
        queueKey: queueKey,
        request: request,
        score: ChannelUsageService.getPriorityScore(request.priorityKey),
      ),
    );

    _sortQueue();
    _pump();
  }

  static void _sortQueue() {
    if (_queue.length <= 1) return;

    final list = _queue.toList()
      ..sort((a, b) {
        final modeWeightA = a.request.mode == ChannelSyncMode.latest ? 8.0 : 0.0;
        final modeWeightB = b.request.mode == ChannelSyncMode.latest ? 8.0 : 0.0;

        return (b.score + modeWeightB).compareTo(a.score + modeWeightA);
      });

    _queue
      ..clear()
      ..addAll(list);
  }

  static void _pump() {
    if (_running) return;
    _running = true;
    _runLoop();
  }

  static Future<void> _runLoop() async {
    while (_queue.isNotEmpty || _activeCount > 0) {
      while (_activeCount < _maxConcurrent && _queue.isNotEmpty) {
        final job = _queue.removeFirst();
        _activeCount++;
        _queued.remove(job.queueKey);

        unawaited(_runJob(job).whenComplete(() {
          _activeCount--;
        }));

        await Future.delayed(_queueGap);
      }

      await Future.delayed(const Duration(milliseconds: 150));
    }

    _running = false;
  }

  static Future<void> _runJob(_ChannelSyncJob job) async {
    final request = job.request;

    try {
      final oldCache =
      await ChannelVideosCacheService.loadChannelData(request.channelId);

      final oldRegular = oldCache?.regularVideos ?? <YoutubeVideo>[];
      final oldShorts = oldCache?.shortsVideos ?? <YoutubeVideo>[];
      final oldLive = oldCache?.liveVideos ?? <YoutubeVideo>[];

      if (request.mode == ChannelSyncMode.latest) {
        final latest = await YoutubeService.getChannelLatestBatch(
          channelUrl: request.channelUrl,
          handle: request.handle,
          maxResults: request.maxResults,
        );

        if (latest.isEmpty) return;

        final regular = <YoutubeVideo>[];
        final shorts = <YoutubeVideo>[];
        final live = <YoutubeVideo>[];

        for (final v in latest) {
          if (v.type == VideoType.live) {
            live.add(v);
          } else if (YoutubeService.isLikelyShortVideo(v)) {
            shorts.add(v);
          } else {
            regular.add(v);
          }
        }

        await ChannelVideosCacheService.saveChannelDataSegmented(
          channelId: request.channelId,
          latestRegularVideos: regular,
          latestShortsVideos: shorts,
          latestLiveVideos: live,
          archiveRegularVideos: oldCache?.archiveRegularVideos ?? const [],
          archiveShortsVideos: oldCache?.archiveShortsVideos ?? const [],
          archiveLiveVideos: oldCache?.archiveLiveVideos ?? const [],
          reachedEnd: oldCache?.reachedEnd ?? false,
          loadMoreRound: oldCache?.loadMoreRound ?? 0,
          emptyLoadMoreHits: oldCache?.emptyLoadMoreHits ?? 0,
        );
      } else {
        final full = await YoutubeService.getAllChannelVideos(
          channelUrl: request.channelUrl,
          handle: request.handle,
          maxResults: request.maxResults,
        );

        if (full.isEmpty) return;

        final regular = <YoutubeVideo>[];
        final shorts = <YoutubeVideo>[];
        final live = <YoutubeVideo>[];

        for (final v in full) {
          if (v.type == VideoType.live) {
            live.add(v);
          } else if (YoutubeService.isLikelyShortVideo(v)) {
            shorts.add(v);
          } else {
            regular.add(v);
          }
        }

        final latestRegular = regular.take(30).toList();
        final latestShorts = shorts.take(30).toList();
        final latestLive = live.take(20).toList();

        final archiveRegular = regular.skip(30).toList();
        final archiveShorts = shorts.skip(30).toList();
        final archiveLive = live.skip(20).toList();

        await ChannelVideosCacheService.saveChannelDataSegmented(
          channelId: request.channelId,
          latestRegularVideos: latestRegular,
          latestShortsVideos: latestShorts,
          latestLiveVideos: latestLive,
          archiveRegularVideos: archiveRegular,
          archiveShortsVideos: archiveShorts,
          archiveLiveVideos: archiveLive,
          reachedEnd: oldCache?.reachedEnd ?? false,
          loadMoreRound: oldCache?.loadMoreRound ?? 0,
          emptyLoadMoreHits: oldCache?.emptyLoadMoreHits ?? 0,
        );
      }

      _lastSyncAt[request.channelId] = DateTime.now();

      debugPrint(
        '🔄 Background sync done: ${request.channelId} (${request.mode.name})',
      );
    } catch (e) {
      debugPrint('❌ Background sync error (${request.channelId}): $e');
    }
  }
}

class ChannelSyncRequest {
  final String channelId;
  final String channelUrl;
  final String? handle;
  final String priorityKey;
  final int maxResults;
  final bool force;
  final ChannelSyncMode mode;

  const ChannelSyncRequest({
    required this.channelId,
    required this.channelUrl,
    required this.priorityKey,
    this.handle,
    this.maxResults = 60,
    this.force = false,
    this.mode = ChannelSyncMode.latest,
  });
}

enum ChannelSyncMode {
  latest,
  archive,
}

class _ChannelSyncJob {
  final String queueKey;
  final ChannelSyncRequest request;
  final double score;

  const _ChannelSyncJob({
    required this.queueKey,
    required this.request,
    required this.score,
  });
}