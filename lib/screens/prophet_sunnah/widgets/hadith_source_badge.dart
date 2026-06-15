import 'package:flutter/material.dart';

class HadithSourceBadge extends StatelessWidget {
  final String source;
  final String hadithNumber;
  final String authenticity;

  const HadithSourceBadge({
    super.key,
    required this.source,
    required this.hadithNumber,
    required this.authenticity,
  });

  Color get _color {
    if (authenticity.contains('طµط­ظٹط­')) return const Color(0xFF4CAF50);
    if (authenticity.contains('ط­ط³ظ†')) return const Color(0xFFFF9800);
    return const Color(0xFF9E9E9E);
  }

  IconData get _icon {
    if (authenticity.contains('طµط­ظٹط­')) return Icons.verified_rounded;
    if (authenticity.contains('ط­ط³ظ†')) return Icons.check_circle_outline_rounded;
    return Icons.info_outline_rounded;
  }

  String get _shortAuth => authenticity.split(' - ').first;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ط§ظ„ظ…طµط¯ط±
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '$source | $hadithNumber',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.book_outlined, color: Colors.grey, size: 11),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // ط§ظ„ط¯ط±ط¬ط©
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _shortAuth,
                style: TextStyle(
                  color: _color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(_icon, color: _color, size: 11),
            ],
          ),
        ),
      ],
    );
  }
}