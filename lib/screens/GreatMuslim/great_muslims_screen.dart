import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/GreatMuslim/theme/great_muslims_styled_widgets.dart';

import '../../services/great_muslims_service.dart';
import 'great_person_detail_screen.dart';

class GreatMuslimsScreen extends StatefulWidget {
  final Color primaryColor;

  const GreatMuslimsScreen({
    super.key,
    required this.primaryColor,
  });

  @override
  State<GreatMuslimsScreen> createState() => _GreatMuslimsScreenState();
}

class _GreatMuslimsScreenState extends State<GreatMuslimsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnim;
  late AnimationController _listAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  List<GreatMuslim> _allPersons = [];
  bool _isLoading = true;

  String _searchQuery = '';
  bool _isSearching = false;
  late TextEditingController _searchCtrl;
  late FocusNode _searchFocus;

  List<String> _categories = ['الكل'];
  int _selectedCatIndex = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        if (mounted) setState(() => _scrollOffset = _scrollController.offset);
      });

    _searchCtrl = TextEditingController();
    _searchFocus = FocusNode();

    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _headerFade = CurvedAnimation(
        parent: _headerAnim,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnim,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _listAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      debugPrint('🔄 GreatMuslimsScreen: بدء التحميل...');
      final data = await GreatMuslimsService.load();
      debugPrint('✅ GreatMuslimsScreen: تم تحميل ${data.length} شخصية');

      if (!mounted) return;

      setState(() {
        _allPersons = data;
        _categories = [
          'الكل',
          ...data.map((e) => e.category).toSet().toList()
        ];
        _isLoading = false;
      });

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _headerAnim.forward();
        _listAnim.forward();
      }
    } catch (e) {
      debugPrint('❌ GreatMuslimsScreen خطأ: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<GreatMuslim> get _filtered {
    var result = _allPersons;
    if (_selectedCatIndex > 0) {
      result = GreatMuslimsService.filterByCategory(
          result, _categories[_selectedCatIndex]);
    }
    if (_searchQuery.isNotEmpty) {
      result = GreatMuslimsService.search(result, _searchQuery);
    }
    return result;
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _listAnim.dispose();
    _scrollController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchCtrl.clear();
        _searchFocus.unfocus();
      } else {
        Future.delayed(const Duration(milliseconds: 300),
                () => _searchFocus.requestFocus());
      }
    });
  }

  void _navigate(GreatMuslim person, String tag, Color primary) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) => GreatPersonDetailScreen(
          person: person,
          allPersons: _allPersons,
          primaryColor: primary,
          heroTag: tag,
        ),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic);
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = widget.primaryColor;
    final bg = isDark ? const Color(0xFF0B1411) : const Color(0xFFF4EFE6);
    final persons = _filtered;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 🏛 الهيدر
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  color: Colors.white,
                ),
                onPressed: _toggleSearch,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: MuseumAppBarBackground(primary: primary),
            ),
          ),

          /// 🔎 البحث
          if (_isSearching)
            SliverToBoxAdapter(
              child: MuslimSearchBar(
                primary: primary,
                isDark: isDark,
                controller: _searchCtrl,
                focusNode: _searchFocus,
                searchQuery: _searchQuery,
                onChanged: (v) => setState(() => _searchQuery = v),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ),

          /// 🏷 الفئات
          SliverToBoxAdapter(
            child: CategoryChipsList(
              primary: primary,
              isDark: isDark,
              categories: _categories,
              selectedIndex: _selectedCatIndex,
              onSelected: (i) => setState(() => _selectedCatIndex = i),
            ),
          ),

          /// 📊 العداد
          SliverToBoxAdapter(
            child: PersonsCountHeader(
              count: persons.length,
              primary: primary,
              isDark: isDark,
            ),
          ),

          /// ⏳ التحميل
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )

          /// 📭 فارغ
          else if (persons.isEmpty)
            SliverFillRemaining(
              child: EmptyStateWidget(
                primary: primary,
                isDark: isDark,
                isFiltered:
                _searchQuery.isNotEmpty || _selectedCatIndex > 0,
                onRetry: () {
                  setState(() => _isLoading = true);
                  GreatMuslimsService.clearCache();
                  _loadData();
                },
              ),
            )

          /// 🏛 القائمة
          else ...[
              /// البطاقة المميزة
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FeaturedPersonCard(
                    person: persons.first,
                    primary: primary,
                    isDark: isDark,
                    heroTag: 'great_person_${persons.first.id}',
                    onTap: () => _navigate(
                      persons.first,
                      'great_person_${persons.first.id}',
                      primary,
                    ),
                  ),
                ),
              ),

              /// الشبكة
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final person = persons[index + 1];
                      final tag = 'great_person_${person.id}';

                      return ModernGridCard(
                        person: person,
                        primary: primary,
                        isDark: isDark,
                        heroTag: tag,
                        onTap: () => _navigate(person, tag, primary),
                      );
                    },
                    childCount: persons.length - 1,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}