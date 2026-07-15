// lib/screens/radio/download_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/services/radio_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:provider/provider.dart';
import 'data/quran_data.dart';
import 'data/recitation_categories_data.dart';
import 'models/radio_station.dart';
import 'models/surah_model.dart';

class DownloadScreen extends StatefulWidget {
  final IslamicRadioStation station;
  final Color primary;

  const DownloadScreen({
    super.key,
    required this.station,
    required this.primary,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _selectedSurahs = {};
  int? _selectedJuz;

  // âœ… ط«ظˆط§ط¨طھ - ظ„ط§ طھطھط؛ظٹط±
  static const bool _isDark = true;
  static const Color _gold = Color(0xFFC8A44D);
  static const Color _cardColor = Color(0xFF111827);
  static const Color _bgColor = Color(0xFF080C18);

  // âœ… Cache ط§ظ„ط³ظˆط± ظˆط±ظˆط§ط¨ط·ظ‡ط§
  late final Map<int, String?> _surahUrlCache;
  late final Map<int, String> _surahItemIdCache;
  late final Map<int, RecitationItem> _surahItemCache;

  // âœ… ط§ط³ظ… ط§ظ„ظ…ط¬ظ„ط¯ ظ…ط­ط³ظˆط¨ ظ…ط±ط© ظˆط§ط­ط¯ط©
  late final String _stationDirName;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // âœ… ط­ط³ط§ط¨ Cache ظ…ط±ط© ظˆط§ط­ط¯ط©
    _buildCache();

    _stationDirName = widget.station.name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  void _onTabChanged() {
    if (mounted && !_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _buildCache() {
    _surahUrlCache = {};
    _surahItemIdCache = {};
    _surahItemCache = {};

    for (final surah in QuranData.surahs) {
      final url = widget.station.surahStreamUrl(surah.number);
      _surahUrlCache[surah.number] = url;

      if (url != null) {
        final item = RecitationItem(
          title: surah.name,
          subtitle: widget.station.name,
          emoji: widget.station.iconEmoji,
          audioUrl: url,
          imageUrl: widget.station.imageUrl,
        );
        _surahItemCache[surah.number] = item;
        _surahItemIdCache[surah.number] =
            ItemDownloadService.itemIdFromRecitationItem(item);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
          children: [
            // â•گâ•گ ط§ظ„ط®ظ„ظپظٹط© â•گâ•گ
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter:
                  _DownloadBgPainter(primary: widget.primary),
                ),
              ),
            ),

            // â•گâ•گ ط§ظ„ظ…ط­طھظˆظ‰ â•گâ•گ
            Column(
              children: [
                SizedBox(height: safePadding.top),
                _buildAppBar(),
                _StationInfoWidget(
                  station: widget.station,
                  primary: widget.primary,
                  surahItemIdCache: _surahItemIdCache,
                ),
                _buildTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _SurahsTab(
                        station: widget.station,
                        primary: widget.primary,
                        selectedSurahs: _selectedSurahs,
                        surahUrlCache: _surahUrlCache,
                        surahItemIdCache: _surahItemIdCache,
                        onSelectionChanged: (nums) {
                          setState(() {
                            _selectedSurahs
                              ..clear()
                              ..addAll(nums);
                          });
                        },
                        onToggleSurah: (num) {
                          setState(() {
                            if (_selectedSurahs.contains(num)) {
                              _selectedSurahs.remove(num);
                            } else {
                              _selectedSurahs.add(num);
                            }
                          });
                        },
                      ),
                      _JuzTab(
                        station: widget.station,
                        primary: widget.primary,
                        selectedJuz: _selectedJuz,
                        surahItemIdCache: _surahItemIdCache,
                        onSelectJuz: (juz) {
                          setState(() {
                            _selectedJuz =
                            _selectedJuz == juz ? null : juz;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                _DownloadButton(
                  station: widget.station,
                  primary: widget.primary,
                  tabController: _tabController,
                  selectedSurahs: _selectedSurahs,
                  selectedJuz: _selectedJuz,
                  surahItemCache: _surahItemCache,
                  surahUrlCache: _surahUrlCache,
                  stationDirName: _stationDirName,
                  onDownloadStarted: () {
                    setState(() {
                      _selectedSurahs.clear();
                      _selectedJuz = null;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border:
                Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'تحميل التلاوات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          // âœ… AnimatedSwitcher ظ„ط¹ط¯ط§ط¯ ط§ظ„طھط­ط¯ظٹط¯
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedSurahs.isNotEmpty &&
                _tabController.index == 0
                ? Container(
              key: const ValueKey('badge'),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: widget.primary.withValues(alpha: 0.4)),
              ),
              child: Text(
                '${_selectedSurahs.length} سورة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.primary,
                ),
              ),
            )
                : const SizedBox.shrink(key: ValueKey('no-badge')),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.primary, widget.primary.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.primary.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: GoogleFonts.cairo(
            fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.cairo(
            fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: '📖  السور'),
          Tab(text: '📚  الأجزاء'),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ط´ظٹط® - Widget ظ…ط³طھظ‚ظ„ ظ…ط¹ Selector
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _StationInfoWidget extends StatelessWidget {
  final IslamicRadioStation station;
  final Color primary;
  final Map<int, String> surahItemIdCache;

  static const Color _gold = Color(0xFFC8A44D);
  static const Color _cardColor = Color(0xFF111827);

  const _StationInfoWidget({
    required this.station,
    required this.primary,
    required this.surahItemIdCache,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ItemDownloadService, int>(
      // âœ… ظٹط¹ظٹط¯ ط§ظ„ط¨ظ†ط§ط، ظپظ‚ط· ط¹ظ†ط¯ طھط؛ظٹظٹط± ط¹ط¯ط¯ ط§ظ„ظ…ط­ظ…ظ„ط§طھ
      selector: (_, service) {
        int count = 0;
        for (final itemId in surahItemIdCache.values) {
          if (service.isDownloaded(itemId)) count++;
        }
        return count;
      },
      builder: (_, downloadedCount, __) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: 0.2),
                    _gold.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  station.iconEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: downloadedCount > 0
                        ? Row(
                      key: ValueKey(downloadedCount),
                      children: [
                        const Icon(
                          Icons.download_done_rounded,
                          size: 13,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$downloadedCount سورة محملة',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      key: const ValueKey('none'),
                      'لا توجد تحميلات',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… طھط¨ظˆظٹط¨ ط§ظ„ط³ظˆط± - Widget ظ…ط³طھظ‚ظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _SurahsTab extends StatelessWidget {
  final IslamicRadioStation station;
  final Color primary;
  final Set<int> selectedSurahs;
  final Map<int, String?> surahUrlCache;
  final Map<int, String> surahItemIdCache;
  final void Function(Set<int>) onSelectionChanged;
  final void Function(int) onToggleSurah;

  const _SurahsTab({
    required this.station,
    required this.primary,
    required this.selectedSurahs,
    required this.surahUrlCache,
    required this.surahItemIdCache,
    required this.onSelectionChanged,
    required this.onToggleSurah,
  });

  @override
  Widget build(BuildContext context) {
    // âœ… Selector ظٹط±ط§ظ‚ط¨ Set ط§ظ„ظ…ط­ظ…ظ„ط§طھ ظپظ‚ط·
    return Selector<ItemDownloadService, Set<int>>(
      selector: (_, service) {
        final downloaded = <int>{};
        for (final entry in surahItemIdCache.entries) {
          if (service.isDownloaded(entry.value)) {
            downloaded.add(entry.key);
          }
        }
        return downloaded;
      },
      shouldRebuild: (prev, next) =>
      prev.length != next.length || !prev.every(next.contains),
      builder: (_, downloadedSurahs, __) => Column(
        children: [
          _QuickSelectBar(
            primary: primary,
            downloadedSurahs: downloadedSurahs,
            onSelectAll: () => onSelectionChanged(
              QuranData.surahs
                  .where((s) => !downloadedSurahs.contains(s.number))
                  .map((s) => s.number)
                  .toSet(),
            ),
            onClearAll: () => onSelectionChanged({}),
            onSelectJuz30: () => onSelectionChanged(
              QuranData.surahsByJuz(30)
                  .where((s) => !downloadedSurahs.contains(s.number))
                  .map((s) => s.number)
                  .toSet(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              itemCount: QuranData.surahs.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemBuilder: (_, i) {
                final surah = QuranData.surahs[i];
                final isDownloaded =
                downloadedSurahs.contains(surah.number);
                final isSelected =
                selectedSurahs.contains(surah.number);

                return _SurahTile(
                  surah: surah,
                  isDownloaded: isDownloaded,
                  isSelected: isSelected,
                  primary: primary,
                  onTap: isDownloaded
                      ? null
                      : () => onToggleSurah(surah.number),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گ Quick Select Bar â•گâ•گ
class _QuickSelectBar extends StatelessWidget {
  final Color primary;
  final Set<int> downloadedSurahs;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;
  final VoidCallback onSelectJuz30;

  const _QuickSelectBar({
    required this.primary,
    required this.downloadedSurahs,
    required this.onSelectAll,
    required this.onClearAll,
    required this.onSelectJuz30,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _QuickBtn(
            label: 'تحديد الكل',
            icon: Icons.select_all_rounded,
            primary: primary,
            onTap: onSelectAll,
          ),
          const SizedBox(width: 8),
          _QuickBtn(
            label: 'إلغاء الكل',
            icon: Icons.deselect_rounded,
            primary: primary,
            onTap: onClearAll,
          ),
          const SizedBox(width: 8),
          _QuickBtn(
            label: 'جزء عمّ',
            icon: Icons.star_rounded,
            primary: primary,
            onTap: onSelectJuz30,
          ),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â•گâ•گ Surah Tile â•گâ•گ
class _SurahTile extends StatelessWidget {
  final SurahModel surah;
  final bool isDownloaded;
  final bool isSelected;
  final Color primary;
  final VoidCallback? onTap;

  static const Color _cardColor = Color(0xFF111827);

  const _SurahTile({
    required this.surah,
    required this.isDownloaded,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.1)
              : isDownloaded
              ? Colors.green.withValues(alpha: 0.06)
              : _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primary.withValues(alpha: 0.35)
                : isDownloaded
                ? Colors.green.withValues(alpha: 0.2)
                : primary.withValues(alpha: 0.06),
            width: isSelected ? 1.2 : 0.6,
          ),
        ),
        child: Row(
          children: [
            _SurahNumberBadge(
              number: surah.number,
              isDownloaded: isDownloaded,
              isSelected: isSelected,
              primary: primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? primary
                          : isDownloaded
                          ? Colors.green
                          : Colors.white,
                    ),
                  ),
                  Text(
                    '${surah.versesCount} آية • ${surah.isMakki ? 'مكية' : 'مدنية'} • الجزء ${surah.juzNumber}',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              isDownloaded ? '✓' : surah.approximateSizeStr,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDownloaded ? Colors.green : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahNumberBadge extends StatelessWidget {
  final int number;
  final bool isDownloaded;
  final bool isSelected;
  final Color primary;

  const _SurahNumberBadge({
    required this.number,
    required this.isDownloaded,
    required this.isSelected,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected
            ? primary.withValues(alpha: 0.15)
            : isDownloaded
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.06),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isDownloaded
            ? const Icon(Icons.download_done_rounded,
            size: 16, color: Colors.green)
            : isSelected
            ? Icon(Icons.check_rounded, size: 16, color: primary)
            : Text(
          '$number',
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… طھط¨ظˆظٹط¨ ط§ظ„ط£ط¬ط²ط§ط، - Widget ظ…ط³طھظ‚ظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _JuzTab extends StatelessWidget {
  final IslamicRadioStation station;
  final Color primary;
  final int? selectedJuz;
  final Map<int, String> surahItemIdCache;
  final void Function(int) onSelectJuz;

  const _JuzTab({
    required this.station,
    required this.primary,
    required this.selectedJuz,
    required this.surahItemIdCache,
    required this.onSelectJuz,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ItemDownloadService, Set<int>>(
      selector: (_, service) {
        final downloaded = <int>{};
        for (final entry in surahItemIdCache.entries) {
          if (service.isDownloaded(entry.value)) {
            downloaded.add(entry.key);
          }
        }
        return downloaded;
      },
      shouldRebuild: (prev, next) =>
      prev.length != next.length || !prev.every(next.contains),
      builder: (_, downloadedSurahs, __) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: QuranData.juzList.length,
        addAutomaticKeepAlives: false,
        itemBuilder: (_, i) {
          final juz = QuranData.juzList[i];
          final surahsInJuz = QuranData.surahsByJuz(juz.number);
          final downloadedInJuz = surahsInJuz
              .where((s) => downloadedSurahs.contains(s.number))
              .length;
          final isFullyDownloaded =
              downloadedInJuz == surahsInJuz.length;
          final isSelected = selectedJuz == juz.number;

          return _JuzTile(
            juz: juz,
            surahsInJuz: surahsInJuz,
            downloadedCount: downloadedInJuz,
            isFullyDownloaded: isFullyDownloaded,
            isSelected: isSelected,
            primary: primary,
            onTap: () => onSelectJuz(juz.number),
          );
        },
      ),
    );
  }
}

class _JuzTile extends StatelessWidget {
  final dynamic juz;
  final List<SurahModel> surahsInJuz;
  final int downloadedCount;
  final bool isFullyDownloaded;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  static const Color _cardColor = Color(0xFF111827);

  const _JuzTile({
    required this.juz,
    required this.surahsInJuz,
    required this.downloadedCount,
    required this.isFullyDownloaded,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.1)
              : isFullyDownloaded
              ? Colors.green.withValues(alpha: 0.06)
              : _cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primary.withValues(alpha: 0.35)
                : isFullyDownloaded
                ? Colors.green.withValues(alpha: 0.2)
                : primary.withValues(alpha: 0.07),
            width: isSelected ? 1.3 : 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _JuzNumberBadge(
                    number: juz.number,
                    isFullyDownloaded: isFullyDownloaded,
                    isSelected: isSelected,
                    primary: primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          juz.name,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? primary
                                : isFullyDownloaded
                                ? Colors.green
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${surahsInJuz.length} سورة',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        juz.approximateSizeStr(QuranData.surahs),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? primary : Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$downloadedCount/${surahsInJuz.length} محمّل',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: downloadedCount > 0
                              ? Colors.green
                              : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  _JuzCheckBox(isSelected: isSelected, primary: primary),
                ],
              ),
            ),
            if (downloadedCount > 0 && !isFullyDownloaded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: downloadedCount / surahsInJuz.length,
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    valueColor:
                    const AlwaysStoppedAnimation(Colors.green),
                    minHeight: 4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _JuzNumberBadge extends StatelessWidget {
  final int number;
  final bool isFullyDownloaded;
  final bool isSelected;
  final Color primary;

  const _JuzNumberBadge({
    required this.number,
    required this.isFullyDownloaded,
    required this.isSelected,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFullyDownloaded
              ? [
            Colors.green.withValues(alpha: 0.2),
            Colors.green.withValues(alpha: 0.1),
          ]
              : isSelected
              ? [
            primary.withValues(alpha: 0.25),
            primary.withValues(alpha: 0.1),
          ]
              : [
            primary.withValues(alpha: 0.1),
            primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: isFullyDownloaded
            ? const Icon(Icons.download_done_rounded,
            color: Colors.green, size: 22)
            : Text(
          '$number',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isSelected ? primary : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _JuzCheckBox extends StatelessWidget {
  final bool isSelected;
  final Color primary;

  const _JuzCheckBox({
    required this.isSelected,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? primary : Colors.white30,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… ط²ط± ط§ظ„طھط­ظ…ظٹظ„ - Widget ظ…ط³طھظ‚ظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _DownloadButton extends StatelessWidget {
  final IslamicRadioStation station;
  final Color primary;
  final TabController tabController;
  final Set<int> selectedSurahs;
  final int? selectedJuz;
  final Map<int, RecitationItem> surahItemCache;
  final Map<int, String?> surahUrlCache;
  final String stationDirName;
  final VoidCallback onDownloadStarted;

  static const bool _isDark = true;

  const _DownloadButton({
    required this.station,
    required this.primary,
    required this.tabController,
    required this.selectedSurahs,
    required this.selectedJuz,
    required this.surahItemCache,
    required this.surahUrlCache,
    required this.stationDirName,
    required this.onDownloadStarted,
  });

  @override
  Widget build(BuildContext context) {
    final isSurahTab = tabController.index == 0;
    final hasSelection =
    isSurahTab ? selectedSurahs.isNotEmpty : selectedJuz != null;

    return Consumer<RadioDownloadService>(
      builder: (_, download, __) {
        final status = download.getStatus(station.id);
        final isDownloading = status == DownloadStatus.downloading;
        final progress = download.getProgress(station.id);
        final info = download.getInfo(station.id);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0A0E0D),
            border: Border(
              top: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDownloading) ...[
                _DownloadProgressBar(
                  progress: progress,
                  primary: primary,
                  downloadedCount: info?.downloadedCount ?? 0,
                  totalCount: info?.totalToDownload ?? 0,
                ),
                const SizedBox(height: 10),
              ],

              if (!isDownloading && hasSelection) ...[
                _SelectionSummary(
                  isSurahTab: isSurahTab,
                  selectedSurahs: selectedSurahs,
                  selectedJuz: selectedJuz,
                  primary: primary,
                  download: download,
                  stationId: station.id,
                ),
                const SizedBox(height: 10),
              ],

              Row(
                children: [
                  if (isDownloading)
                    Expanded(
                      child: _ActionButton(
                        label: 'إلغاء التحميل',
                        icon: Icons.close_rounded,
                        color: Colors.red,
                        onTap: () => download.cancelDownload(station.id),
                      ),
                    )
                  else if (hasSelection)
                    Expanded(
                      child: _ActionButton(
                        label: isSurahTab
                            ? 'تحميل ${selectedSurahs.length} سورة'
                            : 'تحميل ${QuranData.juzByNumber(selectedJuz!).name}',
                        icon: Icons.download_rounded,
                        color: primary,
                        onTap: () =>
                            _startDownload(context, download),
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            isSurahTab
                                ? 'اختر سوراً للتحميل'
                                : 'اختر جزءاً للتحميل',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _startDownload(
      BuildContext context, RadioDownloadService download) {
    final itemDownload = context.read<ItemDownloadService>();

    if (tabController.index == 0) {
      for (final surahNum in selectedSurahs) {
        final item = surahItemCache[surahNum];
        if (item == null) continue;

        final surahFileName = item.title
            .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
            .replaceAll(RegExp(r'\s+'), '_')
            .trim();

        itemDownload.downloadItem(
          item,
          customDir: stationDirName,
          customFileName: surahFileName,
        );
      }
    } else if (selectedJuz != null) {
      final surahsInJuz = QuranData.surahsByJuz(selectedJuz!);
      for (final surah in surahsInJuz) {
        final item = surahItemCache[surah.number];
        if (item == null) continue;

        final surahFileName = surah.name
            .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
            .replaceAll(RegExp(r'\s+'), '_')
            .trim();

        itemDownload.downloadItem(
          item,
          customDir: stationDirName,
          customFileName: surahFileName,
        );
      }
    }

    onDownloadStarted();
  }
}

class _DownloadProgressBar extends StatelessWidget {
  final double progress;
  final Color primary;
  final int downloadedCount;
  final int totalCount;

  const _DownloadProgressBar({
    required this.progress,
    required this.primary,
    required this.downloadedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(primary),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'جاري تحميل $downloadedCount من $totalCount سورة',
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  final bool isSurahTab;
  final Set<int> selectedSurahs;
  final int? selectedJuz;
  final Color primary;
  final RadioDownloadService download;
  final int stationId;

  const _SelectionSummary({
    required this.isSurahTab,
    required this.selectedSurahs,
    required this.selectedJuz,
    required this.primary,
    required this.download,
    required this.stationId,
  });

  @override
  Widget build(BuildContext context) {
    final downloaded = download.getDownloadedSurahs(stationId);

    if (isSurahTab) {
      final newSurahs =
          selectedSurahs.where((n) => !downloaded.contains(n)).length;
      final alreadyHave = selectedSurahs.length - newSurahs;
      double totalSize = 0;
      for (final num in selectedSurahs) {
        if (!downloaded.contains(num)) {
          totalSize += QuranData.surahByNumber(num).approximateSizeMB;
        }
      }

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem('سيُحمَّل', '$newSurahs سورة', primary),
            if (alreadyHave > 0)
              _SummaryItem('موجود', '$alreadyHave سورة', Colors.green),
            _SummaryItem(
              'الحجم',
              '${totalSize.toStringAsFixed(0)} MB',
              Colors.orange,
            ),
          ],
        ),
      );
    } else {
      final juz = QuranData.juzByNumber(selectedJuz!);
      final surahsInJuz = QuranData.surahsByJuz(selectedJuz!);
      final newSurahs =
          surahsInJuz.where((s) => !downloaded.contains(s.number)).length;
      double totalSize = surahsInJuz
          .where((s) => !downloaded.contains(s.number))
          .fold(0.0, (sum, s) => sum + s.approximateSizeMB);

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem('سيُحمَّل', '$newSurahs سورة', primary),
            _SummaryItem('الجزء', '${juz.number}', primary),
            _SummaryItem(
              'الحجم',
              '${totalSize.toStringAsFixed(0)} MB',
              Colors.orange,
            ),
          ],
        ),
      );
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گ Background Painter â•گâ•گ
class _DownloadBgPainter extends CustomPainter {
  final Color primary;

  const _DownloadBgPainter({required this.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF060A14),
          Color(0xFF0A0E1A),
          Color(0xFF0C1220),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [primary.withValues(alpha: 0.08), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, 0),
          radius: size.width * 0.8,
        ),
      );
    canvas.drawCircle(
        Offset(size.width * 0.5, 0), size.width * 0.8, glow);
  }

  @override
  bool shouldRepaint(covariant _DownloadBgPainter old) =>
      old.primary != primary;
}