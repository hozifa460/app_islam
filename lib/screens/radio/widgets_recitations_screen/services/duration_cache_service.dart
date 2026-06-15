// lib/screens/radio/widgets_recitations_screen/services/duration_cache_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DurationCacheService {
  static final DurationCacheService _instance =
  DurationCacheService._internal();
  factory DurationCacheService() => _instance;
  DurationCacheService._internal();

  // ✅ Cache في الذاكرة
  final Map<String, Duration> _memCache = {};

  // ✅ Player مشترك واحد
  AudioPlayer? _sharedPlayer;

  // ✅ Queue لتسلسل الطلبات
  final List<_DurationTask> _queue = [];
  bool _isProcessing = false;

  // ✅ Set للروابط الجاري تحميلها
  final Set<String> _pending = {};

  // ══════════════════════════════════════════════════════
  // ✅ جلب سريع من cache الذاكرة فقط - بدون network
  // ══════════════════════════════════════════════════════
  Duration? getCached(String audioUrl) {
    if (audioUrl.isEmpty) return null;
    return _memCache[_keyFrom(audioUrl)];
  }

  // ══════════════════════════════════════════════════════
  // جلب المدة - من cache أو network
  // ══════════════════════════════════════════════════════
  Future<Duration?> getDuration(String audioUrl) async {
    if (audioUrl.isEmpty) return null;

    final key = _keyFrom(audioUrl);

    // ✅ من cache الذاكرة - فوري
    if (_memCache.containsKey(key)) return _memCache[key];

    // ✅ من التخزين المحلي
    final saved = await _loadFromPrefs(key);
    if (saved != null) {
      _memCache[key] = saved;
      return saved;
    }

    // ✅ إذا كان جاري التحميل بالفعل
    if (_pending.contains(key)) return null;

    // ✅ أضف للـ queue
    final completer = Completer<Duration?>();
    _queue.add(_DurationTask(url: audioUrl, key: key, completer: completer));
    _pending.add(key);

    if (!_isProcessing) _processQueue();

    return completer.future;
  }

  Future<void> _processQueue() async {
    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final task = _queue.removeAt(0);

      try {
        final duration = await _fetchDuration(task.url);
        if (duration != null && duration.inSeconds > 0) {
          _memCache[task.key] = duration;
          await _saveToPrefs(task.key, duration);
        }
        task.completer.complete(duration);
      } catch (_) {
        task.completer.complete(null);
      } finally {
        _pending.remove(task.key);
      }

      // ✅ تأخير بين الطلبات
      if (_queue.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    _isProcessing = false;
  }

  Future<Duration?> _fetchDuration(String url) async {
    try {
      _sharedPlayer ??= AudioPlayer();

      final duration = await _sharedPlayer!
          .setUrl(url)
          .timeout(const Duration(seconds: 15));

      await _sharedPlayer!.stop();

      return duration;
    } catch (e) {
      debugPrint('⚠️ DurationCache: $e');
      return null;
    }
  }

  Future<Duration?> _loadFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt('dur_$key');
      if (saved != null && saved > 0) {
        return Duration(seconds: saved);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveToPrefs(String key, Duration duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('dur_$key', duration.inSeconds);
    } catch (_) {}
  }

  String _keyFrom(String url) => url.hashCode.abs().toString();

  void clearMemCache() => _memCache.clear();

  // ══════════════════════════════════════════════════════
  // ✅ تنسيق المدة - static
  // ══════════════════════════════════════════════════════
  static String formatDuration(Duration? d) {
    if (d == null || d.inSeconds <= 0) return '';
    if (d.inHours > 0) {
      final h = d.inHours;
      final m = (d.inMinutes % 60).toString().padLeft(2, '0');
      final s = (d.inSeconds % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void dispose() {
    _sharedPlayer?.dispose();
    _sharedPlayer = null;
    _queue.clear();
    _pending.clear();
  }
}

class _DurationTask {
  final String url;
  final String key;
  final Completer<Duration?> completer;

  _DurationTask({
    required this.url,
    required this.key,
    required this.completer,
  });
}