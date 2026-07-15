import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sunnah_item.dart';
import 'hadith_source_badge.dart';

class SunnahItemCard extends StatelessWidget {
  final SunnahItem item;
  final int index;
  final bool isExpanded;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const SunnahItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.isExpanded,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final expandedColor =
    isDark ? const Color(0xFF1A2540) : const Color(0xFFF0EBE0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isExpanded ? expandedColor : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? color.withValues(alpha: 0.45)
                : (isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.07)),
            width: 1.2,
          ),
          boxShadow: isExpanded
              ? [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ط§ظ„ط¹ظ†ظˆط§ظ†
            _ItemHeader(
              item: item,
              index: index,
              isExpanded: isExpanded,
              color: color,
              isDark: isDark,
            ),
            // ط§ظ„طھظپط§طµظٹظ„
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: _ItemDetails(
                item: item,
                color: color,
                isDark: isDark,
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 320),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ ظ‡ظٹط¯ط± ط§ظ„ط¨ط·ط§ظ‚ط© â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ItemHeader extends StatelessWidget {
  final SunnahItem item;
  final int index;
  final bool isExpanded;
  final Color color;
  final bool isDark;

  const _ItemHeader({
    required this.item,
    required this.index,
    required this.isExpanded,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ظ…ط¤ط´ط± ط§ظ„ط±ظ‚ظ… / ط§ظ„ط³ظ‡ظ…
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isExpanded
                  ? color.withValues(alpha: 0.2)
                  : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05)),
              border: Border.all(
                color: isExpanded
                    ? color.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isExpanded
                  ? Icon(Icons.keyboard_arrow_up_rounded,
                  key: const ValueKey('up'), color: color, size: 20)
                  : Center(
                key: const ValueKey('num'),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ط§ظ„ط¹ظ†ظˆط§ظ†
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                  ),
                ),
                if (!isExpanded) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white38
                          : const Color(0xFF9A9AB0),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ طھظپط§طµظٹظ„ ط§ظ„ط¨ط·ط§ظ‚ط© â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ItemDetails extends StatelessWidget {
  final SunnahItem item;
  final Color color;
  final bool isDark;

  const _ItemDetails({
    required this.item,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ظپط§طµظ„
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  color.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // ط§ظ„ظˆطµظپ
          _DescriptionBox(text: item.description, isDark: isDark),
          const SizedBox(height: 12),
          // ط§ظ„ط­ط¯ظٹط«
          _HadithBox(hadith: item.hadith, color: color, isDark: isDark),
          const SizedBox(height: 12),
          // ط§ظ„ط±ط§ظˆظٹ
          _NarratorRow(narrator: item.narrator, isDark: isDark),
          const SizedBox(height: 12),
          // Footer
          _CardFooter(item: item, color: color),
        ],
      ),
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  final String text;
  final bool isDark;
  const _DescriptionBox({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF5A5A7A),
                fontSize: 13,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.info_outline_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
            size: 15,
          ),
        ],
      ),
    );
  }
}

class _HadithBox extends StatelessWidget {
  final String hadith;
  final Color color;
  final bool isDark;
  const _HadithBox(
      {required this.hadith, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الحديث الشريف',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF9A9AB0),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.format_quote_rounded,
                  color: color.withValues(alpha: 0.6), size: 14),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"$hadith"',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              fontSize: 14,
              fontFamily: 'Amiri',
              height: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _NarratorRow extends StatelessWidget {
  final String narrator;
  final bool isDark;
  const _NarratorRow({required this.narrator, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            narrator,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF7A7A9A),
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'رواه:',
          style: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFF9A9AB0),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.person_outline_rounded,
          color: isDark ? Colors.white24 : Colors.black26,
          size: 14,
        ),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  final SunnahItem item;
  final Color color;
  const _CardFooter({required this.item, required this.color});

  void _copy(BuildContext context) {
    final text = '${item.title}\n\n'
        '"${item.hadith}"\n\n'
        'رواه: ${item.narrator}\n'
        'المصدر: ${item.source} | رقم: ${item.hadithNumber}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('تم نسخ الحديث ✓',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ط²ط± ط§ظ„ظ†ط³ط®
        GestureDetector(
          onTap: () => _copy(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('نسخ',
                    style: TextStyle(color: color, fontSize: 12)),
                const SizedBox(width: 5),
                Icon(Icons.copy_rounded, color: color, size: 13),
              ],
            ),
          ),
        ),
        // ط§ظ„ط´ط§ط±ط©
        Flexible(
          child: HadithSourceBadge(
            source: item.source,
            hadithNumber: item.hadithNumber,
            authenticity: item.authenticity,
          ),
        ),
      ],
    );
  }
}