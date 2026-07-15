import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sunnah_service.dart';
import 'sunnah_theme.dart';

class SunnahHeader extends StatelessWidget {
  final Size size;
  final SunnahTheme theme;
  final SunnahService service;
  final AnimationController pulseController;
  final Animation<double> pulseAnim;
  final Animation<double> shimmerAnim;
  final VoidCallback onToggleTheme;

  const SunnahHeader({
    super.key,
    required this.size,
    required this.theme,
    required this.service,
    required this.pulseController,
    required this.pulseAnim,
    required this.shimmerAnim,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentSunnahs = service.getCurrentSunnahs();
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
          colors: theme.headerGradient,
        ),
        boxShadow: theme.headerShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -40,
            child: _buildOrbDecoration(
                size.width * 0.45, SunnahTheme.emerald.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: _buildOrbDecoration(
                size.width * 0.35, SunnahTheme.gold.withValues(alpha: 0.05)),
          ),
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
                  _buildTopRow(now, isSmall),
                  SizedBox(height: isSmall ? 12 : 18),
                  _buildStatsRow(completed, total, isSmall),
                  SizedBox(height: isSmall ? 12 : 16),
                  _buildProgressBar(progress, completed, total),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbDecoration(double orbSize, Color color) {
    return Container(
      width: orbSize,
      height: orbSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildTopRow(DateTime now, bool isSmall) {
    return Row(
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
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFD1FAE5)],
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
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: size.width * 0.032,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Column(
          children: [
            _buildClockWidget(now),
            SizedBox(height: isSmall ? 4 : 8),
            _buildThemeToggle(),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveBadge() {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SunnahTheme.emeraldLight,
              boxShadow: [
                BoxShadow(
                  color: SunnahTheme.emeraldLight
                      .withValues(alpha: pulseAnim.value - 0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            service.getCurrentPeriodLabel(),
            style: const TextStyle(
              color: SunnahTheme.emeraldLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockWidget(DateTime now) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, __) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.035,
          vertical: size.height * 0.008,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.1),
          border:
          Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color:
              SunnahTheme.emerald.withValues(alpha: 0.08 * pulseAnim.value),
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
              SunnahTheme.getDayName(now.weekday),
              style: TextStyle(
                color: SunnahTheme.emeraldLight.withValues(alpha: 0.85),
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
        onToggleTheme();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withValues(alpha: 0.1),
          border:
          Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Icon(
          theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: theme.isDark ? SunnahTheme.goldLight : Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildStatsRow(int completed, int total, bool isSmall) {
    final globalCompleted = service.completedToday;
    final globalTotal = service.totalSunnahs;

    return Row(
      children: [
        _buildStatCard(
          value: '$completed/$total',
          label: 'سنة الوقت',
          emoji: '⏰',
          color: SunnahTheme.emerald,
          isSmall: isSmall,
        ),
        SizedBox(width: size.width * 0.025),
        _buildStatCard(
          value: '$globalCompleted/$globalTotal',
          label: 'إجمالي اليوم',
          emoji: '📿',
          color: SunnahTheme.goldLight,
          isSmall: isSmall,
        ),
        SizedBox(width: size.width * 0.025),
        _buildStatCard(
          value: '${globalTotal - globalCompleted}',
          label: 'متبقي',
          emoji: '🎯',
          color: SunnahTheme.blueLight,
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
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
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
                color: Colors.white.withValues(alpha: 0.6),
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

  Widget _buildProgressBar(double progress, int completed, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم الوقت الحالي',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: size.width * 0.03,
              ),
            ),
            AnimatedBuilder(
              animation: shimmerAnim,
              builder: (_, __) => ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  begin: Alignment(shimmerAnim.value - 1, 0),
                  end: Alignment(shimmerAnim.value, 0),
                  colors: const [
                    SunnahTheme.goldLight,
                    Colors.white,
                    SunnahTheme.goldLight,
                  ],
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
              height: SunnahTheme.progressHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              widthFactor: progress,
              alignment: Alignment.centerRight,
              child: Container(
                height: SunnahTheme.progressHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: SunnahTheme.emeraldLightGradient,
                  boxShadow: [
                    BoxShadow(
                      color: SunnahTheme.emerald.withValues(alpha: 0.6),
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
                  colors: [SunnahTheme.goldLight, SunnahTheme.gold],
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
}