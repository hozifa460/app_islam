import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamic_app/screens/fatwa/services/advanced_search_service.dart';
import 'package:islamic_app/screens/fatwa/services/fatwa_search_service.dart';
import 'package:islamic_app/screens/fatwa/services/local_search_service.dart';

import 'models/fatwa_model.dart';

class FatwaSearchScreen extends StatefulWidget {
  const FatwaSearchScreen({Key? key}) : super(key: key);

  @override
  State<FatwaSearchScreen> createState() => _FatwaSearchScreenState();
}

class _FatwaSearchScreenState extends State<FatwaSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<FatwaSearchResult> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isDataLoaded = false;

  // فلاتر
  String? _selectedScholar;
  String? _selectedCategory;

  // تصنيفات سريعة
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
    {'name': 'جنائز', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.grey},
  ];

  // أسئلة مقترحة
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
    _loadFatawa();
  }

  // ══════════════════════════════════════
  // تحميل الفتاوى من كل الملفات
  // ══════════════════════════════════════
  Future<void> _loadFatawa() async {
    try {
      await LocalSearchService.loadFatawa();

      if (!mounted) return;

      setState(() {
        _isDataLoaded = true;
      });

      print('✅ تم تحميل ${LocalSearchService.allFatawa.length} فتوى في شاشة البحث');
    } catch (e) {
      print('❌ خطأ في تحميل الفتاوى: $e');
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
      }
    }
  }

  // ══════════════════════════════════════
  // البحث
  // ══════════════════════════════════════
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final allFatawa = LocalSearchService.allFatawa;

      List<FatwaSearchResult> results = await AdvancedSearchService.search(
        query,
        allFatawa,
        scholarFilter: _selectedScholar,
        categoryFilter: _selectedCategory,
        topK: 20,
      );

      setState(() {
        _results = results;
        _hasSearched = true;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في البحث: $e');
      setState(() {
        _isLoading = false;
        _hasSearched = true;
        _results = [];
      });
    }
  }

  // ══════════════════════════════════════
  // الواجهة الرئيسية
  // ══════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0E1714) : const Color(0xFFF5F5F5),
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
                        Text('جاري تحميل الفتاوى...',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: _isLoading
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

  // ══════════════════════════════════════
  // الهيدر
  // ══════════════════════════════════════
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
            color: Colors.green.withOpacity(0.3),
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
              const Expanded(
                child: Text(
                  'البحث في الفتاوى',
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
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // شريط البحث
  // ══════════════════════════════════════
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2520) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isDark ? 0.1 : 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
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
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear,
                  color: isDark ? Colors.grey[400] : Colors.grey),
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
              horizontal: 20, vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // الحالة الابتدائية (قبل البحث)
  // ══════════════════════════════════════
  Widget _buildInitialState(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // التصنيفات
          Text('تصفح حسب الموضوع',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold,
                fontFamily: 'Cairo', color: textColor,
              )),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _quickCategories.length,
            itemBuilder: (context, index) {
              final cat = _quickCategories[index];
              return _buildCategoryChip(
                cat['name'], cat['icon'], cat['color'], isDark,
              );
            },
          ),
          const SizedBox(height: 24),

          // أسئلة مقترحة
          Text('أسئلة شائعة',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold,
                fontFamily: 'Cairo', color: textColor,
              )),
          const SizedBox(height: 12),
          ..._suggestedQuestions.map((q) => _buildSuggestedQuestion(q, isDark)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // تصنيف واحد
  // ══════════════════════════════════════
  Widget _buildCategoryChip(String name, IconData icon, Color color, bool isDark) {
    return InkWell(
      onTap: () {
        _searchController.text = name;
        _performSearch(name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(name,
                style: TextStyle(
                  color: color, fontSize: 11,
                  fontWeight: FontWeight.bold, fontFamily: 'Cairo',
                )),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // سؤال مقترح
  // ══════════════════════════════════════
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
              color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(question,
                    style: TextStyle(
                      fontSize: 14, fontFamily: 'Cairo',
                      color: isDark ? Colors.white70 : Colors.black87,
                    )),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: isDark ? Colors.grey[600] : Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // حالة التحميل
  // ══════════════════════════════════════
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 16),
          Text('جاري البحث في الفتاوى...',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // نتائج البحث
  // ══════════════════════════════════════
  Widget _buildSearchResults(bool isDark) {
    if (_results.isEmpty) return _buildEmptyResults(isDark);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('${_results.length} نتيجة',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14, fontFamily: 'Cairo',
                  )),
              const Spacer(),
              if (_selectedScholar != null || _selectedCategory != null)
                TextButton.icon(
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('مسح الفلتر',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return _buildFatwaCard(_results[index], index, isDark);
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════
  // كارت فتوى واحدة
  // ══════════════════════════════════════
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
                color: Colors.grey.withOpacity(isDark ? 0.05 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(isDark ? 0.1 : 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 13,
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(fatwa.category,
                          style: const TextStyle(
                            color: Color(0xFF2E7D32), fontSize: 11,
                            fontWeight: FontWeight.bold, fontFamily: 'Cairo',
                          )),
                    ),
                    const Spacer(),
                    if (fatwa.hasAudio)
                      const Icon(Icons.headphones, size: 16, color: Color(0xFF1565C0)),
                  ],
                ),
              ),

              // السؤال
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  fatwa.title.isNotEmpty ? fatwa.title : fatwa.question,
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo', height: 1.5, color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // معاينة الجواب
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  fatwa.answer.length > 120
                      ? '${fatwa.answer.substring(0, 120)}...'
                      : fatwa.answer,
                  style: TextStyle(
                    fontSize: 13, color: subColor,
                    fontFamily: 'Cairo', height: 1.5,
                  ),
                ),
              ),

              // المصدر
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: subColor),
                    const SizedBox(width: 4),
                    Text(fatwa.scholar,
                        style: TextStyle(
                          color: subColor, fontSize: 12,
                          fontFamily: 'Cairo', fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(width: 12),
                    Icon(Icons.library_books_outlined, size: 14, color: subColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(fatwa.book,
                          style: TextStyle(
                            color: subColor, fontSize: 12, fontFamily: 'Cairo',
                          ),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // لا توجد نتائج
  // ══════════════════════════════════════
  Widget _buildEmptyResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80,
              color: isDark ? Colors.grey[700] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text('لم يتم العثور على نتائج',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo',
              )),
          const SizedBox(height: 8),
          Text('جرب البحث بكلمات مختلفة',
              style: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                fontSize: 14, fontFamily: 'Cairo',
              )),
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
            label: const Text('بحث جديد',
                style: TextStyle(fontFamily: 'Cairo')),
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

  // ══════════════════════════════════════
  // تفاصيل الفتوى
  // ══════════════════════════════════════
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
                      width: 40, height: 4,
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
                          const Icon(Icons.auto_stories, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fatwa.title.isNotEmpty ? fatwa.title : fatwa.question,
                              style: TextStyle(
                                fontSize: 16, fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold, color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

                    // المحتوى
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // معلومات
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

                            // السؤال
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(isDark ? 0.1 : 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: const Border(
                                  right: BorderSide(color: Color(0xFF2E7D32), width: 4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('السؤال:',
                                      style: TextStyle(
                                        fontSize: 13, fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      )),
                                  const SizedBox(height: 4),
                                  Text(fatwa.question,
                                      style: TextStyle(
                                        fontSize: 15, fontFamily: 'Cairo',
                                        height: 1.8, color: textColor,
                                      )),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // الجواب
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.withOpacity(0.05)
                                    : const Color(0xFFF9FBF9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('الجواب:',
                                      style: TextStyle(
                                        fontSize: 13, fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(fatwa.answer,
                                      style: TextStyle(
                                        fontSize: 15, fontFamily: 'Cairo',
                                        height: 2.0, color: textColor,
                                      )),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // أزرار
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: '${fatwa.question}\n\n${fatwa.answer}\n\nالمصدر: ${fatwa.scholar} - ${fatwa.book}',
                                        ),
                                      );
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('تم النسخ',
                                              style: TextStyle(fontFamily: 'Cairo')),
                                          backgroundColor: const Color(0xFF2E7D32),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: const Text('نسخ',
                                        style: TextStyle(fontFamily: 'Cairo')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                if (fatwa.hasAudio) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('الصوت: ${fatwa.audio}',
                                                style: const TextStyle(fontFamily: 'Cairo')),
                                            backgroundColor: const Color(0xFF1565C0),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.headphones, size: 16),
                                      label: const Text('استماع',
                                          style: TextStyle(fontFamily: 'Cairo')),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF1565C0),
                                        side: const BorderSide(color: Color(0xFF1565C0)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
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
        color: const Color(0xFF2E7D32).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                fontSize: 12, fontFamily: 'Cairo',
                color: Color(0xFF2E7D32), fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // الفلترة
  // ══════════════════════════════════════
  void _showFilterSheet() {
    final allFatawa = LocalSearchService.allFatawa;

    // استخراج العلماء والتصنيفات من البيانات
    final scholars = allFatawa
        .map((f) => f.scholar)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final categories = allFatawa
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
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('العالم / المصدر',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo', color: Color(0xFF2E7D32),
                    )),
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
                    ...scholars.map((s) => _filterChip(
                      s, _selectedScholar == s, () {
                      setState(() => _selectedScholar = s);
                      Navigator.pop(context);
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    },
                    )),
                  ],
                ),

                const SizedBox(height: 20),

                const Text('التصنيف',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo', color: Color(0xFF2E7D32),
                    )),
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
                    ...categories.map((c) => _filterChip(
                      c, _selectedCategory == c, () {
                      setState(() => _selectedCategory = c);
                      Navigator.pop(context);
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    },
                    )),
                  ],
                ),

                const SizedBox(height: 20),
              ],
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
          color: isSelected
              ? const Color(0xFF2E7D32)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2E7D32)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontFamily: 'Cairo', fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}