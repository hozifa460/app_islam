import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/books_theme.dart';
import '../../animations/books_animations.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط¨ط·ط§ظ‚ط© ط§ظ„ظƒطھط§ط¨ ط§ظ„ظ…طھط­ط±ظƒط©
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class BookCardWidget extends StatelessWidget {
  final Map<String, dynamic> book;
  final String downloadStatus;
  final bool isDark;
  final int? downloadedParts;
  final int? totalParts;
  final VoidCallback onTap;
  final VoidCallback onDownloadTap;

  const BookCardWidget({
    super.key,
    required this.book,
    required this.downloadStatus,
    required this.isDark,
    this.downloadedParts,
    this.totalParts,
    required this.onTap,
    required this.onDownloadTap,
  });

  bool get isCollection => book['type'] == 'collection';

  @override
  Widget build(BuildContext context) {
    return TapScaleAnimation(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          // ط؛ظ„ط§ظپ ط§ظ„ظƒطھط§ط¨
          _BookCover(
            imageUrl: book['imageUrl'] ?? '',
            downloadStatus: downloadStatus,
            isDark: isDark,
            onDownloadTap: onDownloadTap,
          ),
          const SizedBox(height: 8),
          // ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ظƒطھط§ط¨
          _BookInfo(
            title: book['title'],
            downloadStatus: downloadStatus,
            isCollection: isCollection,
            downloadedParts: downloadedParts,
            totalParts: totalParts,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط؛ظ„ط§ظپ ط§ظ„ظƒطھط§ط¨
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _BookCover extends StatelessWidget {
  final String imageUrl;
  final String downloadStatus;
  final bool isDark;
  final VoidCallback onDownloadTap;

  const _BookCover({
    required this.imageUrl,
    required this.downloadStatus,
    required this.isDark,
    required this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ط§ظ„طµظˆط±ط©
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _BookImage(imageUrl: imageUrl, isDark: isDark),
            ),
          ),
          // ط£ظٹظ‚ظˆظ†ط© ط§ظ„طھط­ظ…ظٹظ„
          Positioned(
            top: 8,
            left: 8,
            child: _DownloadStatusIcon(
              status: downloadStatus,
              onTap: onDownloadTap,
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// طµظˆط±ط© ط§ظ„ظƒطھط§ط¨ ظ…ط¹ Shimmer
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _BookImage extends StatelessWidget {
  final String imageUrl;
  final bool isDark;

  const _BookImage({
    required this.imageUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _PlaceholderBookCover(isDark: isDark);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _ShimmerPlaceholder(isDark: isDark),
      errorWidget: (context, url, error) => _PlaceholderBookCover(isDark: isDark),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  final bool isDark;

  const _ShimmerPlaceholder({required this.isDark});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              BooksTheme.cardDark.withValues(alpha: 0.6),
              BooksTheme.cardDark.withValues(alpha: 0.3),
              BooksTheme.cardDark.withValues(alpha: 0.6),
            ],
            stops: [
              _controller.value - 0.3,
              _controller.value,
              _controller.value + 0.3,
            ].map((e) => e.clamp(0.0, 1.0)).toList(),
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: BooksTheme.gold,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _PlaceholderBookCover extends StatelessWidget {
  final bool isDark;

  const _PlaceholderBookCover({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BooksTheme.cardDark,
      child: Icon(
        Icons.book,
        color: BooksTheme.gold.withValues(alpha: 0.5),
        size: 36,
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط£ظٹظ‚ظˆظ†ط© ط­ط§ظ„ط© ط§ظ„طھط­ظ…ظٹظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _DownloadStatusIcon extends StatelessWidget {
  final String status;
  final VoidCallback onTap;

  const _DownloadStatusIcon({
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: PulseDownloadIcon(
        isDownloading: status == 'partial',
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BooksTheme.getDownloadIconDecoration(
            BooksTheme.downloadStatusColor(status),
          ),
          child: Icon(
            BooksTheme.downloadStatusIcon(status),
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ظƒطھط§ط¨
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _BookInfo extends StatelessWidget {
  final String title;
  final String downloadStatus;
  final bool isCollection;
  final int? downloadedParts;
  final int? totalParts;
  final bool isDark;

  const _BookInfo({
    required this.title,
    required this.downloadStatus,
    required this.isCollection,
    this.downloadedParts,
    this.totalParts,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ط§ظ„ط¹ظ†ظˆط§ظ†
          SizedBox(
            height: 32,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: BooksTheme.getTextColor(isDark),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          // ط­ط§ظ„ط© ط§ظ„طھط­ظ…ظٹظ„
          Text(
            BooksTheme.downloadStatusLabel(downloadStatus),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: BooksTheme.downloadStatusLabelColor(downloadStatus),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // ط´ط±ظٹط· ط§ظ„طھظ‚ط¯ظ… ظ„ظ„ظ…ط¬ظ…ظˆط¹ط§طھ
          if (isCollection && (totalParts ?? 0) > 0) ...[
            const SizedBox(height: 3),
            _CollectionProgressBar(
              downloaded: downloadedParts ?? 0,
              total: totalParts ?? 0,
            ),
          ],
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط´ط±ظٹط· طھظ‚ط¯ظ… ط§ظ„ظ…ط¬ظ…ظˆط¹ط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _CollectionProgressBar extends StatelessWidget {
  final int downloaded;
  final int total;

  const _CollectionProgressBar({
    required this.downloaded,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : downloaded / total;
    final isComplete = downloaded == total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 3,
            backgroundColor: Colors.grey.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? Colors.green : BooksTheme.gold,
            ),
          ),
        ),
      ),
    );
  }
}