import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../radio/services/Radio_Intillegence.dart';
import '../../radio/services/audio_coordinator.dart';
import '../../radio/services/listening_history_service.dart';
import '../../radio/services/offline_radio_service.dart';
import '../../radio/services/online_surah_service.dart';
import '../../radio/radio_screen.dart';
import '../../radio/models/radio_station.dart';
import '../../radio/data/radio_data.dart';
import '../../radio/widgets/cached_image_widget.dart';
import '../../radio/widgets/radio_image_widget.dart';
import 'home_card_skeleton.dart';

class HomeRadioCard extends StatefulWidget {
  final Color primary;
  final Color gold;
  final Color cardColor;
  final bool isDark;

  const HomeRadioCard({
    super.key,
    required this.primary,
    required this.gold,
    required this.cardColor,
    required this.isDark,
  });

  @override
  State<HomeRadioCard> createState() => _HomeRadioCardState();
}

class _HomeRadioCardState extends State<HomeRadioCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // â•گâ•گ ط¯ظ…ط¬ ط§ظ„ظ€ 3 Selectors ظپظٹ Selector ظˆط§ط­ط¯ â•گâ•گ
  _HomeRadioState _buildState(
    RadioIntillegence online,
    OfflineRadioService offline,
    OnlineSurahService onlineSurah,
  ) {
    if (online.currentStation != null) {
      return _HomeRadioState(
        hasPlayer: true,
        name: online.currentStation!.name,
        category: online.currentStation!.category,
        emoji: online.currentStation!.iconEmoji,
        imageUrl: online.currentStation!.imageUrl,
        isPlaying: online.isPlaying,
        isBuffering: online.isBuffering,
        sourceType: _SourceType.online,
      );
    }
    if (onlineSurah.currentStation != null) {
      return _HomeRadioState(
        hasPlayer: true,
        name: onlineSurah.currentSurahName,
        category: '${onlineSurah.currentStation!.name} • أونلاين',
        emoji: onlineSurah.currentStation!.iconEmoji,
        imageUrl: onlineSurah.currentStation!.imageUrl,
        isPlaying: onlineSurah.isPlaying,
        isBuffering: onlineSurah.isBuffering,
        sourceType: _SourceType.onlineSurah,
      );
    }
    if (offline.currentStation != null) {
      return _HomeRadioState(
        hasPlayer: true,
        name:
            offline.currentSurahName.isNotEmpty
                ? offline.currentSurahName
                : offline.currentStation!.name,
        category: '${offline.currentStation!.name} • أوفلاين',
        emoji: offline.currentStation!.iconEmoji,
        imageUrl: offline.currentStation!.imageUrl,
        isPlaying: offline.isPlaying,
        isBuffering: false,
        sourceType: _SourceType.offline,
      );
    }
    return const _HomeRadioState(
      hasPlayer: false,
      name: '',
      category: '',
      emoji: '📻',
      imageUrl: null,
      isPlaying: false,
      isBuffering: false,
      sourceType: _SourceType.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RadioScreen(primaryColor: widget.primary),
          ),
        );
      },
      // â•گâ•گ Selector3 ظˆط§ط­ط¯ ط¨ط¯ظ„ 3 ظ…طھط¯ط§ط®ظ„ط© â•گâ•گ
      child: Selector3<
        RadioIntillegence,
        OfflineRadioService,
        OnlineSurahService,
        _HomeRadioState
      >(
        selector:
            (_, online, offline, onlineSurah) =>
                _buildState(online, offline, onlineSurah),
        builder: (_, state, __) {
          // â•گâ•گ ط£ظ„ظˆط§ظ† ظ…ط­ط³ظˆط¨ط© ظ…ط±ط© ظˆط§ط­ط¯ط© â•گâ•گ
          final borderColor =
              state.isPlaying
                  ? widget.primary.withValues(alpha: 0.32)
                  : isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06);

          final shadowColor =
              state.isPlaying
                  ? widget.primary.withValues(alpha: isDark ? 0.16 : 0.10)
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDark
                        ? const [Color(0xFF17221F), Color(0xFF101916)]
                        : const [Color(0xFFFFFCF5), Color(0xFFF5F0E4)],
              ),
              border: Border.all(
                color:
                    isDark ? borderColor : widget.gold.withValues(alpha: 0.34),
                width: state.isPlaying ? 1.4 : 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: isDark ? 0.9 : 0.65),
                  blurRadius: state.isPlaying ? 22 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isDark, state),
                _buildSearchRow(isDark),
                if (state.hasPlayer)
                  _buildNowPlaying(isDark, state)
                else
                  const SizedBox(height: 2),
                _buildQuickStations(isDark),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark, _HomeRadioState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.09)
                      : const Color(0xFFE9ECE7),
              shape: BoxShape.circle,
              border: Border.all(color: widget.gold.withValues(alpha: 0.22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: isDark ? Colors.white : const Color(0xFF18362F),
              size: 27,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الراديو والتلاوات',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                    color: isDark ? Colors.white : const Color(0xFF151B21),
                  ),
                ),
                Text(
                  '${RadioStationsData.all.length} محطة - تلاوات وحفلات',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : const Color(0xFF54544F),
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

  Widget _buildSearchRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : const Color(0xFFE9ECE7),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 23,
                    color: isDark ? Colors.white70 : const Color(0xFF173D35),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'البحث',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.09)
                      : const Color(0xFFE9ECE7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tune_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF173D35),
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(bool isDark, _HomeRadioState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.gold.withValues(alpha: isDark ? 0.13 : 0.12),
              isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFFFFDF7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.gold.withValues(alpha: isDark ? 0.34 : 0.52),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          // Portrait on the right and the full existing player controls on
          // the left, matching the reference without removing any action.
          textDirection: TextDirection.rtl,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 52,
                height: 52,
                child: CachedImageWidget(
                  imageUrl: state.imageUrl,
                  borderRadius: BorderRadius.circular(12),
                  errorWidget: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.primary.withValues(alpha: 0.2),
                          widget.gold.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        state.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    state.name,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!state.isBuffering) ...[
                        RepaintBoundary(
                          child: _MiniEqualizer(
                            controller: _animController,
                            color: widget.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          state.isBuffering
                              ? 'جاري التحميل...'
                              : state.category,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _PlayerControls(state: state, primary: widget.primary),
          ],
        ),
      ),
    );
  }

  // â•گâ•گ طھط¨ط³ظٹط· Quick Stations â€” Selector ظˆط§ط­ط¯ ظپظ‚ط· â•گâ•گ
  Widget _buildQuickStations(bool isDark) {
    return Selector<ListeningHistoryService, List<ListeningHistoryItem>>(
      selector: (_, service) => service.history.take(3).toList(),
      shouldRebuild: (prev, next) {
        if (prev.length != next.length) return true;
        if (prev.isEmpty) return false;
        return prev.first.title != next.first.title;
      },
      builder: (_, recentItems, __) {
        if (recentItems.isNotEmpty) {
          return _buildRecentSection(isDark, recentItems);
        }
        return _buildSuggestedSection(isDark);
      },
    );
  }

  Widget _buildRecentSection(bool isDark, List<ListeningHistoryItem> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _sectionLabel('استمعت مؤخرًا', isDark),
          Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _RecentItemTile(
                    item: items[i],
                    primary: widget.primary,
                    gold: widget.gold,
                    isDark: isDark,
                  ),
                ),
                if (i != items.length - 1) const SizedBox(width: 7),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // â•گâ•گ ط§ط³طھط¨ط¯ط§ظ„ Selector ط§ظ„ظ…طھط¯ط§ط®ظ„ ط¨ظ€ Consumer ط¨ط³ظٹط· â•گâ•گ
  Widget _buildSuggestedSection(bool isDark) {
    return Consumer<RadioIntillegence>(
      builder: (_, radio, __) {
        final stations =
            radio.recentStations.isNotEmpty
                ? radio.recentStations.take(3).toList()
                : RadioStationsData.all.take(3).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _sectionLabel('محطات مقترحة', isDark),
              Row(
                children: [
                  for (var i = 0; i < stations.length; i++) ...[
                    Expanded(
                      child: _QuickStationTile(
                        station: stations[i],
                        primary: widget.primary,
                        isDark: isDark,
                      ),
                    ),
                    if (i != stations.length - 1) const SizedBox(width: 7),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white70 : const Color(0xFF24282D),
        ),
      ),
    );
  }
}

// â•گâ•گ ط¨ط§ظ‚ظٹ ط§ظ„ظƒظ„ط§ط³ط§طھ ط¨ط¯ظˆظ† طھط؛ظٹظٹط± â•گâ•گ

class _RecentItemTile extends StatelessWidget {
  final ListeningHistoryItem item;
  final Color primary;
  final Color gold;
  final bool isDark;

  const _RecentItemTile({
    required this.item,
    required this.primary,
    required this.gold,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _playItem(context);
      },
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : gold.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.16 : 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, size: 15, color: primary),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.title,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.timeAgo,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 7.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 31,
                height: 31,
                child: RadioImageWidget(
                  imageUrl: item.imageUrl,
                  imageAsset: item.imageAsset,
                  emoji: item.emoji,
                  primary: primary,
                  size: 31,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (item.type) {
      case 'radio':
        return Colors.red;
      case 'surah':
        return Colors.blue;
      case 'recitation':
        return Colors.purple;
      case 'local':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  void _playItem(BuildContext context) {
    final coordinator = context.read<AudioCoordinator>();
    IslamicRadioStation? station;
    if (item.stationId != null) {
      station = RadioStationsData.byId(item.stationId!);
    }
    station ??= IslamicRadioStation(
      id: item.audioUrl.hashCode.abs(),
      name: item.title,
      nameEn: item.title,
      url: item.audioUrl,
      category: item.type == 'radio' ? 'راديو' : 'تلاوات',
      categoryEn: 'Recitations',
      description: item.subtitle,
      descriptionEn: item.subtitle,
      iconEmoji: item.emoji,
      imageUrl: item.imageUrl,
      imageAsset: item.imageAsset,
    );

    switch (item.type) {
      case 'radio':
        coordinator.playOnlineRadio(station);
        break;
      case 'surah':
        if (item.surahNumber != null) {
          coordinator.playOnlineSurah(
            station: station,
            surahNumber: item.surahNumber!,
          );
        } else {
          coordinator.playOnlineRadio(station);
        }
        break;
      case 'local':
        coordinator.playLocalItem(station: station);
        break;
      default:
        coordinator.playOnlineRadio(station);
    }
  }
}

class _QuickStationTile extends StatelessWidget {
  final IslamicRadioStation station;
  final Color primary;
  final bool isDark;

  const _QuickStationTile({
    required this.station,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<AudioCoordinator>().playOnlineRadio(station);
      },
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : primary.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.16 : 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, size: 15, color: primary),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    station.name,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    station.category,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 7.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 31,
                height: 31,
                child: CachedImageWidget(
                  imageUrl: station.imageUrl,
                  borderRadius: BorderRadius.circular(9),
                  errorWidget: Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withValues(alpha: 0.15),
                          primary.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Text(
                        station.iconEmoji,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerControls extends StatelessWidget {
  final _HomeRadioState state;
  final Color primary;

  const _PlayerControls({required this.state, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlBtn(
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<AudioCoordinator>().playPrevious();
          },
          icon: Icons.skip_previous_rounded,
          size: 30,
          iconSize: 16,
          primary: primary,
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            if (state.isBuffering) return;
            HapticFeedback.mediumImpact();
            context.read<AudioCoordinator>().togglePlayPause();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                state.isBuffering
                    ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        key: ValueKey(state.isPlaying),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
          ),
        ),
        const SizedBox(width: 6),
        _ControlBtn(
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<AudioCoordinator>().playNext();
          },
          icon: Icons.skip_next_rounded,
          size: 30,
          iconSize: 16,
          primary: primary,
        ),
      ],
    );
  }
}

// â•گâ•گ ط²ط± طھط­ظƒظ… ظ…ظڈط¹ط§ط¯ ط§ط³طھط®ط¯ط§ظ…ظ‡ â•گâ•گ
class _ControlBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color primary;

  const _ControlBtn({
    required this.onTap,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: iconSize, color: primary),
      ),
    );
  }
}

class _MiniEqualizer extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _MiniEqualizer({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder:
            (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (i) {
                final phase = controller.value * 2 * pi + i * 0.9;
                final h = 4.0 + 8.0 * ((sin(phase) + 1) / 2);
                return Container(
                  width: 2,
                  height: h,
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  final AnimationController controller;
  const _LiveDot({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final opacity = 0.4 + 0.6 * ((sin(controller.value * 2 * pi) + 1) / 2);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.red.withValues(alpha: opacity * 0.5),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: opacity * 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              Text(
                'LIVE',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
    for (int i = 0; i < 3; i++) {
      final p = (progress + i * 0.33) % 1.0;
      final radius = 12.0 + p * 10.0;
      final opacity = (1.0 - p) * 0.4;
      paint.color = color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.progress != progress;
}

enum _SourceType { none, online, onlineSurah, offline }

class _HomeRadioState {
  final bool hasPlayer;
  final String name;
  final String category;
  final String emoji;
  final String? imageUrl;
  final bool isPlaying;
  final bool isBuffering;
  final _SourceType sourceType;

  const _HomeRadioState({
    required this.hasPlayer,
    required this.name,
    required this.category,
    required this.emoji,
    required this.imageUrl,
    required this.isPlaying,
    required this.isBuffering,
    required this.sourceType,
  });

  @override
  bool operator ==(Object other) =>
      other is _HomeRadioState &&
      other.hasPlayer == hasPlayer &&
      other.name == name &&
      other.category == category &&
      other.isPlaying == isPlaying &&
      other.isBuffering == isBuffering &&
      other.sourceType == sourceType;

  @override
  int get hashCode => Object.hash(
    hasPlayer,
    name,
    category,
    isPlaying,
    isBuffering,
    sourceType,
  );
}
