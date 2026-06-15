import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../languages/app_localizations.dart';
import '../services/auth_service.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key});

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.read<AuthService>();
    final tr = context.tr; // â†گ ط§ظ„طھط±ط¬ظ…ط©

    return Column(
      children: [
        // â•گâ•گâ•گ ط§ظ„ظپط§طµظ„ â•گâ•گâ•گ
        _Divider(isDark: isDark),

        const SizedBox(height: 22),

        // â•گâ•گâ•گ ط£ط²ط±ط§ط± Google ظˆ Apple â•گâ•گâ•گ
        Row(
          children: [
            Expanded(
              child: _SocialBtn(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                iconColor: const Color(0xFFDB4437),
                isDark: isDark,
                onTap: () => _google(context, auth),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _SocialBtn(
                label: 'Apple',
                icon: Icons.apple_rounded,
                iconColor: isDark ? Colors.white : Colors.black87,
                isDark: isDark,
                onTap: () => _apple(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // â•گâ•گâ•گ ط§ظ„ط¯ط®ظˆظ„ ظƒط²ط§ط¦ط± â•گâ•گâ•گ
        TextButton(
          onPressed: () => auth.continueAsGuest(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                tr.loginAsGuest, // â†گ ظ…طھط±ط¬ظ…
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _google(BuildContext context, AuthService auth) async {
    final tr = context.tr;
    final r = await auth.signInWithGoogle();
    if (!r.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r.error ?? tr.error, style: GoogleFonts.cairo()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _apple(BuildContext context) {
    final tr = context.tr;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr.appleComingSoon, style: GoogleFonts.cairo()),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr; // â†گ ط§ظ„طھط±ط¬ظ…ط©
    final lc =
    isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300;
    final tc =
    isDark ? Colors.white.withValues(alpha: 0.4) : Colors.grey.shade500;

    return Row(
      children: [
        Expanded(child: Divider(color: lc, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            tr.orLoginWith, // â†گ ظ…طھط±ط¬ظ…
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: tc,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: lc, thickness: 1)),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.grey.shade300,
              width: 1.4,
            ),
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}