import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/azkar_theme.dart';
import 'widgets/azkar_counter_widget.dart';
import 'animations/azkar_animations.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط´ط§ط´ط© طھظپط§طµظٹظ„ ط§ظ„ط£ط°ظƒط§ط±
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class AzkarDetailScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> azkar;

  const AzkarDetailScreen({
    super.key,
    required this.title,
    required this.azkar,
  });

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  late List<int> counters;
  late List<int> initialCounts;

  @override
  void initState() {
    super.initState();
    counters = widget.azkar.map((a) => a['count'] as int).toList();
    initialCounts = List.from(counters);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final basePadding = (screenWidth * 0.045).clamp(12.0, 24.0);
    final cardPadding = (screenWidth * 0.05).clamp(14.0, 24.0);
    final titleFontSize = (screenWidth * 0.055).clamp(18.0, 26.0);
    final zekrFontSize = (screenWidth * 0.058).clamp(18.0, 26.0);
    final infoFontSize = (screenWidth * 0.035).clamp(11.0, 14.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AzkarTheme.getBackgroundColor(isDark);
    final textColorMain = AzkarTheme.getTextColor(isDark);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(isDark, textColorMain, titleFontSize, basePadding),
        body: SafeArea(
          child: ListView.builder(
            padding: EdgeInsets.all(basePadding),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.azkar.length,
            itemBuilder: (context, index) => _buildZekrCard(
              context,
              index,
              isDark,
              textColorMain,
              basePadding,
              cardPadding,
              zekrFontSize,
              infoFontSize,
              screenWidth,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      bool isDark,
      Color textColor,
      double titleFontSize,
      double basePadding,
      ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            widget.title,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w800,
              fontSize: titleFontSize,
              color: textColor,
            ),
          ),
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(basePadding * 0.5),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AzkarTheme.gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AzkarTheme.gold.withValues(alpha: 0.2),
          ),
        ),
        child: TapScaleAnimationWidget(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new,
              color: textColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZekrCard(
      BuildContext context,
      int index,
      bool isDark,
      Color textColorMain,
      double basePadding,
      double cardPadding,
      double zekrFontSize,
      double infoFontSize,
      double screenWidth,
      ) {
    final isDone = counters[index] == 0;
    final zekr = widget.azkar[index];

    return StaggeredListAnimationWidget(
      index: index,
      totalItems: widget.azkar.length,
      child: TapScaleAnimationWidget(
        onTap: () {
          if (counters[index] > 0) {
            setState(() => counters[index]--);
            HapticFeedback.lightImpact();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(bottom: basePadding),
          padding: EdgeInsets.all(cardPadding),
          decoration: isDone
              ? AzkarTheme.getCompletedZekrDecoration(isDark, screenWidth * 0.055)
              : AzkarTheme.getActiveZekrDecoration(isDark, screenWidth * 0.055),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ظ†طµ ط§ظ„ط°ظƒط±
              Text(
                zekr['text'],
                style: GoogleFonts.amiri(
                  fontSize: zekrFontSize,
                  height: 1.8,
                  color: isDone
                      ? (isDark ? Colors.white54 : Colors.black45)
                      : textColorMain,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: basePadding * 0.8),

              // ط§ظ„ظ…طµط¯ط±
              if ((zekr['source'] ?? '').toString().isNotEmpty)
                AzkarInfoBox(
                  icon: Icons.menu_book_rounded,
                  text: 'ط§ظ„ظ…طµط¯ط±: ${zekr['source']}',
                  color: AzkarTheme.gold,
                  isDark: isDark,
                  fontSize: infoFontSize,
                  padding: basePadding,
                ),

              // ط§ظ„ظپط§ط¦ط¯ط©
              if ((zekr['benefit'] ?? '').toString().isNotEmpty)
                AzkarInfoBox(
                  icon: Icons.lightbulb_outline_rounded,
                  text: zekr['benefit'],
                  color: AzkarTheme.success,
                  isDark: isDark,
                  fontSize: infoFontSize,
                  padding: basePadding,
                  isBenefit: true,
                ),

              SizedBox(height: basePadding * 0.6),

              // ط§ظ„ط¹ط¯ط§ط¯
              AzkarCounterWidget(
                count: counters[index],
                initialCount: initialCounts[index],
                isDone: isDone,
                isDark: isDark,
                screenWidth: screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}