import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Constants/sunnah_theme.dart';
import '../models/sunnah_category.dart';
import 'sunnah_detail_sheet.dart';

class CategoryCardWidget extends StatefulWidget {
  final SunnahCategory category;
  final int index;
  final bool isDark;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.index,
    required this.isDark,
  });

  @override
  State<CategoryCardWidget> createState() => _CategoryCardWidgetState();
}

class _CategoryCardWidgetState extends State<CategoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 80),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _slideAnim = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    try {
      final hex = widget.category.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return SunnahTheme.gold;
    }
  }

  void _openSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SunnahDetailSheet(
        category: widget.category,
        categoryColor: _color,
        isDark: widget.isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Opacity(
          opacity: _scaleAnim.value.clamp(0.0, 1.0),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _CardContent(
          category: widget.category,
          color: _color,
          isDark: widget.isDark,
          onTap: _openSheet,
        ),
      ),
    );
  }
}

// ─── محتوى البطاقة ──────────────────────────────────────────────────────────

class _CardContent extends StatefulWidget {
  final SunnahCategory category;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _CardContent({
    required this.category,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_CardContent> createState() => _CardContentState();
}

class _CardContentState extends State<_CardContent> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark
        ? const Color(0xFF111827)
        : Colors.white;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.black.withOpacity(0.3)
                    : widget.color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // شريط جانبي ملون
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.color,
                          widget.color.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                // المحتوى
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // سهم
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: widget.color.withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      // عداد
                      _CountBadge(
                        count: widget.category.sunnahs.length,
                        color: widget.color,
                      ),
                      const SizedBox(width: 14),
                      // النص
                      Expanded(
                        child: _CardText(
                          category: widget.category,
                          isDark: widget.isDark,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // أيقونة
                      _CategoryIcon(color: widget.color),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardText extends StatelessWidget {
  final SunnahCategory category;
  final bool isDark;
  final Color color;
  const _CardText(
      {required this.category, required this.isDark, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          category.name,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${category.sunnahs.length} سنة نبوية موثقة',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF9A9AB0),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.verified_rounded, size: 11, color: color.withOpacity(0.7)),
          ],
        ),
      ],
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final Color color;
  const _CategoryIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.25), color.withOpacity(0.08)],
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(Icons.menu_book_rounded, color: color, size: 24),
    );
  }
}