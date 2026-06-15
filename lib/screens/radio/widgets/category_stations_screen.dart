// lib/screens/radio/category_stations_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets/modern_bottom_player.dart';
import 'package:islamic_app/screens/radio/widgets/station_image_widget.dart';
import 'package:islamic_app/screens/radio/widgets/station_live_badge_widget.dart';
import 'package:provider/provider.dart';

import '../models/radio_station.dart';
import '../services/Radio_Intillegence.dart';
import '../services/audio_coordinator.dart';

class CategoryStationsScreen extends StatefulWidget {
  final String category;
  final String categoryIcon;
  final List<IslamicRadioStation> stations;
  final Color primaryColor;

  const CategoryStationsScreen({
    super.key,
    required this.category,
    required this.categoryIcon,
    required this.stations,
    required this.primaryColor,
  });

  @override
  State<CategoryStationsScreen> createState() => _CategoryStationsScreenState();
}

class _CategoryStationsScreenState extends State<CategoryStationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _equalizerController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _showSearch = false;

  static const Color _gold = Color(0xFFC8A44D);

  static const Map<String, List<Color>> _catColors = {
    'ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ…': [Color(0xFF2D1B69), Color(0xFF7C3AED)],
    'ط§ظ„ط­ط±ظ…ظٹظ† ط§ظ„ط´ط±ظٹظپظٹظ†': [Color(0xFF1A3A2A), Color(0xFF16A34A)],
    'ط¥ط°ط§ط¹ط§طھ ط±ط³ظ…ظٹط©': [Color(0xFF1E3A5F), Color(0xFF2563EB)],
    'طھظپط³ظٹط± ظˆط¹ظ„ظˆظ…': [Color(0xFF3B1F00), Color(0xFFC2700C)],
    'ط±ظ‚ظٹط© ظˆط£ط¯ط¹ظٹط©': [Color(0xFF2D1A3A), Color(0xFF9333EA)],
    'طھظ„ط§ظˆط§طھ ط®ط§ط´ط¹ط©': [Color(0xFF1A1A2E), Color(0xFF6366F1)],
    'طھط±ط¬ظ…ط§طھ ط§ظ„ظ‚ط±ط¢ظ†': [Color(0xFF064E3B), Color(0xFF059669)],
  };

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _equalizerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<IslamicRadioStation> get _filteredStations {
    if (_searchQuery.trim().isEmpty) return widget.stations;

    final q = _searchQuery.trim();
    return widget.stations.where((s) {
      return s.name.contains(q) ||
          s.description.contains(q) ||
          s.category.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    final isTablet = size.width > 600;

    final crossCount = isTablet ? 3 : 2;
    const spacing = 12.0;
    const px = 16.0;

    final cardW =
        (size.width - px * 2 - spacing * (crossCount - 1)) / crossCount;
    final imgH = (size.height * 0.16).clamp(90.0, 200.0);
    const textH = 65.0;
    final cardH = imgH + textH;
    final ratio = cardW / cardH;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080C18),
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (_, __) => CustomPaint(
                    painter: _CatBgPainter(
                      progress: _bgController.value,
                      primary: widget.primaryColor,
                      gold: _gold,
                    ),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                SizedBox(height: safePadding.top),
                _buildAppBar(isTablet),

                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _showSearch
                      ? _buildSearchField(px)
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: _filteredStations.isEmpty
                      ? _buildEmpty()
                      : GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      px,
                      4,
                      px,
                      110 + safePadding.bottom,
                    ),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: ratio,
                    ),
                    itemCount: _filteredStations.length,
                    itemBuilder: (_, i) => RepaintBoundary(
                      child: _CategoryStationCard(
                        station: _filteredStations[i],
                        primary: widget.primaryColor,
                        gold: _gold,
                        isTablet: isTablet,
                        equalizerController: _equalizerController,
                        catColors: _catColors,
                        imgH: imgH,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Selector<AudioCoordinator, bool>(
                selector: (_, c) => c.hasActivePlayer,
                builder: (_, hasPlayer, __) {
                  if (!hasPlayer) return const SizedBox.shrink();

                  return ModernBottomPlayer(
                    primary: widget.primaryColor,
                    isTablet: isTablet,
                    safePadding: safePadding,
                    equalizerController: _equalizerController,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.categoryIcon} ${widget.category}',
                  style: GoogleFonts.cairo(
                    fontSize: isTablet ? 20 : 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.stations.length} ظ…ط­ط·ط©',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showSearch
                    ? widget.primaryColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _showSearch
                      ? widget.primaryColor.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                _showSearch ? Icons.close_rounded : Icons.search_rounded,
                color: _showSearch ? widget.primaryColor : Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(double px) {
    return Padding(
      padding: EdgeInsets.fromLTRB(px, 0, px, 8),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.primaryColor.withValues(alpha: 0.2)),
        ),
        child: TextField(
          controller: _searchController,
          textDirection: TextDirection.rtl,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'ط§ط¨ط­ط«...',
            hintStyle: GoogleFonts.cairo(
              color: Colors.white38,
              fontSize: 12,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: widget.primaryColor.withValues(alpha: 0.5),
              size: 18,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('ًں”چ', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            'ظ„ط§ طھظˆط¬ط¯ ظ†طھط§ط¦ط¬',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStationCard extends StatelessWidget {
  final IslamicRadioStation station;
  final Color primary, gold;
  final bool isTablet;
  final AnimationController equalizerController;
  final Map<String, List<Color>> catColors;
  final double imgH;

  const _CategoryStationCard({
    required this.station,
    required this.primary,
    required this.gold,
    required this.isTablet,
    required this.equalizerController,
    required this.catColors,
    required this.imgH,
  });

  List<Color> get _colors =>
      catColors[station.category] ??
          [const Color(0xFF1A1A2E), const Color(0xFF6366F1)];

  @override
  Widget build(BuildContext context) {
    return Selector<RadioIntillegence, _GridStationState>(
      selector: (_, radio) {
        final isCurrent = radio.currentStation?.id == station.id;
        return _GridStationState(
          isCurrent: isCurrent,
          isPlaying: isCurrent && radio.isPlaying,
          isBuffering: isCurrent && radio.isBuffering,
          isFav: radio.isFavorite(station.id),
        );
      },
      builder: (_, state, __) {
        return GestureDetector(
          onTap: () {
            final radio = context.read<RadioIntillegence>();
            final coordinator = context.read<AudioCoordinator>();

            if (state.isCurrent && state.isPlaying) {
              radio.pause();
            } else if (state.isCurrent) {
              radio.resume();
            } else {
              coordinator.playOnlineRadio(station);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: StationImageWidget(
                        imageUrl: station.imageUrl,
                        imageAsset: station.imageAsset,
                        fallbackEmoji: station.iconEmoji,
                        primaryColor: primary,
                        goldColor: gold,
                        isActive: state.isCurrent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 7,
                      right: 7,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: state.isPlaying ? gold : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: state.isBuffering
                            ? Padding(
                          padding: const EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: primary,
                          ),
                        )
                            : Icon(
                          state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: state.isPlaying
                              ? Colors.white
                              : Colors.black87,
                          size: 15,
                        ),
                      ),
                    ),
                    if (state.isPlaying && !state.isBuffering)
                      Positioned(
                        bottom: 10,
                        left: 8,
                        child: _MiniEq(
                          controller: equalizerController,
                          color: gold,
                        ),
                      ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: GestureDetector(
                        onTap: () =>
                            context.read<RadioIntillegence>().toggleFavorite(station.id),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            state.isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: state.isFav
                                ? Colors.red.shade400
                                : Colors.white70,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 7,
                      left: 7,
                      child: StationLiveBadgeWidget(
                        isActive: state.isPlaying,
                        alwaysShow: true,
                        controller: equalizerController,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                station.name,
                style: GoogleFonts.cairo(
                  fontSize: isTablet ? 11.5 : 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                station.description,
                style: GoogleFonts.cairo(
                  fontSize: isTablet ? 9.5 : 9,
                  color: Colors.white.withValues(alpha: 0.45),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}

class _GridStationState {
  final bool isCurrent;
  final bool isPlaying;
  final bool isBuffering;
  final bool isFav;

  const _GridStationState({
    required this.isCurrent,
    required this.isPlaying,
    required this.isBuffering,
    required this.isFav,
  });

  @override
  bool operator ==(Object other) {
    return other is _GridStationState &&
        other.isCurrent == isCurrent &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering &&
        other.isFav == isFav;
  }

  @override
  int get hashCode => Object.hash(isCurrent, isPlaying, isBuffering, isFav);
}

class _MiniEq extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _MiniEq({
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (i) {
            final phase = controller.value * 2 * pi + i * 0.9;
            final h = 3.0 + 8.0 * ((sin(phase) + 1) / 2);
            return Container(
              width: 2.5,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 0.8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CatBgPainter extends CustomPainter {
  final double progress;
  final Color primary, gold;

  _CatBgPainter({
    required this.progress,
    required this.primary,
    required this.gold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF060A14), Color(0xFF0A0E1A), Color(0xFF0C1220)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    final glowPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final x = size.width * (0.2 + 0.6 * sin(phase * 2 * pi + i * 1.3));
      final y = size.height * (0.1 + 0.3 * cos(phase * 2 * pi + i * 1.8));
      final r = 120.0 + 50.0 * sin(phase * pi + i);

      glowPaint.shader = RadialGradient(
        colors: [
          (i.isEven ? primary : gold).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));

      canvas.drawCircle(Offset(x, y), r, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CatBgPainter old) =>
      old.progress != progress || old.primary != primary || old.gold != gold;
}