// lib/screens/asma_allah/asma_allah_detail_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../languages/app_localizations.dart';
import '../../services/asma_allah_service.dart';
import 'detail/asma_detail_nav_buttons.dart';
import 'widgets/asma_theme.dart';
import 'widgets/asma_painters.dart';
import 'widgets/asma_shared_widgets.dart';

class AsmaAllahDetailScreen extends StatefulWidget {
  final String fullName;     // âœ… ط§ظ„ط§ط³ظ… ط§ظ„ظƒط§ظ…ظ„ ظ…ظ† JSON
  final String displayName;  // âœ… ط§ظ„ط§ط³ظ… ط§ظ„ظ‚طµظٹط±
  final String meaning;
  final Color primaryColor;
  final int order;
  final List<Map<String, String>> names;
  final String heroTag;

  const AsmaAllahDetailScreen({
    super.key,
    required this.fullName,
    required this.displayName,
    required this.meaning,
    required this.primaryColor,
    required this.order,
    required this.names,
    required this.heroTag,
  });

  @override
  State<AsmaAllahDetailScreen> createState() => _AsmaAllahDetailScreenState();
}

class _AsmaAllahDetailScreenState extends State<AsmaAllahDetailScreen>
    with SingleTickerProviderStateMixin {
  String _detailedMeaning = '';
  String _reflection = '';
  bool _isLoading = true;
  bool _isFirstLoad = true;

  late AnimationController _controller;
  late Animation<double> _fadeTop;
  late Animation<double> _fadeCard;
  late Animation<double> _fadeButtons;
  late Animation<Offset> _slideTop;
  late Animation<Offset> _slideCard;
  late Animation<Offset> _slideButtons;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeTop = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut));
    _fadeCard = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.75, curve: Curves.easeOut));
    _fadeButtons = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut));

    _slideTop = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)));
    _slideCard = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.75, curve: Curves.easeOutCubic)));
    _slideButtons =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic)));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadNameData();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNameData() async {
    try {
      final langCode = Localizations.localeOf(context).languageCode;
      final data = await AsmaAllahService.getNameByOrder(widget.order, langCode);
      if (mounted) {
        setState(() {
          _detailedMeaning = data['meaning'] as String;
          _reflection = (data['reflection'] ?? '') as String;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detailedMeaning = widget.meaning;
          _reflection = context.tr.defaultReflection;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareName() async {
    await Share.share(
      context.tr.shareAsmaFormat(widget.displayName, widget.meaning),
    );
  }

  void _goToName(BuildContext context, int newIndex) async {
    try {
      final langCode = Localizations.localeOf(context).languageCode;
      final data = await AsmaAllahService.getNameByOrder(newIndex, langCode);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => AsmaAllahDetailScreen(
            fullName: data['fullName'] as String,        // âœ…
            displayName: data['displayName'] as String,  // âœ…
            meaning: data['meaning'] as String,
            primaryColor: widget.primaryColor,
            order: newIndex,
            names: widget.names,
            heroTag: 'asma_name_$newIndex',
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      final item = widget.names[newIndex - 1];
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AsmaAllahDetailScreen(
            fullName: item['name']!,
            displayName: item['displayName'] ?? item['name']!,
            meaning: item['meaning']!,
            primaryColor: widget.primaryColor,
            order: newIndex,
            names: widget.names,
            heroTag: 'asma_name_$newIndex',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = AsmaTheme(isDark: isDark);
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.width < 360;
    final isMedium = screenSize.width < 400;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Directionality(
      textDirection: context.tr.textDirection,
      child: Scaffold(
        backgroundColor:
        isDark ? const Color(0xFF0A0E1A) : const Color(0xFFFFFDF8),
        body: Stack(
          children: [
            Positioned.fill(child: _buildBackground(isDark)),
            Column(
              children: [
                _buildAppBar(context, isDark, isSmall),
                Expanded(
                  child:
                  _buildContent(context, isDark, theme, isSmall, isMedium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AsmaTheme(isDark: isDark).bgGradientAlt,
        ),
      ),
      child: CustomPaint(
        painter: AsmaIslamicPatternPainter(
          color: isDark
              ? AsmaTheme.gold.withValues(alpha: 0.03)
              : AsmaTheme.gold.withValues(alpha: 0.05),
          step: 60,
          sides: 8,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? const Color(0xFF1A2540)
                : const Color(0xFFEEB742).withValues(alpha: 0.95),
            isDark
                ? const Color(0xFF0F1628)
                : const Color(0xFF9D7A2E).withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : widget.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isSmall ? 12 : 16,
            isSmall ? 8 : 12,
            isSmall ? 12 : 16,
            isSmall ? 16 : 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildAppBarButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                    isDark: isDark,
                    isSmall: isSmall,
                  ),
                  const Spacer(),
                  _buildOrderBadge(isSmall),
                  SizedBox(width: isSmall ? 8 : 12),
                  _buildAppBarButton(
                    icon: Icons.share_rounded,
                    onTap: _shareName,
                    isDark: isDark,
                    isSmall: isSmall,
                  ),
                ],
              ),
              SizedBox(height: isSmall ? 12 : 16),
              // âœ… ط¹ط±ط¶ ط§ظ„ط§ط³ظ… ط§ظ„ظƒط§ظ…ظ„ ظپظٹ AppBar
              _buildFullNameDisplay(isSmall, isDark),
              SizedBox(height: isSmall ? 8 : 12),
              _buildProgressIndicator(isSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required bool isSmall,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.15),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isSmall ? 10 : 12),
          child: Icon(icon, color: Colors.white, size: isSmall ? 18 : 20),
        ),
      ),
    );
  }

  Widget _buildOrderBadge(bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AsmaTheme.gold.withValues(alpha: 0.9), AsmaTheme.goldDark]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AsmaTheme.gold.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              color: Colors.white, size: isSmall ? 14 : 16),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            '${widget.order} / ${widget.names.length}',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// âœ… ط¹ط±ط¶ ط§ظ„ط§ط³ظ… ط§ظ„ظƒط§ظ…ظ„ ظ…ظ† JSON ظپظٹ AppBar
  Widget _buildFullNameDisplay(bool isSmall, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDecorator(isSmall),
        SizedBox(width: isSmall ? 8 : 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.fullName, // âœ… ط§ظ„ط§ط³ظ… ط§ظ„ظƒط§ظ…ظ„ ظ‡ظ†ط§
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: isSmall ? 18 : 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                      color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: isSmall ? 8 : 12),
        _buildDecorator(isSmall, flip: true),
      ],
    );
  }

  Widget _buildDecorator(bool isSmall, {bool flip = false}) {
    return Transform.flip(
      flipX: flip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 15 : 20,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AsmaTheme.gold.withValues(alpha: 0.1), AsmaTheme.gold]),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 3),
          Container(
            width: isSmall ? 5 : 6,
            height: isSmall ? 5 : 6,
            decoration: BoxDecoration(
              color: AsmaTheme.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AsmaTheme.gold.withValues(alpha: 0.5), blurRadius: 6)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isSmall) {
    final progress = widget.order / widget.names.length;
    return Column(
      children: [
        Container(
          height: isSmall ? 4 : 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AsmaTheme.goldLight,
                        AsmaTheme.gold,
                        AsmaTheme.goldDark
                      ]),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                            color: AsmaTheme.gold.withValues(alpha: 0.5),
                            blurRadius: 6)
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: isSmall ? 6 : 8),
        Text(
          context.tr.nameOfTotalNames(widget.order),
          style: GoogleFonts.cairo(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: isSmall ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, AsmaTheme theme,
      bool isSmall, bool isMedium) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 20,
        vertical: isSmall ? 20 : 24,
      ),
      child: Column(
        children: [
          FadeTransition(
            opacity: _fadeTop,
            child: SlideTransition(
              position: _slideTop,
              child: _buildNameCircle(isDark, isSmall),
            ),
          ),
          SizedBox(height: isSmall ? 20 : 28),
          AsmaDecorativeDivider(isSmall: isSmall),
          SizedBox(height: isSmall ? 20 : 24),
          FadeTransition(
            opacity: _fadeCard,
            child: SlideTransition(
              position: _slideCard,
              child: _buildMeaningCard(isDark, isSmall, theme),
            ),
          ),
          SizedBox(height: isSmall ? 16 : 20),
          FadeTransition(
            opacity: _fadeCard,
            child: SlideTransition(
              position: _slideCard,
              child: _buildReflectionCard(isDark, isSmall, theme),
            ),
          ),
          SizedBox(height: isSmall ? 20 : 28),
          FadeTransition(
            opacity: _fadeButtons,
            child: SlideTransition(
              position: _slideButtons,
              child: AsmaDetailNavButtons(
                order: widget.order,
                totalNames: widget.names.length,
                isDark: isDark,
                isSmall: isSmall,
                onNavigate: (index) => _goToName(context, index),
              ),
            ),
          ),
          SizedBox(height: isSmall ? 16 : 20),
        ],
      ),
    );
  }

  /// âœ… ط¹ط±ط¶ ط§ظ„ط§ط³ظ… ط§ظ„ظ‚طµظٹط± ظپظٹ ط§ظ„ط¯ط§ط¦ط±ط©
  Widget _buildNameCircle(bool isDark, bool isSmall) {
    final size = isSmall ? 110.0 : 130.0;
    return Hero(
      tag: widget.heroTag,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isDark
                  ? [const Color(0xFF1E2A4A), const Color(0xFF0F1628)]
                  : [Colors.white, const Color(0xFFFFF8E8)],
            ),
            border: Border.all(color: AsmaTheme.gold, width: 3),
            boxShadow: [
              BoxShadow(
                color: AsmaTheme.gold.withValues(alpha: isDark ? 0.3 : 0.25),
                blurRadius: 25,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : AsmaTheme.gold.withValues(alpha: 0.1),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.75,
                height: size * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AsmaTheme.gold.withValues(alpha: 0.3), width: 1.5),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.all(size * 0.12),
                  child: Text(
                      widget.displayName, // âœ… ط§ظ„ط§ط³ظ… ط§ظ„ظ‚طµظٹط± ظ‡ظ†ط§
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: size * 0.26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AsmaTheme.gold : AsmaTheme.goldDark,
                      shadows: [
                        Shadow(
                            color: AsmaTheme.gold.withValues(alpha: 0.3),
                            blurRadius: 10)
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AsmaTheme.gold, AsmaTheme.goldDark]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AsmaTheme.gold.withValues(alpha: 0.4), blurRadius: 8)
                    ],
                  ),
                  child: Text('${widget.order}',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: isSmall ? 11 : 13,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeaningCard(bool isDark, bool isSmall, AsmaTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.cardGradient,
        ),
        borderRadius: BorderRadius.circular(AsmaTheme.cardRadius),
        border: Border.all(color: theme.cardBorder, width: 1.5),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AsmaTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book_rounded,
                    color: AsmaTheme.gold, size: isSmall ? 20 : 24),
              ),
              const SizedBox(width: 12),
              Text(context.tr.meaningTitle,
                  style: GoogleFonts.cairo(
                    fontSize: isSmall ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AsmaTheme.gold : AsmaTheme.goldDark,
                  )),
            ],
          ),
          SizedBox(height: isSmall ? 14 : 18),
          Text(
            _isLoading ? widget.meaning : _detailedMeaning,
            textAlign: TextAlign.justify,
            style: theme.bodyText(isSmall ? 14 : 16),
          ),
          SizedBox(height: isSmall ? 14 : 18),
          Container(
            padding: EdgeInsets.all(isSmall ? 12 : 14),
            decoration: BoxDecoration(
              color: AsmaTheme.gold.withValues(alpha: isDark ? 0.1 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AsmaTheme.gold.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: AsmaTheme.gold, size: isSmall ? 18 : 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr.reflectOnName,
                    style: GoogleFonts.cairo(
                      fontSize: isSmall ? 11 : 13,
                      color: theme.subTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(bool isDark, bool isSmall, AsmaTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            AsmaTheme.gold.withValues(alpha: 0.12),
            const Color(0xFF1A2438).withValues(alpha: 0.9)
          ]
              : [AsmaTheme.gold.withValues(alpha: 0.08), const Color(0xFFFFF8E8)],
        ),
        borderRadius: BorderRadius.circular(AsmaTheme.cardRadius),
        border: Border.all(
          color: AsmaTheme.gold.withValues(alpha: isDark ? 0.35 : 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AsmaTheme.gold.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: AsmaTheme.gold, size: isSmall ? 20 : 24),
              const SizedBox(width: 10),
              Text(context.tr.reflectionAndDua,
                  style: GoogleFonts.cairo(
                    fontSize: isSmall ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AsmaTheme.gold : AsmaTheme.goldDark,
                  )),
              const SizedBox(width: 10),
              Icon(Icons.auto_awesome_rounded,
                  color: AsmaTheme.gold, size: isSmall ? 20 : 24),
            ],
          ),
          SizedBox(height: isSmall ? 16 : 20),
          Icon(Icons.format_quote_rounded,
              color: AsmaTheme.gold.withValues(alpha: 0.4), size: isSmall ? 30 : 36),
          SizedBox(height: isSmall ? 8 : 12),
          _isLoading
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AsmaTheme.gold),
            ),
          )
              : Text(
            _reflection,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: isSmall ? 17 : 20,
              height: 2.0,
              fontWeight: FontWeight.w600,
              color: theme.textColor,
            ),
          ),
          SizedBox(height: isSmall ? 8 : 12),
          Transform.rotate(
            angle: math.pi,
            child: Icon(Icons.format_quote_rounded,
                color: AsmaTheme.gold.withValues(alpha: 0.4), size: isSmall ? 30 : 36),
          ),
        ],
      ),
    );
  }
}