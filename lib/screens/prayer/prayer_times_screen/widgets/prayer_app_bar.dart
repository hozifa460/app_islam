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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        cityName.isNotEmpty ? cityName : context.tr.prayerTimes,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: textColor,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.my_location, color: gold),
          tooltip: context.tr.updateLocationTooltip,
          onPressed: onRefreshLocation,
        ),
        IconButton(
          icon: Icon(
            adhanEnabled
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: adhanEnabled
                ? gold
                : (isDark ? Colors.white54 : Colors.black45),
          ),
          onPressed: onAdhanSettings,
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.settings_voice, color: gold),
            onPressed: onMuezzinSettings,
          ),
        ),
      ],
    );
  }
}