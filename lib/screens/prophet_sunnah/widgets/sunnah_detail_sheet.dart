import 'package:flutter/material.dart';
import '../models/sunnah_category.dart';
import 'sunnah_item_card.dart';

class SunnahDetailSheet extends StatefulWidget {
  final SunnahCategory category;
  final Color categoryColor;
  final bool isDark;

  const SunnahDetailSheet({
    super.key,
    required this.category,
    required this.categoryColor,
    required this.isDark,
  });

  @override
  State<SunnahDetailSheet> createState() => _SunnahDetailSheetState();
}

class _SunnahDetailSheetState extends State<SunnahDetailSheet>
    with SingleTickerProviderStateMixin {
  int _expandedIndex = -1;
  late AnimationController _sheetAnim;

  @override
  void initState() {
    super.initState();
    _sheetAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _sheetAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = (screenHeight * 0.92).clamp(400.0, 900.0);
    final bgColor = widget.isDark
        ? const Color(0xFF0D1321)
        : const Color(0xFFF8F5EE);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _sheetAnim, curve: Curves.easeOut)),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            _SheetHandle(color: widget.categoryColor),
            // Header
            _SheetHeader(
              category: widget.category,
              color: widget.categoryColor,
              isDark: widget.isDark,
            ),
            // ط§ظ„ظ‚ط§ط¦ظ…ط©
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  MediaQuery.of(context).padding.bottom + 20,
                ),
                itemCount: widget.category.sunnahs.length,
                itemBuilder: (context, index) => SunnahItemCard(
                  item: widget.category.sunnahs[index],
                  index: index,
                  isExpanded: _expandedIndex == index,
                  color: widget.categoryColor,
                  isDark: widget.isDark,
                  onTap: () => setState(() {
                    _expandedIndex = _expandedIndex == index ? -1 : index;
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final Color color;
  const _SheetHandle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final SunnahCategory category;
  final Color color;
  final bool isDark;

  const _SheetHeader({
    required this.category,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1A2540) : Colors.white;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ط³ظ‡ظ… ط§ظ„ط¥ط؛ظ„ط§ظ‚
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.close_rounded, color: color, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          // ط¹ط¯ط§ط¯
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${category.sunnahs.length}',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ط³ظ†ط©',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ط§ظ„ط¹ظ†ظˆط§ظ†
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  category.name,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ط§ط¶ط؛ط· ط¹ظ„ظ‰ ط§ظ„ط³ظ†ط© ظ„ط¹ط±ط¶ ط§ظ„طھظپط§طµظٹظ„',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF9A9AB0),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}