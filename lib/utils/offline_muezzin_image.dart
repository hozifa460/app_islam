import 'dart:io';
import 'package:flutter/material.dart';
import '../services/adhan_image_cache_service.dart';

class OfflineMuezzinImage extends StatelessWidget {
  final String muezzinId;
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const OfflineMuezzinImage({
    super.key,
    required this.muezzinId,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = FutureBuilder<String?>(
      future: AdhanImageCacheService.instance.getLocalPath(muezzinId),
      builder: (context, snapshot) {
        final localPath = snapshot.data;

        if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
          return Image.file(
            File(localPath),
            fit: fit,
            width: width,
            height: height,
          );
        }

        if (imageUrl.isNotEmpty) {
          return Image.network(
            imageUrl,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) {
              return _placeholder();
            },
          );
        }

        return _placeholder();
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.black12,
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white54,
          size: 32,
        ),
      ),
    );
  }
}