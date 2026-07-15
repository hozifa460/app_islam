import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/books_theme.dart';
import '../../animations/books_animations.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط´ط±ظٹط· ط§ظ„ط¨ط­ط« ط§ظ„ظ…طھط­ط±ظƒ
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final String hintText;

  const AnimatedSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isDark,
    this.hintText = 'ابحث عن كتاب...',
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _borderAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused
                ? BooksTheme.gold
                : (widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : BooksTheme.gold.withValues(alpha: 0.2)),
            width: _borderAnimation.value,
          ),
          boxShadow: widget.isDark
              ? []
              : [
            BoxShadow(
              color: _isFocused
                  ? BooksTheme.gold.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: _isFocused ? 15 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isFocused = hasFocus);
          if (hasFocus) {
            _focusController.forward();
          } else {
            _focusController.reverse();
          }
        },
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          style: GoogleFonts.cairo(
            color: BooksTheme.getTextColor(widget.isDark),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.cairo(
              color: BooksTheme.getSubTextColor(widget.isDark),
            ),
            prefixIcon: AnimatedRotation(
              turns: _isFocused ? 0.1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.search, color: BooksTheme.gold),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              color: BooksTheme.getSubTextColor(widget.isDark),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged('');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}