import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import 'khatma_common_widgets.dart';

class KhatmaDashboardView extends StatelessWidget {
  final Color primaryColor;
  final int currentPage;
  final int dailyPages;
  final int totalPages;
  final int? previousPage;
  final List<String> surahNames;
  final int Function(int) getSurahIndexForPage;
  final int Function() getCurrentJuz;
  final String Function(int) toArabicNum;
  final int Function() getEstimatedMinutes;
  final int Function() getDaysRemaining;
  final VoidCallback onGoToWird;
  final Function(int) onAdvanceProgress;
  final VoidCallback onUndoProgress;
  final VoidCallback onSelectReminderTime;
  final VoidCallback onShowResetDialog;

  const KhatmaDashboardView({
    super.key,
    required this.primaryColor,
    required this.currentPage,
    required this.dailyPages,
    required this.totalPages,
    required this.previousPage,
    required this.surahNames,
    required this.getSurahIndexForPage,
    required this.getCurrentJuz,
    required this.toArabicNum,
    required this.getEstimatedMinutes,
    required this.getDaysRemaining,
    required this.onGoToWird,
    required this.onAdvanceProgress,
    required this.onUndoProgress,
    required this.onSelectReminderTime,
    required this.onShowResetDialog,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int endPage = currentPage + dailyPages - 1;
    if (endPage > totalPages) endPage = totalPages;
    int remainingPages = totalPages - currentPage + 1;
    double progress = (currentPage - 1) / totalPages;

    int currentSurahIdx = getSurahIndexForPage(currentPage);
    int endSurahIdx = getSurahIndexForPage(endPage);
    int currentJuz = getCurrentJuz();

    final bgCard = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context, progress, currentJuz, remainingPages),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildWirdCard(
                  context, isDark, bgCard, textMain,
                  endPage, currentSurahIdx, endSurahIdx,
                ),
                const SizedBox(height: 20),
                _buildStatsCard(
                  context, isDark, bgCard, textMain,
                  currentSurahIdx, currentJuz,
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ AppBar مع دائرة التقدم
  Widget _buildAppBar(BuildContext context, double progress,
      int currentJuz, int remainingPages) {
    final tr = context.tr;

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.alarm_add_rounded, color: Colors.white),
          tooltip: tr.t('khatmaDailyReminder'),
          onPressed: onSelectReminderTime,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'reset') onShowResetDialog();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  const Icon(Icons.refresh, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(tr.t('khatmaResetKhatma'),
                      style: GoogleFonts.cairo()),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: LayoutBuilder(
          builder: (context, constraints) {
            final topPadding = MediaQuery.of(context).padding.top;
            final totalHeight = constraints.maxHeight;
            final contentHeight = totalHeight - topPadding - kToolbarHeight;
            final screenWidth = constraints.maxWidth;

            final isNarrow = screenWidth < 360;
            final isTight = contentHeight < 200;

            final circleSize = isTight ? 100.0 : isNarrow ? 120.0 : 150.0;
            final percentFont = isTight ? 24.0 : isNarrow ? 30.0 : 36.0;
            final strokeW = isTight ? 8.0 : (isNarrow ? 10.0 : 14.0);
            final juzFont = isTight ? 9.0 : (isNarrow ? 10.0 : 12.0);
            final gapAfterCircle = isTight ? 8.0 : (isNarrow ? 12.0 : 18.0);

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    primaryColor,
                    HSLColor.fromColor(primaryColor)
                        .withLightness(0.25)
                        .toColor(),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  child: ClipRect(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isNarrow ? 12 : 20),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: screenWidth - (isNarrow ? 24 : 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildProgressCircle(
                                context, progress, circleSize, percentFont,
                                strokeW, juzFont, currentJuz,
                              ),
                              SizedBox(height: gapAfterCircle),
                              KhatmaDashboardStats(
                                currentPage: currentPage,
                                remainingPages: remainingPages,
                                getDaysRemaining: getDaysRemaining,
                                isNarrow: isNarrow,
                                isTight: isTight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ دائرة التقدم
  Widget _buildProgressCircle(
      BuildContext context,
      double progress, double circleSize, double percentFont,
      double strokeW, double juzFont, int currentJuz,
      ) {
    final tr = context.tr;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return SizedBox(
          width: circleSize,
          height: circleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: strokeW,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: Colors.transparent,
                ),
              ),
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeW,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.amberAccent),
                  strokeCap: StrokeCap.round,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(value * 100).toInt()}%',
                      style: GoogleFonts.cairo(
                        fontSize: percentFont,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${tr.t('juzWord')} ${toArabicNum(currentJuz)}',
                        style: GoogleFonts.cairo(
                            fontSize: juzFont, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ بطاقة الورد اليومي
  Widget _buildWirdCard(
      BuildContext context, bool isDark, Color bgCard,
      Color textMain, int endPage, int currentSurahIdx, int endSurahIdx,
      ) {
    final tr = context.tr;

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // العنوان
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 300;
                return Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmall ? 8 : 10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.menu_book,
                          color: primaryColor,
                          size: isSmall ? 18 : 22),
                    ),
                    SizedBox(width: isSmall ? 8 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(tr.t('khatmaTodayWird'),
                                style: GoogleFonts.cairo(
                                  fontSize: isSmall ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                )),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              '$dailyPages ${tr.t('pageWord')} • ≈ ${getEstimatedMinutes()} ${tr.t('minuteWord')}',
                              style: GoogleFonts.cairo(
                                  fontSize: isSmall ? 10 : 12,
                                  color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // تفاصيل الورد
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 280;
                return Row(
                  children: [
                    Expanded(
                      child: KhatmaPageCard(
                        label: tr.t('khatmaStart'),
                        page: currentPage,
                        surahIdx: currentSurahIdx,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        toArabicNum: toArabicNum,
                        surahNames: surahNames,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 6 : 12),
                      child: Icon(Icons.arrow_forward,
                          color: primaryColor,
                          size: isSmall ? 20 : 24),
                    ),
                    Expanded(
                      child: KhatmaPageCard(
                        label: tr.t('khatmaEnd'),
                        page: endPage,
                        surahIdx: endSurahIdx,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        toArabicNum: toArabicNum,
                        surahNames: surahNames,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // الأزرار
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 300;
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: isSmall ? 48 : 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: onGoToWird,
                        icon: Icon(Icons.auto_stories,
                            color: Colors.white,
                            size: isSmall ? 20 : 24),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(tr.t('khatmaReadWird'),
                              style: GoogleFonts.cairo(
                                fontSize: isSmall ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 8 : 10),
                    SizedBox(
                      width: double.infinity,
                      height: isSmall ? 44 : 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.green.shade400, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => onAdvanceProgress(endPage + 1),
                        icon: Icon(Icons.check_circle_outline,
                            color: Colors.green.shade600,
                            size: isSmall ? 18 : 22),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(tr.t('khatmaReadFromMushaf'),
                              style: GoogleFonts.cairo(
                                fontSize: isSmall ? 12 : 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              )),
                        ),
                      ),
                    ),
                    if (previousPage != null) ...[
                      SizedBox(height: isSmall ? 8 : 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: TextButton.icon(
                          onPressed: onUndoProgress,
                          icon: Icon(Icons.undo,
                              size: isSmall ? 16 : 18,
                              color: Colors.orange),
                          label: Text(tr.t('khatmaUndoLast'),
                              style: GoogleFonts.cairo(
                                color: Colors.orange,
                                fontSize: isSmall ? 11 : 13,
                              )),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ بطاقة الإحصائيات
  Widget _buildStatsCard(
      BuildContext context, bool isDark, Color bgCard, Color textMain,
      int currentSurahIdx, int currentJuz,
      ) {
    final tr = context.tr;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(tr.t('khatmaStats'),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          KhatmaStatRow(
            icon: Icons.auto_stories,
            label: tr.t('khatmaCurrentPage'),
            value: '${toArabicNum(currentPage)} / ٦٠٤',
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 14),
          KhatmaStatRow(
            icon: Icons.view_agenda,
            label: tr.t('khatmaCurrentJuz'),
            value: '${tr.t('juzWord')} ${toArabicNum(currentJuz)} ${tr.t('of30')}',
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 14),
          KhatmaStatRow(
            icon: Icons.book,
            label: tr.t('khatmaCurrentSurah'),
            value: surahNames[currentSurahIdx - 1],
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 14),
          KhatmaStatRow(
            icon: Icons.calendar_today,
            label: tr.t('khatmaDaysRemaining'),
            value: '${getDaysRemaining()} ${tr.t('dayWord')}',
            isDark: isDark,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }
}