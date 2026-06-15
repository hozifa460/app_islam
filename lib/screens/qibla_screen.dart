import 'dart:async';
import 'dart:math' show pi, sin, cos, atan2;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class QiblaScreen extends StatefulWidget {
  final Color? primaryColor;
  const QiblaScreen({super.key, this.primaryColor});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {

  static const _bgDark    = Color(0xFF0A0E17);
  static const _bgLight   = Color(0xFFF0F4FF);
  static const _gold      = Color(0xFFE6B325);
  static const _green     = Color(0xFF2ECC71);
  static const _darkGreen = Color(0xFF1A6B3A);
  static const _red       = Color(0xFFE74C3C);

  // â”€â”€ ط§ظ„ظƒط¹ط¨ط© ط§ظ„ظ…ط´ط±ظپط© â”€â”€
  static const _kaabeLat = 21.422487;
  static const _kaabeLng = 39.826206;

  // â”€â”€ ط§ظ„ط­ط§ظ„ط© â”€â”€
  double? _userLat;
  double? _userLng;
  bool    _loading        = true;
  bool    _hasPermissions = false;
  double  _qiblaAngle     = 0; // ط²ط§ظˆظٹط© ط§ظ„ظ‚ط¨ظ„ط© ظ…ظ† ط§ظ„ط´ظ…ط§ظ„
  double  _compassHeading = 0; // ط§طھط¬ط§ظ‡ ط§ظ„ظ‡ط§طھظپ ط§ظ„ط­ط§ظ„ظٹ

  StreamSubscription<CompassEvent>? _compassSub;

  // â”€â”€ ط£ظ†ظٹظ…ظٹط´ظ† â”€â”€
  late AnimationController _glowCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _successCtrl;
  late Animation<double>   _glowAnim;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _successAnim;

  bool _wasFacingQibla = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkPermissionsAndStart();
  }

  void _setupAnimations() {
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut),
    );
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _successAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„طµظ„ط§ط­ظٹط§طھ ظˆط§ظ„ظ…ظˆظ‚ط¹
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Future<void> _checkPermissionsAndStart() async {
    setState(() => _loading = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        if (!mounted) return;

        final angle = _calculateQiblaAngle(
          pos.latitude,
          pos.longitude,
        );

        setState(() {
          _hasPermissions = true;
          _userLat        = pos.latitude;
          _userLng        = pos.longitude;
          _qiblaAngle     = angle;
        });

        _startCompass();
      }
    } catch (e) {
      debugPrint('Error: $e');
    }

    if (mounted) setState(() => _loading = false);
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط­ط³ط§ط¨ ط²ط§ظˆظٹط© ط§ظ„ظ‚ط¨ظ„ط© ط±ظٹط§ط¶ظٹط§ظ‹
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  double _calculateQiblaAngle(double lat, double lng) {
    final lat1  = lat       * pi / 180;
    final lat2  = _kaabeLat * pi / 180;
    final dLng  = (_kaabeLng - lng) * pi / 180;

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) -
        sin(lat1) * cos(lat2) * cos(dLng);

    final angle = atan2(y, x) * 180 / pi;
    return (angle + 360) % 360;
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  طھط´ط؛ظٹظ„ ط§ظ„ط¨ظˆطµظ„ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      final heading = event.heading;
      if (heading == null) return;

      setState(() {
        _compassHeading = (heading + 360) % 360;
      });

      // ظپط­طµ ظ…ظˆط§ط¬ظ‡ط© ط§ظ„ظ‚ط¨ظ„ط©
      final isFacing = _isFacingQibla;
      if (isFacing && !_wasFacingQibla) {
        HapticFeedback.mediumImpact();
        _glowCtrl.forward();
        _successCtrl.forward(from: 0);
      } else if (!isFacing && _wasFacingQibla) {
        HapticFeedback.lightImpact();
        _glowCtrl.reverse();
      }
      _wasFacingQibla = isFacing;
    });
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط­ط³ط§ط¨ط§طھ ظ…ط³ط§ط¹ط¯ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  // âœ… ط²ط§ظˆظٹط© ط¯ظˆط±ط§ظ† ط§ظ„ط¥ط¨ط±ط© ظ†ط­ظˆ ط§ظ„ظ‚ط¨ظ„ط©
  double get _needleAngle {
    double angle = _qiblaAngle - _compassHeading;
    // ط£ظ‚طµط± ظ…ط³ط§ط± ظ„ظ„ط¯ظˆط±ط§ظ†
    while (angle > 180)  angle -= 360;
    while (angle < -180) angle += 360;
    return angle * pi / 180;
  }

  // âœ… ط²ط§ظˆظٹط© ط¯ظˆط±ط§ظ† ط§ظ„ظ‚ط±طµ ط¹ظƒط³ ط§ظ„ظ‡ط§طھظپ
  double get _dialAngle => -(_compassHeading * pi / 180);

  double get _deviation {
    double d = _qiblaAngle - _compassHeading;
    while (d > 180)  d -= 360;
    while (d < -180) d += 360;
    return d;
  }

  bool get _isFacingQibla => _deviation.abs() < 5.0;

  int get _accuracy {
    return ((1 - _deviation.abs().clamp(0, 180) / 180) * 100).round();
  }

  Color get _guidanceColor {
    final abs = _deviation.abs();
    if (abs < 5)  return _green;
    if (abs < 25) return const Color(0xFFF39C12);
    return _red;
  }

  String get _directionLabel {
    final d   = _deviation;
    final abs = d.abs();
    if (abs < 5)   return 'âœ“  ط§ظ„ظ‚ط¨ظ„ط© ط£ظ…ط§ظ…ظƒ ظ…ط¨ط§ط´ط±ط©';
    if (abs < 20)  return d > 0 ? 'ط¯ظˆظ‘ط± ظ‚ظ„ظٹظ„ط§ظ‹ ظ„ظ„ظٹط³ط§ط±'   : 'ط¯ظˆظ‘ط± ظ‚ظ„ظٹظ„ط§ظ‹ ظ„ظ„ظٹظ…ظٹظ†';
    if (abs < 60)  return d > 0 ? 'ط¯ظˆظ‘ط± ظ„ظ„ظٹط³ط§ط±'           : 'ط¯ظˆظ‘ط± ظ„ظ„ظٹظ…ظٹظ†';
    if (abs < 120) return d > 0 ? 'ط§ظ„ظ‚ط¨ظ„ط© ط¹ظ„ظ‰ ظٹط³ط§ط±ظƒ'      : 'ط§ظ„ظ‚ط¨ظ„ط© ط¹ظ„ظ‰ ظٹظ…ظٹظ†ظƒ';
    return 'ط§ظ„ظ‚ط¨ظ„ط© ط®ظ„ظپظƒطŒ ط§ط³طھط¯ط±';
  }

  IconData get _directionIcon {
    final d   = _deviation;
    final abs = d.abs();
    if (abs < 5)   return Icons.check_circle_rounded;
    if (abs < 20)  return d > 0 ? Icons.rotate_left         : Icons.rotate_right;
    if (abs < 120) return d > 0 ? Icons.arrow_back_rounded  : Icons.arrow_forward_rounded;
    return Icons.sync_rounded;
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  BUILD
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? _bgDark : _bgLight,
        body: _loading
            ? _buildLoading(isDark)
            : !_hasPermissions
            ? _buildPermissionScreen(isDark)
            : _buildMainUI(isDark, size),
      ),
    );
  }

  Widget _buildMainUI(bool isDark, Size size) {
    final compassSize = (size.width * 0.74).clamp(210.0, 310.0);
    final isFacing    = _isFacingQibla;
    final guidance    = _guidanceColor;
    final accuracy    = _accuracy;

    return Stack(
      fit: StackFit.expand,
      children: [
        // â”€â”€ ط®ظ„ظپظٹط© â”€â”€
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                isFacing
                    ? const Color(0xFF0D2016)
                    : const Color(0xFF0D1520),
                _bgDark,
              ]
                  : [
                isFacing
                    ? const Color(0xFFE8F8EF)
                    : const Color(0xFFEEF3FF),
                _bgLight,
              ],
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDark),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.015),
                      _buildGuidanceBanner(isDark, isFacing, guidance),
                      SizedBox(height: size.height * 0.018),
                      _buildCompassSection(
                          isDark, compassSize, isFacing, guidance),
                      SizedBox(height: size.height * 0.018),
                      _buildAccuracyBar(
                          isDark, accuracy, isFacing, guidance),
                      SizedBox(height: size.height * 0.015),
                      _buildInfoCards(isDark),
                      SizedBox(height: size.height * 0.015),
                      _buildHowToUse(isDark),
                      SizedBox(height: size.height * 0.015),
                      _buildCalibrationHint(isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // â”€â”€ AppBar â”€â”€
  Widget _buildAppBar(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : _gold.withValues(alpha: 0.25),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: textColor, size: 18),
              onPressed: () => Navigator.pop(context),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ط§طھط¬ط§ظ‡ ط§ظ„ظ‚ط¨ظ„ط©',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                if (_userLat != null)
                  Text(
                    'ط§ظ„ظ‚ط¨ظ„ط©: ${_qiblaAngle.toStringAsFixed(1)}آ° '
                        '| ظ‡ط§طھظپظƒ: ${_compassHeading.toStringAsFixed(1)}آ°',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: textColor.withValues(alpha: 0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.12),
              border: Border.all(color: _gold.withValues(alpha: 0.3)),
            ),
            child: const Icon(
                Icons.mosque_rounded, color: _gold, size: 20),
          ),
        ],
      ),
    );
  }

  // â”€â”€ ظ„ط§ظپطھط© ط§ظ„ط¥ط±ط´ط§ط¯ â”€â”€
  Widget _buildGuidanceBanner(
      bool isDark, bool isFacing, Color guidance) {
    return AnimatedBuilder(
      animation: _successCtrl,
      builder: (_, __) => Transform.scale(
        scale: isFacing ? _successAnim.value : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                guidance.withValues(alpha: isDark ? 0.22 : 0.10),
                guidance.withValues(alpha: isDark ? 0.06 : 0.03),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: guidance.withValues(alpha: 0.42), width: 2),
            boxShadow: [
              BoxShadow(
                color: guidance.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_directionIcon),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: guidance.withValues(alpha: 0.14),
                    border: Border.all(
                        color: guidance.withValues(alpha: 0.35)),
                  ),
                  child: Icon(_directionIcon,
                      color: guidance, size: 26),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        key: ValueKey(_directionLabel),
                        _directionLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: guidance,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isFacing
                          ? 'ظٹظ…ظƒظ†ظƒ ط§ظ„ط¢ظ† ط£ط¯ط§ط، ط§ظ„طµظ„ط§ط© ظپظٹ ظ‡ط°ط§ ط§ظ„ط§طھط¬ط§ظ‡'
                          : 'ظˆط¬ظ‘ظ‡ ظ‡ط§طھظپظƒ ط­طھظ‰ طھط´ظٹط± ط§ظ„ط¥ط¨ط±ط© ط§ظ„ط®ط¶ط±ط§ط، ظ„ظ„ط£ط¹ظ„ظ‰',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.58)
                            : Colors.black.withValues(alpha: 0.50),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ظ‚ط³ظ… ط§ظ„ط¨ظˆطµظ„ط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildCompassSection(
      bool isDark,
      double compassSize,
      bool isFacing,
      Color guidance,
      ) {
    return Column(
      children: [
        // طھط¹ظ„ظٹظ…ط©
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : _gold.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 13,
                  color: isDark ? Colors.white54 : Colors.black45),
              const SizedBox(width: 6),
              Text(
                'ط£ظ…ط³ظƒ ط§ظ„ظ‡ط§طھظپ ط£ظپظ‚ظٹط§ظ‹ ظˆط¯ظˆظ‘ط± ط­طھظ‰ طھط´ظٹط± ط§ظ„ط¥ط¨ط±ط© â–² ظ„ظ„ط£ط¹ظ„ظ‰',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color:
                  isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // â”€â”€ ط§ظ„ط¨ظˆطµظ„ط© â”€â”€
        AnimatedBuilder(
          animation:
          Listenable.merge([_pulseAnim, _glowAnim]),
          builder: (_, __) {
            return SizedBox(
              width: compassSize + 44,
              height: compassSize + 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // طھظˆظ‡ط¬ ط§ظ„ظ‚ط¨ظ„ط©
                  if (_glowAnim.value > 0)
                    Container(
                      width: compassSize + 34,
                      height: compassSize + 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _green.withValues(alpha: 
                                0.38 * _glowAnim.value),
                            blurRadius: 38,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                  // ط­ظ„ظ‚ط© ط®ط§ط±ط¬ظٹط© ظ…طھط­ط±ظƒط©
                  Transform.scale(
                    scale: isFacing ? _pulseAnim.value : 1.0,
                    child: Container(
                      width: compassSize + 14,
                      height: compassSize + 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            guidance.withValues(alpha: 0.85),
                            guidance.withValues(alpha: 0.08),
                            guidance.withValues(alpha: 0.85),
                            guidance.withValues(alpha: 0.08),
                            guidance.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // âœ… ط§ظ„ظ‚ط±طµ ظٹط¯ظˆط± ظ…ط¹ ط§ظ„ظ‡ط§طھظپ
                  Transform.rotate(
                    angle: _dialAngle,
                    child: _CompassDial(
                      size: compassSize,
                      isDark: isDark,
                      gold: _gold,
                    ),
                  ),

                  // âœ… ط§ظ„ط¥ط¨ط±ط© طھط´ظٹط± ظ„ظ„ظ‚ط¨ظ„ط© ط¯ط§ط¦ظ…ط§ظ‹
                  Transform.rotate(
                    angle: _needleAngle,
                    child: _buildNeedle(
                        compassSize * 0.50, isFacing),
                  ),

                  // ط§ظ„ظ…ط±ظƒط²
                  _buildCenterDot(isDark, isFacing),

                  // ظ…ط¤ط´ط± ظ‡ط§طھظپظƒ (ط«ط§ط¨طھ ط£ط¹ظ„ظ‰)
                  Positioned(
                    top: 0,
                    child: _buildPhoneIndicator(
                        isDark, isFacing),
                  ),

                  // ط³ظ‡ظ… ط§ظ„ط¯ظˆط±ط§ظ† (ط£ط³ظپظ„)
                  if (!isFacing)
                    Positioned(
                      bottom: 2,
                      child: _buildRotationHint(isDark),
                    ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // ط§ظ„ط§ظ†ط­ط±ط§ظپ
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            key: ValueKey(isFacing),
            isFacing
                ? 'ًں•‹  ط£ظ†طھ طھظˆط§ط¬ظ‡ ط§ظ„ظƒط¹ط¨ط© ط§ظ„ظ…ط´ط±ظپط©'
                : 'ط§ظ†ط­ط±ط§ظپ: ${_deviation.abs().toStringAsFixed(1)}آ°'
                ' ${_deviation > 0 ? "ظٹط³ط§ط±ط§ظ‹" : "ظٹظ…ظٹظ†ط§ظ‹"}',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isFacing
                  ? _green
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
          ),
        ),
      ],
    );
  }

  // â”€â”€ ط§ظ„ط¥ط¨ط±ط© â”€â”€
  Widget _buildNeedle(double height, bool isFacing) {
    final top    = isFacing ? _green : const Color(0xFF27AE60);
    final bottom = isFacing
        ? _green.withValues(alpha: 0.3)
        : Colors.grey.withValues(alpha: 0.38);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 26,
          height: height * 0.56,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              CustomPaint(
                size: Size(26, height * 0.56),
                painter:
                _TrianglePainter(color: top, pointUp: true),
              ),
              Positioned(
                top: 3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: top, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: top.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(Icons.mosque_rounded,
                      size: 10, color: top),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 26,
          height: height * 0.44,
          child: CustomPaint(
            painter:
            _TrianglePainter(color: bottom, pointUp: false),
          ),
        ),
      ],
    );
  }

  // â”€â”€ ط§ظ„ظ…ط±ظƒط² â”€â”€
  Widget _buildCenterDot(bool isDark, bool isFacing) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isFacing
              ? [_green, _darkGreen]
              : [
            isDark
                ? const Color(0xFF1E2D3A)
                : Colors.white,
            isDark
                ? const Color(0xFF0D1420)
                : const Color(0xFFEEF0F5),
          ],
        ),
        border: Border.all(
            color: isFacing ? _green : _gold, width: 2.5),
        boxShadow: [
          BoxShadow(
            color:
            (isFacing ? _green : _gold).withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.my_location_rounded,
        color: isFacing
            ? Colors.white
            : (isDark ? _gold : _darkGreen),
        size: 17,
      ),
    );
  }

  // â”€â”€ ظ…ط¤ط´ط± ط§ظ„ظ‡ط§طھظپ â”€â”€
  Widget _buildPhoneIndicator(bool isDark, bool isFacing) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isFacing
                ? _green.withValues(alpha: 0.13)
                : (isDark
                ? Colors.white.withValues(alpha: 0.09)
                : Colors.white.withValues(alpha: 0.95)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFacing
                  ? _green.withValues(alpha: 0.45)
                  : _gold.withValues(alpha: 0.32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFacing
                    ? Icons.check_circle_rounded
                    : Icons.smartphone_rounded,
                size: 12,
                color: isFacing ? _green : _gold,
              ),
              const SizedBox(width: 4),
              Text(
                isFacing ? 'ط§ظ„ظ‚ط¨ظ„ط© âœ“' : 'ظ…ظˆظ‚ط¹ظƒ',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isFacing
                      ? _green
                      : (isDark ? Colors.white70 : _darkGreen),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_drop_down_rounded,
          color: isFacing ? _green : _gold,
          size: 28,
        ),
      ],
    );
  }

  // â”€â”€ ط³ظ‡ظ… ط§ظ„ط¯ظˆط±ط§ظ† â”€â”€
  Widget _buildRotationHint(bool isDark) {
    final goLeft = _deviation > 0;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            goLeft
                ? Icons.arrow_back_ios_rounded
                : Icons.arrow_forward_ios_rounded,
            color: _gold,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            goLeft ? 'ط¯ظˆظ‘ط± ظ„ظ„ظٹط³ط§ط±' : 'ط¯ظˆظ‘ط± ظ„ظ„ظٹظ…ظٹظ†',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : _darkGreen,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            goLeft
                ? Icons.arrow_back_ios_rounded
                : Icons.arrow_forward_ios_rounded,
            color: _gold,
            size: 13,
          ),
        ],
      ),
    );
  }

  // â”€â”€ ط´ط±ظٹط· ط§ظ„ط¯ظ‚ط© â”€â”€
  Widget _buildAccuracyBar(
      bool isDark, int accuracy, bool isFacing, Color guidance) {
    final textColor =
    isDark ? Colors.white : const Color(0xFF1A1A2E);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : _gold.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: isDark ? 0.10 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.gps_fixed_rounded,
                      color: guidance, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'ط¯ظ‚ط© ط§ظ„ط§طھط¬ط§ظ‡',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ]),
                Text(
                  '$accuracy%',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: guidance,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: accuracy / 100,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.13),
                valueColor:
                AlwaysStoppedAnimation<Color>(guidance),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              accuracy >= 95
                  ? 'âœ“ ظ…ظ…طھط§ط² â€” ط£ظ†طھ طھظˆط§ط¬ظ‡ ط§ظ„ظ‚ط¨ظ„ط© ط¨ط¯ظ‚ط© ط¹ط§ظ„ظٹط©'
                  : accuracy >= 70
                  ? 'ظ‚ط±ظٹط¨ â€” ط§ط³طھظ…ط± ظپظٹ ط§ظ„ط¯ظˆط±ط§ظ† ظ‚ظ„ظٹظ„ط§ظ‹'
                  : accuracy >= 40
                  ? 'ظ…طھظˆط³ط· â€” ط¯ظˆظ‘ط± ظ†ط­ظˆ ط§ظ„ط¥ط¨ط±ط© ط§ظ„ط®ط¶ط±ط§ط،'
                  : 'ط¨ط¹ظٹط¯ â€” ط¯ظˆظ‘ط± ظ‡ط§طھظپظƒ ظ†ط­ظˆ ط§ظ„ط¥ط¨ط±ط© ط§ظ„ط®ط¶ط±ط§ط،',
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                color: textColor.withValues(alpha: 0.52),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ ط¨ط·ط§ظ‚ط§طھ ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ â”€â”€
  Widget _buildInfoCards(bool isDark) {
    final textColor =
    isDark ? Colors.white : const Color(0xFF1A1A2E);
    final cards = [
      (
      label: 'ط§ظ„ظ‚ط¨ظ„ط©\nظ…ظ† ط§ظ„ط´ظ…ط§ظ„',
      value: '${_qiblaAngle.toStringAsFixed(1)}آ°',
      icon: Icons.explore_rounded,
      color: _gold,
      ),
      (
      label: 'ط§طھط¬ط§ظ‡\nظ‡ط§طھظپظƒ',
      value: '${_compassHeading.toStringAsFixed(1)}آ°',
      icon: Icons.screen_rotation_rounded,
      color: const Color(0xFF3498DB),
      ),
      (
      label: 'ط§ظ„ط§ظ†ط­ط±ط§ظپ\nط¹ظ† ط§ظ„ظ‚ط¨ظ„ط©',
      value: '${_deviation.abs().toStringAsFixed(1)}آ°',
      icon: Icons.swap_horiz_rounded,
      color: _guidanceColor,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: cards.map((c) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                  vertical: 11, horizontal: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: c.color.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: isDark ? 0.10 : 0.04),
                    blurRadius: 7,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.color.withValues(alpha: 0.11),
                    ),
                    child: Icon(c.icon,
                        color: c.color, size: 17),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    child: Text(
                      c.value,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.label,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      color: textColor.withValues(alpha: 0.48),
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // â”€â”€ ظƒظٹظپ طھط³طھط®ط¯ظ… â”€â”€
  Widget _buildHowToUse(bool isDark) {
    final textColor =
    isDark ? Colors.white : const Color(0xFF1A1A2E);
    final steps = [
      (
      icon: Icons.phone_android_rounded,
      color: const Color(0xFF3498DB),
      title: 'ط£ظ…ط³ظƒ ط§ظ„ظ‡ط§طھظپ ط£ظپظ‚ظٹط§ظ‹',
      desc: 'ط¶ط¹ ط§ظ„ظ‡ط§طھظپ ظ…ظˆط§ط²ظٹط§ظ‹ ظ„ظ„ط£ط±ط¶ ظ„ظ„ط­طµظˆظ„ ط¹ظ„ظ‰ ط£ظپط¶ظ„ ط¯ظ‚ط©',
      ),
      (
      icon: Icons.rotate_right_rounded,
      color: _gold,
      title: 'ط¯ظˆظ‘ط± ط¬ط³ظ…ظƒ ط¨ط¨ط·ط،',
      desc:
      'ط§ط³طھط¯ط± ط¨ط¨ط·ط، ط­طھظ‰ طھط´ظٹط± ط§ظ„ط¥ط¨ط±ط© ط§ظ„ط®ط¶ط±ط§ط، â–² ظ„ظ„ط£ط¹ظ„ظ‰',
      ),
      (
      icon: Icons.check_circle_rounded,
      color: _green,
      title: 'ط§ظ„ط¯ظ‚ط© 95%+ = ط§ظ„ظ‚ط¨ظ„ط©',
      desc:
      'ط³طھط´ط¹ط± ط¨ط§ظ‡طھط²ط§ط² ط§ظ„ظ‡ط§طھظپ ط¹ظ†ط¯ ظ…ظˆط§ط¬ظ‡ط© ط§ظ„ظ‚ط¨ظ„ط© ط¨ط¯ظ‚ط©',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : _gold.withValues(alpha: 0.16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.help_outline_rounded,
                  color: _gold, size: 17),
              const SizedBox(width: 7),
              Text(
                'ظƒظٹظپ طھط³طھط®ط¯ظ… ط§ظ„ط¨ظˆطµظ„ط©طں',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ]),
            const SizedBox(height: 11),
            ...steps.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.color.withValues(alpha: 0.13),
                        border: Border.all(
                            color: s.color.withValues(alpha: 0.38)),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: s.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(s.title,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              )),
                          Text(s.desc,
                              style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                color: textColor
                                    .withValues(alpha: 0.52),
                                height: 1.4,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // â”€â”€ ظ…ط¹ط§ظٹط±ط© â”€â”€
  Widget _buildCalibrationHint(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.orange.withValues(alpha: 0.07)
              : Colors.orange.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(13),
          border:
          Border.all(color: Colors.orange.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 17),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'ط¥ط°ط§ ظƒط§ظ†طھ ط§ظ„ظ†طھظٹط¬ط© ط؛ظٹط± ط¯ظ‚ظٹظ‚ط©: ط­ط±ظ‘ظƒ ظ‡ط§طھظپظƒ ط¹ظ„ظ‰ ط´ظƒظ„ âˆ‍ '
                    'ط¹ط¯ط© ظ…ط±ط§طھطŒ ط«ظ… ط§ط¨طھط¹ط¯ ط¹ظ† ط§ظ„ط£ط¬ط³ط§ظ… ط§ظ„ظ…ط¹ط¯ظ†ظٹط© ظˆط§ظ„ظƒظ‡ط±ط¨ط§ط¦ظٹط©',
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  color: isDark
                      ? Colors.orange.shade200
                      : Colors.orange.shade800,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ طھط­ظ…ظٹظ„ â”€â”€
  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _gold, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'ط¬ط§ط±ظچ طھط­ط¯ظٹط¯ ظ…ظˆظ‚ط¹ظƒ...',
            style: GoogleFonts.cairo(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ ظ„ط§ ط¥ط°ظ† â”€â”€
  Widget _buildPermissionScreen(bool isDark) {
    final textColor =
    isDark ? Colors.white : const Color(0xFF1A1A2E);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.1),
                border: Border.all(color: _gold.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.location_off_rounded,
                  color: _gold, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              'ط§ظ„ظ…ظˆظ‚ط¹ ظ…ط·ظ„ظˆط¨',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ظٹظڈط±ط¬ظ‰ طھظپط¹ظٹظ„ ط®ط¯ظ…ط© ط§ظ„ظ…ظˆظ‚ط¹ ظ„طھط­ط¯ظٹط¯ ط§طھط¬ط§ظ‡ ط§ظ„ظ‚ط¨ظ„ط© ط¨ط¯ظ‚ط©',
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                color: textColor.withValues(alpha: 0.58),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 26, vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _checkPermissionsAndStart,
              icon: const Icon(Icons.location_on_rounded, size: 17),
              label: Text(
                'ط§ظ„ط³ظ…ط§ط­ ط¨ط§ظ„ظ…ظˆظ‚ط¹',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  ظ‚ط±طµ ط§ظ„ط¨ظˆطµظ„ط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _CompassDial extends StatelessWidget {
  final double size;
  final bool   isDark;
  final Color  gold;
  const _CompassDial(
      {required this.size, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _DialPainter(isDark: isDark, gold: gold),
    ),
  );
}

class _DialPainter extends CustomPainter {
  final bool  isDark;
  final Color gold;
  const _DialPainter({required this.isDark, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // ط®ظ„ظپظٹط©
    canvas.drawCircle(
      c, r,
      Paint()
        ..shader = RadialGradient(
          colors: isDark
              ? [const Color(0xFF1C2A3A), const Color(0xFF0D1420)]
              : [Colors.white, const Color(0xFFF2F2F8)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // ط­ظ„ظ‚ط§طھ
    canvas.drawCircle(c, r - 2,
        Paint()
          ..color = gold.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(c, r - 9,
        Paint()
          ..color = (isDark ? Colors.white : Colors.black)
              .withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // ط®ط·ظˆط· ط§ظ„ط¯ط±ط¬ط§طھ
    for (int i = 0; i < 360; i += 5) {
      final a   = i * pi / 180;
      final iM  = i % 90 == 0;
      final im  = i % 45 == 0;
      final i1  = i % 10 == 0;
      final len = iM ? r*0.15 : im ? r*0.11 : i1 ? r*0.07 : r*0.04;

      canvas.drawLine(
        Offset(c.dx + (r-10)*sin(a), c.dy - (r-10)*cos(a)),
        Offset(c.dx + (r-10-len)*sin(a), c.dy - (r-10-len)*cos(a)),
        Paint()
          ..color = i == 0
              ? Colors.red
              : iM ? gold
              : (isDark ? Colors.white : Colors.black)
              .withValues(alpha: im ? 0.5 : 0.18)
          ..strokeWidth = iM ? 2.5 : im ? 1.5 : 1.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // ط§ظ„ط­ط±ظˆظپ ط§ظ„ط§طھط¬ط§ظ‡ظٹط©
    for (final d in [
      (t: 'N',  a: 0.0,      c2: Colors.red,  fs: 21.0, b: true),
      (t: 'S',  a: pi,       c2: gold,         fs: 16.0, b: true),
      (t: 'E',  a: pi/2,     c2: gold,         fs: 16.0, b: true),
      (t: 'W',  a: -pi/2,    c2: gold,         fs: 16.0, b: true),
      (t: 'NE', a: pi/4,     c2: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.38), fs: 10.5, b: false),
      (t: 'SE', a: 3*pi/4,   c2: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.38), fs: 10.5, b: false),
      (t: 'SW', a: -3*pi/4,  c2: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.38), fs: 10.5, b: false),
      (t: 'NW', a: -pi/4,    c2: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.38), fs: 10.5, b: false),
    ]) {
      final p = Offset(
        c.dx + r * 0.72 * sin(d.a),
        c.dy - r * 0.72 * cos(d.a),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: d.t,
          style: TextStyle(
            fontSize: d.fs,
            fontWeight: d.b ? FontWeight.w900 : FontWeight.w600,
            color: d.c2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width/2, tp.height/2));
    }

    // ط¯ظˆط§ط¦ط± ط¯ط§ط®ظ„ظٹط©
    for (final rr in [r*0.44, r*0.27]) {
      canvas.drawCircle(c, rr,
          Paint()
            ..color = (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.04)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(_DialPainter o) => o.isDark != isDark;
}

// â”€â”€ ط±ط³ط§ظ… ط§ظ„ط¥ط¨ط±ط© â”€â”€
class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool  pointUp;
  const _TrianglePainter(
      {required this.color, required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointUp) {
      path.moveTo(size.width/2, 0);
      path.lineTo(size.width,   size.height);
      path.lineTo(0,            size.height);
    } else {
      path.moveTo(0,            0);
      path.lineTo(size.width,   0);
      path.lineTo(size.width/2, size.height);
    }
    path.close();

    canvas.drawPath(path,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
          ..color = color.withValues(alpha: 0.22));

    canvas.drawPath(path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withValues(alpha: 0.72),
              color,
              color.withValues(alpha: 0.72),
            ],
          ).createShader(
              Rect.fromLTWH(0, 0, size.width, size.height)));
  }

  @override
  bool shouldRepaint(_TrianglePainter o) =>
      o.color != color || o.pointUp != pointUp;
}