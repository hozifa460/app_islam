import 'package:flutter/material.dart';
import 'package:islamic_app/screens/sunnah/widgets/sunnah_empty_state.dart';
import '../model/sunnah_model.dart';
import '../services/sunnah_service.dart';
import 'sunnah_theme.dart';
import 'sunnah_card.dart';

class SunnahCurrentTab extends StatelessWidget {
  final Size size;
  final SunnahTheme theme;
  final SunnahService service;
  final AnimationController pulseController;
  final Animation<double> pulseAnim;
  final AnimationController floatingController;
  final Animation<double> floatingAnim;
  final TabController tabController;
  final Future<void> Function() onRefresh;
  final Function(SunnahModel) onShowDetails;
  final Function(int) onToggle;

  const SunnahCurrentTab({
    super.key,
    required this.size,
    required this.theme,
    required this.service,
    required this.pulseController,
    required this.pulseAnim,
    required this.floatingController,
    required this.floatingAnim,
    required this.tabController,
    required this.onRefresh,
    required this.onShowDetails,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final sunnahs = service.getCurrentSunnahs();
    if (sunnahs.isEmpty) {
      return SunnahEmptyState(
        size: size,
        theme: theme,
        floatingController: floatingController,
        floatingAnim: floatingAnim,
        tabController: tabController,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: SunnahTheme.emerald,
      backgroundColor: theme.card,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          size.width * 0.04,
          size.height * 0.015,
          size.width * 0.04,
          size.height * 0.04,
        ),
        children: [
          _buildCurrentBanner(sunnahs),
          SizedBox(height: size.height * 0.015),
          ...sunnahs.asMap().entries.map(
                (e) => SunnahCard(
              sunnah: e.value,
              index: e.key,
              size: size,
              theme: theme,
              service: service,
              onToggle: () => onToggle(e.value.id),
              onTap: () => onShowDetails(e.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBanner(List<SunnahModel> sunnahs) {
    final remaining = sunnahs.where((s) => !s.isCompleted).length;

    return AnimatedBuilder(
      animation: floatingController,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, floatingAnim.value * 0.2),
        child: child,
      ),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: theme.isDark
                ? [
              SunnahTheme.emerald.withOpacity(0.15),
              SunnahTheme.blue.withOpacity(0.08),
            ]
                : [
              SunnahTheme.emerald.withOpacity(0.1),
              SunnahTheme.emerald.withOpacity(0.04),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(
            color: SunnahTheme.emerald.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: SunnahTheme.emerald
                  .withOpacity(theme.isDark ? 0.08 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, __) => Container(
                width: size.width * 0.12,
                height: size.width * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SunnahTheme.emeraldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: SunnahTheme.emerald
                          .withOpacity(0.3 * pulseAnim.value),
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
                    service.getCurrentPeriodLabel(),
                    style: TextStyle(
                      color: theme.textPrimary,
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
                      color: theme.textSecondary,
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
                gradient: SunnahTheme.emeraldGradient,
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
}