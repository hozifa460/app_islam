import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/feed_cache_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';

import 'channels_feed_recommender_service.dart';

class ChannelsPrefetchService {
  static bool _running = false;
  static DateTime? _lastRunAt;

  static const Duration _minInterval = Duration(minutes: 20);

  static Future<void> prefetchIfNeeded() async {
    if (_running) return;

    if (_lastRunAt != null &&
        DateTime.now().difference(_lastRunAt!) < _minInterval) {
      return;
    }

    try {
      final cached = await FeedCacheService.loadFeed();
      if (cached != null &&
          (cached.videos.isNotEmpty || cached.shorts.isNotEmpty)) {
        _lastRunAt = DateTime.now();
        return;
      }

      await prefetchNow();
    } catch (e) {
      debugPrint('❌ ChannelsPrefetchService.prefetchIfNeeded error: $e');
    }
  }

  static Future<void> prefetchNow() async {
    if (_running) return;
    _running = true;

    try {
      await ChannelUsageService.init();

      final jsonStr = await rootBundle.loadString('assets/json/channels.json');
      final List<dynamic> data = json.decode(jsonStr);

      final scholars = data.map((e) => Map<String, dynamic>.from(e)).toList();

      scholars.shuffle(Random());

      scholars.sort((a, b) {
        final aKey = _extractYoutubeKey(a);
        final bKey = _extractYoutubeKey(b);

        final aScore = ChannelUsageService.getPriorityScore(aKey);
        final bScore = ChannelUsageService.getPriorityScore(bKey);

        return bScore.compareTo(aScore);
      });

      final regular = <YoutubeVideo>[];
      final shorts = <YoutubeVideo>[];
      final seen = <String>{};

      for (final scholar in scholars.take(10)) {
        final platforms = scholar['platforms'] as List<dynamic>? ?? [];

        for (final p in platforms) {
          final pm = Map<String, dynamic>.from(p);

          if (pm['icon'] == 'youtube') {
            try {
              final videos = await YoutubeService.getChannelLatestBatch(
                channelUrl: pm['url'] ?? '',
                handle: pm['handle'],
                channelId: pm['channelId']?.toString(),
                maxResults: 10,
              );

              for (final v in videos) {
                if (v.id.isEmpty || v.title.trim().isEmpty) continue;
                if (!seen.add(v.id)) continue;

                if (YoutubeService.isLikelyShortVideo(v)) {
                  shorts.add(v);
                } else {
                  regular.add(v);
                }
              }
            } catch (_) {}

            break;
          }
        }

        if (regular.length >= 32 && shorts.length >= 14) {
          break;
        }
      }

      regular.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      shorts.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      final built = await ChannelsFeedRecommenderService.buildSmartFeed(
        pool: regular,
        shortsPool: shorts,
        sessionSeed: DateTime.now().millisecondsSinceEpoch,
      );

      if (built.videos.isNotEmpty || built.shorts.isNotEmpty) {
        await FeedCacheService.saveFeed(
          videos: built.videos,
          shorts: built.shorts,
          showingRecent: built.showingRecent,
        );
      }

      _lastRunAt = DateTime.now();

      debugPrint(
        '⚡ Channels prefetch done: ${built.videos.length} videos, ${built.shorts.length} shorts',
      );
    } catch (e) {
      debugPrint('❌ ChannelsPrefetchService.prefetchNow error: $e');
    } finally {
      _running = false;
    }
  }

  static Future<void> warmupBeforeOpen() async {
    try {
      await prefetchIfNeeded();
    } catch (e) {
      debugPrint('❌ warmupBeforeOpen error: $e');
    }
  }

  static Future<void> warmupAggressively() async {
    try {
      await prefetchNow();
    } catch (e) {
      debugPrint('❌ warmupAggressively error: $e');
    }
  }

  static String _extractYoutubeKey(Map<String, dynamic> scholar) {
    final platforms = scholar['platforms'] as List<dynamic>? ?? [];
    for (final p in platforms) {
      final pm = Map<String, dynamic>.from(p);
      if (pm['icon'] == 'youtube') {
        return (pm['url']?.toString().isNotEmpty == true)
            ? pm['url'].toString()
            : (pm['handle']?.toString() ?? scholar['name']?.toString() ?? '');
      }
    }
    return scholar['name']?.toString() ?? '';
  }
}