import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/azkar_theme.dart';
import '../animations/azkar_animations.dart';
import 'decorative_elements.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط¨ط·ط§ظ‚ط© طھطµظ†ظٹظپ ط§ظ„ط£ط°ظƒط§ط±
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class AzkarCategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final List<dynamic> azkarList;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const AzkarCategoryCard({
    super.key,
    required this.category,
    required this.azkarList,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sizes = AzkarSizes(size);
    final accent = AzkarTheme.getCardAccent(index);

    return SlideInAnimationWidget(
      index: index,
      child: TapScaleAnimationWidget(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          height: sizes.cardHeight,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AzkarTheme.getCardDecoration(
            index: index,
            isDark: isDark,
            accent: accent,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // ط§ظ„ط¯ظˆط§ط¦ط± ط§ظ„ط®ظ„ظپظٹط©
                CardBackgroundCircles(
                  cardHeight: sizes.cardHeight,
                  accent: accent,
                ),
                // ط§ظ„ط´ط±ظٹط· ط§ظ„ط¬ط§ظ†ط¨ظٹ
                ColoredSideStrip(
                  color: accent,
                  height: sizes.cardHeight,
                ),
                // ط§ظ„ظ…ط­طھظˆظ‰
                _buildCardContent(context, sizes, accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
      BuildContext context,
      AzkarSizes sizes,
      Color accent,
      ) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (size.width * 0.038).clamp(10.0, 18.0),
      ),
      child: Row(
        children: [
          _buildIcon(sizes, accent),
          SizedBox(width: (size.width * 0.035).clamp(8.0, 16.0)),
          Expanded(child: _buildTextContent(sizes, accent)),
          const SizedBox(width: 8),
          _buildArrow(sizes, accent),
        ],
      ),
    );
  }

  Widget _buildIcon(AzkarSizes sizes, Color accent) {
    return PulseAnimationWidget(
      minScale: 0.95,
      maxScale: 1.0,
      duration: const Duration(seconds: 3),
      child: Container(
        width: sizes.iconContainerSize,
        height: sizes.iconContainerSize,
        decoration: AzkarTheme.getIconContainerDecoration(accent),
        child: Center(
          child: Icon(
            _iconFromString(category['icon'] as String),
            color: accent,
            size: sizes.iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(AzkarSizes sizes, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ط±ظ‚ظ… ط§ظ„طھطµظ†ظٹظپ
        Text(
          (index + 1).toString().padLeft(2, '0'),
          style: GoogleFonts.cairo(
            fontSize: sizes.subFontSize * 0.9,
            color: accent.withValues(alpha: 0.55),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 1),
        // ط§ظ„ط¹ظ†ظˆط§ظ†
        Text(
          category['title'] as String,
          style: GoogleFonts.cairo(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w800,
            fontSize: sizes.titleFontSize,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        // ط¹ط¯ط¯ ط§ظ„ط£ط°ظƒط§ط±
        _buildAzkarCountBadge(sizes, accent),
      ],
    );
  }

  Widget _buildAzkarCountBadge(AzkarSizes sizes, Color accent) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.basePadding * 0.5,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_list_bulleted_rounded,
            color: accent,
            size: sizes.subFontSize * 1.1,
          ),
          const SizedBox(width: 4),
          Text(
            '${azkarList.length} ط°ظƒط±',
            style: GoogleFonts.cairo(
              fontSize: sizes.subFontSize,
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(AzkarSizes sizes, Color accent) {
    return Container(
      width: sizes.arrowContainerSize,
      height: sizes.arrowContainerSize,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: accent,
          size: sizes.arrowIconSize,
        ),
      ),
    );
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'wb_sunny_rounded':
        return Icons.wb_sunny_rounded;
      case 'nights_stay_rounded':
        return Icons.nights_stay_rounded;
      case 'mosque_rounded':
        return Icons.mosque_rounded;
      case 'bedtime_rounded':
        return Icons.bedtime_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}