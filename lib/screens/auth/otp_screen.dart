import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/auth/services/auth_service.dart';
import 'package:islamic_app/screens/auth/widgets/auth_background.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with TickerProviderStateMixin {
  static const _gold = Color(0xFFD4AF37);
  static const _otpLength = 6;

  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  Timer? _cooldownTimer;
  int _cooldown = 60;
  String? _error;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < _otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    _setupAnimations();
  }

  void _setupAnimations() {
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _entrySlide = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulse = Tween(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _entryCtrl.forward();
    _startCooldown();
  }

  void _startCooldown() {
    _cooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _cooldown--;
          if (_cooldown <= 0) _cooldownTimer?.cancel();
        });
      }
    });
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    _cooldownTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthService>();
    final email = auth.pendingEmail ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Center(
              child: SlideTransition(
                position: _entrySlide,
                child: FadeTransition(
                  opacity: _entryFade,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),

                        // ═══ أيقونة ═══
                        _buildIcon(isDark),

                        const SizedBox(height: 32),

                        // ═══ عنوان ═══
                        Text(
                          'تأكيد البريد الإلكتروني',
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'أدخل الرمز المكون من 6 أرقام المُرسل إلى',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // ═══ البريد ═══
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _gold.withOpacity(isDark ? 0.12 : 0.08),
                            border: Border.all(
                                color: _gold.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email_rounded,
                                  color: _gold, size: 18),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  email,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _gold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ═══ حقول OTP ═══
                        _buildOTPFields(isDark),

                        // ═══ خطأ ═══
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade300, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _error!,
                                  style: GoogleFonts.cairo(
                                    color: Colors.red.shade300,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // ═══ زر تأكيد ═══
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _verify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _gold,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                              _gold.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: _gold.withOpacity(0.4),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                                : Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                const Icon(
                                    Icons.verified_rounded,
                                    size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'تأكيد وإنشاء الحساب',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ═══ إعادة إرسال ═══
                        TextButton(
                          onPressed: _cooldown <= 0 ? _resend : null,
                          child: Text(
                            _cooldown <= 0
                                ? 'إعادة إرسال الرمز'
                                : 'إعادة الإرسال بعد $_cooldown ثانية',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: _cooldown <= 0
                                  ? _gold.withOpacity(0.85)
                                  : (isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey.shade400),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ═══ رجوع ═══
                        TextButton.icon(
                          onPressed: () =>
                              context.read<AuthService>().signOut(),
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 16,
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : Colors.grey.shade500,
                          ),
                          label: Text(
                            'العودة لتسجيل الدخول',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          '﴿ رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي ﴾',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            color: _gold.withOpacity(isDark ? 0.5 : 0.6),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(
        scale: _pulse.value,
        child: child,
      ),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isDark
                ? [const Color(0xFF1E2A4A), const Color(0xFF0F1628)]
                : [Colors.white, const Color(0xFFFFF8E8)],
          ),
          border: Border.all(color: _gold, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(isDark ? 0.35 : 0.2),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(Icons.mark_email_read_rounded,
            color: _gold, size: 48),
      ),
    );
  }

  Widget _buildOTPFields(bool isDark) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_otpLength, (i) {
          return Container(
            width: 46,
            height: 56,
            margin: EdgeInsets.only(
              left: 3,
              right: i == 2 ? 10 : 3,  // فراغ بين النصفين
            ),
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: _gold.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : _gold.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: _gold,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() => _error = null);
                if (value.isNotEmpty && i < _otpLength - 1) {
                  _focusNodes[i + 1].requestFocus();
                }
                if (value.isEmpty && i > 0) {
                  _focusNodes[i - 1].requestFocus();
                }
                if (_otpCode.length == _otpLength) {
                  _verify();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Future<void> _verify() async {
    final code = _otpCode;
    if (code.length != _otpLength) {
      setState(() => _error = 'أدخل الرمز كاملاً');
      return;
    }

    setState(() => _error = null);
    final result = await context.read<AuthService>().verifyOTP(code);

    if (!result.success && mounted) {
      setState(() => _error = result.error);
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resend() async {
    final success = await context.read<AuthService>().resendOTP();
    _startCooldown();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ تم إرسال رمز جديد'
                : '❌ فشل الإرسال',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor:
          success ? Colors.green.shade600 : Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}