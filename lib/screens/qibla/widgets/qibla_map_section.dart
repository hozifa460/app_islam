import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

import '../service/qibla_calculator.dart';
import 'qibla_theme.dart';
import 'qibla_needle.dart';

class QiblaMapSection extends StatefulWidget {
  final QiblaTheme theme;
  final double userLat;
  final double userLng;
  final double qiblaAngle;
  final double distanceToKaaba;
  final bool isFacing;
  final double locationAccuracy;
  final double compassHeading;

  const QiblaMapSection({
    super.key,
    required this.theme,
    required this.userLat,
    required this.userLng,
    required this.qiblaAngle,
    required this.distanceToKaaba,
    required this.isFacing,
    required this.locationAccuracy,
    required this.compassHeading,
  });

  @override
  State<QiblaMapSection> createState() => _QiblaMapSectionState();
}

class _QiblaMapSectionState extends State<QiblaMapSection>
    with TickerProviderStateMixin {
  late MapController _mapController;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const LatLng _kaabaPosition = LatLng(
    QiblaCalculator.kaabeLat,
    QiblaCalculator.kaabeLng,
  );

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(QiblaMapSection old) {
    super.didUpdateWidget(old);
    if ((old.compassHeading - widget.compassHeading).abs() > 0.3) {
      _rotateMap();
    }
  }

  void _rotateMap() {
    try {
      _mapController.rotate(-widget.compassHeading);
    } catch (_) {}
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  LatLng get _userPosition => LatLng(widget.userLat, widget.userLng);

  double get _qiblaDeviation {
    double d = widget.qiblaAngle - widget.compassHeading;
    return ((d + 180.0) % 360.0) - 180.0;
  }

  // ✅ زاوية الإبرة = اتجاه القبلة الحقيقي بالراديان
  // لأن الخريطة تدور مع الهاتف، نستخدم الزاوية المطلقة للقبلة
  double get _needleAngleOnMap {
    return widget.qiblaAngle * math.pi / 180.0;
  }

  double _calculateZoom() {
    final dist = widget.distanceToKaaba;
    if (dist < 1) return 15.0;
    if (dist < 10) return 12.0;
    if (dist < 100) return 9.0;
    if (dist < 500) return 6.5;
    if (dist < 2000) return 4.5;
    return 3.0;
  }

  String _getCardinalDirection(double angle) {
    const dirs = [
      'شمال', 'ش.ش.غ', 'شمال غرب', 'غ.ش.غ',
      'غرب', 'غ.ج.غ', 'جنوب غرب', 'ج.ج.غ',
      'جنوب', 'ج.ج.ش', 'جنوب شرق', 'ش.ج.ش',
      'شرق', 'ش.ش.غ', 'شمال شرق', 'غ.ش.غ',
    ];
    return dirs[((angle + 11.25) / 22.5).floor() % 16];
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final size = MediaQuery.of(context).size;
    final mapHeight = (size.height * 0.44).clamp(250.0, 400.0);
    final guidance = QiblaTheme.getGuidanceColor(_qiblaDeviation);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(theme, guidance),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: theme.cardBg,
              borderRadius: BorderRadius.circular(QiblaTheme.cardRadius),
              border: Border.all(color: theme.cardBorder),
              boxShadow: theme.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(theme),

                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: mapHeight,
                    child: Stack(
                      children: [
                        // ✅ FlutterMap يحتوي على كل العناصر الجغرافية
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _userPosition,
                            initialZoom: _calculateZoom(),
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.pinchZoom |
                              InteractiveFlag.drag |
                              InteractiveFlag.doubleTapZoom,
                            ),
                          ),
                          children: [
                            // طبقة الخريطة
                            TileLayer(
                              urlTemplate: theme.isDark
                                  ? 'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png'
                                  : 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                              subdomains: const ['a', 'b', 'c', 'd'],
                              userAgentPackageName: 'com.islamicapp.qibla',
                              maxZoom: 19,
                            ),

                            // طبقة labels
                            TileLayer(
                              urlTemplate: theme.isDark
                                  ? 'https://{s}.basemaps.cartocdn.com/dark_only_labels/{z}/{x}/{y}{r}.png'
                                  : 'https://{s}.basemaps.cartocdn.com/light_only_labels/{z}/{x}/{y}{r}.png',
                              subdomains: const ['a', 'b', 'c', 'd'],
                              userAgentPackageName: 'com.islamicapp.qibla',
                              maxZoom: 19,
                            ),

                            // ✅ دائرة دقة الموقع داخل FlutterMap
                            // تبقى مع موقع المستخدم الجغرافي دائماً
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: _userPosition,
                                  radius: widget.locationAccuracy
                                      .clamp(10.0, 200.0),
                                  useRadiusInMeter: true,
                                  color: (widget.isFacing
                                      ? QiblaTheme.green
                                      : QiblaTheme.blue)
                                      .withOpacity(0.07),
                                  borderColor: (widget.isFacing
                                      ? QiblaTheme.green
                                      : QiblaTheme.blue)
                                      .withOpacity(0.25),
                                  borderStrokeWidth: 1.2,
                                ),
                              ],
                            ),

                            // خط القبلة
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: [_userPosition, _kaabaPosition],
                                  strokeWidth: 2.0,
                                  color: QiblaTheme.gold.withOpacity(0.65),
                                  isDotted: true,
                                ),
                              ],
                            ),

                            // ✅ MarkerLayer يحتوي علامة المستخدم والكعبة
                            // كلاهما مرتبط بالإحداثيات الجغرافية
                            // لكن rotate: false يمنع دوران المحتوى مع الخريطة
                            MarkerLayer(
                              rotate: true,
                              markers: [
                                // ✅ علامة المستخدم - rotate:true تعني
                                // أن الـ widget لا يدور مع الخريطة
                                Marker(
                                  point: _userPosition,
                                  width: 90,
                                  height: 90,
                                  child: AnimatedBuilder(
                                    animation: _pulseAnim,
                                    builder: (_, __) =>
                                        _buildUserMarker(),
                                  ),
                                ),

                                // علامة الكعبة
                                Marker(
                                  point: _kaabaPosition,
                                  width: 52,
                                  height: 64,
                                  child: _buildKaabaMarker(),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // مؤشر الشمال
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _buildNorthIndicator(theme),
                        ),

                        // شريط الحالة
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildMapStatusBar(theme, guidance),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildControlButtons(theme),
              ],
            ),
          ),

          const SizedBox(height: 10),
          _buildLegend(theme),
        ],
      ),
    );
  }

  // =========================================================
  // ✅ علامة المستخدم داخل MarkerLayer
  // rotate: true في MarkerLayer يعني الـ widget لا يدور مع الخريطة
  // لكن موقعه الجغرافي يبقى ثابتاً
  // =========================================================
  Widget _buildUserMarker() {
    // ✅ الإبرة تشير للقبلة بالزاوية المطلقة
    // لأن rotate:true يُلغي دوران الخريطة على الـ marker
    // نحتاج إضافة دوران الخريطة لتصحيح اتجاه الإبرة
    final correctedAngle = _needleAngleOnMap +
        (-widget.compassHeading * math.pi / 180.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // حلقة نبض عند المواجهة
        if (widget.isFacing)
          Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QiblaTheme.green.withOpacity(0.1),
                border: Border.all(
                  color: QiblaTheme.green.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          ),

        // ✅ الإبرة تدور بالزاوية الصحيحة
        Transform.rotate(
          angle: correctedAngle,
          child: _MapNeedle(
            isFacing: widget.isFacing,
            size: 54,
          ),
        ),

        // نقطة الموقع المركزية
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: widget.isFacing
                  ? [QiblaTheme.green, QiblaTheme.darkGreen]
                  : [QiblaTheme.blue, const Color(0xFF1A5276)],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: (widget.isFacing
                    ? QiblaTheme.green
                    : QiblaTheme.blue)
                    .withOpacity(0.55),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Kaaba Marker
  // =========================================================
  Widget _buildKaabaMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [QiblaTheme.gold, Color(0xFFB8860B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: QiblaTheme.gold.withOpacity(0.55),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Text('🕋', style: TextStyle(fontSize: 22)),
        ),
        Container(
          width: 2.5,
          height: 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                QiblaTheme.gold,
                QiblaTheme.gold.withOpacity(0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // مؤشر الشمال
  // =========================================================
  Widget _buildNorthIndicator(QiblaTheme theme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: theme.isDark
            ? Colors.black.withOpacity(0.65)
            : Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'N',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.red,
              height: 1,
            ),
          ),
          const Text(
            '↑',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red,
              height: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // شريط الحالة
  // =========================================================
  Widget _buildMapStatusBar(QiblaTheme theme, Color guidance) {
    final deviation = _qiblaDeviation;
    final label = QiblaTheme.getDirectionLabel(deviation);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.isDark
            ? Colors.black.withOpacity(0.72)
            : Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: guidance.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(QiblaTheme.getDirectionIcon(deviation),
              color: guidance, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: theme.boldStyle(12, guidance),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!widget.isFacing) ...[
            const SizedBox(width: 6),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: guidance.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${deviation.abs().toStringAsFixed(1)}°',
                style: theme.boldStyle(11, guidance),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // Header
  // =========================================================
  Widget _buildHeader(QiblaTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: QiblaTheme.gold.withOpacity(0.13),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.map_rounded,
                color: QiblaTheme.gold, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خريطة القبلة',
                    style: theme.boldStyle(14, theme.textColor)),
                Text(
                  'الخريطة والإبرة تدوران مع الهاتف',
                  style: theme.labelStyle(10),
                ),
              ],
            ),
          ),
          _buildAccuracyBadge(theme),
        ],
      ),
    );
  }

  // =========================================================
  // بطاقات المعلومات
  // =========================================================
  Widget _buildInfoRow(QiblaTheme theme, Color guidance) {
    return Row(
      children: [
        _buildInfoCard(
          theme: theme,
          icon: Icons.straighten_rounded,
          label: 'المسافة',
          value: QiblaCalculator.formatDistance(widget.distanceToKaaba),
          color: QiblaTheme.blue,
        ),
        const SizedBox(width: 8),
        _buildInfoCard(
          theme: theme,
          icon: Icons.explore_rounded,
          label: 'الاتجاه',
          value:
          '${widget.qiblaAngle.toStringAsFixed(1)}° ${_getCardinalDirection(widget.qiblaAngle)}',
          color: QiblaTheme.gold,
        ),
        const SizedBox(width: 8),
        _buildInfoCard(
          theme: theme,
          icon: widget.isFacing
              ? Icons.check_circle_rounded
              : Icons.adjust_rounded,
          label: 'الحالة',
          value: widget.isFacing
              ? 'مواجه ✓'
              : '${_qiblaDeviation.abs().toStringAsFixed(1)}° انحراف',
          color: widget.isFacing ? QiblaTheme.green : QiblaTheme.red,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required QiblaTheme theme,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.boldStyle(12, color),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: theme.labelStyle(9),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // أزرار التحكم
  // =========================================================
  Widget _buildControlButtons(QiblaTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: _buildMapButton(
              theme: theme,
              icon: Icons.my_location_rounded,
              label: 'موقعي',
              onTap: () =>
                  _mapController.move(_userPosition, _calculateZoom()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMapButton(
              theme: theme,
              icon: Icons.zoom_out_map_rounded,
              label: 'المسار الكامل',
              onTap: () {
                final midLat =
                    (widget.userLat + QiblaCalculator.kaabeLat) / 2;
                final midLng =
                    (widget.userLng + QiblaCalculator.kaabeLng) / 2;
                _mapController.move(LatLng(midLat, midLng), 3.0);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMapButton(
              theme: theme,
              icon: Icons.location_on_rounded,
              label: 'الكعبة',
              onTap: () => _mapController.move(_kaabaPosition, 14.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required QiblaTheme theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: theme.isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: QiblaTheme.gold),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: theme.boldStyle(11, theme.textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // Badge الدقة
  // =========================================================
  Widget _buildAccuracyBadge(QiblaTheme theme) {
    final acc = widget.locationAccuracy;
    final isGood = acc <= 20;
    final isMed = acc <= 60;
    final color = isGood
        ? QiblaTheme.green
        : isMed
        ? QiblaTheme.orange
        : QiblaTheme.red;
    final label = isGood ? 'GPS دقيق' : isMed ? 'متوسط' : 'ضعيف';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: theme.boldStyle(9, color)),
        ],
      ),
    );
  }

  // =========================================================
  // مفتاح الخريطة
  // =========================================================
  Widget _buildLegend(QiblaTheme theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 4,
      children: [
        _legendItem(theme, '🕋', null, 'الكعبة المشرفة'),
        _legendItem(theme, null, Icons.circle, 'موقعك الحالي',
            color: QiblaTheme.blue),
        _legendItem(theme, null, Icons.navigation_rounded, 'اتجاه القبلة',
            color: QiblaTheme.gold),
      ],
    );
  }

  Widget _legendItem(
      QiblaTheme theme,
      String? emoji,
      IconData? icon,
      String label, {
        Color? color,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emoji != null)
          Text(emoji, style: const TextStyle(fontSize: 11))
        else
          Icon(icon!, color: color, size: 11),
        const SizedBox(width: 3),
        Text(label, style: theme.labelStyle(10)),
      ],
    );
  }
}

// =========================================================
// إبرة الخريطة المصغرة
// =========================================================
class _MapNeedle extends StatelessWidget {
  final bool isFacing;
  final double size;

  const _MapNeedle({required this.isFacing, required this.size});

  @override
  Widget build(BuildContext context) {
    final topColor = isFacing ? QiblaTheme.green : const Color(0xFF27AE60);
    final bottomColor = isFacing
        ? QiblaTheme.green.withOpacity(0.28)
        : Colors.grey.withOpacity(0.33);
    final w = size * 0.36;
    final hTop = size * 0.52 * 0.56;
    final hBot = size * 0.52 * 0.44;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            CustomPaint(
              size: Size(w, hTop),
              painter: TrianglePainter(color: topColor, pointUp: true),
            ),
            Positioned(
              top: 2,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: topColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: topColor.withOpacity(0.35),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Icon(Icons.mosque_rounded, size: 7, color: topColor),
              ),
            ),
          ],
        ),
        CustomPaint(
          size: Size(w, hBot),
          painter: TrianglePainter(color: bottomColor, pointUp: false),
        ),
      ],
    );
  }
}