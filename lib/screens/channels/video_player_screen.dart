import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:islamic_app/screens/channels/features/favorites_manager.dart';
import 'package:islamic_app/screens/channels/helpers/time_format_helper.dart';
import 'package:islamic_app/screens/channels/services/channel_usage_service.dart';
import 'package:islamic_app/screens/channels/services/share_service.dart';
import 'package:islamic_app/screens/channels/services/video_history_service.dart';
import 'package:islamic_app/screens/channels/services/video_suggestions_service.dart';
import 'package:islamic_app/screens/channels/services/youtube_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'features/video_fullscreen_player_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String channelTitle;
  final String channelId;
  final String viewCount;
  final String publishedAt;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.channelTitle,
    this.channelId = '',
    this.viewCount = '',
    this.publishedAt = '',
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  late YoutubePlayerController _ytController;
  late AnimationController _fadeCtrl;

  // player state
  bool _isVertical = false;
  bool _isShort = false;
  bool _showPlayerControls = true;
  bool _showCenterSeekIndicator = false;
  bool _seekForward = true;
  int _seekIndicatorSeconds = 10;
  int _lastRenderedSecond = -1;

  // current times
  double _currentTime = 0;
  double _totalTime = 0;

  // details
  VideoDetails? _videoDetails;
  List<YoutubeComment> _comments = [];
  ChannelInfo? _channelInfo;

  bool _loadingDetails = true;
  bool _loadingComments = true;
  bool _descriptionExpanded = false;

  // history/progress
  Timer? _progressTimer;
  int _lastSavedPosition = 0;
  bool _completionTracked = false;

  // suggestions/autoplay
  List<YoutubeVideo> _suggestedVideos = [];
  bool _loadingSuggestions = true;
  bool _autoplayEnabled = true;
  Timer? _autoplayCountdownTimer;
  int _autoplayCountdown = 5;
  bool _showAutoplayOverlay = false;
  bool _autoplayTriggered = false;

  // controls
  Timer? _hidePlayerControlsTimer;
  Timer? _seekIndicatorTimer;

  // fullscreen restore
  Duration _fullscreenSavedPosition = Duration.zero;
  bool _fullscreenWasPlaying = false;

  // favorites/watch later
  FavoritesManager? _favoritesManager;
  bool _isFavorite = false;
  bool _isInWatchLater = false;

  // player preferences
  bool _captionsEnabled = true;
  String _selectedQuality = 'auto';
  bool _rebuildingPlayer = false;

  static const String _prefCaptionsEnabled =
      'video_player_captions_enabled_v1';
  static const String _prefQuality = 'video_player_quality_v1';

  String get _channelKey =>
      widget.channelId.isNotEmpty ? widget.channelId : widget.channelTitle;

  YoutubeVideo? get _autoplayNext =>
      VideoSuggestionsService.pickAutoplayNext(suggestions: _suggestedVideos);

  String get _videoUrl => 'https://www.youtube.com/watch?v=${widget.videoId}';

  YoutubeVideo get _currentVideoForShare {
    return YoutubeVideo(
      id: widget.videoId,
      title: _videoDetails?.title ?? widget.title,
      description: _videoDetails?.description ?? '',
      thumbnail: 'https://i.ytimg.com/vi/${widget.videoId}/hqdefault.jpg',
      channelTitle: _videoDetails?.channelTitle ?? widget.channelTitle,
      channelId: widget.channelId.isNotEmpty
          ? widget.channelId
          : (_videoDetails?.channelId ?? ''),
      publishedAt: _videoDetails?.publishedAt ?? DateTime.now(),
      viewCount: _videoDetails?.viewCount ?? widget.viewCount,
      likeCount: _videoDetails?.likeCount ?? '0',
      commentCount: _videoDetails?.commentCount ?? '0',
      duration: _videoDetails?.duration ?? '',
      url: _videoUrl,
      type: _isShort ? VideoType.shorts : VideoType.regular,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadPlayerPreferences();
    _favoritesManager = await FavoritesManager.getInstance();

    _isFavorite = _favoritesManager?.isVideoFavorite(widget.videoId) ?? false;
    _isInWatchLater = _favoritesManager?.isInWatchLater(widget.videoId) ?? false;

    _ytController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: _captionsEnabled,
        forceHD: _selectedQuality == '1080p' || _selectedQuality == '720p',
      ),
    )..addListener(_listener);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();

    _startHidePlayerControlsTimer();
    _detectVideoType();
    _loadExtraData();
    _loadSuggestions();
    _startProgressTracking();
    _markStarted();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadPlayerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _captionsEnabled = prefs.getBool(_prefCaptionsEnabled) ?? true;
    _selectedQuality = prefs.getString(_prefQuality) ?? 'auto';
  }

  Future<void> _saveCaptionsPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefCaptionsEnabled, value);
  }

  Future<void> _saveQualityPreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefQuality, value);
  }

  Future<void> _markStarted() async {
    await VideoHistoryService.markAsShown(widget.videoId);
    await ChannelUsageService.markVideoStarted(
      channelId: _channelKey,
      videoId: widget.videoId,
    );
  }

  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      await _saveCurrentProgressSnapshot();
    });
  }

  Future<void> _saveCurrentProgressSnapshot() async {
    final duration = _ytController.metadata.duration.inSeconds;
    final position = _ytController.value.position.inSeconds;

    if (duration <= 0 || position <= 0) return;

    final delta = position - _lastSavedPosition;
    if (delta > 0 && delta <= 12) {
      await ChannelUsageService.addWatchTime(
        channelId: _channelKey,
        watchedSeconds: delta,
      );
    }
    _lastSavedPosition = position;

    await VideoHistoryService.saveProgressSnapshot(
      videoId: widget.videoId,
      positionSeconds: position,
      durationSeconds: duration,
    );

    final progress = VideoHistoryService.getProgress(widget.videoId);
    if (!_completionTracked && progress >= 0.90) {
      _completionTracked = true;
      await ChannelUsageService.markVideoCompleted(
        channelId: _channelKey,
        videoId: widget.videoId,
      );
      await VideoHistoryService.markAsWatched(widget.videoId);
    }
  }

  Future<void> _loadSuggestions() async {
    try {
      final suggestions = await VideoSuggestionsService.getSuggestions(
        currentVideoId: widget.videoId,
        channelId: widget.channelId,
        channelTitle: widget.channelTitle,
        maxResults: 15,
      );

      if (mounted) {
        setState(() {
          _suggestedVideos = suggestions;
          _loadingSuggestions = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingSuggestions = false);
      }
    }
  }

  Future<void> _detectVideoType() async {
    try {
      final url = Uri.parse(
        'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${widget.videoId}&format=json',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final width = (data['width'] as num?) ?? 480;
        final height = (data['height'] as num?) ?? 270;

        final title = widget.title.toLowerCase();
        final looksLikeShort = title.contains('#shorts') ||
            title.contains('shorts') ||
            title.contains('#short');

        if (mounted) {
          setState(() {
            _isVertical = height > width;
            _isShort = looksLikeShort || height > width;
          });
        }
        return;
      }
    } catch (_) {}

    final title = widget.title.toLowerCase();
    final looksLikeShort = title.contains('#shorts') ||
        title.contains('shorts') ||
        title.contains('#short') ||
        title.contains('شورت');

    if (mounted) {
      setState(() {
        _isShort = looksLikeShort;
        _isVertical = looksLikeShort;
      });
    }
  }

  Future<void> _loadExtraData() async {
    final details = await YoutubeService.getVideoFullDetails(widget.videoId);

    if (mounted) {
      setState(() {
        _videoDetails = details;
        _loadingDetails = false;
      });
    }

    final detailsSuggestShort = details != null &&
        YoutubeService.isLikelyShortVideo(
          YoutubeVideo(
            id: widget.videoId,
            title: details.title,
            description: details.description,
            thumbnail: '',
            channelTitle: details.channelTitle,
            channelId: details.channelId,
            publishedAt: details.publishedAt,
            viewCount: details.viewCount,
            likeCount: details.likeCount,
            commentCount: details.commentCount,
            duration: details.duration,
            url: _videoUrl,
          ),
        );

    if (mounted && detailsSuggestShort) {
      setState(() {
        _isShort = true;
      });
    }

    final chId = widget.channelId.isNotEmpty
        ? widget.channelId
        : details?.channelId ?? '';

    if (chId.isNotEmpty) {
      final chInfo = await YoutubeService.getChannelInfo(chId);
      if (mounted) {
        setState(() => _channelInfo = chInfo);
      }
    }

    final comments = await YoutubeService.getVideoComments(widget.videoId);
    if (mounted) {
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    }
  }

  void _listener() {
    if (!mounted) return;

    final position = _ytController.value.position.inMilliseconds.toDouble();
    final total = _ytController.metadata.duration.inMilliseconds.toDouble();
    final currentSecond = _ytController.value.position.inSeconds;

    if (_lastRenderedSecond != currentSecond || _totalTime != total) {
      _lastRenderedSecond = currentSecond;

      setState(() {
        _currentTime = position;
        _totalTime = total;
      });
    }

    if (_autoplayEnabled &&
        !_autoplayTriggered &&
        _autoplayNext != null &&
        _ytController.metadata.duration.inSeconds > 0 &&
        _ytController.value.position.inSeconds >=
            (_ytController.metadata.duration.inSeconds - 1)) {
      _startAutoplayCountdown();
    }
  }

  @override
  void deactivate() {
    _ytController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _persistBeforeExit();
    _progressTimer?.cancel();
    _autoplayCountdownTimer?.cancel();
    _seekIndicatorTimer?.cancel();
    _hidePlayerControlsTimer?.cancel();

    _ytController.removeListener(_listener);
    _ytController.dispose();
    _fadeCtrl.dispose();

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

  Future<void> _persistBeforeExit() async {
    try {
      await _saveCurrentProgressSnapshot();
    } catch (_) {}
  }

  Future<void> _toggleFullScreen() async {
    final currentPosition = _ytController.value.position;
    final wasPlaying = _ytController.value.isPlaying;

    _fullscreenSavedPosition = currentPosition;
    _fullscreenWasPlaying = wasPlaying;

    _ytController.pause();

    final returnedPosition = await Navigator.push<Duration>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoFullscreenPlayerScreen(
          videoId: widget.videoId,
          title: _videoDetails?.title ?? widget.title,
          channelTitle: _videoDetails?.channelTitle ?? widget.channelTitle,
          channelId: widget.channelId.isNotEmpty
              ? widget.channelId
              : (_videoDetails?.channelId ?? ''),
          viewCount: _videoDetails?.viewCount ?? widget.viewCount,
          startPosition: currentPosition,
          wasPlaying: wasPlaying,
          isVertical: _isVertical || _isShort,
          captionsEnabled: _captionsEnabled,
          selectedQuality: _selectedQuality,
        ),
      ),
    );

    if (returnedPosition != null) {
      try {
         _ytController.seekTo(returnedPosition);
        if (_fullscreenWasPlaying) {
          _ytController.play();
        }
      } catch (_) {}
    }
  }

  Future<void> _seekRelative(int seconds) async {
    final current = _ytController.value.position.inSeconds;
    final total = _ytController.metadata.duration.inSeconds;

    if (total <= 0) return;

    final target = (current + seconds).clamp(0, total);
    _ytController.seekTo(Duration(seconds: target));

    _seekForward = seconds > 0;
    _seekIndicatorSeconds = seconds.abs();

    if (!mounted) return;
    setState(() {
      _showCenterSeekIndicator = true;
      _showPlayerControls = true;
    });

    _seekIndicatorTimer?.cancel();
    _seekIndicatorTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() {
        _showCenterSeekIndicator = false;
      });
    });

    _startHidePlayerControlsTimer();
  }

  void _startHidePlayerControlsTimer() {
    _hidePlayerControlsTimer?.cancel();
    _hidePlayerControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showPlayerControls = false;
      });
    });
  }

  void _togglePlayerControls() {
    if (!mounted) return;

    setState(() {
      _showPlayerControls = !_showPlayerControls;
    });

    if (_showPlayerControls) {
      _startHidePlayerControlsTimer();
    } else {
      _hidePlayerControlsTimer?.cancel();
    }
  }

  void _togglePlayPause() {
    if (_ytController.value.isPlaying) {
      _ytController.pause();
    } else {
      _ytController.play();
    }

    if (!mounted) return;
    setState(() {
      _showPlayerControls = true;
    });

    _startHidePlayerControlsTimer();
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openSuggestedVideo(YoutubeVideo video) async {
    await _saveCurrentProgressSnapshot();

    _autoplayCountdownTimer?.cancel();
    _autoplayTriggered = false;
    _showAutoplayOverlay = false;

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoId: video.id,
          title: video.title,
          channelTitle: video.channelTitle,
          channelId: video.channelId,
          viewCount: YoutubeService.formatViews(video.viewCount),
          publishedAt: TimeFormatHelper.shortTimeAgoArabic(video.publishedAt),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_favoritesManager == null) return;
    await _favoritesManager!.toggleVideoFavorite(_currentVideoForShare);
    if (mounted) {
      setState(() {
        _isFavorite = _favoritesManager!.isVideoFavorite(widget.videoId);
      });
    }
  }

  Future<void> _toggleWatchLater() async {
    if (_favoritesManager == null) return;
    await _favoritesManager!.toggleWatchLater(_currentVideoForShare);
    if (mounted) {
      setState(() {
        _isInWatchLater = _favoritesManager!.isInWatchLater(widget.videoId);
      });
    }
  }

  Future<void> _shareCurrentVideo() async {
    await ShareService.shareVideo(_currentVideoForShare, context: context);
  }

  Future<void> _copyCurrentVideoLink() async {
    await ShareService.copyLink(_videoUrl, context: context);
  }

  Future<void> _rebuildPlayerWithSettings() async {
    if (_rebuildingPlayer) return;
    _rebuildingPlayer = true;

    try {
      final currentPosition = _ytController.value.position;
      final wasPlaying = _ytController.value.isPlaying;

      _ytController.removeListener(_listener);
      _ytController.pause();
      _ytController.dispose();

      _ytController = YoutubePlayerController(
        initialVideoId: widget.videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: _captionsEnabled,
          forceHD: _selectedQuality == '1080p' || _selectedQuality == '720p',
        ),
      )..addListener(_listener);

      await Future.delayed(const Duration(milliseconds: 300));

      try {
         _ytController.seekTo(currentPosition);
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 120));

      if (wasPlaying) {
        _ytController.play();
      }

      if (mounted) {
        setState(() {});
      }
    } finally {
      _rebuildingPlayer = false;
    }
  }

  void _showPlayerSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetHandle(),
                    ListTile(
                      leading: const Icon(Icons.closed_caption_rounded),
                      title: Text(
                        'الترجمة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
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
                      leading: const Icon(Icons.high_quality_rounded),
                      title: Text(
                        'الجودة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
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
              ),
            );
          },
        );
      },
    );
  }

  void _showCurrentVideoActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1F2E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(),
                _sheetTile(
                  icon: _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  title: _isFavorite
                      ? 'إزالة من المفضلة'
                      : 'إضافة إلى المفضلة',
                  onTap: () async {
                    Navigator.pop(context);
                    await _toggleFavorite();
                  },
                ),
                _sheetTile(
                  icon: _isInWatchLater
                      ? Icons.watch_later_rounded
                      : Icons.watch_later_outlined,
                  title: _isInWatchLater
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
          ),
        );
      },
    );
  }

  void _showSuggestedVideoActionsSheet(YoutubeVideo video) {
    final isFavorite = _favoritesManager?.isVideoFavorite(video.id) ?? false;
    final isWatchLater = _favoritesManager?.isInWatchLater(video.id) ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1F2E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _sheetTile(
                  icon: Icons.play_arrow_rounded,
                  title: 'تشغيل الآن',
                  onTap: () async {
                    Navigator.pop(context);
                    await _openSuggestedVideo(video);
                  },
                ),
                _sheetTile(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  title: isFavorite
                      ? 'إزالة من المفضلة'
                      : 'إضافة إلى المفضلة',
                  onTap: () async {
                    Navigator.pop(context);
                    if (_favoritesManager != null) {
                      await _favoritesManager!.toggleVideoFavorite(video);
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                ),
                _sheetTile(
                  icon: isWatchLater
                      ? Icons.watch_later_rounded
                      : Icons.watch_later_outlined,
                  title: isWatchLater
                      ? 'إزالة من المشاهدة لاحقًا'
                      : 'إضافة إلى المشاهدة لاحقًا',
                  onTap: () async {
                    Navigator.pop(context);
                    if (_favoritesManager != null) {
                      await _favoritesManager!.toggleWatchLater(video);
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                ),
                _sheetTile(
                  icon: Icons.share_rounded,
                  title: 'مشاركة',
                  onTap: () async {
                    Navigator.pop(context);
                    await ShareService.shareVideo(video, context: context);
                  },
                ),
                _sheetTile(
                  icon: Icons.link_rounded,
                  title: 'نسخ الرابط',
                  onTap: () async {
                    Navigator.pop(context);
                    await ShareService.copyLink(video.url, context: context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final mq = MediaQuery.of(context);

    final colors = _ScreenColors(
      bg: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      cardBg: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      textColor: isDark ? Colors.white : Colors.black,
      subColor: isDark ? const Color(0xFFAAAAAA) : const Color(0xFF606060),
      capColor: isDark ? const Color(0xFF8A8A8A) : const Color(0xFF909090),
      borderColor:
      isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE6E6E6),
      primary: const Color(0xFFFF0000),
      chipBg: isDark ? const Color(0xFF272727) : const Color(0xFFF2F2F2),
      isDark: isDark,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: _isShort ? Colors.black : colors.bg,
          body: _isShort
              ? _buildShortsMode(colors, w, h)
              : SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _fadeCtrl,
                curve: Curves.easeOutCubic,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Stack(
                    children: [
                      _buildPlayer(w, mq),
                      if (_showAutoplayOverlay && _autoplayNext != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.82),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'تشغيل التالي خلال $_autoplayCountdown ثوانٍ',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _cancelAutoplayCountdown,
                                  child: Text(
                                    'إلغاء',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () async {
                                    _cancelAutoplayCountdown();
                                    final next = _autoplayNext;
                                    if (next != null) {
                                      await _openSuggestedVideo(next);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF0000),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'تشغيل الآن',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildTitleSection(w, colors),
                        ),
                        SliverToBoxAdapter(
                          child: _buildChannelBar(w, colors),
                        ),
                        SliverToBoxAdapter(
                          child: _buildTopActions(w, colors),
                        ),
                        SliverToBoxAdapter(
                          child: _buildAutoplaySection(w, colors),
                        ),
                        SliverToBoxAdapter(
                          child: _buildUpNextCard(w, colors),
                        ),
                        SliverToBoxAdapter(
                          child: _buildDescriptionSection(w, colors),
                        ),
                        if (_videoDetails != null &&
                            _videoDetails!.tags.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _buildTagsSection(w, colors),
                          ),
                        SliverToBoxAdapter(
                          child: _buildSuggestedHeader(w, colors),
                        ),
                        _buildSuggestedList(w, colors),
                        SliverToBoxAdapter(
                          child: _buildCommentsHeader(w, colors),
                        ),
                        _buildCommentsList(w, colors),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: mq.padding.bottom + 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  void _startAutoplayCountdown() {
    if (_autoplayTriggered) return;
    _autoplayTriggered = true;

    _autoplayCountdownTimer?.cancel();
    _autoplayCountdown = 5;

    if (mounted) {
      setState(() {
        _showAutoplayOverlay = true;
      });
    }

    _autoplayCountdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (!mounted) {
            timer.cancel();
            return;
          }

          if (_autoplayCountdown <= 1) {
            timer.cancel();
            setState(() {
              _showAutoplayOverlay = false;
            });

            final next = _autoplayNext;
            if (next != null) {
              await _openSuggestedVideo(next);
            }
          } else {
            setState(() {
              _autoplayCountdown--;
            });
          }
        });
  }

  void _cancelAutoplayCountdown() {
    _autoplayCountdownTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _showAutoplayOverlay = false;
    });
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

  Widget _buildShortsMode(_ScreenColors c, double w, double h) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: YoutubePlayer(
              controller: _ytController,
              showVideoProgressIndicator: false,
              aspectRatio: 9 / 16,
              bottomActions: const [],
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.30),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.70),
                  ],
                  stops: const [0.0, 0.18, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: safeTop + 10,
            right: 12,
            child: _circleBtn(
              Icons.arrow_back_ios_new_rounded,
                  () => Navigator.pop(context),
              20,
            ),
          ),
          Positioned(
            top: safeTop + 10,
            left: 12,
            child: _circleBtn(
              Icons.open_in_new_rounded,
                  () => _openUrl('https://www.youtube.com/shorts/${widget.videoId}'),
              18,
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: safeBottom + 18,
            child: Text(
              _videoDetails?.title ?? widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.4,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(double w, MediaQueryData mq) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          YoutubePlayer(
            controller: _ytController,
            showVideoProgressIndicator: false,
            bottomActions: const [],
          ),

          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _togglePlayerControls,
                      onDoubleTap: () => _seekRelative((_isVertical || _isShort) ? -5 : -10),
                      child: const SizedBox.expand(),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _togglePlayerControls,
                      onDoubleTap: () => _seekRelative((_isVertical || _isShort) ? 5 : 10),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _showPlayerControls ? 1 : 0,
            child: IgnorePointer(
              ignoring: !_showPlayerControls,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.30),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.42),
                    ],
                    stops: const [0.0, 0.15, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 8,
            right: 56,
            left: 56,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showPlayerControls ? 1 : 0,
              child: IgnorePointer(
                ignoring: true,
                child: Text(
                  _videoDetails?.title ?? widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            top: 8,
            right: 8,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showPlayerControls ? 1 : 0,
              child: _circleBtn(
                Icons.arrow_back_ios_new_rounded,
                    () => Navigator.pop(context),
                18,
              ),
            ),
          ),

          Positioned(
            top: 8,
            left: 8,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showPlayerControls ? 1 : 0,
              child: _circleBtn(
                Icons.open_in_new_rounded,
                    () => _openUrl(_videoUrl),
                16,
              ),
            ),
          ),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _showPlayerControls ? 1 : 0,
            child: Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.42),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _ytController.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),

          if (_showCenterSeekIndicator)
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
                      Text(
                        '${_seekIndicatorSeconds} ثوان',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
            bottom: 8,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showPlayerControls ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_showPlayerControls,
                child: Container(
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
                        _formatDuration(_currentTime),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _totalTime > 0
                                ? (_currentTime / _totalTime).clamp(0.0, 1.0)
                                : 0.0,
                            minHeight: 4,
                            backgroundColor: Colors.white.withOpacity(0.22),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF0000),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_totalTime),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleFullScreen,
                        child: Icon(
                          _isVertical || _isShort
                              ? Icons.stay_current_portrait_rounded
                              : Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 22,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, double size) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }

  Widget _buildTitleSection(double w, _ScreenColors c) {
    final details = _videoDetails;
    final viewCount = details?.viewCount ?? widget.viewCount;
    final date = details?.publishedAt;
    final publishText = date != null
        ? TimeFormatHelper.shortTimeAgoArabic(date)
        : widget.publishedAt;

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.035, w * 0.04, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _videoDetails?.title ?? widget.title,
            style: GoogleFonts.cairo(
              fontSize: (w * 0.044).clamp(15.0, 19.0),
              fontWeight: FontWeight.w800,
              color: c.textColor,
              height: 1.45,
            ),
          ),
          SizedBox(height: w * 0.014),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (viewCount.isNotEmpty) _metaChip('$viewCount مشاهدة', c),
              if (publishText.isNotEmpty) _metaChip(publishText, c),
              if ((_videoDetails?.duration ?? '').isNotEmpty)
                _metaChip(_videoDetails!.duration, c),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String text, _ScreenColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.chipBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: c.subColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChannelBar(double w, _ScreenColors c) {
    final channelName = _channelInfo?.title ?? widget.channelTitle;
    final subscriberText = _channelInfo != null
        ? '${YoutubeService.formatCount(_channelInfo!.subscriberCount)} مشترك'
        : 'قناة يوتيوب';

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, 0),
      child: Container(
        padding: EdgeInsets.all(w * 0.028),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.borderColor),
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 46,
                height: 46,
                child: _channelInfo?.thumbnail.isNotEmpty == true
                    ? CachedNetworkImage(
                  imageUrl: _channelInfo!.thumbnail,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _channelFallback(c, w),
                )
                    : _channelFallback(c, w),
              ),
            ),
            SizedBox(width: w * 0.025),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channelName,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: w * 0.005),
                  Text(
                    subscriberText,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: c.capColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final chId = widget.channelId.isNotEmpty
                    ? widget.channelId
                    : _videoDetails?.channelId ?? '';
                if (chId.isNotEmpty) {
                  _openUrl(
                    'https://www.youtube.com/channel/$chId?sub_confirmation=1',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                'اشتراك',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _channelFallback(_ScreenColors c, double w) {
    return Container(
      color: c.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          widget.channelTitle.isNotEmpty ? widget.channelTitle[0] : '؟',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: c.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTopActions(double w, _ScreenColors c) {
    final progress = VideoHistoryService.getProgress(widget.videoId);

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.025, w * 0.04, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _ytActionChip(
              icon: _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: _isFavorite ? 'مفضل' : 'مفضلة',
              c: c,
              filled: true,
              onTap: _toggleFavorite,
            ),
            SizedBox(width: w * 0.02),
            _ytActionChip(
              icon: Icons.share_outlined,
              label: 'مشاركة',
              c: c,
              filled: true,
              onTap: _shareCurrentVideo,
            ),
            SizedBox(width: w * 0.02),
            _ytActionChip(
              icon: _isInWatchLater
                  ? Icons.watch_later_rounded
                  : Icons.watch_later_outlined,
              label: _isInWatchLater ? 'لاحقًا ✓' : 'احفظ',
              c: c,
              filled: true,
              onTap: _toggleWatchLater,
            ),
            SizedBox(width: w * 0.02),
            _ytActionChip(
              icon: Icons.link_rounded,
              label: 'نسخ الرابط',
              c: c,
              filled: true,
              onTap: _copyCurrentVideoLink,
            ),
            SizedBox(width: w * 0.02),
            _ytActionChip(
              icon: Icons.closed_caption_rounded,
              label: _captionsEnabled ? 'CC On' : 'CC Off',
              c: c,
              filled: true,
              onTap: _showPlayerSettingsSheet,
            ),
            SizedBox(width: w * 0.02),
            _ytActionChip(
              icon: Icons.high_quality_rounded,
              label: _selectedQuality == 'auto' ? 'Auto' : _selectedQuality,
              c: c,
              filled: true,
              onTap: _showPlayerSettingsSheet,
            ),
            SizedBox(width: w * 0.02),
            _ytActionChip(
              icon: Icons.more_horiz_rounded,
              label: 'المزيد',
              c: c,
              filled: true,
              onTap: _showCurrentVideoActionsSheet,
            ),
            if (progress > 0 && progress < 0.9) ...[
              SizedBox(width: w * 0.02),
              _ytActionChip(
                icon: Icons.history_rounded,
                label: '${(progress * 100).round()}%',
                c: c,
                filled: true,
                onTap: () {},
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ytActionChip({
    required IconData icon,
    required String label,
    required _ScreenColors c,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.chipBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: c.textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoplaySection(double w, _ScreenColors c) {
    final next = _autoplayNext;
    if (next == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, 0),
      child: Row(
        children: [
          Text(
            'التشغيل التلقائي',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c.textColor,
            ),
          ),
          const Spacer(),
          Switch(
            value: _autoplayEnabled,
            onChanged: (v) => setState(() => _autoplayEnabled = v),
            activeColor: c.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextCard(double w, _ScreenColors c) {
    final next = _autoplayNext;
    if (next == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.02, w * 0.04, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSuggestedVideo(next),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: c.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.borderColor),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: next.thumbnail,
                        width: 135,
                        height: 80,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 135,
                          height: 80,
                          color: c.chipBg,
                          child: const Icon(Icons.play_circle_outline),
                        ),
                      ),
                      if (next.duration.isNotEmpty)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              next.duration,
                              style: GoogleFonts.cairo(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: w * 0.025),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التالي',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: c.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        next.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.textColor,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        next.channelTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: c.capColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: c.primary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(double w, _ScreenColors c) {
    final desc = _videoDetails?.description ?? '';

    if (desc.isEmpty && _loadingDetails) {
      return Padding(
        padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, 0),
        child: Container(
          height: w * 0.2,
          decoration: BoxDecoration(
            color: c.chipBg,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    if (desc.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, 0),
      child: GestureDetector(
        onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(w * 0.035),
          decoration: BoxDecoration(
            color: c.chipBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الوصف',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: c.textColor,
                ),
              ),
              SizedBox(height: w * 0.018),
              AnimatedCrossFade(
                firstChild: Text(
                  desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: c.subColor,
                    height: 1.6,
                  ),
                ),
                secondChild: SelectableText(
                  desc,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: c.subColor,
                    height: 1.6,
                  ),
                ),
                crossFadeState: _descriptionExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              SizedBox(height: w * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _descriptionExpanded ? 'عرض أقل' : 'المزيد',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: c.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection(double w, _ScreenColors c) {
    final tags = _videoDetails!.tags.take(15).toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.025, w * 0.04, 0),
      child: Container(
        padding: EdgeInsets.all(w * 0.035),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.borderColor),
        ),
        child: Wrap(
          spacing: w * 0.015,
          runSpacing: w * 0.012,
          children: tags
              .map(
                (tag) => Container(
              padding:
              EdgeInsets.symmetric(horizontal: w * 0.022, vertical: 6),
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#$tag',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: c.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSuggestedHeader(double w, _ScreenColors c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, 0),
      child: Row(
        children: [
          Text(
            'مقترحات لك',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: c.textColor,
            ),
          ),
          const Spacer(),
          if (_suggestedVideos.isNotEmpty)
            Text(
              '${_suggestedVideos.length} فيديو',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: c.capColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  RenderObjectWidget _buildSuggestedList(double w, _ScreenColors c) {
    if (_loadingSuggestions) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(w * 0.04),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_suggestedVideos.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (_, i) {
          final video = _suggestedVideos[i];
          final isFirst = i == 0;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              w * 0.04,
              isFirst ? w * 0.018 : w * 0.014,
              w * 0.04,
              0,
            ),
            child: _SuggestedVideoCard(
              video: video,
              onTap: () => _openSuggestedVideo(video),
              onMore: () => _showSuggestedVideoActionsSheet(video),
            ),
          );
        },
        childCount: _suggestedVideos.length,
      ),
    );
  }

  Widget _buildCommentsHeader(double w, _ScreenColors c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.04, w * 0.04, 0),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: c.primary,
          ),
          SizedBox(width: w * 0.015),
          Text(
            'التعليقات',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.textColor,
            ),
          ),
          SizedBox(width: w * 0.01),
          if (!_loadingComments)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_comments.length}',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: c.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  RenderObjectWidget _buildCommentsList(double w, _ScreenColors c) {
    if (_loadingComments) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
            padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.02, w * 0.04, 0),
            child: _commentShimmer(w, c),
          ),
          childCount: 3,
        ),
      );
    }

    if (_comments.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(w * 0.06),
          child: Center(
            child: Text(
              'لا توجد تعليقات',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: c.capColor,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(
          padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.015, w * 0.04, 0),
          child: _CommentCard(
            comment: _comments[i],
            colors: c,
            w: w,
            timeAgo: TimeFormatHelper.shortTimeAgoArabic,
          ),
        ),
        childCount: _comments.length,
      ),
    );
  }

  Widget _commentShimmer(double w, _ScreenColors c) {
    return Container(
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.chipBg,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: w * 0.3, color: c.chipBg),
                SizedBox(height: w * 0.015),
                Container(height: 10, width: w * 0.6, color: c.chipBg),
                SizedBox(height: w * 0.008),
                Container(height: 10, width: w * 0.4, color: c.chipBg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedVideoCard extends StatelessWidget {
  final YoutubeVideo video;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  const _SuggestedVideoCard({
    required this.video,
    required this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final progress = VideoHistoryService.getProgress(video.id);
    final partial = VideoHistoryService.isPartiallyWatched(video.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnail,
                    width: 160,
                    height: 92,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 160,
                      height: 92,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.play_circle_outline),
                    ),
                  ),
                  if (video.duration.isNotEmpty)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.duration,
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (progress > 0 && progress < 0.9)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF0000),
                        ),
                      ),
                    ),
                  if (partial)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.92),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'أكمل',
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      video.channelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${YoutubeService.formatViews(video.viewCount)} مشاهدة • ${TimeFormatHelper.shortTimeAgoArabic(video.publishedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onMore,
              child: Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final YoutubeComment comment;
  final _ScreenColors colors;
  final double w;
  final String Function(DateTime) timeAgo;

  const _CommentCard({
    required this.comment,
    required this.colors,
    required this.w,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              width: 40,
              height: 40,
              child: comment.authorImage.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: comment.authorImage,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallback(),
              )
                  : _fallback(),
            ),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.authorName,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: w * 0.012),
                    Text(
                      timeAgo(comment.publishedAt),
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: colors.capColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.01),
                Text(
                  comment.text,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: colors.subColor,
                    height: 1.5,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: colors.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          comment.authorName.isNotEmpty ? comment.authorName[0] : '؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _ScreenColors {
  final Color bg;
  final Color cardBg;
  final Color textColor;
  final Color subColor;
  final Color capColor;
  final Color borderColor;
  final Color primary;
  final Color chipBg;
  final bool isDark;

  const _ScreenColors({
    required this.bg,
    required this.cardBg,
    required this.textColor,
    required this.subColor,
    required this.capColor,
    required this.borderColor,
    required this.primary,
    required this.chipBg,
    required this.isDark,
  });
}