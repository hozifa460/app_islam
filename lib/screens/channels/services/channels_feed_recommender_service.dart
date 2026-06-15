import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:islamic_app/screens/channels/services/channel_feed_ranking_service.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/user_interest_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelsFeedRecommenderService {
  // ═══════════════════════════════════════════════
  //  Storage Keys
  // ═══════════════════════════════════════════════
  static const String _topFeedHistoryKey = 'channels_top_feed_history_v5';
  static const String _exposureKey = 'channels_exposure_v3';
  static const String _clickKey = 'channels_click_v3';
  static const String _fastClickKey = 'channels_fast_click_v3';
  static const String _lastInteractionKey = 'channels_last_interaction_v3';
  static const String _lastExposureTimeKey = 'channels_last_exposure_time_v3';
  static const String _rotationKey = 'channels_feed_rotation_v4';
  static const String _channelExposureCountKey = 'channels_feed_exposure_count_v1';

  static const int _rotationStep = 13;
  static const int _topFeedCount = 7;

  // ═══════════════════════════════════════════════
  //  ✅ حد أقصى صارم لكل قناة في الفيد النهائي
  // ═══════════════════════════════════════════════
  static const int _absoluteMaxPerChannel = 2;
  static const int _maxConsecutiveSameChannel = 1; // لا تتابع نفس القناة

  // ═══════════════════════════════════════════════
  //  Main Smart Feed Builder
  // ═══════════════════════════════════════════════
  static Future<
      ({List<YoutubeVideo> videos, List<YoutubeVideo> shorts, bool showingRecent})
  > buildSmartFeed({
    required List<YoutubeVideo> pool,
    required List<YoutubeVideo> shortsPool,
    required int sessionSeed,
  }) async {
    final random = Random(sessionSeed);
    bool showingRecent = true;

    final history = await _loadHistory();
    final stats = await _loadStats();
    final channelExposure = await _loadChannelExposureCount();

    // ── إزالة المكررات أولاً ──
    pool = _removeDuplicates(pool);
    shortsPool = _removeDuplicates(shortsPool);

    // ── تصنيف الفيديوهات ──
    final partial = <YoutubeVideo>[];
    final recent = <YoutubeVideo>[];
    final popular = <YoutubeVideo>[];

    for (final v in pool) {
      if (VideoHistoryService.isCompleted(v.id)) continue;

      if (VideoHistoryService.isPartiallyWatched(v.id)) {
        partial.add(v);
      } else {
        final days = DateTime.now().difference(v.publishedAt).inDays;
        if (days <= 30) {
          recent.add(v);
        } else {
          popular.add(v);
        }
      }
    }

    partial.sort((a, b) => VideoHistoryService.getProgress(b.id)
        .compareTo(VideoHistoryService.getProgress(a.id)));

    recent.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    popular.sort((a, b) {
      final vA = int.tryParse(a.viewCount) ?? 0;
      final vB = int.tryParse(b.viewCount) ?? 0;
      return vB.compareTo(vA);
    });

    // ── بناء القائمة الأولية ──
    List<YoutubeVideo> primaryList;

    if (partial.isNotEmpty) {
      primaryList = [...partial.take(6), ...recent, ...popular];
      showingRecent = true;
    } else if (recent.isNotEmpty) {
      primaryList = List.from(recent);
      showingRecent = true;
    } else if (popular.isNotEmpty) {
      primaryList = List.from(popular);
      showingRecent = false;
    } else {
      primaryList = List.from(pool);
      showingRecent = true;
    }

    // ✅ حد صارم لكل قناة
    primaryList = _strictLimitPerChannel(
      primaryList,
      maxPerChannel: _absoluteMaxPerChannel,
    );

    if (primaryList.length > 80) {
      primaryList = primaryList.take(80).toList();
    }

    // ── Scoring مع عقوبة القنوات المسيطرة ──
    final scored = primaryList.map((video) {
      final base = _scoreVideo(video);
      final penalty = _historyPenalty(video, history);
      final adaptive = _adaptiveBonus(video, stats);
      final engagement = _engagementBonus(video);
      final dominancePenalty = _channelDominancePenalty(video, channelExposure);
      final boost = random.nextDouble() * 3.0;

      return _Scored(
        video: video,
        score: base - penalty + adaptive + engagement - dominancePenalty + boost,
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    primaryList = scored.map((e) => e.video).toList();

    // ── ✅ Diversity Injection: ضمان تنوع القنوات ──
    primaryList = _ensureChannelDiversity(primaryList);

    // ── Spread + Balance ──
    primaryList = _spreadChannelsStrict(primaryList);

    primaryList = ChannelFeedRankingService.buildBalancedFeed(
      videos: primaryList,
      maxItems: 80,
    );

    // ── Rotation ──
    final rotIndex = await _loadRotation();

    if (primaryList.length > 16) {
      final eliteSize = min(28, primaryList.length);
      final elite = primaryList.take(eliteSize).toList();
      final rest = primaryList.skip(eliteSize).toList();

      final start = rotIndex % elite.length;
      final rotated = [...elite.skip(start), ...elite.take(start)];

      final window = rotated.take(min(16, rotated.length)).toList();
      final remaining = rotated.skip(window.length).toList();

      window.shuffle(random);

      primaryList = [...window, ...remaining, ...rest];
    }

    // ── ✅ Anti-Cluster الصارم ──
    primaryList = _antiClusterStrict(primaryList);

    // ── ✅ إزالة المكررات النهائية ──
    primaryList = _removeDuplicates(primaryList);

    // ── ✅ حد نهائي صارم لكل قناة ──
    primaryList = _strictLimitPerChannel(
      primaryList,
      maxPerChannel: _absoluteMaxPerChannel,
    );

    await _saveRotation(rotIndex + _rotationStep);

    if (primaryList.length > 80) {
      primaryList = primaryList.take(80).toList();
    }

    // ── Shorts ──
    var finalShorts = _buildSmartShorts(
      shortsPool: shortsPool,
      history: history,
      stats: stats,
      random: random,
      rotIndex: rotIndex,
      channelExposure: channelExposure,
    );

    // ── Save History + Exposure ──
    unawaited(_saveHistory(primaryList));
    unawaited(_updateChannelExposureCount(primaryList, finalShorts));

    return (
    videos: primaryList,
    shorts: finalShorts,
    showingRecent: showingRecent,
    );
  }

  // ═══════════════════════════════════════════════
  //  ✅ إزالة المكررات
  // ═══════════════════════════════════════════════
  static List<YoutubeVideo> _removeDuplicates(List<YoutubeVideo> videos) {
    final seen = <String>{};
    final result = <YoutubeVideo>[];

    for (final v in videos) {
      if (v.id.isNotEmpty && seen.add(v.id)) {
        result.add(v);
      }
    }

    return result;
  }

  // ═══════════════════════════════════════════════
  //  ✅ عقوبة القنوات المسيطرة
  // ═══════════════════════════════════════════════
  static double _channelDominancePenalty(
      YoutubeVideo video,
      Map<String, int> channelExposure,
      ) {
    final ch = video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    if (ch.isEmpty) return 0;

    final exposure = channelExposure[ch] ?? 0;

    // كلما ظهرت القناة أكثر، تزيد العقوبة بشكل تصاعدي
    if (exposure >= 20) return 40;
    if (exposure >= 15) return 30;
    if (exposure >= 10) return 20;
    if (exposure >= 7) return 12;
    if (exposure >= 5) return 6;
    if (exposure >= 3) return 3;
    return 0;
  }

  // ═══════════════════════════════════════════════
  //  ✅ ضمان تنوع القنوات
  // ═══════════════════════════════════════════════
  static List<YoutubeVideo> _ensureChannelDiversity(List<YoutubeVideo> videos) {
    if (videos.length <= 6) return videos;

    final channelCounts = <String, int>{};
    for (final v in videos) {
      final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;
      channelCounts[ch] = (channelCounts[ch] ?? 0) + 1;
    }

    final totalChannels = channelCounts.keys.length;
    if (totalChannels <= 3) return videos;

    // حساب الحد المثالي لكل قناة
    final idealMax = max(2, (videos.length / totalChannels).ceil());
    final effectiveMax = min(idealMax, _absoluteMaxPerChannel);

    final result = <YoutubeVideo>[];
    final currentCounts = <String, int>{};

    for (final v in videos) {
      final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;
      final count = currentCounts[ch] ?? 0;

      if (count < effectiveMax) {
        result.add(v);
        currentCounts[ch] = count + 1;
      }
    }

    return result;
  }

  // ═══════════════════════════════════════════════
  //  Fast Feed (للتحديثات السريعة)
  // ═══════════════════════════════════════════════
  static Future<
      ({List<YoutubeVideo> videos, List<YoutubeVideo> shorts, bool showingRecent})
  > buildFastFeed({
    required List<YoutubeVideo> pool,
    required List<YoutubeVideo> shortsPool,
    required int sessionSeed,
  }) async {
    final random = Random(sessionSeed);

    pool = _removeDuplicates(pool);
    shortsPool = _removeDuplicates(shortsPool);

    final unwatched = pool
        .where((v) => !VideoHistoryService.isCompleted(v.id))
        .toList();

    final source = unwatched.isNotEmpty ? unwatched : pool;
    final limited = _strictLimitPerChannel(
      source,
      maxPerChannel: _absoluteMaxPerChannel,
    );

    final sorted = List<YoutubeVideo>.from(limited)
      ..sort((a, b) => _fastScore(b).compareTo(_fastScore(a)));

    var result = _spreadChannelsStrict(sorted.take(60).toList());

    result = ChannelFeedRankingService.buildBalancedFeed(
      videos: result,
      maxItems: 60,
    );

    if (result.length > 16) {
      final start = sessionSeed % result.length;
      result = [...result.skip(start), ...result.take(start)];
    }

    result = _antiClusterStrict(result);
    result = _removeDuplicates(result);
    result = _strictLimitPerChannel(result, maxPerChannel: _absoluteMaxPerChannel);

    final shortsFiltered = shortsPool
        .where((v) => !VideoHistoryService.isCompleted(v.id))
        .toList();

    final shortsLimited = _strictLimitPerChannel(
      shortsFiltered,
      maxPerChannel: 2,
    );

    final shortsSorted = List<YoutubeVideo>.from(shortsLimited)
      ..sort((a, b) => _fastScore(b).compareTo(_fastScore(a)));

    var shorts = _spreadChannelsStrict(shortsSorted.take(24).toList());
    shorts.shuffle(random);
    shorts = _removeDuplicates(shorts);

    return (
    videos: result.take(60).toList(),
    shorts: shorts.take(24).toList(),
    showingRecent: true,
    );
  }

  // ═══════════════════════════════════════════════
  //  Smart Shorts Builder
  // ═══════════════════════════════════════════════
  static List<YoutubeVideo> _buildSmartShorts({
    required List<YoutubeVideo> shortsPool,
    required _History history,
    required _Stats stats,
    required Random random,
    required int rotIndex,
    required Map<String, int> channelExposure,
  }) {
    shortsPool = _removeDuplicates(shortsPool);

    final unwatched = VideoHistoryService.filterUnwatched(
      shortsPool,
          (v) => v.id,
    );

    final source = unwatched.isNotEmpty ? unwatched : shortsPool;
    final limited = _strictLimitPerChannel(source, maxPerChannel: 2);

    final scored = List<YoutubeVideo>.from(limited).map((video) {
      final base = _scoreVideo(video);
      final penalty = _historyPenalty(video, history) * 0.3;
      final adaptive = _adaptiveBonus(video, stats);
      final dominance = _channelDominancePenalty(video, channelExposure) * 0.5;
      final boost = random.nextDouble() * 3.0;

      return _Scored(
        video: video,
        score: base - penalty + adaptive - dominance + boost,
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    var result = scored.map((e) => e.video).toList();

    if (result.length > 10) {
      final start = rotIndex % result.length;
      result = [...result.skip(start), ...result.take(start)];

      final chunk = result.take(min(14, result.length)).toList()
        ..shuffle(random);
      final rest = result.skip(chunk.length).toList();

      result = [...chunk, ...rest];
    }

    result = _spreadChannelsStrict(result);
    result = _removeDuplicates(result);
    result = _strictLimitPerChannel(result, maxPerChannel: 2);

    return result.take(30).toList();
  }

  // ═══════════════════════════════════════════════
  //  Scoring
  // ═══════════════════════════════════════════════
  static double _scoreVideo(YoutubeVideo video) {
    final completed = VideoHistoryService.isCompleted(video.id);
    final partial = VideoHistoryService.isPartiallyWatched(video.id);
    final shown = VideoHistoryService.isShown(video.id);
    final progress = VideoHistoryService.getProgress(video.id);

    final views = int.tryParse(video.viewCount) ?? 0;
    final days = DateTime.now().difference(video.publishedAt).inDays;

    // 1. حداثة الفيديو (0-20)
    double freshness = days <= 1
        ? 20
        : days <= 3 ? 16
        : days <= 7 ? 12
        : days <= 14 ? 8
        : days <= 30 ? 5
        : days <= 90 ? 2
        : 0.5;

    // 2. ✅ اهتمام المستخدم الذكي (0-40)
    final interestScore = UserInterestService.getVideoInterestScore(
      channelId: video.channelId,
      channelTitle: video.channelTitle,
      videoTitle: video.title,
      description: video.description,
    );

    // 3. شعبية (0-10)
    double popularity = 0;
    if (views > 0) {
      popularity = min(log(views + 1) / ln10 * 1.5, 10.0);
    }

    // 4. حالة المشاهدة
    double watchBonus = 0;
    if (partial) watchBonus = 12;
    else if (progress > 0 && progress < 0.9) watchBonus = 8;
    if (completed) watchBonus = -30;

    // 5. جديد للمستخدم
    double novelty = shown ? 0 : 8;

    // 6. وقت اليوم
    double timeBonus = _timeOfDayBonus(video);

    // 7. محتوى
    double contentBonus = _engagementBonus(video);

    double score = freshness
        + interestScore * 0.5  // ✅ الاهتمام الذكي
        + popularity
        + watchBonus
        + novelty
        + timeBonus
        + contentBonus;

    return score;
  }

  static double _fastScore(YoutubeVideo video) {
    final completed = VideoHistoryService.isCompleted(video.id);
    final partial = VideoHistoryService.isPartiallyWatched(video.id);
    final progress = VideoHistoryService.getProgress(video.id);

    final views = int.tryParse(video.viewCount) ?? 0;
    final days = DateTime.now().difference(video.publishedAt).inDays;

    double freshness = days <= 1
        ? 18 : days <= 3 ? 14 : days <= 7 ? 10 : days <= 30 ? 6 : 2;

    // ✅ اهتمام ذكي
    final interest = UserInterestService.getVideoInterestScore(
      channelId: video.channelId,
      channelTitle: video.channelTitle,
      videoTitle: video.title,
      description: video.description,
    );

    double score = freshness + interest * 0.4;

    if (partial) score += 10;
    if (progress > 0 && progress < 0.9) score += 7;
    if (completed) score -= 25;
    if (views > 0) score += min(views.toString().length * 1.0, 8.0);

    return score;
  }

  // ═══════════════════════════════════════════════
  //  Engagement & Content Bonus
  // ═══════════════════════════════════════════════
  static double _engagementBonus(YoutubeVideo video) {
    final title = video.title.toLowerCase();
    final desc = video.description.toLowerCase();

    double score = 0;

    const keywords = [
      'تفسير', 'شرح', 'فتوى', 'محاضرة', 'درس', 'موعظة',
      'رقائق', 'سيرة', 'دعاء', 'ذكر', 'قرآن', 'حديث',
      'عقيدة', 'توحيد',
    ];

    for (final k in keywords) {
      if (title.contains(k) || desc.contains(k)) score += 1.2;
    }

    if (title.contains('سؤال') || title.contains('جواب')) score += 1.5;
    if (title.contains('مختصر') || title.contains('دقائق')) score += 1.0;
    if (title.contains('مؤثر') || title.contains('مهم')) score += 1.2;

    return min(score, 8.0); // حد أقصى
  }

  static double _timeOfDayBonus(YoutubeVideo video) {
    final hour = DateTime.now().hour;
    final title = video.title.toLowerCase();
    final desc = video.description.toLowerCase();

    double score = 0;

    if (hour >= 4 && hour < 10) {
      if (title.contains('قرآن') || desc.contains('قرآن')) score += 5;
      if (title.contains('تفسير') || desc.contains('تفسير')) score += 3;
      if (title.contains('ذكر') || desc.contains('ذكر')) score += 3;
    } else if (hour >= 10 && hour < 18) {
      if (title.contains('شرح') || desc.contains('شرح')) score += 3;
      if (title.contains('درس') || desc.contains('درس')) score += 3;
      if (title.contains('فتوى') || desc.contains('فتوى')) score += 2;
    } else {
      if (title.contains('موعظة') || desc.contains('موعظة')) score += 4;
      if (title.contains('رقائق') || desc.contains('رقائق')) score += 4;
      if (title.contains('دعاء') || desc.contains('دعاء')) score += 3;
    }

    return min(score, 6.0); // حد أقصى
  }

  // ═══════════════════════════════════════════════
  //  History Penalty
  // ═══════════════════════════════════════════════
  static double _historyPenalty(YoutubeVideo video, _History h) {
    double penalty = 0;

    final ch = video.channelId.isNotEmpty ? video.channelId : video.channelTitle;

    if (h.lastVideos.contains(video.id)) penalty += 35;
    else if (h.prevVideos.contains(video.id)) penalty += 16;

    if (ch.isNotEmpty) {
      if (h.lastChannels.contains(ch)) penalty += 20;
      else if (h.prevChannels.contains(ch)) penalty += 10;
    }

    return penalty;
  }

  // ═══════════════════════════════════════════════
  //  Adaptive Channel Adjustment
  // ═══════════════════════════════════════════════
  static double _adaptiveBonus(YoutubeVideo video, _Stats stats) {
    final ch = video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    if (ch.isEmpty) return 0;

    final exp = stats.exposure[ch] ?? 0;
    final clicks = stats.clicks[ch] ?? 0;
    final fast = stats.fastClicks[ch] ?? 0;
    final lastMs = stats.lastInteraction[ch];

    if (exp == 0) return 0;

    final ctr = clicks / exp;
    final fastCtr = fast / exp;
    final recency = _recencyMultiplier(lastMs);

    double adj = 0;

    // ✅ عقوبات أقوى للقنوات ذات CTR منخفض
    if (exp >= 6 && ctr < 0.10) adj -= 35;
    else if (exp >= 4 && ctr < 0.18) adj -= 20;

    // ✅ مكافآت محدودة
    if (ctr >= 0.45) adj += 10;
    else if (ctr >= 0.30) adj += 6;

    if (fastCtr >= 0.30) adj += 8;
    else if (fastCtr >= 0.18) adj += 4;

    return min(adj * recency, 15.0); // حد أقصى للمكافأة
  }

  static double _recencyMultiplier(int? ms) {
    if (ms == null || ms == 0) return 0.65;
    final days = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(ms))
        .inDays;
    if (days <= 1) return 1.2;
    if (days <= 3) return 1.1;
    if (days <= 7) return 1.0;
    if (days <= 14) return 0.85;
    if (days <= 30) return 0.72;
    return 0.55;
  }

  static List<YoutubeVideo> _strictLimitPerChannel(
      List<YoutubeVideo> videos, {
        int maxPerChannel = 2,
      }) {
    final counts = <String, int>{};
    final result = <YoutubeVideo>[];

    for (final v in videos) {
      final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;

      if (ch.isEmpty) {
        result.add(v);
        continue;
      }

      final count = counts[ch] ?? 0;
      if (count >= maxPerChannel) continue;

      counts[ch] = count + 1;
      result.add(v);
    }

    return result;
  }

  // ═══════════════════════════════════════════════
  //  ✅ Spread الصارم - يمنع تتابع نفس القناة
  // ═══════════════════════════════════════════════
  static List<YoutubeVideo> _spreadChannelsStrict(List<YoutubeVideo> videos) {
    if (videos.length <= 2) return videos;

    final result = <YoutubeVideo>[];
    final remaining = List<YoutubeVideo>.from(videos);
    final recentCh = Queue<String>();

    while (remaining.isNotEmpty) {
      int chosen = -1;

      // ابحث عن فيديو من قناة مختلفة عن آخر 3
      for (int i = 0; i < remaining.length; i++) {
        final ch = remaining[i].channelId.isNotEmpty
            ? remaining[i].channelId
            : remaining[i].channelTitle;

        if (!recentCh.contains(ch)) {
          chosen = i;
          break;
        }
      }

      // إذا كل القنوات المتبقية موجودة في الأخيرة، خذ الأول
      chosen = chosen == -1 ? 0 : chosen;

      final picked = remaining.removeAt(chosen);
      result.add(picked);

      final ch =
      picked.channelId.isNotEmpty ? picked.channelId : picked.channelTitle;
      recentCh.addLast(ch);

      // ✅ نافذة أكبر = توزيع أفضل
      if (recentCh.length > 4) recentCh.removeFirst();
    }

    return result;
  }

  // ═══════════════════════════════════════════════
  //  ✅ Anti-Cluster الصارم
  // ═══════════════════════════════════════════════
  static List<YoutubeVideo> _antiClusterStrict(List<YoutubeVideo> videos) {
    if (videos.length < 3) return videos;

    final result = <YoutubeVideo>[];
    final remaining = List<YoutubeVideo>.from(videos);
    final recentChannels = Queue<String>();

    while (remaining.isNotEmpty) {
      YoutubeVideo? picked;

      // ابحث عن فيديو من قناة لم تظهر في آخر 4
      for (final c in remaining) {
        final ch = c.channelId.isNotEmpty ? c.channelId : c.channelTitle;

        if (!recentChannels.contains(ch)) {
          picked = c;
          break;
        }
      }

      picked ??= remaining.first;
      result.add(picked);
      remaining.remove(picked);

      final ch =
      picked.channelId.isNotEmpty ? picked.channelId : picked.channelTitle;

      recentChannels.addLast(ch);
      // ✅ نافذة 4 بدل 3
      if (recentChannels.length > 4) {
        recentChannels.removeFirst();
      }
    }

    return result;
  }

  // ═══════════════════════════════════════════════
  //  ✅ تتبع عدد ظهور كل قناة في الفيد
  // ═══════════════════════════════════════════════
  static Future<Map<String, int>> _loadChannelExposureCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_channelExposureCountKey);
      if (raw == null || raw.isEmpty) return {};
      final decoded = Map<String, dynamic>.from(json.decode(raw));
      return decoded.map((k, v) => MapEntry(k, int.tryParse('$v') ?? 0));
    } catch (_) {
      return {};
    }
  }

  static Future<void> _updateChannelExposureCount(
      List<YoutubeVideo> videos,
      List<YoutubeVideo> shorts,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counts = await _loadChannelExposureCount();

      for (final v in [...videos.take(20), ...shorts.take(10)]) {
        final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;
        if (ch.isEmpty) continue;
        counts[ch] = (counts[ch] ?? 0) + 1;
      }

      // ✅ تقليل القيم القديمة تدريجياً (decay)
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastDecayKey = 'channel_exposure_last_decay';
      final lastDecay = prefs.getInt(lastDecayKey) ?? 0;

      if (now - lastDecay > 86400000) { // 24 ساعة
        for (final key in counts.keys.toList()) {
          counts[key] = ((counts[key] ?? 0) * 0.7).round();
          if ((counts[key] ?? 0) <= 0) counts.remove(key);
        }
        await prefs.setInt(lastDecayKey, now);
      }

      // تقليم
      if (counts.length > 200) {
        final sorted = counts.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        for (int i = 0; i < counts.length - 200; i++) {
          counts.remove(sorted[i].key);
        }
      }

      await prefs.setString(_channelExposureCountKey, json.encode(counts));
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════
  //  Tracking
  // ═══════════════════════════════════════════════
  static Future<void> trackTopFeedExposure(List<YoutubeVideo> videos) async {
    if (videos.isEmpty) return;

    final stats = await _loadStats();
    final exposure = Map<String, int>.from(stats.exposure);
    final now = DateTime.now().millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    final topIds = <String>[];

    for (final v in videos.take(_topFeedCount)) {
      final ch = v.channelId.isNotEmpty ? v.channelId : v.channelTitle;
      if (ch.isEmpty) continue;
      exposure[ch] = (exposure[ch] ?? 0) + 1;
      topIds.add(v.id);
    }

    await prefs.setString(
      _lastExposureTimeKey,
      json.encode({'time': now, 'topIds': topIds}),
    );

    await _saveStats(stats.copyWith(exposure: exposure));
  }

  static Future<void> trackTopFeedClick(YoutubeVideo video) async {
    final ch = video.channelId.isNotEmpty ? video.channelId : video.channelTitle;
    if (ch.isEmpty) return;

    final stats = await _loadStats();
    final clicks = Map<String, int>.from(stats.clicks);
    final fastClicks = Map<String, int>.from(stats.fastClicks);
    final lastInteraction = Map<String, int>.from(stats.lastInteraction);

    clicks[ch] = (clicks[ch] ?? 0) + 1;
    lastInteraction[ch] = DateTime.now().millisecondsSinceEpoch;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lastExposureTimeKey);

      if (raw != null && raw.isNotEmpty) {
        final d = Map<String, dynamic>.from(json.decode(raw));
        final time = int.tryParse('${d['time'] ?? 0}') ?? 0;
        final topIds = List<String>.from(d['topIds'] ?? const []);
        final now = DateTime.now().millisecondsSinceEpoch;

        if (topIds.contains(video.id) && ((now - time) / 1000).floor() <= 6) {
          fastClicks[ch] = (fastClicks[ch] ?? 0) + 1;
          lastInteraction[ch] = now;
        }
      }
    } catch (_) {}

    await _saveStats(stats.copyWith(
      clicks: clicks,
      fastClicks: fastClicks,
      lastInteraction: lastInteraction,
    ));
  }

  // ═══════════════════════════════════════════════
  //  Storage Helpers
  // ═══════════════════════════════════════════════
  static Future<int> _loadRotation() async {
    try {
      return (await SharedPreferences.getInstance()).getInt(_rotationKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> _saveRotation(int v) async {
    try {
      (await SharedPreferences.getInstance()).setInt(_rotationKey, v);
    } catch (_) {}
  }

  static Future<_History> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_topFeedHistoryKey);
      if (raw == null || raw.isEmpty) return _History.empty();
      return _History.fromJson(Map<String, dynamic>.from(json.decode(raw)));
    } catch (_) {
      return _History.empty();
    }
  }

  static Future<void> _saveHistory(List<YoutubeVideo> videos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final old = await _loadHistory();

      final top = videos.take(_topFeedCount).toList();
      final ids = top.map((v) => v.id).toList();
      final channels = top
          .map((v) => v.channelId.isNotEmpty ? v.channelId : v.channelTitle)
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();

      await prefs.setString(
        _topFeedHistoryKey,
        json.encode(_History(
          lastVideos: ids,
          prevVideos: old.lastVideos,
          lastChannels: channels,
          prevChannels: old.lastChannels,
        ).toJson()),
      );
    } catch (_) {}
  }

  static Future<_Stats> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      Map<String, int> decode(String? raw) {
        if (raw == null || raw.isEmpty) return {};
        final d = Map<String, dynamic>.from(json.decode(raw));
        return d.map((k, v) => MapEntry(k, int.tryParse('$v') ?? 0));
      }

      return _Stats(
        exposure: decode(prefs.getString(_exposureKey)),
        clicks: decode(prefs.getString(_clickKey)),
        fastClicks: decode(prefs.getString(_fastClickKey)),
        lastInteraction: decode(prefs.getString(_lastInteractionKey)),
      );
    } catch (_) {
      return _Stats.empty();
    }
  }

  static Future<void> _saveStats(_Stats s) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _trim(s.exposure, s.clicks, s.fastClicks, s.lastInteraction);

      await prefs.setString(_exposureKey, json.encode(s.exposure));
      await prefs.setString(_clickKey, json.encode(s.clicks));
      await prefs.setString(_fastClickKey, json.encode(s.fastClicks));
      await prefs.setString(
          _lastInteractionKey, json.encode(s.lastInteraction));
    } catch (_) {}
  }

  static void _trim(
      Map<String, int> exposure,
      Map<String, int> clicks,
      Map<String, int> fastClicks,
      Map<String, int> lastInteraction,
      ) {
    if (exposure.length > 200) {
      final keys = exposure.keys.toList()
        ..sort((a, b) => (exposure[a] ?? 0).compareTo(exposure[b] ?? 0));

      for (int i = 0; i < exposure.length - 200; i++) {
        final k = keys[i];
        exposure.remove(k);
        clicks.remove(k);
        fastClicks.remove(k);
        lastInteraction.remove(k);
      }
    }
  }
}

// ═══════════════════════════════════════════════
//  Data Classes
// ═══════════════════════════════════════════════
class _History {
  final List<String> lastVideos;
  final List<String> prevVideos;
  final List<String> lastChannels;
  final List<String> prevChannels;

  const _History({
    required this.lastVideos,
    required this.prevVideos,
    required this.lastChannels,
    required this.prevChannels,
  });

  Map<String, dynamic> toJson() => {
    'lv': lastVideos,
    'pv': prevVideos,
    'lc': lastChannels,
    'pc': prevChannels,
  };

  factory _History.fromJson(Map<String, dynamic> j) => _History(
    lastVideos: List<String>.from(j['lv'] ?? const []),
    prevVideos: List<String>.from(j['pv'] ?? const []),
    lastChannels: List<String>.from(j['lc'] ?? const []),
    prevChannels: List<String>.from(j['pc'] ?? const []),
  );

  factory _History.empty() => const _History(
    lastVideos: [],
    prevVideos: [],
    lastChannels: [],
    prevChannels: [],
  );
}

class _Stats {
  final Map<String, int> exposure;
  final Map<String, int> clicks;
  final Map<String, int> fastClicks;
  final Map<String, int> lastInteraction;

  const _Stats({
    required this.exposure,
    required this.clicks,
    required this.fastClicks,
    required this.lastInteraction,
  });

  factory _Stats.empty() => const _Stats(
    exposure: {},
    clicks: {},
    fastClicks: {},
    lastInteraction: {},
  );

  _Stats copyWith({
    Map<String, int>? exposure,
    Map<String, int>? clicks,
    Map<String, int>? fastClicks,
    Map<String, int>? lastInteraction,
  }) =>
      _Stats(
        exposure: exposure ?? this.exposure,
        clicks: clicks ?? this.clicks,
        fastClicks: fastClicks ?? this.fastClicks,
        lastInteraction: lastInteraction ?? this.lastInteraction,
      );
}

class _Scored {
  final YoutubeVideo video;
  final double score;
  _Scored({required this.video, required this.score});
}