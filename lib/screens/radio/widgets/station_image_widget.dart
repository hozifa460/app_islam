// lib/screens/radio/widgets/station_image_widget.dart

import 'package:flutter/material.dart';

import 'cached_image_widget.dart';

class StationImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? imageAsset;
  final String fallbackEmoji;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color primaryColor;
  final Color goldColor;
  final bool isActive;
  final BoxFit fit;

  const StationImageWidget({
    super.key,
    this.imageUrl,
    this.imageAsset,
    required this.fallbackEmoji,
    this.width,
    this.height,
    this.borderRadius,
    required this.primaryColor,
    required this.goldColor,
    this.isActive = false,
    this.fit = BoxFit.cover,
  });

  bool get _hasNetworkImage =>
      imageUrl != null &&
          imageUrl!.isNotEmpty &&
          Uri.tryParse(imageUrl!)?.hasScheme == true;

  bool get _hasAssetImage =>
      imageAsset != null && imageAsset!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [
                primaryColor.withOpacity(0.35),
                goldColor.withOpacity(0.22),
              ]
                  : [
                primaryColor.withOpacity(0.16),
                primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_hasNetworkImage) {
      return CachedImageWidget(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: _buildFallback(),
      );
    }

    if (_hasAssetImage) {
      return Image.asset(
        imageAsset!,
        fit: fit,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: primaryColor.withOpacity(0.08),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 1.8,
            color: primaryColor.withOpacity(0.45),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
            primaryColor.withOpacity(0.28),
            goldColor.withOpacity(0.18),
          ]
              : [
            primaryColor.withOpacity(0.14),
            goldColor.withOpacity(0.08),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: Text(
          fallbackEmoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}