import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نظام تتبع اهتمامات المستخدم الذكي
/// يتعلم من سلوك المستخدم ويتكيف مع تغير اهتماماته
class UserInterestService {
  static const String _interestsKey = 'user_interests_v2';
  static const String _topicScoresKey = 'user_topic_scores_v2';
  static const String _channelAffinityKey = 'user_channel_affinity_v2';
  static const String _watchPatternsKey = 'user_watch_patterns_v1';
  static const String _lastDecayKey = 'user_interest_last_decay';

  static final Map<String, ChannelAffinity> _channelAffinity = {};
  static final Map<String, double> _topicScores = {};
  static final Map<String, WatchPattern> _watchPatterns = {};
  static bool _initialized = false;

  // ═══════════════════════════════════════════════
  //  الكلمات المفتاحية للمواضيع
  // ═══════════════════════════════════════════════
  static const Map<String, List<String>> _topicKeywords = {
    'quran': ['قرآن', 'تلاوة', 'تجويد', 'حفظ', 'ترتيل', 'سورة', 'آية'],
    'tafsir': ['تفسير', 'معاني', 'إعراب', 'بلاغة'],
    'hadith': ['حديث', 'سنة', 'نبوي', 'صحيح', 'رواية', 'إسناد'],
    'fiqh': ['فقه', 'حكم', 'فتوى', 'حلال', 'حرام', 'مسألة', 'أحكام'],
    'aqeedah': ['عقيدة', 'توحيد', 'إيمان', 'أسماء الله', 'صفات'],
    'seerah': ['سيرة', 'نبوية', 'غزوة', 'صحابة', 'تابعين'],
    'lecture': ['محاضرة', 'درس', 'دورة', 'شرح', 'كتاب'],
    'khutbah': ['خطبة', 'جمعة', 'منبر', 'وعظ'],
    'dua': ['دعاء', 'أذكار', 'ذكر', 'تسبيح', 'استغفار', 'ورد'],
    'mawaeez': ['موعظة', 'رقائق', 'مؤثر', 'قلوب', 'توبة', 'زهد'],
    'family': ['أسرة', 'تربية', 'أطفال', 'زوجة', 'زوج', 'بيت'],
    'contemporary': ['معاصر', 'واقع', 'شبهات', 'رد', 'نقاش'],
  };

  // ═══════════════════════════════════════════════
  //  التهيئة
  // ═══════════════════════════════════════════════
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // تحميل Channel Affinity
      final affinityRaw = prefs.getString(_channelAffinityKey);
      _channelAffinity.clear();
      if (affinityRaw != null && affinityRaw.isNotEmpty) {
        final decoded = json.decode(affinityRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          try {
            _channelAffinity[entry.key] = ChannelAffinity.fromJson(
              Map<String, dynamic>.from(entry.value),
            );
          } catch (_) {}
        }
      }

      // تحميل Topic Scores
      final topicRaw = prefs.getString(_topicScoresKey);
      _topicScores.clear();
      if (topicRaw != null && topicRaw.isNotEmpty) {
        final decoded = json.decode(topicRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _topicScores[entry.key] = (entry.value as num).toDouble();
        }
      }

      // تحميل Watch Patterns
      final patternsRaw = prefs.getString(_watchPatternsKey);
      _watchPatterns.clear();
      if (patternsRaw != null && patternsRaw.isNotEmpty) {
        final decoded = json.decode(patternsRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          try {
            _watchPatterns[entry.key] = WatchPattern.fromJson(
              Map<String, dynamic>.from(entry.value),
            );
          } catch (_) {}
        }
      }

      // Decay يومي
      await _applyDailyDecay(prefs);

      _initialized = true;
      debugPrint('🧠 UserInterestService loaded: '
          '${_channelAffinity.length} channels, '
          '${_topicScores.length} topics');
    } catch (e) {
      debugPrint('❌ UserInterestService init error: $e');
      _initialized = true;
    }
  }

  // ═══════════════════════════════════════════════
  //  تسجيل الأحداث
  // ═══════════════════════════════════════════════

  /// عند الضغط على فيديو
  static Future<void> trackVideoClick({
    required String videoId,
    required String channelId,
    required String channelTitle,
    required String videoTitle,
    required String description,
  }) async {
    if (!_initialized) await init();

    final ch = channelId.isNotEmpty ? channelId : channelTitle;
    if (ch.isEmpty) return;

    // تحديث Channel Affinity
    final current = _channelAffinity[ch] ?? ChannelAffinity.empty();
    _channelAffinity[ch] = current.copyWith(
      clicks: current.clicks + 1,
      lastClickAt: DateTime.now(),
    );

    // تحديث Topic Scores
    final topics = _extractTopics(videoTitle, description);
    for (final topic in topics) {
      _topicScores[topic] = (_topicScores[topic] ?? 0) + 2.0;
    }

    await _save();
  }

  /// عند مشاهدة فيديو (مع الوقت)
  static Future<void> trackVideoWatch({
    required String videoId,
    required String channelId,
    required String channelTitle,
    required String videoTitle,
    required String description,
    required int watchedSeconds,
    required int totalSeconds,
    required bool completed,
  }) async {
    if (!_initialized) await init();

    final ch = channelId.isNotEmpty ? channelId : channelTitle;
    if (ch.isEmpty) return;

    final watchRatio = totalSeconds > 0
        ? (watchedSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    // تحديث Channel Affinity
    final current = _channelAffinity[ch] ?? ChannelAffinity.empty();
    _channelAffinity[ch] = current.copyWith(
      totalWatchSeconds: current.totalWatchSeconds + watchedSeconds,
      completedVideos: current.completedVideos + (completed ? 1 : 0),
      avgWatchRatio: _runningAvg(
        current.avgWatchRatio,
        watchRatio,
        current.clicks,
      ),
      lastWatchAt: DateTime.now(),
    );

    // تحديث Topics بناءً على نسبة المشاهدة
    final topics = _extractTopics(videoTitle, description);
    final topicBoost = completed ? 5.0 : watchRatio * 3.0;
    for (final topic in topics) {
      _topicScores[topic] = (_topicScores[topic] ?? 0) + topicBoost;
    }

    // تسجيل نمط المشاهدة
    final hour = DateTime.now().hour;
    final dayPeriod = _getDayPeriod(hour);
    final pattern = _watchPatterns[dayPeriod] ?? WatchPattern.empty();
    _watchPatterns[dayPeriod] = pattern.copyWith(
      watchCount: pattern.watchCount + 1,
      totalSeconds: pattern.totalSeconds + watchedSeconds,
      topTopics: _mergeTopTopics(pattern.topTopics, topics),
    );

    await _save();
  }

  /// عند تخطي فيديو (سحب سريع)
  static Future<void> trackVideoSkip({
    required String channelId,
    required String channelTitle,
    required String videoTitle,
    required String description,
  }) async {
    if (!_initialized) await init();

    final ch = channelId.isNotEmpty ? channelId : channelTitle;
    if (ch.isEmpty) return;

    final current = _channelAffinity[ch] ?? ChannelAffinity.empty();
    _channelAffinity[ch] = current.copyWith(
      skips: current.skips + 1,
    );

    // تقليل اهتمام المواضيع المتخطاة
    final topics = _extractTopics(videoTitle, description);
    for (final topic in topics) {
      _topicScores[topic] = max(0, (_topicScores[topic] ?? 0) - 0.5);
    }

    await _save();
  }

  /// عند ظهور فيديو في الفيد (exposure)
  static Future<void> trackExposure({
    required String channelId,
    required String channelTitle,
  }) async {
    if (!_initialized) await init();

    final ch = channelId.isNotEmpty ? channelId : channelTitle;
    if (ch.isEmpty) return;

    final current = _channelAffinity[ch] ?? ChannelAffinity.empty();
    _channelAffinity[ch] = current.copyWith(
      exposures: current.exposures + 1,
    );
    // لا نحفظ فوراً هنا لتقليل الكتابة
  }

  static Future<void> saveExposures() async {
    await _save();
  }

  // ═══════════════════════════════════════════════
  //  حساب النقاط
  // ═══════════════════════════════════════════════

  /// نقاط اهتمام المستخدم بقناة معينة (0-100)
  static double getChannelInterestScore(String channelKey) {
    final affinity = _channelAffinity[channelKey];
    if (affinity == null) return 0;

    final recency = _recencyFactor(affinity.lastClickAt ?? affinity.lastWatchAt);

    // CTR (Click-Through Rate)
    final ctr = affinity.exposures > 0
        ? affinity.clicks / affinity.exposures
        : 0.0;

    // Engagement
    final avgWatch = affinity.avgWatchRatio;
    final completionRate = affinity.clicks > 0
        ? affinity.completedVideos / affinity.clicks
        : 0.0;

    // Skip Rate (سلبي)
    final skipRate = affinity.exposures > 0
        ? affinity.skips / affinity.exposures
        : 0.0;

    double score = 0;

    // CTR عالي = اهتمام عالي
    score += min(ctr * 30, 25.0);

    // مشاهدة طويلة = اهتمام عالي
    score += min(avgWatch * 25, 20.0);

    // إكمال الفيديوهات
    score += min(completionRate * 20, 15.0);

    // وقت المشاهدة الإجمالي
    score += min(affinity.totalWatchSeconds / 300.0, 15.0);

    // عدد النقرات
    score += min(affinity.clicks * 1.5, 15.0);

    // عقوبة التخطي
    score -= min(skipRate * 20, 15.0);

    // تأثير الحداثة
    score *= recency;

    return score.clamp(0, 100);
  }

  /// نقاط اهتمام المستخدم بموضوع معين
  static double getTopicScore(String topic) {
    return _topicScores[topic] ?? 0;
  }

  /// أعلى المواضيع اهتماماً
  static List<String> getTopTopics({int limit = 5}) {
    final sorted = _topicScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// نقاط فيديو بناءً على اهتمامات المستخدم
  static double getVideoInterestScore({
    required String channelId,
    required String channelTitle,
    required String videoTitle,
    required String description,
  }) {
    final ch = channelId.isNotEmpty ? channelId : channelTitle;

    double score = 0;

    // 1. اهتمام بالقناة (40%)
    score += getChannelInterestScore(ch) * 0.4;

    // 2. اهتمام بالموضوع (35%)
    final topics = _extractTopics(videoTitle, description);
    if (topics.isNotEmpty) {
      double topicScore = 0;
      for (final topic in topics) {
        topicScore += getTopicScore(topic);
      }
      score += min(topicScore / topics.length, 30.0) * 0.35;
    }

    // 3. وقت اليوم المناسب (15%)
    score += _timeRelevanceScore(videoTitle, description) * 0.15;

    // 4. تنوع (10%) - مكافأة للمحتوى الجديد
    final affinity = _channelAffinity[ch];
    if (affinity == null || affinity.clicks == 0) {
      score += 8; // مكافأة الاكتشاف
    }

    return score;
  }

  // ═══════════════════════════════════════════════
  //  مساعدات داخلية
  // ═══════════════════════════════════════════════

  static List<String> _extractTopics(String title, String description) {
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';
    final found = <String>{};

    for (final entry in _topicKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          found.add(entry.key);
          break;
        }
      }
    }

    return found.toList();
  }

  static double _recencyFactor(DateTime? lastInteraction) {
    if (lastInteraction == null) return 0.3;

    final days = DateTime.now().difference(lastInteraction).inDays;
    if (days <= 1) return 1.0;
    if (days <= 3) return 0.9;
    if (days <= 7) return 0.8;
    if (days <= 14) return 0.65;
    if (days <= 30) return 0.5;
    if (days <= 60) return 0.35;
    return 0.2;
  }

  static double _runningAvg(double oldAvg, double newValue, int count) {
    if (count <= 0) return newValue;
    final weight = min(count, 20);
    return (oldAvg * weight + newValue) / (weight + 1);
  }

  static String _getDayPeriod(int hour) {
    if (hour >= 4 && hour < 10) return 'morning';
    if (hour >= 10 && hour < 16) return 'afternoon';
    if (hour >= 16 && hour < 21) return 'evening';
    return 'night';
  }

  static double _timeRelevanceScore(String title, String desc) {
    final hour = DateTime.now().hour;
    final period = _getDayPeriod(hour);

    final pattern = _watchPatterns[period];
    if (pattern == null || pattern.topTopics.isEmpty) return 5.0;

    final videoTopics = _extractTopics(title, desc);
    double match = 0;

    for (final topic in videoTopics) {
      if (pattern.topTopics.contains(topic)) {
        match += 3.0;
      }
    }

    return min(match, 10.0);
  }

  static List<String> _mergeTopTopics(
      List<String> existing,
      List<String> newTopics,
      ) {
    final merged = <String, int>{};
    for (final t in existing) {
      merged[t] = (merged[t] ?? 0) + 1;
    }
    for (final t in newTopics) {
      merged[t] = (merged[t] ?? 0) + 2;
    }

    final sorted = merged.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toList();
  }

  // ═══════════════════════════════════════════════
  //  Decay يومي - لتتبع تغير الاهتمامات
  // ═══════════════════════════════════════════════
  static Future<void> _applyDailyDecay(SharedPreferences prefs) async {
    final lastDecay = prefs.getInt(_lastDecayKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // مرة كل 24 ساعة
    if (now - lastDecay < 86400000) return;

    const decayFactor = 0.92; // 8% تراجع يومي

    // Decay للمواضيع
    for (final key in _topicScores.keys.toList()) {
      _topicScores[key] = (_topicScores[key]! * decayFactor);
      if (_topicScores[key]! < 0.1) _topicScores.remove(key);
    }

    // Decay للقنوات (الغير نشطة فقط)
    for (final key in _channelAffinity.keys.toList()) {
      final affinity = _channelAffinity[key]!;
      final daysSinceActivity = affinity.lastClickAt != null
          ? DateTime.now().difference(affinity.lastClickAt!).inDays
          : 999;

      if (daysSinceActivity > 7) {
        _channelAffinity[key] = affinity.copyWith(
          avgWatchRatio: affinity.avgWatchRatio * decayFactor,
        );
      }

      // حذف القنوات القديمة جداً
      if (daysSinceActivity > 90 && affinity.clicks < 3) {
        _channelAffinity.remove(key);
      }
    }

    await prefs.setInt(_lastDecayKey, now);
    await _save();

    debugPrint('🔄 Interest decay applied');
  }

  // ═══════════════════════════════════════════════
  //  حفظ
  // ═══════════════════════════════════════════════
  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // حفظ Channel Affinity
      final affinityData = <String, dynamic>{};
      for (final entry in _channelAffinity.entries) {
        affinityData[entry.key] = entry.value.toJson();
      }
      await prefs.setString(_channelAffinityKey, json.encode(affinityData));

      // حفظ Topics
      await prefs.setString(_topicScoresKey, json.encode(_topicScores));

      // حفظ Patterns
      final patternsData = <String, dynamic>{};
      for (final entry in _watchPatterns.entries) {
        patternsData[entry.key] = entry.value.toJson();
      }
      await prefs.setString(_watchPatternsKey, json.encode(patternsData));
    } catch (e) {
      debugPrint('❌ UserInterestService save error: $e');
    }
  }

  static Future<void> clearAll() async {
    _channelAffinity.clear();
    _topicScores.clear();
    _watchPatterns.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_channelAffinityKey);
    await prefs.remove(_topicScoresKey);
    await prefs.remove(_watchPatternsKey);
  }
}

// ═══════════════════════════════════════════════
//  Data Models
// ═══════════════════════════════════════════════

class ChannelAffinity {
  final int clicks;
  final int exposures;
  final int skips;
  final int totalWatchSeconds;
  final int completedVideos;
  final double avgWatchRatio;
  final DateTime? lastClickAt;
  final DateTime? lastWatchAt;

  const ChannelAffinity({
    required this.clicks,
    required this.exposures,
    required this.skips,
    required this.totalWatchSeconds,
    required this.completedVideos,
    required this.avgWatchRatio,
    this.lastClickAt,
    this.lastWatchAt,
  });

  factory ChannelAffinity.empty() => const ChannelAffinity(
    clicks: 0,
    exposures: 0,
    skips: 0,
    totalWatchSeconds: 0,
    completedVideos: 0,
    avgWatchRatio: 0,
  );

  ChannelAffinity copyWith({
    int? clicks,
    int? exposures,
    int? skips,
    int? totalWatchSeconds,
    int? completedVideos,
    double? avgWatchRatio,
    DateTime? lastClickAt,
    DateTime? lastWatchAt,
  }) =>
      ChannelAffinity(
        clicks: clicks ?? this.clicks,
        exposures: exposures ?? this.exposures,
        skips: skips ?? this.skips,
        totalWatchSeconds: totalWatchSeconds ?? this.totalWatchSeconds,
        completedVideos: completedVideos ?? this.completedVideos,
        avgWatchRatio: avgWatchRatio ?? this.avgWatchRatio,
        lastClickAt: lastClickAt ?? this.lastClickAt,
        lastWatchAt: lastWatchAt ?? this.lastWatchAt,
      );

  Map<String, dynamic> toJson() => {
    'c': clicks,
    'e': exposures,
    's': skips,
    'tw': totalWatchSeconds,
    'cv': completedVideos,
    'aw': avgWatchRatio,
    'lc': lastClickAt?.millisecondsSinceEpoch,
    'lw': lastWatchAt?.millisecondsSinceEpoch,
  };

  factory ChannelAffinity.fromJson(Map<String, dynamic> j) => ChannelAffinity(
    clicks: j['c'] ?? 0,
    exposures: j['e'] ?? 0,
    skips: j['s'] ?? 0,
    totalWatchSeconds: j['tw'] ?? 0,
    completedVideos: j['cv'] ?? 0,
    avgWatchRatio: (j['aw'] ?? 0).toDouble(),
    lastClickAt: j['lc'] != null
        ? DateTime.fromMillisecondsSinceEpoch(j['lc'])
        : null,
    lastWatchAt: j['lw'] != null
        ? DateTime.fromMillisecondsSinceEpoch(j['lw'])
        : null,
  );
}

class WatchPattern {
  final int watchCount;
  final int totalSeconds;
  final List<String> topTopics;

  const WatchPattern({
    required this.watchCount,
    required this.totalSeconds,
    required this.topTopics,
  });

  factory WatchPattern.empty() => const WatchPattern(
    watchCount: 0,
    totalSeconds: 0,
    topTopics: [],
  );

  WatchPattern copyWith({
    int? watchCount,
    int? totalSeconds,
    List<String>? topTopics,
  }) =>
      WatchPattern(
        watchCount: watchCount ?? this.watchCount,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        topTopics: topTopics ?? this.topTopics,
      );

  Map<String, dynamic> toJson() => {
    'wc': watchCount,
    'ts': totalSeconds,
    'tt': topTopics,
  };

  factory WatchPattern.fromJson(Map<String, dynamic> j) => WatchPattern(
    watchCount: j['wc'] ?? 0,
    totalSeconds: j['ts'] ?? 0,
    topTopics: List<String>.from(j['tt'] ?? []),
  );
}