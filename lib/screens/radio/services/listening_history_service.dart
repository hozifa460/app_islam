// lib/screens/radio/services/listening_history_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListeningHistoryItem {
  final String title;
  final String subtitle;
  final String emoji;
  final String? imageUrl;
  final String? imageAsset;
  final String audioUrl;
  final String type; // 'radio', 'surah', 'recitation', 'local'
  final String? stationName;
  final int? stationId;
  final int? surahNumber;
  final DateTime listenedAt;

  ListeningHistoryItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.imageUrl,
    this.imageAsset,
    required this.audioUrl,
    required this.type,
    this.stationName,
    this.stationId,
    this.surahNumber,
    DateTime? listenedAt,
  }) : listenedAt = listenedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'emoji': emoji,
    'imageUrl': imageUrl,
    'imageAsset': imageAsset,
    'audioUrl': audioUrl,
    'type': type,
    'stationName': stationName,
    'stationId': stationId,
    'surahNumber': surahNumber,
    'listenedAt': listenedAt.toIso8601String(),
  };

  factory ListeningHistoryItem.fromJson(Map<String, dynamic> json) {
    return ListeningHistoryItem(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      emoji: json['emoji'] ?? '🎵',
      imageUrl: json['imageUrl'],
      imageAsset: json['imageAsset'],
      audioUrl: json['audioUrl'] ?? '',
      type: json['type'] ?? 'radio',
      stationName: json['stationName'],
      stationId: json['stationId'],
      surahNumber: json['surahNumber'],
      listenedAt: json['listenedAt'] != null
          ? DateTime.tryParse(json['listenedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(listenedAt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
  }

  String get typeLabel {
    switch (type) {
      case 'radio':
        return 'راديو';
      case 'surah':
        return 'سورة';
      case 'recitation':
        return 'تلاوة';
      case 'local':
        return 'أوفلاين';
      default:
        return '';
    }
  }
}

class ListeningHistoryService extends ChangeNotifier {
  static final ListeningHistoryService _instance =
  ListeningHistoryService._internal();
  factory ListeningHistoryService() => _instance;
  ListeningHistoryService._internal();

  List<ListeningHistoryItem> _history = [];
  static const int _maxItems = 30;
  static const String _key = 'listening_history_v1';

  List<ListeningHistoryItem> get history => _history;
  bool get hasHistory => _history.isNotEmpty;
  int get count => _history.length;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr != null) {
        final List<dynamic> list = json.decode(jsonStr);
        _history = list
            .map((e) => ListeningHistoryItem.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ ListeningHistory init: $e');
    }
    notifyListeners();
  }

  Future<void> addItem(ListeningHistoryItem item) async {
    // أزل التكرار
    _history.removeWhere((h) =>
    h.title == item.title &&
        h.subtitle == item.subtitle &&
        h.audioUrl == item.audioUrl);

    // أضف في البداية
    _history.insert(0, item);

    // حدّ أقصى
    if (_history.length > _maxItems) {
      _history = _history.sublist(0, _maxItems);
    }

    await _save();
    notifyListeners();
  }

  Future<void> removeItem(int index) async {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      await _save();
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr =
      json.encode(_history.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonStr);
    } catch (e) {
      debugPrint('❌ ListeningHistory save: $e');
    }
  }
}