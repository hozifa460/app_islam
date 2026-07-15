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
        name: offline.currentSurahName.isNotEmpty
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
      child: Selector3<RadioIntillegence, OfflineRadioService,
          OnlineSurahService, _HomeRadioState>(
        selector: (_, online, offline, onlineSurah) =>
            _buildState(online, offline, onlineSurah),
        builder: (_, state, __) {
          // â•گâ•گ ط£ظ„ظˆط§ظ† ظ…ط­ط³ظˆط¨ط© ظ…ط±ط© ظˆط§ط­ط¯ط© â•گâ•گ
          final borderColor = state.isPlaying
              ? widget.primary.withValues(alpha: 0.32)
              : isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06);

          final shadowColor = state.isPlaying
              ? widget.primary.withValues(alpha: isDark ? 0.16 : 0.10)
              : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: state.isPlaying
                    ? [
                  widget.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                  widget.gold.withValues(alpha: isDark ? 0.10 : 0.06),
                  widget.primary.withValues(alpha: isDark ? 0.08 : 0.04),
                ]
                    : [
                  isDark
                      ? const Color(0xFF111827)
                      : Colors.white,
                  isDark
                      ? const Color(0xFF111827).withValues(alpha: 0.96)
                      : Colors.white.withValues(alpha: 0.98),
                ],
              ),
              border: Border.all(
                color: borderColor,
                width: state.isPlaying ? 1.3 : 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: state.isPlaying ? 18 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isDark, state),
                if (state.hasPlayer && state.isPlaying)
                  _buildNowPlaying(isDark, state)
                else
                  _buildQuickStations(isDark),
                const SizedBox(height: 6),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark, _HomeRadioState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.primary, widget.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: widget.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.radio_rounded, color: Colors.white, size: 22),
                if (state.isPlaying)
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (_, __) => CustomPaint(
                        size: const Size(44, 44),
                        painter: _WavePainter(
                          progress: _animController.value,
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isPlaying ? 'يستمع الآن' : 'الراديو والتلاوات',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                Row(
                  children: [
                    if (state.isPlaying) ...[
                      _LiveDot(controller: _animController),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        state.isPlaying
                            ? state.category
                            : '${RadioStationsData.all.length} محطة • تلاوات وحفلات',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: state.isPlaying
                              ? widget.primary
                              : isDark
                              ? Colors.white54
                              : Colors.black45,
                          fontWeight: state.isPlaying
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: widget.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(bool isDark, _HomeRadioState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.primary.withValues(alpha: isDark ? 0.10 : 0.06),
              widget.gold.withValues(alpha: isDark ? 0.05 : 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.primary.withValues(alpha: isDark ? 0.14 : 0.10),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: CachedImageWidget(
                  imageUrl: state.imageUrl,
                  borderRadius: BorderRadius.circular(12),
                  errorWidget: Container(
                    width: 48,
                    height: 48,
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
                      child: Text(state.emoji,
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.name,
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

  Widget _buildRecentSection(
      bool isDark, List<ListeningHistoryItem> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('آخر ما استمعت إليه', isDark),
          ...items.map((item) => _RecentItemTile(
            item: item,
            primary: widget.primary,
            gold: widget.gold,
            isDark: isDark,
          )),
        ],
      ),
    );
  }

  // â•گâ•گ ط§ط³طھط¨ط¯ط§ظ„ Selector ط§ظ„ظ…طھط¯ط§ط®ظ„ ط¨ظ€ Consumer ط¨ط³ظٹط· â•گâ•گ
  Widget _buildSuggestedSection(bool isDark) {
    return Consumer<RadioIntillegence>(
      builder: (_, radio, __) {
        final stations = radio.recentStations.isNotEmpty
            ? radio.recentStations.take(3).toList()
            : RadioStationsData.all.take(3).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('محطات مقترحة', isDark),
              ...stations.map((s) => _QuickStationTile(
                station: s,
                primary: widget.primary,
                isDark: isDark,
              )),
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
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white38 : Colors.black38,
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
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 36,
                height: 36,
                child: RadioImageWidget(
                  imageUrl: item.imageUrl,
                  imageAsset: item.imageAsset,
                  emoji: item.emoji,
                  primary: primary,
                  size: 36,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: _typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.typeLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: _typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.timeAgo,
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, size: 16, color: primary),
            ),
          ],
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (item.type) {
      case 'radio':      return Colors.red;
      case 'surah':      return Colors.blue;
      case 'recitation': return Colors.purple;
      case 'local':      return Colors.green;
      default:           return Colors.orange;
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
              station: station, surahNumber: item.surahNumber!);
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
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 36,
                height: 36,
                child: CachedImageWidget(
                  imageUrl: station.imageUrl,
                  borderRadius: BorderRadius.circular(10),
                  errorWidget: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withValues(alpha: 0.15),
                          primary.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(station.iconEmoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    station.category,
                    style: GoogleFonts.cairo(
                      fontSize: 9,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, size: 16, color: primary),
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
            child: state.isBuffering
                ? const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
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
        builder: (_, __) => Row(
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
        final opacity =
            0.4 + 0.6 * ((sin(controller.value * 2 * pi) + 1) / 2);
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
    final paint = Paint()
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
      hasPlayer, name, category, isPlaying, isBuffering, sourceType);
}