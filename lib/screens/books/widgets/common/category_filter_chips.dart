import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/books_theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// فلاتر الأقسام المتحركة
/// ═══════════════════════════════════════════════════════════════════════════
class CategoryFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final bool isDark;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((category) {
          return _AnimatedFilterChip(
            label: category,
            isSelected: selectedCategory == category,
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              onCategorySelected(category);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _AnimatedFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedFilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BooksTheme.getFilterChipDecoration(
            isSelected: widget.isSelected,
            isDark: widget.isDark,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSelected) ...[
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: widget.isDark ? BooksTheme.gold : Colors.white,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  color: widget.isSelected
                      ? (widget.isDark ? BooksTheme.gold : Colors.white)
                      : BooksTheme.getSubTextColor(widget.isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}