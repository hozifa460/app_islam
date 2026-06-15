import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';

import '../../../../languages/app_localizations.dart';
import 'prayer_models.dart';
import 'prayer_badges.dart';

class PrayerRowCard extends StatelessWidget {
  final PrayerRow row;
  final String muezzinName;
  final bool isDefaultMuezzin;
  final PrayerCustomization config;
  final bool isDark;
  final Color gold;
  final VoidCallback onTap;

  const PrayerRowCard({
    super.key,
    required this.row,
    required this.muezzinName,
    required this.isDefaultMuezzin,
    required this.config,
    required this.isDark,
    required this.gold,
    required this.onTap,
  });

  Color _getPrayerCardAccentColor() {
    if (!isDefaultMuezzin) {
      return gold.withOpacity(isDark ? 0.16 : 0.9);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final listCardGradient = isDark
        ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final listCardBorder =
    isDark ? Colors.white.withOpacity(0.1) : gold.withOpacity(0.2);

    final isCurrent = row.isCurrent;
    final isNext = row.isNext;
    final isPast = row.isPast;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCurrent
                ? [gold.withOpacity(0.15), gold.withOpacity(0.05)]
                : isNext
                ? [gold.withOpacity(0.10), gold.withOpacity(0.03)]
                : listCardGradient,
          ),
          color: _getPrayerCardAccentColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent
                ? gold.withOpacity(0.9)
                : !isDefaultMuezzin
                ? gold.withOpacity(0.45)
                : isNext
                ? gold.withOpacity(0.55)
                : listCardBorder,
            width: isCurrent ? 2.0 : (!isDefaultMuezzin ? 1.4 : 1.0),
          ),
          boxShadow: isNext
              ? [
            BoxShadow(
              color: gold.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ]
              : [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(isPast, isCurrent, isNext, subTextColor),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNameColumn(
                    isPast, isCurrent, isNext, textColor, subTextColor,context,
                  ),
                ),
                const SizedBox(width: 8),
                _buildTimeColumn(isPast, isCurrent, isNext, textColor, subTextColor,context,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCustomizeRow(context,isDark, subTextColor),
            if (row.noAdhan != true) ...[
              const SizedBox(height: 10),
              _buildStatusBadges(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isPast, bool isCurrent, bool isNext, Color subTextColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isPast
            ? Colors.grey.withOpacity(0.2)
            : gold.withOpacity(isCurrent || isNext ? 0.25 : 0.10),
        borderRadius: BorderRadius.circular(15),
        border: (isCurrent || isNext)
            ? Border.all(color: gold.withOpacity(0.8), width: 1.5)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            row.icon,
            color: isPast
                ? Colors.grey
                : (isCurrent || isNext ? gold : subTextColor),
            size: 24,
          ),
          if (isNext)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameColumn(
      bool isPast, bool isCurrent, bool isNext,
      Color textColor,
      Color subTextColor,
      BuildContext context
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              row.name,
              style: GoogleFonts.amiri(
                fontSize: 22,
                color: isPast ? subTextColor.withOpacity(0.5) : textColor,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isCurrent)
              PrayerBadge(text: context.tr.prayerNow, bg: gold, fg: Colors.black),
            if (isNext && !isCurrent)
              PrayerBadge(
                text: context.tr.prayerNext,
                bg: gold.withOpacity(0.2),
                fg: gold,
                border: gold.withOpacity(0.5),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          row.noAdhan == true ? context.tr.thisPrayerHasNoAdhan : context.tr.tapToCustomizePrayer,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            color: row.noAdhan == true
                ? Colors.orange
                : subTextColor.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(
      bool isPast,
      bool isCurrent,
      bool isNext,
      Color textColor,
      Color subTextColor,
      BuildContext context
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            row.time,
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: isPast
                  ? subTextColor.withOpacity(0.4)
                  : (isCurrent || isNext ? gold : textColor),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (row.noAdhan == true)
          Text(
            context.tr.noAdhan,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: subTextColor.withOpacity(0.5),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomizeRow(BuildContext context,bool isDark, Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 18,
            color: row.noAdhan == true ? Colors.grey : gold,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              row.noAdhan == true
                  ? context.tr.cannotCustomizeSunrise
                  : context.tr.currentMuezzinLabel(muezzinName),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: row.noAdhan == true
                    ? subTextColor.withOpacity(0.6)
                    : gold.withOpacity(0.95),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (row.noAdhan != true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                context.tr.customize,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadges(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        MuezzinTypeBadge(isDefault: isDefaultMuezzin, gold: gold),
        StatusMiniBadge(
          label: context.tr.adhanLabel,
          color: config.adhanEnabled ? Colors.green : Colors.red,
          active: config.adhanEnabled,
        ),
        StatusMiniBadge(
          label: config.reminderEnabled ?
          context.tr.reminderWithMins(config.reminderOffset) :
          context.tr.reminderLabel,
          color: config.reminderEnabled ? Colors.blue : Colors.grey,
          active: config.reminderEnabled,
        ),
        StatusMiniBadge(
          label: config.iqamaEnabled ?
          context.tr.iqamaWithMins(config.iqamaDelay) :
          context.tr.iqamaLabel,
          color: config.iqamaEnabled ? Colors.purple : Colors.grey,
          active: config.iqamaEnabled,
        ),
      ],
    );
  }
}