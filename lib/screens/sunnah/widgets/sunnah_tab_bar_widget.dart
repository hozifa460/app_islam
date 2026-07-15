import 'package:flutter/material.dart';
import '../services/sunnah_service.dart';
import 'sunnah_theme.dart';

class SunnahTabBarWidget extends StatelessWidget {
  final Size size;
  final SunnahTheme theme;
  final SunnahService service;
  final TabController tabController;

  const SunnahTabBarWidget({
    super.key,
    required this.size,
    required this.theme,
    required this.service,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        size.width * 0.04, size.height * 0.012, size.width * 0.04, 0,
      ),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(SunnahTheme.tabBarRadius),
        border: Border.all(color: theme.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: SunnahTheme.emeraldGradient,
          boxShadow: [
            BoxShadow(
              color: SunnahTheme.emerald.withValues(alpha: 0.35),
              blurRadius: 8,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: theme.textSecondary,
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
                  child:
                  Text('سنن الآن', overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 4),
                _buildTabBadge(
                  '${service.getCurrentSunnahs().length}',
                  SunnahTheme.emerald,
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
                  child: Text('جميع السنن',
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 4),
                _buildTabBadge(
                  '${service.totalSunnahs}',
                  SunnahTheme.purple,
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SunnahTheme.badgeRadius),
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
}