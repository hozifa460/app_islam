import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Asma_Allah_Detail_Screen.dart';
import 'asma_allah_all_names_scree.dart';

class AsmaAllahScreen extends StatefulWidget {
  final Color primaryColor;

  const AsmaAllahScreen({super.key, required this.primaryColor});

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen> {
  final TransformationController _zoomController = TransformationController();

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final current = _zoomController.value.clone();
    _zoomController.value = current..scale(1.15);
  }

  void _zoomOut() {
    final current = _zoomController.value.clone();
    _zoomController.value = current..scale(0.87);
  }

  void _resetZoom() {
    _zoomController.value = Matrix4.identity();
  }

  static const List<Map<String, String>> names = [
    {'name': 'الله', 'meaning': 'اسم الجلالة الجامع لكل صفات الكمال'},
    {'name': 'الرحمن', 'meaning': 'واسع الرحمة بجميع خلقه'},
    {'name': 'الرحيم', 'meaning': 'المنعم على عباده المؤمنين برحمته'},
    {'name': 'الملك', 'meaning': 'المتصرف في ملكه كيف يشاء'},
    {'name': 'القدوس', 'meaning': 'المنزه عن كل نقص وعيب'},
    {'name': 'السلام', 'meaning': 'السالم من كل عيب ونقص'},
    {'name': 'المؤمن', 'meaning': 'الذي يؤمّن عباده من الخوف'},
    {'name': 'المهيمن', 'meaning': 'الرقيب الحافظ لكل شيء'},
    {'name': 'العزيز', 'meaning': 'القوي الغالب الذي لا يُغلب'},
    {'name': 'الجبار', 'meaning': 'الذي يجبر الضعيف ويقهر الجبابرة'},
    {'name': 'المتكبر', 'meaning': 'العظيم المتعالي عن صفات الخلق'},
    {'name': 'الخالق', 'meaning': 'موجد الأشياء من العدم'},
    {'name': 'البارئ', 'meaning': 'الذي خلق الخلق بقدرته'},
    {'name': 'المصور', 'meaning': 'الذي أعطى كل مخلوق صورته'},
    {'name': 'الغفار', 'meaning': 'كثير المغفرة لعباده'},
    {'name': 'القهار', 'meaning': 'الذي قهر كل شيء بقدرته'},
    {'name': 'الوهاب', 'meaning': 'كثير العطايا والمنح'},
    {'name': 'الرزاق', 'meaning': 'الذي يرزق جميع الخلائق'},
    {'name': 'الفتاح', 'meaning': 'الذي يفتح أبواب الرحمة والنصر'},
    {'name': 'العليم', 'meaning': 'الذي أحاط علمه بكل شيء'},
    {'name': 'القابض', 'meaning': 'الذي يقبض الرزق عمن يشاء'},
    {'name': 'الباسط', 'meaning': 'الذي يوسع الرزق لمن يشاء'},
    {'name': 'الخافض', 'meaning': 'الذي يخفض من يشاء'},
    {'name': 'الرافع', 'meaning': 'الذي يرفع من يشاء'},
    {'name': 'المعز', 'meaning': 'الذي يهب العزة لمن يشاء'},
    {'name': 'المذل', 'meaning': 'الذي يذل من يشاء'},
    {'name': 'السميع', 'meaning': 'الذي يسمع كل شيء'},
    {'name': 'البصير', 'meaning': 'الذي يرى كل شيء'},
    {'name': 'الحكم', 'meaning': 'الذي يحكم بين عباده بالعدل'},
    {'name': 'العدل', 'meaning': 'المنزه عن الظلم في قضائه وحكمه'},
    {'name': 'اللطيف', 'meaning': 'الذي يوصل الخير برفق وخفاء'},
    {'name': 'الخبير', 'meaning': 'العالم بدقائق الأمور وخفاياها'},
    {'name': 'الحليم', 'meaning': 'الذي لا يعجل بالعقوبة على من عصاه'},
    {'name': 'العظيم', 'meaning': 'الذي له العظمة والكبرياء'},
    {'name': 'الغفور', 'meaning': 'الذي يغفر الذنوب ويستر العيوب'},
    {'name': 'الشكور', 'meaning': 'الذي يجزي على العمل القليل بالأجر الكثير'},
    {'name': 'العلي', 'meaning': 'الرفيع القدر والشأن'},
    {'name': 'الكبير', 'meaning': 'الذي كل شيء دونه'},
    {'name': 'الحفيظ', 'meaning': 'الذي يحفظ عباده وأعمالهم'},
    {'name': 'المقيت', 'meaning': 'الذي يوصل القوت إلى الخلق'},
    {'name': 'الحسيب', 'meaning': 'الكافي لعباده والمحاسب لهم'},
    {'name': 'الجليل', 'meaning': 'الموصوف بصفات الجلال والكمال'},
    {'name': 'الكريم', 'meaning': 'الذي يعطي بلا حساب ولا منّ'},
    {'name': 'الرقيب', 'meaning': 'المطلع على كل شيء'},
    {'name': 'المجيب', 'meaning': 'الذي يجيب دعاء الداعين'},
    {'name': 'الواسع', 'meaning': 'الذي وسع علمه ورحمته كل شيء'},
    {'name': 'الحكيم', 'meaning': 'الذي يضع الأمور في مواضعها'},
    {'name': 'الودود', 'meaning': 'المحب لعباده الصالحين'},
    {'name': 'المجيد', 'meaning': 'الذي له المجد الكامل والشرف الواسع'},
    {'name': 'الباعث', 'meaning': 'الذي يبعث الخلق بعد الموت'},
    {'name': 'الشهيد', 'meaning': 'الذي لا يغيب عنه شيء'},
    {'name': 'الحق', 'meaning': 'الثابت الذي لا شك في وجوده'},
    {'name': 'الوكيل', 'meaning': 'الكفيل بأرزاق العباد ومصالحهم'},
    {'name': 'القوي', 'meaning': 'كامل القوة الذي لا يعجزه شيء'},
    {'name': 'المتين', 'meaning': 'الشديد القوة الذي لا يلحقه ضعف'},
    {'name': 'الولي', 'meaning': 'الناصر والمتولي لأمر عباده المؤمنين'},
    {'name': 'الحميد', 'meaning': 'المحمود على كل حال'},
    {'name': 'المحصي', 'meaning': 'الذي أحصى كل شيء عددًا'},
    {'name': 'المبدئ', 'meaning': 'الذي أنشأ الخلق أول مرة'},
    {'name': 'المعيد', 'meaning': 'الذي يعيد الخلق بعد الموت'},
    {'name': 'المحيي', 'meaning': 'الذي يهب الحياة لمن يشاء'},
    {'name': 'المميت', 'meaning': 'الذي يميت من يشاء إذا شاء'},
    {'name': 'الحي', 'meaning': 'الذي له الحياة الكاملة الأبدية'},
    {'name': 'القيوم', 'meaning': 'القائم بنفسه والمقيم لغيره'},
    {'name': 'الواجد', 'meaning': 'الذي لا يعوزه شيء ويجد كل ما يريد'},
    {'name': 'الماجد', 'meaning': 'العظيم في كرمه وشرفه'},
    {'name': 'الواحد', 'meaning': 'المنفرد بالوحدانية'},
    {'name': 'الصمد', 'meaning': 'الذي تصمد إليه الخلائق في حاجاتها'},
    {'name': 'القادر', 'meaning': 'الذي يقدر على كل شيء'},
    {'name': 'المقتدر', 'meaning': 'عظيم القدرة البالغة'},
    {'name': 'المقدم', 'meaning': 'الذي يقدم من يشاء بحكمته'},
    {'name': 'المؤخر', 'meaning': 'الذي يؤخر من يشاء بحكمته'},
    {'name': 'الأول', 'meaning': 'الذي ليس قبله شيء'},
    {'name': 'الآخر', 'meaning': 'الذي ليس بعده شيء'},
    {'name': 'الظاهر', 'meaning': 'العالي فوق كل شيء'},
    {'name': 'الباطن', 'meaning': 'القريب الذي لا تخفى عليه خافية'},
    {'name': 'الوالي', 'meaning': 'المالك المتصرف في الأمور كلها'},
    {'name': 'المتعالي', 'meaning': 'المنزه عن مشابهة الخلق'},
    {'name': 'البر', 'meaning': 'كثير الإحسان واللطف بعباده'},
    {'name': 'التواب', 'meaning': 'الذي يقبل توبة التائبين'},
    {'name': 'المنتقم', 'meaning': 'الذي ينتقم من الظالمين والعصاة'},
    {'name': 'العفو', 'meaning': 'الذي يمحو الذنوب ويتجاوز عنها'},
    {'name': 'الرؤوف', 'meaning': 'شديد الرحمة والرفق بعباده'},
    {'name': 'مالك الملك', 'meaning': 'المالك لجميع الملك والتصرف فيه'},
    {'name': 'ذو الجلال والإكرام', 'meaning': 'صاحب العظمة والكبرياء والكرم'},
    {'name': 'المقسط', 'meaning': 'العادل في حكمه وقضائه'},
    {'name': 'الجامع', 'meaning': 'الذي يجمع الخلائق ليوم لا ريب فيه'},
    {'name': 'الغني', 'meaning': 'الذي لا يحتاج إلى أحد'},
    {'name': 'المغني', 'meaning': 'الذي يغني من يشاء من عباده'},
    {
      'name': 'المانع',
      'meaning': 'الذي يمنع الضر عمن يشاء ويمنع العطاء عمّن يشاء',
    },
    {'name': 'الضار', 'meaning': 'الذي يقدّر الضر على من يشاء بحكمته'},
    {'name': 'النافع', 'meaning': 'الذي يقدّر النفع لمن يشاء برحمته'},
    {'name': 'النور', 'meaning': 'الذي نوّر السماوات والأرض وقلوب عباده'},
    {'name': 'الهادي', 'meaning': 'الذي يهدي من يشاء إلى الصراط المستقيم'},
    {'name': 'البديع', 'meaning': 'الذي أبدع الخلق بلا مثال سابق'},
    {'name': 'الباقي', 'meaning': 'الذي لا يزول ولا يفنى'},
    {'name': 'الوارث', 'meaning': 'الذي يرث الأرض ومن عليها'},
    {'name': 'الرشيد', 'meaning': 'الذي يرشد الخلق إلى مصالحهم'},
    {'name': 'الصبور', 'meaning': 'الذي لا يعجل بالعقوبة مع قدرته عليها'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    const gold = Color(0xFFE6B325);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: widget.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'أسماء الله الحسنى',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.041,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AsmaAllahAllNamesScreen(
                      primaryColor: widget.primaryColor,
                      names: names,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                'عرض الكل',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;
            final size = min(width, availableHeight * 0.92);
            final small = width < 380;

            final centerX = width / 2;
            final centerY = size * 0.88;

            final ringRadius1 = size * 0.40;
            final ringRadius2 = size * 0.32;
            final ringRadius3 = size * 0.25;
            final ringRadius4 = size * 0.18;
            final ringRadius5 = size * 0.11;
            final ringRadius6 = size * 0.05;

            final allNames = names.take(99).toList();

            final ring1 = allNames.take(24).toList();
            final ring2 = allNames.skip(24).take(20).toList();
            final ring3 = allNames.skip(44).take(18).toList();
            final ring4 = allNames.skip(62).take(14).toList();
            final ring5 = allNames.skip(76).take(12).toList();
            final ring6 = allNames.skip(88).take(11).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [


                    ],
                  ),
                ),

                const SizedBox(height: 0),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            bottom: 0,
                            child: SizedBox(
                              height: size * 1.9,
                              child: InteractiveViewer(
                                transformationController: _zoomController,
                                minScale: 0.7,
                                maxScale: 3.0,
                                panEnabled: true,
                                scaleEnabled: true,
                                boundaryMargin: const EdgeInsets.all(60),
                                child: SizedBox(
                                  width: width,
                                  height: size * 1.9,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: CustomPaint(
                                            painter: _SubtlePatternPainter(
                                              color: widget.primaryColor
                                                  .withOpacity(0.05),
                                            ),
                                          ),
                                        ),
                                      ),

                                      Text( 'اضغط لعرض المعنى',
                                        style: GoogleFonts.cairo(
                                          fontSize: MediaQuery.of(context).size.width * 0.05,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD7A539),
                                        ),
                                      ),

                                      // مركز "الله"
                                      Positioned(
                                        left: centerX - (size * 0.14),
                                        top: centerY - (size * 0.14),
                                        child: Container(
                                          width: size * 0.28,
                                          height: size * 0.28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                isDark
                                                    ? const Color(0xFF151B26)
                                                    : Colors.white,
                                            border: Border.all(
                                              color: gold,
                                              width: 2.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: gold.withOpacity(0.12),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'الله',
                                                style: GoogleFonts.amiri(
                                                  fontSize: size * 0.14,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      ..._buildRing(
                                        context: context,
                                        names: ring1,
                                        radius: ringRadius1,
                                        centerX: centerX,
                                        centerY: centerY,
                                        circleSize:
                                            small
                                                ? size * 0.082
                                                : size * 0.088,
                                        gold: gold,
                                        isDark: isDark,
                                      ),

                                      ..._buildRing(
                                        context: context,
                                        names: ring2,
                                        radius: ringRadius2,
                                        centerX: centerX,
                                        centerY: centerY,
                                        circleSize:
                                            small
                                                ? size * 0.075
                                                : size * 0.081,
                                        gold: gold,
                                        isDark: isDark,
                                      ),

                                      ..._buildRing(
                                        context: context,
                                        names: ring3,
                                        radius: ringRadius3,
                                        centerX: centerX,
                                        centerY: centerY,
                                        circleSize:
                                            small
                                                ? size * 0.070
                                                : size * 0.076,
                                        gold: gold,
                                        isDark: isDark,
                                      ),

                                      ..._buildRing(
                                        context: context,
                                        names: ring4,
                                        radius: ringRadius4,
                                        centerX: centerX,
                                        centerY: centerY,
                                        circleSize:
                                            small
                                                ? size * 0.064
                                                : size * 0.070,
                                        gold: gold,
                                        isDark: isDark,
                                      ),

                                      ..._buildRing(
                                        context: context,
                                        names: ring5,
                                        radius: ringRadius5,
                                        centerX: centerX,
                                        centerY: centerY,
                                        circleSize:
                                            small
                                                ? size * 0.058
                                                : size * 0.064,
                                        gold: gold,
                                        isDark: isDark,
                                      ),

                                      ..._buildRing(
                                        context: context,
                                        names: ring6,
                                        radius: ringRadius6,
                                        centerX: centerX,
                                        centerY: centerY,
                                        circleSize:
                                            small
                                                ? size * 0.053
                                                : size * 0.058,
                                        gold: gold,
                                        isDark: isDark,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  List<Widget> _buildRing({
    required BuildContext context,
    required List<Map<String, String>> names,
    required double radius,
    required double centerX,
    required double centerY,
    required double circleSize,
    required Color gold,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return List.generate(names.length, (index) {
      final angle = (2 * pi * index / names.length) - pi / 2;
      final x = centerX + radius * cos(angle) - (circleSize / 2);
      final y = centerY + radius * sin(angle) - (circleSize / 2);

      final item = names[index];
      final originalIndex = _AsmaAllahScreenState.names.indexOf(item) + 1;
      final heroTag = 'asma_name_$originalIndex';

      return Positioned(
        left: x,
        top: y,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                reverseTransitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (_, animation, secondaryAnimation) {
                  return AsmaAllahDetailScreen(
                    name: item['name']!,
                    meaning: item['meaning']!,
                    primaryColor: widget.primaryColor,
                    order: originalIndex,
                    names: names,
                    heroTag: heroTag,
                  );
                },
                transitionsBuilder: (_, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );

                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: heroTag,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF151B26) : Colors.white,
                  border: Border.all(color: gold, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    // ✅ متجاوب
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.006),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item['name']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: circleSize * 0.22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildZoomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _zoomButton(Icons.remove, _zoomOut),
          const SizedBox(width: 6),
          _zoomButton(Icons.refresh, _resetZoom),
          const SizedBox(width: 6),
          _zoomButton(Icons.add, _zoomIn),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _SubtlePatternPainter extends CustomPainter {
  final Color color;

  _SubtlePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    const step = 70.0;

    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        final path = Path();
        path.moveTo(x + step / 2, y);
        path.lineTo(x + step, y + step / 4);
        path.lineTo(x + step, y + step * 0.75);
        path.lineTo(x + step / 2, y + step);
        path.lineTo(x, y + step * 0.75);
        path.lineTo(x, y + step / 4);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SubtlePatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
