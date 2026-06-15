import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';
import 'khatma_common_widgets.dart';

class KhatmaSetupView extends StatelessWidget {
  final Color primaryColor;
  final int setupPages;
  final int selectedPreset;
  final int totalPages;
  final List<Map<String, dynamic>> presets;
  final Animation<double> pulseAnim;
  final Function(int) onPresetSelected;
  final Function(int) onPagesChanged;
  final Function(int, bool) onStartKhatma;

  const KhatmaSetupView({
    super.key,
    required this.primaryColor,
    required this.setupPages,
    required this.selectedPreset,
    required this.totalPages,
    required this.presets,
    required this.pulseAnim,
    required this.onPresetSelected,
    required this.onPagesChanged,
    required this.onStartKhatma,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr; // â†گ ط§ظ„طھط±ط¬ظ…ط©

    int daysToFinish = (totalPages / setupPages).ceil();
    final bgCard = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildHeader(context, tr),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPresetsSection(isDark, bgCard, tr),
                const SizedBox(height: 28),
                _buildManualConfig(context, isDark, bgCard, tr),
                const SizedBox(height: 20),
                _buildPlanSummary(daysToFinish, tr),
                const SizedBox(height: 28),
                _buildStartButton(tr),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Header - ظ…ط­ظ…ظٹ ظ…ظ† ط§ظ„ظ€ Overflow
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildHeader(BuildContext context, AppLocalizations tr) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: LayoutBuilder(
          builder: (context, constraints) {
            final topPadding = MediaQuery.of(context).padding.top;
            final availableHeight =
                constraints.maxHeight - topPadding - kToolbarHeight;
            final isSmall = availableHeight < 100;
            final screenWidth = constraints.maxWidth;

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
                  padding: const EdgeInsets.only(
                      top: kToolbarHeight, left: 16, right: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth - 32,
                      maxHeight: availableHeight,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: pulseAnim,
                            child: Container(
                              padding: EdgeInsets.all(isSmall ? 12 : 20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.auto_stories_rounded,
                                  size: isSmall ? 30 : 50,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            tr.khatmaSetupTitle, // â†گ ظ…طھط±ط¬ظ…
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr.khatmaSetupSubtitle, // â†گ ظ…طھط±ط¬ظ…
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ],
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

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط®ط·ط· ط§ظ„ط³ط±ظٹط¹ط© - ظ…ط­ظ…ظٹط© ظ…ظ† ط§ظ„ظ€ Overflow
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildPresetsSection(
      bool isDark, Color bgCard, AppLocalizations tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            tr.khatmaQuickPlans, // â†گ ظ…طھط±ط¬ظ…
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final itemWidth = (totalWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(presets.length, (index) {
                final preset = presets[index];
                final isSelected = selectedPreset == index;
                final pages = preset['pages'] as int;

                return GestureDetector(
                  onTap: () => onPresetSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: itemWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: itemWidth - 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(preset['icon'],
                              size: 32,
                              color: isSelected
                                  ? Colors.white
                                  : primaryColor),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              preset['label'], // â†گ ظ…طھط±ط¬ظ… ظ…ظ† presets
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                    ? Colors.white
                                    : Colors.black87),
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tr.khatmaPagesPerDay(pages), // â†گ ظ…طھط±ط¬ظ…
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„طھط®طµظٹطµ ط§ظ„ظٹط¯ظˆظٹ - ظ…ط­ظ…ظٹ ظ…ظ† ط§ظ„ظ€ Overflow
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildManualConfig(
      BuildContext context, bool isDark, Color bgCard, AppLocalizations tr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    tr.khatmaCustomize, // â†گ ظ…طھط±ط¬ظ…
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 300;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KhatmaCircleButton(
                    icon: Icons.remove,
                    primaryColor: primaryColor,
                    onTap: () {
                      if (setupPages > 1) onPagesChanged(setupPages - 1);
                    },
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: isSmall ? 80 : 100,
                      maxWidth: isSmall ? 100 : 120,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$setupPages',
                            style: GoogleFonts.cairo(
                              fontSize: isSmall ? 36 : 42,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              height: 1,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tr.kharmaPagesDaily, // â†گ ظ…طھط±ط¬ظ…
                            style: GoogleFonts.cairo(
                                color: Colors.grey,
                                fontSize: isSmall ? 11 : 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  KhatmaCircleButton(
                    icon: Icons.add,
                    primaryColor: primaryColor,
                    onTap: () => onPagesChanged(setupPages + 1),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryColor,
              inactiveTrackColor: primaryColor.withValues(alpha: 0.15),
              thumbColor: primaryColor,
              overlayColor: primaryColor.withValues(alpha: 0.12),
              trackHeight: 6,
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: setupPages.toDouble().clamp(1, 100),
              min: 1,
              max: 100,
              onChanged: (val) => onPagesChanged(val.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ظ…ظ„ط®طµ ط§ظ„ط®ط·ط© - ظ…ط­ظ…ظٹ ظ…ظ† ط§ظ„ظ€ Overflow
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildPlanSummary(int daysToFinish, AppLocalizations tr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          primaryColor.withValues(alpha: 0.1),
          primaryColor.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    tr.khatmaPlanSummary, // â†گ ظ…طھط±ط¬ظ…
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          KhatmaSummaryRow(
            icon: Icons.calendar_today,
            label: tr.khatmaDuration, // â†گ ظ…طھط±ط¬ظ…
            value: tr.khatmaDays(daysToFinish), // â†گ ظ…طھط±ط¬ظ…
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 10),
          KhatmaSummaryRow(
            icon: Icons.timer_outlined,
            label: tr.khatmaDailyTime, // â†گ ظ…طھط±ط¬ظ…
            value: tr.khatmaMinutes(setupPages), // â†گ ظ…طھط±ط¬ظ…
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 10),
          KhatmaSummaryRow(
            icon: Icons.auto_stories,
            label: tr.khatmaTotalPages, // â†گ ظ…طھط±ط¬ظ…
            value: tr.khatma604Pages, // â†گ ظ…طھط±ط¬ظ…
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط²ط± ط§ظ„ط¨ط¯ط، - ظ…ط­ظ…ظٹ ظ…ظ† ط§ظ„ظ€ Overflow
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildStartButton(AppLocalizations tr) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.4),
        ),
        onPressed: () => onStartKhatma(setupPages, false),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 250;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: isSmall ? 24 : 28),
                const SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tr.khatmaStartNow, // â†گ ظ…طھط±ط¬ظ…
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}