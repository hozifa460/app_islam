import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/books_theme.dart';
import '../../animations/books_animations.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ظˆظٹط¯ط¬طھ ط§ظ„طھظ‚ط¯ظ… ظپظٹ طھط­ظ…ظٹظ„ ط§ظ„ظ…ط¬ظ„ط¯ط§طھ
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class DownloadProgressWidget extends StatelessWidget {
  final int downloadedCount;
  final int totalCount;
  final bool isDownloading;
  final double downloadProgress;
  final double currentFileProgress;
  final String currentDownloadingTitle;
  final bool wasDownloadStopped;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onDownloadAll;
  final VoidCallback onStop;

  const DownloadProgressWidget({
    super.key,
    required this.downloadedCount,
    required this.totalCount,
    required this.isDownloading,
    required this.downloadProgress,
    required this.currentFileProgress,
    required this.currentDownloadingTitle,
    required this.wasDownloadStopped,
    required this.primaryColor,
    required this.isDark,
    required this.onDownloadAll,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BooksTheme.getProgressContainerDecoration(
        isDark,
        BooksTheme.gold.withValues(alpha: 0.16),
      ),
      child: Column(
        children: [
          // ط§ظ„ط±ط£ط³
          _ProgressHeader(
            downloadedCount: downloadedCount,
            totalCount: totalCount,
            isDownloading: isDownloading,
            primaryColor: primaryColor,
            onDownloadAll: onDownloadAll,
            onStop: onStop,
          ),
          const SizedBox(height: 14),
          // ط§ظ„طھظپط§طµظٹظ„
          if (isDownloading) ...[
            _OverallProgress(
              progress: downloadProgress,
              downloadedCount: downloadedCount,
              totalCount: totalCount,
              primaryColor: primaryColor,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            if (currentDownloadingTitle.isNotEmpty)
              _CurrentFileProgress(
                title: currentDownloadingTitle,
                progress: currentFileProgress,
                isDark: isDark,
              ),
          ],
          // ط±ط³ط§ظ„ط© ط§ظ„ط¥ظٹظ‚ط§ظپ
          if (wasDownloadStopped && !isDownloading)
            _StoppedMessage(),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط±ط£ط³ ط§ظ„طھظ‚ط¯ظ…
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ProgressHeader extends StatelessWidget {
  final int downloadedCount;
  final int totalCount;
  final bool isDownloading;
  final Color primaryColor;
  final VoidCallback onDownloadAll;
  final VoidCallback onStop;

  const _ProgressHeader({
    required this.downloadedCount,
    required this.totalCount,
    required this.isDownloading,
    required this.primaryColor,
    required this.onDownloadAll,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ط´ط§ط±ط© ط§ظ„ط¹ط¯ط¯
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BooksTheme.getBadgeDecoration(BooksTheme.gold),
            child: Text(
              '$downloadedCount / $totalCount ظ…ط­ظ…ظ‘ظ„',
              style: GoogleFonts.cairo(
                color: BooksTheme.gold,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Spacer(),
        // ط²ط± ط§ظ„طھط­ظ…ظٹظ„/ط§ظ„ط¥ظٹظ‚ط§ظپ
        _AnimatedActionButton(
          isDownloading: isDownloading,
          primaryColor: primaryColor,
          onDownloadAll: onDownloadAll,
          onStop: onStop,
        ),
      ],
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final bool isDownloading;
  final Color primaryColor;
  final VoidCallback onDownloadAll;
  final VoidCallback onStop;

  const _AnimatedActionButton({
    required this.isDownloading,
    required this.primaryColor,
    required this.onDownloadAll,
    required this.onStop,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.isDownloading) {
          widget.onStop();
        } else {
          widget.onDownloadAll();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isDownloading ? Colors.redAccent : widget.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isDownloading ? Icons.stop_rounded : Icons.download_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isDownloading ? 'ط¥ظٹظ‚ط§ظپ' : 'طھط­ظ…ظٹظ„ ط§ظ„ظƒظ„',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط§ظ„طھظ‚ط¯ظ… ط§ظ„ط¥ط¬ظ…ط§ظ„ظٹ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _OverallProgress extends StatelessWidget {
  final double progress;
  final int downloadedCount;
  final int totalCount;
  final Color primaryColor;
  final bool isDark;

  const _OverallProgress({
    required this.progress,
    required this.downloadedCount,
    required this.totalCount,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                color: downloadedCount == totalCount ? Colors.green : primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '$downloadedCount ظ…ظ† $totalCount ظ…ط¬ظ„ط¯',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                color: BooksTheme.getSubTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// طھظ‚ط¯ظ… ط§ظ„ظ…ظ„ظپ ط§ظ„ط­ط§ظ„ظٹ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _CurrentFileProgress extends StatelessWidget {
  final String title;
  final double progress;
  final bool isDark;

  const _CurrentFileProgress({
    required this.title,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'ط¬ط§ط±ظٹ طھط­ظ…ظٹظ„: $title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            color: BooksTheme.getSubTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) => LinearProgressIndicator(
              value: value,
              minHeight: 5,
              backgroundColor: Colors.grey.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(BooksTheme.gold),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: BooksTheme.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط±ط³ط§ظ„ط© ط§ظ„ط¥ظٹظ‚ط§ظپ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _StoppedMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            const Icon(
              Icons.pause_circle_outline,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'طھظ… ط¥ظٹظ‚ط§ظپ ط§ظ„طھط­ظ…ظٹظ„ ط³ط§ط¨ظ‚ظ‹ط§طŒ ظˆظٹظ…ظƒظ†ظƒ ط§ط³طھظƒظ…ط§ظ„ظ‡ ط¨ط§ظ„ط¶ط؛ط· ط¹ظ„ظ‰ طھط­ظ…ظٹظ„ ط§ظ„ظƒظ„',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}