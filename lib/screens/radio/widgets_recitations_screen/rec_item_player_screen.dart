// lib/screens/radio/widgets_recitations_screen/rec_item_player_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/playlist_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/models/downloadable_item.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_item_download_button.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';
import 'package:provider/provider.dart';

import '../video/audio_video_swiper.dart';
import '../video/services/playback_position_service.dart';
import '../video/services/video_cache_manager.dart';
import '../video/services/video_size_service.dart';
import '../widgets/cached_image_widget.dart';
import 'models/playlist_model.dart';

class RecItemPlayerScreen extends StatefulWidget {
  final RecitationItem item;
  final Color primary;
  final IslamicRadioStation station;
  final bool isLocal;
  final String? videoUrl;
  final VideoSource? videoSource;

  const RecItemPlayerScreen({
    super.key,
    required this.item,
    required this.primary,
    required this.station,
    this.isLocal = false,
    this.videoUrl, this.videoSource,
  });

  @override
  State<RecItemPlayerScreen> createState() => _RecItemPlayerScreenState();
}

class _RecItemPlayerScreenState extends State<RecItemPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _equalizerController;
  late AnimationController _albumArtController;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<ProcessingState>? _stateSub;

  static const Color _gold = RecColors.gold;

  AudioPlayer? _activePlayer;
  final ValueNotifier<Duration> _positionNotifier =
  ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _durationNotifier =
  ValueNotifier(Duration.zero);

  bool _isLive = false;
  bool _autoPlay = true;

  double _currentSpeed = 1.0;
  DateTime? _sleepTimer;
  Timer? _sleepTimerTask;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _albumArtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachPlayerBindings();
    });
  }

  void _initPlayer() {
    final radio = context.read<RadioIntillegence>();
    _activePlayer = radio.player;
    _isLive = !widget.isLocal && widget.station.url.startsWith('http');

    // â•گâ•گ ط¥ظ„ط؛ط§ط، ط£ظٹ listeners ظ‚ط¯ظٹظ…ط© â•گâ•گ
    _cancelListeners();

    // â•گâ•گ ط§ظ„ط§ط³طھظ…ط§ط¹ ظ„ظ„ظˆظ‚طھ â•گâ•گ
    _positionSub = _activePlayer?.positionStream.listen((pos) {
      if (mounted) setState(() => _positionNotifier.value = pos);
    });

    _durationSub = _activePlayer?.durationStream.listen((dur) {
      if (mounted && dur != null && dur.inSeconds > 0) {
        setState(() {
          _durationNotifier.value = dur;
          _isLive = false;
        });
      }
    });

    _stateSub = _activePlayer?.processingStateStream.listen((state) {
      if (!mounted) return;
      if (state == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  void _cancelListeners() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
  }

  void _onTrackCompleted() {
    if (!mounted || !_autoPlay) return;

    final playlist = context.read<PlaylistService>();
    if (!playlist.hasPlaylist) return;

    final nextItem = playlist.next();
    if (nextItem != null) {
      _playPlaylistItemAndRefresh(nextItem);
    }
  }

  @override
  void dispose() {
    final key = widget.item.audioUrl ?? widget.station.url;
    final pos = _positionNotifier.value;
    if (pos.inSeconds > 0) {
      // âœ… ط­ظپط¸ ظپظٹ ط§ظ„ظƒط§ط´ ط§ظ„ط³ط±ظٹط¹
      VideoCacheManager().savePosition(key, pos);
      // âœ… ظˆظپظٹ SharedPreferences
      PlaybackPositionService().savePosition(key, pos);
    }

    _cancelListeners();
    _sleepTimerTask?.cancel();
    _bgController.dispose();
    _equalizerController.dispose();
    _albumArtController.dispose();
    _positionNotifier.dispose();
    _durationNotifier.dispose();
    super.dispose();
  }

  void _attachPlayerBindings() {
    final radio = context.read<RadioIntillegence>();
    _activePlayer = radio.player;
    _isLive = !widget.isLocal && widget.station.url.startsWith('http');

    _cancelListeners();

    _positionSub = _activePlayer?.positionStream.listen((pos) {
      _positionNotifier.value = pos;
    });

    _durationSub = _activePlayer?.durationStream.listen((dur) {
      if (dur != null) {
        _durationNotifier.value = dur;
        if (dur.inSeconds > 0 && _isLive) {
          if (mounted) setState(() => _isLive = false);
        }
      }
    });

    _stateSub = _activePlayer?.processingStateStream.listen((state) {
      if (!mounted) return;
      if (state == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });

    // âœ… ط§ط³طھط¹ط§ط¯ط© ط§ظ„ظ…ظˆط¶ط¹
    _restoreSavedPosition();
  }

  Future<void> _restoreSavedPosition() async {
    final key = widget.item.audioUrl ?? widget.station.url;

    // âœ… ط£ظˆظ„ط§ظ‹ ظ…ظ† ط§ظ„ظƒط§ط´ ط§ظ„ط³ط±ظٹط¹
    final cacheManager = VideoCacheManager();
    final cachedPos = cacheManager.getSavedPosition(key);
    if (cachedPos != null && cachedPos.inSeconds > 3) {
      // âœ… ط§ظ†طھط¸ط± ط§ظ„ظ…ط´ط؛ظ„
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        final dur = _activePlayer?.duration;
        if (dur != null && dur.inSeconds > 0) break;
      }
      if (!mounted || _activePlayer == null) return;
      await _activePlayer!.seek(cachedPos);
      _positionNotifier.value = cachedPos;
      return;
    }

    // âœ… ط«ط§ظ†ظٹط§ظ‹ ظ…ظ† SharedPreferences
    final savedPos = await PlaybackPositionService().getPositionAsync(key);
    if (savedPos.inSeconds > 3 && mounted && _activePlayer != null) {
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        final dur = _activePlayer?.duration;
        if (dur != null && dur.inSeconds > 0) break;
      }
      if (!mounted || _activePlayer == null) return;
      await _activePlayer!.seek(savedPos);
      _positionNotifier.value = savedPos;
    }
  }

  void _resetProgress({bool? isLive}) {
    _positionNotifier.value = Duration.zero;
    _durationNotifier.value = Duration.zero;
    if (isLive != null && mounted) {
      setState(() => _isLive = isLive);
    }
  }

  Future<void> _playPlaylistItemAndRefresh(PlaylistItem item) async {
    final coordinator = context.read<AudioCoordinator>();
    await coordinator.playPlaylistItem(item);
    _resetProgress(isLive: !item.isLocal);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    final isTablet = size.width > 600;

    final bgColors = RecColors.bgGradient(context).colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RecColors.background(context),
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (_, __) => CustomPaint(
                    painter: _PlayerBgPainter(
                      progress: _bgController.value,
                      primary: widget.primary,
                      gold: _gold,
                      backgroundColors: bgColors,
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: _buildPlayerContent(isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerContent(bool isTablet) {
    final videoUrl = widget.videoUrl ?? widget.item.videoUrl;
    final videoSource = widget.videoSource ?? widget.item.videoSource;

    final hasRealVideo = videoUrl != null &&
        videoUrl.isNotEmpty &&
        videoSource != VideoSource.youtube;

    if (!hasRealVideo) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: _buildAudioOnlyContent(isTablet),
        ),
      );
    }

    return AudioVideoSwiper(
      item: RecitationSubItem(
        title: widget.item.title,
        subtitle: widget.item.subtitle,
        emoji: widget.item.emoji,
        audioUrl: widget.item.audioUrl ?? widget.station.url,
        videoUrl: videoUrl,
        videoSource: videoSource,
        mediaType: MediaType.both,
      ),
      primary: widget.primary,
      audioPlayerWidget: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom - 50,
          ),
          child: _buildAudioOnlyContent(isTablet),
        ),
      ),
      getCurrentPosition: () => _positionNotifier.value,
      onPauseAudio: () async {
        await context.read<RadioIntillegence>().pause();
      },
      onResumeAudio: () async {
        await context.read<RadioIntillegence>().resume();
      },
      onSeekAudio: (pos) async {
        _activePlayer?.seek(pos);
      },
    );
  }

  Widget _buildAudioOnlyContent(bool isTablet) {
    final size = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;

    return Column(
      children: [
        _buildAppBar(isTablet),

        SizedBox(height: isTablet ? 24 : 16),

        _buildReactiveAlbumArt(size, isTablet),

        SizedBox(height: isTablet ? 28 : 22),

        _buildInfo(isTablet),

        SizedBox(height: isTablet ? 8 : 6),

        _buildStatusBadge(),

        SizedBox(height: isTablet ? 16 : 12),

        _buildReactiveProgressBar(isTablet),

        SizedBox(height: isTablet ? 16 : 12),

        _buildReactiveControls(isTablet),

        SizedBox(height: isTablet ? 16 : 12),

        _buildDownloadSection(isTablet),

        SizedBox(height: safePadding.bottom + 20),
      ],
    );
  }

  Widget _buildReactiveAlbumArt(Size size, bool isTablet) {
    return Consumer<PlaylistService>(
      builder: (_, playlist, __) {
        final currentItem = playlist.currentItem;

        final displayTitle = currentItem?.title ?? widget.item.title;
        final displayEmoji = currentItem?.emoji ?? widget.item.emoji;
        final displayImage = currentItem?.imageUrl ?? widget.item.imageUrl;

        return Selector<RadioIntillegence, _RecPlayerUiState>(
          selector: (_, radio) => _RecPlayerUiState(
            isPlaying: radio.isPlaying,
            isBuffering: radio.isBuffering,
          ),
          builder: (_, state, __) {
            return _buildAlbumArt(
              state.isPlaying,
              state.isBuffering,
              size,
              isTablet,
              displayTitle,
              displayEmoji,
              displayImage,
            );
          },
        );
      },
    );
  }

  Widget _buildReactiveProgressBar(bool isTablet) {
    return ValueListenableBuilder<Duration>(
      valueListenable: _durationNotifier,
      builder: (_, duration, __) {
        return ValueListenableBuilder<Duration>(
          valueListenable: _positionNotifier,
          builder: (_, position, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProgressBar(isTablet, position, duration),
                if (!_isLive && duration.inSeconds > 0)
                  _buildRemainingTime(position, duration),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReactiveControls(bool isTablet) {
    return Selector<RadioIntillegence, _RecPlayerUiState>(
      selector: (_, radio) => _RecPlayerUiState(
        isPlaying: radio.isPlaying,
        isBuffering: radio.isBuffering,
      ),
      builder: (_, state, __) {
        return ValueListenableBuilder<Duration>(
          valueListenable: _durationNotifier,
          builder: (_, duration, __) {
            return ValueListenableBuilder<Duration>(
              valueListenable: _positionNotifier,
              builder: (_, position, __) {
                final radio = context.read<RadioIntillegence>();
                return _buildControls(
                  radio,
                  state.isPlaying,
                  state.isBuffering,
                  isTablet,
                  position,
                  duration,
                );
              },
            );
          },
        );
      },
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // AppBar
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildAppBar(bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, isTablet ? 16 : 10, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: RecColors.iconBackground(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: RecColors.iconBorder(context),
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: RecColors.iconColor(context),
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'يستمع الآن',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: RecColors.textSecondary(context),
                ),
              ),
              Text(
                widget.item.subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: RecColors.textPrimary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط§ط±ط© ط§ظ„ط­ط§ظ„ط© (ط£ظˆظ†ظ„ط§ظٹظ† / ط£ظˆظپظ„ط§ظٹظ†)
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildStatusBadge() {
    if (widget.isLocal) {
      // â•گâ•گ ط£ظˆظپظ„ط§ظٹظ† â•گâ•گ
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 14,
              color: Colors.green,
            ),
            const SizedBox(width: 6),
            Text(
              'يعمل بدون إنترنت',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    // â•گâ•گ ط£ظˆظ†ظ„ط§ظٹظ† â•گâ•گ
    return AnimatedBuilder(
      animation: _equalizerController,
      builder: (_, __) {
        final opacity =
            0.5 + 0.5 * sin(_equalizerController.value * 2 * pi);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blue.withValues(alpha: opacity * 0.4),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_rounded,
                size: 14,
                color: Colors.blue.withValues(alpha: opacity),
              ),
              const SizedBox(width: 6),
              Text(
                'يعمل عبر الإنترنت',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              // ظ†ظ‚ط·ط© ط¨ط«
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط؛ظ„ط§ظپ ط§ظ„ط£ظ„ط¨ظˆظ…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildAlbumArt(
      bool isPlaying,
      bool isBuffering,
      Size size,
      bool isTablet,
      String displayTitle,
      String displayEmoji,
      String? displayImage,
      ) {
    final artSize = size.width * (isTablet ? 0.50 : 0.62);

    return AnimatedBuilder(
      animation: _albumArtController,
      builder: (_, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: isPlaying ? artSize : artSize * 0.88,
          height: isPlaying ? artSize : artSize * 0.88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                RecColors.primary(widget.primary, 0.3),
                RecColors.primary(widget.primary, 0.1),
                RecColors.goldOpacity(0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: RecColors.primary(
                  widget.primary,
                  isPlaying ? 0.35 : 0.1,
                ),
                blurRadius: isPlaying ? 60 : 20,
                spreadRadius: isPlaying ? 15 : 0,
              ),
            ],
            border: Border.all(
              color: RecColors.primary(
                widget.primary,
                isPlaying ? 0.3 : 0.15,
              ),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: _buildArtImage(artSize, displayImage, displayEmoji, displayTitle),
              ),
              if (isPlaying && !isBuffering)
                Positioned(
                  bottom: artSize * 0.1,
                  child: _buildEqualizer(),
                ),
              if (isBuffering)
                Container(
                  decoration: BoxDecoration(
                    color: RecColors.black(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: artSize * 0.2,
                      height: artSize * 0.2,
                      child: CircularProgressIndicator(
                        color: widget.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtImage(
      double size,
      String? displayImage,
      String displayEmoji,
      String displayTitle,
      ) {
    if (displayImage != null &&
        displayImage.isNotEmpty &&
        Uri.tryParse(displayImage)?.hasScheme == true) {
      return CachedImageWidget(
        imageUrl: displayImage,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: _buildEmojiArt(size, displayEmoji, displayTitle),
      );
    }
    return _buildEmojiArt(size, displayEmoji, displayTitle);
  }

  Widget _buildEmojiArt(
      double size,
      String displayEmoji,
      String displayTitle,
      ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RecColors.primary(widget.primary, 0.2),
            RecColors.goldOpacity(0.1),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayEmoji,
            style: TextStyle(fontSize: size * 0.25),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              displayTitle,
              style: GoogleFonts.cairo(
                fontSize: (size * 0.07).clamp(10.0, 16.0),
                fontWeight: FontWeight.w700,
                color: widget.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizer() {
    return AnimatedBuilder(
      animation: _equalizerController,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(8, (i) {
            final phase =
                _equalizerController.value * 2 * pi + i * 0.5;
            final h = 4.0 + 16.0 * ((sin(phase) + 1) / 2);
            return Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.primary, RecColors.goldOpacity(0.7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ…ط¹ظ„ظˆظ…ط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildInfo(bool isTablet) {
    return Consumer<PlaylistService>(
      builder: (_, playlist, __) {
        final hasPlaylist = playlist.hasPlaylist;
        final currentItem = playlist.currentItem;

        final title = hasPlaylist && currentItem != null
            ? currentItem.title
            : widget.item.title;
        final subtitle = hasPlaylist && currentItem != null
            ? currentItem.subtitle
            : widget.item.subtitle;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // â•گâ•گ ط§ط³ظ… ط§ظ„ظ‚ط§ط¦ظ…ط© â•گâ•گ
              if (hasPlaylist) ...[
                Text(
                  playlist.playlistName,
                  style: GoogleFonts.cairo(
                    fontSize: isTablet ? 12 : 10,
                    color: RecColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // â•گâ•گ ط§ط³ظ… ط§ظ„طھظ„ط§ظˆط© â•گâ•گ
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w900,
                  color: RecColors.textPrimary(context),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: isTablet ? 14 : 12,
                  color: RecColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // â•گâ•گ ط±ظ‚ظ… ط§ظ„طھظ„ط§ظˆط© ظپظٹ ط§ظ„ظ‚ط§ط¦ظ…ط© â•گâ•گ
              if (hasPlaylist) ...[
                const SizedBox(height: 4),
                Text(
                  '${playlist.currentIndex + 1} / ${playlist.totalItems}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: RecColors.textHint(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!_isLive && _durationNotifier.value.inSeconds > 0) ...[
                  const SizedBox(height: 4),
                  _buildProgressPercentage(),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressPercentage() {
    final position = _positionNotifier.value;
    final duration = _durationNotifier.value;
    final percent = duration.inMilliseconds > 0
        ? ((position.inMilliseconds / duration.inMilliseconds) * 100)
        .toInt()
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: RecColors.primary(widget.primary, 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$percent% مكتمل',
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: RecColors.primary(widget.primary, 0.7),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Progress Bar
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildProgressBar(
      bool isTablet,
      Duration position,
      Duration duration,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _isLive
          ? _buildLiveIndicator()
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: isTablet ? 5 : 4,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: isTablet ? 7 : 6,
              ),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: isTablet ? 16 : 14,
              ),
              activeTrackColor: widget.primary,
              inactiveTrackColor:
              RecColors.primary(widget.primary, 0.2),
              thumbColor: widget.primary,
              overlayColor:
              RecColors.primary(widget.primary, 0.15),
            ),
            child: Slider(
              value: duration.inMilliseconds > 0
                  ? (position.inMilliseconds /
                  duration.inMilliseconds)
                  .clamp(0.0, 1.0)
                  : 0.0,
              onChanged: (v) {
                final newPos = Duration(
                  milliseconds:
                  (v * duration.inMilliseconds).toInt(),
                );
                _activePlayer?.seek(newPos);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 13 : 11,
                    color: RecColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  duration.inSeconds > 0
                      ? _formatDuration(duration)
                      : '--:--',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 13 : 11,
                    color: RecColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingTime(Duration position, Duration duration) {
    final remaining = duration - position;
    if (remaining.isNegative) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_bottom_rounded,
            size: 12,
            color: RecColors.textHint(context),
          ),
          const SizedBox(width: 4),
          Text(
            'متبقي ${_formatDuration(remaining)}',
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: RecColors.textHint(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return AnimatedBuilder(
      animation: _equalizerController,
      builder: (_, __) {
        final opacity =
            0.5 + 0.5 * sin(_equalizerController.value * 2 * pi);
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.red.withValues(alpha: opacity),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'بث مباشر',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط£ط²ط±ط§ط± ط§ظ„طھط­ظƒظ…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildControls(
      RadioIntillegence radio,
      bool isPlaying,
      bool isBuffering,
      bool isTablet,
      Duration position,
      Duration duration,
      ) {
    return Consumer<PlaylistService>(
      builder: (_, playlist, __) {
        final coordinator = context.read<AudioCoordinator>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // â•گâ•گ ط§ظ„طµظپ ط§ظ„ط±ط¦ظٹط³ظٹ â•گâ•گ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ctrlBtn(
                    icon: Icons.replay_10_rounded,
                    size: isTablet ? 40.0 : 34.0,
                    onTap: _isLive
                        ? null
                        : () {
                      final newPos =
                          position - const Duration(seconds: 10);
                      _activePlayer?.seek(
                        newPos < Duration.zero
                            ? Duration.zero
                            : newPos,
                      );
                    },
                    isDisabled: _isLive,
                  ),

                  _ctrlBtn(
                    icon: Icons.skip_previous_rounded,
                    size: isTablet ? 42.0 : 36.0,
                    onTap: playlist.hasPrevious
                        ? () async {
                      final prev = playlist.previous();
                      if (prev != null) {
                        await _playPlaylistItemAndRefresh(prev);
                      }
                    }
                        : null,
                    isDisabled: !playlist.hasPrevious,
                  ),

                  GestureDetector(
                    onTap: isBuffering
                        ? null
                        : () {
                      HapticFeedback.mediumImpact();
                      radio.togglePlayPause();
                    },
                    child: Container(
                      width: isTablet ? 68 : 60,
                      height: isTablet ? 68 : 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.primary,
                            RecColors.primary(widget.primary, 0.75),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: RecColors.primary(widget.primary, 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: isBuffering
                          ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: isTablet ? 34 : 28,
                      ),
                    ),
                  ),

                  _ctrlBtn(
                    icon: Icons.skip_next_rounded,
                    size: isTablet ? 42.0 : 36.0,
                    onTap: playlist.hasNext
                        ? () async {
                      final next = playlist.next();
                      if (next != null) {
                        await _playPlaylistItemAndRefresh(next);
                      }
                    }
                        : null,
                    isDisabled: !playlist.hasNext,
                  ),

                  _ctrlBtn(
                    icon: Icons.forward_10_rounded,
                    size: isTablet ? 40.0 : 34.0,
                    onTap: _isLive
                        ? null
                        : () {
                      final newPos =
                          position + const Duration(seconds: 10);
                      _activePlayer?.seek(
                        newPos > duration ? duration : newPos,
                      );
                    },
                    isDisabled: _isLive,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // â•گâ•گ طµظپ ط§ظ„ط£ط¯ظˆط§طھ â•گâ•گ
              _buildToolsRow(playlist, isTablet),

              // â•گâ•گ ظ‚ط§ط¦ظ…ط© ط§ظ„طھظ„ط§ظˆط§طھ (ط¥ظ† ظˆط¬ط¯طھ) â•گâ•گ
              if (playlist.hasPlaylist && playlist.totalItems > 1) ...[
                const SizedBox(height: 16),
                _buildPlaylistPreview(playlist, coordinator),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _ctrlBtn({
    required IconData icon,
    required double size,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDisabled
              ? RecColors.itemBackground(context)
              : RecColors.iconBackground(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled
                ? RecColors.itemBorder(context)
                : RecColors.iconBorder(context),
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: isDisabled
              ? RecColors.textHint(context)
              : RecColors.iconColor(context),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // طµظپ ط§ظ„ط£ط¯ظˆط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildToolsRow(PlaylistService playlist, bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // ط±ط§ط¯ظٹظˆ
          _toolBtn(
            icon: Icons.radio_rounded,
            label: playlist.isRadioMode ? 'راديو ✓' : 'راديو',
            isActive: playlist.isRadioMode,
            onTap: () => _openRadioModeSelector(),
          ),

          const SizedBox(width: 8),

          // ظ‚ط§ط¦ظ…ط© ط§ظ„طھط´ط؛ظٹظ„
          if (playlist.hasPlaylist && playlist.totalItems > 1)
            _toolBtn(
              icon: Icons.queue_music_rounded,
              label: 'القائمة (${playlist.totalItems})',
              isActive: false,
              onTap: () => _openFullPlaylist(),
            ),

          if (playlist.hasPlaylist && playlist.totalItems > 1)
            const SizedBox(width: 8),

          // ط§ظ„ط³ط±ط¹ط©
          _toolBtn(
            icon: Icons.speed_rounded,
            label: _getSpeedLabel(),
            isActive: _currentSpeed != 1.0,
            onTap: () => _changeSpeed(),
          ),

          const SizedBox(width: 8),

          // ظپظٹ _buildToolsRow ط£ط¶ظپ ظ‡ط°ط§ ط§ظ„ط²ط± ظپظٹ ط£ظˆظ„ ط§ظ„ظ‚ط§ط¦ظ…ط© ط¨ط¹ط¯ ط²ط± ط§ظ„ط±ط§ط¯ظٹظˆ

          _toolBtn(
            icon: _autoPlay
                ? Icons.playlist_play_rounded
                : Icons.playlist_remove_rounded,
            label: _autoPlay ? 'تالي تلقائي ✓' : 'تالي تلقائي',
            isActive: _autoPlay,
            onTap: () {
              setState(() => _autoPlay = !_autoPlay);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _autoPlay
                        ? 'التشغيل التلقائي: مفعّل ▶'
                        : 'التشغيل التلقائي: متوقف ■',
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: _autoPlay ? widget.primary : Colors.grey,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // ط§ظ„ظ…ط¤ظ‚طھ
          _toolBtn(
            icon: Icons.timer_rounded,
            label: _sleepTimer != null ? _getSleepTimerLabel() : 'مؤقت',
            isActive: _sleepTimer != null,
            onTap: () => _openSleepTimer(),
          ),

          const SizedBox(width: 8),

          // ظ…ظ† ط§ظ„ط¨ط¯ط§ظٹط©
          if (!_isLive)
            _toolBtn(
              icon: Icons.replay_rounded,
              label: 'من البداية',
              isActive: false,
              onTap: () {
                _activePlayer?.seek(Duration.zero);
                setState(() => _positionNotifier.value = Duration.zero);
              },
            ),

          if (!_isLive) const SizedBox(width: 8),

          // +30 ط«ط§ظ†ظٹط©
          if (!_isLive)
            _toolBtn(
              icon: Icons.forward_30_rounded,
              label: '+30 ث',
              isActive: false,
              onTap: () {
                final newPos = _positionNotifier.value + const Duration(seconds: 30);
                _activePlayer?.seek(
                  newPos > _durationNotifier.value ? _durationNotifier.value : newPos,
                );
              },
            ),

          if (!_isLive) const SizedBox(width: 8),

          // ظ…ط´ط§ط±ظƒط©
          _toolBtn(
            icon: Icons.share_rounded,
            label: 'مشاركة',
            isActive: false,
            onTap: () => _shareCurrentTrack(),
          ),
        ],
      ),
    );
  }

  void _openRadioModeSelector() {
    final playlistService = context.read<PlaylistService>();
    final itemDownloadService = context.read<ItemDownloadService>();

    final offlineOnly = widget.isLocal;
    final candidates =
    playlistService.getRadioCandidates(offlineOnly: offlineOnly);

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            offlineOnly
                ? 'لا توجد ملفات محمّلة لتشغيلها كراديو'
                : 'لا توجد عناصر متاحة',
            style: GoogleFonts.cairo(),
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final selected = <PlaylistItem>{...playlistService.playlist};

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RecColors.cardBackground(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: RecColors.textHint(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'اختيار تلاوات وضع الراديو',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: RecColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offlineOnly
                        ? 'يتم عرض التلاوات المحمّلة فقط'
                        : 'يتم عرض كل التلاوات المتاحة',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: RecColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ط£ط²ط±ط§ط± طھط­ط¯ظٹط¯ ط³ط±ظٹط¹
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selected.addAll(candidates);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: RecColors.primary(widget.primary, 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: RecColors.primary(widget.primary, 0.2),
                              ),
                            ),
                            child: Text(
                              'تحديد الكل',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: widget.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selected.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: RecColors.iconBackground(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: RecColors.iconBorder(context),
                              ),
                            ),
                            child: Text(
                              'إلغاء الكل',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: RecColors.textSecondary(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: candidates.length,
                      itemBuilder: (_, i) {
                        final item = candidates[i];
                        final isChecked = selected.contains(item);

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isChecked) {
                                selected.remove(item);
                              } else {
                                selected.add(item);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: RecColors.itemBackground(
                                context,
                                isActive: isChecked,
                                primary: widget.primary,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: RecColors.itemBorder(
                                  context,
                                  isActive: isChecked,
                                  primary: widget.primary,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: RecColors.primary(widget.primary, 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: RecColors.textPrimary(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item.subtitle,
                                              style: GoogleFonts.cairo(
                                                fontSize: 10,
                                                color: RecColors.textHint(context),
                                              ),
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (item.isLocal) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.download_done_rounded,
                                              size: 10,
                                              color: Colors.green,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isChecked
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isChecked
                                      ? widget.primary
                                      : RecColors.textHint(context),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ط²ط± ط§ظ„طھظپط¹ظٹظ„
                  GestureDetector(
                    onTap: () {
                      if (selected.isEmpty) return;

                      final selectedList = selected.toList();

                      final current = playlistService.currentItem;
                      int startIndex = 0;
                      if (current != null) {
                        final idx = selectedList.indexWhere(
                              (e) =>
                          e.title == current.title &&
                              e.subtitle == current.subtitle,
                        );
                        if (idx >= 0) startIndex = idx;
                      }

                      playlistService.setCustomRadioPlaylist(
                        selectedList,
                        startIndex: startIndex,
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تفعيل وضع الراديو (${selectedList.length} تلاوة) 🔄',
                            style: GoogleFonts.cairo(),
                            textDirection: TextDirection.rtl,
                          ),
                          backgroundColor: widget.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: selected.isNotEmpty
                            ? LinearGradient(
                          colors: [
                            widget.primary,
                            RecColors.primary(widget.primary, 0.8),
                          ],
                        )
                            : null,
                        color: selected.isEmpty
                            ? RecColors.iconBackground(context)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.radio_rounded,
                            color: selected.isNotEmpty
                                ? Colors.white
                                : RecColors.textHint(context),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selected.isNotEmpty
                                ? 'تشغيل ${selected.length} كراديو'
                                : 'اختر تلاوات أولاً',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: selected.isNotEmpty
                                  ? Colors.white
                                  : RecColors.textHint(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ط¥ظ„ط؛ط§ط، ظˆط¶ط¹ ط§ظ„ط±ط§ط¯ظٹظˆ
                  if (playlistService.isRadioMode) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        playlistService.setRadioMode(false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم إيقاف وضع الراديو',
                              style: GoogleFonts.cairo(),
                              textDirection: TextDirection.rtl,
                            ),
                            backgroundColor: Colors.grey,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'إيقاف وضع الراديو',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _toolBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? RecColors.primary(widget.primary, 0.18)
              : RecColors.iconBackground(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? RecColors.primary(widget.primary, 0.35)
                : RecColors.iconBorder(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? widget.primary : RecColors.textHint(context),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isActive ? widget.primary : RecColors.textHint(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ…ط¹ط§ظٹظ†ط© ظ‚ط§ط¦ظ…ط© ط§ظ„طھط´ط؛ظٹظ„ (ظ…طµط؛ظ‘ط±ط©)
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildPlaylistPreview(
      PlaylistService playlist,
      AudioCoordinator coordinator,
      ) {
    final items = playlist.playlist;
    final currentIdx = playlist.currentIndex;

    final start = (currentIdx - 1).clamp(0, items.length - 1);
    final end = (currentIdx + 2).clamp(0, items.length);
    final visible = items.sublist(start, end);
    final startOffset = start;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RecColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RecColors.cardBorder(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ط§ظ„ط¹ظ†ظˆط§ظ†
          Row(
            children: [
              Icon(
                Icons.queue_music_rounded,
                size: 13,
                color: RecColors.textHint(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  playlist.playlistName,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: RecColors.textHint(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _openFullPlaylist(),
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: RecColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ط§ظ„ط¹ظ†ط§طµط±
          ...visible.asMap().entries.map((entry) {
            final idx = startOffset + entry.key;
            final item = entry.value;
            final isCurrent = idx == currentIdx;

            return GestureDetector(
              onTap: () async {
                final playItem = playlist.playAt(idx);
                if (playItem != null) {
                await _playPlaylistItemAndRefresh(playItem);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? RecColors.primary(widget.primary, 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${idx + 1}',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isCurrent
                            ? widget.primary
                            : RecColors.textHint(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight:
                          isCurrent ? FontWeight.w800 : FontWeight.w500,
                          color: isCurrent
                              ? widget.primary
                              : RecColors.textSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent)
                      Icon(
                        Icons.graphic_eq_rounded,
                        size: 14,
                        color: widget.primary,
                      ),
                    if (item.isLocal)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.download_done_rounded,
                          size: 11,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ‚ط§ط¦ظ…ط© ط§ظ„طھط´ط؛ظٹظ„ ط§ظ„ظƒط§ظ…ظ„ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  void _openFullPlaylist() {
    final playlist = context.read<PlaylistService>();
    final coordinator = context.read<AudioCoordinator>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RecColors.cardBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RecColors.textHint(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${playlist.playlistName} • ${playlist.totalItems} تلاوة',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: RecColors.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (playlist.isRadioMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: RecColors.primary(widget.primary, 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🔄 راديو',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: widget.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: playlist.totalItems,
                itemBuilder: (context, i) {
                  final item = playlist.playlist[i];
                  final isCurrent = i == playlist.currentIndex;

                  return GestureDetector(
                    onTap: () async {
                      final playItem = playlist.playAt(i);
                      if (playItem != null) {
                        await _playPlaylistItemAndRefresh(playItem);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? RecColors.primary(widget.primary, 0.12)
                            : RecColors.cardBackground(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? RecColors.primary(widget.primary, 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isCurrent
                                    ? widget.primary
                                    : RecColors.textHint(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: isCurrent
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isCurrent
                                        ? widget.primary
                                        : RecColors.textPrimary(context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  item.subtitle,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    color: RecColors.textHint(context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (item.isLocal)
                            const Icon(
                              Icons.download_done_rounded,
                              size: 13,
                              color: Colors.green,
                            ),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.graphic_eq_rounded,
                              size: 16,
                              color: widget.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // طھط؛ظٹظٹط± ط³ط±ط¹ط© ط§ظ„طھط´ط؛ظٹظ„
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  static const List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  String _getSpeedLabel() {
    if (_currentSpeed == 1.0) return 'سرعة';
    return '${_currentSpeed}x';
  }

  void _changeSpeed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RecColors.cardBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RecColors.textHint(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'سرعة التشغيل',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: RecColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _speeds.map((speed) {
                final isActive = _currentSpeed == speed;
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentSpeed = speed);
                    _activePlayer?.setSpeed(speed);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? RecColors.primary(widget.primary, 0.2)
                          : RecColors.iconBackground(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? RecColors.primary(widget.primary, 0.4)
                            : RecColors.iconBorder(context),
                      ),
                    ),
                    child: Text(
                      '${speed}x',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? widget.primary
                            : RecColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ…ط¤ظ‚طھ ط§ظ„ظ†ظˆظ…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  String _getSleepTimerLabel() {
    if (_sleepTimer == null) return 'مؤقت';
    final remaining = _sleepTimer!.difference(DateTime.now());
    if (remaining.isNegative) return 'مؤقت';
    return '${remaining.inMinutes} د';
  }

  void _openSleepTimer() {
    final durations = [5, 10, 15, 30, 45, 60, 90];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RecColors.cardBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RecColors.textHint(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'مؤقت الإيقاف التلقائي',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: RecColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'سيتوقف التشغيل تلقائياً بعد المدة المحددة',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: RecColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: durations.map((min) {
                return GestureDetector(
                  onTap: () {
                    _setSleepTimer(min);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: RecColors.iconBackground(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: RecColors.iconBorder(context),
                      ),
                    ),
                    child: Text(
                      '$min د',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: RecColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (_sleepTimer != null)
              GestureDetector(
                onTap: () {
                  setState(() => _sleepTimer = null);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إلغاء المؤقت',
                        style: GoogleFonts.cairo(),
                        textDirection: TextDirection.rtl,
                      ),
                      backgroundColor: Colors.grey,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'إلغاء المؤقت الحالي',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _setSleepTimer(int minutes) {
    _sleepTimerTask?.cancel();

    setState(() {
      _sleepTimer = DateTime.now().add(Duration(minutes: minutes));
    });

    _sleepTimerTask = Timer(Duration(minutes: minutes), () {
      if (!mounted) return;

      context.read<RadioIntillegence>().pause();

      setState(() {
        _sleepTimer = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إيقاف التشغيل تلقائياً ⏰',
            style: GoogleFonts.cairo(),
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: widget.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'سيتوقف التشغيل بعد $minutes دقيقة ⏰',
          style: GoogleFonts.cairo(),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: widget.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظ…ط´ط§ط±ظƒط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  void _shareCurrentTrack() {
    final playlist = context.read<PlaylistService>();
    final current = playlist.currentItem;
    final title = current?.title ?? widget.item.title;
    final subtitle = current?.subtitle ?? widget.item.subtitle;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RecColors.cardBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RecColors.textHint(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'مشاركة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: RecColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RecColors.primary(widget.primary, 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: RecColors.primary(widget.primary, 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎧 أستمع الآن إلى:',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: RecColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: RecColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: RecColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم نسخ المعلومات',
                      style: GoogleFonts.cairo(),
                      textDirection: TextDirection.rtl,
                    ),
                    backgroundColor: widget.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.primary,
                      RecColors.primary(widget.primary, 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.copy_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'نسخ المعلومات',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ‚ط³ظ… ط§ظ„طھط­ظ…ظٹظ„
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildDownloadSection(bool isTablet) {
    final itemId =
    ItemDownloadService.itemIdFromRecitationItem(widget.item);

    return Consumer<ItemDownloadService>(
      builder: (_, service, __) {
        final isDownloaded = service.isDownloaded(itemId);
        final localPath = service.getLocalPath(itemId);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // â•گâ•گ ط¥ط°ط§ ط£ظˆظ†ظ„ط§ظٹظ† ظˆط؛ظٹط± ظ…ط­ظ…ظ‘ظ„: ط§ط¹ط±ط¶ ط¯ط¹ظˆط© ظ„ظ„طھط­ظ…ظٹظ„ â•گâ•گ
                if (!widget.isLocal && !isDownloaded) ...[
                  _AudioDownloadInvite(
                    item: widget.item,
                    primary: widget.primary,
                    isTablet: isTablet,
                  ),
                ],

              // â•گâ•گ ظ…ط­ظ…ظ‘ظ„: ط§ط¹ط±ط¶ ظ…ط³ط§ط± ط§ظ„ط­ظپط¸ â•گâ•گ
              if (isDownloaded && localPath != null) ...[
                _buildSavePath(localPath, service, itemId, isTablet),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavePath(
      String localPath,
      ItemDownloadService service,
      String itemId,
      bool isTablet,
      ) {
    final displayPath = _getDisplayPath(localPath);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_rounded,
                color: Colors.green,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'محفوظ في الجهاز',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              FutureBuilder<String>(
                future: service.getFileSize(itemId),
                builder: (_, snap) => Text(
                  snap.data ?? '...',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.green.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  displayPath,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: RecColors.textHint(context),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _confirmDelete(service, itemId),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'حذف',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDisplayPath(String fullPath) {
    final parts = fullPath.split('/');
    if (parts.length > 4) {
      return '.../${parts.sublist(parts.length - 3).join('/')}';
    }
    return fullPath;
  }

  void _confirmDelete(ItemDownloadService service, String itemId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: RecColors.cardBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'حذف التحميل',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            color: RecColors.textPrimary(context),
          ),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'هل تريد حذف "${widget.item.title}" من الجهاز؟',
          style: GoogleFonts.cairo(color: RecColors.textSecondary(context)),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              service.deleteDownload(itemId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط±ط³ط§ظ… ط§ظ„ط®ظ„ظپظٹط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class _PlayerBgPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color gold;
  final List<Color> backgroundColors;

  _PlayerBgPainter({
    required this.progress,
    required this.primary,
    required this.gold,
    required this.backgroundColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        colors: backgroundColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bg,
    );

    final glow = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final x = size.width * (0.2 + 0.6 * sin(phase * 2 * pi + i * 1.3));
      final y = size.height * (0.1 + 0.3 * cos(phase * 2 * pi + i * 1.7));
      final r = 120.0 + 60.0 * sin(phase * pi + i);

      glow.shader = RadialGradient(
        colors: [
          (i.isEven ? primary : gold).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(x, y), radius: r),
      );

      canvas.drawCircle(Offset(x, y), r, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _PlayerBgPainter old) {
    return old.progress != progress ||
        old.primary != primary ||
        old.gold != gold ||
        old.backgroundColors != backgroundColors;
  }
}

class _RecPlayerUiState {
  final bool isPlaying;
  final bool isBuffering;

  const _RecPlayerUiState({
    required this.isPlaying,
    required this.isBuffering,
  });

  @override
  bool operator ==(Object other) {
    return other is _RecPlayerUiState &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering;
  }

  @override
  int get hashCode => Object.hash(isPlaying, isBuffering);
}

class _AudioDownloadInvite extends StatefulWidget {
  final RecitationItem item;
  final Color primary;
  final bool isTablet;

  const _AudioDownloadInvite({
    required this.item,
    required this.primary,
    required this.isTablet,
  });

  @override
  State<_AudioDownloadInvite> createState() => _AudioDownloadInviteState();
}

class _AudioDownloadInviteState extends State<_AudioDownloadInvite> {
  int? _size;

  @override
  void initState() {
    super.initState();
    _loadSize();
  }

  Future<void> _loadSize() async {
    final url = widget.item.audioUrl;
    if (url == null || url.isEmpty) return;

    final size = await VideoSizeService().getSize(url);
    if (mounted && size != null) {
      setState(() => _size = size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_download_rounded,
            color: Colors.blue.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'حمّل للاستماع بدون إنترنت',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'الحجم: ',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.blue.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      _size != null
                          ? VideoSizeService.formatBytes(_size)
                          : 'جاري التحقق...',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RecItemDownloadButton(
            item: widget.item,
            primary: widget.primary,
            isTablet: widget.isTablet,
          ),
        ],
      ),
    );
  }
}