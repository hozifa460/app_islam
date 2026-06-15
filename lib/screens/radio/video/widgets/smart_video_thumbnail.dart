// lib/screens/radio/video/widgets/smart_video_thumbnail.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../widgets/radio_image_widget.dart';
import '../services/video_download_service.dart';

// ✅ كاش في الذاكرة فقط - لا قرص - لا مساحة
class ThumbnailMemoryCache {
  static final ThumbnailMemoryCache _instance =
  ThumbnailMemoryCache._internal();
  factory ThumbnailMemoryCache() => _instance;
  ThumbnailMemoryCache._internal();

  final Map<String, Uint8List> _cache = {};

  Uint8List? get(String url) => _cache[url];
  void set(String url, Uint8List bytes) => _cache[url] = bytes;
  bool has(String url) => _cache.containsKey(url);

  // ✅ يُمسح عند الخروج من RadioScreen
  void clear() {
    _cache.clear();
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
      _resolve();
    }
  }

  void _resolve() {
    // ✅ imageUrl يدوي له الأولوية
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) return;

    final url = widget.videoUrl;
    if (url == null || url.isEmpty) return;

    // ✅ من الكاش في الذاكرة - فوري
    final cached = ThumbnailMemoryCache().get(url);
    if (cached != null) {
      _thumbBytes = cached;
      return;
    }

    // ✅ ولّد في الخلفية
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

  @override
  Widget build(BuildContext context) {
    // ✅ 1. imageUrl يدوي
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return RadioImageWidget(
        imageUrl: widget.imageUrl,
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

    // ✅ 3. Fallback
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.primary.withOpacity(0.2),
            widget.primary.withOpacity(0.05),
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
              color: widget.primary.withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}