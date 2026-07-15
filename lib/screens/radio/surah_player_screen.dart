// lib/screens/radio/surah_player_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/radio_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/models/downloadable_item.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_app_bar.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_controls.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_extra_controls.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_mode_badge.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_offline_playlist.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_online_info.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_options_sheet.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_progress_bar.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_surah_info.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/sp_surah_info_dialog.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_album_art.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_animations.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_background.dart';
import 'package:provider/provider.dart';
import 'data/quran_data.dart';
import 'data/recitation_categories_data.dart';
import 'models/radio_station.dart';
import 'models/surah_model.dart';

class SurahPlayerScreen extends StatefulWidget {
  final IslamicRadioStation station;
  final int surahNumber;
  final Color primary;
  final bool isOnline;

  const SurahPlayerScreen({
    super.key,
    required this.station,
    required this.surahNumber,
    required this.primary,
    this.isOnline = false,
  });

  @override
  State<SurahPlayerScreen> createState() => _SurahPlayerScreenState();
}

class _SurahPlayerScreenState extends State<SurahPlayerScreen>
    with TickerProviderStateMixin {
  final SpAnimationHelper _animHelper = SpAnimationHelper();

  late SurahModel _surah;
  bool _isInitialized = false;

  // âœ… Cache ط§ظ„ظ€ itemId ظ„طھط¬ظ†ط¨ ط¥ط¹ط§ط¯ط© ط§ظ„ط­ط³ط§ط¨
  late final String? _surahUrl;
  late final String? _itemId;
  late final RecitationItem? _tempItem;

  @override
  void initState() {
    super.initState();

    try {
      _surah = QuranData.surahByNumber(widget.surahNumber);
    } catch (_) {
      _surah = QuranData.surahs.first;
    }

    // âœ… ط­ط³ط§ط¨ ظ…ط±ط© ظˆط§ط­ط¯ط©
    _surahUrl = widget.station.surahStreamUrl(widget.surahNumber);
    if (_surahUrl != null) {
      _tempItem = RecitationItem(
        title: _surah.name,
        subtitle: widget.station.name,
        emoji: widget.station.iconEmoji,
        audioUrl: _surahUrl!,
        imageUrl: widget.station.imageUrl,
      );
      _itemId = ItemDownloadService.itemIdFromRecitationItem(_tempItem!);
    } else {
      _tempItem = null;
      _itemId = null;
    }

    _animHelper.init(this);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (!mounted) return;

    final radio = context.read<RadioIntillegence>();
    final currentUrl = radio.currentStation?.url;
    final expectedUrl = widget.isOnline ? (_surahUrl ?? '') : currentUrl;

    if (currentUrl != null &&
        expectedUrl != null &&
        expectedUrl.isNotEmpty &&
        currentUrl == expectedUrl) {
      if (mounted) setState(() => _isInitialized = true);
      return;
    }

    final coordinator = context.read<AudioCoordinator>();

    if (widget.isOnline) {
      await coordinator.playSurahTrack(
        station: widget.station,
        surahNumber: widget.surahNumber,
        isLocal: false,
      );
    } else {
      String? localPath;
      if (_itemId != null) {
        localPath =
            context.read<ItemDownloadService>().getLocalPath(_itemId!);
      }

      await coordinator.playSurahTrack(
        station: widget.station,
        surahNumber: widget.surahNumber,
        isLocal: true,
        localPath: localPath,
      );
    }

    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _animHelper.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause(AudioCoordinator c) async {
    widget.isOnline
        ? await c.onlineSurah.togglePlayPause()
        : await c.offlineRadio.togglePlayPause();
  }

  Future<void> _playNext(AudioCoordinator c) async {
    widget.isOnline
        ? await c.onlineSurah.playNext()
        : await c.offlineRadio.playNext();
  }

  Future<void> _playPrevious(AudioCoordinator c) async {
    widget.isOnline
        ? await c.onlineSurah.playPrevious()
        : await c.offlineRadio.playPrevious();
  }

  void _downloadCurrentSurah() {
    if (_itemId == null || _tempItem == null) return;

    final downloadService = context.read<ItemDownloadService>();

    final stationDir = widget.station.name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    final surahFile = _surah.name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    downloadService.downloadItem(
      _tempItem!,
      customDir: stationDir,
      customFileName: surahFile,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'جاري تحميل سورة ${_surah.name}... ✓',
          style: GoogleFonts.cairo(),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: widget.primary,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // â•گâ•گ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گ
            Positioned.fill(
              child: RepaintBoundary(
                child: SpBackground(
                  controller: _animHelper.bgController,
                  primary: widget.primary,
                  isDark: isDark,
                ),
              ),
            ),

            // â•گâ•گ ط§ظ„ظ…ط­طھظˆظ‰ â•گâ•گ
            SafeArea(
              child: _PlayerContent(
                station: widget.station,
                surah: _surah,
                primary: widget.primary,
                isOnline: widget.isOnline,
                isTablet: isTablet,
                isDark: isDark,
                animHelper: _animHelper,
                itemId: _itemId,
                tempItem: _tempItem,
                onDownload: widget.isOnline ? _downloadCurrentSurah : null,
                onNext: _playNext,
                onPrevious: _playPrevious,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… Widget ظ…ط³طھظ‚ظ„ ظ„ظ„ظ…ط­طھظˆظ‰ - ظٹظ‚ظ„ظ„ ط¥ط¹ط§ط¯ط© ط¨ظ†ط§ط، ط§ظ„ظ€ Stack
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _PlayerContent extends StatelessWidget {
  final IslamicRadioStation station;
  final SurahModel surah;
  final Color primary;
  final bool isOnline;
  final bool isTablet;
  final bool isDark;
  final SpAnimationHelper animHelper;
  final String? itemId;
  final RecitationItem? tempItem;
  final VoidCallback? onDownload;
  final Future<void> Function(AudioCoordinator) onNext;
  final Future<void> Function(AudioCoordinator) onPrevious;

  const _PlayerContent({
    required this.station,
    required this.surah,
    required this.primary,
    required this.isOnline,
    required this.isTablet,
    required this.isDark,
    required this.animHelper,
    required this.itemId,
    required this.tempItem,
    required this.onDownload,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // â•گâ•گ AppBar - ط«ط§ط¨طھ ظ„ط§ ظٹطھط؛ظٹط± â•گâ•گ
        _StaticAppBar(
          station: station,
          surah: surah,
          primary: primary,
          isOnline: isOnline,
          isDark: isDark,
          isTablet: isTablet,
          onDownload: onDownload,
        ),

        const Spacer(),

        // â•گâ•گ ط¨ط§ط¯ط¬ ط§ظ„ظˆط¶ط¹ â•گâ•گ
        SpModeBadge(
          isOnline: isOnline,
          primary: primary,
          onDownload: onDownload,
        ),

        const SizedBox(height: 16),

        // â•گâ•گ ط؛ظ„ط§ظپ ط§ظ„ط£ظ„ط¨ظˆظ… - ظٹطھط­ط¯ط« ظ…ط¹ isPlaying ظپظ‚ط· â•گâ•گ
        _AlbumArtSection(
          animHelper: animHelper,
          surah: surah,
          primary: primary,
          isTablet: isTablet,
          stationEmoji: station.iconEmoji,
          isOnline: isOnline,
        ),

        const SizedBox(height: 28),

        // â•گâ•گ ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ط³ظˆط±ط© â•گâ•گ
        SpSurahInfo(
          surah: surah,
          isDark: isDark,
          isTablet: isTablet,
          isLooping: false,
          primary: primary,
          onToggleLoop: () {},
        ),

        const SizedBox(height: 20),

        // â•گâ•گ ط´ط±ظٹط· ط§ظ„طھظ‚ط¯ظ… - ظٹطھط­ط¯ط« ط¨ط´ظƒظ„ ظ…ط³طھظ‚ظ„ â•گâ•گ
        _ProgressSection(
          primary: primary,
          isDark: isDark,
          isTablet: isTablet,
          isOnline: isOnline,
        ),

        const SizedBox(height: 18),

        // â•گâ•گ ط£ط²ط±ط§ط± ط§ظ„طھط­ظƒظ… â•گâ•گ
        _ControlsSection(
          primary: primary,
          isDark: isDark,
          isTablet: isTablet,
          isOnline: isOnline,
          station: station,
          onNext: onNext,
          onPrevious: onPrevious,
        ),

        const SizedBox(height: 14),

        // â•گâ•گ ط£ط²ط±ط§ط± ط¥ط¶ط§ظپظٹط© â•گâ•گ
        SpExtraControls(
          isDark: isDark,
          isTablet: isTablet,
          isOnline: isOnline,
          primary: primary,
          onDownload: onDownload,
          onShowInfo: () => SpSurahInfoDialog.show(
            context: context,
            surah: surah,
            isDark: isDark,
            primary: primary,
            isOnline: isOnline,
          ),
          onRadioMode: null,
        ),

        // â•گâ•گ ظ‚ط³ظ… ط§ظ„طھط­ظ…ظٹظ„ â•گâ•گ
        if (itemId != null)
          _DownloadSectionWidget(
            surah: surah,
            station: station,
            primary: primary,
            isDark: isDark,
            isOnline: isOnline,
            itemId: itemId!,
            tempItem: tempItem!,
            onDownload: onDownload,
          ),

        const Spacer(),

        // â•گâ•گ Playlist / Online Info â•گâ•گ
        if (!isOnline)
          Consumer<AudioCoordinator>(
            builder: (_, coordinator, __) => SpOfflinePlaylist(
              isDark: isDark,
              isTablet: isTablet,
              primary: primary,
              station: station,
              currentSurah: surah,
              onPlaySurah: (num) => coordinator.playSurahTrack(
                station: station,
                surahNumber: num,
                isLocal: true,
              ),
            ),
          )
        else
          SpOnlineInfo(isDark: isDark, isTablet: isTablet),

        const SizedBox(height: 16),
      ],
    );
  }
}

// â•گâ•گ AppBar ط«ط§ط¨طھ â•گâ•گ
class _StaticAppBar extends StatelessWidget {
  final IslamicRadioStation station;
  final SurahModel surah;
  final Color primary;
  final bool isOnline;
  final bool isDark;
  final bool isTablet;
  final VoidCallback? onDownload;

  const _StaticAppBar({
    required this.station,
    required this.surah,
    required this.primary,
    required this.isOnline,
    required this.isDark,
    required this.isTablet,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return SpAppBar(
      isDark: isDark,
      isTablet: isTablet,
      isOnline: isOnline,
      stationName: station.name,
      onBack: () => Navigator.pop(context),
      onOptions: () => SpOptionsSheet.show(
        context: context,
        isDark: isDark,
        isOnline: isOnline,
        surah: surah,
        primary: primary,
        onRestart: () async =>
            context.read<RadioIntillegence>().player.seek(Duration.zero),
        onDownload: isOnline ? onDownload : null,
      ),
    );
  }
}

// â•گâ•گ Album Art - ظٹط±ط§ظ‚ط¨ isPlaying ظپظ‚ط· â•گâ•گ
class _AlbumArtSection extends StatelessWidget {
  final SpAnimationHelper animHelper;
  final SurahModel surah;
  final Color primary;
  final bool isTablet;
  final String stationEmoji;
  final bool isOnline;

  const _AlbumArtSection({
    required this.animHelper,
    required this.surah,
    required this.primary,
    required this.isTablet,
    required this.stationEmoji,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    // âœ… Selector ظٹط±ط§ظ‚ط¨ isPlaying ظپظ‚ط·
    return Selector<RadioIntillegence, bool>(
      selector: (_, r) => r.isPlaying,
      builder: (_, isPlaying, __) => SpAlbumArt(
        albumArtController: animHelper.albumArtController,
        equalizerController: animHelper.equalizerController,
        surah: surah,
        isPlaying: isPlaying,
        isTablet: isTablet,
        primary: primary,
        stationEmoji: stationEmoji,
      ),
    );
  }
}

// â•گâ•گ Progress Bar - ظٹط±ط§ظ‚ط¨ position ظˆ duration ظپظ‚ط· â•گâ•گ
class _ProgressSection extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final bool isTablet;
  final bool isOnline;

  const _ProgressSection({
    required this.primary,
    required this.isDark,
    required this.isTablet,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    // âœ… Selector ظٹط±ط§ظ‚ط¨ position ظˆ duration ظپظ‚ط·
    return Selector<RadioIntillegence, ({Duration position, Duration duration})>(
      selector: (_, r) => (
      position: r.player.position,
      duration: r.player.duration ?? Duration.zero,
      ),
      builder: (_, data, __) => SpProgressBar(
        position: data.position,
        duration: data.duration,
        isDark: isDark,
        isTablet: isTablet,
        isOnline: isOnline,
        primary: primary,
        onSeek: (pos) async =>
            context.read<RadioIntillegence>().player.seek(pos),
      ),
    );
  }
}

// â•گâ•گ Controls - ظٹط±ط§ظ‚ط¨ isPlaying ظˆ isLoading ظپظ‚ط· â•گâ•گ
class _ControlsSection extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final bool isTablet;
  final bool isOnline;
  final IslamicRadioStation station;
  final Future<void> Function(AudioCoordinator) onNext;
  final Future<void> Function(AudioCoordinator) onPrevious;

  const _ControlsSection({
    required this.primary,
    required this.isDark,
    required this.isTablet,
    required this.isOnline,
    required this.station,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<RadioIntillegence,
        ({bool isPlaying, bool isLoading, Duration position, Duration duration})>(
      selector: (_, r) => (
      isPlaying: r.isPlaying,
      isLoading: r.isLoading || r.isBuffering,
      position: r.player.position,
      duration: r.player.duration ?? Duration.zero,
      ),
      builder: (_, data, __) {
        final coordinator = context.read<AudioCoordinator>();
        return SpControls(
          isPlaying: data.isPlaying,
          isLoading: data.isLoading,
          isDark: isDark,
          isTablet: isTablet,
          primary: primary,
          position: data.position,
          duration: data.duration,
          onTogglePlayPause: () async =>
              context.read<RadioIntillegence>().togglePlayPause(),
          onNext: () async => onNext(coordinator),
          onPrevious: () async => onPrevious(coordinator),
          onSeek: (pos) async =>
              context.read<RadioIntillegence>().player.seek(pos),
        );
      },
    );
  }
}

// â•گâ•گ Download Section - ظٹط±ط§ظ‚ط¨ ط­ط§ظ„ط© ط§ظ„طھط­ظ…ظٹظ„ ظپظ‚ط· â•گâ•گ
class _DownloadSectionWidget extends StatelessWidget {
  final SurahModel surah;
  final IslamicRadioStation station;
  final Color primary;
  final bool isDark;
  final bool isOnline;
  final String itemId;
  final RecitationItem tempItem;
  final VoidCallback? onDownload;

  const _DownloadSectionWidget({
    required this.surah,
    required this.station,
    required this.primary,
    required this.isDark,
    required this.isOnline,
    required this.itemId,
    required this.tempItem,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ItemDownloadService,
        ({bool isDownloaded, bool isDownloading, double progress, String? localPath})>(
      selector: (_, service) => (
      isDownloaded: service.isDownloaded(itemId),
      isDownloading:
      service.getStatus(itemId) == ItemDownloadStatus.downloading,
      progress: service.getProgress(itemId),
      localPath: service.getLocalPath(itemId),
      ),
      builder: (_, state, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOnline && !state.isDownloaded && !state.isDownloading)
                _DownloadInviteCard(
                  surahName: surah.name,
                  stationName: station.name,
                  onDownload: onDownload,
                ),

              if (state.isDownloading)
                _DownloadProgressCard(
                  surahName: surah.name,
                  progress: state.progress,
                  onCancel: () => context
                      .read<ItemDownloadService>()
                      .cancelDownload(itemId),
                ),

              if (state.isDownloaded && state.localPath != null)
                _SavePathCard(
                  surahName: surah.name,
                  localPath: state.localPath!,
                  isDark: isDark,
                  itemId: itemId,
                ),
            ],
          ),
        );
      },
    );
  }
}

// â•گâ•گ Download Invite â•گâ•گ
class _DownloadInviteCard extends StatelessWidget {
  final String surahName;
  final String stationName;
  final VoidCallback? onDownload;

  const _DownloadInviteCard({
    required this.surahName,
    required this.stationName,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: isDark ? 0.08 : 0.06),
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
                  'حمّل سورة $surahName للاستماع بدون إنترنت',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'ستُحفظ في: تلاوات/$stationName/',
                  style: GoogleFonts.cairo(
                    fontSize: 9,
                    color: Colors.blue.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDownload,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: Colors.blue.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.download_rounded,
                      size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'تحميل',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
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
}

// â•گâ•گ Download Progress â•گâ•گ
class _DownloadProgressCard extends StatelessWidget {
  final String surahName;
  final double progress;
  final VoidCallback onCancel;

  const _DownloadProgressCard({
    required this.surahName,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.downloading_rounded,
                  size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'جاري تحميل سورة $surahName...',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCancel,
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              backgroundColor: Colors.orange.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(Colors.orange),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گ Save Path Card â•گâ•گ
class _SavePathCard extends StatelessWidget {
  final String surahName;
  final String localPath;
  final bool isDark;
  final String itemId;

  const _SavePathCard({
    required this.surahName,
    required this.localPath,
    required this.isDark,
    required this.itemId,
  });

  String _getDisplayPath(String fullPath) {
    final parts = fullPath.split('/');
    if (parts.length > 4) {
      return '.../${parts.sublist(parts.length - 3).join('/')}';
    }
    return fullPath;
  }

  @override
  Widget build(BuildContext context) {
    final displayPath = _getDisplayPath(localPath);
    final service = context.read<ItemDownloadService>();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_rounded,
                  color: Colors.green, size: 14),
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
              // âœ… FutureBuilder ظ…ظ†ظپطµظ„
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
                    fontSize: 9,
                    color: isDark ? Colors.white38 : Colors.black38,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _confirmDelete(context, service),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_rounded,
                          color: Colors.red, size: 12),
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

  void _confirmDelete(
      BuildContext context, ItemDownloadService service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
        isDark ? const Color(0xFF1A2820) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          'حذف التحميل',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'هل تريد حذف سورة $surahName من الجهاز؟',
          style: GoogleFonts.cairo(
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              service.deleteDownload(itemId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
}