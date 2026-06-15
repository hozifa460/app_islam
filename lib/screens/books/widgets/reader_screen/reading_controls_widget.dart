import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/books_theme.dart';
import '../../animations/books_animations.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// شريط التحكم السفلي للقارئ
/// ═══════════════════════════════════════════════════════════════════════════
class ReadingControlsWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color primaryColor;
  final Function(int) onPageChanged;
  final VoidCallback onRestart;
  final VoidCallback onBookmark;

  const ReadingControlsWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.primaryColor,
    required this.onPageChanged,
    required this.onRestart,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    double safeMaxValue = (totalPages > 0 ? totalPages - 1 : 0).toDouble();
    double safeCurrentValue = currentPage.toDouble().clamp(0, safeMaxValue);

    return SafeArea(
      top: false,
      child: Container(
        color: primaryColor,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط التمرير
            _AnimatedSlider(
              value: safeCurrentValue,
              max: safeMaxValue,
              onChanged: onPageChanged,
            ),
            // أزرار التحكم
            _ControlButtons(
              currentPage: currentPage,
              totalPages: totalPages,
              onRestart: onRestart,
              onBookmark: onBookmark,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// شريط التمرير المتحرك
// ═══════════════════════════════════════════
class _AnimatedSlider extends StatelessWidget {
  final double value;
  final double max;
  final Function(int) onChanged;

  const _AnimatedSlider({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: Colors.white,
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withOpacity(0.3),
        trackHeight: 2.6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayColor: Colors.white.withOpacity(0.2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      child: Slider(
        value: value,
        min: 0,
        max: max,
        onChanged: (v) => onChanged(v.toInt()),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// أزرار التحكم
// ═══════════════════════════════════════════
class _ControlButtons extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onRestart;
  final VoidCallback onBookmark;

  const _ControlButtons({
    required this.currentPage,
    required this.totalPages,
    required this.onRestart,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AnimatedIconButton(
          icon: Icons.restart_alt,
          onPressed: onRestart,
        ),
        Expanded(
          child: Center(
            child: _AnimatedPageCounter(
              currentPage: currentPage + 1,
              totalPages: totalPages,
            ),
          ),
        ),
        _AnimatedIconButton(
          icon: Icons.push_pin,
          onPressed: onBookmark,
        ),
      ],
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
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
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _AnimatedPageCounter extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _AnimatedPageCounter({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Text(
        '$currentPage / ${totalPages == 0 ? "..." : totalPages}',
        key: ValueKey(currentPage),
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// زر القفل العائم
/// ═══════════════════════════════════════════════════════════════════════════
class LockButtonWidget extends StatelessWidget {
  final bool isLocked;
  final VoidCallback onToggle;

  const LockButtonWidget({
    super.key,
    required this.isLocked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleAnimation(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BooksTheme.getLockButtonDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isLocked ? Icons.lock : Icons.swap_vert,
                key: ValueKey(isLocked),
                color: isLocked ? BooksTheme.gold : Colors.black54,
                size: 18,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              isLocked ? 'مقفل' : 'Lock',
              style: GoogleFonts.cairo(
                fontSize: 9,
                color: isLocked ? BooksTheme.gold : Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}