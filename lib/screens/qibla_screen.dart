import 'dart:math' show pi;
import 'dart:ui' as ui; // 👈 لإستخدام ui.Path
import 'package:latlong2/latlong.dart' hide Path; // 👈 نخفي Path الخاصة بالخرائط// 👈 نأخذ Path من dart:ui باسم ui.Path

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';



class QiblaScreen extends StatefulWidget {
  final Color? primaryColor;
  const QiblaScreen({super.key, this.primaryColor});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
  bool _hasPermissions = false;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLocation();
  }

  Future<void> _checkPermissionsAndLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _hasPermissions = true;
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F5E9), // لون الخلفية الفاتح
        body: FutureBuilder(
          future: _deviceSupport,
          builder: (_, AsyncSnapshot<bool?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }
            if (snapshot.hasError || snapshot.data == false) {
              return _buildMessageScreen('عذراً، هاتفك لا يدعم مستشعر البوصلة', Icons.error_outline);
            }
            if (!_hasPermissions) {
              return _buildMessageScreen('الرجاء تفعيل الموقع لمعرفة اتجاه القبلة', Icons.location_off, showButton: true);
            }

            return Column(
              children: [
                // 1. الترويسة العلوية (الهيدر)
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, right: 20, left: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0xFF83C5BE), Color(0xFFA7D7C5)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context)),
                      Expanded(
                        child: Text(
                          'مكتشف القبلة الذكي.\nأينما كنت.',
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. الكارت الأبيض الرئيسي الذي يحتوي على كل شيء (خريطة + بوصلة)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      child: _buildMainContent(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ الواجهة المطابقة للصورة (خريطة تتداخل مع البوصلة)
  Widget _buildMainContent() {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (!snapshot.hasData || _userLocation == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        final qiblahData = snapshot.data!;

        // 1. اتجاه الهاتف الحالي بالنسبة للشمال (يدور القرص عكس عقارب الساعة)
        final compassAngle = qiblahData.direction * (pi / 180) * -1;

        // 2. زاوية الكعبة المطلقة بالنسبة للشمال الجغرافي (ثابتة لموقعك الحالي)
        final qiblahOffsetAngle = qiblahData.offset * (pi / 180);

        // 3. درجة انحراف هاتفك عن الكعبة (إذا كانت قريبة من الصفر، أنت موجه للقبلة)
        bool isFacingQibla = qiblahData.qiblah.abs() < 5.0;

        // 4. زاوية دوران "مجسم الكعبة" فقط (يجب أن يعاكس حركة الهاتف ليبقى ثابتاً في اتجاه الكعبة الحقيقي)
        final kaabaRotationAngle = (qiblahData.qiblah * (pi / 180) * -1);

        final meccaLocation = const LatLng(21.422487, 39.826206);

        if (isFacingQibla) HapticFeedback.selectionClick();

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // الخريطة (كما هي)
            SizedBox(
              height: 300,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _userLocation!,
                  initialZoom: 3.0,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.qibla.app',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [_userLocation!, meccaLocation],
                        color: Colors.green.withOpacity(0.7),
                        strokeWidth: 2.0,
                        isDotted: true,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(point: meccaLocation, width: 40, height: 40, child: const Icon(Icons.mosque, color: Colors.black, size: 30)),
                      Marker(point: _userLocation!, width: 40, height: 40, child: const Icon(Icons.navigation, color: Colors.blue, size: 20)),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: 200, left: 0, right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.0), Colors.white],
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // زاوية القبلة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                    child: Text('درجة القبلة: ${qiblahData.offset.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 60),

                  // البوصلة
                  SizedBox(
                    width: 320,
                    height: 350,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ظل البوصلة
                        Container(
                          width: 300, height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: isFacingQibla ? Colors.green.withOpacity(0.4) : Colors.black12, blurRadius: 40, spreadRadius: 10)],
                          ),
                        ),

                        // ✅ القرص الدوار (الشمال والجنوب) يدور مع حركة الهاتف
                        Transform.rotate(
                          angle: compassAngle,
                          child: _buildCompassDial(),
                        ),

                        // ✅ إبرة الكعبة (تدور بشكل مستقل لتشير دائماً لمكة)
                        Transform.rotate(
                          // نستخدم qiblah وليس offset هنا، لكي تتحرك الكعبة بشكل منفصل عن القرص
                          angle: kaabaRotationAngle,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildCompassNeedle(), // الإبرة
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 2)),
                                  child: const Icon(Icons.mosque, color: Colors.black, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ✅ المؤشر الثابت (هاتفك) يشير دائماً للأعلى
                        Positioned(
                          top: -10, // رُفع قليلاً ليكون خارج الدائرة
                          child: Column(
                            children: [
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 50,
                                color: isFacingQibla ? Colors.green : Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    isFacingQibla ? "أنت الآن تواجه القبلة" : "قم بتدوير الهاتف لتتطابق الكعبة مع المؤشر",
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: isFacingQibla ? Colors.green.shade700 : Colors.grey.shade600),
                  ),

                  // تنبيه معايرة البوصلة (مهم جداً للمستخدم)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "إذا شعرت بعدم الدقة، حرك هاتفك على شكل رقم 8 لمعايرة البوصلة",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ بناء قرص البوصلة باستخدام ويدجت فلاتر أساسية (مستحيل أن تتعطل أو تتشوه)
  Widget _buildCompassDial() {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // رسم الخطوط (الدرجات)
          ...List.generate(72, (index) {
            bool isMajor = index % 18 == 0; // كل 90 درجة
            return Transform.rotate(
              angle: index * 5 * pi / 180,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: isMajor ? 3 : 1.5,
                  height: isMajor ? 15 : 8,
                  color: index == 0 ? Colors.red : Colors.black54, // خط الشمال أحمر
                ),
              ),
            );
          }),
          // الحروف
          const Positioned(top: 30, child: Text('N', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
          const Positioned(bottom: 30, child: Text('S', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
          const Positioned(right: 30, child: Text('E', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
          const Positioned(left: 30, child: Text('W', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // ✅ بناء الإبرة الخضراء الكبيرة (مثل صورتك تماماً)
  Widget _buildCompassNeedle() {
    return SizedBox(
      width: 40, height: 260, // تم زيادة الطول قليلاً لتناسب القرص
      child: Column(
        children: [
          // النصف العلوي من الإبرة (يشير للقبلة)
          Expanded(
            child: ClipPath(
              clipper: TriangleClipper(isPointingUp: true), // ✅ يجب أن يكون true للنصف العلوي
              child: Container(color: const Color(0xFF66D089)),
            ),
          ),
          // النصف السفلي من الإبرة
          Expanded(
            child: ClipPath(
              clipper: TriangleClipper(isPointingUp: false),
              child: Container(color: const Color(0xFFA5E6BB)),
            ),
          ),
        ],
      ),
    );
  }

  // رسائل الأخطاء والصلاحيات
  Widget _buildMessageScreen(String text, IconData icon, {bool showButton = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.green.shade300),
          const SizedBox(height: 16),
          Text(text, style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87)),
          if (showButton) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _checkPermissionsAndLocation,
              child: Text('منح الإذن', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  final bool isPointingUp;
  TriangleClipper({required this.isPointingUp});

  @override
  Path getClip(Size size) {
    final ui.Path path = ui.Path();
    if (isPointingUp) {
      // مثلث رأسه للأعلى
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      // مثلث رأسه للأسفل
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();
    return path; // ✅ إرجاع المسار مباشرة
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}