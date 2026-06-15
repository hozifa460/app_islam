// lib/widgets/cached_image_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/services/image_cache_service.dart';

class CachedImageWidget extends StatefulWidget {
  final String? imageUrl;
  final String? imageAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImageWidget({
    super.key,
    this.imageUrl,
    this.imageAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  /// ✅ اختصار سريع - بدل Image.network في أي مكان
  const CachedImageWidget.network(
      String url, {
        super.key,
        this.width,
        this.height,
        this.fit = BoxFit.cover,
        this.borderRadius,
        this.placeholder,
        this.errorWidget,
        this.imageAsset,
      }) : imageUrl = url;

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget> {
  String? _localPath;
  bool _loading = false;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant CachedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.imageAsset != widget.imageAsset) {
      _resolved = false;
      _localPath = null;
      _loading = false;
      _resolve();
    }
  }

  void _resolve() {
    if (_resolved) return;
    _resolved = true;

    // ✅ Asset - فوري
    if (widget.imageAsset != null && widget.imageAsset!.isNotEmpty) {
      return;
    }

    // ✅ Network
    if (_isValidUrl(widget.imageUrl)) {
      final cache = ImageCacheService();
      final cached = cache.getLocalPath(widget.imageUrl!);

      if (cached != null) {
        _localPath = cached;
        return;
      }

      _loading = true;
      _loadAsync();
    }
  }

  Future<void> _loadAsync() async {
    final url = widget.imageUrl;
    if (url == null) return;

    final path = await ImageCacheService().getLocalPathAsync(url);

    if (!mounted) return;
    if (widget.imageUrl != url) return;

    setState(() {
      _localPath = path;
      _loading = false;
    });
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _buildContent();

    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildContent() {
    // ✅ 1. Asset
    if (widget.imageAsset != null && widget.imageAsset!.isNotEmpty) {
      return Image.asset(
        widget.imageAsset!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => _buildError(),
      );
    }

    // ✅ 2. Cached local file
    if (_localPath != null) {
      return Image.file(
        File(_localPath!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, __, ___) {
          ImageCacheService().removeImage(widget.imageUrl ?? '');
          return _buildError();
        },
      );
    }

    // ✅ 3. Loading
    if (_loading) {
      return _buildPlaceholder();
    }

    // ✅ 4. Network fallback (أول مرة قبل التخزين)
    if (_isValidUrl(widget.imageUrl)) {
      return Image.network(
        widget.imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (_, __, ___) => _buildError(),
      );
    }

    // ✅ 5. Error/Empty
    return _buildError();
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Colors.white38,
              ),
            ),
          ),
        );
  }

  Widget _buildError() {
    return widget.errorWidget ??
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white24,
              size: 24,
            ),
          ),
        );
  }
}