// lib/screens/radio/video/video_feed_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/video/services/playback_position_service.dart';
import 'package:islamic_app/screens/radio/video/services/video_cache_manager.dart';
import 'package:islamic_app/screens/radio/video/services/video_download_service.dart';
import 'package:islamic_app/screens/radio/video/services/video_watch_history_service.dart';
import 'package:islamic_app/screens/radio/video/widgets/video_page_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../data/recitation_categories_data.dart';

class VideoFeedScreen extends StatefulWidget {
  final List<RecitationSubItem> videos;
  final int initialIndex;
  final Color primary;
  final String categoryTitle;

  const VideoFeedScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    required this.primary,
    required this.categoryTitle,
  });

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  final _cacheManager = VideoCacheManager();
  int _currentIndex = 0;
  late VideoDownloadService _videoDownloadService;
  int _pageChangeSeq = 0;

  static const int _preloadRange = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ هيئه أولاً
    _videoDownloadService = context.read<VideoDownloadService>();

    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _startCurrentImmediately();
    _preloadNeighbors(_currentIndex);
    _recordWatch(_currentIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauseAllVideosBeforeExit();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseAllVideosBeforeExit();
    }
  }

  // ══════════════════════════════════════════════════════
  // preload حول العنصر الحالي
  // ══════════════════════════════════════════════════════

  Future<void> _preloadAround(int index) async {
    final start = (index - _preloadRange).clamp(0, widget.videos.length - 1);
    final end = (index + _preloadRange).clamp(0, widget.videos.length - 1);

    for (int i = start; i <= end; i++) {
      final item = widget.videos[i];
      final videoUrl = item.videoUrl ?? '';
      if (videoUrl.isEmpty) continue;

      final videoId = VideoDownloadService.videoIdFromUrl(videoUrl);
      final localPath = _videoDownloadService.getLocalPath(videoId);

      final savedPos =
          _cacheManager.getSavedPosition(localPath ?? videoUrl) ??
              await PlaybackPositionService().getPositionAsync(localPath ?? videoUrl);

      VideoPlayerController controller;

      // ✅ إذا محمّل: استخدم controller محلي
      if (localPath != null && File(localPath).existsSync()) {
        controller = await _cacheManager.ensureLocalController(
          localPath,
          restorePosition: savedPos,
        );
      } else {
        // ✅ غير محمّل: استخدم الشبكة
        controller = await _cacheManager.ensureController(videoUrl);

        if (savedPos != null && savedPos.inSeconds > 0) {
          await controller.seekTo(savedPos);
        }
      }

      if (i == _currentIndex && mounted) {
        if (!controller.value.isPlaying) {
          await controller.play();
        }
        setState(() {});
      }
    }
  }

  Future<void> _pauseAllVideosBeforeExit() async {
    for (final video in widget.videos) {
      await _saveAndPauseControllersForItem(video);
    }
  }

  String? _getPlayUrl(RecitationSubItem item) {
    final videoUrl = item.videoUrl ?? '';
    if (videoUrl.isEmpty) return null;

    final videoId = VideoDownloadService.videoIdFromUrl(videoUrl);
    final localPath = _videoDownloadService.getLocalPath(videoId);

    if (localPath != null && File(localPath).existsSync()) {
      return localPath;
    }

    return videoUrl;
  }

  void _startCurrentImmediately() {
    final item = widget.videos[_currentIndex];
    final videoUrl = item.videoUrl ?? '';
    if (videoUrl.isEmpty) return;

    final videoId = VideoDownloadService.videoIdFromUrl(videoUrl);
    final localPath = _videoDownloadService.getLocalPath(videoId);
    final isLocal = localPath != null && File(localPath).existsSync();

    // ✅ المفتاح الفعلي الذي سيُستخدم للتشغيل
    final playKey = isLocal ? localPath! : videoUrl;

    // ✅ إذا كان هناك Controller جاهز لنفس المصدر فشغّله فوراً
    final cachedController = _cacheManager.getController(playKey);
    if (cachedController != null && _cacheManager.isInitialized(playKey)) {
      if (!cachedController.value.isPlaying) {
        cachedController.play();
      }
      if (mounted) setState(() {});
      return;
    }

    // ✅ إذا سنشغل المحلي، أوقف أي نسخة شبكية قديمة لنفس الفيديو
    if (isLocal) {
      final oldNetworkController = _cacheManager.getController(videoUrl);
      oldNetworkController?.pause();
    }

    // ✅ التهيئة حسب المصدر
    final future = isLocal
        ? _cacheManager.ensureLocalController(localPath!)
        : _cacheManager.ensureController(videoUrl);

    future.then((controller) {
      if (!mounted) return;

      // ✅ تأكد أن المستخدم ما زال على نفس الفيديو
      final currentItem = widget.videos[_currentIndex];
      final currentVideoUrl = currentItem.videoUrl ?? '';
      final currentVideoId = VideoDownloadService.videoIdFromUrl(currentVideoUrl);
      final currentLocalPath = _videoDownloadService.getLocalPath(currentVideoId);
      final currentIsLocal =
          currentLocalPath != null && File(currentLocalPath).existsSync();
      final currentKey = currentIsLocal ? currentLocalPath! : currentVideoUrl;

      if (currentKey != playKey) return;

      if (!controller.value.isPlaying) {
        controller.play();
      }

      if (mounted) setState(() {});
    });
  }

  Future<void> _saveAndPauseControllersForItem(RecitationSubItem item) async {
    final videoUrl = item.videoUrl ?? '';
    if (videoUrl.isEmpty) return;

    final videoId = VideoDownloadService.videoIdFromUrl(videoUrl);
    final localPath = _videoDownloadService.getLocalPath(videoId);

    final keys = <String>{
      videoUrl,
      if (localPath != null && localPath.isNotEmpty) localPath,
    };

    for (final key in keys) {
      final controller = _cacheManager.getController(key);
      if (controller != null) {
        final pos = controller.value.position;

        if (pos.inSeconds > 0) {
          _cacheManager.savePosition(key, pos);
          PlaybackPositionService().savePosition(key, pos);
        }

        try {
          await controller.pause();
        } catch (_) {}
      }
    }
  }

  void _preloadNeighbors(int index) {
    final neighborIndexes = <int>[
      index - 1,
      index + 1,
    ];

    for (final i in neighborIndexes) {
      if (i < 0 || i >= widget.videos.length) continue;

      final url = _getPlayUrl(widget.videos[i]);
      if (url == null) continue;

      // ✅ تهيئة في الخلفية فقط - بدون تشغيل
      _cacheManager.ensureController(url);
    }
  }

  void _onPageChanged(int index) async {
    final seq = ++_pageChangeSeq;
    final oldItem = widget.videos[_currentIndex];

    try {
      // ✅ أوقف الشبكي والمحلي معًا
      await _saveAndPauseControllersForItem(oldItem);

      if (seq != _pageChangeSeq || !mounted) return;

      _currentIndex = index;

      final newItem = widget.videos[index];
      final videoUrl = newItem.videoUrl ?? '';
      if (videoUrl.isNotEmpty) {
        final videoId = VideoDownloadService.videoIdFromUrl(videoUrl);
        final localPath = _videoDownloadService.getLocalPath(videoId);

        final savedPos =
            _cacheManager.getSavedPosition(localPath ?? videoUrl) ??
                await PlaybackPositionService().getPositionAsync(localPath ?? videoUrl);

        if (seq != _pageChangeSeq || !mounted) return;

        VideoPlayerController controller;

        if (localPath != null && File(localPath).existsSync()) {
          controller = await _cacheManager.ensureLocalController(
            localPath,
            restorePosition: savedPos,
          );
        } else {
          controller = await _cacheManager.ensureController(videoUrl);

          if (savedPos != null && savedPos.inSeconds > 0) {
            await controller.seekTo(savedPos);
          }
        }

        if (seq != _pageChangeSeq || !mounted) return;

        await controller.play();
      }

      _preloadAround(index);
      _recordWatch(index);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('⚠️ _onPageChanged error: $e');
      if (mounted) setState(() {});
    }
  }

  void _recordWatch(int index) {
    if (index >= widget.videos.length) return;
    final item = widget.videos[index];

    VideoWatchHistoryService().addWatch(
      videoUrl: item.videoUrl ?? '',
      title: item.title,
      category: widget.categoryTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          _pauseAllVideosBeforeExit();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ✅ الفيد العمودي
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: widget.videos.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (_, index) {
                  final url = _getPlayUrl(widget.videos[index]);

                  return VideoPageWidget(
                    key: ValueKey(widget.videos[index].videoUrl),
                    item: widget.videos[index],
                    primary: widget.primary,
                    controller:
                        url != null ? _cacheManager.getController(url) : null,
                    isInitialized:
                        url != null && _cacheManager.isInitialized(url),
                    isActive: index == _currentIndex,
                    showSwipeHint: false,
                    showBottomInfo: true,
                  );
                },
              ),

              // ✅ الهيدر العلوي للفيد
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 8,
                    16,
                    12,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pauseAllVideosBeforeExit();
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.categoryTitle,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentIndex + 1}/${widget.videos.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
