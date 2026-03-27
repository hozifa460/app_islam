import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/global_search_action_button.dart';
import 'mircle_detail_screen.dart';

class MiraclesScreen extends StatefulWidget {
  final Color primaryColor;

  const MiraclesScreen({super.key, required this.primaryColor});

  @override
  State<MiraclesScreen> createState() => _MiraclesScreenState();
}

class _MiraclesScreenState extends State<MiraclesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String _selectedCategory = 'all';
  bool _showFavoritesOnly = false;

  List<Map<String, dynamic>> _miracles = [];
  Set<int> _favorites = {};
  bool _loading = true;
  bool _showSearch = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _loadFavorites().then((_) => _loadMiracles());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════
  //  FAVORITES PERSISTENCE
  // ═══════════════════════════════════════════════
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('miracle_favorites') ?? [];
      setState(() {
        _favorites =
            favList
                .map((e) => int.tryParse(e) ?? -1)
                .where((e) => e != -1)
                .toSet();
      });
    } catch (e) {
      debugPrint('Load favorites error: $e');
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
      debugPrint('Save favorites error: $e');
    }
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
    _saveFavorites();
  }

  // ═══════════════════════════════════════════════
  //  LOAD DATA
  // ═══════════════════════════════════════════════
  Future<void> _loadMiracles() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/mircle/miracles.json',
      );
      final List<dynamic> data = json.decode(jsonString);

      setState(() {
        _miracles = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
      _animController.forward();
    } catch (e) {
      debugPrint('Miracles load error: $e');
      setState(() => _loading = false);
    }
  }

  // ═══════════════════════════════════════════════
  //  COMPUTED PROPERTIES
  // ═══════════════════════════════════════════════
  List<String> get _categories {
    final cats =
        _miracles
            .map((m) => (m['category'] ?? '').toString())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();
    cats.sort();
    return cats;
  }

  List<Map<String, dynamic>> get _filteredMiracles {
    return _miracles.where((item) {
      // Favorites filter
      if (_showFavoritesOnly) {
        final id = item['id'];
        if (id == null || !_favorites.contains(id)) return false;
      }

      final matchesType =
          _selectedFilter == 'all' || item['type'] == _selectedFilter;

      final matchesCategory =
          _selectedCategory == 'all' || item['category'] == _selectedCategory;

      final q = _searchQuery.trim();
      if (q.isEmpty) return matchesType && matchesCategory;

      final title = (item['title'] ?? '').toString();
      final subtitle = (item['subtitle'] ?? '').toString();
      final description = (item['description'] ?? '').toString();
      final source = (item['source'] ?? '').toString();
      final category = (item['category'] ?? '').toString();
      final scientificExplanation =
          (item['scientificExplanation'] ?? '').toString();
      final scientist = (item['scientist'] ?? '').toString();

      final matchesQuery =
          title.contains(q) ||
          subtitle.contains(q) ||
          description.contains(q) ||
          source.contains(q) ||
          category.contains(q) ||
          scientificExplanation.contains(q) ||
          scientist.contains(q);

      return matchesType && matchesCategory && matchesQuery;
    }).toList();
  }

  int get _quranCount => _miracles.where((m) => m['type'] == 'quran').length;

  int get _sunnahCount => _miracles.where((m) => m['type'] == 'sunnah').length;

  int get _favCount => _favorites.length;

  // ═══════════════════════════════════════════════
  //  ICONS & COLORS HELPERS
  // ═══════════════════════════════════════════════
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'علم الفلك':
        return Icons.stars_rounded;
      case 'علم الأجنة':
        return Icons.child_care_rounded;
      case 'علم البحار':
        return Icons.water_rounded;
      case 'علم الجيولوجيا':
        return Icons.terrain_rounded;
      case 'علم الفيزياء':
        return Icons.science_rounded;
      case 'علم المياه':
        return Icons.water_drop_rounded;
      case 'علم النبات':
        return Icons.local_florist_rounded;
      case 'علم الأحياء':
        return Icons.biotech_rounded;
      case 'علم الأحياء الدقيقة':
        return Icons.coronavirus_rounded;
      case 'علم الطب':
        return Icons.medical_services_rounded;
      case 'علم الأعصاب':
        return Icons.psychology_rounded;
      case 'علم الجغرافيا':
        return Icons.public_rounded;
      case 'علم النفس':
        return Icons.self_improvement_rounded;
      case 'علم الحشرات':
        return Icons.bug_report_rounded;
      case 'علم التغذية':
        return Icons.restaurant_rounded;
      case 'علم الصحة العامة':
        return Icons.health_and_safety_rounded;
      case 'إعجاز غيبي':
        return Icons.visibility_rounded;
      case 'إعجاز تاريخي':
        return Icons.history_edu_rounded;
      case 'معجزات نبوية':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'علم الفلك':
        return const Color(0xFF5C6BC0);
      case 'علم الأجنة':
        return const Color(0xFFEC407A);
      case 'علم البحار':
        return const Color(0xFF039BE5);
      case 'علم الجيولوجيا':
        return const Color(0xFF795548);
      case 'علم الفيزياء':
        return const Color(0xFF7E57C2);
      case 'علم المياه':
        return const Color(0xFF00ACC1);
      case 'علم النبات':
        return const Color(0xFF43A047);
      case 'علم الأحياء':
        return const Color(0xFF66BB6A);
      case 'علم الأحياء الدقيقة':
        return const Color(0xFFEF5350);
      case 'علم الطب':
        return const Color(0xFFE53935);
      case 'علم الأعصاب':
        return const Color(0xFFAB47BC);
      case 'علم الجغرافيا':
        return const Color(0xFF26A69A);
      case 'علم النفس':
        return const Color(0xFF8D6E63);
      case 'علم الحشرات':
        return const Color(0xFFFF7043);
      case 'علم التغذية':
        return const Color(0xFFFFA726);
      case 'علم الصحة العامة':
        return const Color(0xFF29B6F6);
      case 'إعجاز غيبي':
        return const Color(0xFFFFCA28);
      case 'إعجاز تاريخي':
        return const Color(0xFF8D6E63);
      case 'معجزات نبوية':
        return const Color(0xFFE6B325);
      default:
        return widget.primaryColor;
    }
  }

  // ═══════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F5F0);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    const gold = Color(0xFFE6B325);

    if (_loading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: widget.primaryColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(color: widget.primaryColor),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل المعجزات...',
                  style: GoogleFonts.cairo(color: subTextColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(isDark, gold),

              SliverToBoxAdapter(
                child: _buildStatsSection(isDark, cardColor, textColor, gold),
              ),

              SliverToBoxAdapter(
                child: _buildCategoryFilter(isDark, cardColor, textColor, gold),
              ),

              if (_showSearch)
                SliverToBoxAdapter(
                  child: _buildSearchBar(isDark, cardColor, textColor),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _showFavoritesOnly
                            ? 'المفضلة (${_filteredMiracles.length})'
                            : 'النتائج (${_filteredMiracles.length})',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (_selectedCategory != 'all' ||
                          _selectedFilter != 'all' ||
                          _searchQuery.isNotEmpty ||
                          _showFavoritesOnly)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'all';
                              _selectedFilter = 'all';
                              _searchQuery = '';
                              _searchController.clear();
                              _showFavoritesOnly = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.clear_all_rounded,
                                    size: 16, color: Colors.red.shade400),
                                const SizedBox(width: 4),
                                Text(
                                  'مسح الفلاتر',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              _filteredMiracles.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState(subTextColor))
                  : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = _filteredMiracles[index];
                        return _buildMiracleCard(
                          item: item,
                          index: index,
                          isDark: isDark,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          gold: gold,
                        );
                      }, childCount: _filteredMiracles.length),
                    ),
                  ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  SLIVER APP BAR
  // ═══════════════════════════════════════════════
  Widget _buildSliverAppBar(bool isDark, Color gold) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.25,
      floating: false,
      pinned: true,
      backgroundColor: widget.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Favorites toggle
        IconButton(
          icon: Icon(
            _showFavoritesOnly
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _showFavoritesOnly ? Colors.redAccent : Colors.white,
          ),
          tooltip: 'المفضلة',
          onPressed: () {
            setState(() => _showFavoritesOnly = !_showFavoritesOnly);
          },
        ),
        IconButton(
          icon: Icon(
            _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
            color: Colors.white,
          ),
          onPressed: () => setState(() => _showSearch = !_showSearch),
        ),
        GlobalSearchActionButton(
          primaryColor: widget.primaryColor,
          iconColor: Colors.white,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 14, left: 50, right: 50),
        title: Text(
          'الإعجاز العلمي',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16, // أصغر قليلاً
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.primaryColor.withOpacity(0.8),
                widget.primaryColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gold.withOpacity(0.15),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: gold.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: gold,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  STATS SECTION
  // ═══════════════════════════════════════════════
  Widget _buildStatsSection(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color gold,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // إذا كان العرض صغير، نعرض صفين
          if (constraints.maxWidth < 340) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: (constraints.maxWidth - 8) / 2,
                  child: _buildStatCard(
                    icon: Icons.menu_book_rounded,
                    label: 'القرآن',
                    count: _quranCount,
                    color: widget.primaryColor,
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - 8) / 2,
                  child: _buildStatCard(
                    icon: Icons.auto_awesome_rounded,
                    label: 'السنة',
                    count: _sunnahCount,
                    color: gold,
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - 8) / 2,
                  child: GestureDetector(
                    onTap:
                        () => setState(
                          () => _showFavoritesOnly = !_showFavoritesOnly,
                        ),
                    child: _buildStatCard(
                      icon: Icons.favorite_rounded,
                      label: 'المفضلة',
                      count: _favCount,
                      color: Colors.redAccent,
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      highlighted: _showFavoritesOnly,
                    ),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - 8) / 2,
                  child: _buildStatCard(
                    icon: Icons.library_books_rounded,
                    label: 'الإجمالي',
                    count: _miracles.length,
                    color: const Color(0xFF66BB6A),
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.menu_book_rounded,
                  label: 'القرآن',
                  count: _quranCount,
                  color: widget.primaryColor,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.auto_awesome_rounded,
                  label: 'السنة',
                  count: _sunnahCount,
                  color: gold,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => setState(
                        () => _showFavoritesOnly = !_showFavoritesOnly,
                      ),
                  child: _buildStatCard(
                    icon: Icons.favorite_rounded,
                    label: 'المفضلة',
                    count: _favCount,
                    color: Colors.redAccent,
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                    highlighted: _showFavoritesOnly,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.library_books_rounded,
                  label: 'الإجمالي',
                  count: _miracles.length,
                  color: const Color(0xFF66BB6A),
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── بعد ──
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: highlighted ? color.withOpacity(0.12) : cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(highlighted ? 0.5 : 0.2),
          width: highlighted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.1 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: 16,
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
                color: textColor.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  CATEGORY FILTER
  // ═══════════════════════════════════════════════
  Widget _buildCategoryFilter(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color gold,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeFilterChip(
                  label: 'الكل',
                  value: 'all',
                  icon: Icons.apps_rounded,
                  selected: _selectedFilter == 'all',
                  color: widget.primaryColor,
                  isDark: isDark,
                  cardColor: cardColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeFilterChip(
                  label: 'القرآن',
                  value: 'quran',
                  icon: Icons.menu_book_rounded,
                  selected: _selectedFilter == 'quran',
                  color: widget.primaryColor,
                  isDark: isDark,
                  cardColor: cardColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeFilterChip(
                  label: 'السنة',
                  value: 'sunnah',
                  icon: Icons.auto_awesome_rounded,
                  selected: _selectedFilter == 'sunnah',
                  color: gold,
                  isDark: isDark,
                  cardColor: cardColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(
                label: 'الكل',
                value: 'all',
                selected: _selectedCategory == 'all',
                color: widget.primaryColor,
                isDark: isDark,
                cardColor: cardColor,
              ),
              ..._categories.map(
                (cat) => _buildCategoryChip(
                  label: cat,
                  value: cat,
                  selected: _selectedCategory == cat,
                  color: _getCategoryColor(cat),
                  isDark: isDark,
                  cardColor: cardColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── بعد ──
  Widget _buildTypeFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required bool selected,
    required Color color,
    required bool isDark,
    required Color cardColor,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? color : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.2),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 3),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: selected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String value,
    required bool selected,
    required Color color,
    required bool isDark,
    required Color cardColor,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : color.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color:
                selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  SEARCH BAR
  // ═══════════════════════════════════════════════
  Widget _buildSearchBar(bool isDark, Color cardColor, Color textColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.cairo(color: textColor, fontSize: 14),
        cursorColor: widget.primaryColor,
        decoration: InputDecoration(
          hintText: 'ابحث في المعجزات...',
          hintStyle: GoogleFonts.cairo(
            color: textColor.withOpacity(0.4),
            fontSize: 13,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: widget.primaryColor.withOpacity(0.6),
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: textColor.withOpacity(0.4),
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

  // ═══════════════════════════════════════════════
  //  MIRACLE CARD
  // ═══════════════════════════════════════════════
  Widget _buildMiracleCard({
    required Map<String, dynamic> item,
    required int index,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color gold,
  }) {
    final isQuran = item['type'] == 'quran';
    final accentColor = isQuran ? widget.primaryColor : gold;
    final category = (item['category'] ?? '').toString();
    final catColor = _getCategoryColor(category);
    final catIcon = _getCategoryIcon(category);
    final id = item['id'] ?? index;
    final isFav = _favorites.contains(id);
    final rating = (item['rating'] ?? 0) as int;
    final scientist = (item['scientist'] ?? '').toString();
    final discoveryYear = (item['discoveryYear'] ?? '').toString();

    // Count sources
    final sourcesList = item['sources'];
    final sourcesCount = (sourcesList is List) ? sourcesList.length : 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60).clamp(0, 600)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accentColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (_, __, ___) => MiracleDetailScreen(
                        item: item,
                        primaryColor: widget.primaryColor,
                        isFavorite: isFav,
                        onToggleFavorite: () => _toggleFavorite(id),
                      ),
                  transitionsBuilder: (_, anim, __, child) {
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 350),
                ),
              );
              // Refresh state when returning from detail
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              catColor.withOpacity(0.15),
                              catColor.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(color: catColor.withOpacity(0.25)),
                        ),
                        child: Icon(catIcon, color: catColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _toggleFavorite(id),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder:
                                        (child, anim) => ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      key: ValueKey(isFav),
                                      color:
                                          isFav
                                              ? Colors.redAccent
                                              : subTextColor.withOpacity(0.4),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['subtitle'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Source preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      item['source'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 13.5,
                        height: 1.6,
                        color: textColor.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bottom tags row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Rating stars
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                              (i) => Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: i < rating
                                ? gold
                                : subTextColor.withOpacity(0.2),
                            size: 13,
                          ),
                        ),
                      ),

                      // Sources count badge
                      if (sourcesCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link_rounded,
                                  size: 10,
                                  color: Colors.blue.shade400),
                              const SizedBox(width: 3),
                              Text(
                                '$sourcesCount',
                                style: GoogleFonts.cairo(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Scientist / Year badge
                      if (scientist.isNotEmpty || discoveryYear.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            discoveryYear.isNotEmpty
                                ? discoveryYear
                                : scientist,
                            style: GoogleFonts.cairo(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: subTextColor.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Category tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Type tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isQuran ? 'قرآن' : 'سنة',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  EMPTY STATE
  // ═══════════════════════════════════════════════
  Widget _buildEmptyState(Color subTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showFavoritesOnly
                ? Icons.favorite_border_rounded
                : Icons.search_off_rounded,
            size: 64,
            color: subTextColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _showFavoritesOnly
                ? 'لا توجد معجزات في المفضلة'
                : 'لا توجد نتائج مطابقة',
            style: GoogleFonts.cairo(
              color: subTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showFavoritesOnly
                ? 'اضغط على ❤️ لإضافة معجزات إلى المفضلة'
                : 'جرّب تغيير كلمات البحث أو الفلاتر',
            style: GoogleFonts.cairo(
              color: subTextColor.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
