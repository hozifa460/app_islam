// lib/screens/radio/widgets/radio_tab_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// شريط التبويبات (راديو / تلاوات)
/// ══════════════════════════════════════════════════════════════
class RadioTabBarWidget extends StatelessWidget {
  final TabController tabController;
  final Color primary;
  final bool isTablet;

  const RadioTabBarWidget({
    super.key,
    required this.tabController,
    required this.primary,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = RadioSizes.tabFontSize(isTablet);

    return Container(
      height: RadioSizes.tabBarHeight(isTablet),
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20.0 : 14.0,
        vertical: 8,
      ),
      decoration: RadioShapes.tabBarContainerDecoration(context),
      padding: const EdgeInsets.all(3),
      child: TabBar(
        controller: tabController,
        indicator: RadioShapes.tabBarIndicatorDecoration(primary),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: RadioColors.tabUnselectedColor(context),
        labelStyle: GoogleFonts.cairo(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          _buildTab('📻', 'الراديو'),
          _buildTab('🎵', 'تلاوات'),
          _buildTab('🎬', 'مرئيات'),
        ],
      ),
    );
  }

  Widget _buildTab(String emoji, String label) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}