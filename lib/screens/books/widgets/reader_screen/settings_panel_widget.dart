import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../animations/books_animations.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// لوحة إعدادات القراءة
/// ═══════════════════════════════════════════════════════════════════════════
class SettingsPanelWidget extends StatelessWidget {
  final bool show;
  final VoidCallback onClose;

  const SettingsPanelWidget({
    super.key,
    required this.show,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SlideDownAnimation(
      show: show,
      child: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text(
              'إعدادات القراءة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            _AnimatedCloseButton(onClose: onClose),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCloseButton extends StatefulWidget {
  final VoidCallback onClose;

  const _AnimatedCloseButton({required this.onClose});

  @override
  State<_AnimatedCloseButton> createState() => _AnimatedCloseButtonState();
}

class _AnimatedCloseButtonState extends State<_AnimatedCloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
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
        widget.onClose();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) => Transform.rotate(
          angle: _rotationAnimation.value * 3.14,
          child: child,
        ),
        child: const Icon(
          Icons.keyboard_arrow_up,
          color: Colors.grey,
        ),
      ),
    );
  }
}