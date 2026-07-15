import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

class QiblaAppBar extends StatelessWidget {
  final QiblaTheme theme;
  final double? qiblaAngle;
  final double compassHeading;
  final VoidCallback onBack;

  const QiblaAppBar({
    super.key,
    required this.theme,
    required this.qiblaAngle,
    required this.compassHeading,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.backBtnBg,
              borderRadius: BorderRadius.circular(QiblaTheme.backBtnRadius),
              border: Border.all(color: theme.backBtnBorder),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: theme.textColor, size: 18),
              onPressed: onBack,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اتجاه القبلة', style: theme.titleStyle),
                if (qiblaAngle != null)
                  Text(
                    'القبلة: ${qiblaAngle!.toStringAsFixed(1)}آ° '
                        '| هاتفك: ${compassHeading.toStringAsFixed(1)}آ°',
                    style: theme.subtitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QiblaTheme.gold.withValues(alpha: 0.12),
              border: Border.all(color: QiblaTheme.gold.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.mosque_rounded,
                color: QiblaTheme.gold, size: 20),
          ),
        ],
      ),
    );
  }
}