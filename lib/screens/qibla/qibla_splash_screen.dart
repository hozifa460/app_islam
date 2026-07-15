import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/qibla/qibla_screen.dart';
import 'package:islamic_app/screens/qibla/service/qibla_location_service.dart';

class QiblaSplashScreen extends StatefulWidget {
  const QiblaSplashScreen({super.key});

  @override
  State<QiblaSplashScreen> createState() => _QiblaSplashScreenState();
}

class _QiblaSplashScreenState extends State<QiblaSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _compassCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;

  late Animation<double> _compassRot;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String _statusText = '...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startLoadingProcess();
  }

  void _setupAnimations() {
    _compassCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _compassRot = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(CurvedAnimation(parent: _compassCtrl, curve: Curves.linear));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeCtrl.forward();
        _slideCtrl.forward();
      }
    });
  }

  Future<void> _startLoadingProcess() async {
    if (mounted) setState(() => _statusText = 'جارٍ التحقق من الأذونات...');
    await Future.delayed(const Duration(milliseconds: 1800));

    var status = await QiblaLocationService.checkStatus();
    if (status == QiblaLocationStatus.permissionDenied && mounted) {
      setState(() => _statusText = 'يرجى منح إذن الموقع...');
      status = await QiblaLocationService.requestPermission();
    }

    if (status != QiblaLocationStatus.granted) {
      _handlePermissionError(status);
      return;
    }

    if (mounted) setState(() => _statusText = 'جارٍ تحديد موقعك بدقة...');
    await Future.delayed(const Duration(milliseconds: 800));

    final position = await QiblaLocationService.getAccuratePosition();
    if (position == null) {
      _handleLocationError();
      return;
    }

    _navigateToQiblaScreen();
  }

  void _navigateToQiblaScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const QiblaScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _handlePermissionError(QiblaLocationStatus status) {
    String message;
    switch (status) {
      case QiblaLocationStatus.serviceDisabled:
        message = 'يرجى تفعيل خدمة الموقع (GPS) والمحاولة مرة أخرى.';
        break;
      case QiblaLocationStatus.permissionDeniedForever:
        message = 'تم رفض الإذن نهائياً. يرجى تفعيله من إعدادات التطبيق.';
        break;
      default:
        message = 'لم يتم منح إذن الموقع. لا يمكن تحديد القبلة.';
    }
    _showErrorAndExit(message);
  }

  void _handleLocationError() {
    _showErrorAndExit('لم نتمكن من تحديد موقعك. يرجى المحاولة مرة أخرى.');
  }

  void _showErrorAndExit(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _compassCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // âœ… طھط­ط¯ظٹط¯ ظ‡ظ„ ظ‡ظˆ ظˆط¶ط¹ ط¯ط§ظƒظ†
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // âœ… طھط­ط¯ظٹط¯ ط§ظ„ط£ظ„ظˆط§ظ† ط­ط³ط¨ ط§ظ„ظˆط¶ط¹
    final bgColorLight = const Color(0xFFF8FAFF);
    final bgColorDark = const Color(0xFF0A0E17);
    final primaryColorLight = const Color(0xFF4A6FA5);
    final primaryColorDark = const Color(0xFF6C96D4);

    final bgColors = isDark
        ? [bgColorDark, const Color(0xFF0F1521), bgColorDark]
        : [bgColorLight, Colors.white, const Color(0xFFF0F4FA)];

    final primaryColor = isDark ? primaryColorDark : primaryColorLight;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundDecorations(
                isDark, primaryColor, isDark ? bgColorDark : bgColorLight),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      _buildCompass(isDark),
                      const Spacer(flex: 2),
                      _buildTitle(primaryColor),
                      const SizedBox(height: 12),
                      _buildSubtitle(primaryColor),
                      const Spacer(flex: 3),
                      _buildStatusIndicator(primaryColor),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // âœ… ط§ظ„ظ€ widgets ظ…ط¹طھظ…ط¯ط© ط¹ظ„ظ‰ ط§ظ„ط£ظ„ظˆط§ظ†
  // =========================================================

  Widget _buildBackgroundDecorations(
      bool isDark, Color primaryColor, Color eraseColor) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _BackgroundPainter(
          isDark: isDark,
          primaryColor: primaryColor,
          eraseColor: eraseColor,
        ),
      ),
    );
  }

  Widget _buildCompass(bool isDark) {
    return AnimatedBuilder(
      animation: _compassRot,
      builder: (_, __) {
        return Transform.rotate(
          angle: _compassRot.value,
          child: SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: _CompassPainter(isDark: isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(Color primaryColor) {
    return Text(
      'Qibla Direction',
      style: GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            color: primaryColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'Locate Qibla Direction by using\nthe Qibla Finder',
        textAlign: TextAlign.center,
        style: GoogleFonts.playfairDisplay(
          fontSize: 15,
          color: primaryColor.withValues(alpha: 0.75),
          height: 1.6,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              _statusText,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: primaryColor.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// âœ… ط±ط³ط§ظ… ط§ظ„ط®ظ„ظپظٹط© ظ…ط¹ ط¯ط¹ظ… ط§ظ„ظˆط¶ط¹ ط§ظ„ط¯ط§ظƒظ†
// =========================================================
class _BackgroundPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;
  final Color eraseColor;

  _BackgroundPainter({
    required this.isDark,
    required this.primaryColor,
    required this.eraseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final decorOpacity = isDark ? 0.15 : 0.12;

    _drawLantern(canvas, size, size.width * 0.12, size.height * 0.08, 0.7, decorOpacity);
    _drawLantern(canvas, size, size.width * 0.88, size.height * 0.12, 0.5, decorOpacity);
    _drawLantern(canvas, size, size.width * 0.25, size.height * 0.04, 0.4, decorOpacity);

    _drawStar(canvas, size, size.width * 0.08, size.height * 0.18, 12, decorOpacity);
    _drawStar(canvas, size, size.width * 0.92, size.height * 0.22, 10, decorOpacity * 0.8);
    _drawStar(canvas, size, size.width * 0.18, size.height * 0.12, 8, decorOpacity * 0.7);
    _drawStar(canvas, size, size.width * 0.82, size.height * 0.06, 14, decorOpacity * 1.2);
    _drawStar(canvas, size, size.width * 0.75, size.height * 0.18, 9, decorOpacity * 0.75);

    _drawMoon(canvas, size, size.width * 0.82, size.height * 0.08, decorOpacity);
  }

  void _drawLantern(Canvas canvas, Size size, double x, double y, double scale, double opacity) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: opacity * scale)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: opacity * scale * 0.8)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(x, y - 20), Offset(x, y), linePaint);
    final bodyPath = Path()
      ..moveTo(x - 8, y)
      ..lineTo(x - 10, y + 8)..lineTo(x - 6, y + 22)..lineTo(x + 6, y + 22)..lineTo(x + 10, y + 8)..lineTo(x + 8, y)..close();
    canvas.drawPath(bodyPath, paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x, y + 24), width: 14, height: 4), paint);
    final domePath = Path()..moveTo(x - 8, y)..quadraticBezierTo(x, y - 8, x + 8, y)..close();
    canvas.drawPath(domePath, paint);
  }

  void _drawStar(Canvas canvas, Size size, double x, double y, double r, double opacity) {
    final paint = Paint()..color = primaryColor.withValues(alpha: opacity)..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final outerX = x + r * math.cos(angle);
      final outerY = y + r * math.sin(angle);
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;
      final innerX = x + r * 0.4 * math.cos(innerAngle);
      final innerY = y + r * 0.4 * math.sin(innerAngle);
      if (i == 0) path.moveTo(outerX, outerY);
      path.lineTo(outerX, outerY);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMoon(Canvas canvas, Size size, double x, double y, double opacity) {
    final paint = Paint()..color = primaryColor.withValues(alpha: opacity)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 28, paint);
    final erasePaint = Paint()..color = eraseColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x + 8, y - 2), 22, erasePaint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.isDark != isDark || old.primaryColor != primaryColor;
}

// =========================================================
// âœ… ط±ط³ط§ظ… ط§ظ„ط¨ظˆطµظ„ط© ظ…ط¹ ط¯ط¹ظ… ط§ظ„ظˆط¶ط¹ ط§ظ„ط¯ط§ظƒظ†
// =========================================================
class _CompassPainter extends CustomPainter {
  final bool isDark;

  _CompassPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final primaryColor = isDark ? const Color(0xFF6C96D4) : const Color(0xFF4A6FA5);
    final textColor = isDark ? Colors.white70 : const Color(0xFF4A6FA5);

    // ط§ظ„ط¯ظˆط§ط¦ط± ط§ظ„ط®ط§ط±ط¬ظٹط©
    canvas.drawCircle(center, radius - 5, Paint()..color = primaryColor.withValues(alpha: 0.15)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(center, radius - 15, Paint()..color = primaryColor.withValues(alpha: 0.08)..style = PaintingStyle.stroke..strokeWidth = 1);

    // ط§ظ„ط¯ط±ط¬ط§طھ
    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMain = i % 90 == 0;
      final isMid = i % 45 == 0;
      final len = isMain ? 18.0 : isMid ? 12.0 : i % 10 == 0 ? 8.0 : 5.0;
      final outerR = radius - 8;
      final innerR = outerR - len;
      canvas.drawLine(
        Offset(center.dx + outerR * math.sin(angle), center.dy - outerR * math.cos(angle)),
        Offset(center.dx + innerR * math.sin(angle), center.dy - innerR * math.cos(angle)),
        Paint()
          ..color = i == 0 ? const Color(0xFFE74C3C) : isMain ? primaryColor : textColor.withValues(alpha: isMid ? 0.5 : 0.25)
          ..strokeWidth = isMain ? 2.5 : isMid ? 1.5 : 0.8
          ..strokeCap = StrokeCap.round,
      );
    }

    // ط§ظ„ط£ط´ط±ط·ط©
    _drawLargeNeedle(canvas, center, radius, 0, const Color(0xFFE74C3C));
    _drawLargeNeedle(canvas, center, radius, math.pi, primaryColor);
    _drawLargeNeedle(canvas, center, radius, math.pi / 2, primaryColor);
    _drawLargeNeedle(canvas, center, radius, -math.pi / 2, primaryColor);

    // ط§ظ„ط¥ط¨ط±ط©
    _drawMainNeedle(canvas, center, radius);

    // ط§ظ„ظ…ط±ظƒط²
    canvas.drawCircle(center, 12, Paint()..color = isDark ? const Color(0xFF0F1521) : Colors.white);
    canvas.drawCircle(center, 12, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 2.5);
    canvas.drawCircle(center, 5, Paint()..color = primaryColor);

    // ط§ظ„ط­ط±ظˆظپ
    _drawLetter(canvas, center, radius, 'N', 0, const Color(0xFFE74C3C), 18);
    _drawLetter(canvas, center, radius, 'S', math.pi, textColor, 16);
    _drawLetter(canvas, center, radius, 'E', math.pi / 2, textColor, 16);
    _drawLetter(canvas, center, radius, 'W', -math.pi / 2, textColor, 16);
  }

  void _drawLargeNeedle(Canvas canvas, Offset center, double radius, double angle, Color color) {
    final outerR = radius * 0.45;
    final innerR = radius * 0.15;
    final path = Path();
    final outerTop = Offset(center.dx + outerR * math.sin(angle), center.dy - outerR * math.cos(angle));
    final left = Offset(center.dx + innerR * math.sin(angle + 0.15), center.dy - innerR * math.cos(angle + 0.15));
    final right = Offset(center.dx + innerR * math.sin(angle - 0.15), center.dy - innerR * math.cos(angle - 0.15));
    path.moveTo(outerTop.dx, outerTop.dy);
    path.lineTo(left.dx, left.dy);
    path.lineTo(right.dx, right.dy);
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.08)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(path, Paint()..shader = LinearGradient(colors: [color.withValues(alpha: 0.8), color, color.withValues(alpha: 0.8)]).createShader(Rect.fromPoints(outerTop, left.dy > right.dy ? left : right)));
  }

  void _drawMainNeedle(Canvas canvas, Offset center, double radius) {
    final needleLength = radius * 0.55;
    final tailLength = radius * 0.40;
    final width = 16.0;

    final northPath = Path()..moveTo(center.dx, center.dy - needleLength)..lineTo(center.dx - width / 2, center.dy)..lineTo(center.dx + width / 2, center.dy)..close();
    canvas.drawPath(northPath, Paint()..color = Colors.black.withValues(alpha: 0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawPath(northPath, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A2A3A), Color(0xFF2C3E50), Color(0xFF1A2A3A)]).createShader(Rect.fromLTWH(center.dx - width / 2, center.dy - needleLength, width, needleLength)));

    final southPath = Path()..moveTo(center.dx, center.dy + tailLength)..lineTo(center.dx - width / 2, center.dy)..lineTo(center.dx + width / 2, center.dy)..close();
    canvas.drawPath(southPath, Paint()..color = Colors.black.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(southPath, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFC0392B), Color(0xFFE74C3C), Color(0xFFC0392B)]).createShader(Rect.fromLTWH(center.dx - width / 2, center.dy, width, tailLength)));
  }

  void _drawLetter(Canvas canvas, Offset center, double radius, String letter, double angle, Color color, double fontSize) {
    final dist = radius * 0.78;
    final pos = Offset(center.dx + dist * math.sin(angle), center.dy - dist * math.cos(angle));
    final tp = TextPainter(text: TextSpan(text: letter, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: color)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.isDark != isDark;
}