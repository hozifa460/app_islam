import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../languages/app_localizations.dart';
import '../data/hijri_data.dart';
import 'hijri_theme.dart';

class HijriInfoRow extends StatelessWidget {
  final HijriCalendar hijri;
  final HijriTheme theme;
  final bool compact;
  final bool tablet;

  const HijriInfoRow({
    super.key,
    required this.hijri,
    required this.theme,
    required this.compact,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': context.tr.dayLabel, 'value': HijriTheme.formatNum(hijri.hDay, context), 'icon': Icons.today_rounded},
      {'title': context.tr.monthLabel, 'value': HijriData.hijriMonths[hijri.hMonth - 1], 'icon': Icons.calendar_month_rounded},
      {'title': context.tr.yearLabel, 'value': HijriTheme.formatNum(hijri.hYear, context), 'icon': Icons.date_range_rounded},
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 5),
            padding: EdgeInsets.symmetric(
              vertical: compact ? 12 : tablet ? 20 : 16,
              horizontal: 6,
            ),
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(HijriTheme.infoCardRadius),
              border: Border.all(color: theme.cardBorder),
              boxShadow: theme.cardShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: compact ? 32 : 38,
                  height: compact ? 32 : 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      theme.primaryColor.withOpacity(0.12),
                      theme.primaryColor.withOpacity(0.04),
                    ]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: theme.primaryColor,
                    size: compact ? 15 : 17,
                  ),
                ),
                SizedBox(height: compact ? 6 : 10),
                Text(
                  item['title'] as String,
                  style: theme.infoTitleStyle(compact),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item['value'] as String,
                    style: theme.infoValueStyle(compact),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}