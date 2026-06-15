import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:islamic_app/screens/qibla/service/qibla_calculator.dart';
import 'package:islamic_app/screens/qibla/service/qibla_location_service.dart';
import 'widgets/qibla_theme.dart';
import 'widgets/qibla_app_bar.dart';
import 'widgets/qibla_guidance_banner.dart';
import 'widgets/qibla_compass_section.dart';
import 'widgets/qibla_accuracy_bar.dart';
import 'widgets/qibla_info_cards.dart';
import 'widgets/qibla_how_to_use.dart';
import 'widgets/qibla_calibration_hint.dart';
import 'widgets/qibla_loading.dart';
import 'widgets/qibla_permission_screen.dart';
import 'widgets/qibla_map_section.dart';

class QiblaScreen extends StatefulWidget {
  final Color? primaryColor;
  const QiblaScreen({super.key, this.primaryColor});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ط«ظˆط§ط¨طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  static const double _facingThreshold = 5.0;

  // â”€â”€â”€ EMA Filter â”€â”€â”€
  // alpha طµط؛ظٹط± = ط£ظ†ط¹ظ… ظ„ظƒظ† ط£ط¨ط·ط£ ط§ط³طھط¬ط§ط¨ط©
  // alpha ظƒط¨ظٹط± = ط£ط³ط±ط¹ ظ„ظƒظ† ط£ظƒط«ط± ط§ظ‡طھط²ط§ط²
  static const double _alphaCompass = 0.15;
  static const double _alphaGps     = 0.20;

  // â”€â”€â”€ GPS Heading: ظ†ط­طھط§ط¬ ط³ط±ط¹ط© > ظ‡ط°ط§ ظ„ظ†ط«ظ‚ ط¨ظ€ GPS heading â”€â”€â”€
  static const double _minSpeedForGpsHeading = 0.8; // m/s â‰ˆ 3 km/h

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // State
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  double? _userLat;
  double? _userLng;
  double  _locationAccuracyMeters = 999;
  bool    _loading                = true;
  bool    _hasPermissions         = false;
  bool    _locationServiceDisabled  = false;
  bool    _permissionDeniedForever  = false;

  double _qiblaAngle       = 0; // True bearing ط¥ظ„ظ‰ ط§ظ„ظƒط¹ط¨ط©
  double _distanceToKaaba  = 0;

  // â”€â”€â”€ Heading ط§ظ„ط­ط§ظ„ظٹ (True North) â”€â”€â”€
  double _displayHeading   = 0; // ظ…ط§ ظٹظڈط¹ط±ط¶ ظ„ظ„ظ…ط³طھط®ط¯ظ…
  double _compassHeading   = 0; // ظ…ظ† ط§ظ„ط¨ظˆطµظ„ط© (ط¨ط¹ط¯ WMM)
  double _gpsHeading       = 0; // ظ…ظ† GPS
  bool   _usingGpsHeading  = false; // ظ‡ظ„ ظ†ط³طھط®ط¯ظ… GPS headingطں

  // â”€â”€â”€ WMM Declination â”€â”€â”€
  double _declination      = 0;
  bool   _declinationReady = false;

  // â”€â”€â”€ ط­ط§ظ„ط© ط§ظ„ط­ط±ظƒط© â”€â”€â”€
  double _currentSpeed     = 0;
  bool   _isMoving         = false;

  // â”€â”€â”€ EMA state â”€â”€â”€
  double _emaSin = 0, _emaCos = 1;
  bool   _emaInit = false;

  // â”€â”€â”€ ظ…ط¹ط§ظٹط±ط© ط§ظ„ط¨ظˆطµظ„ط© â”€â”€â”€
  double _compassAccuracy  = -1;
  bool   _needsCalibration = false;

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Subscriptions
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<Position>?     _positionSub;

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Animations
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  late AnimationController _glowCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _successCtrl;
  late Animation<double>   _glowAnim;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _successAnim;
  late TabController       _tabController;

  bool      _wasFacingQibla = false;
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupAnimations();
    _checkPermissionsAndStart();
  }

  void _setupAnimations() {
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.04)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _successAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _positionSub?.cancel();
    _tabController.dispose();
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Permissions
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Future<void> _checkPermissionsAndStart() async {
    if (!mounted) return;
    setState(() {
      _loading                 = true;
      _locationServiceDisabled = false;
      _permissionDeniedForever = false;
      _hasPermissions          = false;
    });

    try {
      var status = await QiblaLocationService.checkStatus();
      if (status == QiblaLocationStatus.permissionDenied) {
        status = await QiblaLocationService.requestPermission();
      }

      switch (status) {
        case QiblaLocationStatus.serviceDisabled:
          if (mounted) setState(() {
            _locationServiceDisabled = true;
            _loading = false;
          });
          return;

        case QiblaLocationStatus.permissionDeniedForever:
          if (mounted) setState(() {
            _permissionDeniedForever = true;
            _loading = false;
          });
          return;

        case QiblaLocationStatus.permissionDenied:
          if (mounted) setState(() {
            _hasPermissions = false;
            _loading = false;
          });
          return;

        case QiblaLocationStatus.granted:
          break;
      }

      final pos = await QiblaLocationService.getAccuratePosition();
      if (pos != null && mounted) {
        await _updatePosition(pos);
        setState(() => _hasPermissions = true);
        _startCompass();
        _startLocationStream();
      } else {
        if (mounted) setState(() => _hasPermissions = false);
      }
    } catch (e) {
      debugPrint('Qibla Error: $e');
      if (mounted) setState(() => _hasPermissions = false);
    }

    if (mounted) setState(() => _loading = false);
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… طھط­ط¯ظٹط« ط§ظ„ظ…ظˆظ‚ط¹ - ط§ظ„ظ‚ظ„ط¨ ط§ظ„ط£ط³ط§ط³ظٹ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Future<void> _updatePosition(Position pos) async {
    // â”€â”€â”€ ط­ط³ط§ط¨ ط§طھط¬ط§ظ‡ ط§ظ„ظ‚ط¨ظ„ط© â”€â”€â”€
    final qibla   = QiblaCalculator.calculate(pos.latitude, pos.longitude);
    final dist    = QiblaCalculator.distanceToKaaba(pos.latitude, pos.longitude);
    final speed   = pos.speed < 0 ? 0.0 : pos.speed;
    final isMoving = speed > _minSpeedForGpsHeading;

    // â”€â”€â”€ GPS Heading â”€â”€â”€
    // GPS ظٹط¹ط·ظٹ True Bearing ظ„ظ„ط­ط±ظƒط© - ط¯ظ‚ظٹظ‚ 100% ط¨ط¯ظˆظ† ط¨ظˆطµظ„ط©
    double gpsH = _gpsHeading;
    bool usingGps = false;

    if (isMoving && pos.heading >= 0) {
      // GPS heading ظ…ظˆط«ظˆظ‚ ظپظ‚ط· ط¹ظ†ط¯ ط§ظ„ط³ط±ط¹ط© ط§ظ„ظƒط§ظپظٹط©
      gpsH = pos.heading; // ظ‡ط°ط§ True North ظ…ط¨ط§ط´ط±ط©
      usingGps = true;

      // EMA ط¹ظ„ظ‰ GPS heading
      final rad = gpsH * math.pi / 180.0;
      if (!_emaInit) {
        _emaSin = math.sin(rad);
        _emaCos = math.cos(rad);
        _emaInit = true;
      } else {
        _emaSin = (1 - _alphaGps) * _emaSin + _alphaGps * math.sin(rad);
        _emaCos = (1 - _alphaGps) * _emaCos + _alphaGps * math.cos(rad);
      }
      gpsH = (math.atan2(_emaSin, _emaCos) * 180 / math.pi + 360) % 360;
    }

    // â”€â”€â”€ WMM Declination (ظ…ط±ط© ظˆط§ط­ط¯ط© ط£ظˆ ط¹ظ†ط¯ طھط؛ظٹظٹط± ط§ظ„ظ…ظˆظ‚ط¹) â”€â”€â”€
    if (!_declinationReady ||
        _lastPosition == null ||
        Geolocator.distanceBetween(
          _lastPosition!.latitude, _lastPosition!.longitude,
          pos.latitude, pos.longitude,
        ) > 5000) {
      _declination     = _computeWMM(pos.latitude, pos.longitude);
      _declinationReady = true;
    }

    setState(() {
      _userLat                = pos.latitude;
      _userLng                = pos.longitude;
      _locationAccuracyMeters = pos.accuracy;
      _qiblaAngle             = qibla;
      _distanceToKaaba        = dist;
      _currentSpeed           = speed;
      _isMoving               = isMoving;
      _gpsHeading             = gpsH;
      _usingGpsHeading        = usingGps;
      _lastPosition           = pos;
    });

    _updateDisplayHeading();

    debugPrint('ًں“چ ${pos.latitude.toStringAsFixed(5)}, '
        '${pos.longitude.toStringAsFixed(5)} '
        '| ًں•‹ Qibla: ${qibla.toStringAsFixed(1)}آ° '
        '| ًں§² Dec: ${_declination.toStringAsFixed(1)}آ° '
        '| ًں“، GPS-H: ${pos.heading.toStringAsFixed(1)}آ° '
        '| ًںڑ¶ ${speed.toStringAsFixed(1)}m/s');
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… طھط­ط¯ظٹط¯ Heading ط§ظ„ظ…ط¹ط±ظˆط¶
  // ط§ظ„ط£ظˆظ„ظˆظٹط©: GPS (ط¹ظ†ط¯ ط§ظ„ط­ط±ظƒط©) > ط§ظ„ط¨ظˆطµظ„ط© (ط¹ظ†ط¯ ط§ظ„ظˆظ‚ظˆظپ)
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  void _updateDisplayHeading() {
    if (!mounted) return;

    double heading;
    if (_usingGpsHeading && _isMoving) {
      // âœ… GPS True Heading - ط§ظ„ط£ط¯ظ‚
      heading = _gpsHeading;
    } else {
      // âœ… ط§ظ„ط¨ظˆطµظ„ط© + WMM طھط¹ظˆظٹط¶
      heading = _compassHeading;
    }

    setState(() => _displayHeading = heading);
    _checkFacingQibla();
  }

  void _checkFacingQibla() {
    if (_isMoving) {
      _wasFacingQibla = false;
      return;
    }
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
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… ط§ظ„ط¨ظˆطµظ„ط© ظ…ط¹ WMM طھط¹ظˆظٹط¶
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      final raw = event.heading;
      if (raw == null) return;

      final accuracy = event.accuracy ?? -1.0;
      final magnetic = (raw + 360.0) % 360.0;

      // âœ… طھط­ظˆظٹظ„ Magnetic â†’ True North
      final trueH = (magnetic + _declination + 360.0) % 360.0;

      // âœ… EMA Filter
      final rad   = trueH * math.pi / 180.0;
      final alpha = _isMoving ? _alphaGps : _alphaCompass;

      if (!_emaInit) {
        _emaSin = math.sin(rad);
        _emaCos = math.cos(rad);
        _emaInit = true;
      } else {
        _emaSin = (1 - alpha) * _emaSin + alpha * math.sin(rad);
        _emaCos = (1 - alpha) * _emaCos + alpha * math.cos(rad);
      }

      final smoothed =
          (math.atan2(_emaSin, _emaCos) * 180 / math.pi + 360) % 360;

      setState(() {
        _compassHeading  = smoothed;
        _compassAccuracy = accuracy;
        _needsCalibration = accuracy < 0 || accuracy > 20;
      });

      // ط¹ظ†ط¯ ط§ظ„ظˆظ‚ظˆظپ: ط§ط³طھط®ط¯ظ… ط§ظ„ط¨ظˆطµظ„ط©
      if (!_usingGpsHeading) {
        setState(() => _displayHeading = smoothed);
        _checkFacingQibla();
      }
    });
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… GPS Stream
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  void _startLocationStream() {
    _positionSub?.cancel();
    _positionSub = QiblaLocationService.getPositionStream().listen(
          (pos) async {
        if (!mounted) return;
        await _updatePosition(pos);
      },
      onError: (e) => debugPrint('Location stream error: $e'),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… WMM2020 - ط­ط³ط§ط¨ ط§ظ„ط§ظ†ط­ط±ط§ظپ ط§ظ„ظ…ط؛ظ†ط§ط·ظٹط³ظٹ
  // ظ…ط¹ط§ظ…ظ„ط§طھ ط±ط³ظ…ظٹط© ظ…ظ† NOAA
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  double _computeWMM(double latDeg, double lngDeg) {
    // WMM2020 Coefficients (NOAA official, n=1..12)
    const g = [
      [0.0],
      [-29404.5, -1450.7],
      [-2500.0, 2982.0, 1676.8],
      [1363.9, -2381.0, 1236.2, 525.7],
      [903.1, 809.4, 86.2, -309.4, 47.9],
      [-234.4, 363.1, 187.8, -140.7, -151.2, 13.7],
      [65.9, 65.6, 73.0, -121.5, -36.2, 13.5, -64.7],
      [80.6, -76.8, -8.3, 56.5, 15.8, 6.4, -7.2, 9.8],
      [23.6, 9.8, -17.5, -0.4, -21.1, 15.3, 13.7, -16.5, -0.3],
      [5.0, 8.2, 2.9, -1.4, -1.1, -13.3, 1.1, 8.9, -9.3, -11.9],
      [-1.9, -6.2, -0.1, 1.7, -0.9, 0.6, -0.9, 1.9, 1.4, -2.4, -3.9],
      [3.0, -1.4, -2.5, 2.4, -0.9, 0.3, -0.7, -0.1, 1.4, -0.6, 0.2, 3.1],
      [-2.0, -0.1, 0.5, 1.3, -1.2, 0.7, 0.3, 0.5, -0.2, -0.5, 0.1, -1.1, -0.3],
    ];
    const h = [
      [0.0],
      [0.0, 4652.9],
      [0.0, -2991.6, -734.8],
      [0.0, -82.2, 241.8, -542.9],
      [0.0, 282.0, -158.4, 199.8, -350.1],
      [0.0, 47.7, 208.4, -121.3, 32.2, 99.1],
      [0.0, -19.1, 25.0, 52.7, -64.4, 9.0, 68.1],
      [0.0, -51.4, -16.8, 2.3, 23.5, -2.2, -27.2, -1.8],
      [0.0, 8.4, -15.3, 12.8, -11.8, 14.9, 3.6, -6.9, 2.8],
      [0.0, -23.3, 11.1, 9.8, -5.1, -6.2, 7.8, 0.4, -1.5, 9.7],
      [0.0, 3.4, -0.2, 3.5, 4.8, -8.6, -0.1, -4.2, -3.4, -0.1, -8.8],
      [0.0, 0.0, 2.6, -0.5, -0.4, 0.6, -0.2, -1.7, -1.6, -3.0, -2.0, -2.6],
      [0.0, -1.2, 0.5, 1.3, -1.8, 0.1, 0.7, -0.1, 0.6, 0.2, -0.9, 0.0, 0.5],
    ];
    const dg = [
      [0.0],
      [6.7, 7.7],
      [-11.5, -7.1, -2.2],
      [2.8, -6.2, 3.4, -12.2],
      [-1.1, -1.6, -6.0, 5.4, -5.5],
      [-0.3, 0.6, -0.7, 0.1, 1.2, 1.0],
      [-0.6, -0.6, 0.5, 1.4, -1.4, -0.0, 0.8],
      [-0.1, 0.2, -0.1, 0.5, 1.3, -1.2, 0.7, 0.3],
      [-0.3, -0.0, 0.5, -0.3, 0.4, 0.3, 0.1, -0.4, -0.4],
      [-0.0, 0.2, -0.1, -0.4, -0.3, 0.1, -0.1, -0.2, 0.2, -0.1],
      [0.0, -0.0, 0.0, -0.1, 0.1, -0.0, 0.1, 0.0, -0.1, 0.0, -0.1],
      [0.0, 0.0, 0.0, 0.0, -0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ];
    const dh = [
      [0.0],
      [0.0, -25.1],
      [0.0, -30.2, -23.9],
      [0.0, 5.7, -1.0, 1.1],
      [0.0, 0.2, 6.9, 3.7, -5.6],
      [0.0, 0.1, 2.5, -0.9, 3.0, 0.5],
      [0.0, 0.1, -1.8, -1.4, 0.9, 0.1, 1.0],
      [0.0, 0.5, 1.3, -0.2, 0.7, 0.1, -0.1, -0.7],
      [0.0, -0.3, 0.3, 0.3, 0.6, -0.4, 0.3, 0.2, -0.6],
      [0.0, -0.0, 0.1, -0.3, 0.0, -0.2, 0.3, 0.0, 0.0, -0.6],
      [0.0, 0.1, -0.1, 0.0, 0.0, 0.1, 0.0, 0.2, 0.0, -0.0, 0.1],
      [0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ];

    const nMax   = 12;
    const epoch  = 2020.0;
    const refR   = 6371.2;
    const a      = 6378.137;
    const f      = 1.0 / 298.257223563;
    const b      = a * (1.0 - f);

    // Decimal year
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end   = DateTime(now.year + 1, 1, 1);
    final dt    = now.year + now.difference(start).inDays /
        end.difference(start).inDays - epoch;

    final latR = latDeg * math.pi / 180.0;
    final lngR = lngDeg * math.pi / 180.0;

    // Geodetic â†’ Spherical
    final cosLat = math.cos(latR);
    final sinLat = math.sin(latR);
    final a2 = a * a, b2 = b * b;
    final rSurf = math.sqrt(
      (a2 * a2 * cosLat * cosLat + b2 * b2 * sinLat * sinLat) /
          (a2 * cosLat * cosLat + b2 * sinLat * sinLat),
    );
    final rr  = rSurf; // altitude = 0
    final r   = math.sqrt(rr * rr);
    final theta = math.acos(rr * sinLat / r); // colatitude
    final cosT = math.cos(theta);
    final sinT = math.sin(theta);

    // Schmidt ALFs
    final P  = List.generate(nMax + 2, (_) => List.filled(nMax + 2, 0.0));
    final dP = List.generate(nMax + 2, (_) => List.filled(nMax + 2, 0.0));
    P[0][0] = 1.0;
    P[1][0] = cosT; P[1][1] = sinT;
    dP[1][0] = -sinT; dP[1][1] = cosT;

    for (int n = 2; n <= nMax; n++) {
      for (int m = 0; m <= n; m++) {
        if (m == n) {
          final fac = math.sqrt((2.0 * n - 1.0) / (2.0 * n));
          P[n][n]  = sinT * P[n-1][n-1] * fac;
          dP[n][n] = (cosT * P[n-1][n-1] + sinT * dP[n-1][n-1]) * fac;
        } else if (n == m + 1 && n >= 1) {
          P[n][m]  = cosT * (2.0 * m + 1.0) * P[m][m];
          dP[n][m] = (2.0 * m + 1.0) *
              (cosT * dP[m][m] - sinT * P[m][m]);
        } else {
          final k1 = (2.0 * n - 1.0) / (n - m);
          final k2 = (n + m - 1.0) / (n - m);
          P[n][m]  = k1 * cosT * P[n-1][m] - k2 * P[n-2][m];
          dP[n][m] = k1 * (cosT * dP[n-1][m] - sinT * P[n-1][m]) -
              k2 * dP[n-2][m];
        }
      }
    }

    // Field components
    double bTheta = 0, bPhi = 0, bR = 0;
    double rPow = (refR / r) * (refR / r);

    for (int n = 1; n <= nMax; n++) {
      rPow *= (refR / r);
      for (int m = 0; m <= n; m++) {
        if (n >= g.length || m >= g[n].length) continue;
        final gv = g[n][m] + dg[n][m] * dt;
        final hv = m == 0 ? 0.0 : (h[n][m] + dh[n][m] * dt);
        final cosM = math.cos(m * lngR);
        final sinM = math.sin(m * lngR);
        final gcm  = gv * cosM + hv * sinM;
        final gsm  = gv * sinM - hv * cosM;

        bR     += (n + 1.0) * rPow * gcm * P[n][m];
        bTheta -= rPow * gcm * dP[n][m];
        if (sinT.abs() > 1e-10) {
          bPhi += rPow * m * (-gv * sinM + hv * cosM) * P[n][m] / sinT;
        }
      }
    }

    // Spherical â†’ Geodetic
    final diff   = theta - (math.pi / 2.0 - latR);
    final bx     = -bTheta * math.cos(diff) - bR * math.sin(diff);
    final by     = bPhi;

    return math.atan2(by, bx) * 180.0 / math.pi;
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Getters
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  double get _needleAngle {
    double diff = _qiblaAngle - _displayHeading;
    diff = ((diff + 180.0) % 360.0) - 180.0;
    return diff * math.pi / 180.0;
  }

  double get _dialAngle => -(_displayHeading * math.pi / 180.0);

  double get _deviation {
    double d = _qiblaAngle - _displayHeading;
    return ((d + 180.0) % 360.0) - 180.0;
  }

  bool get _isFacingQibla =>
      _deviation.abs() < _facingThreshold && !_isMoving;

  int get _accuracy =>
      ((1.0 - _deviation.abs().clamp(0.0, 180.0) / 180.0) * 100).round();

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Build
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;
    final theme  = QiblaTheme(isDark: isDark);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.bg,
        body: _loading
            ? QiblaLoading(isDark: isDark)
            : _locationServiceDisabled
            ? _buildLocationServiceDisabled(theme)
            : _permissionDeniedForever
            ? _buildPermissionDeniedForever(theme)
            : !_hasPermissions
            ? QiblaPermissionScreen(
          isDark: isDark,
          onRequestPermission: _checkPermissionsAndStart,
        )
            : _buildMainUI(theme, size),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // Main UI
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildMainUI(QiblaTheme theme, Size size) {
    final isFacing = _isFacingQibla;
    final guidance = QiblaTheme.getGuidanceColor(_deviation);

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.facingGradient(isFacing),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              QiblaAppBar(
                theme: theme,
                qiblaAngle: _qiblaAngle,
                compassHeading: _displayHeading,
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 6),
              _buildTabBar(theme),
              const SizedBox(height: 4),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCompassTab(theme, size, isFacing, guidance),
                    _buildMapTab(theme, size, isFacing),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompassTab(
      QiblaTheme theme, Size size, bool isFacing, Color guidance) {
    final compassSize = (size.width * QiblaTheme.compassSizeFactor)
        .clamp(QiblaTheme.compassMinSize, QiblaTheme.compassMaxSize);

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _glowAnim]),
      builder: (_, __) => CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // â”€â”€â”€ ط´ط±ظٹط· ط§ظ„ط­ط§ظ„ط© â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _buildStatusBar(theme),
                if (_needsCalibration) _buildCalibrationWarning(theme),
                SizedBox(height: size.height * 0.015),
                QiblaGuidanceBanner(
                  theme: theme,
                  isFacing: isFacing,
                  guidance: guidance,
                  deviation: _deviation,
                  successCtrl: _successCtrl,
                  successAnim: _successAnim,
                ),
                SizedBox(height: size.height * 0.018),
                QiblaCompassSection(
                  theme: theme,
                  compassSize: compassSize,
                  isFacing: isFacing,
                  guidance: guidance,
                  needleAngle: _needleAngle,
                  dialAngle: _dialAngle,
                  deviation: _deviation,
                  pulseAnim: _pulseAnim,
                  glowAnim: _glowAnim,
                ),
                SizedBox(height: size.height * 0.018),
                QiblaAccuracyBar(
                  theme: theme,
                  accuracy: _accuracy,
                  isFacing: isFacing,
                  guidance: guidance,
                ),
                SizedBox(height: size.height * 0.015),
                QiblaInfoCards(
                  theme: theme,
                  qiblaAngle: _qiblaAngle,
                  compassHeading: _displayHeading,
                  deviation: _deviation,
                  guidance: guidance,
                ),
                SizedBox(height: size.height * 0.015),
                QiblaHowToUse(theme: theme),
                SizedBox(height: size.height * 0.015),
                QiblaCalibrationHint(theme: theme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab(QiblaTheme theme, Size size, bool isFacing) {
    if (_userLat == null || _userLng == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_searching_rounded,
                size: 48,
                color: theme.isDark ? Colors.white38 : Colors.black26),
            const SizedBox(height: 12),
            Text('ط¬ط§ط±ظچ طھط­ط¯ظٹط¯ ظ…ظˆظ‚ط¹ظƒ...', style: theme.labelStyle(15)),
          ],
        ),
      );
    }
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildStatusBar(theme),
              const SizedBox(height: 12),
              QiblaMapSection(
                theme: theme,
                userLat: _userLat!,
                userLng: _userLng!,
                qiblaAngle: _qiblaAngle,
                distanceToKaaba: _distanceToKaaba,
                isFacing: isFacing,
                locationAccuracy: _locationAccuracyMeters,
                compassHeading: _displayHeading,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… ط´ط±ظٹط· ط§ظ„ط­ط§ظ„ط© - ظٹظˆط¶ط­ ظ…طµط¯ط± ط§ظ„ظ€ Heading
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildStatusBar(QiblaTheme theme) {
    final isGps = _usingGpsHeading && _isMoving;
    final color = isGps ? Colors.blue.shade400 : QiblaTheme.green;
    final icon  = isGps ? Icons.gps_fixed_rounded : Icons.explore_rounded;
    final label = isGps
        ? 'GPS آ· ${_currentSpeed.toStringAsFixed(1)} ظ…/ط« آ· ط¯ظ‚ظٹظ‚ ظ،ظ ظ ظھ'
        : 'ط¨ظˆطµظ„ط© آ· ط§ظ†ط­ط±ط§ظپ ${_declination.toStringAsFixed(1)}آ° ظ…ط¹ظˆط¶';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.boldStyle(12, color),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'آ±${_locationAccuracyMeters.toStringAsFixed(0)}ظ… GPS',
              style: theme.labelStyle(10).copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationWarning(QiblaTheme theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ط­ط±ظ‘ظƒ ط§ظ„ظ‡ط§طھظپ ط¹ظ„ظ‰ ط´ظƒظ„ ط±ظ‚ظ… 8 ظ„ظ…ط¹ط§ظٹط±ط© ط§ظ„ط¨ظˆطµظ„ط©',
              style: theme.labelStyle(12)
                  .copyWith(color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Tab Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildTabBar(QiblaTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: theme.isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : QiblaTheme.gold.withValues(alpha: 0.2),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: QiblaTheme.gold.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: QiblaTheme.gold.withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: QiblaTheme.gold,
          unselectedLabelColor:
          theme.isDark ? Colors.white54 : Colors.black45,
          labelStyle: theme.boldStyle(13, QiblaTheme.gold),
          unselectedLabelStyle: theme.labelStyle(13),
          padding: const EdgeInsets.all(4),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('ط§ظ„ط¨ظˆطµظ„ط©'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('ط§ظ„ط®ط±ظٹط·ط©'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€ Info Screens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildLocationServiceDisabled(QiblaTheme theme) =>
      _buildInfoScreen(
        theme: theme,
        icon: Icons.location_off_rounded,
        iconColor: Colors.orange,
        title: 'ط®ط¯ظ…ط© ط§ظ„ظ…ظˆظ‚ط¹ ظ…ط¹ط·ظ„ط©',
        subtitle: 'ظٹط±ط¬ظ‰ طھظپط¹ظٹظ„ GPS',
        buttonText: 'ظپطھط­ ط¥ط¹ط¯ط§ط¯ط§طھ ط§ظ„ظ…ظˆظ‚ط¹',
        onButton: QiblaLocationService.openLocationSettings,
        onRetry: _checkPermissionsAndStart,
      );

  Widget _buildPermissionDeniedForever(QiblaTheme theme) =>
      _buildInfoScreen(
        theme: theme,
        icon: Icons.lock_rounded,
        iconColor: Colors.red,
        title: 'ط§ظ„ط¥ط°ظ† ظ…ط±ظپظˆط¶',
        subtitle: 'ظٹط±ط¬ظ‰ طھظپط¹ظٹظ„ ط¥ط°ظ† ط§ظ„ظ…ظˆظ‚ط¹ ظ…ظ† ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ',
        buttonText: 'ظپطھط­ ط¥ط¹ط¯ط§ط¯ط§طھ ط§ظ„طھط·ط¨ظٹظ‚',
        onButton: QiblaLocationService.openAppSettings,
        onRetry: _checkPermissionsAndStart,
      );

  Widget _buildInfoScreen({
    required QiblaTheme theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onButton,
    required VoidCallback onRetry,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: theme.textColor),
              ),
            ),
            const Spacer(),
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: iconColor),
            ),
            const SizedBox(height: 28),
            Text(title,
                style: theme.titleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            Text(subtitle,
                style: theme.labelStyle(15).copyWith(height: 1.6),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: onButton,
                icon: const Icon(Icons.settings_rounded, size: 20),
                label: Text(buttonText,
                    style: theme.boldStyle(15, Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QiblaTheme.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(QiblaTheme.cardRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text('ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©',
                    style: theme.boldStyle(15, theme.textColor)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.textColor,
                  side: BorderSide(
                      color: theme.textColor.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(QiblaTheme.cardRadius),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}