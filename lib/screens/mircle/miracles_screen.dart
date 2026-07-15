import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'category_miracles_screen.dart';
import 'color_control/color_picker_sheet.dart';
import 'color_control/miracle_color_provider.dart';
import 'color_control/miracle_theme.dart';
import 'mircle_detail_screen.dart';
import 'widgets/star_field_widget.dart';
import 'widgets/featured_miracle_card.dart';
import 'widgets/categories_grid.dart';
import 'widgets/stats_row_widget.dart';
import 'widgets/filter_section_widget.dart';
import 'widgets/miracle_card_widget.dart';
import 'widgets/section_title.dart';
import '../../utils/global_search_action_button.dart';

class MiraclesScreen extends StatefulWidget {
  final Color primaryColor;
  const MiraclesScreen({super.key, required this.primaryColor});

  @override
  State<MiraclesScreen> createState() => _MiraclesScreenState();
}

class _MiraclesScreenState extends State<MiraclesScreen>
    with TickerProviderStateMixin {
  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery       = '';
  String _selectedFilter    = 'all';
  String _selectedCategory  = 'all';
  bool   _showFavoritesOnly = false;
  bool   _showSearch        = false;

  List<Map<String, dynamic>> _miracles  = [];
  Set<int>                   _favorites = {};
  bool                       _loading   = true;

  // â”€â”€ Animation Controllers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double>   _pulseAnim;
  late AnimationController _featuredController;
  late Animation<double>   _featuredAnim;

  // â”€â”€ Particles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final List<StarParticle> _particles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve:  Curves.easeOutCubic,
    );

    _particleController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _featuredController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1100),
    );
    _featuredAnim = CurvedAnimation(
      parent: _featuredController,
      curve:  Curves.easeOutBack,
    );

    for (int i = 0; i < 65; i++) {
      _particles.add(StarParticle.random(_rng));
    }

    _loadFavorites().then((_) => _loadMiracles());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _featuredController.dispose();
    super.dispose();
  }

  // â”€â”€ Persistence â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _loadFavorites() async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('miracle_favorites') ?? [];
      if (!mounted) return;
      setState(() {
        _favorites = favList
            .map((e) => int.tryParse(e) ?? -1)
            .where((e) => e != -1)
            .toSet();
      });
    } catch (e) {
      debugPrint('loadFavorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'miracle_favorites',
        _favorites.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      debugPrint('saveFavorites: $e');
    }
  }

  void _toggleFavorite(int id) {
    setState(() {
      _favorites.contains(id)
          ? _favorites.remove(id)
          : _favorites.add(id);
    });
    _saveFavorites();
  }

  // â”€â”€ Data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _loadMiracles() async {
    try {
      final raw  = await rootBundle.loadString('assets/mircle/miracles.json');
      final data = json.decode(raw) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _miracles = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading  = false;
      });
      _animController.forward();
      _featuredController.forward();
    } catch (e) {
      debugPrint('loadMiracles: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // â”€â”€ Computed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<String> get _categories {
    return _miracles
        .map((m) => (m['category'] ?? '').toString())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<Map<String, dynamic>> get _filteredMiracles {
    return _miracles.where((item) {
      if (_showFavoritesOnly) {
        final id = item['id'];
        if (id == null || !_favorites.contains(id)) return false;
      }
      if (_selectedFilter != 'all' &&
          item['type'] != _selectedFilter) return false;
      if (_selectedCategory != 'all' &&
          item['category'] != _selectedCategory) return false;

      final q = _searchQuery.trim();
      if (q.isEmpty) return true;

      return [
        item['title'],
        item['subtitle'],
        item['description'],
        item['source'],
        item['category'],
        item['scientificExplanation'],
        item['scientist'],
      ].any((v) => (v ?? '').toString().contains(q));
    }).toList();
  }

  int get _quranCount  =>
      _miracles.where((m) => m['type'] == 'quran').length;
  int get _sunnahCount =>
      _miracles.where((m) => m['type'] == 'sunnah').length;
  int get _favCount    => _favorites.length;

  Map<String, dynamic>? get _featuredMiracle {
    if (_miracles.isEmpty) return null;
    final hr = _miracles.where((m) => (m['rating'] ?? 0) >= 4).toList();
    return hr.isNotEmpty ? hr.first : _miracles.first;
  }

  // â”€â”€ Navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _toDetail(Map<String, dynamic> item) async {
    final id       = item['id'] ?? 0;
    final provider = context.read<MiracleColorProvider>();
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MiracleDetailScreen(
          item:             item,
          primaryColor:     provider.effectivePrimary,
          isFavorite:       _favorites.contains(id),
          onToggleFavorite: () => _toggleFavorite(id),
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end:   Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve:  Curves.easeOutCubic,
            )),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 340),
      ),
    );
    if (mounted) setState(() {});
  }

  void _toCategoryScreen(String categoryName) async {
    final provider = context.read<MiracleColorProvider>();
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CategoryMiraclesScreen(
          categoryName:     categoryName,
          miracles:         _miracles,
          primaryColor:     provider.effectivePrimary,
          initialFavorites: Set<int>.from(_favorites),
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end:   Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve:  Curves.easeOutCubic,
            )),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
    if (mounted) _loadFavorites();
  }

  // â”€â”€ Theme Helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  MiracleThemeColors _getTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    try {
      final provider = context.watch<MiracleColorProvider>();
      return MiracleTheme.of(isDark, provider: provider);
    } catch (_) {
      return MiracleTheme.of(isDark);
    }
  }

  // â”€â”€ BUILD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // miracles_screen.dart - build()
  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<MiracleColorProvider>();
    final t        = MiracleTheme.of(isDark, provider: provider);

    if (_loading) return _buildLoader(t);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          // â†گ ظ‡ط°ط§ ظٹط؛ط·ظٹ ط®ظ„ظپظٹط© main.dart
          color: t.bg1,
          child: Stack(
            children: [
              // â”€â”€ ط®ظ„ظپظٹط© ظ…ظ„ظˆظ†ط© ظ…طھط­ط±ظƒط© â”€â”€
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  color: t.bg1,
                ),
              ),

              // â”€â”€ ط§ظ„ظ†ط¬ظˆظ… â”€â”€
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (_, __) => StarFieldWidget(
                    particles:           _particles,
                    animValue:           _particleController.value,
                    starOpacityFactor:   t.starOpacityFactor,
                    nebulaOpacityFactor: t.nebulaOpacityFactor,
                    primaryColor:        t.neonBlue,
                    bg1:                 t.bg1,
                  ),
                ),
              ),

              // â”€â”€ ط§ظ„ظ…ط­طھظˆظ‰ â”€â”€
              Scaffold(
                backgroundColor: Colors.transparent, // â†گ ط´ظپط§ظپ!
                body: FadeTransition(
                  opacity: _fadeAnim,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildAppBar(t),
                      if (_featuredMiracle != null)
                        SliverToBoxAdapter(
                          child: ScaleTransition(
                            scale: _featuredAnim,
                            child: FeaturedMiracleCard(
                              miracle: _featuredMiracle!,
                              t:       t,
                              onTap:   () => _toDetail(_featuredMiracle!),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: CategoriesGrid(
                          categories:         _categories,
                          miracles:           _miracles,
                          selectedCategory:   _selectedCategory,
                          t:                  t,
                          onCategorySelected: (cat) =>
                              setState(() => _selectedCategory = cat),
                          onCategoryTapped:   _toCategoryScreen,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: StatsRowWidget(
                          quranCount:        _quranCount,
                          sunnahCount:       _sunnahCount,
                          favCount:          _favCount,
                          totalCount:        _miracles.length,
                          showFavoritesOnly: _showFavoritesOnly,
                          t:                 t,
                          onFavoriteToggle:  () => setState(
                                  () => _showFavoritesOnly = !_showFavoritesOnly),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: FilterSectionWidget(
                          selectedFilter:    _selectedFilter,
                          selectedCategory:  _selectedCategory,
                          categories:        _categories,
                          t:                 t,
                          onFilterChanged:   (v) =>
                              setState(() => _selectedFilter = v),
                          onCategoryChanged: (v) =>
                              setState(() => _selectedCategory = v),
                        ),
                      ),
                      if (_showSearch)
                        SliverToBoxAdapter(child: _buildSearchBar(t)),
                      SliverToBoxAdapter(child: _buildResultsHeader(t)),
                      _filteredMiracles.isEmpty
                          ? SliverFillRemaining(child: _buildEmptyState())
                          : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final item = _filteredMiracles[index];
                              final id   = item['id'] ?? index;
                              return MiracleCardWidget(
                                item:             item,
                                index:            index,
                                isFavorite: _favorites.contains(id),
                                t:                t,
                                onTap: () => _toDetail(item),
                                onFavoriteToggle: () =>
                                    _toggleFavorite(id),
                              );
                            },
                            childCount: _filteredMiracles.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                          child: SizedBox(height: 40)),
                    ],
                  ),
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
  Widget _buildAppBar(MiracleThemeColors t) {
    final expandedH = MediaQuery.of(context).size.height * 0.25;

    return SliverAppBar(
      expandedHeight: expandedH,
      floating:       false,
      pinned:         true,
      elevation:      0,
      backgroundColor: t.bg1.withValues(alpha: 0.95),

      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color:        t.glass,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: t.glassBorder),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size:  18,
            ),
          ),
        ),
      ),

      actions: [
        // 1. ط²ط± ط§ظ„ط¨ط­ط« ظپظٹ ط§ظ„ظ‚ط±ط¢ظ† ظˆط§ظ„ط³ظ†ط©
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Center(
            child: SizedBox(
              width:  40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color:        t.glass,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: t.glassBorder),
                ),
                child: GlobalSearchActionButton(
                  primaryColor: t.neonBlue,
                  iconColor:    Colors.white,
                ),
              ),
            ),
          ),
        ),

        // 2. ط²ط± طھط؛ظٹظٹط± ط§ظ„ظ„ظˆظ†
        _AppBarIconBtn(
          t:    t,
          onTap: () => ColorPickerSheet.show(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width:  18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.neonBlue,
                  boxShadow: [
                    BoxShadow(
                      color:     t.neonBlue.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.palette_rounded,
                  color: Colors.white, size: 11),
            ],
          ),
        ),

        // 3. ط²ط± ط§ظ„ظ…ظپط¶ظ„ط©
        _AppBarIconBtn(
          t:    t,
          onTap: () =>
              setState(() => _showFavoritesOnly = !_showFavoritesOnly),
          child: Icon(
            _showFavoritesOnly
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _showFavoritesOnly
                ? MiracleThemeColors.neonRed
                : Colors.white,
            size: 18,
          ),
        ),

        // 4. ط²ط± ط§ظ„ط¨ط­ط« ط§ظ„ظ†طµظٹ
        _AppBarIconBtn(
          t:    t,
          onTap: () => setState(() => _showSearch = !_showSearch),
          child: Icon(
            _showSearch
                ? Icons.search_off_rounded
                : Icons.search_rounded,
            color: _showSearch ? t.neonBlue : Colors.white,
            size:  18,
          ),
        ),

        const SizedBox(width: 4),
      ],

      flexibleSpace: FlexibleSpaceBar(
        centerTitle:  true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'الإعجاز العلمي',
              style: GoogleFonts.cairo(
                color:      Colors.white,
                fontWeight: FontWeight.bold,
                fontSize:   16,
                shadows: [
                  Shadow(
                    color:     t.neonBlue.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            Text(
              'Scientific Miracles in Islam',
              style: GoogleFonts.poppins(
                color:        t.neonBlue.withValues(alpha: 0.8),
                fontSize:     7,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        background: _AppBarBackground(
          t:         t,
          pulseAnim: _pulseAnim,
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  LOADING SCREEN
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildLoader(MiracleThemeColors t) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: t.bg1,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (_, __) => StarFieldWidget(
                    particles:           _particles,
                    animValue:           _particleController.value,
                    starOpacityFactor:   t.starOpacityFactor,
                    nebulaOpacityFactor: t.nebulaOpacityFactor,
                    primaryColor:        t.neonBlue,
                    bg1:                 t.bg1,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Container(
                        width:  100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            t.neonBlue.withValues(alpha: 
                                0.25 * _pulseAnim.value),
                            Colors.transparent,
                          ]),
                        ),
                        child: Center(
                          child: Container(
                            width:  62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape:  BoxShape.circle,
                              color:  t.glass,
                              border: Border.all(
                                color: t.neonBlue.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: t.neonBlue.withValues(alpha: 
                                      0.3 * _pulseAnim.value),
                                  blurRadius:   20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: MiracleThemeColors.neonGold,
                              size:  28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width:  38,
                      height: 38,
                      child: CircularProgressIndicator(
                        color:           t.neonBlue,
                        strokeWidth:     2.5,
                        backgroundColor: t.neonBlue.withValues(alpha: 0.1),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'جاري تحميل المعجزات...',
                      style: GoogleFonts.cairo(
                        color:      Colors.white70,
                        fontSize:   15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Loading Scientific Miracles...',
                      style: GoogleFonts.poppins(
                        color:        t.neonBlue.withValues(alpha: 0.5),
                        fontSize:     11,
                        letterSpacing: 1.0,
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
  //  SEARCH BAR
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildSearchBar(MiracleThemeColors t) {
    return Container(
      margin:  const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color:        t.glass,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: t.neonBlue.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color:      t.neonBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller:  _searchController,
        onChanged:   (v) => setState(() => _searchQuery = v),
        style:       GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        cursorColor: t.neonBlue,
        decoration: InputDecoration(
          hintText:  'ابحث في المعجزات...',
          hintStyle: GoogleFonts.cairo(
            color: Colors.white38, fontSize: 13,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: t.neonBlue.withValues(alpha: 0.7),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear_rounded,
                color: Colors.white38, size: 20),
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
  Widget _buildResultsHeader(MiracleThemeColors t) {
    final hasFilters = _selectedCategory  != 'all' ||
        _selectedFilter  != 'all' ||
        _searchQuery.isNotEmpty    ||
        _showFavoritesOnly;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Container(
            width:  3,
            height: 16,
            decoration: BoxDecoration(
              color:        t.neonBlue,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color:     t.neonBlue.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _showFavoritesOnly
                  ? 'المفضلة (${_filteredMiracles.length})'
                  : 'النتائج (${_filteredMiracles.length})',
              style: GoogleFonts.cairo(
                fontSize:   14,
                fontWeight: FontWeight.bold,
                color:      Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasFilters)
            GestureDetector(
              onTap: () => setState(() {
                _selectedCategory  = 'all';
                _selectedFilter    = 'all';
                _searchQuery       = '';
                _searchController.clear();
                _showFavoritesOnly = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: MiracleThemeColors.neonRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MiracleThemeColors.neonRed.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear_all_rounded,
                      size:  14,
                      color: MiracleThemeColors.neonRed.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'مسح',
                      style: GoogleFonts.cairo(
                        fontSize:   10,
                        color: MiracleThemeColors.neonRed.withValues(alpha: 0.8),
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
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  76,
              height: 76,
              decoration: BoxDecoration(
                shape:  BoxShape.circle,
                color:  Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(
                _showFavoritesOnly
                    ? Icons.favorite_border_rounded
                    : Icons.search_off_rounded,
                size:  34,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _showFavoritesOnly
                  ? 'لا توجد معجزات في المفضلة'
                  : 'لا توجد نتائج مطابقة',
              style: GoogleFonts.cairo(
                color:      Colors.white60,
                fontSize:   16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _showFavoritesOnly
                  ? 'اضغط على ❤️ لإضافة معجزات'
                  : 'جرّب تغيير البحث أو الفلاتر',
              style: GoogleFonts.cairo(
                color:    Colors.white30,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  APP BAR ICON BUTTON
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _AppBarIconBtn extends StatelessWidget {
  final MiracleThemeColors t;
  final VoidCallback       onTap;
  final Widget             child;

  const _AppBarIconBtn({
    required this.t,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width:  40,
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:        t.glass,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: t.glassBorder),
          ),
          child: Center(child: child),
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
  final Animation<double>  pulseAnim;

  const _AppBarBackground({
    required this.t,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          colors: [t.bg2, t.bg1],
        ),
      ),
      child: Stack(
        children: [
          // Orb top-right
          Positioned(
            top: -50, right: -50,
            child: Container(
              width:  180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  t.neonBlue.withValues(alpha: 0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Orb top-left
          Positioned(
            top: 20, left: -40,
            child: Container(
              width:  120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  MiracleThemeColors.neonGold.withValues(alpha: 0.05),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Centre pulsing icon
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 55),
              child: AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width:  90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          t.neonBlue.withValues(alpha: 
                              0.15 * pulseAnim.value),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                    Container(
                      width:  58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                        border: Border.all(
                          color: t.neonBlue.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: t.neonBlue.withValues(alpha: 
                                0.25 * pulseAnim.value),
                            blurRadius:   20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: MiracleThemeColors.neonGold,
                        size:  26,
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