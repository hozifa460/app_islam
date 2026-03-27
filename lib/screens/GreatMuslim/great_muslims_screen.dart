import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const _gold = Color(0xFFC8A44D);

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
        _categories = ['الكل', ...data.map((e) => e.category).toSet().toList()];
        _isLoading = false;
      });

      // تشغيل الأنيميشن بعد التحميل
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
      result =
          GreatMuslimsService.filterByCategory(result, _categories[_selectedCatIndex]);
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

          /// =========================
          /// 🏛 CINEMATIC HEADER
          /// =========================
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
              background: Stack(
                fit: StackFit.expand,
                children: [

                  /// خلفية متدرجة
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primary,
                          primary.withOpacity(0.7),
                          const Color(0xFF111111),
                        ],
                      ),
                    ),
                  ),

                  /// زخرفة دوائر عميقة
                  Positioned(
                    top: -40,
                    right: -30,
                    child: _circle(200, Colors.white.withOpacity(0.05)),
                  ),
                  Positioned(
                    bottom: -60,
                    left: -20,
                    child: _circle(160, Colors.amber.withOpacity(0.05)),
                  ),

                  /// النص
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "متحف عظماء الإسلام",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.amiri(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "رحلة عبر أعظم الشخصيات في تاريخ الحضارة الإسلامية",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
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

          /// =========================
          /// 🔎 SEARCH
          /// =========================
          if (_isSearching)
            SliverToBoxAdapter(
              child: _buildSearchBar(primary, isDark),
            ),

          /// =========================
          /// 🏷 CATEGORIES
          /// =========================
          SliverToBoxAdapter(
            child: _buildCategoryChips(primary, isDark),
          ),

          /// =========================
          /// 📊 COUNT + HEADER
          /// =========================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      "${persons.length} شخصية",
                      key: ValueKey(persons.length),
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                  Text(
                    "الشخصيات",
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// =========================
          /// ⏳ LOADING
          /// =========================
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )

          /// =========================
          /// 📭 EMPTY
          /// =========================
          else if (persons.isEmpty)
            SliverFillRemaining(
              child: _buildEmpty(primary, isDark),
            )

          /// =========================
          /// 🏛 FEATURED + GRID
          /// =========================
          else ...[

              /// أول عنصر مميز بانر كبير
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildFeaturedCard(
                    persons.first,
                    primary,
                    isDark,
                  ),
                ),
              ),

              /// الشبكة الحديثة
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final person = persons[index + 1];

                      return _buildModernGridCard(
                        person,
                        primary,
                        isDark,
                      );
                    },
                    childCount: persons.length - 1,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildModernGridCard(
      GreatMuslim person,
      Color primary,
      bool isDark,
      ) {
    final tag = 'great_person_${person.id}';

    return GestureDetector(
      onTap: () => _navigate(person, tag, primary),
      child: Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [

                  /// صورة
                  Image.asset(
                    person.image,
                    fit: BoxFit.cover,
                  ),

                  /// تدرج سفلي
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),

                  /// معلومات
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          person.name,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.amiri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          person.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ──────────────────────────────────────
  //               الهيدر
  // ──────────────────────────────────────
  Widget _buildHeader(Color primary, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0E1714), primary.withOpacity(0.4)]
              : [primary, primary.withOpacity(0.75)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
              top: -40,
              right: -30,
              child: _circle(150, _gold.withOpacity(0.06))),
          Positioned(
              bottom: -20,
              left: -20,
              child: _circle(100, Colors.white.withOpacity(0.04))),
          Positioned(
              top: 60,
              left: 30,
              child: Icon(Icons.star_rounded,
                  size: 14, color: _gold.withOpacity(0.15))),
          Positioned(
              top: 90,
              right: 50,
              child: Icon(Icons.auto_awesome_rounded,
                  size: 12, color: _gold.withOpacity(0.12))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _gold.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: _gold, size: 14),
                        const SizedBox(width: 4),
                        Text('سلسلة العظماء',
                            style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('عظماء الإسلام',
                      style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.1)),
                  const SizedBox(height: 6),
                  Text('تعرّف على أعظم شخصيات الحضارة الإسلامية',
                      style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────
  //             البحث
  // ──────────────────────────────────────
  Widget _buildSearchBar(Color primary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF152620) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
                color: primary.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'ابحث عن شخصية...',
            hintStyle: GoogleFonts.cairo(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 14,
                fontWeight: FontWeight.w600),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            prefixIcon: Icon(Icons.search_rounded,
                color: primary.withOpacity(0.5), size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear_rounded,
                  color: primary.withOpacity(0.5), size: 20),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
            )
                : null,
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  //             الفئات
  // ──────────────────────────────────────
  Widget _buildCategoryChips(Color primary, bool isDark) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final selected = i == _selectedCatIndex;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCatIndex = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                      colors: [primary, primary.withOpacity(0.8)])
                      : null,
                  color: selected
                      ? null
                      : (isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: selected
                          ? primary.withOpacity(0.3)
                          : Colors.transparent),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                        color: primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                      : null,
                ),
                child: Text(
                  _categories[i],
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────
  //          البطاقة المميزة
  // ──────────────────────────────────────
  Widget _buildFeaturedCard(
      GreatMuslim person, Color primary, bool isDark) {
    final tag = 'great_person_${person.id}';

    return GestureDetector(
      onTap: () => _navigate(person, tag, primary),
      child: Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 260,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10)),
                BoxShadow(
                    color: _gold.withOpacity(0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(person.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _errorBox(primary)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.3, 0.6, 1],
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.88),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border:
                      Border.all(color: _gold.withOpacity(0.2), width: 1.5),
                    ),
                  ),
                  // شارة
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [_gold, _gold.withOpacity(0.8)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: _gold.withOpacity(0.3), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('شخصية مميزة',
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  // العصر
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(person.era,
                          style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  // المعلومات
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(28)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.45),
                              ],
                            ),
                            border: Border(
                                top: BorderSide(
                                    color: _gold.withOpacity(0.15))),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(person.name,
                                  style: GoogleFonts.amiri(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              _badge(person.title),
                              const SizedBox(height: 8),
                              Text(person.desc,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.cairo(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  //           البطاقة العادية
  // ──────────────────────────────────────
  Widget _buildPersonCard(
      GreatMuslim person, int index, Color primary, bool isDark) {
    final tag = 'great_person_${person.id}';
    final cardBg = isDark ? const Color(0xFF152620) : Colors.white;

    return GestureDetector(
      onTap: () => _navigate(person, tag, primary),
      child: Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: primary.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                    color: primary.withOpacity(isDark ? 0.08 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  // الصورة
                  Container(
                    width: 90,
                    height: 105,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(person.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _errorBox(primary)),
                          // رقم
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  _gold,
                                  _gold.withOpacity(0.8)
                                ]),
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: [
                                  BoxShadow(
                                      color: _gold.withOpacity(0.3),
                                      blurRadius: 4),
                                ],
                              ),
                              child: Center(
                                child: Text('${index + 1}',
                                    style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // المعلومات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(person.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.amiri(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: primary)),
                        const SizedBox(height: 4),
                        _badge(person.title, small: true),
                        const SizedBox(height: 4),
                        // العصر
                        Text(person.era,
                            style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                color: _gold,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(person.desc,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.black54,
                                fontWeight: FontWeight.w600,
                                height: 1.4)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_ios_rounded,
                                      color: primary, size: 11),
                                  const SizedBox(width: 4),
                                  Text('اقرأ السيرة',
                                      style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: primary,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  //           عناصر مساعدة
  // ──────────────────────────────────────
  Widget _buildEmpty(Color primary, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _searchQuery.isNotEmpty || _selectedCatIndex > 0
                  ? Icons.search_off_rounded
                  : Icons.error_outline_rounded,
              size: 44,
              color: _gold.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty || _selectedCatIndex > 0
                ? 'لا توجد نتائج'
                : 'تعذّر تحميل البيانات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCatIndex > 0
                ? 'جرب البحث باسم آخر أو تغيير الفئة'
                : 'تأكد من وجود ملف البيانات',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w600,
            ),
          ),
          // زر إعادة المحاولة عند فشل التحميل
          if (_searchQuery.isEmpty && _selectedCatIndex == 0) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                GreatMuslimsService.clearCache();
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchCtrl.clear();
        _searchFocus.unfocus();
      } else {
        Future.delayed(
            const Duration(milliseconds: 300), () => _searchFocus.requestFocus());
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

  Widget _appBarBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      onPressed: onTap,
    );
  }

  Widget _badge(String text, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 10, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
              color: _gold,
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _errorBox(Color primary) {
    return Container(
      decoration: BoxDecoration(
        gradient:
        LinearGradient(colors: [primary, primary.withOpacity(0.5)]),
      ),
      child: Center(
        child: Icon(Icons.person_rounded,
            size: 40, color: Colors.white.withOpacity(0.25)),
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildBg(Color primary, bool isDark) {
    final s = _scrollOffset * 0.04;
    final o = (1 - (_scrollOffset / 600)).clamp(0.3, 1.0);
    return IgnorePointer(
      child: Opacity(
        opacity: o,
        child: Stack(
          children: [
            Positioned(
                top: 300 - s,
                right: -40,
                child: _circle(120, primary.withOpacity(0.04))),
            Positioned(
                top: 500 - s,
                left: -30,
                child: _circle(100, _gold.withOpacity(0.04))),
            Positioned(
                bottom: 200 + s,
                right: -20,
                child: _circle(80, primary.withOpacity(0.03))),
          ],
        ),
      ),
    );
  }
}