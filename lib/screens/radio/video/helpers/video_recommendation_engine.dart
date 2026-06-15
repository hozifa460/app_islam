// lib/screens/radio/video/video_recommendation_engine.dart

import 'dart:math';
import '../../data/recitation_categories_data.dart';
import '../../services/listening_history_service.dart';
import '../services/video_watch_history_service.dart';

class VideoRecommendationEngine {
  VideoRecommendationEngine._();

  /// ✅ ترتيب ذكي للفيديوهات
  static List<_ScoredVideo> recommend({
    required List<RecitationCategory> categories,
    required VideoWatchHistoryService watchHistory,
    required ListeningHistoryService listenHistory,
  }) {
    final scored = <_ScoredVideo>[];
    final random = Random();
    final watchScores = watchHistory.categoryScores;

    // ✅ درجات الاستماع
    final listenScores = <String, int>{};
    for (final item in listenHistory.history) {
      final key = item.stationName ?? item.title;
      listenScores[key] = (listenScores[key] ?? 0) + 1;
    }

    for (final cat in categories) {
      for (final item in cat.items) {
        // عناصر رئيسية
        if (item.hasVideo) {
          scored.add(_scoreItem(
            sub: RecitationSubItem(
              title: item.title,
              subtitle: item.subtitle,
              emoji: item.emoji,
              audioUrl: item.audioUrl ?? '',
              imageUrl: item.imageUrl,
              videoUrl: item.videoUrl,
              videoSource: item.videoSource,
              mediaType: item.mediaType,
            ),
            categoryTitle: cat.title,
            watchScores: watchScores,
            listenScores: listenScores,
            watchHistory: watchHistory,
            random: random,
          ));
        }

        // عناصر فرعية
        for (final sub in item.allSubItems) {
          if (sub.hasVideo) {
            scored.add(_scoreItem(
              sub: sub,
              categoryTitle: cat.title,
              watchScores: watchScores,
              listenScores: listenScores,
              watchHistory: watchHistory,
              random: random,
            ));
          }
        }
      }
    }

    // ✅ رتّب حسب الدرجة
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored;
  }

  static _ScoredVideo _scoreItem({
    required RecitationSubItem sub,
    required String categoryTitle,
    required Map<String, int> watchScores,
    required Map<String, int> listenScores,
    required VideoWatchHistoryService watchHistory,
    required Random random,
  }) {
    double score = 0;

    // ✅ 1. درجة القسم المفضل (من المشاهدة)
    final catWatchScore = watchScores[categoryTitle] ?? 0;
    score += catWatchScore * 3.0;

    // ✅ 2. درجة من الاستماع
    for (final key in listenScores.keys) {
      if (sub.title.contains(key) ||
          categoryTitle.contains(key)) {
        score += (listenScores[key] ?? 0) * 2.0;
      }
    }

    // ✅ 3. لم يُشاهد من قبل = أولوية أعلى
    if (!watchHistory.hasWatched(sub.videoUrl ?? '')) {
      score += 5.0;
    }

    // ✅ 4. عشوائية خفيفة للتنوع
    score += random.nextDouble() * 4.0;

    return _ScoredVideo(
      subItem: sub,
      categoryTitle: categoryTitle,
      score: score,
    );
  }
}

class _ScoredVideo {
  final RecitationSubItem subItem;
  final String categoryTitle;
  final double score;

  const _ScoredVideo({
    required this.subItem,
    required this.categoryTitle,
    required this.score,
  });
}