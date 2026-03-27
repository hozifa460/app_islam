import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/sunnah_model.dart';
import '../services/sunnah_service.dart';

class SunnahTrackerScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const SunnahTrackerScreen({
    Key? key,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<SunnahTrackerScreen> createState() => _SunnahTrackerScreenState();
}

class _SunnahTrackerScreenState extends State<SunnahTrackerScreen>
    with TickerProviderStateMixin {
  final SunnahService _service = SunnahService();
  bool _isLoading = true;
  late Timer _timer;

  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  late AnimationController _fadeInController;

  late Animation<double> _pulseAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _floatingAnim;
  late Animation<double> _fadeInAnim;

  late TabController _tabController;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['الكل', 'مؤكدة', 'مستحبة', 'غير مكتملة'];

  // ==================== Theme Colors ====================
  // Dark Mode
  static const Color _darkBg = Color(0xFF0A0E1A);
  static const Color _darkCard = Color(0xFF111827);
  static const Color _darkDivider = Color(0xFF1F2937);
  static const Color _darkTextPrimary = Color(0xFFF9FAFB);
  static const Color _darkTextSecondary = Color(0xFF9CA3AF);

  // Light Mode
  static const Color _lightBg = Color(0xFFF0F4F8);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightDivider = Color(0xFFE5E7EB);
  static const Color _lightTextPrimary = Color(0xFF111827);
  static const Color _lightTextSecondary = Color(0xFF6B7280);

  // Shared
  static const Color _emerald = Color(0xFF10B981);
  static const Color _emeraldDark = Color(0xFF059669);
  static const Color _emeraldLight = Color(0xFF34D399);
  static const Color _gold = Color(0xFFD97706);
  static const Color _goldLight = Color(0xFFFBBF24);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _blueLight = Color(0xFF3B82F6);

  // Getters
  bool get _isDark => widget.isDarkMode;
  Color get _bg => _isDark ? _darkBg : _lightBg;
  Color get _card => _isDark ? _darkCard : _lightCard;
  Color get _divider => _isDark ? _darkDivider : _lightDivider;
  Color get _textPrimary => _isDark ? _darkTextPrimary : _lightTextPrimary;
  Color get _textSecondary => _isDark ? _darkTextSecondary : _lightTextSecondary;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _initAnimations() {
    _tabController = TabController(length: 2, vsync: this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _floatingAnim = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeInAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut),
    );
  }

  Future<void> _loadData() async {
    await _service.loadData();
    if (mounted) {
      setState(() => _isLoading = false);
      _fadeInController.forward();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    _fadeInController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) =>
      Color(int.parse(hex.replaceFirst('#', '0xFF')));

  String _getDayName(int weekday) {
    const days = {
      1: 'الاثنين', 2: 'الثلاثاء', 3: 'الأربعاء',
      4: 'الخميس', 5: 'الجمعة', 6: 'السبت', 7: 'الأحد',
    };
    return days[weekday] ?? '';
  }

  // ==================== Build ====================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: _bg,
          body: _isLoading
              ? _buildSplash(size, padding)
              : _buildBody(size, padding),
        ),
      ),
    );
  }

  // ==================== Splash ====================
  Widget _buildSplash(Size size, EdgeInsets padding) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDark
              ? [const Color(0xFF0A0E1A), const Color(0xFF0D1F17)]
              : [const Color(0xFFE8F5E9), const Color(0xFFF0F4F8)],
        ),
      ),
      child: Stack(
        children: [
          // Background Particles
          ...List.generate(15, (i) => _buildParticle(i, size)),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        width: size.width * 0.28,
                        height: size.width * 0.28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _emeraldLight.withOpacity(0.3),
                              _emeraldDark.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: _emerald.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _emerald.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '🕌',
                            style: TextStyle(
                              fontSize: size.width * 0.12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [_emeraldLight, _goldLight, _emeraldLight],
                    ).createShader(b),
                    child: Text(
                      'متتبع السنن النبوية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'احرص على سننه ﷺ',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: size.width * 0.038,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),
                  SizedBox(
                    width: size.width * 0.45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFF1F2937),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(_emerald),
                        minHeight: 4,
                      ),
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

  Widget _buildParticle(int index, Size size) {
    final rng = math.Random(index * 42);
    final w = rng.nextDouble() * 3 + 1;
    final left = rng.nextDouble() * size.width;
    final top = rng.nextDouble() * size.height;
    final colors = [_emerald, _gold, Colors.white70];
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (_, __) => Opacity(
          opacity:
          (math.sin(_pulseController.value * math.pi * 2 + index) + 1) /
              2 *
              0.5,
          child: Container(
            width: w,
            height: w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[index % 3],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Body ====================
  Widget _buildBody(Size size, EdgeInsets padding) {
    return FadeTransition(
      opacity: _fadeInAnim,
      child: Column(
        children: [
          _buildHeader(size, padding),
          _buildTabBar(size),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentTab(size),
                _buildAllTab(size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Header ====================
  Widget _buildHeader(Size size, EdgeInsets padding) {
    final now = DateTime.now();
    final currentSunnahs = _service.getCurrentSunnahs();
    final completed = currentSunnahs.where((s) => s.isCompleted).length;
    final total = currentSunnahs.length;
    final progress = total > 0 ? completed / total : 0.0;
    final isSmall = size.height < 700;

    return Container(
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: _isDark
              ? [
            const Color(0xFF0D2818),
            const Color(0xFF0A1520),
            const Color(0xFF0A0E1A),
          ]
              : [
            const Color(0xFF064E3B),
            const Color(0xFF065F46),
            const Color(0xFF047857),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _emerald.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Circles
          Positioned(
            top: -40,
            left: -40,
            child: _buildOrbDecoration(
              size.width * 0.45,
              _emerald.withOpacity(0.06),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: _buildOrbDecoration(
              size.width * 0.35,
              _gold.withOpacity(0.05),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.05,
                isSmall ? 10 : 16,
                size.width * 0.05,
                isSmall ? 14 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLiveBadge(),
                            SizedBox(height: isSmall ? 4 : 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: ShaderMask(
                                shaderCallback: (b) =>
                                    const LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Color(0xFFD1FAE5),
                                      ],
                                    ).createShader(b),
                                child: Text(
                                  'متتبع السنن النبوية',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.055,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isSmall ? 2 : 4),
                            Text(
                              'احرص على سنة نبيك ﷺ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: size.width * 0.032,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Column(
                        children: [
                          _buildClockWidget(now, size),
                          SizedBox(height: isSmall ? 4 : 8),
                          _buildThemeToggle(),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: isSmall ? 12 : 18),

                  // Stats
                  _buildStatsRow(size, completed, total),

                  SizedBox(height: isSmall ? 12 : 16),

                  // Progress
                  _buildProgressBar(progress, completed, total, size),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbDecoration(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildLiveBadge() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _emeraldLight,
              boxShadow: [
                BoxShadow(
                  color: _emeraldLight.withOpacity(_pulseAnim.value - 0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _service.getCurrentPeriodLabel(),
            style: TextStyle(
              color: _emeraldLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockWidget(DateTime now, Size size) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.035,
          vertical: size.height * 0.008,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _emerald.withOpacity(0.08 * _pulseAnim.value),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
            Text(
              _getDayName(now.weekday),
              style: TextStyle(
                color: _emeraldLight.withOpacity(0.85),
                fontSize: size.width * 0.026,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onToggleTheme();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Icon(
          _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: _isDark ? _goldLight : Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildStatsRow(Size size, int completed, int total) {
    final globalCompleted = _service.completedToday;
    final globalTotal = _service.totalSunnahs;
    final isSmall = size.width < 360;

    return Row(
      children: [
        _buildStatCard(
          value: '$completed/$total',
          label: 'سنة الوقت',
          emoji: '⏰',
          color: _emerald,
          size: size,
          isSmall: isSmall,
        ),
        SizedBox(width: size.width * 0.025),
        _buildStatCard(
          value: '$globalCompleted/$globalTotal',
          label: 'إجمالي اليوم',
          emoji: '📿',
          color: _goldLight,
          size: size,
          isSmall: isSmall,
        ),
        SizedBox(width: size.width * 0.025),
        _buildStatCard(
          value: '${globalTotal - globalCompleted}',
          label: 'متبقي',
          emoji: '🎯',
          color: _blueLight,
          size: size,
          isSmall: isSmall,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required String emoji,
    required Color color,
    required Size size,
    required bool isSmall,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.013,
          horizontal: size.width * 0.02,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: isSmall ? 14 : 16)),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: isSmall ? 9 : 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
      double progress, int completed, int total, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم الوقت الحالي',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: size.width * 0.03,
              ),
            ),
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (_, __) => ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  begin: Alignment(_shimmerAnim.value - 1, 0),
                  end: Alignment(_shimmerAnim.value, 0),
                  colors: const [_goldLight, Colors.white, _goldLight],
                ).createShader(b),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.008),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              widthFactor: progress,
              alignment: Alignment.centerRight,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [_emeraldLight, _emeraldDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _emerald.withOpacity(0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (progress == 1.0) ...[
          SizedBox(height: size.height * 0.006),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [_goldLight, _gold],
                ).createShader(b),
                child: const Text(
                  'أحسنت! أتممت سنن هذا الوقت',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ==================== TabBar ====================
  Widget _buildTabBar(Size size) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        size.width * 0.04,
        size.height * 0.012,
        size.width * 0.04,
        0,
      ),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: const LinearGradient(
            colors: [_emerald, _emeraldDark],
          ),
          boxShadow: [
            BoxShadow(
              color: _emerald.withOpacity(0.35),
              blurRadius: 8,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: _textSecondary,
        labelStyle: TextStyle(
          fontSize: size.width * 0.033,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(fontSize: size.width * 0.033),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⏰', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                const Flexible(
                  child: Text('سنن الآن', overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 4),
                _buildTabBadge(
                  '${_service.getCurrentSunnahs().length}',
                  _emerald,
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📋', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                const Flexible(
                  child: Text('جميع السنن', overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 4),
                _buildTabBadge(
                  '${_service.totalSunnahs}',
                  _purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==================== Current Tab ====================
  Widget _buildCurrentTab(Size size) {
    final sunnahs = _service.getCurrentSunnahs();
    if (sunnahs.isEmpty) return _buildEmptyState(size);

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _emerald,
      backgroundColor: _card,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          size.width * 0.04,
          size.height * 0.015,
          size.width * 0.04,
          size.height * 0.04,
        ),
        children: [
          _buildCurrentBanner(size, sunnahs),
          SizedBox(height: size.height * 0.015),
          ...sunnahs.asMap().entries.map(
                (e) => _buildSunnahCard(e.value, e.key, size),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBanner(Size size, List<SunnahModel> sunnahs) {
    final remaining = sunnahs.where((s) => !s.isCompleted).length;
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatingAnim.value * 0.2),
        child: child,
      ),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: _isDark
                ? [
              _emerald.withOpacity(0.15),
              _blue.withOpacity(0.08),
            ]
                : [
              _emerald.withOpacity(0.1),
              _emerald.withOpacity(0.04),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(
            color: _emerald.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _emerald.withOpacity(_isDark ? 0.08 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: size.width * 0.12,
                height: size.width * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_emerald, _emeraldDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _emerald.withOpacity(0.3 * _pulseAnim.value),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('⏰', style: TextStyle(fontSize: 22)),
                ),
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _service.getCurrentPeriodLabel(),
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    remaining > 0
                        ? 'تبقى لك $remaining سنة لم تكتمل بعد'
                        : '✨ ممتاز! أتممت جميع سنن هذا الوقت',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [_emerald, _emeraldDark],
                ),
              ),
              child: Text(
                '${sunnahs.length} سنة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== All Tab ====================
  Widget _buildAllTab(Size size) {
    final allSunnahs = _service.getAllSunnahs();
    final Map<String, List<SunnahModel>> grouped = {};
    for (var s in allSunnahs) {
      grouped.putIfAbsent(s.timeCategory, () => []).add(s);
    }

    final categoryOrder = [
      'fajr', 'morning_adhkar', 'duha', 'dhuhr', 'asr',
      'evening_adhkar', 'maghrib', 'isha', 'witr', 'tahajjud',
      'sleep', 'always', 'weekly_fast', 'monthly_fast',
      'friday', 'yearly_fast', 'yearly_prayer',
    ];

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _emerald,
      backgroundColor: _card,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          size.width * 0.04,
          size.height * 0.015,
          size.width * 0.04,
          size.height * 0.04,
        ),
        children: [
          _buildOverallStats(size),
          SizedBox(height: size.height * 0.015),
          _buildFilterChips(size, allSunnahs),
          SizedBox(height: size.height * 0.015),
          ...categoryOrder
              .where((cat) => grouped.containsKey(cat))
              .expand((category) {
            final items = _applyFilter(grouped[category]!);
            if (items.isEmpty) return <Widget>[];
            return [
              _buildCategoryHeader(category, grouped[category]!, size),
              SizedBox(height: size.height * 0.008),
              ...items.asMap().entries.map(
                    (e) => _buildSunnahCard(e.value, e.key, size),
              ),
              SizedBox(height: size.height * 0.01),
            ];
          }),
        ],
      ),
    );
  }

  List<SunnahModel> _applyFilter(List<SunnahModel> sunnahs) {
    switch (_selectedFilterIndex) {
      case 1:
        return sunnahs.where((s) => s.importance == 'مؤكدة').toList();
      case 2:
        return sunnahs.where((s) => s.importance == 'مستحبة').toList();
      case 3:
        return sunnahs.where((s) => !s.isCompleted).toList();
      default:
        return sunnahs;
    }
  }

  Widget _buildOverallStats(Size size) {
    final percentage = _service.completionPercentage;
    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: _isDark
              ? [const Color(0xFF0D2818), const Color(0xFF0A1520)]
              : [const Color(0xFF064E3B), const Color(0xFF065F46)],
        ),
        boxShadow: [
          BoxShadow(
            color: _emerald.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: size.width * 0.22,
            height: size.width * 0.22,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.22,
                  height: size.width * 0.22,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 5,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage == 100 ? _goldLight : _emeraldLight,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toInt()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: size.width * 0.025,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [_emeraldLight, _goldLight],
                  ).createShader(b),
                  child: Text(
                    'إنجازك اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                _buildStatRow(
                  '✅ أكملت',
                  '${_service.completedToday}',
                  _emeraldLight,
                  size,
                ),
                SizedBox(height: size.height * 0.005),
                _buildStatRow(
                  '📋 المجموع',
                  '${_service.totalSunnahs}',
                  _blueLight,
                  size,
                ),
                SizedBox(height: size.height * 0.005),
                _buildStatRow(
                  '⏳ المتبقي',
                  '${_service.totalSunnahs - _service.completedToday}',
                  _goldLight,
                  size,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String label, String value, Color color, Size size) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: size.width * 0.03,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.025,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: size.width * 0.033,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(Size size, List<SunnahModel> allSunnahs) {
    final counts = [
      allSunnahs.length,
      allSunnahs.where((s) => s.importance == 'مؤكدة').length,
      allSunnahs.where((s) => s.importance == 'مستحبة').length,
      allSunnahs.where((s) => !s.isCompleted).length,
    ];

    return SizedBox(
      height: size.height * 0.045,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: size.width * 0.02),
        itemBuilder: (context, i) {
          final selected = _selectedFilterIndex == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilterIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.035,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: selected
                    ? const LinearGradient(
                  colors: [_emerald, _emeraldDark],
                )
                    : null,
                color: selected ? null : _card,
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : _divider,
                  width: 1,
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: _emerald.withOpacity(0.35),
                    blurRadius: 8,
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _filters[i],
                    style: TextStyle(
                      color: selected ? Colors.white : _textSecondary,
                      fontSize: size.width * 0.03,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  SizedBox(width: size.width * 0.015),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withOpacity(0.2)
                          : _divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${counts[i]}',
                      style: TextStyle(
                        color: selected ? Colors.white : _textSecondary,
                        fontSize: size.width * 0.026,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(
      String category, List<SunnahModel> sunnahs, Size size) {
    final label = _service.getCategoryLabel(category);
    final isNow =
    _service.getCurrentSunnahs().any((s) => s.timeCategory == category);
    final completed = sunnahs.where((s) => s.isCompleted).length;
    final total = sunnahs.length;
    const icons = {
      'fajr': '🌙', 'morning_adhkar': '🌅', 'duha': '☀️',
      'dhuhr': '🌞', 'asr': '🌤️', 'evening_adhkar': '🌆',
      'maghrib': '🌇', 'isha': '🌃', 'witr': '⭐',
      'tahajjud': '🌟', 'sleep': '😴', 'always': '♾️',
      'weekly_fast': '📅', 'monthly_fast': '🌕',
      'friday': '🕌', 'yearly_fast': '🗓️', 'yearly_prayer': '🎊',
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isNow
            ? LinearGradient(
          colors: [
            _emerald.withOpacity(_isDark ? 0.18 : 0.12),
            _emerald.withOpacity(0.03),
          ],
        )
            : null,
        color: isNow ? null : _card,
        border: Border.all(
          color: isNow ? _emerald.withOpacity(0.35) : _divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            icons[category] ?? '📿',
            style: TextStyle(fontSize: size.width * 0.048),
          ),
          SizedBox(width: size.width * 0.025),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isNow ? _emeraldLight : _textPrimary,
                fontSize: size.width * 0.038,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isNow)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.022,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [_gold, _goldLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withOpacity(0.25 * _pulseAnim.value),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  '● الآن',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          SizedBox(width: size.width * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completed/$total',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: size.width * 0.028,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: size.width * 0.1,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    backgroundColor:
                    _isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isNow ? _emerald : _textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== Sunnah Card ====================
  Widget _buildSunnahCard(SunnahModel sunnah, int index, Size size) {
    final cardColor = _hexToColor(sunnah.color);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 40).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (_, val, child) => Transform.translate(
        offset: Offset(0, 16 * (1 - val)),
        child: Opacity(opacity: val.clamp(0.0, 1.0), child: child),
      ),
      child: GestureDetector(
        onTap: () => _showDetails(sunnah, size),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: size.height * 0.012),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: _card,
            gradient: sunnah.isCompleted
                ? LinearGradient(
              colors: _isDark
                  ? [
                _emerald.withOpacity(0.07),
                _card,
              ]
                  : [
                _emerald.withOpacity(0.05),
                _card,
              ],
            )
                : LinearGradient(
              colors: [
                _card,
                Color.lerp(_card, cardColor, _isDark ? 0.04 : 0.02)!,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: sunnah.isCompleted
                  ? _emerald.withOpacity(0.25)
                  : _divider,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (sunnah.isCompleted ? _emerald : cardColor)
                    .withOpacity(_isDark ? 0.08 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(_isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Right accent
              Positioned(
                right: 0,
                top: 10,
                bottom: 10,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: sunnah.isCompleted
                          ? [_emeraldLight, _emeraldDark]
                          : [
                        cardColor,
                        cardColor.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  size.height * 0.015,
                  size.width * 0.05,
                  size.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCardIcon(sunnah, cardColor, size),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sunnah.name,
                                      style: TextStyle(
                                        color: sunnah.isCompleted
                                            ? _textSecondary
                                            : _textPrimary,
                                        fontSize: size.width * 0.038,
                                        fontWeight: FontWeight.bold,
                                        decoration: sunnah.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: _textSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _buildImportanceBadge(
                                      sunnah.importance, size),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),
                              Text(
                                sunnah.description,
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: size.width * 0.03,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.012),
                    // Divider
                    Divider(color: _divider, height: 1),
                    SizedBox(height: size.height * 0.01),
                    // Bottom
                    Row(
                      children: [
                        _buildMiniTag(sunnah.type, cardColor, size),
                        if (sunnah.rakaat > 0) ...[
                          SizedBox(width: size.width * 0.015),
                          _buildMiniTag(
                              '${sunnah.rakaat} ركعات', _blue, size),
                        ],
                        const Spacer(),
                        _buildCompleteBtn(sunnah, cardColor, size),
                      ],
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

  Widget _buildCardIcon(SunnahModel sunnah, Color color, Size size) {
    final iconSize = size.width * 0.13;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: sunnah.isCompleted
            ? const LinearGradient(
          colors: [_emerald, _emeraldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [
            color.withOpacity(_isDark ? 0.2 : 0.12),
            color.withOpacity(_isDark ? 0.06 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: sunnah.isCompleted
              ? _emerald.withOpacity(0.4)
              : color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (sunnah.isCompleted ? _emerald : color)
                .withOpacity(0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: sunnah.isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
            : Text(
          sunnah.icon,
          style: TextStyle(fontSize: size.width * 0.058),
        ),
      ),
    );
  }

  Widget _buildImportanceBadge(String importance, Size size) {
    final isHigh = importance == 'مؤكدة';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isHigh
            ? const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        )
            : const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isHigh ? _purple : _blue).withOpacity(0.25),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        isHigh ? '★ مؤكدة' : '◆ مستحبة',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.024,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(_isDark ? 0.12 : 0.08),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.028,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCompleteBtn(SunnahModel sunnah, Color cardColor, Size size) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        await _service.toggleCompletion(sunnah.id);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.035,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: sunnah.isCompleted
              ? LinearGradient(
            colors: _isDark
                ? [const Color(0xFF374151), const Color(0xFF1F2937)]
                : [const Color(0xFFE5E7EB), const Color(0xFFD1D5DB)],
          )
              : LinearGradient(
            colors: [
              cardColor,
              Color.lerp(cardColor, Colors.black, 0.15)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (sunnah.isCompleted ? Colors.grey : cardColor)
                  .withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sunnah.isCompleted
                  ? Icons.close_rounded
                  : Icons.check_rounded,
              color: sunnah.isCompleted
                  ? (_isDark ? _textSecondary : Colors.black45)
                  : Colors.white,
              size: 14,
            ),
            SizedBox(width: size.width * 0.015),
            Text(
              sunnah.isCompleted ? 'إلغاء' : 'أكمل',
              style: TextStyle(
                color: sunnah.isCompleted
                    ? (_isDark ? _textSecondary : Colors.black54)
                    : Colors.white,
                fontSize: size.width * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Empty State ====================
  Widget _buildEmptyState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatingController,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _floatingAnim.value),
                child: child,
              ),
              child: Container(
                width: size.width * 0.28,
                height: size.width * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _emerald.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: _emerald.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '🌙',
                    style: TextStyle(fontSize: size.width * 0.14),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              'لا توجد سنن لهذا الوقت',
              style: TextStyle(
                color: _textPrimary,
                fontSize: size.width * 0.048,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'تفضل بمشاهدة جميع السنن\nمن التبويب الثاني',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: size.width * 0.035,
                height: 1.5,
              ),
            ),
            SizedBox(height: size.height * 0.035),
            GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.018,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [_emerald, _emeraldDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _emerald.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 16)),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'جميع السنن',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.038,
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
    );
  }

  // ==================== Details Sheet ====================
  void _showDetails(SunnahModel sunnah, Size size) {
    final cardColor = _hexToColor(sunnah.color);
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.62,
          maxChildSize: 0.92,
          minChildSize: 0.42,
          builder: (ctx, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: cardColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollCtrl,
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.06),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          cardColor.withOpacity(_isDark ? 0.12 : 0.08),
                          cardColor.withOpacity(0.02),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: size.width * 0.2,
                          height: size.width * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: [
                                cardColor.withOpacity(0.25),
                                cardColor.withOpacity(0.08),
                              ],
                            ),
                            border: Border.all(
                              color: cardColor.withOpacity(0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cardColor.withOpacity(0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              sunnah.icon,
                              style: TextStyle(
                                  fontSize: size.width * 0.1),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.018),
                        Text(
                          sunnah.name,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: size.width * 0.048,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.012),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildMiniTag(sunnah.type, cardColor, size),
                            _buildImportanceBadge(sunnah.importance, size),
                            if (sunnah.rakaat > 0)
                              _buildMiniTag(
                                  '${sunnah.rakaat} ركعات', _blue, size),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailCard(
                          icon: '📝',
                          title: 'الوصف',
                          content: sunnah.description,
                          color: cardColor,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.014),
                        _buildDetailCard(
                          icon: '📖',
                          title: 'الدليل من السنة',
                          content: sunnah.hadith,
                          color: _gold,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.014),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoTile(
                                _service.getCategoryLabel(
                                    sunnah.timeCategory),
                                'وقت السنة',
                                '🕐',
                                cardColor,
                                size,
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: _buildInfoTile(
                                sunnah.importance,
                                'الأهمية',
                                sunnah.importance == 'مؤكدة'
                                    ? '⭐'
                                    : '💫',
                                sunnah.importance == 'مؤكدة'
                                    ? _gold
                                    : _blue,
                                size,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.025),

                        // Action Button
                        StatefulBuilder(
                          builder: (ctx, setSheet) => GestureDetector(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              await _service.toggleCompletion(sunnah.id);
                              setSheet(() {});
                              setState(() {});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.018),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: sunnah.isCompleted
                                    ? LinearGradient(
                                  colors: _isDark
                                      ? [
                                    const Color(0xFF374151),
                                    const Color(0xFF1F2937),
                                  ]
                                      : [
                                    const Color(0xFFE5E7EB),
                                    const Color(0xFFD1D5DB),
                                  ],
                                )
                                    : const LinearGradient(
                                  colors: [_emerald, _emeraldDark],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (sunnah.isCompleted
                                        ? Colors.grey
                                        : _emerald)
                                        .withOpacity(0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    sunnah.isCompleted
                                        ? Icons.replay_rounded
                                        : Icons.check_circle_rounded,
                                    color: sunnah.isCompleted
                                        ? (_isDark
                                        ? _textSecondary
                                        : Colors.black54)
                                        : Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: size.width * 0.025),
                                  Text(
                                    sunnah.isCompleted
                                        ? 'إلغاء الإكمال'
                                        : '✨ علّم كمكتمل',
                                    style: TextStyle(
                                      color: sunnah.isCompleted
                                          ? (_isDark
                                          ? _textSecondary
                                          : Colors.black54)
                                          : Colors.white,
                                      fontSize: size.width * 0.042,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.006),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'إغلاق',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: size.width * 0.035,
                              ),
                            ),
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

  Widget _buildDetailCard({
    required String icon,
    required String title,
    required String content,
    required Color color,
    required Size size,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _isDark ? _darkBg : const Color(0xFFF9FAFB),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: TextStyle(fontSize: size.width * 0.04)),
              SizedBox(width: size.width * 0.02),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: size.width * 0.034,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.009),
          Text(
            content,
            style: TextStyle(
              color: _textSecondary,
              fontSize: size.width * 0.033,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      String value,
      String label,
      String icon,
      Color color,
      Size size,
      ) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _isDark ? _darkBg : const Color(0xFFF9FAFB),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: size.width * 0.055)),
          SizedBox(height: size.height * 0.006),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: size.width * 0.034,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              color: _textSecondary,
              fontSize: size.width * 0.028,
            ),
          ),
        ],
      ),
    );
  }
}