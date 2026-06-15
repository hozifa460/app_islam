import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';

class PrayerBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color? border;

  const PrayerBadge({
    super.key,
    required this.text,
    required this.bg,
    required this.fg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MuezzinTypeBadge extends StatelessWidget {
  final bool isDefault;
  final Color gold;

  const MuezzinTypeBadge({
    super.key,
    required this.isDefault,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    if (isDefault) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.25)),
        ),
        child: Text(
          context.tr.defaultMuezzinBadge,
          style: GoogleFonts.cairo(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: gold.withOpacity(0.30)),
      ),
      child: Text(
        context.tr.customMuezzinBadge,
        style: GoogleFonts.cairo(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: gold,
        ),
      ),
    );
  }
}

class StatusMiniBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;

  const StatusMiniBadge({
    super.key,
    required this.label,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? color.withOpacity(0.12)
            : Colors.grey.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? color.withOpacity(0.30)
              : Colors.grey.withOpacity(0.20),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: active ? color : Colors.grey,
        ),
      ),
    );
  }
}