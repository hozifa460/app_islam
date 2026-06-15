import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Constants/sunnah_theme.dart';
import 'models/sunnah_category.dart';
import 'widgets/sunnah_app_bar.dart';
import 'widgets/category_list_widget.dart';
import 'widgets/sunnah_stats_bar.dart';

class ProphetSunnahScreen extends StatefulWidget {
  const ProphetSunnahScreen({super.key});

  @override
  State<ProphetSunnahScreen> createState() => _ProphetSunnahScreenState();
}

class _ProphetSunnahScreenState extends State<ProphetSunnahScreen>
    with TickerProviderStateMixin {
  List<SunnahCategory> _categories = [];
  List<SunnahCategory> _filteredCategories = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String jsonString =
      await rootBundle.loadString('assets/json/life_sunna.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> categoriesJson = jsonData['categories'];

      if (mounted) {
        setState(() {
          _categories =
              categoriesJson.map((e) => SunnahCategory.fromJson(e)).toList();
          _filteredCategories = _categories;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories.where((cat) {
          final nameMatch = cat.name.contains(query);
          final sunnahMatch = cat.sunnahs.any((s) =>
          s.title.contains(query) ||
              s.hadith.contains(query) ||
              s.description.contains(query));
          return nameMatch || sunnahMatch;
        }).toList();
      }
    });
  }

  int get _totalSunnahs =>
      _categories.fold(0, (sum, cat) => sum + cat.sunnahs.length);

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: SunnahTheme.backgroundColor(context),
      body: _isLoading
          ? _LoadingView(isDark: isDark)
          : _hasError
          ? _ErrorView(onRetry: _loadData)
          : FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SunnahAppBar(
              searchController: _searchController,
              onSearch: _onSearch,
              isDark: isDark,
            ),
            SunnahStatsBar(
              totalCategories: _categories.length,
              totalSunnahs: _totalSunnahs,
              isDark: isDark,
            ),
            CategoryListWidget(
              categories: _filteredCategories,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading ───────────────────────────────────────────────────────────────

class _LoadingView extends StatefulWidget {
  final bool isDark;
  const _LoadingView({required this.isDark});

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [SunnahTheme.goldLight, SunnahTheme.goldDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: SunnahTheme.gold.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل السنن...',
            style: TextStyle(
              color: widget.isDark ? Colors.white70 : const Color(0xFF5A5A7A),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في التحميل',
              style: TextStyle(
                color: SunnahTheme.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تأكد من وجود ملف البيانات',
              style: TextStyle(
                color: SunnahTheme.textSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SunnahTheme.gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}