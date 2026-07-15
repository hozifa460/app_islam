// lib/screens/radio/video/widgets/smart_video_thumbnail.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../widgets/radio_image_widget.dart';
import '../services/video_download_service.dart';

// âœ… ظƒط§ط´ ظپظٹ ط§ظ„ط°ط§ظƒط±ط© ظپظ‚ط· - ظ„ط§ ظ‚ط±طµ - ظ„ط§ ظ…ط³ط§ط­ط©
class ThumbnailMemoryCache {
  static final ThumbnailMemoryCache _instance =
  ThumbnailMemoryCache._internal();
  factory ThumbnailMemoryCache() => _instance;
  ThumbnailMemoryCache._internal();

  static const int _maxEntries = 30;
  final Map<String, Uint8List> _cache = {};
  final List<String> _accessOrder = [];

  Uint8List? get(String url) {
    if (!_cache.containsKey(url)) return null;
    _accessOrder.remove(url);
    _accessOrder.add(url);
    return _cache[url];
  }

  void set(String url, Uint8List bytes) {
    if (_cache.containsKey(url)) {
      _accessOrder.remove(url);
    } else if (_cache.length >= _maxEntries) {
      final oldest = _accessOrder.removeAt(0);
      _cache.remove(oldest);
    }
    _cache[url] = bytes;
    _accessOrder.add(url);
  }

  bool has(String url) => _cache.containsKey(url);

  // âœ… ظٹظڈظ…ط³ط­ ط¹ظ†ط¯ ط§ظ„ط®ط±ظˆط¬ ظ…ظ† RadioScreen
  void clear() {
    _cache.clear();
    _accessOrder.clear();
    debugPrint('🗑️ ThumbnailMemoryCache: cleared');
  }

  int get count => _cache.length;
}

class SmartVideoThumbnail extends StatefulWidget {
  final String? imageUrl;
  final String? videoUrl;
  final String emoji;
  final Color primary;
  final double size;
  final BorderRadius borderRadius;
  final BoxFit fit;

  const SmartVideoThumbnail({
    super.key,
    required this.imageUrl,
    required this.videoUrl,
    required this.emoji,
    required this.primary,
    required this.size,
    required this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  State<SmartVideoThumbnail> createState() => _SmartVideoThumbnailState();
}

class _SmartVideoThumbnailState extends State<SmartVideoThumbnail> {
  Uint8List? _thumbBytes;
  String? _youtubeThumbUrl;
  bool _generating = false;

  String get _cacheKey => widget.videoUrl ?? '';

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant SmartVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.videoUrl != widget.videoUrl) {
      _thumbBytes = null;
      _youtubeThumbUrl = null;
      _resolve();
    }
  }

  void _resolve() {
    // ✅ imageUrl يدوي له الأولوية
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) return;

    final url = widget.videoUrl;
    if (url == null || url.isEmpty) return;

    // ✅ استخراج صورة يوتيوب مباشرة إن وجد
    final ytId = _getYoutubeId(url);
    if (ytId != null) {
      setState(() {
        _youtubeThumbUrl = 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
      });
      return;
    }

    // ✅ من الكاش في الذاكرة - فوري
    final cached = ThumbnailMemoryCache().get(url);
    if (cached != null) {
      _thumbBytes = cached;
      return;
    }

    // ✅ ولِّد في الخلفية
    _generate(url);
  }

  Future<void> _generate(String videoUrl) async {
    if (_generating) return;
    _generating = true;

    try {
      // ✅ 1. حاول من الملف المحلي أولاً (بدون إنترنت)
      final localPath = _getLocalPath(videoUrl);
      final source = localPath ?? videoUrl;

      final bytes = await VideoThumbnail.thumbnailData(
        video: source,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
        timeMs: 3000,
      );

      if (bytes != null && bytes.isNotEmpty) {
        // ✅ احفظ في الكاش
        ThumbnailMemoryCache().set(videoUrl, bytes);

        if (mounted) {
          setState(() => _thumbBytes = bytes);
        }
      }
    } catch (_) {
    } finally {
      _generating = false;
    }
  }

  String? _getLocalPath(String videoUrl) {
    try {
      final videoId = VideoDownloadService.videoIdFromUrl(videoUrl);
      final dl = Provider.of<VideoDownloadService>(context, listen: false);
      final path = dl.getLocalPath(videoId);
      if (path != null && File(path).existsSync()) return path;
    } catch (_) {}
    return null;
  }

  String? _getYoutubeId(String url) {
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      final id = match.group(2);
      if (id != null && id.length == 11) return id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. imageUrl يدوي أو يوتيوب
    final displayUrl = (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
        ? widget.imageUrl
        : _youtubeThumbUrl;

    if (displayUrl != null && displayUrl.isNotEmpty) {
      return RadioImageWidget(
        imageUrl: displayUrl,
        emoji: widget.emoji,
        primary: widget.primary,
        size: widget.size,
        borderRadius: widget.borderRadius,
        fit: widget.fit,
      );
    }

    // ✅ 2. صورة مصغرة مولدة
    if (_thumbBytes != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: Image.memory(
          _thumbBytes!,
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }

    // âœ… 3. Fallback
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.primary.withValues(alpha: 0.2),
            widget.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Icon(
              Icons.videocam_rounded,
              color: widget.primary.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}