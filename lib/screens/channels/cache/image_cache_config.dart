import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheConfig {
  static const String _cacheKey = 'channelsImageCache_v3';

  // ✅ CacheManager واحد ثابت
  static final CacheManager customCacheManager = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 400,
      fileService: HttpFileService(),
    ),
  );

  // ✅ تهيئة مرة واحدة
  static void configure() {
    PaintingBinding.instance.imageCache.maximumSize = 200;
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        100 * 1024 * 1024; // 100MB
  }

  // ═══════════════════════════════════════════════
  // ✅ Thumbnail الرئيسي - جودة عالية + أداء
  // ═══════════════════════════════════════════════
  static Widget videoThumbnail({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final videoId = _extractVideoId(url);

    Widget image;

    if (videoId != null && videoId.isNotEmpty) {
      // ✅ استخدم hqdefault مباشرة - جودة ممتازة وسريع
      image = _buildCachedImage(
        url: 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
        width: width,
        height: height,
        fit: fit,
        // ✅ حجم كافٍ للجودة دون إهدار الذاكرة
        memCacheWidth: 640,
        memCacheHeight: 360,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    } else if (url.isNotEmpty) {
      image = _buildCachedImage(
        url: url,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: 640,
        memCacheHeight: 360,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    } else {
      return placeholder ?? const _PlaceholderBox();
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: image);
    }

    return image;
  }

  // ═══════════════════════════════════════════════
  // ✅ Short Thumbnail - نسبة 9:16
  // ═══════════════════════════════════════════════
  static Widget shortThumbnail({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
  }) {
    final videoId = _extractVideoId(url);

    // ✅ sddefault = 640x480 مناسبة للشورتس (9:16)
    final bestUrl = (videoId != null && videoId.isNotEmpty)
        ? 'https://i.ytimg.com/vi/$videoId/sddefault.jpg'
        : url;

    if (bestUrl.isEmpty) return const _PlaceholderBox();

    return _buildCachedImage(
      url: bestUrl,
      width: width,
      height: height,
      fit: fit,
      // ✅ حجم أكبر يناسب نسبة 9:16
      memCacheWidth: 480,
      memCacheHeight: 640,
      placeholder: null,
      errorWidget: null,
    );
  }

  // ═══════════════════════════════════════════════
  // ✅ Channel Avatar
  // ═══════════════════════════════════════════════
  static Widget channelAvatar({
    required String url,
    required double size,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (url.isEmpty) {
      return errorWidget ?? _AvatarError(size: size);
    }

    return ClipOval(
      child: _buildCachedImage(
        url: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: (size * 2).toInt(),
        memCacheHeight: (size * 2).toInt(),
        placeholder: placeholder ?? _AvatarPlaceholder(size: size),
        errorWidget: errorWidget ?? _AvatarError(size: size),
        fadeIn: true,
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // ✅ Core builder - مشترك
  // ═══════════════════════════════════════════════
  static Widget _buildCachedImage({
    required String url,
    double? width,
    double? height,
    required BoxFit fit,
    required int memCacheWidth,
    required int memCacheHeight,
    Widget? placeholder,
    Widget? errorWidget,
    bool fadeIn = false,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      // ✅ جودة منخفضة للـ filter - لا تأثير على الصورة الفعلية
      filterQuality: FilterQuality.low,
      cacheManager: customCacheManager,
      // ✅ حجم الذاكرة محدود
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      // ✅ بدون animation أثناء السكرول (السبب الرئيسي للـ jank)
      fadeInDuration: fadeIn
          ? const Duration(milliseconds: 200)
          : Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => placeholder ?? const _PlaceholderBox(),
      errorWidget: (_, __, ___) => errorWidget ?? const _ErrorBox(),
    );
  }

  // ═══════════════════════════════════════════════
  // ✅ استخراج Video ID
  // ═══════════════════════════════════════════════
  static String? _extractVideoId(String url) {
    if (url.isEmpty) return null;
    try {
      // من thumbnail URL
      final thumbMatch =
      RegExp(r'/vi(?:_webp)?/([a-zA-Z0-9_-]{11})/')
          .firstMatch(url);
      if (thumbMatch != null) return thumbMatch.group(1);

      // من watch URL
      final watchMatch =
      RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(url);
      if (watchMatch != null) return watchMatch.group(1);

      // من youtu.be
      final shortMatch =
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})').firstMatch(url);
      if (shortMatch != null) return shortMatch.group(1);

      // من shorts URL
      final shortsMatch =
      RegExp(r'/shorts/([a-zA-Z0-9_-]{11})').firstMatch(url);
      if (shortsMatch != null) return shortsMatch.group(1);
    } catch (_) {}
    return null;
  }

  static Future<void> clearCache() async {
    try {
      await customCacheManager.emptyCache();
    } catch (_) {}
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}

// ════════════════════════════════════════════════
// Widgets مساعدة - كلها const
// ════════════════════════════════════════════════

class _PlaceholderBox extends StatelessWidget {
  const _PlaceholderBox();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark
          ? const Color(0xFF1E2530)
          : const Color(0xFFE2E8F0),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark
          ? const Color(0xFF1E2530)
          : const Color(0xFFE2E8F0),
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 28,
          color: isDark
              ? const Color(0xFF475569)
              : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final double size;
  const _AvatarPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const ColoredBox(color: Color(0xFFE2E8F0)),
    );
  }
}

class _AvatarError extends StatelessWidget {
  final double size;
  const _AvatarError({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const ColoredBox(
        color: Color(0xFFE2E8F0),
        child: Icon(Icons.person_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }
}