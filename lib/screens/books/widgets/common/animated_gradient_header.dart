import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/books_theme.dart';
import '../../animations/books_animations.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// الهيدر المتدرج المتحرك
/// ═══════════════════════════════════════════════════════════════════════════
class AnimatedGradientHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final Color primaryColor;
  final IconData icon;
  final VoidCallback onBack;

  const AnimatedGradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.icon,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: _AnimatedHeaderContent(
        title: title,
        subtitle: subtitle,
        primaryColor: primaryColor,
        icon: icon,
        onBack: onBack,
      ),
    );
  }
}

class _AnimatedHeaderContent extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color primaryColor;
  final IconData icon;
  final VoidCallback onBack;

  const _AnimatedHeaderContent({
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.icon,
    required this.onBack,
  });

  @override
  State<_AnimatedHeaderContent> createState() => _AnimatedHeaderContentState();
}

class _AnimatedHeaderContentState extends State<_AnimatedHeaderContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BooksTheme.getGradientHeaderDecoration(widget.primaryColor),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                children: [
                  // زر الرجوع
                  _BackButton(onBack: widget.onBack),
                  const SizedBox(width: 12),
                  // العنوان والوصف
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // الأيقونة
                  _HeaderIcon(icon: widget.icon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onBack;

  const _BackButton({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return TapScaleAnimation(
      onTap: onBack,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatefulWidget {
  final IconData icon;

  const _HeaderIcon({required this.icon});

  @override
  State<_HeaderIcon> createState() => _HeaderIconState();
}

class _HeaderIconState extends State<_HeaderIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}