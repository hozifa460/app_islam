// lib/screens/radio/video/video_watch_history_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoWatchEntry {
  final String videoUrl;
  final String title;
  final String category;
  final DateTime watchedAt;
  int watchCount;

  VideoWatchEntry({
    required this.videoUrl,
    required this.title,
    required this.category,
    required this.watchedAt,
    this.watchCount = 1,
  });

  Map<String, dynamic> toJson() => {
    'videoUrl': videoUrl,
    'title': title,
    'category': category,
    'watchedAt': watchedAt.toIso8601String(),
    'watchCount': watchCount,
  };

  factory VideoWatchEntry.fromJson(Map<String, dynamic> json) {
    return VideoWatchEntry(
      videoUrl: json['videoUrl'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      watchedAt: DateTime.tryParse(json['watchedAt'] ?? '') ?? DateTime.now(),
      watchCount: json['watchCount'] ?? 1,
    );
  }
}

class VideoWatchHistoryService {
  static final VideoWatchHistoryService _instance =
  VideoWatchHistoryService._internal();
  factory VideoWatchHistoryService() => _instance;
  VideoWatchHistoryService._internal();

  static const String _key = 'video_watch_history';
  static const int _maxEntries = 100;

  List<VideoWatchEntry> _history = [];
  bool _loaded = false;

  List<VideoWatchEntry> get history => _history;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr != null) {
        final list = json.decode(jsonStr) as List;
        _history = list
            .map((e) => VideoWatchEntry.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ VideoWatchHistory init: $e');
    }
    _loaded = true;
  }

  Future<void> addWatch({
    required String videoUrl,
    required String title,
    required String category,
  }) async {
    await init();

    final existing = _history.indexWhere((e) => e.videoUrl == videoUrl);
    if (existing >= 0) {
      _history[existing].watchCount++;
      final entry = _history.removeAt(existing);
      _history.insert(0, entry);
    } else {
      _history.insert(
        0,
        VideoWatchEntry(
          videoUrl: videoUrl,
          title: title,
          category: category,
          watchedAt: DateTime.now(),
        ),
      );
    }

    if (_history.length > _maxEntries) {
      _history = _history.sublist(0, _maxEntries);
    }

    await _save();
  }

  /// الأقسام الأكثر مشاهدة
  Map<String, int> get categoryScores {
    final scores = <String, int>{};
    for (final entry in _history) {
      scores[entry.category] =
          (scores[entry.category] ?? 0) + entry.watchCount;
    }
    return scores;
  }

  /// هل شاهد هذا الفيديو من قبل
  bool hasWatched(String videoUrl) =>
      _history.any((e) => e.videoUrl == videoUrl);

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(_history.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonStr);
    } catch (_) {}
  }
}