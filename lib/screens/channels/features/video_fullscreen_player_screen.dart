import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/channels/features/favorites_manager.dart';
import 'package:islamic_app/screens/channels/services/share_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoFullscreenPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String channelTitle;
  final String channelId;
  final String viewCount;
  final Duration startPosition;
  final bool wasPlaying;
  final bool isVertical;
  final bool captionsEnabled;
  final String selectedQuality;

  const VideoFullscreenPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.channelId,
    required this.viewCount,
    required this.startPosition,
    required this.wasPlaying,
    required this.isVertical,
    required this.captionsEnabled,
    required this.selectedQuality,
  });

  @override
  State<VideoFullscreenPlayerScreen> createState() =>
      _VideoFullscreenPlayerScreenState();
}

class _VideoFullscreenPlayerScreenState
    extends State<VideoFullscreenPlayerScreen> {
  late YoutubePlayerController _controller;
  FavoritesManager? _favoritesManager;

  bool _initializedSeek = false;
  bool _showControls = true;
  bool _showSeekIndicator = false;

  bool _captionsEnabled = true;
  String _selectedQuality = 'auto';

  bool _isFavorite = false;
  bool _isInWatchLater = false;

  bool _seekForward = true;
  int _seekSeconds = 10;

  Timer? _hideControlsTimer;
  Timer? _seekIndicatorTimer;

  static const String _prefCaptionsEnabled = 'video_player_captions_enabled_v1';
  static const String _prefQuality = 'video_player_quality_v1';

  String get _videoUrl => 'https://www.youtube.com/watch?v=${widget.videoId}';

  YoutubeVideo get _currentVideo {
    return YoutubeVideo(
      id: widget.videoId,
      title: widget.title,
      description: '',
      thumbnail: 'https://i.ytimg.com/vi/${widget.videoId}/hqdefault.jpg',
      channelTitle: widget.channelTitle,
      channelId: widget.channelId,
      publishedAt: DateTime.now(),
      viewCount: widget.viewCount,
      likeCount: '0',
      commentCount: '0',
      duration: '',
      url: _videoUrl,
      type: widget.isVertical ? VideoType.shorts : VideoType.regular,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeFullscreen();
  }

  Future<void> _initializeFullscreen() async {
    _favoritesManager = await FavoritesManager.getInstance();
    _isFavorite = _favoritesManager?.isVideoFavorite(widget.videoId) ?? false;
    _isInWatchLater =
        _favoritesManager?.isInWatchLater(widget.videoId) ?? false;

    _captionsEnabled = widget.captionsEnabled;
    _selectedQuality = widget.selectedQuality;

    if (widget.isVertical) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        loop: false,
        enableCaption: _captionsEnabled,
        forceHD: _selectedQuality == '1080p' || _selectedQuality == '720p',
      ),
    )..addListener(_listener);

    _startHideControlsTimer();

    if (mounted) {
      setState(() {});
    }
  }

  void _listener() {
    if (!_initializedSeek && _controller.value.isReady) {
      _initializedSeek = true;

      Future.delayed(const Duration(milliseconds: 180), () async {
        try {
          _controller.seekTo(widget.startPosition);
          if (widget.wasPlaying) {
            _controller.play();
          } else {
            _controller.pause();
          }
        } catch (_) {}
      });
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showControls = false;
      });
    });
  }

  void _toggleControls() {
    if (!mounted) return;

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  Future<void> _seekRelative(int seconds) async {
    final current = _controller.value.position.inSeconds;
    final total = _controller.metadata.duration.inSeconds;

    if (total <= 0) return;

    final target = (current + seconds).clamp(0, total);
    _controller.seekTo(Duration(seconds: target));

    _seekForward = seconds > 0;
    _seekSeconds = seconds.abs();

    if (!mounted) return;
    setState(() {
      _showSeekIndicator = true;
      _showControls = true;
    });

    _seekIndicatorTimer?.cancel();
    _seekIndicatorTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() {
        _showSeekIndicator = false;
      });
    });

    _startHideControlsTimer();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }

    if (!mounted) return;
    setState(() {
      _showControls = true;
    });

    _startHideControlsTimer();
  }

  Future<void> _saveCaptionsPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefCaptionsEnabled, value);
  }

  Future<void> _saveQualityPreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefQuality, value);
  }

  Future<void> _toggleFavorite() async {
    if (_favoritesManager == null) return;
    await _favoritesManager!.toggleVideoFavorite(_currentVideo);
    if (mounted) {
      setState(() {
        _isFavorite = _favoritesManager!.isVideoFavorite(widget.videoId);
      });
    }
  }

  Future<void> _toggleWatchLater() async {
    if (_favoritesManager == null) return;
    await _favoritesManager!.toggleWatchLater(_currentVideo);
    if (mounted) {
      setState(() {
        _isInWatchLater = _favoritesManager!.isInWatchLater(widget.videoId);
      });
    }
  }

  Future<void> _shareCurrentVideo() async {
    await ShareService.shareVideo(_currentVideo, context: context);
  }

  Future<void> _copyCurrentVideoLink() async {
    await ShareService.copyLink(_videoUrl, context: context);
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showPlayerSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1F2E)
              : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.62,
                minChildSize: 0.40,
                maxChildSize: 0.90,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _sheetHandle(),
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          leading: const Icon(Icons.closed_caption_rounded),
                          title: Text(
                            'الترجمة',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            _captionsEnabled ? 'مفعلة' : 'متوقفة',
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                        SwitchListTile(
                          value: _captionsEnabled,
                          onChanged: (value) async {
                            await _saveCaptionsPreference(value);

                            setModalState(() => _captionsEnabled = value);
                            if (mounted) {
                              setState(() => _captionsEnabled = value);
                            }

                            Navigator.pop(context);

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم حفظ إعداد الترجمة، وسيُطبق عند تشغيل الفيديو القادم أو عند إعادة فتح الفيديو',
                                  style: GoogleFonts.cairo(),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          leading: const Icon(Icons.high_quality_rounded),
                          title: Text(
                            'الجودة',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            _selectedQuality == 'auto'
                                ? 'تلقائي'
                                : _selectedQuality,
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                        ...[
                          ('auto', 'تلقائي'),
                          ('1080p', '1080p'),
                          ('720p', '720p'),
                          ('480p', '480p'),
                          ('360p', '360p'),
                        ].map(
                          (q) => RadioListTile<String>(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            value: q.$1,
                            groupValue: _selectedQuality,
                            title: Text(q.$2, style: GoogleFonts.cairo()),
                            onChanged: (value) async {
                              if (value == null) return;

                              await _saveQualityPreference(value);

                              setModalState(() => _selectedQuality = value);
                              if (mounted) {
                                setState(() => _selectedQuality = value);
                              }

                              Navigator.pop(context);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم حفظ الجودة المفضلة، وستُستخدم مع الفيديو التالي أو عند إعادة فتح الفيديو',
                                    style: GoogleFonts.cairo(),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showActionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1F2E)
              : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.52,
            minChildSize: 0.30,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetHandle(),
                    _sheetTile(
                      icon:
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                      title:
                          _isFavorite
                              ? 'إزالة من المفضلة'
                              : 'إضافة إلى المفضلة',
                      onTap: () async {
                        Navigator.pop(context);
                        await _toggleFavorite();
                      },
                    ),
                    _sheetTile(
                      icon:
                          _isInWatchLater
                              ? Icons.watch_later_rounded
                              : Icons.watch_later_outlined,
                      title:
                          _isInWatchLater
                              ? 'إزالة من المشاهدة لاحقًا'
                              : 'إضافة إلى المشاهدة لاحقًا',
                      onTap: () async {
                        Navigator.pop(context);
                        await _toggleWatchLater();
                      },
                    ),
                    _sheetTile(
                      icon: Icons.share_rounded,
                      title: 'مشاركة',
                      onTap: () async {
                        Navigator.pop(context);
                        await _shareCurrentVideo();
                      },
                    ),
                    _sheetTile(
                      icon: Icons.link_rounded,
                      title: 'نسخ الرابط',
                      onTap: () async {
                        Navigator.pop(context);
                        await _copyCurrentVideoLink();
                      },
                    ),
                    _sheetTile(
                      icon: Icons.open_in_new_rounded,
                      title: 'فتح في يوتيوب',
                      onTap: () async {
                        Navigator.pop(context);
                        await _openUrl(_videoUrl);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _closeFullscreen() async {
    final position = _controller.value.position;

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    if (!mounted) return;
    Navigator.pop(context, position);
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _seekIndicatorTimer?.cancel();

    _controller.removeListener(_listener);
    _controller.dispose();

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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final safeTop = mq.padding.top;
    final safeBottom = mq.padding.bottom;

    final playerAspect = widget.isVertical ? (9 / 16) : (16 / 9);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: playerAspect,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        YoutubePlayer(
                          controller: _controller,
                          showVideoProgressIndicator: false,
                          bottomActions: const [],
                        ),

                        Positioned.fill(
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _toggleControls,
                                  onDoubleTap:
                                      () => _seekRelative(
                                        widget.isVertical ? -5 : -10,
                                      ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _toggleControls,
                                  onDoubleTap:
                                      () => _seekRelative(
                                        widget.isVertical ? 5 : 10,
                                      ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _showControls ? 1 : 0,
                          child: IgnorePointer(
                            ignoring: !_showControls,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.30),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.38),
                                  ],
                                  stops: const [0.0, 0.16, 0.75, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: safeTop > 0 ? safeTop * 0.3 : 8,
                          right: 60,
                          left: 60,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: _showControls ? 1 : 0,
                            child: IgnorePointer(
                              ignoring: true,
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.85),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: safeTop + 4,
                          left: 12,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: _showControls ? 1 : 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _closeFullscreen,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.48),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.fullscreen_exit_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: safeTop + 4,
                          right: 12,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: _showControls ? 1 : 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _showActionsSheet,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.48),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.more_vert_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _showControls ? 1 : 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.42),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (_showSeekIndicator)
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _seekForward
                                          ? Icons.forward_10_rounded
                                          : Icons.replay_10_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '$_seekSeconds ثوان',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: safeBottom + 6,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: _showControls ? 1 : 0,
                            child: IgnorePointer(
                              ignoring: !_showControls,
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  final compact = c.maxWidth < 430;

                                  if (compact) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.28),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: LinearProgressIndicator(
                                                    value:
                                                        _controller
                                                                    .metadata
                                                                    .duration
                                                                    .inMilliseconds >
                                                                0
                                                            ? (_controller
                                                                        .value
                                                                        .position
                                                                        .inMilliseconds /
                                                                    _controller
                                                                        .metadata
                                                                        .duration
                                                                        .inMilliseconds)
                                                                .clamp(0.0, 1.0)
                                                            : 0.0,
                                                    minHeight: 4,
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(0.22),
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                          Color
                                                        >(Color(0xFFFF0000)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                _formatDuration(
                                                  _controller
                                                      .value
                                                      .position
                                                      .inMilliseconds
                                                      .toDouble(),
                                                ),
                                                style: GoogleFonts.cairo(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                _formatDuration(
                                                  _controller
                                                      .metadata
                                                      .duration
                                                      .inMilliseconds
                                                      .toDouble(),
                                                ),
                                                style: GoogleFonts.cairo(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: _showPlayerSettingsSheet,
                                                child: const Icon(
                                                  Icons.settings_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.28),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _formatDuration(
                                            _controller
                                                .value
                                                .position
                                                .inMilliseconds
                                                .toDouble(),
                                          ),
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: LinearProgressIndicator(
                                              value:
                                                  _controller
                                                              .metadata
                                                              .duration
                                                              .inMilliseconds >
                                                          0
                                                      ? (_controller
                                                                  .value
                                                                  .position
                                                                  .inMilliseconds /
                                                              _controller
                                                                  .metadata
                                                                  .duration
                                                                  .inMilliseconds)
                                                          .clamp(0.0, 1.0)
                                                      : 0.0,
                                              minHeight: 4,
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.22),
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(Color(0xFFFF0000)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDuration(
                                            _controller
                                                .metadata
                                                .duration
                                                .inMilliseconds
                                                .toDouble(),
                                          ),
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: _showPlayerSettingsSheet,
                                          child: const Icon(
                                            Icons.settings_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  String _formatDuration(double ms) {
    final d = Duration(milliseconds: ms.toInt());
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }

    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }
}
