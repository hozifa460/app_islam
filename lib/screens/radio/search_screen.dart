// lib/screens/radio/search_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/models/radio_station.dart';
import 'package:islamic_app/screens/radio/recitation_surahs_screen.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/global_search_service.dart';
import 'package:islamic_app/screens/radio/surah_player_screen.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/models/downloadable_item.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_item_player_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/rec_sub_items_screen.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:provider/provider.dart';

import 'data/quran_data.dart';
import 'data/radio_data.dart';

class RecSearchScreen extends StatefulWidget {
  final Color primary;
  final List<RecitationCategory> categories;

  const RecSearchScreen({
    super.key,
    required this.primary,
    required this.categories,
  });

  @override
  State<RecSearchScreen> createState() => _RecSearchScreenState();
}

class _RecSearchScreenState extends State<RecSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<SearchResult> _results = [];
  Timer? _debounce;
  bool _isSearching = false;
  String? _activeFilterKey;
  String _lastQuery = '';

  // ✅ Cache القراء - تُحسب مرة واحدة
  late final List<IslamicRadioStation> _reciters;

  // ✅ Cache إحصائيات ثابتة
  late final int _recitersCount;
  late final int _stationsCount;

  static const Color _gold = Color(0xFFC8A44D);

  // ✅ Getter محسّن مع cache
  List<SearchResult> get _filteredResults {
    if (_activeFilterKey == null || _activeFilterKey == 'all') {
      return _results;
    }

    final typeMap = {
      'reciter': SearchResultType.reciter,
      'surah': SearchResultType.surah,
      'category': SearchResultType.category,
      'subItem': SearchResultType.subItem,
      'subSection': SearchResultType.subSection,
      'radioStation': SearchResultType.radioStation,
    };

    final targetType = typeMap[_activeFilterKey];
    if (targetType == null) return _results;

    return _results.where((r) => r.type == targetType).toList();
  }

  // ✅ حساب filterCounts مرة واحدة من _results
  Map<String, int> get _filterCounts {
    final counts = <String, int>{'all': _results.length};

    for (final r in _results) {
      switch (r.type) {
        case SearchResultType.reciter:
          counts['reciter'] = (counts['reciter'] ?? 0) + 1;
          break;
        case SearchResultType.surah:
          counts['surah'] = (counts['surah'] ?? 0) + 1;
          break;
        case SearchResultType.category:
          counts['category'] = (counts['category'] ?? 0) + 1;
          break;
        case SearchResultType.subItem:
          counts['subItem'] = (counts['subItem'] ?? 0) + 1;
          break;
        case SearchResultType.subSection:
          counts['subSection'] = (counts['subSection'] ?? 0) + 1;
          break;
        case SearchResultType.radioStation:
          counts['radioStation'] = (counts['radioStation'] ?? 0) + 1;
          break;
      }
    }
    return counts;
  }

  @override
  void initState() {
    super.initState();

    // ✅ حساب مرة واحدة
    _reciters = RadioStationsData.all
        .where((s) => s.supportsDownload)
        .toList();
    _recitersCount = _reciters.length;
    _stationsCount = RadioStationsData.all.length;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await GlobalSearchService.initRecentSearches();
      if (mounted) {
        _focusNode.requestFocus();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim() == _lastQuery.trim()) return;

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      _lastQuery = query.trim();
      final trimmed = query.trim();

      if (trimmed.isEmpty) {
        setState(() {
          _isSearching = false;
          _results = [];
          _activeFilterKey = null; // ✅ reset filter عند مسح البحث
        });
        return;
      }

      final results = GlobalSearchService.search(
        trimmed,
        categories: widget.categories,
      );

      setState(() {
        _isSearching = true;
        _results = results;
        // ✅ reset filter إذا النتائج قليلة
        if (_activeFilterKey != null && _activeFilterKey != 'all') {
          final counts = _filterCounts;
          if ((counts[_activeFilterKey] ?? 0) == 0) {
            _activeFilterKey = null;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safePadding = MediaQuery.of(context).padding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadioColors.background(context),
        body: Column(
          children: [
            SizedBox(height: safePadding.top),
            _buildSearchBar(isDark),
            Expanded(
              child: _isSearching
                  ? _buildSearchContent(isDark)
                  : _buildSuggestions(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent(bool isDark) {
    final filtered = _filteredResults;
    final counts = _filterCounts; // ✅ حساب مرة واحدة

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Text(
                '${_results.length} نتيجة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const Spacer(),
              if (_activeFilterKey != null && _activeFilterKey != 'all')
                Text(
                  'بعد الفلترة: ${filtered.length}',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: widget.primary.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ),

        _buildFilterBar(isDark, counts), // ✅ تمرير counts جاهزة
        const SizedBox(height: 10),

        Expanded(
          child: _results.isEmpty
              ? _buildNoResults(isDark)
              : filtered.isEmpty
              ? _buildNoFilterResults(isDark)
              : _buildFilteredResultsList(filtered, isDark),
        ),
      ],
    );
  }

  Widget _buildNoFilterResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧩', style: TextStyle(fontSize: 42)),
          const SizedBox(height: 12),
          Text(
            'لا توجد نتائج لهذا الفلتر',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'جرّب اختيار فلتر آخر',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredResultsList(
      List<SearchResult> filtered,
      bool isDark,
      ) {
    return RepaintBoundary(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        physics: const BouncingScrollPhysics(),
        itemCount: filtered.length,
        addAutomaticKeepAlives: false,
        itemBuilder: (_, i) => _buildResultTile(filtered[i], isDark),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      height: 50,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.primary.withOpacity(isDark ? 0.2 : 0.15),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),

          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textDirection: TextDirection.rtl,
              onChanged: _onSearchChanged,
              // ✅ تحسين الـ keyboard
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن قارئ، سورة، حفلة، تلاوة...',
                hintStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // ✅ Summary أصغر مع AnimatedSwitcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: (_isSearching && _results.isNotEmpty)
                ? Padding(
              key: const ValueKey('summary'),
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Text(
                _getResultsSummary(),
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),

          // ✅ AnimatedSwitcher لزر المسح
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _controller.text.isNotEmpty
                ? GestureDetector(
              key: const ValueKey('clear'),
              onTap: () {
                _controller.clear();
                _onSearchChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            )
                : const SizedBox.shrink(key: ValueKey('no-clear')),
          ),
        ],
      ),
    );
  }

  String _getResultsSummary() {
    final counts = _filterCounts;
    final parts = <String>[];

    if ((counts['reciter'] ?? 0) > 0) parts.add('${counts['reciter']} قارئ');
    if ((counts['surah'] ?? 0) > 0) parts.add('${counts['surah']} سورة');
    if ((counts['subItem'] ?? 0) > 0) parts.add('${counts['subItem']} تلاوة');
    if ((counts['radioStation'] ?? 0) > 0) {
      parts.add('${counts['radioStation']} محطة');
    }

    return parts.join(' • ');
  }

  // ✅ إصلاح _buildFilterBar - يقبل counts جاهزة
  Widget _buildFilterBar(bool isDark, Map<String, int> filterCounts) {
    const filters = <Map<String, String>>[
      {'label': 'الكل', 'key': 'all', 'emoji': '🌐'},
      {'label': 'قراء', 'key': 'reciter', 'emoji': '📖'},
      {'label': 'سور', 'key': 'surah', 'emoji': '📘'},
      {'label': 'أقسام', 'key': 'category', 'emoji': '📂'},
      {'label': 'تلاوات', 'key': 'subItem', 'emoji': '🎵'},
      {'label': 'مجموعات', 'key': 'subSection', 'emoji': '📁'},
      {'label': 'محطات', 'key': 'radioStation', 'emoji': '📻'},
    ];

    // ✅ إصلاح البق: فلتر بناءً على key وليس type
    final visibleFilters = filters.where((f) {
      final key = f['key']!;
      if (key == 'all') return true;
      return (filterCounts[key] ?? 0) > 0;
    }).toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: visibleFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = visibleFilters[i];
          final key = item['key']!;
          final isActive = _activeFilterKey == key ||
              (_activeFilterKey == null && key == 'all');
          final count = filterCounts[key] ?? 0;

          return GestureDetector(
            onTap: () => setState(() {
              _activeFilterKey = key == 'all' ? null : key;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? widget.primary.withOpacity(0.18)
                    : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? widget.primary.withOpacity(0.35)
                      : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['emoji']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    item['label']!,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? widget.primary
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? widget.primary.withOpacity(0.2)
                            : (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.06)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.cairo(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? widget.primary
                              : (isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _highlightText(String text, String query, bool isDark) {
    if (query.isEmpty) {
      return Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) {
      return Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final before = text.substring(0, startIndex);
    final match = text.substring(startIndex, startIndex + query.length);
    final after = text.substring(startIndex + query.length);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: TextStyle(
              color: widget.primary,
              backgroundColor: widget.primary.withOpacity(0.15),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  Widget _buildSuggestions(bool isDark) {
    final suggestions = GlobalSearchService.getSuggestions();
    final recent = GlobalSearchService.recentSearches;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildQuickStats(isDark),
        const SizedBox(height: 16),

        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(width: 6),
              Text(
                'بحث سابق',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await GlobalSearchService.clearRecentSearches();
                  if (mounted) setState(() {});
                },
                child: Text(
                  'مسح',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.red.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent
                .map((r) => _buildChip(r, Icons.history_rounded, isDark))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // ✅ Selector بدل Consumer للمشغل الحالي
        Selector<AudioCoordinator, bool>(
          selector: (_, c) => c.hasActivePlayer,
          builder: (_, hasPlayer, __) {
            if (!hasPlayer) return const SizedBox.shrink();

            return Consumer<AudioCoordinator>(
              builder: (_, coordinator, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.headphones_rounded,
                          size: 16, color: widget.primary),
                      const SizedBox(width: 6),
                      Text(
                        'يستمع الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.primary
                          .withOpacity(isDark ? 0.1 : 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.primary.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          coordinator.currentEmoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                coordinator.currentName,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                coordinator.currentSubtitle,
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),

        Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, size: 16, color: _gold),
            const SizedBox(width: 6),
            Text(
              'اقتراحات',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map((s) => _buildChip(s, Icons.search_rounded, isDark))
              .toList(),
        ),

        if (widget.categories.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                'الأقسام المتاحة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.categories.map(
                (cat) => _CategoryTile(
              cat: cat,
              isDark: isDark,
              onTap: () {
                _controller.text = cat.title;
                _onSearchChanged(cat.title);
              },
            ),
          ),
        ],

        // ✅ حساب العناصر المحملة خارج Consumer
        _DownloadedItemsSection(
          isDark: isDark,
          reciters: _reciters,
          onTap: (title) {
            _controller.text = title;
            _onSearchChanged(title);
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Row(
      children: [
        _statCard('$_recitersCount', 'قارئ', Icons.person_rounded,
            Colors.purple, isDark),
        const SizedBox(width: 8),
        _statCard('114', 'سورة', Icons.menu_book_rounded, Colors.blue, isDark),
        const SizedBox(width: 8),
        _statCard('${widget.categories.length}', 'قسم', Icons.folder_rounded,
            Colors.orange, isDark),
        const SizedBox(width: 8),
        _statCard('$_stationsCount', 'محطة', Icons.radio_rounded, Colors.red,
            isDark),
      ],
    );
  }

  Widget _statCard(
      String value,
      String label,
      IconData icon,
      Color color,
      bool isDark,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text, IconData icon, bool isDark) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _onSearchChanged(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(SearchResult result, bool isDark) {
    return GestureDetector(
      onTap: () => _onResultTap(result),
      onLongPress: () => _showResultOptions(result),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getTypeColors(result.type),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  result.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ استخدام _highlightText
                  _highlightText(result.title, _lastQuery, isDark),
                  Text(
                    result.subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getTypeColor(result.type).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.typeLabel,
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _getTypeColor(result.type),
                ),
              ),
            ),

            // ✅ Selector بدل Consumer لتقليل إعادة البناء
            _DownloadBadge(result: result),

            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  void _showResultOptions(SearchResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultOptionsSheet(
        result: result,
        isDark: isDark,
        primary: widget.primary,
        onOpen: () {
          Navigator.pop(context);
          _onResultTap(result);
        },
      ),
    );
  }

  Color _getTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.reciter:
        return Colors.purple;
      case SearchResultType.surah:
        return Colors.blue;
      case SearchResultType.category:
        return Colors.orange;
      case SearchResultType.subItem:
        return Colors.green;
      case SearchResultType.subSection:
        return Colors.teal;
      case SearchResultType.radioStation:
        return Colors.red;
    }
  }

  List<Color> _getTypeColors(SearchResultType type) {
    final base = _getTypeColor(type);
    return [base.withOpacity(0.3), base.withOpacity(0.1)];
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 14),
          Text(
            'لا توجد نتائج لـ "${_controller.text}"',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'جرّب البحث بكلمة مختلفة',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  void _onResultTap(SearchResult result) {
    GlobalSearchService.addRecentSearch(_controller.text);

    switch (result.type) {
      case SearchResultType.reciter:
        if (result.station != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecitationSurahsScreen(
                station: result.station!,
                primary: widget.primary,
              ),
            ),
          );
        }
        break;

      case SearchResultType.surah:
        _showReciterPicker(result);
        break;

      case SearchResultType.category:
        break;

      case SearchResultType.subSection:
        if (result.recitationItem != null &&
            result.recitationItem!.hasSubItems) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecSubItemsScreen(
                parentItem: result.recitationItem!,
                primary: widget.primary,
              ),
            ),
          );
        }
        break;

      case SearchResultType.subItem:
        if (result.subItem != null && result.parentItem != null) {
          final coordinator = context.read<AudioCoordinator>();
          final station = IslamicRadioStation(
            id: result.subItem!.audioUrl.hashCode.abs(),
            name: result.subItem!.title,
            nameEn: result.subItem!.title,
            url: result.subItem!.audioUrl,
            category: result.parentItem!.title,
            categoryEn: 'Recitations',
            description: result.subItem!.subtitle,
            descriptionEn: result.subItem!.subtitle,
            iconEmoji: result.subItem!.emoji,
            imageUrl: result.subItem!.imageUrl,
          );

          coordinator.playOnlineRadio(station);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecItemPlayerScreen(
                item: RecitationItem(
                  title: result.subItem!.title,
                  subtitle: result.subItem!.subtitle,
                  emoji: result.subItem!.emoji,
                  audioUrl: result.subItem!.audioUrl,
                  imageUrl: result.subItem!.imageUrl,
                ),
                primary: widget.primary,
                station: station,
                isLocal: false,
              ),
            ),
          );
        } else if (result.recitationItem?.station != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecitationSurahsScreen(
                station: result.recitationItem!.station!,
                primary: widget.primary,
              ),
            ),
          );
        }
        break;

      case SearchResultType.radioStation:
        if (result.station != null) {
          context.read<AudioCoordinator>().playOnlineRadio(result.station!);
          Navigator.pop(context);
        }
        break;
    }
  }

  void _showReciterPicker(SearchResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ReciterPickerSheet(
        result: result,
        reciters: _reciters, // ✅ استخدام الـ cache
        isDark: isDark,
        primary: widget.primary,
        onReciterSelected: (reciter) {
          Navigator.pop(context);
          _showPlayOptions(result: result, reciter: reciter);
        },
      ),
    );
  }

  void _showPlayOptions({
    required SearchResult result,
    required IslamicRadioStation reciter,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahNumber = result.surahNumber ?? 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PlayOptionsSheet(
        result: result,
        reciter: reciter,
        surahNumber: surahNumber,
        isDark: isDark,
        primary: widget.primary,
        onPlayOnline: () {
          Navigator.pop(sheetContext);
          final coordinator = context.read<AudioCoordinator>();
          coordinator.playOnlineSurah(
            station: reciter,
            surahNumber: surahNumber,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahPlayerScreen(
                station: reciter,
                surahNumber: surahNumber,
                primary: widget.primary,
                isOnline: true,
              ),
            ),
          );
        },
        onOpenReciter: () {
          Navigator.pop(sheetContext);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecitationSurahsScreen(
                station: reciter,
                primary: widget.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// ✅ Widgets مستقلة لتقليل إعادة البناء
// ══════════════════════════════════════════

/// شارة التحميل في نتيجة البحث
class _DownloadBadge extends StatelessWidget {
  final SearchResult result;

  const _DownloadBadge({required this.result});

  String? _getAudioUrl() {
    if (result.type == SearchResultType.surah &&
        result.station != null &&
        result.surahNumber != null) {
      return result.station!.surahStreamUrl(result.surahNumber!);
    } else if (result.subItem != null) {
      return result.subItem!.audioUrl;
    } else if (result.recitationItem?.audioUrl != null) {
      return result.recitationItem!.audioUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final audioUrl = _getAudioUrl();
    if (audioUrl == null || audioUrl.isEmpty) return const SizedBox.shrink();

    final tempItem = RecitationItem(
      title: result.title,
      subtitle: result.subtitle,
      emoji: result.emoji,
      audioUrl: audioUrl,
    );
    final itemId = ItemDownloadService.itemIdFromRecitationItem(tempItem);

    return Selector<ItemDownloadService, bool>(
      selector: (_, s) => s.isDownloaded(itemId),
      builder: (_, isDownloaded, __) {
        if (!isDownloaded) return const SizedBox.shrink();
        return const Padding(
          padding: EdgeInsets.only(right: 6),
          child: Icon(
            Icons.download_done_rounded,
            size: 13,
            color: Colors.green,
          ),
        );
      },
    );
  }
}

/// قسم العناصر المحملة في الـ Suggestions
class _DownloadedItemsSection extends StatelessWidget {
  final bool isDark;
  final List<IslamicRadioStation> reciters;
  final void Function(String title) onTap;

  const _DownloadedItemsSection({
    required this.isDark,
    required this.reciters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ItemDownloadService, List<Map<String, String>>>(
      selector: (_, service) {
        final items = <Map<String, String>>[];
        for (final station in reciters) {
          for (final surah in QuranData.surahs) {
            final url = station.surahStreamUrl(surah.number);
            if (url == null) continue;
            final tempItem = RecitationItem(
              title: surah.name,
              subtitle: station.name,
              emoji: station.iconEmoji,
              audioUrl: url,
            );
            final itemId =
            ItemDownloadService.itemIdFromRecitationItem(tempItem);
            if (service.isDownloaded(itemId)) {
              items.add({
                'title': 'سورة ${surah.name}',
                'subtitle': station.name,
                'emoji': station.iconEmoji,
              });
              if (items.length >= 10) break; // ✅ حد أقصى
            }
          }
          if (items.length >= 10) break;
        }
        return items;
      },
      shouldRebuild: (prev, next) => prev.length != next.length,
      builder: (_, downloadedItems, __) {
        if (downloadedItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.download_done_rounded,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  'محملة على جهازك (${downloadedItems.length})',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: downloadedItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final item = downloadedItems[i];
                  return GestureDetector(
                    onTap: () => onTap(item['title']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(isDark ? 0.08 : 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item['emoji']!,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item['title']!,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tile لعرض القسم في الـ Suggestions
class _CategoryTile extends StatelessWidget {
  final RecitationCategory cat;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.cat,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat.title,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${cat.items.length} عنصر • ${cat.description}',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet خيارات النتيجة
class _ResultOptionsSheet extends StatelessWidget {
  final SearchResult result;
  final bool isDark;
  final Color primary;
  final VoidCallback onOpen;

  const _ResultOptionsSheet({
    required this.result,
    required this.isDark,
    required this.primary,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            result.subtitle,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          _OptionTileWidget(
            icon: Icons.open_in_new_rounded,
            label: 'فتح',
            subtitle: 'الانتقال إلى ${result.typeLabel}',
            color: primary,
            isDark: isDark,
            onTap: onOpen,
          ),
          const SizedBox(height: 8),
          _OptionTileWidget(
            icon: Icons.copy_rounded,
            label: 'نسخ الاسم',
            subtitle: result.title,
            color: Colors.blue,
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: result.title));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم نسخ "${result.title}"',
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Sheet اختيار القارئ
class _ReciterPickerSheet extends StatelessWidget {
  final SearchResult result;
  final List<IslamicRadioStation> reciters;
  final bool isDark;
  final Color primary;
  final void Function(IslamicRadioStation) onReciterSelected;

  const _ReciterPickerSheet({
    required this.result,
    required this.reciters,
    required this.isDark,
    required this.primary,
    required this.onReciterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.subtitle,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اختر القارئ',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: reciters.length,
              itemBuilder: (context, i) {
                final reciter = reciters[i];
                return GestureDetector(
                  onTap: () => onReciterSelected(reciter),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primary.withOpacity(0.2),
                                primary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              reciter.iconEmoji,
                              style: const TextStyle(fontSize: 20),
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
                                reciter.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                reciter.description,
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Sheet خيارات التشغيل
class _PlayOptionsSheet extends StatelessWidget {
  final SearchResult result;
  final IslamicRadioStation reciter;
  final int surahNumber;
  final bool isDark;
  final Color primary;
  final VoidCallback onPlayOnline;
  final VoidCallback onOpenReciter;

  const _PlayOptionsSheet({
    required this.result,
    required this.reciter,
    required this.surahNumber,
    required this.isDark,
    required this.primary,
    required this.onPlayOnline,
    required this.onOpenReciter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Text(result.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'بصوت ${reciter.name}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _OptionTileWidget(
            icon: Icons.play_circle_rounded,
            label: 'استماع مباشر',
            subtitle: 'يحتاج اتصال بالإنترنت',
            color: primary,
            isDark: isDark,
            onTap: onPlayOnline,
          ),
          const SizedBox(height: 10),

          _OptionTileWidget(
            icon: Icons.library_music_rounded,
            label: 'فتح صفحة ${reciter.name}',
            subtitle: 'عرض كل السور',
            color: Colors.teal,
            isDark: isDark,
            onTap: onOpenReciter,
          ),
          const SizedBox(height: 10),

          // ✅ Download section
          _DownloadSection(
            reciter: reciter,
            surahNumber: surahNumber,
            surahName: result.surah?.name ?? '',
            isDark: isDark,
            primary: primary,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// قسم التحميل
class _DownloadSection extends StatelessWidget {
  final IslamicRadioStation reciter;
  final int surahNumber;
  final String surahName;
  final bool isDark;
  final Color primary;

  const _DownloadSection({
    required this.reciter,
    required this.surahNumber,
    required this.surahName,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final surahUrl = reciter.surahStreamUrl(surahNumber);
    if (surahUrl == null || surahUrl.isEmpty) return const SizedBox.shrink();

    final tempItem = RecitationItem(
      title: surahName,
      subtitle: reciter.name,
      emoji: reciter.iconEmoji,
      audioUrl: surahUrl,
      imageUrl: reciter.imageUrl,
    );
    final itemId = ItemDownloadService.itemIdFromRecitationItem(tempItem);

    return Selector<ItemDownloadService,
        ({bool isDownloaded, bool isDownloading, double progress})>(
      selector: (_, service) => (
      isDownloaded: service.isDownloaded(itemId),
      isDownloading:
      service.getStatus(itemId) == ItemDownloadStatus.downloading,
      progress: service.getProgress(itemId),
      ),
      builder: (_, state, __) {
        if (state.isDownloaded) {
          return _DownloadedState(
            isDark: isDark,
            onDelete: () =>
                context.read<ItemDownloadService>().deleteDownload(itemId),
          );
        }

        if (state.isDownloading) {
          return _DownloadingState(
            isDark: isDark,
            surahName: surahName,
            reciterName: reciter.name,
            progress: state.progress,
            onCancel: () =>
                context.read<ItemDownloadService>().cancelDownload(itemId),
          );
        }

        return _OptionTileWidget(
          icon: Icons.download_rounded,
          label: 'تحميل السورة',
          subtitle: 'للاستماع بدون إنترنت',
          color: Colors.green,
          isDark: isDark,
          onTap: () {
            final stationDir = reciter.name
                .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
                .replaceAll(RegExp(r'\s+'), '_');
            final surahFile = surahName
                .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
                .replaceAll(RegExp(r'\s+'), '_');

            context.read<ItemDownloadService>().downloadItem(
              tempItem,
              customDir: stationDir,
              customFileName: surahFile,
            );
          },
        );
      },
    );
  }
}

class _DownloadedState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onDelete;

  const _DownloadedState({required this.isDark, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.download_done_rounded,
              color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تم التحميل ✓',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'السورة محفوظة على جهازك',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Colors.green.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'حذف',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadingState extends StatelessWidget {
  final bool isDark;
  final String surahName;
  final String reciterName;
  final double progress;
  final VoidCallback onCancel;

  const _DownloadingState({
    required this.isDark,
    required this.surahName,
    required this.reciterName,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.downloading_rounded,
                  color: Colors.orange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'جاري التحميل...',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'سورة $surahName بصوت $reciterName',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.orange.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCancel,
                child: const Icon(Icons.close_rounded,
                    color: Colors.orange, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              backgroundColor: Colors.orange.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(Colors.orange),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile خيار إجراء
class _OptionTileWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionTileWidget({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}