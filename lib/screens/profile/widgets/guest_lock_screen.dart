import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_screen.dart';
import '../../auth/services/auth_service.dart';

class GuestLockScreen extends StatelessWidget {
  const GuestLockScreen({super.key});

  static const _gold = Color(0xFFD4AF37);
  static const _goldD = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E1A)
          : const Color(0xFFFFFDF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ط£ظٹظ‚ظˆظ†ط©
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _gold.withValues(alpha: 0.15),
                        _gold.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: _gold.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: _gold,
                    size: 52,
                  ),
                ),

                const SizedBox(height: 32),

                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [_goldD, _gold, _goldD],
                  ).createShader(b),
                  child: Text(
                    'الملف الشخصي',
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'سجّل دخولك لتتمكن من الوصول إلى ملفك\nالشخصي وحفظ تقدمك',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.55)
                        : Colors.grey.shade600,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // ظ…ظ…ظٹط²ط§طھ
                ..._features(isDark),

                const SizedBox(height: 36),

                // ط²ط±
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<AuthService>().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const AuthScreen(),
                          ),
                              (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 6,
                      shadowColor: _gold.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login_rounded, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'تسجيل الدخول',
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'العودة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  '﴿ وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَى ﴾',
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: _gold.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _features(bool isDark) {
    final list = [
      (Icons.cloud_sync_rounded, 'مزامنة التقدم عبر الأجهزة', Colors.blue),
      (Icons.restore_rounded, 'استعادة البيانات بعد الحذف', Colors.green),
      (Icons.star_rounded, 'تتبع إنجازاتك اليومية', _gold),
      (Icons.shield_rounded, 'حماية بياناتك وخصوصيتك', Colors.purple),
    ];

    return list
        .map((f) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: f.$3.withValues(alpha: 0.1),
            ),
            child: Icon(f.$1, color: f.$3, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              f.$2,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black87,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green.shade400,
            size: 18,
          ),
        ],
      ),
    ))
        .toList();
  }
}