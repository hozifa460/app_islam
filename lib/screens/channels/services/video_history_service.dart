import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoHistoryService {
  static const String _watchedKey = 'watched_video_ids_v2';
  static const String _shownKey = 'shown_video_ids_v2';
  static const String _progressKey = 'video_progress_map_v1';

  static const int _maxHistory = 1000;
  static const int _maxProgressEntries = 1500;

  static final Set<String> _watchedIds = {};
  static final Set<String> _shownIds = {};
  static final Map<String, VideoProgressData> _progressMap = {};

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final watched = prefs.getStringList(_watchedKey) ?? [];
      final shown = prefs.getStringList(_shownKey) ?? [];
      final progressRaw = prefs.getString(_progressKey);

      _watchedIds
        ..clear()
        ..addAll(watched);

      _shownIds
        ..clear()
        ..addAll(shown);

      _progressMap.clear();
      if (progressRaw != null && progressRaw.isNotEmpty) {
        final decoded = jsonDecode(progressRaw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          try {
            _progressMap[entry.key] = VideoProgressData.fromJson(
              Map<String, dynamic>.from(entry.value),
            );
          } catch (_) {}
        }
      }

      _initialized = true;

      debugPrint(
        '📚 Video history loaded: ${_watchedIds.length} watched, ${_shownIds.length} shown, ${_progressMap.length} progress',
      );
    } catch (e) {
      debugPrint('❌ Video history init error: $e');
    }
  }

  static Future<void> markAsWatched(String videoId) async {
    if (!_initialized) await init();
    if (videoId.isEmpty) return;

    _watchedIds.add(videoId);
    _shownIds.add(videoId);

    final current = _progressMap[videoId];
    if (current != null && !current.completed) {
      _progressMap[videoId] = current.copyWith(
        completed: true,
        progress: current.progress < 1.0 ? 1.0 : current.progress,
        updatedAt: DateTime.now(),
      );
    }

    await _saveWatched();
    await _saveShown();
    await _saveProgress();
  }

  static Future<void> markAsShown(String videoId) async {
    if (!_initialized) await init();
    if (videoId.isEmpty) return;

    if (_shownIds.contains(videoId)) return;
    _shownIds.add(videoId);
    await _saveShown();
  }

  static Future<void> markManyAsShown(List<String> videoIds) async {
    if (!_initialized) await init();

    bool changed = false;
    for (final id in videoIds) {
      if (id.isEmpty) continue;
      if (_shownIds.add(id)) {
        changed = true;
      }
    }

    if (changed) {
      await _saveShown();
    }
  }

  static Future<void> saveProgress({
    required String videoId,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    if (!_initialized) await init();
    if (videoId.isEmpty || durationSeconds <= 0) return;

    final safePosition = positionSeconds.clamp(0, durationSeconds);
    final progress = (safePosition / durationSeconds).clamp(0.0, 1.0);
    final completed = progress >= 0.90;

    final old = _progressMap[videoId];
    _progressMap[videoId] = VideoProgressData(
      positionSeconds: safePosition,
      durationSeconds: durationSeconds,
      progress: progress,
      completed: completed,
      updatedAt: DateTime.now(),
      openCount: (old?.openCount ?? 0) + 1,
    );

    _shownIds.add(videoId);

    if (completed) {
      _watchedIds.add(videoId);
    }

    await _trimProgressIfNeeded();
    await _saveShown();
    await _saveWatched();
    await _saveProgress();
  }

  static Future<void> saveProgressSnapshot({
    required String videoId,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    if (!_initialized) await init();
    if (videoId.isEmpty || durationSeconds <= 0) return;

    final safePosition = positionSeconds.clamp(0, durationSeconds);
    final progress = (safePosition / durationSeconds).clamp(0.0, 1.0);
    final completed = progress >= 0.90;

    final old = _progressMap[videoId];
    final oldPosition = old?.positionSeconds ?? 0;

    if (safePosition < oldPosition && !completed) {
      return;
    }

    _progressMap[videoId] = VideoProgressData(
      positionSeconds: safePosition,
      durationSeconds: durationSeconds,
      progress: progress,
      completed: completed,
      updatedAt: DateTime.now(),
      openCount: old?.openCount ?? 1,
    );

    _shownIds.add(videoId);
    if (completed) {
      _watchedIds.add(videoId);
    }

    await _trimProgressIfNeeded();
    await _saveShown();
    await _saveWatched();
    await _saveProgress();
  }

  static double getProgress(String videoId) {
    return _progressMap[videoId]?.progress ?? 0.0;
  }

  static int getPositionSeconds(String videoId) {
    return _progressMap[videoId]?.positionSeconds ?? 0;
  }

  static bool isCompleted(String videoId) {
    final p = _progressMap[videoId];
    if (p == null) return _watchedIds.contains(videoId);
    return p.completed;
  }

  static bool isPartiallyWatched(String videoId) {
    final p = _progressMap[videoId];
    if (p == null) return false;
    return !p.completed && p.progress >= 0.15;
  }

  static List<String> getResumeVideoIds({int limit = 20}) {
    final entries = _progressMap.entries
        .where((e) => !e.value.completed)
        .where((e) => e.value.progress > 0.0)
        .toList()
      ..sort((a, b) => b.value.updatedAt.compareTo(a.value.updatedAt));

    return entries.take(limit).map((e) => e.key).toList();
  }

  static List<VideoProgressEntry> getResumeEntries({int limit = 20}) {
    final entries = _progressMap.entries
        .where((e) => !e.value.completed)
        .where((e) => e.value.progress > 0.0)
        .toList()
      ..sort((a, b) => b.value.updatedAt.compareTo(a.value.updatedAt));

    return entries
        .take(limit)
        .map((e) => VideoProgressEntry(videoId: e.key, data: e.value))
        .toList();
  }

  static bool isWatched(String videoId) => _watchedIds.contains(videoId);

  static bool isShown(String videoId) => _shownIds.contains(videoId);

  static List<T> filterUnwatched<T>(
      List<T> videos,
      String Function(T) getId,
      ) {
    return videos.where((v) => !isCompleted(getId(v))).toList();
  }

  static List<T> filterUnshown<T>(
      List<T> videos,
      String Function(T) getId,
      ) {
    return videos.where((v) => !_shownIds.contains(getId(v))).toList();
  }

  static int get watchedCount => _watchedIds.length;
  static int get shownCount => _shownIds.length;
  static int get progressCount => _progressMap.length;

  static Future<void> clearShownHistory() async {
    if (!_initialized) await init();

    _shownIds
      ..clear()
      ..addAll(_watchedIds);

    await _saveShown();
    debugPrint('🔄 Shown history cleared');
  }

  static Future<void> clearAll() async {
    _watchedIds.clear();
    _shownIds.clear();
    _progressMap.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_watchedKey);
    await prefs.remove(_shownKey);
    await prefs.remove(_progressKey);

    debugPrint('🗑️ Video history cleared');
  }

  static Future<void> _saveWatched() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _watchedIds.toList();

      if (list.length > _maxHistory) {
        list.removeRange(0, list.length - _maxHistory);
      }

      await prefs.setStringList(_watchedKey, list);
    } catch (e) {
      debugPrint('❌ Save watched error: $e');
    }
  }

  static Future<void> _saveShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _shownIds.toList();

      if (list.length > _maxHistory) {
        list.removeRange(0, list.length - _maxHistory);
      }

      await prefs.setStringList(_shownKey, list);
    } catch (e) {
      debugPrint('❌ Save shown error: $e');
    }
  }

  static Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = <String, dynamic>{};

      for (final entry in _progressMap.entries) {
        data[entry.key] = entry.value.toJson();
      }

      await prefs.setString(_progressKey, jsonEncode(data));
    } catch (e) {
      debugPrint('❌ Save progress error: $e');
    }
  }

  static Future<void> _trimProgressIfNeeded() async {
    if (_progressMap.length <= _maxProgressEntries) return;

    final entries = _progressMap.entries.toList()
      ..sort((a, b) => a.value.updatedAt.compareTo(b.value.updatedAt));

    final removeCount = _progressMap.length - _maxProgressEntries;
    for (int i = 0; i < removeCount; i++) {
      _progressMap.remove(entries[i].key);
    }
  }
}

class VideoProgressData {
  final int positionSeconds;
  final int durationSeconds;
  final double progress;
  final bool completed;
  final DateTime updatedAt;
  final int openCount;

  const VideoProgressData({
    required this.positionSeconds,
    required this.durationSeconds,
    required this.progress,
    required this.completed,
    required this.updatedAt,
    required this.openCount,
  });

  VideoProgressData copyWith({
    int? positionSeconds,
    int? durationSeconds,
    double? progress,
    bool? completed,
    DateTime? updatedAt,
    int? openCount,
  }) {
    return VideoProgressData(
      positionSeconds: positionSeconds ?? this.positionSeconds,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      openCount: openCount ?? this.openCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'positionSeconds': positionSeconds,
    'durationSeconds': durationSeconds,
    'progress': progress,
    'completed': completed,
    'updatedAt': updatedAt.toIso8601String(),
    'openCount': openCount,
  };

  factory VideoProgressData.fromJson(Map<String, dynamic> json) {
    return VideoProgressData(
      positionSeconds: int.tryParse('${json['positionSeconds'] ?? 0}') ?? 0,
      durationSeconds: int.tryParse('${json['durationSeconds'] ?? 0}') ?? 0,
      progress: double.tryParse('${json['progress'] ?? 0}') ?? 0.0,
      completed: json['completed'] == true,
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}') ?? DateTime.now(),
      openCount: int.tryParse('${json['openCount'] ?? 1}') ?? 1,
    );
  }
}

class VideoProgressEntry {
  final String videoId;
  final VideoProgressData data;

  const VideoProgressEntry({
    required this.videoId,
    required this.data,
  });
}