import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/auth/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../../languages/app_localizations.dart';
import '../../languages/widgets/language_selector.dart';
import 'otp_screen.dart';
import 'widgets/auth_background.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_tab_selector.dart';
import 'widgets/login_form.dart';
import 'widgets/signup_form.dart';
import 'widgets/social_login_section.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFD4AF37);
  bool _isLogin = true;

  late AnimationController _entryCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _socialFade;

  @override
  void initState() {
    super.initState();
    _setupEntry();
    _entryCtrl.forward();
  }

  void _setupEntry() {
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _headerFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _formFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );
    _formSlide = Tween(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _socialFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final tr = context.tr;

    // ═══════════════════════════════════════
    // ✅ OTP فقط - بدون VerifyEmail
    // ═══════════════════════════════════════
    if (auth.needsOTP) {
      return const OTPScreen();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bp = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            bottom: false,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 26, right: 26, bottom: bp + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: const LanguageButton(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _headerSlide,
                      child: FadeTransition(
                        opacity: _headerFade,
                        child: AuthHeader(isLogin: _isLogin),
                      ),
                    ),
                    const SizedBox(height: 34),
                    SlideTransition(
                      position: _formSlide,
                      child: FadeTransition(
                        opacity: _formFade,
                        child: _buildCard(isDark),
                      ),
                    ),
                    const SizedBox(height: 26),
                    FadeTransition(
                      opacity: _socialFade,
                      child: const SocialLoginSection(),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _socialFade,
                      child: Text(
                        tr.authQuote,
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: _gold.withOpacity(isDark ? 0.5 : 0.65),
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.white.withOpacity(0.55),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : _gold.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : _gold.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AuthTabSelector(
            isLogin: _isLogin,
            onChanged: (v) => setState(() => _isLogin = v),
          ),
          const SizedBox(height: 26),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) {
              final slide = Tween(
                begin: Offset(_isLogin ? -0.08 : 0.08, 0),
                end: Offset.zero,
              ).animate(anim);
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: _isLogin
                ? const LoginForm(key: ValueKey('login'))
                : const SignupForm(key: ValueKey('signup')),
          ),
        ],
      ),
    );
  }
}