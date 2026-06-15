import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelUsageService {
  static const String _usageKey = 'channel_usage_stats_v1';
  static const int _maxChannels = 300;

  static final Map<String, ChannelUsageStats> _usage = {};
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_usageKey);

      _usage.clear();

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          try {
            _usage[entry.key] = ChannelUsageStats.fromJson(
              Map<String, dynamic>.from(entry.value),
            );
          } catch (_) {}
        }
      }

      _initialized = true;
      debugPrint('📊 Channel usage loaded: ${_usage.length}');
    } catch (e) {
      debugPrint('❌ ChannelUsageService init error: $e');
    }
  }

  static Future<void> markChannelOpened(String channelId) async {
    if (channelId.isEmpty) return;
    if (!_initialized) await init();

    final current = _usage[channelId] ?? ChannelUsageStats.empty();
    _usage[channelId] = current.copyWith(
      openCount: current.openCount + 1,
      lastOpenedAt: DateTime.now(),
      lastInteractedAt: DateTime.now(),
    );

    await _save();
  }

  static Future<void> markVideoStarted({
    required String channelId,
    required String videoId,
  }) async {
    if (channelId.isEmpty || videoId.isEmpty) return;
    if (!_initialized) await init();

    final current = _usage[channelId] ?? ChannelUsageStats.empty();
    _usage[channelId] = current.copyWith(
      watchStarts: current.watchStarts + 1,
      lastWatchedAt: DateTime.now(),
      lastInteractedAt: DateTime.now(),
    );

    await _save();
  }

  static Future<void> markVideoCompleted({
    required String channelId,
    required String videoId,
  }) async {
    if (channelId.isEmpty || videoId.isEmpty) return;
    if (!_initialized) await init();

    final current = _usage[channelId] ?? ChannelUsageStats.empty();
    _usage[channelId] = current.copyWith(
      completedVideos: current.completedVideos + 1,
      lastWatchedAt: DateTime.now(),
      lastInteractedAt: DateTime.now(),
    );

    await _save();
  }

  static Future<void> addWatchTime({
    required String channelId,
    required int watchedSeconds,
  }) async {
    if (channelId.isEmpty || watchedSeconds <= 0) return;
    if (!_initialized) await init();

    final current = _usage[channelId] ?? ChannelUsageStats.empty();
    _usage[channelId] = current.copyWith(
      totalWatchSeconds: current.totalWatchSeconds + watchedSeconds,
      lastWatchedAt: DateTime.now(),
      lastInteractedAt: DateTime.now(),
    );

    await _save();
  }

  static Future<void> markSearchHit(String channelId) async {
    if (channelId.isEmpty) return;
    if (!_initialized) await init();

    final current = _usage[channelId] ?? ChannelUsageStats.empty();
    _usage[channelId] = current.copyWith(
      searchHits: current.searchHits + 1,
      lastInteractedAt: DateTime.now(),
    );

    await _save();
  }

  static ChannelUsageStats? getStats(String channelId) {
    return _usage[channelId];
  }

  static double getPriorityScore(String channelId) {
    final stats = _usage[channelId];
    if (stats == null) return 0;

    final now = DateTime.now();
    final daysSinceInteraction = stats.lastInteractedAt == null
        ? 999
        : now.difference(stats.lastInteractedAt!).inDays;

    final recencyBoost = daysSinceInteraction <= 1
        ? 12.0
        : daysSinceInteraction <= 3
        ? 8.0
        : daysSinceInteraction <= 7
        ? 4.0
        : daysSinceInteraction <= 30
        ? 1.5
        : 0.0;

    final watchTimeFactor = stats.totalWatchSeconds / 600.0;

    return (stats.openCount * 1.5) +
        (stats.watchStarts * 2.0) +
        (stats.completedVideos * 3.0) +
        (stats.searchHits * 1.0) +
        watchTimeFactor +
        recencyBoost;
  }

  static List<String> sortChannelIdsByPriority(Iterable<String> channelIds) {
    final list = channelIds.toList();
    list.sort((a, b) => getPriorityScore(b).compareTo(getPriorityScore(a)));
    return list;
  }

  static Future<void> _save() async {
    try {
      await _trimIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      final encoded = <String, dynamic>{};

      for (final entry in _usage.entries) {
        encoded[entry.key] = entry.value.toJson();
      }

      await prefs.setString(_usageKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('❌ ChannelUsageService save error: $e');
    }
  }

  static Future<void> _trimIfNeeded() async {
    if (_usage.length <= _maxChannels) return;

    final entries = _usage.entries.toList()
      ..sort((a, b) {
        final aDate = a.value.lastInteractedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.value.lastInteractedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

    final removeCount = _usage.length - _maxChannels;
    for (int i = 0; i < removeCount; i++) {
      _usage.remove(entries[i].key);
    }
  }

  static Future<void> clearAll() async {
    _usage.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usageKey);
  }
}

class ChannelUsageStats {
  final int openCount;
  final int watchStarts;
  final int completedVideos;
  final int totalWatchSeconds;
  final int searchHits;
  final DateTime? lastOpenedAt;
  final DateTime? lastWatchedAt;
  final DateTime? lastInteractedAt;

  const ChannelUsageStats({
    required this.openCount,
    required this.watchStarts,
    required this.completedVideos,
    required this.totalWatchSeconds,
    required this.searchHits,
    required this.lastOpenedAt,
    required this.lastWatchedAt,
    required this.lastInteractedAt,
  });

  factory ChannelUsageStats.empty() {
    return const ChannelUsageStats(
      openCount: 0,
      watchStarts: 0,
      completedVideos: 0,
      totalWatchSeconds: 0,
      searchHits: 0,
      lastOpenedAt: null,
      lastWatchedAt: null,
      lastInteractedAt: null,
    );
  }

  ChannelUsageStats copyWith({
    int? openCount,
    int? watchStarts,
    int? completedVideos,
    int? totalWatchSeconds,
    int? searchHits,
    DateTime? lastOpenedAt,
    DateTime? lastWatchedAt,
    DateTime? lastInteractedAt,
  }) {
    return ChannelUsageStats(
      openCount: openCount ?? this.openCount,
      watchStarts: watchStarts ?? this.watchStarts,
      completedVideos: completedVideos ?? this.completedVideos,
      totalWatchSeconds: totalWatchSeconds ?? this.totalWatchSeconds,
      searchHits: searchHits ?? this.searchHits,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      lastInteractedAt: lastInteractedAt ?? this.lastInteractedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'openCount': openCount,
    'watchStarts': watchStarts,
    'completedVideos': completedVideos,
    'totalWatchSeconds': totalWatchSeconds,
    'searchHits': searchHits,
    'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    'lastWatchedAt': lastWatchedAt?.toIso8601String(),
    'lastInteractedAt': lastInteractedAt?.toIso8601String(),
  };

  factory ChannelUsageStats.fromJson(Map<String, dynamic> json) {
    return ChannelUsageStats(
      openCount: int.tryParse('${json['openCount'] ?? 0}') ?? 0,
      watchStarts: int.tryParse('${json['watchStarts'] ?? 0}') ?? 0,
      completedVideos: int.tryParse('${json['completedVideos'] ?? 0}') ?? 0,
      totalWatchSeconds: int.tryParse('${json['totalWatchSeconds'] ?? 0}') ?? 0,
      searchHits: int.tryParse('${json['searchHits'] ?? 0}') ?? 0,
      lastOpenedAt: DateTime.tryParse('${json['lastOpenedAt'] ?? ''}'),
      lastWatchedAt: DateTime.tryParse('${json['lastWatchedAt'] ?? ''}'),
      lastInteractedAt: DateTime.tryParse('${json['lastInteractedAt'] ?? ''}'),
    );
  }
}