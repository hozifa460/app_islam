import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../languages/app_localizations.dart';
import '../../services/asma_allah_service.dart';
import 'all_names/asma_name_card.dart';
import 'asma_allah_detail_screen.dart';
import 'widgets/asma_theme.dart';
import 'widgets/asma_painters.dart';
import 'widgets/asma_shared_widgets.dart';

class AsmaAllahAllNamesScreen extends StatefulWidget {
  final Color primaryColor;

  const AsmaAllahAllNamesScreen({
    super.key,
    required this.primaryColor,
  });

  @override
  State<AsmaAllahAllNamesScreen> createState() =>
      _AsmaAllahAllNamesScreenState();
}

class _AsmaAllahAllNamesScreenState extends State<AsmaAllahAllNamesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, String>> _allNames = [];
  bool _isLoading = true;
  bool _isSearchFocused = false;

  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadNames();
    }
  }

  Future<void> _loadNames() async {
    try {
      final String currentLang = context.tr.locale.languageCode; // ط¬ظ„ط¨ ظƒظˆط¯ ط§ظ„ظ„ط؛ط©
      final data = await AsmaAllahService.getNamesSimple(currentLang); // طھظ…ط±ظٹط±ظ‡ط§ ظ„ظ„ظ€ Service
      if (mounted) {
        setState(() {
          _allNames = data;
          _isLoading = false;
        });
        _staggerController.forward();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, String>> get _filteredNames {
    if (_searchQuery.isEmpty) return _allNames;
    return _allNames.where((item) {
      final name = item['name'] ?? '';
      final meaning = item['meaning'] ?? '';
      return name.contains(_searchQuery) || meaning.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = AsmaTheme(isDark: isDark);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Directionality(
      textDirection: context.tr.textDirection, // ًں‘ˆ طھظ…طھ ط§ظ„ط¥ط¶ط§ظپط© ظ„ظٹط¯ط¹ظ… ط§ظ„ظ„ط؛ط§طھ LTR
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.bgGradientAlt,
            ),
          ),
          child: Stack(
            children: [
              // ط§ظ„ظ†ظ‚ظˆط´
              Positioned.fill(
                child: CustomPaint(
                  painter: AsmaIslamicPatternPainter(
                    color: AsmaTheme.gold
                        .withValues(alpha: isDark ? 0.025 : 0.04),
                    step: 65,
                    sides: 6,
                  ),
                ),
              ),

              // ط§ظ„ظ…ط­طھظˆظ‰
              Column(
                children: [
                  _buildAppBar(context, isDark),
                  _buildSearchBar(isDark),
                  _buildCountBadge(isDark),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState(isDark)
                        : _filteredNames.isEmpty
                        ? _buildEmptyState(isDark)
                        : _buildNamesGrid(isDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // AppBar
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildAppBar(BuildContext context, bool isDark) {
    final theme = AsmaTheme(isDark: isDark);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.allNamesAppBarGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : AsmaTheme.gold.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AsmaAppBarIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        context.tr.asmaAllahTitle, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط© (ظ…ظˆط¬ظˆط¯ط© ظ…ط³ط¨ظ‚ط§ظ‹)
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AsmaMiniDot(),
                          Container(
                            width: 40,
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AsmaTheme.gold
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: Text(
                              context.tr.ninetyNineNames, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط© (ظ…ظˆط¬ظˆط¯ط© ظ…ط³ط¨ظ‚ط§ظ‹)
                              style: GoogleFonts.cairo(
                                color: AsmaTheme.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AsmaTheme.gold,
                                  Colors.transparent
                                ],
                              ),
                            ),
                          ),
                          const AsmaMiniDot(),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  AsmaAppBarIconButton(
                    icon: Icons.auto_awesome_rounded,
                    onTap: () {},
                    isDecorative: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط±ظٹط· ط§ظ„ط¨ط­ط«
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
              const Color(0xFF1A2438).withValues(alpha: 0.9),
              const Color(0xFF0F1628).withValues(alpha: 0.9),
            ]
                : [Colors.white, const Color(0xFFFFF8E8)],
          ),
          borderRadius:
          BorderRadius.circular(AsmaTheme.searchRadius),
          border: Border.all(
            color: _isSearchFocused
                ? AsmaTheme.gold
                : AsmaTheme.gold.withValues(alpha: isDark ? 0.2 : 0.25),
            width: _isSearchFocused ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isSearchFocused
                  ? AsmaTheme.gold.withValues(alpha: 0.2)
                  : (isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : AsmaTheme.gold.withValues(alpha: 0.08)),
              blurRadius: _isSearchFocused ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: _isSearchFocused
                  ? AsmaTheme.gold
                  : (isDark
                  ? Colors.white54
                  : AsmaTheme.brownSub),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Focus(
                onFocusChange: (focused) {
                  setState(() => _isSearchFocused = focused);
                },
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value.trim());
                  },
                  style: GoogleFonts.cairo(
                    color: isDark ? Colors.white : AsmaTheme.brownText,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr.searchNameOrMeaningHint, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                    hintStyle: GoogleFonts.cairo(
                      color: isDark
                          ? Colors.white38
                          : AsmaTheme.brownSub.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AsmaTheme.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AsmaTheme.gold, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط§ط±ط© ط§ظ„ط¹ط¯ط¯
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildCountBadge(bool isDark) {
    final count = _filteredNames.length;
    final isFiltered = _searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AsmaTheme.gold.withValues(alpha: 0.15),
                  AsmaTheme.gold.withValues(alpha: 0.08)
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AsmaTheme.gold.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFiltered
                      ? Icons.filter_list_rounded
                      : Icons.grid_view_rounded,
                  color: AsmaTheme.gold,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isFiltered ? context.tr.resultsCount(count) :
                  context.tr.namesCount(count), // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                  style: GoogleFonts.cairo(
                    color: isDark ? AsmaTheme.gold : AsmaTheme.goldDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (isFiltered)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear_all_rounded,
                        color: isDark
                            ? Colors.white70
                            : Colors.black54,
                        size: 16),
                    const SizedBox(width: 4),
                    Text(
                      context.tr.clearFilter, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                      style: GoogleFonts.cairo(
                        color: isDark
                            ? Colors.white70
                            : Colors.black54,
                        fontSize: 12,
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

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط­ط§ظ„ط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                  color: AsmaTheme.gold, strokeWidth: 3)),
          const SizedBox(height: 20),
          Text(context.tr.loadingNames, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white54 : AsmaTheme.brownSub,
                fontSize: 15,
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AsmaTheme.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded,
                color: AsmaTheme.gold.withValues(alpha: 0.5), size: 48),
          ),
          const SizedBox(height: 20),
          Text(context.tr.noMatchingResults, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
              style: GoogleFonts.cairo(
                fontSize: 17,
                color: isDark ? Colors.white70 : AsmaTheme.brownSub,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 8),
          Text(context.tr.tryAnotherSearch, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              )),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط¨ظƒط© ط§ظ„ط£ط³ظ…ط§ط،
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildNamesGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 360;
        final isMedium = width < 430;

        final crossAxisCount = isSmall ? 2 : (isMedium ? 2 : 3);
        final spacing = isSmall ? 12.0 : 14.0;
        final padding = isSmall ? 16.0 : 20.0;

        final usableWidth =
            width - (padding * 2) - (spacing * (crossAxisCount - 1));
        final itemWidth = usableWidth / crossAxisCount;
        final itemHeight = isSmall ? 200.0 : 220.0;  // âœ… ظƒط§ظ† 185 ظˆ 200
        final childAspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
          itemCount: _filteredNames.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final item = _filteredNames[index];
            final originalIndex = _allNames.indexOf(item) + 1;

            return AsmaNameCard(
              name: item['name']!,
              displayName: item['displayName'] ?? item['name']!,     // âœ…
              arabicName: item['arabicName'] ?? '',                   // âœ…
              meaning: item['meaning']!,
              order: originalIndex,
              isDark: isDark,
              isSmall: isSmall,
              primaryColor: widget.primaryColor,
              onTap: () => _navigateToDetail(context, item, originalIndex),
            );
          },
        );
      },
    );
  }

  void _navigateToDetail(
      BuildContext context, Map<String, String> item, int order) {
    final heroTag = 'asma_name_$order';

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) {
          return AsmaAllahDetailScreen(
            fullName: item['name']!,
            displayName: item['displayName'] ?? item['name']!,
            meaning: item['meaning']!,
            primaryColor: widget.primaryColor,
            order: order,
            names: _allNames,
            heroTag: heroTag,
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}