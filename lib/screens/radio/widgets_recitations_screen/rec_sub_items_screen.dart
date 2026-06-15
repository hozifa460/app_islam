// lib/screens/radio/widgets_recitations_screen/rec_sub_items_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:islamic_app/screens/radio/widgets/modern_bottom_player.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_item_player_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_sub_items_download_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/playlist_service.dart';
import 'package:provider/provider.dart';

import '../services/offline_radio_service.dart';
import '../services/online_surah_service.dart';
import '../widgets_radio_screen/theme/radio_colors.dart';
import 'duration_text.dart';
import 'models/downloadable_item.dart';
import 'theme/rec_colors.dart';

class RecSubItemsScreen extends StatefulWidget {
  final RecitationItem parentItem;
  final Color primary;

  const RecSubItemsScreen({
    super.key,
    required this.parentItem,
    required this.primary,
  });

  @override
  State<RecSubItemsScreen> createState() => _RecSubItemsScreenState();
}

class _RecSubItemsScreenState extends State<RecSubItemsScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _equalizerController;

  // ══ أضف هذا ══
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // ══ أضف هذا ══
  List<RecitationSubItem> get _filteredSubItems {
    // فقط العناصر المفردة (بدون أقسام)
    final all = widget.parentItem.subItems ?? [];
    if (_searchQuery.trim().isEmpty) return all;

    final query = _searchQuery.trim().toLowerCase();
    return all.where((sub) {
      return sub.title.toLowerCase().contains(query) ||
          sub.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _bgController.dispose();
    _equalizerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // أضف getter للأقسام المفلترة
  List<RecitationSubSection> get _filteredSections {
    final sections = widget.parentItem.subSections ?? [];
    if (_searchQuery.trim().isEmpty) return sections;

    final query = _searchQuery.trim().toLowerCase();
    return sections.where((section) {
      // بحث في عنوان القسم
      if (section.title.toLowerCase().contains(query)) return true;
      // بحث في عناصر القسم
      return section.items.any((sub) =>
      sub.title.toLowerCase().contains(query) ||
          sub.subtitle.toLowerCase().contains(query));
    }).toList();
  }

// ══ بناء المحتوى (أقسام + عناصر مفردة) ══
  Widget _buildContent() {
    final safePadding = MediaQuery.of(context).padding;
    final hasSections = _filteredSections.isNotEmpty;
    final hasLooseItems = _filteredSubItems.isNotEmpty;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 190 + safePadding.bottom),
      physics: const BouncingScrollPhysics(),
      children: [
        // ══ الأقسام ══
        if (hasSections)
          ..._filteredSections.map((section) =>
              _buildSection(section)),

        // ══ العناصر المفردة (subItems بدون قسم) ══
        if (hasLooseItems && hasSections) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('تلاوات أخرى', '🎵'),
        ],

        if (hasLooseItems)
          ..._filteredSubItems.asMap().entries.map((entry) {
            final allSubs = widget.parentItem.allSubItems;
            final realIndex = allSubs.indexOf(entry.value);

            final downloadItem = RecitationItem(
              title: entry.value.title,
              subtitle: entry.value.subtitle,
              emoji: entry.value.emoji,
              audioUrl: entry.value.audioUrl,
              imageUrl: entry.value.imageUrl ?? widget.parentItem.imageUrl,
            );

            final itemId =
            ItemDownloadService.itemIdFromRecitationItem(downloadItem);

            return _SubItemTile(
              subItem: entry.value,
              parentItem: widget.parentItem,
              index: realIndex >= 0 ? realIndex : entry.key,
              primary: widget.primary,
              equalizerController: _equalizerController,
              itemId: itemId,
              downloadItem: downloadItem,
            );
          }),
      ],
    );
  }

// ══ عنوان القسم ══
  Widget _buildSectionHeader(String title, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: RadioColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

// ══ قسم كامل ══
  Widget _buildSection(RecitationSubSection section) {
    final allSubs = widget.parentItem.allSubItems;

    // فلترة العناصر داخل القسم حسب البحث
    List<RecitationSubItem> sectionItems;
    if (_searchQuery.trim().isEmpty) {
      sectionItems = section.items;
    } else {
      final query = _searchQuery.trim().toLowerCase();
      sectionItems = section.items.where((sub) =>
      sub.title.toLowerCase().contains(query) ||
          sub.subtitle.toLowerCase().contains(query)).toList();
    }

    if (sectionItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(section.title, section.emoji),
        ...sectionItems.map((sub) {
          final realIndex = allSubs.indexOf(sub);

          final downloadItem = RecitationItem(
            title: sub.title,
            subtitle: sub.subtitle,
            emoji: sub.emoji,
            audioUrl: sub.audioUrl,
            imageUrl: sub.imageUrl ?? widget.parentItem.imageUrl,
          );

          final itemId =
          ItemDownloadService.itemIdFromRecitationItem(downloadItem);

          return _SubItemTile(
            subItem: sub,
            parentItem: widget.parentItem,
            index: realIndex >= 0 ? realIndex : 0,
            primary: widget.primary,
            equalizerController: _equalizerController,
            itemId: itemId,
            downloadItem: downloadItem,
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    final isTablet = size.width > 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RecColors.background(context),
        body: Stack(
          children: [
            // ═════════ الخلفية ═════════
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (_, __) => CustomPaint(
                  painter: _SubItemsBgPainter(
                    progress: _bgController.value,
                    primary: widget.primary,
                    gold: RecColors.gold,
                    backgroundColors: RecColors.bgGradient(context).colors,
                  ),
                ),
              ),
            ),

            // ═════════ المحتوى ═════════
            Column(
              children: [
                SizedBox(height: safePadding.top),

                // AppBar
                _buildAppBar(isTablet),

                // Header
                _buildHeader(isTablet),

                // ══ شريط البحث - أضف هذا ══
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _buildSearchBar(),
                ),

                // القائمة
                // استبدل الـ Expanded الذي فيه ListView بهذا:

                Expanded(
                  child: RepaintBoundary(
                    child: _filteredSubItems.isEmpty && _filteredSections.isEmpty
                        ? _buildEmptySearch(context)
                        : _buildContent(),
                  ),
                ),
              ],
            ),

            // ═════════ المشغل السفلي ═════════
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Consumer3<RadioIntillegence, OfflineRadioService, OnlineSurahService>(
                builder: (_, online, offline, onlineSurah, __) {
                  final hasAny = online.currentStation != null ||
                      offline.currentStation != null ||
                      onlineSurah.currentStation != null;

                  if (!hasAny) {
                    return const SizedBox.shrink();
                  }

                  return RepaintBoundary(
                    child: ModernBottomPlayer(
                      primary: widget.primary,
                      isTablet: isTablet,
                      safePadding: safePadding,
                      equalizerController: _equalizerController,
                    ),
                  );
                },
              ),
            ),

            // ═════════ FAB تحميل التلاوات ═════════
            Consumer<AudioCoordinator>(
              builder: (_, coordinator, __) {
                final hasPlayer = coordinator.hasActivePlayer;
                final playerHeight = hasPlayer ? 80.0 : 0.0;
                final bottomOffset = hasPlayer
                    ? playerHeight + safePadding.bottom + 12
                    : safePadding.bottom + 16;

                return Positioned(
                  bottom: bottomOffset,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecSubItemsDownloadScreen(
                            parentItem: widget.parentItem,
                            primary: widget.primary,
                          ),
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
                            widget.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تحميل التلاوات',
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: RecColors.searchBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RecColors.searchBorder(context, widget.primary),
        ),
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        style: GoogleFonts.cairo(
          fontSize: 13,
          color: RecColors.searchText(context),
        ),
        decoration: InputDecoration(
          hintText: 'ابحث في التلاوات...',
          hintStyle: GoogleFonts.cairo(
            color: RecColors.searchHint(context),
            fontSize: 12,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: RecColors.primary(widget.primary, 0.5),
            size: 18,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
            onTap: () {
              _searchController.clear();
              _onSearchChanged('');
            },
            child: Icon(
              Icons.close_rounded,
              color: RecColors.searchHint(context),
              size: 16,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _searchQuery = value);
      }
    });
  }

  Widget _buildEmptySearch([BuildContext? ctx]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            'لا توجد نتائج لـ "$_searchQuery"',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════ AppBar ═════════
  Widget _buildAppBar(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
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
                Icons.arrow_back_ios_new_rounded,
                color: RecColors.iconColor(context),
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
                  widget.parentItem.title,
                  style: GoogleFonts.cairo(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w900,
                    color: RecColors.textPrimary(context),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.parentItem.subItemsCount} تلاوة',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: RecColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════ Header ═════════
  Widget _buildHeader(bool isTablet) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RecColors.primary(widget.primary, 0.15),
            RecColors.goldOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RecColors.primary(widget.primary, 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  RecColors.primary(widget.primary, 0.25),
                  RecColors.goldOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                widget.parentItem.emoji,
                style: const TextStyle(fontSize: 28),
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
                  widget.parentItem.title,
                  style: GoogleFonts.cairo(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: RecColors.textPrimary(context),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.parentItem.subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: RecColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _statBadge(
                      '${widget.parentItem.subItemsCount}',
                      'تلاوة',
                      widget.primary,
                    ),
                    const SizedBox(width: 8),
                    _statBadge(
                      '📂',
                      'مجموعة',
                      RecColors.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: RecColors.primary(color, 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RecColors.primary(color, 0.2)),
      ),
      child: Text(
        '$value $label',
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// بطاقة العنصر الفرعي
// ══════════════════════════════════════════════════════════════

class _SubItemTile extends StatelessWidget {
  final RecitationSubItem subItem;
  final RecitationItem parentItem;
  final int index;
  final Color primary;
  final AnimationController equalizerController;
  final String itemId;
  final RecitationItem downloadItem;

  const _SubItemTile({
    required this.subItem,
    required this.parentItem,
    required this.index,
    required this.primary,
    required this.equalizerController,
    required this.itemId,
    required this.downloadItem,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ItemDownloadService, _SubItemDownloadState>(
      selector: (_, service) => _SubItemDownloadState(
        isDownloaded: service.isDownloaded(itemId),
        isDownloading:
        service.getStatus(itemId) == ItemDownloadStatus.downloading,
        progress: service.getProgress(itemId),
        localPath: service.getLocalPath(itemId),
      ),
      builder: (_, downloadState, __) {
        final stationId = (downloadState.localPath ?? subItem.audioUrl)
            .hashCode
            .abs();

        return Selector<RadioIntillegence, _SubItemPlaybackState>(
          selector: (_, radio) {
            final isCurrent = radio.currentStation?.id == stationId;
            return _SubItemPlaybackState(
              isCurrent: isCurrent,
              isPlaying: isCurrent && radio.isPlaying,
              isBuffering: isCurrent && radio.isBuffering,
            );
          },
          builder: (_, playbackState, __) {
            return GestureDetector(
              onTap: () => _handleTap(
                context,
                downloadState.isDownloaded,
                downloadState.localPath,
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: RecColors.itemBackground(
                    context,
                    isActive: playbackState.isCurrent,
                    primary: primary,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: RecColors.itemBorder(
                      context,
                      isActive: playbackState.isCurrent,
                      primary: primary,
                    ),
                    width: playbackState.isCurrent ? 1.2 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: playbackState.isCurrent
                              ? _buildMiniEqualizer()
                              : Text(
                            '${index + 1}',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: RecColors.textPrimary(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                subItem.title,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: playbackState.isCurrent
                                      ? primary
                                      : RecColors.textPrimary(context),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      subItem.subtitle,
                                      style: GoogleFonts.cairo(
                                        fontSize: 10,
                                        color: RecColors.textHint(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (subItem.audioUrl.isNotEmpty) ...[
                                    Text(
                                      ' • ',
                                      style: TextStyle(
                                        color: RecColors.textSecondary(context),
                                        fontSize: 10,
                                      ),
                                    ),
                                    DurationText(
                                      audioUrl: subItem.audioUrl,
                                      fallbackSeconds: subItem.durationSeconds,
                                      fontSize: 10,
                                      color: RecColors.textHint(context),
                                    ),
                                  ],
                                  if (downloadState.isDownloaded) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.download_done_rounded,
                                      size: 11,
                                      color: Colors.green,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDownloadBtn(
                              context,
                              downloadState,
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _handleTap(
                                context,
                                downloadState.isDownloaded,
                                downloadState.localPath,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: playbackState.isCurrent
                                      ? LinearGradient(
                                    colors: [
                                      primary,
                                      primary.withOpacity(0.8),
                                    ],
                                  )
                                      : null,
                                  color: playbackState.isCurrent
                                      ? null
                                      : RecColors.primary(primary, 0.1),
                                  shape: BoxShape.circle,
                                  boxShadow: playbackState.isCurrent
                                      ? [
                                    BoxShadow(
                                      color:
                                      RecColors.primary(primary, 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                      : null,
                                ),
                                child: playbackState.isBuffering
                                    ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Icon(
                                  playbackState.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 20,
                                  color: playbackState.isCurrent
                                      ? Colors.white
                                      : primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (downloadState.isDownloading) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: downloadState.progress > 0
                              ? downloadState.progress
                              : null,
                          backgroundColor: RecColors.primary(primary, 0.1),
                          valueColor: AlwaysStoppedAnimation(primary),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleTap(
      BuildContext context,
      bool isDownloaded,
      String? localPath,
      ) {
    final downloadService = context.read<ItemDownloadService>();

    final playlist = context.read<PlaylistService>();
    playlist.buildFromSubItems(
      parentItem: parentItem,
      downloadService: downloadService,
      startIndex: index,
    );

    final currentPlaylistItem = playlist.currentItem;
    if (currentPlaylistItem == null) return;

    final coordinator = context.read<AudioCoordinator>();
    coordinator.playPlaylistItem(currentPlaylistItem);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecItemPlayerScreen(
          item: RecitationItem(
            title: subItem.title,
            subtitle: subItem.subtitle,
            emoji: subItem.emoji,
            imageUrl: subItem.imageUrl ?? parentItem.imageUrl,
            audioUrl: isDownloaded && localPath != null
                ? localPath
                : subItem.audioUrl,
          ),
          primary: primary,
          station: IslamicRadioStation(
            id: (localPath ?? subItem.audioUrl).hashCode.abs(),
            name: subItem.title,
            nameEn: subItem.title,
            url: localPath ?? subItem.audioUrl,
            category: parentItem.title,
            categoryEn: 'Recitations',
            description: subItem.subtitle,
            descriptionEn: subItem.subtitle,
            iconEmoji: subItem.emoji,
            imageUrl: subItem.imageUrl ?? parentItem.imageUrl,
          ),
          isLocal: isDownloaded && localPath != null,
          videoUrl: subItem.videoUrl,
          videoSource: subItem.videoSource,
        ),
      ),
    );
  }

  Widget _buildDownloadBtn(
      BuildContext context,
      _SubItemDownloadState state,
      ) {
    return GestureDetector(
      onTap: () {
        final service = context.read<ItemDownloadService>();

        if (state.isDownloading) {
          service.cancelDownload(itemId);
        } else if (state.isDownloaded) {
          service.deleteDownload(itemId);
        } else {
          service.downloadItem(downloadItem);
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: RecColors.downloadBadgeBackground(
            context,
            state.isDownloaded,
            primary,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: RecColors.downloadBadgeBorder(
              context,
              state.isDownloaded,
              primary,
            ),
          ),
        ),
        child: state.isDownloading
            ? Padding(
          padding: const EdgeInsets.all(7),
          child: CircularProgressIndicator(
            value: state.progress > 0 ? state.progress : null,
            strokeWidth: 1.5,
            color: Colors.orange,
          ),
        )
            : Icon(
          state.isDownloaded
              ? Icons.download_done_rounded
              : Icons.download_rounded,
          size: 14,
          color: state.isDownloaded ? Colors.green : primary,
        ),
      ),
    );
  }

  Widget _buildMiniEqualizer() {
    return AnimatedBuilder(
      animation: equalizerController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase =
                equalizerController.value * 2 * pi + i * 0.9;
            final h = 4.0 + 10.0 * ((sin(phase) + 1) / 2);
            return Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 0.8),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SubItemDownloadState {
  final bool isDownloaded;
  final bool isDownloading;
  final double progress;
  final String? localPath;

  const _SubItemDownloadState({
    required this.isDownloaded,
    required this.isDownloading,
    required this.progress,
    required this.localPath,
  });

  @override
  bool operator ==(Object other) {
    return other is _SubItemDownloadState &&
        other.isDownloaded == isDownloaded &&
        other.isDownloading == isDownloading &&
        other.progress == progress &&
        other.localPath == localPath;
  }

  @override
  int get hashCode =>
      Object.hash(isDownloaded, isDownloading, progress, localPath);
}

class _SubItemPlaybackState {
  final bool isCurrent;
  final bool isPlaying;
  final bool isBuffering;

  const _SubItemPlaybackState({
    required this.isCurrent,
    required this.isPlaying,
    required this.isBuffering,
  });

  @override
  bool operator ==(Object other) {
    return other is _SubItemPlaybackState &&
        other.isCurrent == isCurrent &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering;
  }

  @override
  int get hashCode => Object.hash(isCurrent, isPlaying, isBuffering);
}

// ══ الخلفية ══
class _SubItemsBgPainter extends CustomPainter {
  final double progress;
  final Color primary, gold;
  final List<Color> backgroundColors;

  _SubItemsBgPainter({
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
    for (int i = 0; i < 2; i++) {
      final phase = (progress + i * 0.5) % 1.0;
      final x = size.width * (0.3 + 0.4 * sin(phase * 2 * pi + i));
      final y = size.height * (0.1 + 0.15 * cos(phase * 2 * pi + i));
      final r = 110.0 + 40.0 * sin(phase * pi);

      glow.shader = RadialGradient(
        colors: [
          (i.isEven ? primary : gold).withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));

      canvas.drawCircle(Offset(x, y), r, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _SubItemsBgPainter old) =>
      old.progress != progress ||
          old.primary != primary ||
          old.gold != gold ||
          old.backgroundColors != backgroundColors;
}