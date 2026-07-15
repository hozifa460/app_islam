// lib/screens/radio/widgets_radio_screen/radio_image_widget.dart

import 'package:flutter/material.dart';
import 'cached_image_widget.dart';

/// ✅ Widget موحد للصور - يستخدم الكاش تلقائياً
class RadioImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? imageAsset;
  final String emoji;
  final Color primary;
  final double size;
  final BorderRadius? borderRadius;
  final bool isActive;
  final BoxFit fit;

  const RadioImageWidget({
    super.key,
    this.imageUrl,
    this.imageAsset,
    required this.emoji,
    required this.primary,
    required this.size,
    this.borderRadius,
    this.isActive = false,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      imageAsset: imageAsset,
      fit: fit,
      placeholder: _fallback(),
      errorWidget: _fallback(),
    );
  }

  Widget _fallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isActive ? 0.48 : 0.30),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.48)),
      ),
    );
  }
}
