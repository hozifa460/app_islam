import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthHeader extends StatelessWidget {
  final bool isLogin;
  const AuthHeader({super.key, required this.isLogin});

  static const _gold = Color(0xFFD4AF37);
  static const _goldL = Color(0xFFE6C866);
  static const _goldD = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isDark
                  ? const [Color(0xFF1E2A4A), Color(0xFF0F1628)]
                  : const [Colors.white, Color(0xFFFFF8E8)],
            ),
            border: Border.all(color: _gold, width: 2.8),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(isDark ? 0.35 : 0.2),
                blurRadius: 30,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : _gold.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset(
              'assets/icon/icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.mosque_rounded,
                size: 42,
                color: _gold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [_goldD, _gold, _goldL, _gold, _goldD],
          ).createShader(b),
          child: Text(
            'طريق الإسلام',
            style: GoogleFonts.amiri(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Text(
            isLogin ? 'مرحباً بعودتك 👋' : 'أهلاً وسهلاً بك ✨',
            key: ValueKey(isLogin),
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF5D4E37).withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}