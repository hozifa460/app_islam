import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/great_muslims_service.dart';

class GreatPersonDetailScreen extends StatefulWidget {
  final GreatMuslim person;
  final List<GreatMuslim> allPersons;
  final Color primaryColor;
  final String heroTag;

  const GreatPersonDetailScreen({
    super.key,
    required this.person,
    this.allPersons = const [],
    required this.primaryColor,
    required this.heroTag,
  });

  @override
  State<GreatPersonDetailScreen> createState() => _GreatPersonDetailScreenState();
}

class _GreatPersonDetailScreenState extends State<GreatPersonDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _revealCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;
  late ScrollController _scrollController;

  double _scrollOffset = 0.0;
  bool _showTitle = false;
  GreatMuslim? _nextPerson;
  GreatMuslim? _prevPerson;

  static const _gold = Color(0xFFC8A44D);
  static const _parchment = Color(0xFFF5E6C8);

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
          _showTitle = _scrollOffset > 280;
        });
      });

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _setupNavigation();
  }

  void _setupNavigation() {
    final idx = widget.allPersons.indexWhere((p) => p.id == widget.person.id);
    if (idx > 0) _prevPerson = widget.allPersons[idx - 1];
    if (idx < widget.allPersons.length - 1) _nextPerson = widget.allPersons[idx + 1];
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _share() {
    HapticFeedback.lightImpact();
    final p = widget.person;
    final text = '''
✨ ${p.name} ✨
${p.title}
📅 ${p.era}

📖 ${p.details}

${p.quote.isNotEmpty ? '💬 "${p.quote}"' : ''}

— من تطبيق طريق الإسلام
''';
    Share.share(text.trim());
  }

  void _navigateTo(GreatMuslim person) {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => GreatPersonDetailScreen(
          person: person,
          allPersons: widget.allPersons,
          primaryColor: widget.primaryColor,
          heroTag: 'great_person_${person.id}',
        ),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0D0B) : const Color(0xFFFAF8F3);
    final cardBg = isDark ? const Color(0xFF141A17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final p = widget.person;
    final primary = widget.primaryColor;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // 1. خلفية الجسيمات المتحركة
            _FloatingParticles(controller: _particleCtrl, color: _gold),

            // 2. المحتوى الرئيسي
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ═══════ الهيدر السينمائي ═══════
                SliverAppBar(
                  expandedHeight: size.height * 0.55,
                  pinned: true,
                  stretch: true,
                  backgroundColor: _showTitle ? primary : Colors.transparent,
                  elevation: 0,
                  leading: _buildBackButton(),
                  title: AnimatedOpacity(
                    opacity: _showTitle ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      p.name,
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  actions: [
                    _buildActionButton(Icons.share_rounded, _share),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    background: Hero(
                      tag: widget.heroTag,
                      child: _buildCinematicHeader(p, primary, size),
                    ),
                  ),
                ),

                // ═══════ شريط المعلومات السريعة ═══════
                SliverToBoxAdapter(
                  child: _buildFloatingInfoBar(p, primary, isDark),
                ),

                // ═══════ المحتوى ═══════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: Column(
                      children: [
                        // السيرة الذاتية - ستايل المخطوطة
                        _buildParchmentBio(p, cardBg, isDark, textColor, primary),

                        // الإنجازات - ستايل الميداليات
                        if (p.achievements.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildMedalAchievements(p, cardBg, isDark, textColor, primary),
                        ],

                        // المقولة - ستايل النقش
                        if (p.quote.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildEngravedQuote(p, isDark, primary),
                        ],

                        // التنقل بين الشخصيات
                        const SizedBox(height: 32),
                        _buildNavigationCards(cardBg, isDark, primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 3. شريط التنقل السفلي
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(primary, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //                  الهيدر السينمائي
  // ═══════════════════════════════════════════════════════════
  Widget _buildCinematicHeader(GreatMuslim p, Color primary, Size size) {
    final parallax = _scrollOffset * 0.5;

    return Stack(
      fit: StackFit.expand,
      children: [
        // الصورة مع Parallax
        Transform.translate(
          offset: Offset(0, parallax),
          child: Transform.scale(
            scale: 1 + (_scrollOffset < 0 ? _scrollOffset.abs() / 500 : 0),
            child: Image.asset(
              p.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, primary.withOpacity(0.6)],
                  ),
                ),
                child: Icon(Icons.person, size: 100, color: Colors.white24),
              ),
            ),
          ),
        ),

        // تدرج سينمائي متعدد الطبقات
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.3, 0.6, 0.85, 1],
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.95),
              ],
            ),
          ),
        ),

        // تأثير الـ Vignette
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),

        // الإطار الذهبي المتوهج
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final v = _pulseCtrl.value;
            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: _gold.withOpacity(0.1 + v * 0.15),
                  width: 1,
                ),
              ),
            );
          },
        ),

        // شارة "من عظماء الإسلام"
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          right: 20,
          child: _buildAnimatedBadge(),
        ),

        // معلومات الشخصية
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                  border: Border(
                    top: BorderSide(color: _gold.withOpacity(0.3), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // الاسم
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.8)],
                      ).createShader(bounds),
                      child: Text(
                        p.name,
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // اللقب
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_gold.withOpacity(0.3), _gold.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _gold.withOpacity(0.5)),
                      ),
                      child: Text(
                        p.title,
                        style: GoogleFonts.cairo(
                          color: _parchment,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //                  شريط المعلومات العائم
  // ═══════════════════════════════════════════════════════════
  Widget _buildFloatingInfoBar(GreatMuslim p, Color primary, bool isDark) {
    final items = [
      {'icon': Icons.category_rounded, 'value': p.category},
      {'icon': Icons.history_rounded, 'value': p.era},
      {'icon': Icons.date_range_rounded, 'value': '${p.birthYear} - ${p.deathYear}'},
    ];

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withOpacity(0.2)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                        left: BorderSide(
                          color: _gold.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: _gold,
                          size: 20,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['value'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //                  السيرة - ستايل المخطوطة
  // ═══════════════════════════════════════════════════════════
  Widget _buildParchmentBio(
      GreatMuslim p, Color cardBg, bool isDark, Color text, Color primary) {
    return _animatedReveal(
      delay: 0.1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? cardBg : _parchment.withOpacity(0.3),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _gold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // زخارف الأركان
            Positioned(
              top: 0,
              right: 0,
              child: _cornerDecoration(true),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _cornerDecoration(false),
            ),

            // المحتوى
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // العنوان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'سيرته العطرة',
                        style: GoogleFonts.amiri(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.auto_stories, color: _gold, size: 22),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  _ornamentalDivider(),
                  const SizedBox(height: 20),

                  // النص
                  Text(
                    p.details,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 17,
                      height: 2.2,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF2D2416),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //                  الإنجازات - ستايل الميداليات
  // ═══════════════════════════════════════════════════════════
  Widget _buildMedalAchievements(
      GreatMuslim p, Color cardBg, bool isDark, Color text, Color primary) {
    return _animatedReveal(
      delay: 0.25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // العنوان
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'إنجازاته الخالدة',
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _gold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_gold, _gold.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 12),
                    ],
                  ),
                  child: const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // قائمة الإنجازات
          ...p.achievements.asMap().entries.map((entry) {
            final idx = entry.key;
            final achievement = entry.value;

            return _animatedReveal(
              delay: 0.3 + idx * 0.08,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الميدالية
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _gold,
                            _gold.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.white.withOpacity(0.3), size: 40),
                          Text(
                            '${idx + 1}',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // نص الإنجاز
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _gold.withOpacity(0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          achievement,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            height: 1.7,
                            fontWeight: FontWeight.w600,
                            color: text.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //                  المقولة - ستايل النقش
  // ═══════════════════════════════════════════════════════════
  Widget _buildEngravedQuote(GreatMuslim p, bool isDark, Color primary) {
    return _animatedReveal(
      delay: 0.4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [const Color(0xFF1A1510), const Color(0xFF0F0D0A)]
                : [const Color(0xFFF8F0E3), _parchment],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _gold.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          children: [
            // علامات الاقتباس الكبيرة
            Positioned(
              top: 10,
              right: 20,
              child: Icon(
                Icons.format_quote,
                size: 60,
                color: _gold.withOpacity(0.15),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 20,
              child: Transform.rotate(
                angle: pi,
                child: Icon(
                  Icons.format_quote,
                  size: 60,
                  color: _gold.withOpacity(0.15),
                ),
              ),
            ),

            // المحتوى
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // أيقونة
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: _gold.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.lightbulb_outline, color: _gold, size: 26),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'من حكمه ومواعظه',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: _gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الفاصل الزخرفي
                  _ornamentalDivider(),
                  const SizedBox(height: 24),

                  // المقولة
                  Text(
                    '❝ ${p.quote} ❞',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 24,
                      height: 2.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2E2415),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _ornamentalDivider(),
                  const SizedBox(height: 16),

                  // اسم القائل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 1,
                        color: _gold.withOpacity(0.3),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          p.name,
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            color: _gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 1,
                        color: _gold.withOpacity(0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //                  بطاقات التنقل
  // ═══════════════════════════════════════════════════════════
  Widget _buildNavigationCards(Color cardBg, bool isDark, Color primary) {
    if (_prevPerson == null && _nextPerson == null) return const SizedBox();

    return _animatedReveal(
      delay: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 16),
            child: Text(
              'استكشف المزيد',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ),

          Row(
            textDirection: TextDirection.rtl,
            children: [
              if (_nextPerson != null)
                Expanded(
                  child: _navigationCard(_nextPerson!, 'التالي', Icons.arrow_back_ios, cardBg, isDark),
                ),
              if (_prevPerson != null && _nextPerson != null) const SizedBox(width: 12),
              if (_prevPerson != null)
                Expanded(
                  child: _navigationCard(_prevPerson!, 'السابق', Icons.arrow_forward_ios, cardBg, isDark),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navigationCard(
      GreatMuslim person, String label, IconData icon, Color cardBg, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateTo(person),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                person.image,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 55,
                  height: 55,
                  color: _gold.withOpacity(0.2),
                  child: Icon(Icons.person, color: _gold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amiri(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //                  الشريط السفلي
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomBar(Color primary, bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
            border: Border(top: BorderSide(color: _gold.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _share,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    'مشاركة السيرة',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withOpacity(0.3)),
                ),
                child: IconButton(
                  onPressed: () {
                    // يمكن إضافة وظيفة الحفظ
                    HapticFeedback.lightImpact();
                  },
                  icon: Icon(Icons.bookmark_outline, color: _gold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //                  عناصر مساعدة
  // ═══════════════════════════════════════════════════════════
  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBadge() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        final scale = 1.0 + _pulseCtrl.value * 0.05;
        return Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_gold.withOpacity(0.3), _gold.withOpacity(0.15)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: _gold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'من عظماء الإسلام',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cornerDecoration(bool topRight) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _CornerPainter(
          color: _gold.withOpacity(0.15),
          topRight: topRight,
        ),
      ),
    );
  }

  Widget _ornamentalDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: _gold.withOpacity(0.3)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.auto_awesome, color: _gold, size: 16),
        ),
        Container(width: 40, height: 1, color: _gold.withOpacity(0.3)),
      ],
    );
  }

  Widget _animatedReveal({required double delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _revealCtrl,
      builder: (_, __) {
        final value = CurvedAnimation(
          parent: _revealCtrl,
          curve: Interval(delay, delay + 0.3, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  الجسيمات المتحركة
// ═══════════════════════════════════════════════════════════
class _FloatingParticles extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _FloatingParticles({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Stack(
          children: List.generate(8, (i) {
            final offset = controller.value + i * 0.125;
            final y = (offset % 1) * MediaQuery.of(context).size.height;
            final x = (sin(offset * 2 * pi + i) * 0.3 + 0.5) * MediaQuery.of(context).size.width;
            final size = 4.0 + (i % 3) * 2;
            final opacity = 0.1 + (sin(offset * pi) + 1) * 0.1;

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//                  رسام زخرفة الأركان
// ═══════════════════════════════════════════════════════════
class _CornerPainter extends CustomPainter {
  final Color color;
  final bool topRight;

  _CornerPainter({required this.color, required this.topRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (topRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.7);
      path.moveTo(size.width, 0);
      path.lineTo(size.width * 0.3, 0);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(0, size.height * 0.3);
      path.moveTo(0, size.height);
      path.lineTo(size.width * 0.7, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}