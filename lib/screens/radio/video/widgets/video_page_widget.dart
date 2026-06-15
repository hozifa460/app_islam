// lib/screens/radio/video/video_page_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../data/recitation_categories_data.dart';
import '../services/video_download_service.dart';
import '../services/video_size_service.dart';

class VideoPageWidget extends StatefulWidget {
  final RecitationSubItem item;
  final Color primary;
  final VideoPlayerController? controller;
  final bool isInitialized;
  final bool isActive;
  final bool showSwipeHint;
  final bool showBottomInfo;

  const VideoPageWidget({
    super.key,
    required this.item,
    required this.primary,
    required this.controller,
    required this.isInitialized,
    required this.isActive,
    this.showSwipeHint = false,
    this.showBottomInfo = true,
  });

  @override
  State<VideoPageWidget> createState() => _VideoPageWidgetState();
}

class _VideoPageWidgetState extends State<VideoPageWidget> {
  bool _showControls = false;
  bool _isCleanMode = false;
  bool _showCleanBar = true;
  bool _isFullscreen = false;
  Timer? _hideTimer;
  Timer? _cleanBarTimer;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onUpdate);

    // âœ… ط£ط¸ظ‡ط± ط§ظ„ط£ط²ط±ط§ط± ط£ظˆظ„ ظ…ط±ط© ط¹ظ†ط¯ ط§ظ„ط¯ط®ظˆظ„
    if (widget.isActive && widget.isInitialized) {
      _showControls = true;
      _startHideTimer();
    }

    // âœ… ط´ط؛ظ‘ظ„ طھظ„ظ‚ط§ط¦ظٹط§ظ‹ ط¨ط¹ط¯ ط¨ظ†ط§ط، ط§ظ„طµظپط­ط©
    _ensureAutoPlayIfNeeded();
  }

  @override
  void didUpdateWidget(covariant VideoPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onUpdate);
      widget.controller?.addListener(_onUpdate);
    }

    // âœ… ط¥ط°ط§ ط§ظ„طµظپط­ط© ط£طµط¨ط­طھ ظ†ط´ط·ط©طŒ ط£ط¸ظ‡ط± ط§ظ„ط£ط²ط±ط§ط± ظ…ط¤ظ‚طھط§ظ‹
    if (widget.isActive && !oldWidget.isActive) {
      setState(() => _showControls = true);
      _startHideTimer();
    }

    // âœ… ط´ط؛ظ‘ظ„ طھظ„ظ‚ط§ط¦ظٹط§ظ‹ ط¹ظ†ط¯ ط§ظ„ط±ط¬ظˆط¹/ط¥ط¹ط§ط¯ط© ط§ظ„ط¨ظ†ط§ط،
    _ensureAutoPlayIfNeeded();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    final c = widget.controller;
    if (c == null) return;

    if (c.value.isPlaying) {
      c.pause();
      setState(() => _showControls = true);
      _hideTimer?.cancel();
    } else {
      c.play();
      _startHideTimer();
    }
  }

  void _toggleControls() {
    if (_isCleanMode) {
      setState(() => _showCleanBar = !_showCleanBar);
      if (_showCleanBar) _startCleanBarTimer();
      return;
    }
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (widget.controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _startCleanBarTimer() {
    _cleanBarTimer?.cancel();
    _cleanBarTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showCleanBar = false);
    });
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleCleanMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isCleanMode = !_isCleanMode;
      _showCleanBar = true;
    });
    if (_isCleanMode) _startCleanBarTimer();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double _btnSize() {
    final w = MediaQuery.of(context).size.shortestSide;
    return w < 360
        ? 38
        : w < 600
        ? 44
        : 52;
  }

  double _playBtnSize() {
    final w = MediaQuery.of(context).size.shortestSide;
    return w < 360
        ? 54
        : w < 600
        ? 64
        : 76;
  }

  double _sideBtnSize() {
    final w = MediaQuery.of(context).size.shortestSide;
    return w < 360
        ? 38
        : w < 600
        ? 44
        : 50;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _cleanBarTimer?.cancel();
    widget.controller?.removeListener(_onUpdate);

    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    super.dispose();
  }

  void _showDownloadSheet() {
    final url = widget.item.videoUrl ?? '';
    if (url.isEmpty) return;
    final videoId = VideoDownloadService.videoIdFromUrl(url);
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => _DownloadSheet(
            item: widget.item,
            primary: widget.primary,
            videoId: videoId,
            videoUrl: url,
          ),
    );
  }

  void _ensureAutoPlayIfNeeded() {
    if (!widget.isActive) return;
    if (widget.controller == null) return;

    // âœ… ط­ط§ظˆظ„ ظپظˆط±ط§ظ‹ ط¨ط¯ظˆظ† ط§ظ†طھط¸ط§ط± frame
    if (widget.isInitialized && !widget.controller!.value.isPlaying) {
      widget.controller!.play();
      return;
    }

    // âœ… ط¥ط°ط§ ظ„ظ… ظٹظƒظ† ط¬ط§ظ‡ط²ط§ظ‹ ط¨ط¹ط¯طŒ ط§ظ†طھط¸ط± ط«ظ… ط­ط§ظˆظ„
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.controller == null) return;
      if (!widget.isInitialized) return;

      if (!widget.controller!.value.isPlaying) {
        widget.controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final ready = widget.isInitialized && c != null;
    final playing = c?.value.isPlaying ?? false;
    final hasError = c?.value.hasError ?? false;
    final pos = c?.value.position ?? Duration.zero;
    final dur = c?.value.duration ?? Duration.zero;
    final sb = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _toggleControls,
      onLongPress: _showDownloadSheet,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (ready && !hasError)
              Center(
                child: AspectRatio(
                  aspectRatio:
                      c!.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9,
                  child: VideoPlayer(c),
                ),
              )
            else if (hasError)
              const Center(
                child: Icon(Icons.error_outline, color: Colors.red, size: 40),
              )
            else
              Center(
                child: CircularProgressIndicator(
                  color: widget.primary,
                  strokeWidth: 2.5,
                ),
              ),

            // â•گâ•گâ•گ Clean Mode â•گâ•گâ•گ
            if (_isCleanMode) ...[
              if (_showCleanBar && ready)
                Positioned(
                  bottom: sb + 10,
                  left: 16,
                  right: 16,
                  child: _Glass(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _slider(c!, pos, dur),
                        _timeRow(pos, dur, playing),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: sb + 60,
                right: 16,
                child: _GlassBtn(
                  size: 32,
                  icon: Icons.visibility_rounded,
                  onTap: _toggleCleanMode,
                ),
              ),
              if (!_showCleanBar) _thinBar(pos, dur),
            ],

            // â•گâ•گâ•گ Normal Mode â•گâ•گâ•گ
            if (!_isCleanMode) ...[
              if (!playing && !_showControls && ready)
                Center(
                  child: _GlassBtn(
                    size: _playBtnSize(),
                    icon: Icons.play_arrow_rounded,
                    iconSize: _playBtnSize() * 0.55,
                    onTap: _togglePlayPause,
                  ),
                ),

              if (_showControls && ready) ...[
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlassBtn(
                        size: _btnSize(),
                        icon: Icons.replay_10_rounded,
                        onTap:
                            () => c!.seekTo(pos - const Duration(seconds: 10)),
                      ),
                      SizedBox(width: _btnSize() * 0.5),
                      _GlassBtn(
                        size: _playBtnSize(),
                        icon:
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                        iconSize: _playBtnSize() * 0.55,
                        onTap: _togglePlayPause,
                      ),
                      SizedBox(width: _btnSize() * 0.5),
                      _GlassBtn(
                        size: _btnSize(),
                        icon: Icons.forward_10_rounded,
                        onTap:
                            () => c!.seekTo(pos + const Duration(seconds: 10)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: _isFullscreen
                      ? MediaQuery.of(context).padding.bottom + 80
                      : sb + 60,
                  left: _isFullscreen ? 60 : 16,
                  right: _isFullscreen ? 80 : 16,
                  child: _Glass(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _slider(c!, pos, dur),
                        _timeRow(pos, dur, null),
                      ],
                    ),
                  ),
                ),
              ],

              if (widget.showBottomInfo && !_isFullscreen) _info(sb),
              if (ready) _sideActions(c!, sb),
              if (!_showControls && ready) _thinBar(pos, dur),

              if (widget.showSwipeHint && !_isFullscreen)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'â†گ ط§ط³ط­ط¨ ظ„ظ„ط¹ظˆط¯ط© ظ„ظ„طµظˆطھ',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _slider(VideoPlayerController c, Duration pos, Duration dur) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        activeTrackColor: widget.primary,
        inactiveTrackColor: Colors.white24,
        thumbColor: widget.primary,
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(
        value:
            dur.inMilliseconds > 0
                ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
                : 0.0,
        onChanged:
            (v) => c.seekTo(
              Duration(milliseconds: (v * dur.inMilliseconds).toInt()),
            ),
      ),
    );
  }

  Widget _timeRow(Duration pos, Duration dur, bool? playing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _fmt(pos),
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
          ),
          if (playing != null)
            GestureDetector(
              onTap: _togglePlayPause,
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          Text(
            _fmt(dur),
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _thinBar(Duration pos, Duration dur) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: LinearProgressIndicator(
        value:
            dur.inMilliseconds > 0
                ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
                : 0.0,
        backgroundColor: Colors.white12,
        valueColor: AlwaysStoppedAnimation(widget.primary),
        minHeight: 2.5,
      ),
    );
  }

  Widget _info(double sb) {
    return Positioned(
      bottom: _isFullscreen
          ? MediaQuery.of(context).padding.bottom + 10
          : sb + 20,
      left: _isFullscreen ? 60 : 16,
      right: _isFullscreen ? 100 : 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.item.title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: const [Shadow(blurRadius: 10, color: Colors.black87)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.item.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.item.subtitle,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.white70,
                shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sideActions(VideoPlayerController c, double sb) {
    final s = _sideBtnSize();
    final vid = VideoDownloadService.videoIdFromUrl(widget.item.videoUrl ?? '');

    return Positioned(
      right: _isFullscreen ? 20 : 12,
      bottom: _isFullscreen
          ? MediaQuery.of(context).padding.bottom + 30
          : sb + 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SideBtn(
            size: s,
            icon:
                _isFullscreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
            label: _isFullscreen ? 'طھطµط؛ظٹط±' : 'طھظƒط¨ظٹط±',
            onTap: _toggleFullscreen,
          ),
          const SizedBox(height: 14),
          _SideBtn(
            size: s,
            icon: Icons.visibility_off_rounded,
            label: 'ط®ط§ظ„ظٹط©',
            onTap: _toggleCleanMode,
          ),
          const SizedBox(height: 14),
          _SideBtn(
            size: s,
            icon:
                c.value.volume > 0
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
            label: c.value.volume > 0 ? 'طµظˆطھ' : 'ظƒطھظ…',
            onTap: () {
              HapticFeedback.selectionClick();
              c.setVolume(c.value.volume > 0 ? 0 : 1);
            },
          ),
          const SizedBox(height: 14),
          Consumer<VideoDownloadService>(
            builder: (_, dl, __) {
              final st = dl.getStatus(vid);
              final pr = dl.getProgress(vid);
              if (st == VideoDownloadStatus.downloaded) {
                return _SideBtn(
                  size: s,
                  icon: Icons.download_done_rounded,
                  label: 'ظ…ط­ظ…ظ‘ظ„',
                  color: Colors.green,
                  onTap: _showDownloadSheet,
                );
              }
              if (st == VideoDownloadStatus.downloading) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: s,
                      height: s,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: pr > 0 ? pr : null,
                            strokeWidth: 2.5,
                            color: Colors.orange,
                          ),
                          GestureDetector(
                            onTap: () => dl.cancelDownload(vid),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(pr * 100).toInt()}%',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                );
              }
              return _SideBtn(
                size: s,
                icon: Icons.download_rounded,
                label: 'طھط­ظ…ظٹظ„',
                onTap: _showDownloadSheet,
              );
            },
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// Download Sheet
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _DownloadSheet extends StatefulWidget {
  final RecitationSubItem item;
  final Color primary;
  final String videoId;
  final String videoUrl;
  const _DownloadSheet({
    required this.item,
    required this.primary,
    required this.videoId,
    required this.videoUrl,
  });
  @override
  State<_DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<_DownloadSheet> {
  int? _size;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await VideoSizeService().getSize(widget.videoUrl);
    if (mounted)
      setState(() {
        _size = s;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Consumer<VideoDownloadService>(
        builder: (_, dl, __) {
          final st = dl.getStatus(widget.videoId);
          final pr = dl.getProgress(widget.videoId);
          final lp = dl.getLocalPath(widget.videoId);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.item.title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.storage_rounded,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ط§ظ„ط­ط¬ظ…:',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                        const Spacer(),
                        _loading
                            ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: widget.primary,
                              ),
                            )
                            : Text(
                              _size != null
                                  ? VideoSizeService.formatBytes(_size)
                                  : 'ط؛ظٹط± ظ…ط¹ط±ظˆظپ',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: widget.primary,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (st == VideoDownloadStatus.downloading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pr > 0 ? pr : null,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(widget.primary),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 8),
                _btn('ط¥ظ„ط؛ط§ط،', Icons.close_rounded, Colors.red, () {
                  dl.cancelDownload(widget.videoId);
                  Navigator.pop(context);
                }),
              ] else if (st == VideoDownloadStatus.downloaded) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'طھظ… ط§ظ„طھط­ظ…ظٹظ„ âœ“',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _btn('ط­ط°ظپ', Icons.delete_rounded, Colors.red, () {
                  dl.deleteDownload(widget.videoId);
                  Navigator.pop(context);
                }),
              ] else
                _btn(
                  'طھط­ظ…ظٹظ„ ط§ظ„ظپظٹط¯ظٹظˆ',
                  Icons.download_rounded,
                  widget.primary,
                  () {
                    dl.downloadVideo(
                      videoUrl: widget.videoUrl,
                      title: widget.item.title,
                    );
                    Navigator.pop(context);
                  },
                  filled: true,
                ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          );
        },
      ),
    );
  }

  Widget _btn(
    String l,
    IconData i,
    Color c,
    VoidCallback t, {
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: t,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient:
              filled ? LinearGradient(colors: [c, c.withValues(alpha: 0.8)]) : null,
          color: filled ? null : c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: filled ? Colors.white : c, size: 20),
            const SizedBox(width: 8),
            Text(
              l,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _GlassBtn extends StatelessWidget {
  final double size;
  final IconData icon;
  final double? iconSize;
  final VoidCallback onTap;
  const _GlassBtn({
    required this.size,
    required this.icon,
    this.iconSize,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: iconSize ?? size * 0.5),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final Widget child;
  const _Glass({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}

class _SideBtn extends StatelessWidget {
  final double size;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SideBtn({
    required this.size,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
              ],
            ),
            child: Icon(icon, color: color ?? Colors.white, size: size * 0.48),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: color ?? Colors.white70,
              shadows: const [Shadow(blurRadius: 6, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }
}
