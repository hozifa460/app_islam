import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller!.forward();

    // ✅ الانتقال بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_navigated) {
        _navigated = true;
        widget.onFinish(); // استدعاء الـ callback
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ كشف وضع الهاتف الحالي (داكن أو فاتح)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ تحديد الألوان بناءً على الوضع
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final iconBgColor = isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE6B325).withOpacity(0.15); // خلفية ذهبية خفيفة في الفاتح
    final fallbackIconColor = isDark ? Colors.white : const Color(0xFFE6B325);

    return Scaffold(
      backgroundColor: bgColor, // خلفية متكيفة
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(parent: _controller!, curve: Curves.easeOutBack),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor, // لون خلفية الأيقونة المتكيف
                ),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 150,
                  errorBuilder: (c, e, s) => Icon(Icons.mosque, size: 100, color: fallbackIconColor),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: _controller!, curve: Curves.easeIn),
              ),
              child: Column(
                children: [
                  Text(
                    'طريق الإسلام',
                    style: GoogleFonts.amiri(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor, // نص متكيف
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'رفيقك في العبادة اليومية',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: secondaryTextColor, // نص فرعي متكيف
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}