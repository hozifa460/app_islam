// lib/screens/radio/video/audio_video_swiper.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/video/services/playback_position_service.dart';
import 'package:islamic_app/screens/radio/video/services/video_cache_manager.dart';
import 'package:islamic_app/screens/radio/video/widgets/video_page_widget.dart';
import '../data/recitation_categories_data.dart';

class AudioVideoSwiper extends StatefulWidget {
  final RecitationSubItem item;
  final Color primary;
  final Widget audioPlayerWidget;
  final Duration Function() getCurrentPosition;
  final Future<void> Function() onPauseAudio;
  final Future<void> Function() onResumeAudio;
  final Future<void> Function(Duration) onSeekAudio;

  const AudioVideoSwiper({
    super.key,
    required this.item,
    required this.primary,
    required this.audioPlayerWidget,
    required this.getCurrentPosition,
    required this.onPauseAudio,
    required this.onResumeAudio,
    required this.onSeekAudio,
  });

  static bool canSwipe(RecitationSubItem item) {
    return item.hasVideo &&
        item.videoUrl != null &&
        item.videoUrl!.isNotEmpty &&
        !item.isYouTube;
  }

  @override
  State<AudioVideoSwiper> createState() => _AudioVideoSwiperState();
}

class _AudioVideoSwiperState extends State<AudioVideoSwiper> {
  late final PageController _pageController;
  final _cacheManager = VideoCacheManager();
  final _posService = PlaybackPositionService();
  int _currentPage = 0;

  bool _videoReady = false;
  bool _videoError = false;
  bool _videoLoading = false;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _preloadVideo();
    _startPositionSaver();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveCurrentPosition();

    // âœ… ط£ظˆظ‚ظپ ط§ظ„ظپظٹط¯ظٹظˆ ط¹ظ†ط¯ ط§ظ„ط®ط±ظˆط¬
    final url = widget.item.videoUrl;
    if (url != null && url.isNotEmpty) {
      final controller = _cacheManager.getController(url);
      try {
        controller?.pause();
      } catch (_) {}
    }

    _pageController.dispose();
    super.dispose();
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط­ظپط¸ ط§ظ„ظ…ظˆط¶ط¹
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  void _startPositionSaver() {
    _saveTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) { if (mounted) _saveCurrentPosition(); },
    );
  }

  void _saveCurrentPosition() {
    final key = widget.item.audioUrl;
    Duration pos;

    if (_currentPage == 1) {
      final c = _cacheManager.getController(widget.item.videoUrl!);
      pos = c?.value.position ?? Duration.zero;
    } else {
      pos = widget.getCurrentPosition();
    }

    if (pos.inSeconds > 0) {
      _posService.savePosition(key, pos);
    }
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Preload
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Future<void> _preloadVideo() async {
    final url = widget.item.videoUrl;
    if (url == null || url.isEmpty) return;

    // âœ… ظ„ط§ طھط¹ظٹط¯ ط§ظ„طھط­ظ…ظٹظ„ ط¥ط°ط§ ط¬ط§ظ‡ط²
    if (_cacheManager.isInitialized(url)) {
      setState(() {
        _videoReady = true;
        _videoLoading = false;
      });
      return;
    }

    setState(() => _videoLoading = true);

    try {
      await _cacheManager.ensureController(url);
      if (!mounted) return;

      setState(() {
        _videoReady = true;
        _videoLoading = false;
        _videoError = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _videoError = true;
          _videoLoading = false;
        });
      }
    }
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„طھط¨ط¯ظٹظ„
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  void _onPageChanged(int page) async {
    final wasAudio = _currentPage == 0;
    setState(() => _currentPage = page);

    if (page == 1 && wasAudio) {
      await _switchToVideo();
    } else if (page == 0 && !wasAudio) {
      await _switchToAudio();
    }
  }

  Future<void> _switchToVideo() async {
    // âœ… ط£ظˆظ‚ظپ ط§ظ„طµظˆطھ ط£ظˆظ„ط§ظ‹ ظˆط§ظ†طھط¸ط± ظپط¹ظ„ط§ظ‹
    await widget.onPauseAudio();
    await Future.delayed(const Duration(milliseconds: 100));

    final url = widget.item.videoUrl;
    if (url == null) return;

    final c = _cacheManager.getController(url);
    if (c != null && _cacheManager.isInitialized(url)) {
      final currentPos = widget.getCurrentPosition();
      await c.seekTo(currentPos);
      await c.play();
    }
  }

  Future<void> _switchToAudio() async {
    final url = widget.item.videoUrl;
    if (url == null) return;

    final c = _cacheManager.getController(url);
    if (c == null) return;

    // âœ… ط§ط­ظپط¸ ط§ظ„ظˆظ‚طھ ظˆط£ظˆظ‚ظپ ط§ظ„ظپظٹط¯ظٹظˆ ط£ظˆظ„ط§ظ‹
    final currentPos = c.value.position;
    await c.pause();
    await Future.delayed(const Duration(milliseconds: 100));

    // âœ… ط«ظ… ط´ط؛ظ‘ظ„ ط§ظ„طµظˆطھ
    await widget.onSeekAudio(currentPos);
    await widget.onResumeAudio();
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Build
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // âœ… ظ…ط¤ط´ط± ط§ظ„طµظپط­ط©
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TabBtn(
                label: '🎵 صوت',
                isActive: _currentPage == 0,
                primary: widget.primary,
                isDark: isDark,
                onTap: () => _pageController.animateToPage(0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
              ),
              const SizedBox(width: 8),
              _TabBtn(
                label: _videoLoading ? '🎬 تحضير...' : '🎬 فيديو',
                isActive: _currentPage == 1,
                primary: widget.primary,
                isDark: isDark,
                showDot: _videoReady && _currentPage != 1,
                onTap: () => _pageController.animateToPage(1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
              ),
            ],
          ),
        ),

        // âœ… ط§ظ„ظ…ط­طھظˆظ‰
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              // âœ… طµظپط­ط© ط§ظ„طµظˆطھ
              widget.audioPlayerWidget,

              // âœ… طµظپط­ط© ط§ظ„ظپظٹط¯ظٹظˆ - ظ†ظپط³ VideoPageWidget ظ…ظ† ط§ظ„ظپظٹط¯
              _buildVideoPage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPage() {
    if (_videoError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text('فشل تحميل الفيديو',
                  style: GoogleFonts.cairo(color: Colors.white54)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() => _videoError = false);
                  _preloadVideo();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('إعادة',
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final url = widget.item.videoUrl;
    if (url == null || url.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text('لا يوجد فيديو',
              style: GoogleFonts.cairo(color: Colors.white54)),
        ),
      );
    }

    // âœ… ظ†ظپط³ VideoPageWidget ط§ظ„ظ…ط³طھط®ط¯ظ… ظپظٹ ط§ظ„ظپظٹط¯
    return VideoPageWidget(
      item: widget.item,
      primary: widget.primary,
      controller: _cacheManager.getController(url),
      isInitialized: _cacheManager.isInitialized(url),
      isActive: _currentPage == 1,
      showSwipeHint: true,
      showBottomInfo: true,
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _TabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color primary;
  final bool isDark;
  final bool showDot;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.isActive,
    required this.primary,
    required this.isDark,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? primary.withValues(alpha: 0.15)
              : (isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? primary.withValues(alpha: 0.3)
                : (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? primary
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
            ),
            if (showDot) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}