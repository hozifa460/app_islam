import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/GreatMuslim/theme/great_muslims_animations.dart';
import 'package:islamic_app/screens/GreatMuslim/theme/great_muslims_styled_widgets.dart';
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
  State<GreatPersonDetailScreen> createState() =>
      _GreatPersonDetailScreenState();
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
    final idx =
    widget.allPersons.indexWhere((p) => p.id == widget.person.id);
    if (idx > 0) _prevPerson = widget.allPersons[idx - 1];
    if (idx < widget.allPersons.length - 1) {
      _nextPerson = widget.allPersons[idx + 1];
    }
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
              ).animate(CurvedAnimation(
                parent: anim,
                curve: Curves.easeOutCubic,
              )),
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
            // 1. خلفية الجسيمات
            FloatingParticles(
              controller: _particleCtrl,
              color: GreatMuslimsColors.gold,
            ),

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
                  backgroundColor:
                  _showTitle ? primary : Colors.transparent,
                  elevation: 0,
                  leading: BlurredIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
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
                    BlurredIconButton(
                      icon: Icons.share_rounded,
                      onTap: _share,
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    background: Hero(
                      tag: widget.heroTag,
                      child: CinematicHeaderContent(
                        person: p,
                        primary: primary,
                        screenSize: size,
                        scrollOffset: _scrollOffset,
                        topPadding: MediaQuery.of(context).padding.top,
                        pulsingBorder: PulsingGoldenBorder(
                          controller: _pulseCtrl,
                        ),
                        animatedBadge: AnimatedPulseBadge(
                          controller: _pulseCtrl,
                          text: 'من عظماء الإسلام',
                          icon: Icons.star,
                        ),
                      ),
                    ),
                  ),
                ),

                // ═══════ شريط المعلومات ═══════
                SliverToBoxAdapter(
                  child: FloatingInfoBar(
                    person: p,
                    isDark: isDark,
                  ),
                ),

                // ═══════ المحتوى ═══════
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: Column(
                      children: [
                        // السيرة
                        AnimatedRevealWidget(
                          controller: _revealCtrl,
                          delay: 0.1,
                          child: ParchmentBioCard(
                            person: p,
                            cardBg: cardBg,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                        ),

                        // الإنجازات
                        if (p.achievements.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildMedalAchievements(
                            p, cardBg, isDark, textColor, primary,
                          ),
                        ],

                        // المقولة
                        if (p.quote.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          AnimatedRevealWidget(
                            controller: _revealCtrl,
                            delay: 0.4,
                            child: EngravedQuoteCard(
                              person: p,
                              isDark: isDark,
                            ),
                          ),
                        ],

                        // التنقل
                        const SizedBox(height: 32),
                        _buildNavigationCards(
                          cardBg, isDark, primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 3. الشريط السفلي
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BlurredBottomBar(
                primary: primary,
                isDark: isDark,
                onShare: _share,
                onBookmark: () {
                  HapticFeedback.lightImpact();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //          الإنجازات (تستخدم أنيميشن داخلي لكل عنصر)
  // ═══════════════════════════════════════════════════════════
  Widget _buildMedalAchievements(
      GreatMuslim p,
      Color cardBg,
      bool isDark,
      Color text,
      Color primary,
      ) {
    return AnimatedRevealWidget(
      controller: _revealCtrl,
      delay: 0.25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const AchievementsSectionHeader(),
          ...p.achievements.asMap().entries.map((entry) {
            final idx = entry.key;
            final achievement = entry.value;

            return AnimatedRevealWidget(
              controller: _revealCtrl,
              delay: 0.3 + idx * 0.08,
              child: AchievementMedalItem(
                achievement: achievement,
                index: idx,
                cardBg: cardBg,
                textColor: text,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //          بطاقات التنقل
  // ═══════════════════════════════════════════════════════════
  Widget _buildNavigationCards(
      Color cardBg,
      bool isDark,
      Color primary,
      ) {
    if (_prevPerson == null && _nextPerson == null) {
      return const SizedBox();
    }

    return AnimatedRevealWidget(
      controller: _revealCtrl,
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
                  child: NavigationPersonCard(
                    person: _nextPerson!,
                    label: 'التالي',
                    cardBg: cardBg,
                    isDark: isDark,
                    onTap: () => _navigateTo(_nextPerson!),
                  ),
                ),
              if (_prevPerson != null && _nextPerson != null)
                const SizedBox(width: 12),
              if (_prevPerson != null)
                Expanded(
                  child: NavigationPersonCard(
                    person: _prevPerson!,
                    label: 'السابق',
                    cardBg: cardBg,
                    isDark: isDark,
                    onTap: () => _navigateTo(_prevPerson!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}