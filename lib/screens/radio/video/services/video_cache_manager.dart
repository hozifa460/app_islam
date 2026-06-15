// lib/screens/radio/video/video_cache_manager.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  static const int _maxCacheSize = 5;

  final Map<String, VideoPlayerController> _cache = {};
  final Set<String> _initializedUrls = {};
  final Set<String> _initializing = {};
  final Map<String, Completer<void>> _initCompleters = {};
  final List<String> _accessOrder = [];

  VideoPlayerController? getController(String url) => _cache[url];

  bool isInitialized(String url) => _initializedUrls.contains(url);

  void _touchUrl(String url) {
    _accessOrder.remove(url);
    _accessOrder.add(url);
  }

  void _evictIfNeeded() {
    while (_cache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldest = _accessOrder.removeAt(0);
      if (_cache.containsKey(oldest)) {
        try { _cache[oldest]!.dispose(); } catch (_) {}
        _cache.remove(oldest);
        _initializedUrls.remove(oldest);
        _savedPositions.remove(oldest);
      }
    }
  }

  Future<VideoPlayerController> ensureController(String url) async {
    if (_cache.containsKey(url) && _initializedUrls.contains(url)) {
      _touchUrl(url);
      return _cache[url]!;
    }

    if (_initializing.contains(url)) {
      final completer = _initCompleters[url];
      if (completer != null) {
        try {
          await completer.future.timeout(const Duration(seconds: 30));
        } catch (_) {
          _initializing.remove(url);
          _initCompleters.remove(url);
        }
      }
      if (_cache.containsKey(url)) return _cache[url]!;
    }

    if (_cache.containsKey(url)) {
      _initializing.add(url);
      _initCompleters[url] = Completer<void>();
      try {
        if (!_initializedUrls.contains(url)) {
          await _cache[url]!.initialize();
          _cache[url]!.setLooping(true);
          _initializedUrls.add(url);
        }
      } catch (e) {
        debugPrint('❌ VideoCacheManager reinit: $e');
      } finally {
        _initializing.remove(url);
        _initCompleters.remove(url)?.complete();
      }
      _touchUrl(url);
      return _cache[url]!;
    }

    _initializing.add(url);
    _initCompleters[url] = Completer<void>();
    _evictIfNeeded();

    late final VideoPlayerController controller;

    // ✅ تحقق إذا المسار ملف محلي
    final isLocal = !url.startsWith('http://') && !url.startsWith('https://');

    if (isLocal) {
      controller = VideoPlayerController.file(File(url));
    } else {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: const {
          'User-Agent':
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/91.0.4472.120 Mobile Safari/537.36',
          'Accept': '*/*',
          'Accept-Encoding': 'identity',
          'Connection': 'keep-alive',
        },
      );
    }

    _cache[url] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      _initializedUrls.add(url);
      _touchUrl(url);
    } catch (e) {
      debugPrint('❌ VideoCacheManager init: $e');
    } finally {
      _initializing.remove(url);
      _initCompleters.remove(url)?.complete();
    }

    return controller;
  }

  // ✅ حفظ مواضع التوقف
  final Map<String, Duration> _savedPositions = {};

  void savePosition(String url, Duration pos) {
    if (url.isNotEmpty && pos.inSeconds > 0) {
      _savedPositions[url] = pos;
    }
  }

  /// ✅ نقل controller من مفتاح قديم (شبكي) إلى مفتاح جديد (محلي)
  void transferController(String oldUrl, String newUrl) {
    if (!_cache.containsKey(oldUrl)) return;
    if (_cache.containsKey(newUrl)) return;

    final controller = _cache.remove(oldUrl);
    if (controller == null) return;

    _cache[newUrl] = controller;
    _touchUrl(newUrl);
    _accessOrder.remove(oldUrl);

    if (_initializedUrls.remove(oldUrl)) {
      _initializedUrls.add(newUrl);
    }

    // ✅ انقل الموضع المحفوظ أيضاً
    final savedPos = _savedPositions.remove(oldUrl);
    if (savedPos != null) {
      _savedPositions[newUrl] = savedPos;
    }
  }

  /// ✅ أنشئ Controller محلي إذا كان الفيديو محمّلاً
  Future<VideoPlayerController> ensureLocalController(
      String localPath, {
        Duration? restorePosition,
      }) async {
    // ✅ إذا موجود ومُهيأ
    if (_cache.containsKey(localPath) && _initializedUrls.contains(localPath)) {
      _touchUrl(localPath);
      final controller = _cache[localPath]!;
      if (restorePosition != null && restorePosition.inSeconds > 0) {
        await controller.seekTo(restorePosition);
      }
      return controller;
    }

    // ✅ إذا موجود لكن غير مهيأ
    if (_cache.containsKey(localPath)) {
      try {
        await _cache[localPath]!.initialize();
        _cache[localPath]!.setLooping(true);
        _initializedUrls.add(localPath);
        _touchUrl(localPath);

        if (restorePosition != null && restorePosition.inSeconds > 0) {
          await _cache[localPath]!.seekTo(restorePosition);
        }
      } catch (e) {
        debugPrint('❌ ensureLocalController reinit: $e');
      }
      return _cache[localPath]!;
    }

    final controller = VideoPlayerController.file(File(localPath));
    _cache[localPath] = controller;
    _evictIfNeeded();

    try {
      await controller.initialize();
      controller.setLooping(true);

      if (restorePosition != null && restorePosition.inSeconds > 0) {
        await controller.seekTo(restorePosition);
      }

      _initializedUrls.add(localPath);
      _touchUrl(localPath);
    } catch (e) {
      debugPrint('❌ ensureLocalController init: $e');
    }

    return controller;
  }

  Duration? getSavedPosition(String url) => _savedPositions[url];

  void pauseAll() {
    for (final c in _cache.values) {
      try { c.pause(); } catch (_) {}
    }
  }

  void disposeUrl(String url) {
    if (!_cache.containsKey(url)) return;
    try { _cache[url]!.dispose(); } catch (_) {}
    _cache.remove(url);
    _initializedUrls.remove(url);
    _initializing.remove(url);
    _initCompleters.remove(url);
    _accessOrder.remove(url);
    _savedPositions.remove(url);
  }

  void disposeAll() {
    for (final c in _cache.values) {
      try { c.dispose(); } catch (_) {}
    }
    _cache.clear();
    _initializedUrls.clear();
    _initializing.clear();
    _initCompleters.clear();
    _accessOrder.clear();
  }

  int get cachedCount => _cache.length;
}