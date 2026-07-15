import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:islamic_app/screens/fatwa/services/advanced_search_service.dart';
import 'package:islamic_app/screens/fatwa/services/fatwa_search_service.dart';
import 'package:islamic_app/screens/fatwa/services/local_search_service.dart';

import 'models/fatwa_model.dart';

class FatwaSearchScreen extends StatefulWidget {
  const FatwaSearchScreen({super.key});

  @override
  State<FatwaSearchScreen> createState() => _FatwaSearchScreenState();
}

class _FatwaSearchScreenState extends State<FatwaSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _resultsScrollController = ScrollController();

  List<FatwaSearchResult> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isDataLoaded = LocalSearchService.allFatawa.isNotEmpty;
  int _searchGeneration = 0;
  int _visibleResultCount = _resultsPageSize;
  static const int _resultsPageSize = 20;

  // ظپظ„ط§طھط±
  String? _selectedScholar;
  String? _selectedCategory;

  // طھطµظ†ظٹظپط§طھ ط³ط±ظٹط¹ط©
  final List<Map<String, dynamic>> _quickCategories = [
    {'name': 'صلاة', 'icon': Icons.mosque, 'color': Colors.green},
    {'name': 'زكاة', 'icon': Icons.volunteer_activism, 'color': Colors.amber},
    {'name': 'صيام', 'icon': Icons.nights_stay, 'color': Colors.indigo},
    {'name': 'حج', 'icon': Icons.location_city, 'color': Colors.brown},
    {'name': 'طهارة', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'name': 'بيوع', 'icon': Icons.store, 'color': Colors.orange},
    {'name': 'نكاح', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'عقيدة', 'icon': Icons.star, 'color': Colors.purple},
    {'name': 'أذكار', 'icon': Icons.auto_stories, 'color': Colors.teal},
    {
      'name': 'جنائز',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.grey,
    },
  ];

  // ط£ط³ط¦ظ„ط© ظ…ظ‚طھط±ط­ط©
  final List<String> _suggestedQuestions = [
    'ما حكم الصلاة جالساً للمريض؟',
    'هل يجوز الإفطار في السفر؟',
    'كيف أحسب زكاة المال؟',
    'ما حكم صلاة التراويح؟',
    'هل يجوز قراءة القرآن بدون وضوء؟',
    'ما حكم الربا في البنوك؟',
  ];

  @override
  void initState() {
    super.initState();
    LocalSearchService.dataRevision.addListener(_onFatwaDataChanged);
    _resultsScrollController.addListener(_loadMoreResultsIfNeeded);
    _loadFatawa();
  }

  void _loadMoreResultsIfNeeded() {
    if (!_resultsScrollController.hasClients ||
        _visibleResultCount >= _results.length) {
      return;
    }
    if (_resultsScrollController.position.extentAfter > 320) return;
    setState(() {
      final nextPage = _visibleResultCount + _resultsPageSize;
      _visibleResultCount =
          nextPage < _results.length ? nextPage : _results.length;
    });
  }

  void _onFatwaDataChanged() {
    if (!mounted) return;
    setState(() => _isDataLoaded = true);
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // طھط­ظ…ظٹظ„ ط§ظ„ظپطھط§ظˆظ‰ ظ…ظ† ظƒظ„ ط§ظ„ظ…ظ„ظپط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Future<void> _loadFatawa() async {
    try {
      await LocalSearchService.loadFatawa();

      if (!mounted) return;

      setState(() {
        _isDataLoaded = true;
      });

      debugPrint(
        '✅ تم تحميل ${LocalSearchService.allFatawa.length} فتوى في شاشة البحث',
      );
    } catch (e) {
      debugPrint('❌ خطأ في تحميل الفتاوى: $e');
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
      }
    }
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط¨ط­ط«
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    final requestId = ++_searchGeneration;
    setState(() => _isLoading = true);

    try {
      final allFatawa = LocalSearchService.allFatawa;

      List<FatwaSearchResult> results = await AdvancedSearchService.search(
        query,
        allFatawa,
        scholarFilter: _selectedScholar,
        categoryFilter: _selectedCategory,
        // نحتفظ بكل النتائج الدقيقة مرتبة، وتعرض الشاشة 20 في كل دفعة.
        topK: null,
      );

      if (!mounted || requestId != _searchGeneration) return;
      setState(() {
        _results = results;
        _visibleResultCount =
            results.length < _resultsPageSize
                ? results.length
                : _resultsPageSize;
        _hasSearched = true;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_resultsScrollController.hasClients) {
          _resultsScrollController.jumpTo(0);
        }
      });
    } catch (e) {
      debugPrint('❌ خطأ في البحث: $e');
      if (!mounted || requestId != _searchGeneration) return;
      setState(() {
        _isLoading = false;
        _hasSearched = true;
        _results = [];
      });
    }
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظˆط§ط¬ظ‡ط© ط§ظ„ط±ط¦ظٹط³ظٹط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0E1714) : const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              _buildSearchBar(isDark),

              if (!_isDataLoaded)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF2E7D32)),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل الفتاوى...',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child:
                      _isLoading
                          ? _buildLoadingState()
                          : _hasSearched
                          ? _buildSearchResults(isDark)
                          : _buildInitialState(isDark),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظ‡ظٹط¯ط±
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                tooltip: 'مصادر وملفات الفتاوى',
                icon: const Icon(
                  Icons.cloud_download_outlined,
                  color: Colors.white,
                ),
                onPressed: _showSourcesStatus,
              ),
              const Expanded(
                child: Text(
                  'البحث في الفتاوى',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: _showFilterSheet,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${LocalSearchService.allFatawa.length} فتوى من عدة مصادر',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط±ظٹط· ط§ظ„ط¨ط­ط«
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2520) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: isDark ? 0.1 : 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (_) => setState(() {}),
          onSubmitted: _performSearch,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Cairo',
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن فتوى...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontFamily: 'Cairo',
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _results = [];
                          _hasSearched = false;
                        });
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط­ط§ظ„ط© ط§ظ„ط§ط¨طھط¯ط§ط¦ظٹط© (ظ‚ط¨ظ„ ط§ظ„ط¨ط­ط«)
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildInitialState(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ط§ظ„طھطµظ†ظٹظپط§طھ
          Text(
            'تصفح حسب الموضوع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _quickCategories.length,
            itemBuilder: (context, index) {
              final cat = _quickCategories[index];
              return _buildCategoryChip(
                cat['name'],
                cat['icon'],
                cat['color'],
                isDark,
              );
            },
          ),
          const SizedBox(height: 24),

          // ط£ط³ط¦ظ„ط© ظ…ظ‚طھط±ط­ط©
          Text(
            'أسئلة شائعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ..._suggestedQuestions.map((q) => _buildSuggestedQuestion(q, isDark)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // طھطµظ†ظٹظپ ظˆط§ط­ط¯
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildCategoryChip(
    String name,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        _searchController.text = name;
        _performSearch(name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط³ط¤ط§ظ„ ظ…ظ‚طھط±ط­
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildSuggestedQuestion(String question, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          _searchController.text = question;
          _performSearch(question);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2520) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDark
                      ? Colors.grey.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط­ط§ظ„ط© ط§ظ„طھط­ظ…ظٹظ„
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 16),
          Text(
            'جاري البحث في الفتاوى...',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ†طھط§ط¦ط¬ ط§ظ„ط¨ط­ط«
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildSearchResults(bool isDark) {
    if (_results.isEmpty) return _buildEmptyResults(isDark);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${_results.length} نتيجة',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              if (_selectedScholar != null || _selectedCategory != null)
                TextButton.icon(
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text(
                    'مسح الفلتر',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedScholar = null;
                      _selectedCategory = null;
                    });
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _resultsScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _visibleResultCount,
            itemBuilder: (context, index) {
              return _buildFatwaCard(_results[index], index, isDark);
            },
          ),
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظƒط§ط±طھ ظپطھظˆظ‰ ظˆط§ط­ط¯ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildFatwaCard(FatwaSearchResult result, int index, bool isDark) {
    final fatwa = result.fatwa;
    final cardBg = isDark ? const Color(0xFF1C2520) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showFatwaDetail(fatwa),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: isDark ? 0.05 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ط§ظ„ظ‡ظٹط¯ط±
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2E7D32,
                  ).withValues(alpha: isDark ? 0.1 : 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          fatwa.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (fatwa.hasAudio)
                      const Icon(
                        Icons.headphones,
                        size: 16,
                        color: Color(0xFF1565C0),
                      ),
                  ],
                ),
              ),

              // ط§ظ„ط³ط¤ط§ظ„
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  fatwa.title.isNotEmpty ? fatwa.title : fatwa.question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    height: 1.5,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ظ…ط¹ط§ظٹظ†ط© ط§ظ„ط¬ظˆط§ط¨
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  fatwa.answer.length > 120
                      ? '${fatwa.answer.substring(0, 120)}...'
                      : fatwa.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: subColor,
                    fontFamily: 'Cairo',
                    height: 1.5,
                  ),
                ),
              ),

              // ط§ظ„ظ…طµط¯ط±
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color:
                          isDark
                              ? Colors.grey.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: subColor),
                    const SizedBox(width: 4),
                    Flexible(
                      flex: 2,
                      child: Text(
                        fatwa.scholar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subColor,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.library_books_outlined,
                      size: 14,
                      color: subColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        fatwa.book,
                        style: TextStyle(
                          color: subColor,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
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

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ„ط§ طھظˆط¬ط¯ ظ†طھط§ط¦ط¬
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildEmptyResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على نتائج',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب البحث بكلمات مختلفة',
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _results = [];
                _hasSearched = false;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text(
              'بحث جديد',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // طھظپط§طµظٹظ„ ط§ظ„ظپطھظˆظ‰
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  void _showFatwaDetail(Fatwa fatwa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1C2520) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_stories,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fatwa.title.isNotEmpty
                                  ? fatwa.title
                                  : fatwa.question,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),

                    // ط§ظ„ظ…ط­طھظˆظ‰
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ظ…ط¹ظ„ظˆظ…ط§طھ
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip(Icons.person, fatwa.scholar),
                                _infoChip(Icons.library_books, fatwa.book),
                                _infoChip(Icons.category, fatwa.category),
                                if (fatwa.categories.isNotEmpty)
                                  ...fatwa.categories.map(
                                    (c) => _infoChip(Icons.label, c),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ط§ظ„ط³ط¤ط§ظ„
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2E7D32,
                                ).withValues(alpha: isDark ? 0.1 : 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: const Border(
                                  right: BorderSide(
                                    color: Color(0xFF2E7D32),
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'السؤال:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fatwa.question,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Cairo',
                                      height: 1.8,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ط§ظ„ط¬ظˆط§ط¨
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.grey.withValues(alpha: 0.05)
                                        : const Color(0xFFF9FBF9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الجواب:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fatwa.answer,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Cairo',
                                      height: 2.0,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ط£ط²ط±ط§ط±
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              '${fatwa.question}\n\n${fatwa.answer}\n\nالمصدر: ${fatwa.scholar} - ${fatwa.book}',
                                        ),
                                      );
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'تم النسخ',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFF2E7D32,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: const Text(
                                      'نسخ',
                                      style: TextStyle(fontFamily: 'Cairo'),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                if (fatwa.hasAudio) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final uri = Uri.tryParse(fatwa.audio);
                                        if (uri == null ||
                                            !await canLaunchUrl(uri)) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'تعذر فتح الملف الصوتي',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.headphones,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'استماع',
                                        style: TextStyle(fontFamily: 'Cairo'),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF1565C0,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF1565C0),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Cairo',
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSourcesStatus() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return ValueListenableBuilder<int>(
                valueListenable: LocalSearchService.remoteRevision,
                builder: (context, _, __) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final files = LocalSearchService.remoteFiles;
                  final completed =
                      files.where((f) => f.status == 'مكتمل').length;
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2520) : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'مصادر وملفات الفتاوى',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'تحديث الفهرس',
                              onPressed: () async {
                                await LocalSearchService.refreshRemoteSources();
                              },
                              icon: const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${LocalSearchService.allFatawa.length} فتوى متاحة الآن • $completed من ${files.length} ملفات بعيدة مكتملة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _sourceProgressCard(
                          title: 'الملفات المضمنة داخل التطبيق',
                          status: 'مكتمل',
                          details: 'متاحة بدون إنترنت',
                          progress: 1,
                          isDark: isDark,
                        ),
                        if (files.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 12),
                                  Text(
                                    'جاري قراءة فهارس GitLab وGitHub...',
                                    style: TextStyle(fontFamily: 'Cairo'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...files.map((file) {
                            final remaining =
                                file.totalBytes > file.downloadedBytes
                                    ? file.totalBytes - file.downloadedBytes
                                    : 0;
                            final details =
                                file.totalBytes > 0
                                    ? '${file.sourceName} • ${file.parsedCount} فتوى • ${_formatBytes(file.downloadedBytes)} من ${_formatBytes(file.totalBytes)} • متبقي ${_formatBytes(remaining)}'
                                    : '${file.sourceName} • ${file.parsedCount} فتوى • ${_formatBytes(file.downloadedBytes)}';
                            return _sourceProgressCard(
                              title: file.displayName,
                              status: file.status,
                              details: details,
                              progress:
                                  file.totalBytes > 0 ? file.fraction : null,
                              isDark: isDark,
                              onPause:
                                  file.status == 'يتم التحميل' ||
                                          file.status == 'استئناف'
                                      ? () =>
                                          LocalSearchService.pauseRemoteFile(
                                            file.fileName,
                                          )
                                      : null,
                              onStart:
                                  file.status == 'مكتمل'
                                      ? null
                                      : (file.status == 'في الانتظار' ||
                                          file.status == 'متوقف مؤقتاً')
                                      ? () =>
                                          LocalSearchService.startRemoteFile(
                                            file.fileName,
                                          )
                                      : null,
                            );
                          }),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _sourceProgressCard({
    required String title,
    required String status,
    required String details,
    required double? progress,
    required bool isDark,
    VoidCallback? onPause,
    VoidCallback? onStart,
  }) {
    final completed = status == 'مكتمل';
    final action = onPause ?? onStart;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.cloud_download_outlined,
                color:
                    completed
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF1565C0),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color:
                      completed
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF1565C0),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip:
                      onPause != null ? 'إيقاف الملف' : 'بدء/استئناف الملف',
                  onPressed: action,
                  icon: Icon(
                    onPause != null ? Icons.pause_circle : Icons.play_circle,
                    color:
                        onPause != null
                            ? const Color(0xFFEF6C00)
                            : const Color(0xFF1565C0),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
            color:
                completed ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
            backgroundColor: Colors.grey.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 7),
          Text(
            details,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظپظ„طھط±ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  void _showFilterSheet() {
    final allFatawa = LocalSearchService.allFatawa;

    // ط§ط³طھط®ط±ط§ط¬ ط§ظ„ط¹ظ„ظ…ط§ط، ظˆط§ظ„طھطµظ†ظٹظپط§طھ ظ…ظ† ط§ظ„ط¨ظٹط§ظ†ط§طھ
    final scholars =
        allFatawa
            .map((f) => f.scholar)
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final categories =
        allFatawa
            .map((f) => f.category)
            .where((c) => c.isNotEmpty && c != 'عام')
            .toSet()
            .toList()
          ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1C2520) : Colors.white;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'العالم / المصدر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip('الكل', _selectedScholar == null, () {
                        setState(() => _selectedScholar = null);
                        Navigator.pop(context);
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      }),
                      ...scholars.map(
                        (s) => _filterChip(s, _selectedScholar == s, () {
                          setState(() => _selectedScholar = s);
                          Navigator.pop(context);
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text);
                          }
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'التصنيف',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip('الكل', _selectedCategory == null, () {
                        setState(() => _selectedCategory = null);
                        Navigator.pop(context);
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      }),
                      ...categories.map(
                        (c) => _filterChip(c, _selectedCategory == c, () {
                          setState(() => _selectedCategory = c);
                          Navigator.pop(context);
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text);
                          }
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF2E7D32)
                  : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    LocalSearchService.dataRevision.removeListener(_onFatwaDataChanged);
    _resultsScrollController
      ..removeListener(_loadMoreResultsIfNeeded)
      ..dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
