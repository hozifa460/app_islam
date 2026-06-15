import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTabSelector extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onChanged;

  const AuthTabSelector({
    super.key,
    required this.isLogin,
    required this.onChanged,
  });

  static const _gold = Color(0xFFD4AF37);
  static const _goldD = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.grey.shade200.withOpacity(0.7),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.shade300.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          _Tab(
            text: 'تسجيل الدخول',
            active: isLogin,
            isDark: isDark,
            onTap: () => onChanged(true),
          ),
          _Tab(
            text: 'إنشاء حساب',
            active: !isLogin,
            isDark: isDark,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _Tab({
    required this.text,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  static const _gold = Color(0xFFD4AF37);
  static const _goldD = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: active
                ? const LinearGradient(colors: [_goldD, _gold])
                : null,
            boxShadow: active
                ? [
              BoxShadow(
                color: _gold.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active
                  ? Colors.white
                  : isDark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}