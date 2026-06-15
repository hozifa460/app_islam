import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Map<String, String> _pathCache = {};
  final Set<String> _downloading = {};

  bool _initialized = false;
  String? _cacheDir;

  Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _cacheDir = '${dir.path}/radio_image_cache';

    final cacheFolder = Directory(_cacheDir!);
    if (!await cacheFolder.exists()) {
      await cacheFolder.create(recursive: true);
    }

    await _loadExistingPaths();
    _initialized = true;

    debugPrint('✅ ImageCacheService initialized');
  }

  Future<void> _loadExistingPaths() async {
    if (_cacheDir == null) return;

    final dir = Directory(_cacheDir!);
    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        _pathCache[fileName] = entity.path;
      }
    }
  }

  Future<void> preloadImages(List<String> imageUrls) async {
    await init();

    final urls = imageUrls
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    for (final url in urls) {
      final key = _keyFromUrl(url);
      if (_pathCache.containsKey(key) || _downloading.contains(key)) {
        continue;
      }

      _downloading.add(key);
      _downloadAndCache(url, key).whenComplete(() {
        _downloading.remove(key);
      });
    }
  }

  String? getLocalPath(String imageUrl) {
    if (imageUrl.isEmpty) return null;
    final key = _keyFromUrl(imageUrl);
    return _pathCache[key];
  }

  Future<String?> getLocalPathAsync(String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    await init();

    final key = _keyFromUrl(imageUrl);

    if (_pathCache.containsKey(key)) {
      return _pathCache[key];
    }

    if (_downloading.contains(key)) return null;

    _downloading.add(key);
    try {
      return await _downloadAndCache(imageUrl, key);
    } finally {
      _downloading.remove(key);
    }
  }

  bool isCached(String imageUrl) {
    if (imageUrl.isEmpty) return false;
    final key = _keyFromUrl(imageUrl);
    return _pathCache.containsKey(key);
  }

  Future<String?> _downloadAndCache(String url, String key) async {
    try {
      if (_cacheDir == null) await init();
      if (_cacheDir == null) return null;

      final filePath = '$_cacheDir/$key';
      final file = File(filePath);

      if (await file.exists()) {
        final size = await file.length();
        if (size > 100) {
          _pathCache[key] = filePath;
          return filePath;
        }
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      if (response.statusCode != 200 || response.bodyBytes.length < 100) {
        return null;
      }

      await file.writeAsBytes(response.bodyBytes, flush: true);
      _pathCache[key] = filePath;
      return filePath;
    } catch (e) {
      debugPrint('❌ ImageCacheService download error: $e');
      return null;
    }
  }

  Future<void> clearAll() async {
    _pathCache.clear();

    if (_cacheDir != null) {
      final dir = Directory(_cacheDir!);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
    }
  }

  Future<String> getCacheSize() async {
    if (_cacheDir == null) return '0 MB';

    try {
      final dir = Directory(_cacheDir!);
      if (!await dir.exists()) return '0 MB';

      int totalBytes = 0;
      await for (final entity in dir.list()) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }

      if (totalBytes < 1024 * 1024) {
        return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '0 MB';
    }
  }

  int get cachedCount => _pathCache.length;

  Future<void> removeImage(String imageUrl) async {
    final key = _keyFromUrl(imageUrl);
    final path = _pathCache.remove(key);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  String _keyFromUrl(String url) {
    final bytes = utf8.encode(url);
    final hash = md5.convert(bytes).toString();

    String ext = 'jpg';
    if (url.toLowerCase().contains('.png')) {
      ext = 'png';
    } else if (url.toLowerCase().contains('.webp')) {
      ext = 'webp';
    } else if (url.toLowerCase().contains('.jpeg')) {
      ext = 'jpeg';
    }

    return '$hash.$ext';
  }
}