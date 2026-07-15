import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/mircle/widgets/miracle_card_widget.dart';
import 'package:islamic_app/screens/mircle/widgets/miracle_helpers.dart';
import 'package:islamic_app/screens/mircle/color_control/miracle_theme.dart';
import 'package:islamic_app/screens/mircle/widgets/star_field_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mircle_detail_screen.dart';

class CategoryMiraclesScreen extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> miracles;
  final Color primaryColor;
  final Set<int> initialFavorites;

  const CategoryMiraclesScreen({
    super.key,
    required this.categoryName,
    required this.miracles,
    required this.primaryColor,
    required this.initialFavorites,
  });

  @override
  State<CategoryMiraclesScreen> createState() => _CategoryMiraclesScreenState();
}

class _CategoryMiraclesScreenState extends State<CategoryMiraclesScreen>
    with TickerProviderStateMixin {
  // â”€â”€ Controllers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _headerController;
  late Animation<double> _headerAnim;

  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all / quran / sunnah
  bool _showSearch = false;
  bool _showFavOnly = false;
  Set<int> _favorites = {};

  final List<StarParticle> _particles = [];
  final _rng = Random();

  // â”€â”€ Init â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  void initState() {
    super.initState();

    _favorites = Set.from(widget.initialFavorites);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerAnim = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );

    // Generate particles
    for (int i = 0; i < 65; i++) {
      _particles.add(StarParticle.random(_rng));
    }

    _animController.forward();
    _headerController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  // â”€â”€ Favorites â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _toggleFavorite(int id) async {
    setState(() {
      _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'miracle_favorites',
        _favorites.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      debugPrint('saveFav: $e');
    }
  }

  // â”€â”€ Computed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Miracles of this category only
  List<Map<String, dynamic>> get _categoryMiracles =>
      widget.miracles
          .where((m) => m['category'] == widget.categoryName)
          .toList();

  int get _quranCount =>
      _categoryMiracles.where((m) => m['type'] == 'quran').length;
  int get _sunnahCount =>
      _categoryMiracles.where((m) => m['type'] == 'sunnah').length;
  int get _favCount =>
      _categoryMiracles.where((m) => _favorites.contains(m['id'])).length;

  List<Map<String, dynamic>> get _filtered {
    return _categoryMiracles.where((item) {
      // Favorites filter
      if (_showFavOnly) {
        final id = item['id'];
        if (id == null || !_favorites.contains(id)) return false;
      }

      // Type filter
      if (_selectedFilter != 'all' && item['type'] != _selectedFilter)
        return false;

      // Search
      final q = _searchQuery.trim();
      if (q.isEmpty) return true;

      return [
        item['title'],
        item['subtitle'],
        item['description'],
        item['source'],
        item['scientificExplanation'],
        item['scientist'],
      ].any((v) => (v ?? '').toString().contains(q));
    }).toList();
  }

  // â”€â”€ Navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _toDetail(Map<String, dynamic> item) async {
    final id = item['id'] ?? 0;
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => MiracleDetailScreen(
              item: item,
              primaryColor: widget.primaryColor,
              isFavorite: _favorites.contains(id),
              onToggleFavorite: () => _toggleFavorite(id),
            ),
        transitionsBuilder:
            (_, anim, __, child) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            ),
        transitionDuration: const Duration(milliseconds: 340),
      ),
    );
    setState(() {});
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = MiracleTheme.of(isDark);

    final catColor = MiracleHelpers.getCategoryColor(widget.categoryName);
    final catIcon = MiracleHelpers.getCategoryIcon(widget.categoryName);
    final emoji = MiracleHelpers.getCategoryEmoji(widget.categoryName);
    final engName = MiracleHelpers.getCategoryEnglish(widget.categoryName);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: t.bg1,
          child: Stack(
            children: [
              // ط®ظ„ظپظٹط© ظ…طھط­ط±ظƒط©
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  color: t.bg1,
                ),
              ),
              // ظ†ط¬ظˆظ…
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder:
                      (_, __) => StarFieldWidget(
                        particles: _particles,
                        animValue: _particleController.value,
                        starOpacityFactor: t.starOpacityFactor,
                        nebulaOpacityFactor: t.nebulaOpacityFactor,
                        primaryColor: t.neonBlue,
                        bg1: t.bg1,
                      ),
                ),
              ),
              // Scaffold ط´ظپط§ظپ ظ„ظ„ظ€ AppBar ظپظ‚ط·
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    // â”€â”€ Star field â”€â”€
                    AnimatedBuilder(
                      animation: _particleController,
                      builder:
                          (_, __) => StarFieldWidget(
                            particles: _particles,
                            animValue: _particleController.value,
                            starOpacityFactor: t.starOpacityFactor,
                            nebulaOpacityFactor: t.nebulaOpacityFactor,
                            primaryColor: t.neonBlue,
                            bg1: t.bg1,
                          ),
                    ),

                    // â”€â”€ Main content â”€â”€
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // â”€â”€ App Bar â”€â”€
                          _buildAppBar(t, catColor, catIcon, emoji, engName),

                          // â”€â”€ Stats row â”€â”€
                          SliverToBoxAdapter(
                            child: _buildStatsRow(t, catColor),
                          ),

                          // â”€â”€ Filter chips â”€â”€
                          SliverToBoxAdapter(
                            child: _buildFilterRow(t, catColor),
                          ),

                          // â”€â”€ Search bar â”€â”€
                          if (_showSearch)
                            SliverToBoxAdapter(child: _buildSearchBar(t)),

                          // â”€â”€ Results header â”€â”€
                          SliverToBoxAdapter(
                            child: _buildResultsHeader(t, catColor),
                          ),

                          // â”€â”€ Cards â”€â”€
                          _filtered.isEmpty
                              ? SliverFillRemaining(
                                child: _buildEmptyState(t, catColor),
                              )
                              : SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final item = _filtered[index];
                                    final id = item['id'] ?? index;
                                    return MiracleCardWidget(
                                      item: item,
                                      index: index,
                                      isFavorite: _favorites.contains(id),
                                      t: t,
                                      onTap: () => _toDetail(item),
                                      onFavoriteToggle:
                                          () => _toggleFavorite(id),
                                    );
                                  }, childCount: _filtered.length),
                                ),
                              ),

                          const SliverToBoxAdapter(child: SizedBox(height: 40)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  APP BAR
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildAppBar(
    MiracleThemeColors t,
    Color catColor,
    IconData catIcon,
    String emoji,
    String engName,
  ) {
    final expandedH = MediaQuery.of(context).size.height * 0.28;

    return SliverAppBar(
      expandedHeight: expandedH,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: t.bg1.withValues(alpha: 0.95),

      // Back button
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: t.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.glassBorder),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: t.text, size: 18),
          ),
        ),
      ),

      // Actions
      actions: [
        _AppBarBtn(
          icon:
              _showFavOnly
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
          color: _showFavOnly ? MiracleTheme.neonRed : t.text,
          t: t,
          onTap: () => setState(() => _showFavOnly = !_showFavOnly),
        ),
        _AppBarBtn(
          icon: _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
          color: _showSearch ? MiracleTheme.neonBlue : t.text,
          t: t,
          onTap: () => setState(() => _showSearch = !_showSearch),
        ),
        const SizedBox(width: 8),
      ],

      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 14),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.categoryName,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                shadows: [
                  Shadow(color: catColor.withValues(alpha: 0.6), blurRadius: 12),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              engName,
              style: GoogleFonts.poppins(
                color: catColor.withValues(alpha: 0.85),
                fontSize: 8,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        background: _AppBarBackground(
          t: t,
          catColor: catColor,
          catIcon: catIcon,
          emoji: emoji,
          pulseAnim: _pulseAnim,
          headerAnim: _headerAnim,
          totalCount: _categoryMiracles.length,
          categoryName: widget.categoryName,
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  STATS ROW
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildStatsRow(MiracleThemeColors t, Color catColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.menu_book_rounded,
              label: 'القرآن',
              sublabel: 'Quran',
              count: _quranCount,
              color: const Color(0xFF4FC3F7),
              t: t,
              onTap:
                  () => setState(
                    () =>
                        _selectedFilter =
                            _selectedFilter == 'quran' ? 'all' : 'quran',
                  ),
              highlighted: _selectedFilter == 'quran',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.auto_awesome_rounded,
              label: 'السنة',
              sublabel: 'Sunnah',
              count: _sunnahCount,
              color: MiracleTheme.neonGold,
              t: t,
              onTap:
                  () => setState(
                    () =>
                        _selectedFilter =
                            _selectedFilter == 'sunnah' ? 'all' : 'sunnah',
                  ),
              highlighted: _selectedFilter == 'sunnah',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.favorite_rounded,
              label: 'المفضلة',
              sublabel: 'Favorites',
              count: _favCount,
              color: MiracleTheme.neonRed,
              t: t,
              onTap: () => setState(() => _showFavOnly = !_showFavOnly),
              highlighted: _showFavOnly,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.library_books_rounded,
              label: 'الإجمالي',
              sublabel: 'Total',
              count: _categoryMiracles.length,
              color: MiracleTheme.neonGreen,
              t: t,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  FILTER ROW
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildFilterRow(MiracleThemeColors t, Color catColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: _FilterChip(
              label: 'الكل',
              icon: Icons.apps_rounded,
              selected: _selectedFilter == 'all',
              color: catColor,
              t: t,
              onTap: () => setState(() => _selectedFilter = 'all'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: 'القرآن',
              icon: Icons.menu_book_rounded,
              selected: _selectedFilter == 'quran',
              color: const Color(0xFF4FC3F7),
              t: t,
              onTap: () => setState(() => _selectedFilter = 'quran'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: 'السنة',
              icon: Icons.auto_awesome_rounded,
              selected: _selectedFilter == 'sunnah',
              color: MiracleTheme.neonGold,
              t: t,
              onTap: () => setState(() => _selectedFilter = 'sunnah'),
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  SEARCH BAR
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildSearchBar(MiracleThemeColors t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiracleTheme.neonBlue.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: MiracleTheme.neonBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        cursorColor: MiracleTheme.neonBlue,
        decoration: InputDecoration(
          hintText: 'ابحث في ${widget.categoryName}...',
          hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 13),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: MiracleTheme.neonBlue.withValues(alpha: 0.7),
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  RESULTS HEADER
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildResultsHeader(MiracleThemeColors t, Color catColor) {
    final hasFilters =
        _selectedFilter != 'all' || _searchQuery.isNotEmpty || _showFavOnly;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: catColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: catColor.withValues(alpha: 0.4), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _showFavOnly
                  ? 'المفضلة (${_filtered.length})'
                  : 'المعجزات (${_filtered.length})',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasFilters)
            GestureDetector(
              onTap:
                  () => setState(() {
                    _selectedFilter = 'all';
                    _searchQuery = '';
                    _searchController.clear();
                    _showFavOnly = false;
                  }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: MiracleTheme.neonRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MiracleTheme.neonRed.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear_all_rounded,
                      size: 14,
                      color: MiracleTheme.neonRed.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'مسح',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: MiracleTheme.neonRed.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
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

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  EMPTY STATE
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildEmptyState(MiracleThemeColors t, Color catColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: catColor.withValues(alpha: 0.08),
                border: Border.all(color: catColor.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(color: catColor.withValues(alpha: 0.1), blurRadius: 20),
                ],
              ),
              child: Icon(
                _showFavOnly
                    ? Icons.favorite_border_rounded
                    : Icons.search_off_rounded,
                size: 36,
                color: catColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _showFavOnly
                  ? 'لا توجد معجزات في المفضلة'
                  : 'لا توجد نتائج مطابقة',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _showFavOnly
                  ? 'اضغط على ❤️ لإضافة معجزات إلى المفضلة'
                  : 'جرّب تغيير البحث أو الفلاتر',
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  APP BAR BACKGROUND
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _AppBarBackground extends StatelessWidget {
  final MiracleThemeColors t;
  final Color catColor;
  final IconData catIcon;
  final String emoji;
  final String categoryName;
  final Animation<double> pulseAnim;
  final Animation<double> headerAnim;
  final int totalCount;

  const _AppBarBackground({
    required this.t,
    required this.catColor,
    required this.catIcon,
    required this.emoji,
    required this.categoryName,
    required this.pulseAnim,
    required this.headerAnim,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [catColor.withValues(alpha: 0.25), t.bg2, t.bg1],
        ),
      ),
      child: Stack(
        children: [
          // Emoji watermark
          Positioned(
            top: -20,
            right: -20,
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 160,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Glow orbs
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [catColor.withValues(alpha: 0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 60,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MiracleTheme.neonBlue.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Centre: pulsing icon + count
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ScaleTransition(
                scale: headerAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing icon
                    AnimatedBuilder(
                      animation: pulseAnim,
                      builder:
                          (_, __) => Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      catColor.withValues(alpha: 
                                        0.18 * pulseAnim.value,
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Inner circle
                              Container(
                                width: 66,
                                height: 66,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.07),
                                  border: Border.all(
                                    color: catColor.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: catColor.withValues(alpha: 
                                        0.3 * pulseAnim.value,
                                      ),
                                      blurRadius: 22,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(catIcon, color: catColor, size: 30),
                              ),
                            ],
                          ),
                    ),

                    const SizedBox(height: 8),

                    // Count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: catColor.withValues(alpha: 0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: catColor.withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        '$totalCount معجزة',
                        style: GoogleFonts.cairo(
                          color: catColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  SMALL WIDGETS
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final MiracleThemeColors t;
  final VoidCallback onTap;

  const _AppBarBtn({
    required this.icon,
    required this.color,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: t.glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.glassBorder),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final int count;
  final Color color;
  final MiracleThemeColors t;
  final VoidCallback onTap;
  final bool highlighted;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.count,
    required this.color,
    required this.t,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: highlighted ? color.withValues(alpha: 0.15) : t.glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? color.withValues(alpha: 0.5) : t.glassBorder,
            width: highlighted ? 1.5 : 1,
          ),
          boxShadow:
              highlighted
                  ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8),
                ],
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sublabel,
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: color.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final MiracleThemeColors t;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : t.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : t.glassBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow:
              selected
                  ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)]
                  : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: selected ? color : t.mutedText),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  color: selected ? color : t.mutedText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
