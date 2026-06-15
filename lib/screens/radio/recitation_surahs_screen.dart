// lib/screens/radio/recitation_surahs_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/offline_radio_service.dart';
import 'package:islamic_app/screens/radio/services/online_surah_service.dart';
import 'package:islamic_app/screens/radio/surah_player_screen.dart';
import 'package:islamic_app/screens/radio/widgets/modern_bottom_player.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/rs_app_bar.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/rs_fab.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/rs_mini_player.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/rs_reciter_header.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/rs_search_bar.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/rs_surah_tile.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_animations.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_background.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:provider/provider.dart';
import 'data/quran_data.dart';
import 'data/recitation_categories_data.dart';
import 'download_screen.dart';
import 'models/radio_station.dart';

class RecitationSurahsScreen extends StatefulWidget {
  final IslamicRadioStation station;
  final Color primary;

  const RecitationSurahsScreen({
    super.key,
    required this.station,
    required this.primary,
  });

  @override
  State<RecitationSurahsScreen> createState() =>
      _RecitationSurahsScreenState();
}

class _RecitationSurahsScreenState extends State<RecitationSurahsScreen>
    with SingleTickerProviderStateMixin {
  final RsAnimationHelper _animHelper = RsAnimationHelper();

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const bool _isDark = true;
  static const Color _cardColor = Color(0xFF111827);

  // ✅ Cache محسوبة مرة واحدة
  late final Map<int, String?> _surahUrlCache;
  late final Map<int, String> _surahItemIdCache;

  @override
  void initState() {
    super.initState();
    _animHelper.init(this);
    _buildSurahCache(); // ✅ حساب مرة واحدة
  }

  // ✅ بناء الـ cache مرة واحدة عند init
  void _buildSurahCache() {
    _surahUrlCache = {};
    _surahItemIdCache = {};

    for (final surah in QuranData.surahs) {
      final url = widget.station.surahStreamUrl(surah.number);
      _surahUrlCache[surah.number] = url;

      if (url != null) {
        final tempItem = RecitationItem(
          title: surah.name,
          subtitle: widget.station.name,
          emoji: widget.station.iconEmoji,
          audioUrl: url,
        );
        _surahItemIdCache[surah.number] =
            ItemDownloadService.itemIdFromRecitationItem(tempItem);
      }
    }
  }

  @override
  void dispose() {
    _animHelper.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _playOnlineSurah(
      BuildContext context,
      AudioCoordinator coordinator,
      int surahNumber,
      ) async {
    if (!widget.station.supportsStream) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا القارئ لا يدعم الاستماع المباشر',
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

    await coordinator.playSurahTrack(
      station: widget.station,
      surahNumber: surahNumber,
      isLocal: false,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahPlayerScreen(
          station: widget.station,
          surahNumber: surahNumber,
          primary: widget.primary,
          isOnline: true,
        ),
      ),
    );
  }

  // ✅ فصل حساب السور المفلترة
  List<dynamic> get _filteredSurahs {
    if (_searchQuery.isEmpty) return QuranData.surahs;
    final query = _searchQuery.toLowerCase();
    return QuranData.surahs.where((s) {
      return s.name.contains(_searchQuery) ||
          s.nameEn.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final safePadding = mediaQuery.padding;
    final isTablet = size.width > 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadioColors.background(context),
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: RsBackground(primary: widget.primary),
              ),
            ),

            Column(
              children: [
                SizedBox(height: safePadding.top),

                RsAppBar(
                  stationName: widget.station.name,
                  onBack: () => Navigator.pop(context),
                ),

                RsReciterHeader(
                  station: widget.station,
                  primary: widget.primary,
                  isDark: _isDark,
                ),

                // ✅ Selector بدل Consumer - يعيد البناء فقط عند تغيير station ID
                Selector<OfflineRadioService, bool>(
                  selector: (_, offline) =>
                  offline.currentStation?.id == widget.station.id,
                  builder: (_, isCurrentStation, __) {
                    if (!isCurrentStation) return const SizedBox.shrink();

                    return Consumer<OfflineRadioService>(
                      builder: (_, offline, __) => RsMiniPlayer(
                        offline: offline,
                        station: widget.station,
                        primary: widget.primary,
                        isDark: _isDark,
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: RsSearchBar(
                    controller: _searchController,
                    primary: widget.primary,
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),

                // ✅ Selector بدل Consumer لتقليل إعادة البناء
                Expanded(
                  child: Selector<ItemDownloadService, Set<int>>(
                    // ✅ يعيد البناء فقط عند تغيير Set المحملات
                    selector: (_, service) {
                      final downloaded = <int>{};
                      for (final entry in _surahItemIdCache.entries) {
                        if (service.isDownloaded(entry.value)) {
                          downloaded.add(entry.key);
                        }
                      }
                      return downloaded;
                    },
                    shouldRebuild: (prev, next) => prev.length != next.length ||
                        !prev.every(next.contains),
                    builder: (_, downloaded, __) {
                      final surahs = _filteredSurahs;

                      return Consumer<AudioCoordinator>(
                        builder: (_, coordinator, __) {
                          final playerHeight =
                          coordinator.hasActivePlayer ? 90.0 : 0.0;
                          const fabHeight = 56.0 + 16 + 16;
                          final bottomPadding =
                              playerHeight + fabHeight + safePadding.bottom;

                          return ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              16, 0, 16, bottomPadding,
                            ),
                            // ✅ تحسينات ListView
                            itemCount: surahs.length,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            itemBuilder: (_, i) => RsSurahTile(
                              surah: surahs[i],
                              station: widget.station,
                              isDownloaded: downloaded.contains(surahs[i].number),
                              isDark: _isDark,
                              cardColor: _cardColor,
                              primary: widget.primary,
                              onPlayOnline: _playOnlineSurah,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // ══ المشغل السفلي ══
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
                      equalizerController: _animHelper.equalizerController,
                    ),
                  );
                },
              ),
            ),

            // ══ FAB ══
            Selector<AudioCoordinator, bool>(
              selector: (_, c) => c.hasActivePlayer,
              builder: (_, hasPlayer, __) {
                final bottom = hasPlayer
                    ? 90.0 + safePadding.bottom
                    : safePadding.bottom + 16;

                return Positioned(
                  bottom: bottom,
                  left: 16,
                  right: 16,
                  child: RsFab(
                    primary: widget.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DownloadScreen(
                            station: widget.station,
                            primary: widget.primary,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}