import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../data/hijri_data.dart';
import 'hijri_theme.dart';
import 'hijri_painters.dart';

class HijriHeroHeader extends StatelessWidget {
  final HijriCalendar hijri;
  final DateTime selectedDate;
  final Color primaryColor;
  final bool compact;
  final bool tablet;
  final AnimationController pulseController;
  final AnimationController starController;
  final Map<String, String>? event;
  final Map<String, dynamic>? nextEvent;

  const HijriHeroHeader({
    super.key,
    required this.hijri,
    required this.selectedDate,
    required this.primaryColor,
    required this.compact,
    required this.tablet,
    required this.pulseController,
    required this.starController,
    required this.event,
    required this.nextEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            Color.lerp(primaryColor, const Color(0xFF0A0E17), 0.3)!,
            Color.lerp(primaryColor, const Color(0xFF0A0E17), 0.5)!,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          // ط§ظ„ظ†ظ‚ط´ ط§ظ„ط¥ط³ظ„ط§ظ…ظٹ
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: Colors.white.withValues(alpha: 0.03),
                lineWidth: 0.5,
              ),
            ),
          ),

          // ط§ظ„ط¯ظˆط§ط¦ط± ط§ظ„ط²ط®ط±ظپظٹط©
          _buildDecorativeCircles(),

          // ط§ظ„ظ‡ظ„ط§ظ„
          Positioned(
            top: compact ? 50 : 60,
            left: compact ? 20 : tablet ? 40 : 28,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (_, child) => Transform.rotate(
                angle: pulseController.value * 0.06,
                child: child,
              ),
              child: _buildEnhancedCrescent(),
            ),
          ),

          // ط§ظ„ظ†ط¬ظˆظ… ط§ظ„ظ…طھظ„ط£ظ„ط¦ط©
          ..._buildStars(),

          // ط§ظ„ط²ط®ط±ظپط© ط§ظ„ظ‡ظ†ط¯ط³ظٹط©
          Positioned(
            top: compact ? 55 : 65,
            right: compact ? 15 : 25,
            child: _buildGeometricDecoration(),
          ),

          // ط§ظ„ظ…ط­طھظˆظ‰ ط§ظ„ط±ط¦ظٹط³ظٹ
          Positioned(
            left: 16,
            right: 16,
            bottom: compact ? 20 : 28,
            child: SafeArea(
              top: false,
              child: _buildMainContent(context),
            ),
          ),

          // ط§ظ„طھط¯ط±ط¬ ط§ظ„ط³ظپظ„ظٹ
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color.lerp(
                        primaryColor, const Color(0xFF0A0E17), 0.5)!
                        .withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط¯ظˆط§ط¦ط± ط§ظ„ط²ط®ط±ظپظٹط© ط§ظ„ظ…طھظˆظ‡ط¬ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        // ط¯ط§ط¦ط±ط© ظƒط¨ظٹط±ط© ط£ط¹ظ„ظ‰ ط§ظ„ظٹظ…ظٹظ†
        Positioned(
          top: -80,
          right: -60,
          child: AnimatedBuilder(
            animation: pulseController,
            builder: (_, __) => Transform.scale(
              scale: 1 + (pulseController.value * 0.1),
              child: Container(
                width: compact ? 180 : 220,
                height: compact ? 180 : 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      HijriTheme.gold.withValues(alpha: 0.12),
                      HijriTheme.gold.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ط¯ط§ط¦ط±ط© ظ…طھظˆط³ط·ط© ط£ط³ظپظ„ ط§ظ„ظٹط³ط§ط±
        Positioned(
          bottom: -50,
          left: -40,
          child: AnimatedBuilder(
            animation: pulseController,
            builder: (_, __) => Transform.scale(
              scale: 1 + (pulseController.value * 0.08),
              child: Container(
                width: compact ? 140 : 170,
                height: compact ? 140 : 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ط¯ط§ط¦ط±ط© طµط؛ظٹط±ط© ظپظٹ ط§ظ„ظˆط³ط·
        Positioned(
          top: compact ? 100 : 120,
          right: compact ? 80 : 100,
          child: AnimatedBuilder(
            animation: starController,
            builder: (_, __) => Opacity(
              opacity: 0.3 + (starController.value * 0.4),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      HijriTheme.gold.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظ‡ظ„ط§ظ„ ط§ظ„ظ…ط­ط³ظ‘ظ†
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildEnhancedCrescent() {
    final s = compact ? 55.0 : tablet ? 75.0 : 65.0;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        children: [
          // طھظˆظ‡ط¬ ط®ط§ط±ط¬ظٹ
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: HijriTheme.gold.withValues(alpha: 0.3),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // ط§ظ„ظ‡ظ„ط§ظ„ ط§ظ„ط±ط¦ظٹط³ظٹ
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  HijriTheme.gold.withValues(alpha: 0.5),
                  HijriTheme.gold.withValues(alpha: 0.25),
                  HijriTheme.gold.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: HijriTheme.gold.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          // ط§ظ„ظ‚ط·ط¹ ط§ظ„ط¯ط§ط®ظ„ظٹ ظ„ظ„ظ‡ظ„ط§ظ„
          Positioned(
            left: s * 0.22,
            top: s * 0.05,
            child: Container(
              width: s * 0.82,
              height: s * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                    primaryColor, const Color(0xFF0A0E17), 0.35),
              ),
            ),
          ),
          // ظ†ط¬ظ…ط© طµط؛ظٹط±ط© ط¨ط¬ط§ظ†ط¨ ط§ظ„ظ‡ظ„ط§ظ„
          Positioned(
            right: s * 0.05,
            bottom: s * 0.25,
            child: AnimatedBuilder(
              animation: starController,
              builder: (_, __) => Opacity(
                opacity: 0.5 + (starController.value * 0.5),
                child: CustomPaint(
                  size: Size(s * 0.12, s * 0.12),
                  painter: StarPainter(color: HijriTheme.gold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظ†ط¬ظˆظ… ط§ظ„ظ…طھظ„ط£ظ„ط¦ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  List<Widget> _buildStars() {
    final starData = [
      {'top': 70.0, 'right': 50.0, 'size': 3.0, 'delay': 0.0},
      {'top': 90.0, 'right': 90.0, 'size': 2.5, 'delay': 0.3},
      {'top': 60.0, 'right': 130.0, 'size': 2.0, 'delay': 0.6},
      {'top': 110.0, 'left': 80.0, 'size': 2.5, 'delay': 0.2},
      {'top': 80.0, 'left': 120.0, 'size': 2.0, 'delay': 0.5},
      {'top': 130.0, 'right': 70.0, 'size': 1.8, 'delay': 0.4},
    ];

    return starData.map((data) {
      return Positioned(
        top: data['top'] as double,
        right: data.containsKey('right')
            ? data['right'] as double
            : null,
        left:
        data.containsKey('left') ? data['left'] as double : null,
        child: AnimatedBuilder(
          animation: starController,
          builder: (_, __) {
            final delay = data['delay'] as double;
            final animValue =
            ((starController.value + delay) % 1.0);
            return Opacity(
              opacity: (0.3 + (animValue * 0.7)).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.8 + (animValue * 0.4),
                child: Container(
                  width: (data['size'] as double) * 2,
                  height: (data['size'] as double) * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: HijriTheme.gold.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط²ط®ط±ظپط© ط§ظ„ظ‡ظ†ط¯ط³ظٹط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildGeometricDecoration() {
    final size = compact ? 35.0 : 45.0;
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, __) => Transform.rotate(
        angle: pulseController.value * 0.1,
        child: Opacity(
          opacity: 0.15 + (pulseController.value * 0.1),
          child: CustomPaint(
            size: Size(size, size),
            painter:
            GeometricDecorationPainter(color: HijriTheme.gold),
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظ…ط­طھظˆظ‰ ط§ظ„ط±ط¦ظٹط³ظٹ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildMainContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ط§ظ„ظ…ظ†ط§ط³ط¨ط© ط§ظ„ظ‚ط§ط¯ظ…ط©
        if (nextEvent != null) ...[
          _buildNextEventBadge(context),
          SizedBox(height: compact ? 8 : 10),
        ],

        // ط§ط³ظ… ط§ظ„ظٹظˆظ…
        _buildDayNameBadge(context),
        SizedBox(height: compact ? 12 : 16),

        // ط§ظ„طھط§ط±ظٹط® ط§ظ„ظ‡ط¬ط±ظٹ
        _buildHijriDate(context),
        const SizedBox(height: 6),

        // ط§ظ„طھط§ط±ظٹط® ط§ظ„ظ…ظٹظ„ط§ط¯ظٹ
        _buildGregorianDate(),

        // ظˆط³ظ… ط§ظ„ظ…ظ†ط§ط³ط¨ط©
        if (event != null) ...[
          SizedBox(height: compact ? 10 : 14),
          _buildEventBadge(),
        ],
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط§ط±ط© ط§ظ„ظ…ظ†ط§ط³ط¨ط© ط§ظ„ظ‚ط§ط¯ظ…ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildNextEventBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HijriTheme.gold.withValues(alpha: 0.2),
            HijriTheme.gold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HijriTheme.gold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_rounded,
            color: HijriTheme.gold,
            size: compact ? 12 : 14,
          ),
          SizedBox(width: compact ? 4 : 6),
          Flexible(
            child: Text(
              'ط§ظ„ظ‚ط§ط¯ظ…: ${nextEvent!['title']}',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: compact ? 9 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: HijriTheme.gold.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'ط¨ط¹ط¯ ${HijriTheme.formatNum(nextEvent!['daysLeft'] , context )} ظٹظˆظ…',
              style: GoogleFonts.cairo(
                color: HijriTheme.gold,
                fontSize: compact ? 8 : 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط§ط±ط© ط§ط³ظ… ط§ظ„ظٹظˆظ…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildDayNameBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            color: HijriTheme.gold.withValues(alpha: 0.8),
            size: compact ? 12 : 14,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            HijriTheme.getWeekday(selectedDate , context),
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„طھط§ط±ظٹط® ط§ظ„ظ‡ط¬ط±ظٹ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildHijriDate(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: FittedBox(
        key: ValueKey(
            '${hijri.hDay}-${hijri.hMonth}-${hijri.hYear}'),
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSideDecoration(isLeft: true),
            SizedBox(width: compact ? 8 : 12),
            Text(
              '${HijriTheme.formatNum(hijri.hDay , context )}'
                  ' ${HijriData.hijriMonths[hijri.hMonth - 1]}'
                  ' ${HijriTheme.formatNum(hijri.hYear , context )}',
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: compact ? 26 : tablet ? 38 : 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 8 : 12),
            _buildSideDecoration(isLeft: false),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„طھط§ط±ظٹط® ط§ظ„ظ…ظٹظ„ط§ط¯ظٹ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildGregorianDate() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Row(
        key: ValueKey(selectedDate.toString()),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: compact ? 20 : 25,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  HijriTheme.gold.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 12),
            child: Text(
              DateFormat('dd MMMM yyyy', 'ar').format(selectedDate),
              style: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: compact ? 11 : 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            width: compact ? 20 : 25,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  HijriTheme.gold.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظˆط³ظ… ط§ظ„ظ…ظ†ط§ط³ط¨ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildEventBadge() {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, child) => Transform.scale(
        scale: 1 + (pulseController.value * 0.03),
        child: child,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HijriTheme.gold.withValues(alpha: 0.25),
              HijriTheme.gold.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border:
          Border.all(color: HijriTheme.gold.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: HijriTheme.gold.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: HijriTheme.gold,
                size: compact ? 12 : 14),
            SizedBox(width: compact ? 4 : 6),
            Flexible(
              child: Text(
                event!['title']!,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: HijriTheme.gold,
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط²ط®ط§ط±ظپ ط§ظ„ط¬ط§ظ†ط¨ظٹط© ظ„ظ„طھط§ط±ظٹط®
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildSideDecoration({required bool isLeft}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLeft) ...[
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HijriTheme.gold.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Container(
          width: compact ? 15 : 20,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: LinearGradient(
              colors: isLeft
                  ? [
                Colors.transparent,
                HijriTheme.gold.withValues(alpha: 0.5)
              ]
                  : [
                HijriTheme.gold.withValues(alpha: 0.5),
                Colors.transparent
              ],
            ),
          ),
        ),
        if (isLeft) ...[
          const SizedBox(width: 4),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HijriTheme.gold.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}