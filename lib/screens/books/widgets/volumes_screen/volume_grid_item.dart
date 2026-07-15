import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/books_theme.dart';
import '../../animations/books_animations.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط¹ظ†طµط± ط§ظ„ظ…ط¬ظ„ط¯ ظپظٹ ط§ظ„ط´ط¨ظƒط©
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class VolumeGridItem extends StatelessWidget {
  final Map<String, dynamic> volume;
  final bool isDownloaded;
  final int index;
  final bool isDark;
  final bool isSmall;
  final VoidCallback onTap;

  const VolumeGridItem({
    super.key,
    required this.volume,
    required this.isDownloaded,
    required this.index,
    required this.isDark,
    required this.isSmall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = volume['imageUrl']?.toString() ?? '';

    return StaggeredBookCardAnimation(
      index: index,
      child: TapScaleAnimation(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          decoration: BooksTheme.getCardDecoration(isDark),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // ط§ظ„ط؛ظ„ط§ظپ
                Expanded(
                  child: _VolumeCover(
                    imageUrl: imageUrl,
                    isDownloaded: isDownloaded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 10),
                // ط§ظ„ط¹ظ†ظˆط§ظ†
                _VolumeTitle(
                  title: volume['title'] ?? 'مجلد',
                  isSmall: isSmall,
                  isDark: isDark,
                ),
                const SizedBox(height: 4),
                // ط§ظ„ط­ط§ظ„ط©
                _VolumeStatus(
                  isDownloaded: isDownloaded,
                  isSmall: isSmall,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط؛ظ„ط§ظپ ط§ظ„ظ…ط¬ظ„ط¯
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _VolumeCover extends StatelessWidget {
  final String imageUrl;
  final bool isDownloaded;
  final bool isDark;

  const _VolumeCover({
    required this.imageUrl,
    required this.isDownloaded,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ط§ظ„طµظˆط±ط©
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => _LoadingPlaceholder(isDark: isDark),
              errorWidget: (context, url, error) => _ErrorPlaceholder(isDark: isDark),
            )
                : _ErrorPlaceholder(isDark: isDark),
          ),
        ),
        // ط£ظٹظ‚ظˆظ†ط© ط§ظ„ط­ط§ظ„ط©
        Positioned(
          top: 8,
          left: 8,
          child: _StatusBadge(isDownloaded: isDownloaded),
        ),
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final bool isDark;

  const _LoadingPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.grey.shade100,
      child: Center(
        child: CircularProgressIndicator(
          color: BooksTheme.gold,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final bool isDark;

  const _ErrorPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.grey.shade100,
      child: Icon(
        Icons.book,
        color: BooksTheme.gold.withValues(alpha: 0.6),
        size: 36,
      ),
    );
  }
}

class _StatusBadge extends StatefulWidget {
  final bool isDownloaded;

  const _StatusBadge({required this.isDownloaded});

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDownloaded != widget.isDownloaded) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: widget.isDownloaded
              ? Colors.green.withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(
          widget.isDownloaded ? Icons.check : Icons.cloud_download,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط¹ظ†ظˆط§ظ† ط§ظ„ظ…ط¬ظ„ط¯
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _VolumeTitle extends StatelessWidget {
  final String title;
  final bool isSmall;
  final bool isDark;

  const _VolumeTitle({
    required this.title,
    required this.isSmall,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: BooksTheme.getTextColor(isDark),
        fontSize: isSmall ? 12 : 13,
        height: 1.3,
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط­ط§ظ„ط© ط§ظ„ظ…ط¬ظ„ط¯
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _VolumeStatus extends StatelessWidget {
  final bool isDownloaded;
  final bool isSmall;
  final bool isDark;

  const _VolumeStatus({
    required this.isDownloaded,
    required this.isSmall,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Text(
        isDownloaded ? 'جاهز للقراءة' : 'اضغط لفتح المجلد',
        key: ValueKey(isDownloaded),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.cairo(
          color: isDownloaded
              ? Colors.green
              : BooksTheme.getSubTextColor(isDark),
          fontSize: isSmall ? 10 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}