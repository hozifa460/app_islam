import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/share_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShortsPlayerScreen extends StatefulWidget {
  final List<YoutubeVideo> shorts;
  final int initialIndex;

  const ShortsPlayerScreen({
    super.key,
    required this.shorts,
    required this.initialIndex,
  });

  @override
  State<ShortsPlayerScreen> createState() => _ShortsPlayerScreenState();
}

class _ShortsPlayerScreenState extends State<ShortsPlayerScreen> {
  late final PageController _pageController;
  final Map<int, YoutubePlayerController> _controllers = {};

  int _currentIndex = 0;
  bool _showOverlay = true;
  Timer? _overlayTimer;
  Timer? _progressTimer;

  final Map<String, int> _lastSavedPositionByVideo = {};
  final Set<String> _completedTracked = {};
  final Set<String> _likedShortIds = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _initController(_currentIndex);
    _initController(_currentIndex + 1);
    _initController(_currentIndex - 1);

    _startOverlayTimer();
    _startProgressTracking();
    _markCurrentShortStarted();
  }

  Future<void> _markCurrentShortStarted() async {
    if (_currentIndex < 0 || _currentIndex >= widget.shorts.length) return;

    final video = widget.shorts[_currentIndex];
    final channelKey =
    video.channelId.isNotEmpty ? video.channelId : video.channelTitle;

    await ChannelUsageService.markVideoStarted(
      channelId: channelKey,
      videoId: video.id,
    );
    await VideoHistoryService.markAsShown(video.id);
  }

  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _persistCurrentShortProgress();
    });
  }

  Future<void> _persistCurrentShortProgress() async {
    if (_currentIndex < 0 || _currentIndex >= widget.shorts.length) return;

    final video = widget.shorts[_currentIndex];
    final controller = _controllers[_currentIndex];
    if (controller == null) return;

    final duration = controller.metadata.duration.inSeconds;
    final position = controller.value.position.inSeconds;

    if (duration <= 0 || position <= 0) return;

    final lastPosition = _lastSavedPositionByVideo[video.id] ?? 0;
    final delta = position - lastPosition;

    if (delta > 0 && delta <= 8) {
      final channelKey =
      video.channelId.isNotEmpty ? video.channelId : video.channelTitle;

      await ChannelUsageService.addWatchTime(
        channelId: channelKey,
        watchedSeconds: delta,
      );
    }

    _lastSavedPositionByVideo[video.id] = position;

    await VideoHistoryService.saveProgressSnapshot(
      videoId: video.id,
      positionSeconds: position,
      durationSeconds: duration,
    );

    final progress = VideoHistoryService.getProgress(video.id);
    if (progress >= 0.85 && !_completedTracked.contains(video.id)) {
      _completedTracked.add(video.id);

      final channelKey =
      video.channelId.isNotEmpty ? video.channelId : video.channelTitle;

      await ChannelUsageService.markVideoCompleted(
        channelId: channelKey,
        videoId: video.id,
      );
      await VideoHistoryService.markAsWatched(video.id);
    }
  }

  void _toggleLike(YoutubeVideo video) {
    setState(() {
      if (_likedShortIds.contains(video.id)) {
        _likedShortIds.remove(video.id);
      } else {
        _likedShortIds.add(video.id);
      }
    });
  }

  Future<void> _copyShortLink(YoutubeVideo video) async {
    final url = 'https://www.youtube.com/shorts/${video.id}';
    await Clipboard.setData(ClipboardData(text: url));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الرابط',
          style: GoogleFonts.cairo(),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCommentsSheet(YoutubeVideo video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'التعليقات',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        video.commentCount != '0'
                            ? video.commentCount
                            : '0',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Center(
                      child: Text(
                        'عرض التعليقات الكاملة يمكن ربطه لاحقاً\nحالياً هذه نافذة جاهزة للواجهة',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMoreSheet(YoutubeVideo video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.copy_rounded, color: Colors.white),
                  title: Text(
                    'نسخ الرابط',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _copyShortLink(video);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.open_in_new_rounded, color: Colors.white),
                  title: Text(
                    'فتح في يوتيوب',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _openYoutube(video);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_rounded, color: Colors.white),
                  title: Text(
                    'فتح القناة',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _openChannel(video);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _initController(int index) {
    if (index < 0 || index >= widget.shorts.length) return;
    if (_controllers.containsKey(index)) return;

    final video = widget.shorts[index];

    final controller = YoutubePlayerController(
      initialVideoId: video.id,
      flags: YoutubePlayerFlags(
        autoPlay: index == _currentIndex,
        mute: false,
        loop: false,
        enableCaption: true,
        forceHD: false,
      ),
    );

    _controllers[index] = controller;
  }

  void _disposeFarControllers() {
    final keys = _controllers.keys.toList();
    for (final key in keys) {
      if ((key - _currentIndex).abs() > 1) {
        _controllers[key]?.dispose();
        _controllers.remove(key);
      }
    }
  }

  Future<void> _onPageChanged(int index) async {
    await _persistCurrentShortProgress();

    final oldController = _controllers[_currentIndex];
    oldController?.pause();

    _currentIndex = index;

    _initController(index);
    _initController(index + 1);
    _initController(index - 1);

    final newController = _controllers[index];
    newController?.play();

    _disposeFarControllers();
    _showOverlayTemporarily();
    await _markCurrentShortStarted();

    if (mounted) setState(() {});
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });

    if (_showOverlay) {
      _startOverlayTimer();
    } else {
      _overlayTimer?.cancel();
    }
  }

  void _showOverlayTemporarily() {
    if (!mounted) return;
    setState(() => _showOverlay = true);
    _startOverlayTimer();
  }

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showOverlay = false);
      }
    });
  }

  void _togglePlayPause() {
    final controller = _controllers[_currentIndex];
    if (controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    _showOverlayTemporarily();
    setState(() {});
  }

  @override
  void dispose() {
    _persistCurrentShortProgress();
    _progressTimer?.cancel();
    _overlayTimer?.cancel();

    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    super.dispose();
  }

  Future<void> _openYoutube(YoutubeVideo video) async {
    final url = Uri.parse('https://www.youtube.com/shorts/${video.id}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openChannel(YoutubeVideo video) async {
    if (video.channelId.isEmpty) return;
    final url = Uri.parse('https://www.youtube.com/channel/${video.channelId}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: widget.shorts.length,
          onPageChanged: (index) {
            _onPageChanged(index);
          },
          itemBuilder: (context, index) {
            final video = widget.shorts[index];
            final controller = _controllers[index];

            if (controller == null) {
              _initController(index);
              return const ColoredBox(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            return _ShortPage(
              video: video,
              controller: controller,
              currentIndex: index + 1,
              totalCount: widget.shorts.length,
              showOverlay: _showOverlay,
              isLiked: _likedShortIds.contains(video.id),
              onBack: () => Navigator.pop(context),
              onOpenYoutube: () => _openYoutube(video),
              onOpenChannel: () => _openChannel(video),
              onTapScreen: _toggleOverlay,
              onTogglePlayPause: _togglePlayPause,
              onLike: () => _toggleLike(video),
              onComments: () => _showCommentsSheet(video),
              onShare: () {
                ShareService.showShareOptions(
                  context: context,
                  video: video,
                  isDark: true,
                );
              },
              onMore: () => _showMoreSheet(video),
            );
          },
        ),
      ),
    );
  }
}

class _ShortPage extends StatelessWidget {
  final YoutubeVideo video;
  final YoutubePlayerController controller;
  final int currentIndex;
  final int totalCount;
  final bool showOverlay;
  final VoidCallback onBack;
  final VoidCallback onOpenYoutube;
  final VoidCallback onOpenChannel;
  final VoidCallback onTapScreen;
  final VoidCallback onTogglePlayPause;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback onShare;
  final VoidCallback onMore;

  const _ShortPage({
    required this.video,
    required this.controller,
    required this.currentIndex,
    required this.totalCount,
    required this.showOverlay,
    required this.onBack,
    required this.onOpenYoutube,
    required this.onOpenChannel,
    required this.onTapScreen,
    required this.onTogglePlayPause,
    required this.isLiked,
    required this.onLike,
    required this.onComments,
    required this.onShare,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final progress = controller.metadata.duration.inMilliseconds > 0
        ? (controller.value.position.inMilliseconds /
        controller.metadata.duration.inMilliseconds)
        .clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapScreen,
      onDoubleTap: onTogglePlayPause,
      child: Stack(
        children: [
          Positioned.fill(
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: false,
              aspectRatio: 9 / 16,
              bottomActions: const [],
            ),
          ),

          // overlay gradient
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: showOverlay ? 0.30 : 0.12),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: showOverlay ? 0.78 : 0.45),
                    ],
                    stops: const [0.0, 0.16, 0.54, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // play icon in center
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: showOverlay && !controller.value.isPlaying ? 1 : 0,
            child: Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 54,
                ),
              ),
            ),
          ),

          // top progress bars
          Positioned(
            top: safeTop + 8,
            left: 10,
            right: 10,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: showOverlay ? 1 : 0,
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      totalCount > 8 ? 8 : totalCount,
                          (i) {
                        final normalizedIndex = totalCount > 8
                            ? (i == 7
                            ? currentIndex == totalCount ? totalCount : -1
                            : i + 1)
                            : i + 1;

                        final active = normalizedIndex == currentIndex;

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.23),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 2.8,
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // top buttons
          Positioned(
            top: safeTop + 22,
            right: 12,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: showOverlay ? 1 : 0,
              child: _circleBtn(
                Icons.arrow_back_ios_new_rounded,
                onBack,
              ),
            ),
          ),
          Positioned(
            top: safeTop + 22,
            left: 12,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: showOverlay ? 1 : 0,
              child: _circleBtn(
                Icons.open_in_new_rounded,
                onOpenYoutube,
              ),
            ),
          ),

          // index badge
          Positioned(
            top: safeTop + 74,
            left: 14,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: showOverlay ? 1 : 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '$currentIndex / $totalCount',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          // side actions
          Positioned(
            right: 12,
            bottom: safeBottom + 88,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: showOverlay ? 1 : 0,
              child: Column(
                children: [
                  _sideAction(
                    icon: Icons.thumb_up_alt_rounded,
                    label: video.likeCount != '0'
                        ? YoutubeService.formatCount(video.likeCount)
                        : '',
                    onTap: onLike,
                    active: isLiked,
                  ),
                  const SizedBox(height: 18),
                  _sideAction(
                    icon: Icons.comment_rounded,
                    label: video.commentCount != '0'
                        ? YoutubeService.formatCount(video.commentCount)
                        : '',
                    onTap: onComments,
                  ),
                  const SizedBox(height: 18),
                  _sideAction(
                    icon: Icons.share_rounded,
                    label: 'مشاركة',
                    onTap: onShare,
                  ),
                  const SizedBox(height: 18),
                  _sideAction(
                    icon: Icons.more_horiz_rounded,
                    label: '',
                    onTap: onMore,
                  ),
                ],
              ),
            ),
          ),

          // bottom text area
          Positioned(
            left: 14,
            right: 72,
            bottom: safeBottom + 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: showOverlay ? 1 : 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onOpenChannel,
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              video.channelTitle.isNotEmpty
                                  ? video.channelTitle[0]
                                  : 'طں',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            video.channelTitle,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'اشتراك',
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    video.title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (video.viewCount.isNotEmpty && video.viewCount != '0')
                        Flexible(
                          child: Text(
                            '${YoutubeService.formatViews(video.viewCount)} مشاهدة',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            video.channelTitle.isNotEmpty
                                ? '${video.channelTitle} • الصوت الأصلي'
                                : 'الصوت الأصلي',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.46),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _sideAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFFF0000)
                  : Colors.black.withValues(alpha: 0.42),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? const Color(0xFFFF0000)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 23,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 56),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

}