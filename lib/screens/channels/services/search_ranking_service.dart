import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';

class SearchRankingService {
  static List<YoutubeVideo> rankResults({
    required String query,
    required List<YoutubeVideo> results,
  }) {
    final normalizedQuery = _normalize(query);

    final ranked = List<YoutubeVideo>.from(results)
      ..sort((a, b) {
        final aScore = _score(normalizedQuery, a);
        final bScore = _score(normalizedQuery, b);
        return bScore.compareTo(aScore);
      });

    return ranked;
  }

  static double _score(String query, YoutubeVideo video) {
    final title = _normalize(video.title);
    final channel = _normalize(video.channelTitle);
    final desc = _normalize(video.description);

    final completed = VideoHistoryService.isCompleted(video.id);
    final partial = VideoHistoryService.isPartiallyWatched(video.id);

    final channelKey =
    video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    final usagePriority = ChannelUsageService.getPriorityScore(channelKey);

    double score = 0;

    if (title == query) score += 120;
    if (title.startsWith(query)) score += 60;
    if (title.contains(query)) score += 40;

    final queryTerms = query.split(' ').where((e) => e.trim().isNotEmpty).toList();
    for (final term in queryTerms) {
      if (title.contains(term)) score += 12;
      if (channel.contains(term)) score += 8;
      if (desc.contains(term)) score += 4;
    }

    if (channel.contains(query)) score += 18;
    if (desc.contains(query)) score += 8;

    final views = int.tryParse(video.viewCount) ?? 0;
    if (views > 0) {
      score += views.toString().length * 1.5;
    }

    final days = DateTime.now().difference(video.publishedAt).inDays;
    if (days <= 3) {
      score += 12;
    } else if (days <= 7) {
      score += 8;
    } else if (days <= 30) {
      score += 4;
    }

    score += usagePriority * 0.5;

    if (partial) score += 10;
    if (completed) score -= 8;

    if (YoutubeService.isLikelyShortVideo(video)) {
      score -= 3;
    }

    return score;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}