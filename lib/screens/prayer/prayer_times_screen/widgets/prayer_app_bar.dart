import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';

class PrayerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String cityName;
  final bool adhanEnabled;
  final bool isDark;
  final Color gold;
  final VoidCallback onRefreshLocation;
  final VoidCallback onAdhanSettings;
  final VoidCallback onMuezzinSettings;
  final VoidCallback onBack;

  const PrayerAppBar({
    super.key,
    required this.cityName,
    required this.adhanEnabled,
    required this.isDark,
    required this.gold,
    required this.onRefreshLocation,
    required this.onAdhanSettings,
    required this.onMuezzinSettings,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFFE6C97B);

    return AppBar(
      toolbarHeight: 76,
      backgroundColor: const Color(0xFF10233F),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        cityName.isNotEmpty ? cityName : context.tr.prayerTimes,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w900,
          fontSize: 24,
          letterSpacing: 0.4,
          color: textColor,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.gps_fixed_rounded, color: gold),
          tooltip: context.tr.updateLocationTooltip,
          onPressed: onRefreshLocation,
        ),
        IconButton(
          icon: Icon(
            adhanEnabled ? Icons.notifications_active : Icons.notifications_off,
            color:
                adhanEnabled
                    ? gold
                    : (isDark ? Colors.white54 : Colors.black45),
          ),
          onPressed: onAdhanSettings,
        ),
        IconButton(
          icon: Icon(Icons.mic_none_rounded, color: gold),
          onPressed: onMuezzinSettings,
        ),
      ],
    );
  }
}
