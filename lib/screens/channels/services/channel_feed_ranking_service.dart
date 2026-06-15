import 'dart:collection';
import 'dart:math';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class ChannelFeedRankingService {
  // ✅ حد أقصى صارم لكل قناة
  static const int _maxPerChannelInFeed = 2;

  static List<YoutubeVideo> buildBalancedFeed({
    required List<YoutubeVideo> videos,
    int maxItems = 80,
  }) {
    if (videos.isEmpty) return [];

    // ✅ إزالة المكررات أولاً
    final seen = <String>{};
    final uniqueVideos = <YoutubeVideo>[];
    for (final v in videos) {
      if (v.id.isNotEmpty && seen.add(v.id)) {
        uniqueVideos.add(v);
      }
    }

    final grouped = <String, List<YoutubeVideo>>{};
    for (final video in uniqueVideos) {
      final key = video.channelId.isNotEmpty
          ? video.channelId
          : (video.channelTitle.isNotEmpty
          ? video.channelTitle
          : 'unknown_${video.id}');
      grouped.putIfAbsent(key, () => []).add(video);
    }

    // ترتيب فيديوهات كل قناة
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => _videoScore(b).compareTo(_videoScore(a)));
      // ✅ حد أقصى لكل قناة
      if (entry.value.length > _maxPerChannelInFeed) {
        grouped[entry.key] = entry.value.take(_maxPerChannelInFeed).toList();
      }
    }

    // ✅ ترتيب القنوات مع تنويع
    final channelOrder = grouped.keys.toList();
    channelOrder.sort((a, b) {
      final aScore = ChannelUsageService.getPriorityScore(a);
      final bScore = ChannelUsageService.getPriorityScore(b);

      // ✅ إضافة عشوائية بسيطة لكسر الأنماط
      final aJitter = (a.hashCode % 5) * 0.5;
      final bJitter = (b.hashCode % 5) * 0.5;

      return (bScore + bJitter).compareTo(aScore + aJitter);
    });

    final result = <YoutubeVideo>[];
    final recentChannelHits = Queue<String>();

    // ✅ Round-robin مع فصل أفضل
    int rounds = 0;
    while (result.length < maxItems && rounds < 50) {
      bool addedAny = false;

      for (final channelId in channelOrder) {
        final list = grouped[channelId];
        if (list == null || list.isEmpty) continue;

        // ✅ تحقق أن القناة لم تظهر في آخر 3
        if (recentChannelHits.length >= 3 &&
            recentChannelHits.contains(channelId)) {
          continue;
        }

        final next = list.removeAt(0);
        result.add(next);

        recentChannelHits.addLast(channelId);
        if (recentChannelHits.length > 4) {
          recentChannelHits.removeFirst();
        }

        addedAny = true;
        if (result.length >= maxItems) break;
      }

      if (!addedAny) {
        // إضافة الباقي بدون قيود
        for (final channelId in channelOrder) {
          final list = grouped[channelId];
          if (list == null || list.isEmpty) continue;
          result.addAll(list);
          list.clear();
        }
        break;
      }

      rounds++;
    }

    return result.take(maxItems).toList();
  }

  static double _videoScore(YoutubeVideo video) {
    final now = DateTime.now();
    final days = now.difference(video.publishedAt).inDays.clamp(0, 3650);

    final freshness = days <= 1
        ? 20.0
        : days <= 3
        ? 16.0
        : days <= 7
        ? 12.0
        : days <= 30
        ? 8.0
        : days <= 90
        ? 4.0
        : 1.0;

    final views = int.tryParse(video.viewCount) ?? 0;
    final popularity = views <= 0 ? 0.0 : log(views + 1) / ln10;

    final progress = VideoHistoryService.getProgress(video.id);
    final completed = VideoHistoryService.isCompleted(video.id);
    final shown = VideoHistoryService.isShown(video.id);

    final progressBoost = completed
        ? -25.0
        : progress >= 0.85
        ? -12.0
        : progress >= 0.2
        ? 8.0
        : 5.0;

    final shownPenalty = shown ? 2.0 : 0.0;

    final channelKey =
    video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    final channelPriority = ChannelUsageService.getPriorityScore(channelKey);

    return freshness +
        popularity +
        progressBoost +
        min(channelPriority * 0.3, 12.0) - // ✅ حد أقصى
        shownPenalty;
  }
}