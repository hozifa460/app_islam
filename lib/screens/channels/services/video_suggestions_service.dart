import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/feed_cache_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class VideoSuggestionsService {
  static Future<List<YoutubeVideo>> getSuggestions({
    required String currentVideoId,
    required String channelId,
    required String channelTitle,
    int maxResults = 15,
  }) async {
    final suggestions = <YoutubeVideo>[];
    final seen = <String>{currentVideoId};

    final sameChannelCandidates = <YoutubeVideo>[];
    final feedCandidates = <YoutubeVideo>[];
    final priorityCandidates = <YoutubeVideo>[];
    final continueWatchingCandidates = <YoutubeVideo>[];

    try {
      if (channelId.isNotEmpty) {
        final channelVideos = await YoutubeService.searchInChannel(
          channelId: channelId,
          query: '',
          maxResults: maxResults * 2,
        );

        for (final video in channelVideos) {
          if (!_isGoodSuggestion(video, currentVideoId)) continue;
          sameChannelCandidates.add(video);
        }
      }
    } catch (_) {}

    try {
      final feed = await FeedCacheService.loadFeed();
      if (feed != null) {
        final merged = [
          ...feed.videos,
          ...feed.shorts.where((v) => !YoutubeService.isLikelyShortVideo(v)),
        ];

        for (final video in merged) {
          if (!_isGoodSuggestion(video, currentVideoId)) continue;

          final key =
          video.channelId.isNotEmpty ? video.channelId : video.channelTitle;

          final sameCurrentChannel =
              (channelId.isNotEmpty && video.channelId == channelId) ||
                  (channelTitle.isNotEmpty &&
                      video.channelTitle == channelTitle);

          if (sameCurrentChannel) {
            sameChannelCandidates.add(video);
          } else if (ChannelUsageService.getPriorityScore(key) > 0) {
            priorityCandidates.add(video);
          } else {
            feedCandidates.add(video);
          }
        }
      }
    } catch (_) {}

    try {
      final feed = await FeedCacheService.loadFeed();
      if (feed != null) {
        final merged = [
          ...feed.videos,
          ...feed.shorts.where((v) => !YoutubeService.isLikelyShortVideo(v)),
        ];

        for (final video in merged) {
          if (!_isGoodSuggestion(video, currentVideoId)) continue;

          final progress = VideoHistoryService.getProgress(video.id);
          final completed = VideoHistoryService.isCompleted(video.id);

          if (!completed && progress > 0.08 && progress < 0.9) {
            continueWatchingCandidates.add(video);
          }
        }
      }
    } catch (_) {}

    final sameChannelRanked = _rankList(
      sameChannelCandidates,
      currentChannelId: channelId,
      currentChannelTitle: channelTitle,
      preferSameChannel: true,
    );

    final priorityRanked = _rankList(
      priorityCandidates,
      currentChannelId: channelId,
      currentChannelTitle: channelTitle,
      preferSameChannel: false,
    );

    final continueRanked = _rankList(
      continueWatchingCandidates,
      currentChannelId: channelId,
      currentChannelTitle: channelTitle,
      preferSameChannel: false,
    );

    final feedRanked = _rankList(
      feedCandidates,
      currentChannelId: channelId,
      currentChannelTitle: channelTitle,
      preferSameChannel: false,
    );

    final buckets = <List<YoutubeVideo>>[
      continueRanked,
      sameChannelRanked,
      priorityRanked,
      feedRanked,
    ];

    final channelCounts = <String, int>{};
    final int maxPerChannel = maxResults <= 8 ? 1 : 2;

    while (suggestions.length < maxResults) {
      bool addedAny = false;

      for (final bucket in buckets) {
        if (bucket.isEmpty) continue;

        YoutubeVideo? picked;

        for (final candidate in bucket) {
          final candidateChannel = candidate.channelId.isNotEmpty
              ? candidate.channelId
              : candidate.channelTitle;

          final count = channelCounts[candidateChannel] ?? 0;
          if (count >= maxPerChannel) continue;
          if (seen.contains(candidate.id)) continue;

          picked = candidate;
          break;
        }

        if (picked != null) {
          bucket.remove(picked);
          suggestions.add(picked);
          seen.add(picked.id);

          final candidateChannel = picked.channelId.isNotEmpty
              ? picked.channelId
              : picked.channelTitle;
          channelCounts[candidateChannel] =
              (channelCounts[candidateChannel] ?? 0) + 1;

          addedAny = true;
          if (suggestions.length >= maxResults) break;
        }
      }

      if (!addedAny) break;
    }

    final arranged = _spreadSuggestionsByChannel(suggestions);
    return arranged.take(maxResults).toList();
  }

  static YoutubeVideo? pickAutoplayNext({
    required List<YoutubeVideo> suggestions,
  }) {
    if (suggestions.isEmpty) return null;

    final ranked = List<YoutubeVideo>.from(suggestions)
      ..sort((a, b) {
        final aScore = _autoplayScore(a);
        final bScore = _autoplayScore(b);
        return bScore.compareTo(aScore);
      });

    final arranged = _spreadSuggestionsByChannel(ranked);
    return arranged.first;
  }

  static bool _isGoodSuggestion(YoutubeVideo video, String currentVideoId) {
    if (video.id.isEmpty) return false;
    if (video.id == currentVideoId) return false;
    if (video.title.trim().isEmpty) return false;
    if (YoutubeService.isLikelyShortVideo(video)) return false;
    return true;
  }

  static List<YoutubeVideo> _rankList(
      List<YoutubeVideo> items, {
        required String currentChannelId,
        required String currentChannelTitle,
        required bool preferSameChannel,
      }) {
    final map = <String, YoutubeVideo>{};

    for (final v in items) {
      map[v.id] = v;
    }

    final list = map.values.toList();

    list.sort((a, b) {
      final aScore = _score(
        a,
        currentChannelId: currentChannelId,
        currentChannelTitle: currentChannelTitle,
        preferSameChannel: preferSameChannel,
      );
      final bScore = _score(
        b,
        currentChannelId: currentChannelId,
        currentChannelTitle: currentChannelTitle,
        preferSameChannel: preferSameChannel,
      );
      return bScore.compareTo(aScore);
    });

    return list;
  }

  static double _score(
      YoutubeVideo video, {
        required String currentChannelId,
        required String currentChannelTitle,
        required bool preferSameChannel,
      }) {
    final sameChannel =
        (currentChannelId.isNotEmpty && video.channelId == currentChannelId) ||
            (currentChannelTitle.isNotEmpty &&
                video.channelTitle == currentChannelTitle);

    final completed = VideoHistoryService.isCompleted(video.id);
    final partial = VideoHistoryService.isPartiallyWatched(video.id);
    final progress = VideoHistoryService.getProgress(video.id);

    final channelKey =
    video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    final usagePriority = ChannelUsageService.getPriorityScore(channelKey);

    final views = int.tryParse(video.viewCount) ?? 0;
    final days = DateTime.now().difference(video.publishedAt).inDays;

    double freshness = 0;
    if (days <= 1) {
      freshness = 12;
    } else if (days <= 3) {
      freshness = 10;
    } else if (days <= 7) {
      freshness = 8;
    } else if (days <= 30) {
      freshness = 4;
    } else {
      freshness = 1;
    }

    double score = 0;

    if (preferSameChannel && sameChannel) score += 18;
    if (!preferSameChannel && sameChannel) score += 6;

    score += freshness;
    score += usagePriority * 0.5;
    score += _engagementStyleBonus(video);

    if (partial) score += 14;
    if (progress > 0 && progress < 0.9) score += 8;

    if (completed) score -= 10;

    if (views > 0) {
      score += views.toString().length.toDouble();
    }

    return score;
  }

  static double _autoplayScore(YoutubeVideo video) {
    final completed = VideoHistoryService.isCompleted(video.id);
    final partial = VideoHistoryService.isPartiallyWatched(video.id);
    final progress = VideoHistoryService.getProgress(video.id);

    final channelKey =
    video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    final usagePriority = ChannelUsageService.getPriorityScore(channelKey);

    final views = int.tryParse(video.viewCount) ?? 0;
    final days = DateTime.now().difference(video.publishedAt).inDays;

    double score = 0;

    if (partial) score += 24;
    if (progress > 0 && progress < 0.9) score += 10;
    if (completed) score -= 12;

    score += usagePriority * 0.7;
    score += _engagementStyleBonus(video);

    if (days <= 3) {
      score += 10;
    } else if (days <= 7) {
      score += 7;
    } else if (days <= 30) {
      score += 3;
    }

    if (views > 0) {
      score += views.toString().length * 1.3;
    }

    return score;
  }

  static double _engagementStyleBonus(YoutubeVideo video) {
    final title = video.title.toLowerCase();
    final desc = video.description.toLowerCase();

    double score = 0;

    if (title.contains('شرح') || desc.contains('شرح')) score += 1.5;
    if (title.contains('تفسير') || desc.contains('تفسير')) score += 1.5;
    if (title.contains('فتوى') || desc.contains('فتوى')) score += 1.2;
    if (title.contains('سؤال') || title.contains('جواب')) score += 1.4;
    if (title.contains('محاضرة') || desc.contains('محاضرة')) score += 1.0;
    if (title.contains('موعظة') || desc.contains('موعظة')) score += 1.1;
    if (title.contains('سيرة') || desc.contains('سيرة')) score += 1.0;
    if (title.contains('مختصر') || title.contains('دقائق')) score += 0.8;

    return score;
  }

  static List<YoutubeVideo> _spreadSuggestionsByChannel(
      List<YoutubeVideo> videos,
      ) {
    if (videos.length < 3) return videos;

    final result = <YoutubeVideo>[];
    final remaining = List<YoutubeVideo>.from(videos);

    while (remaining.isNotEmpty) {
      YoutubeVideo? picked;

      for (final candidate in remaining) {
        final candidateChannel = candidate.channelId.isNotEmpty
            ? candidate.channelId
            : candidate.channelTitle;

        final lastChannel = result.isNotEmpty
            ? (result.last.channelId.isNotEmpty
            ? result.last.channelId
            : result.last.channelTitle)
            : null;

        final secondLastChannel = result.length > 1
            ? (result[result.length - 2].channelId.isNotEmpty
            ? result[result.length - 2].channelId
            : result[result.length - 2].channelTitle)
            : null;

        if (candidateChannel != lastChannel &&
            candidateChannel != secondLastChannel) {
          picked = candidate;
          break;
        }
      }

      picked ??= remaining.first;
      result.add(picked);
      remaining.remove(picked);
    }

    return result;
  }
}