import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';

class ProfileGuestBanner extends StatelessWidget {
  final VoidCallback onLogin;

  const ProfileGuestBanner({super.key, required this.onLogin});

  static const _gold = Color(0xFFD4AF37);
  static const _goldD = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr; // ← الترجمة

    return Scaffold(
      body: Stack(
        children: [
          // ═══ الخلفية ═══
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [Color(0xFF0A0E1A), Color(0xFF152238)]
                      : const [Color(0xFFFFFDF8), Color(0xFFFFF8E8)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ═══ الأيقونة ═══
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gold.withOpacity(0.1),
                        border: Border.all(
                          color: _gold.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: _gold,
                        size: 52,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ═══ العنوان ═══
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [_goldD, _gold, _goldD],
                      ).createShader(b),
                      child: Text(
                        tr.guestProfileTitle, // ← مترجم
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ═══ الوصف ═══
                    Text(
                      tr.guestProfileDesc, // ← مترجم
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.grey.shade600,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 36),

                    // ═══ مميزات الحساب ═══
                    _FeaturesList(isDark: isDark),

                    const SizedBox(height: 36),

                    // ═══ زر تسجيل الدخول ═══
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [_goldD, _gold],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login_rounded,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                tr.guestLogin, // ← مترجم
                                style: GoogleFonts.cairo(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ═══ آية ═══
                    Text(
                      tr.guestQuote, // ← مترجم
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        color: _gold.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  final bool isDark;
  const _FeaturesList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr; // ← الترجمة

    // ═══ المميزات مع الترجمة ═══
    final features = [
      (Icons.cloud_sync_rounded, tr.guestFeature1, Colors.blue),
      (Icons.history_rounded, tr.guestFeature2, Colors.green),
      (Icons.star_rounded, tr.guestFeature3, const Color(0xFFD4AF37)),
      (Icons.notifications_rounded, tr.guestFeature4, Colors.orange),
    ];

    return Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: f.$3.withOpacity(0.12),
                ),
                child: Icon(f.$1, color: f.$3, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  f.$2, // ← النص المترجم
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withOpacity(0.75)
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade400,
                size: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}