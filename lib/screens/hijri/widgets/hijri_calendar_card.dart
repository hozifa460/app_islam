import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../languages/app_localizations.dart';
import '../data/hijri_data.dart';
import 'hijri_theme.dart';
import 'hijri_shared_widgets.dart';

class HijriCalendarCard extends StatelessWidget {
  final List<DateTime> days;
  final DateTime today;
  final DateTime selectedDate;
  final DateTime displayedMonth;
  final HijriTheme theme;
  final bool compact;
  final bool tablet;
  final Animation<Offset> slideAnimation;
  final bool Function(DateTime) hasEvent;
  final bool Function(DateTime, DateTime) isSame;
  final void Function(DateTime) onDayTap;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onGoToToday;

  const HijriCalendarCard({
    super.key,
    required this.days,
    required this.today,
    required this.selectedDate,
    required this.displayedMonth,
    required this.theme,
    required this.compact,
    required this.tablet,
    required this.slideAnimation,
    required this.hasEvent,
    required this.isSame,
    required this.onDayTap,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onGoToToday,
  });

  @override
  Widget build(BuildContext context) {
    final hijriMonth = HijriCalendar.fromDate(displayedMonth);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : tablet ? 22 : 16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(HijriTheme.cardRadius),
        border: Border.all(color: theme.cardBorder),
        boxShadow: theme.calendarShadow,
      ),
      child: Column(
        children: [
          _buildMonthNavigator(context,hijriMonth),
          SizedBox(height: compact ? 12 : 16),
          _buildWeekDaysHeader(),
          SizedBox(height: compact ? 6 : 10),
          _buildDaysGrid(),
          SizedBox(height: compact ? 10 : 14),
          if (!isSame(selectedDate, today)) _buildGoToTodayButton(context),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط±ظٹط· ط§ظ„طھظ†ظ‚ظ„ ط¨ظٹظ† ط§ظ„ط£ط´ظ‡ط±
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildMonthNavigator(BuildContext context,HijriCalendar hijriMonth) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 8 : 12,
        horizontal: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          theme.primaryColor.withValues(alpha: 0.06),
          theme.primaryColor.withValues(alpha: 0.02),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          HijriMonthArrow(
            icon: Icons.chevron_left_rounded,
            color: theme.primaryColor,
            onTap: onPrevMonth,
          ),
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${HijriData.arabicMonths[displayedMonth.month - 1]}'
                        ' ${HijriTheme.formatNum(displayedMonth.year, context)}', // ًں‘ˆ ط§ط³طھط®ط¯ظ…ظ†ط§ formatNum
                    style: GoogleFonts.cairo(
                      fontSize: compact ? 14 : 17,
                      fontWeight: FontWeight.bold,
                      color: theme.text,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${HijriData.hijriMonths[hijriMonth.hMonth - 1]} ${HijriTheme.formatNum(hijriMonth.hYear, context)}', // ًں‘ˆ ط§ط³طھط®ط¯ظ…ظ†ط§ formatNum
                    style: GoogleFonts.cairo(
                      fontSize: compact ? 10 : 12,
                      color: theme.subText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          HijriMonthArrow(
            icon: Icons.chevron_right_rounded,
            color: theme.primaryColor,
            onTap: onNextMonth,
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط±ط£ط³ ط£ظٹط§ظ… ط§ظ„ط£ط³ط¨ظˆط¹
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildWeekDaysHeader() {
    return Row(
      children: HijriData.weekDays.map((d) {
        final isFri = d == 'ط¬';
        return Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                d,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  color: isFri
                      ? HijriTheme.gold
                      : theme.primaryColor.withValues(alpha: 0.6),
                  fontSize: compact ? 10 : 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط¨ظƒط© ط§ظ„ط£ظٹط§ظ…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildDaysGrid() {
    return SlideTransition(
      position: slideAnimation,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: days.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: compact ? 3 : 5,
          mainAxisSpacing: compact ? 3 : 5,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) {
          final day = days[i];
          return _DayCell(
            day: day,
            displayedMonth: displayedMonth,
            today: today,
            selectedDate: selectedDate,
            theme: theme,
            compact: compact,
            hasEvent: hasEvent(day),
            isCurrent: day.month == displayedMonth.month,
            isToday: isSame(day, today),
            isSelected: isSame(day, selectedDate),
            isFriday: day.weekday == DateTime.friday,
            onTap: () => onDayTap(day),
          );
        },
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط²ط± ط§ظ„ط¹ظˆط¯ط© ظ„ظ„ظٹظˆظ…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildGoToTodayButton(BuildContext context) {
    return GestureDetector(
      onTap: onGoToToday,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            theme.primaryColor.withValues(alpha: 0.1),
            theme.primaryColor.withValues(alpha: 0.04),
          ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr.backToToday, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
              style: GoogleFonts.cairo(
                color: theme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.today_rounded,
                color: theme.primaryColor, size: 16),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط®ظ„ظٹط© ط§ظ„ظٹظˆظ… ط§ظ„ظˆط§ط­ط¯
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _DayCell extends StatelessWidget {
  final DateTime day;
  final DateTime displayedMonth;
  final DateTime today;
  final DateTime selectedDate;
  final HijriTheme theme;
  final bool compact;
  final bool hasEvent;
  final bool isCurrent;
  final bool isToday;
  final bool isSelected;
  final bool isFriday;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.displayedMonth,
    required this.today,
    required this.selectedDate,
    required this.theme,
    required this.compact,
    required this.hasEvent,
    required this.isCurrent,
    required this.isToday,
    required this.isSelected,
    required this.isFriday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
            theme.primaryColor,
            Color.lerp(
                theme.primaryColor, Colors.black, 0.25)!,
          ])
              : null,
          color: !isSelected
              ? (isToday
              ? HijriTheme.gold.withValues(alpha: 0.1)
              : hasEvent
              ? theme.primaryColor.withValues(alpha: 0.04)
              : null)
              : null,
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
          border: isToday && !isSelected
              ? Border.all(
              color: HijriTheme.gold.withValues(alpha: 0.5),
              width: 1.5)
              : hasEvent && !isSelected
              ? Border.all(
              color: theme.primaryColor.withValues(alpha: 0.15))
              : null,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ط±ظ‚ظ… ط§ظ„ظٹظˆظ…
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  HijriTheme.formatNum(day.day, context), // ًں‘ˆ ط§ط³طھط®ط¯ظ…ظ†ط§ formatNum
                  style: GoogleFonts.cairo(
                    fontSize: compact ? 11 : 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
              ),
            ),

            // ظ†ظ‚ط·ط© ط§ظ„ظ…ظ†ط§ط³ط¨ط©
            if (hasEvent)
              Positioned(
                top: compact ? 2 : 3,
                left: compact ? 2 : 3,
                child: Container(
                  width: compact ? 6 : 8,
                  height: compact ? 6 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        isSelected
                            ? Colors.white
                            : HijriTheme.gold,
                        (isSelected
                            ? Colors.white
                            : HijriTheme.gold)
                            .withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected
                            ? Colors.white
                            : HijriTheme.gold)
                            .withValues(alpha: 0.5),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),

            // ظ†ظ‚ط·ط© ط§ظ„ظٹظˆظ… ط§ظ„ط­ط§ظ„ظٹ
            if (isToday && !isSelected)
              Positioned(
                bottom: compact ? 2 : 3,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HijriTheme.gold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTextColor() {
    if (isSelected) return Colors.white;
    if (!isCurrent) return theme.subText.withValues(alpha: 0.3);
    if (isFriday) return HijriTheme.gold;
    return theme.text;
  }
}