import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../languages/app_localizations.dart';
import '../../services/asma_allah_service.dart';
import 'asma_allah_all_names_scree.dart';
import 'asma_allah_detail_screen.dart';
import 'circle/asma_name_circle.dart';
import 'circle/asma_zoom_controls.dart';
import 'widgets/asma_theme.dart';
import 'widgets/asma_painters.dart';

class AsmaAllahScreen extends StatefulWidget {
  final Color primaryColor;
  const AsmaAllahScreen({super.key, required this.primaryColor});

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen>
    with TickerProviderStateMixin {
  List<Map<String, String>> _names = [];
  bool _isLoading = true;

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _rotateController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotateAnimation;

  final TransformationController _transformController =
  TransformationController();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
    _rotateAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _rotateController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadNames();
    }
  }

  Future<void> _loadNames() async {
    try {
      final String currentLang = context.tr.locale.languageCode; // جلب كود اللغة
      final data = await AsmaAllahService.getNamesSimple(currentLang); // تمريرها للـ Service
      if (mounted) {
        setState(() {
          _names = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = AsmaTheme(isDark: isDark);

    return Directionality(
      textDirection: context.tr.textDirection,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.bgGradient,
            ),
          ),
          child: Stack(
            children: [
              // الحلقة التفاعلية
              Positioned.fill(
                child: SafeArea(
                  child: _buildInteractiveCircle(context, isDark),
                ),
              ),

              // AppBar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: _buildCustomAppBar(context, isDark, theme),
                ),
              ),

              // شريط التلميح
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      SizedBox(
                          height:
                          MediaQuery.of(context).size.width < 360
                              ? 56
                              : 70),
                      _buildHintBar(isDark),
                    ],
                  ),
                ),
              ),

              // أزرار التحكم
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: AsmaZoomControls(
                      isDark: isDark,
                      transformController: _transformController,
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

  // ═══════════════════════════════════════════════════════════
  // AppBar
  // ═══════════════════════════════════════════════════════════
  Widget _buildCustomAppBar(
      BuildContext context, bool isDark, AsmaTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;
        final isMedium = constraints.maxWidth < 400;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 6 : 8,
            vertical: isSmall ? 6 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.circleAppBarGradient,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AsmaTheme.gold.withOpacity(0.15)
                    : AsmaTheme.gold.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Material(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AsmaTheme.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.all(isSmall ? 8 : 10),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : AsmaTheme.gold,
                      size: isSmall ? 18 : 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 6 : 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.tr.asmaAllahTitle, // 👈 تمت الترجمة
                        style: GoogleFonts.cairo(
                          color: isDark
                              ? Colors.white
                              : AsmaTheme.brownText,
                          fontSize: isSmall ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: isSmall ? 20 : 30,
                            height: 1.5,
                            color: AsmaTheme.gold
                                .withOpacity(isDark ? 0.5 : 0.6),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              context.tr.ninetyNineNames, // 👈 تمت الترجمة
                              style: GoogleFonts.cairo(
                                color: AsmaTheme.gold,
                                fontSize: isSmall ? 10 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: isSmall ? 20 : 30,
                            height: 1.5,
                            color: AsmaTheme.gold
                                .withOpacity(isDark ? 0.5 : 0.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmall ? 6 : 12),
              Material(
                color: isDark
                    ? AsmaTheme.gold.withOpacity(0.15)
                    : AsmaTheme.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AsmaAllahAllNamesScreen(
                        primaryColor: widget.primaryColor,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 8 : 14,
                      vertical: isSmall ? 8 : 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.grid_view_rounded,
                            color: AsmaTheme.gold,
                            size: isSmall ? 16 : 18),
                        if (!isMedium) ...[
                          const SizedBox(width: 6),
                          Text(
                            context.tr.showAllNames, // 👈 تمت الترجمة
                            style: GoogleFonts.cairo(
                              color: isDark
                                  ? Colors.white
                                  : AsmaTheme.brownText,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmall ? 12 : 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // شريط التلميح
  // ═══════════════════════════════════════════════════════════
  Widget _buildHintBar(bool isDark) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 360;
            final isVerySmall = constraints.maxWidth < 300;

            return Container(
              padding: EdgeInsets.symmetric(
                vertical: isSmall ? 6 : 8,
                horizontal: isSmall ? 10 : 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AsmaTheme.gold.withOpacity(
                        (isDark ? 0.05 : 0.08) * _glowAnimation.value),
                    Colors.transparent,
                  ],
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: AsmaTheme.gold
                          .withOpacity(0.5 + 0.5 * _glowAnimation.value),
                      size: isSmall ? 14 : 16,
                    ),
                    SizedBox(width: isSmall ? 4 : 8),
                    Text(
                      context.tr.tapToSeeMeaning, // 👈 تمت الترجمة
                      style: GoogleFonts.cairo(
                        color: isDark
                            ? AsmaTheme.gold.withOpacity(
                            0.6 + 0.4 * _glowAnimation.value)
                            : AsmaTheme.brownSub.withOpacity(
                            0.6 + 0.3 * _glowAnimation.value),
                        fontSize: isSmall ? 11 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isVerySmall) ...[
                      SizedBox(width: isSmall ? 8 : 16),
                      Container(
                        width: 1,
                        height: isSmall ? 12 : 14,
                        color: AsmaTheme.gold.withOpacity(0.3),
                      ),
                      SizedBox(width: isSmall ? 8 : 12),
                      Icon(Icons.pinch_rounded,
                          color: AsmaTheme.gold.withOpacity(0.5),
                          size: isSmall ? 12 : 14),
                      const SizedBox(width: 4),
                      Text(
                        context.tr.pinchToZoom, // 👈 تمت الترجمة
                        style: GoogleFonts.cairo(
                          color: isDark
                              ? AsmaTheme.gold.withOpacity(0.4)
                              : AsmaTheme.brownSub.withOpacity(0.4),
                          fontSize: isSmall ? 9 : 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // الحلقة الدائرية
  // ═══════════════════════════════════════════════════════════
  Widget _buildInteractiveCircle(BuildContext context, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;
        final double circleSize =
            min(availableWidth, availableHeight) * 0.95;

        final double centerX = circleSize / 2;
        final double centerY = circleSize / 2;
        final double maxRadius = circleSize * 0.46;

        final List<double> radii = [
          maxRadius,
          maxRadius * 0.78,
          maxRadius * 0.60,
          maxRadius * 0.45,
          maxRadius * 0.32,
          maxRadius * 0.18,
        ];

        final List<double> circleSizes = [
          circleSize * 0.082,
          circleSize * 0.076,
          circleSize * 0.070,
          circleSize * 0.064,
          circleSize * 0.058,
          circleSize * 0.052,
        ];

        final double centerSize = circleSize * 0.23;
        final allNames = _names.take(99).toList();

        final List<List<Map<String, String>>> rings = [
          allNames.sublist(0, min(24, allNames.length)),
          allNames.sublist(min(24, allNames.length), min(44, allNames.length)),
          allNames.sublist(min(44, allNames.length), min(62, allNames.length)),
          allNames.sublist(min(62, allNames.length), min(76, allNames.length)),
          allNames.sublist(min(76, allNames.length), min(88, allNames.length)),
          allNames.sublist(min(88, allNames.length), min(99, allNames.length)),
        ];

        final double patternSize = circleSize * 2;

        return InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: EdgeInsets.symmetric(
            horizontal: availableWidth * 0.5,
            vertical: availableHeight * 0.5,
          ),
          child: SizedBox(
            width: availableWidth,
            height: availableHeight,
            child: Center(
              child: SizedBox(
                width: circleSize,
                height: circleSize,
                child: AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (_, __) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // النقوش
                        Positioned(
                          left: -patternSize / 4,
                          top: -patternSize / 4,
                          child: SizedBox(
                            width: patternSize,
                            height: patternSize,
                            child: CustomPaint(
                              painter: AsmaIslamicPatternPainter(
                                color: AsmaTheme.gold.withOpacity(0.03),
                                sides: 6,
                              ),
                            ),
                          ),
                        ),

                        // دوائر التوهج
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (_, __) {
                            return CustomPaint(
                              size: Size(circleSize, circleSize),
                              painter: AsmaGlowRingsPainter(
                                center: Offset(centerX, centerY),
                                radii: radii,
                                gold: AsmaTheme.gold,
                                opacity:
                                0.04 + _glowAnimation.value * 0.06,
                              ),
                            );
                          },
                        ),

                        // الحلقات الست
                        for (int ringIndex = 0;
                        ringIndex < 6;
                        ringIndex++)
                          ..._buildNameRing(
                            context: context,
                            ringNames: rings[ringIndex],
                            radius: radii[ringIndex],
                            circleSize: circleSizes[ringIndex],
                            centerX: centerX,
                            centerY: centerY,
                            ringIndex: ringIndex,
                            isDark: isDark,
                          ),

                        // المركز
                        _buildCenterCircle(
                          centerX: centerX,
                          centerY: centerY,
                          size: centerSize,
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // بناء حلقة واحدة
  // ═══════════════════════════════════════════════════════════
  List<Widget> _buildNameRing({
    required BuildContext context,
    required List<Map<String, String>> ringNames,
    required double radius,
    required double circleSize,
    required double centerX,
    required double centerY,
    required int ringIndex,
    required bool isDark,
  }) {
    final List<Color> borderColors = [
      AsmaTheme.gold,
      AsmaTheme.goldDeep,
      const Color(0xFFCD853F),
      AsmaTheme.goldDark,
      AsmaTheme.gold,
      AsmaTheme.gold.withOpacity(0.8),
    ];
    final Color borderColor = borderColors[ringIndex % borderColors.length];

    return List.generate(ringNames.length, (index) {
      final double angle = (2 * pi * index / ringNames.length) - (pi / 2);
      final double x = centerX + radius * cos(angle) - (circleSize / 2);
      final double y = centerY + radius * sin(angle) - (circleSize / 2);

      final Map<String, String> item = ringNames[index];
      final int globalIndex = _names.indexOf(item) + 1;
      final String heroTag = 'asma_$globalIndex';

      return Positioned(
        left: x,
        top: y,
        child: AsmaNameCircleWidget(
          displayName: item['displayName'] ?? item['name']!,  // ✅ تغيير هنا
          meaning: item['meaning']!,
          size: circleSize,
          borderColor: borderColor,
          isDark: isDark,
          glowAnimation: _glowAnimation,
          heroTag: heroTag,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 450),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (_, animation, __) {
                  return AsmaAllahDetailScreen(
                    fullName: item['name']!,                            // ✅ الكامل للـ AppBar
                    displayName: item['displayName'] ?? item['name']!,  // ✅ القصير للدائرة
                    meaning: item['meaning']!,
                    primaryColor: widget.primaryColor,
                    order: globalIndex,
                    names: _names,
                    heroTag: heroTag,
                  );
                },
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // المركز
  // ═══════════════════════════════════════════════════════════
  Widget _buildCenterCircle({
    required double centerX,
    required double centerY,
    required double size,
    required bool isDark,
  }) {
    return Positioned(
      left: centerX - size / 2,
      top: centerY - size / 2,
      child: AnimatedBuilder(
        animation:
        Listenable.merge([_pulseAnimation, _glowAnimation]),
        builder: (_, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                    const Color(0xFF1E2A4A),
                    const Color(0xFF0F1628)
                  ]
                      : [Colors.white, const Color(0xFFFFF3D6)],
                ),
                border: Border.all(
                  color: AsmaTheme.gold,
                  width: size < 60 ? 2 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AsmaTheme.gold.withOpacity(
                      isDark
                          ? (0.2 + _glowAnimation.value * 0.4)
                          : (0.15 + _glowAnimation.value * 0.25),
                    ),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: AsmaTheme.gold
                        .withOpacity(isDark ? 0.1 : 0.08),
                    blurRadius: 50,
                    spreadRadius: 15,
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
                        color: AsmaTheme.gold
                            .withOpacity(isDark ? 0.3 : 0.25),
                        width: 1.5,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.15),
                      child: Text(
                        context.tr.allahWord, // 👈 تمت الترجمة
                        style: GoogleFonts.amiri(
                          fontSize: size * 0.35,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AsmaTheme.gold
                              : AsmaTheme.goldDark,
                          shadows: [
                            Shadow(
                              color: AsmaTheme.gold
                                  .withOpacity(isDark ? 0.5 : 0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
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
}