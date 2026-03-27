import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Asma_Allah_Detail_Screen.dart';
import 'asma_allah_all_names_scree.dart';

class AsmaAllahScreen extends StatefulWidget {
  final Color primaryColor;
  const AsmaAllahScreen({super.key, required this.primaryColor});

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _rotateController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotateAnimation;

  // Zoom Controller
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();

    // Pulse Animation للمركز
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Glow Animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Rotate Animation خفيف جداً
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _rotateController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  // قائمة الأسماء
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
    {'name': 'المانع', 'meaning': 'الذي يمنع الضر عمن يشاء'},
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color gold = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0A0E1A), const Color(0xFF0F1628), const Color(0xFF050810)]
                  : [const Color(0xFFFFFDF5), const Color(0xFFFFF8E1), const Color(0xFFFFF3CD)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // AppBar مخصص
                _buildCustomAppBar(context, isDark, gold),

                // شريط التلميح
                _buildHintBar(gold),

                // المحتوى الرئيسي - الحلقة الدائرية
                Expanded(
                  child: _buildCircularContent(context, isDark, gold),
                ),

                // أزرار التحكم
                _buildZoomControls(gold),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // AppBar مخصص
  // ═══════════════════════════════════════════════════════════
  Widget _buildCustomAppBar(BuildContext context, bool isDark, Color gold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors:isDark? [
          const Color(0xFF1E2A4A),
          const Color(0xFF0F1628),
        ] : [
          Colors.white.withOpacity(0.6),
          gold.withOpacity(0.0),
        ]),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الرجوع
          Material(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDark? Colors.white : gold,
                    size: 20
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // العنوان
          Expanded(
            child: Column(
              children: [
                Text(
                  'أسماء الله الحسنى',
                  style: GoogleFonts.cairo(
                    color: isDark? Colors.white : gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 30, height: 1.5, color: gold.withOpacity(0.6)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '٩٩ اسماً',
                        style: GoogleFonts.cairo(color: gold, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(width: 30, height: 1.5, color: gold.withOpacity(0.6)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // زر عرض الكل
          Material(
            color: gold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AsmaAllahAllNamesScreen(primaryColor: widget.primaryColor, names: names),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.grid_view_rounded, color: gold, size: 18),
                    const SizedBox(width: 6),
                    Text('الكل', style: GoogleFonts.cairo(
                        color: isDark? Colors.white : gold,
                        fontWeight: FontWeight.bold
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // شريط التلميح
  // ═══════════════════════════════════════════════════════════
  Widget _buildHintBar(Color gold) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gold.withOpacity(0.02),
                gold.withOpacity(0.08 * _glowAnimation.value),
                gold.withOpacity(0.02),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: gold.withOpacity(0.5 + 0.5 * _glowAnimation.value),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'اضغط على الاسم لعرض المعنى',
                style: GoogleFonts.cairo(
                  color: gold.withOpacity(0.7 + 0.3 * _glowAnimation.value),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 14, color: gold.withOpacity(0.3)),
              const SizedBox(width: 12),
              Icon(Icons.pinch_rounded, color: gold.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Text(
                'قرّب / بعّد',
                style: GoogleFonts.cairo(color: gold.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // المحتوى الرئيسي - الحلقة الدائرية في المنتصف تماماً
  // ═══════════════════════════════════════════════════════════
  Widget _buildCircularContent(BuildContext context, bool isDark, Color gold) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // الأبعاد المتاحة
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;

        // ═══════════════════════════════════════════════════════
        // الحساب الذكي لمنع الـ Overflow نهائياً
        // نأخذ الأصغر بين العرض والطول مع هامش أمان
        // ═══════════════════════════════════════════════════════
        final double canvasSize = min(availableWidth, availableHeight) * 0.95;

        // المركز دائماً في نصف الكانفاس
        final double centerX = canvasSize / 2;
        final double centerY = canvasSize / 2;

        // نصف القطر الأقصى للحلقة الخارجية (مع هامش أمان)
        final double maxRadius = canvasSize * 0.42;

        // أنصاف الأقطار للحلقات الست (من الخارج للداخل)
        final List<double> radii = [
          maxRadius,            // الحلقة 1 - الخارجية
          maxRadius * 0.78,     // الحلقة 2
          maxRadius * 0.60,     // الحلقة 3
          maxRadius * 0.45,     // الحلقة 4
          maxRadius * 0.32,     // الحلقة 5
          maxRadius * 0.18,     // الحلقة 6 - الداخلية
        ];

        // أحجام دوائر الأسماء لكل حلقة
        final List<double> circleSizes = [
          canvasSize * 0.078,
          canvasSize * 0.072,
          canvasSize * 0.066,
          canvasSize * 0.060,
          canvasSize * 0.055,
          canvasSize * 0.050,
        ];

        // حجم الدائرة المركزية
        final double centerSize = canvasSize * 0.22;

        // توزيع الأسماء على الحلقات
        final allNames = names.take(99).toList();
        final List<List<Map<String, String>>> rings = [
          allNames.sublist(0, 24),      // الحلقة 1: 24 اسم
          allNames.sublist(24, 44),     // الحلقة 2: 20 اسم
          allNames.sublist(44, 62),     // الحلقة 3: 18 اسم
          allNames.sublist(62, 76),     // الحلقة 4: 14 اسم
          allNames.sublist(76, 88),     // الحلقة 5: 12 اسم
          allNames.sublist(88, 99),     // الحلقة 6: 11 اسم
        ];

        return Center(
          child: SizedBox(
            width: canvasSize,
            height: canvasSize,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(100),
              child: AnimatedBuilder(
                animation: _rotateAnimation,
                builder: (_, __) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ═══ الطبقة 1: النقش الإسلامي الخلفي ═══
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _IslamicPatternPainter(
                            color: gold.withOpacity(0.03),
                          ),
                        ),
                      ),

                      // ═══ الطبقة 2: دوائر التوهج ═══
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (_, __) {
                          return CustomPaint(
                            size: Size(canvasSize, canvasSize),
                            painter: _GlowRingsPainter(
                              center: Offset(centerX, centerY),
                              radii: radii,
                              gold: gold,
                              opacity: 0.04 + _glowAnimation.value * 0.06,
                            ),
                          );
                        },
                      ),

                      // ═══ الطبقة 3: الحلقات الست ═══
                      for (int ringIndex = 0; ringIndex < 6; ringIndex++)
                        ..._buildNameRing(
                          context: context,
                          ringNames: rings[ringIndex],
                          radius: radii[ringIndex],
                          circleSize: circleSizes[ringIndex],
                          centerX: centerX,
                          centerY: centerY,
                          ringIndex: ringIndex,
                          gold: gold,
                          isDark: isDark,
                        ),

                      // ═══ الطبقة 4: الدائرة المركزية "الله" ═══
                      _buildCenterCircle(
                        centerX: centerX,
                        centerY: centerY,
                        size: centerSize,
                        gold: gold,
                        isDark: isDark,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // بناء حلقة واحدة من الأسماء
  // ═══════════════════════════════════════════════════════════
  List<Widget> _buildNameRing({
    required BuildContext context,
    required List<Map<String, String>> ringNames,
    required double radius,
    required double circleSize,
    required double centerX,
    required double centerY,
    required int ringIndex,
    required Color gold,
    required bool isDark,
  }) {
    // ألوان الحدود المتدرجة
    final List<Color> borderColors = [
      gold,
      const Color(0xFFDAA520),
      const Color(0xFFCD853F),
      const Color(0xFFB8860B),
      const Color(0xFFD4AF37),
      gold.withOpacity(0.8),
    ];
    final Color borderColor = borderColors[ringIndex % borderColors.length];

    return List.generate(ringNames.length, (index) {
      // حساب الزاوية لكل اسم
      final double angle = (2 * pi * index / ringNames.length) - (pi / 2);

      // حساب الموقع
      final double x = centerX + radius * cos(angle) - (circleSize / 2);
      final double y = centerY + radius * sin(angle) - (circleSize / 2);

      final Map<String, String> item = ringNames[index];
      final int globalIndex = names.indexOf(item) + 1;
      final String heroTag = 'asma_$globalIndex';

      return Positioned(
        left: x,
        top: y,
        child: _NameCircleWidget(
          name: item['name']!,
          meaning: item['meaning']!,
          size: circleSize,
          borderColor: borderColor,
          isDark: isDark,
          gold: gold,
          heroTag: heroTag,
          glowAnimation: _glowAnimation,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 450),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (_, animation, __) {
                  return AsmaAllahDetailScreen(
                    name: item['name']!,
                    meaning: item['meaning']!,
                    primaryColor: widget.primaryColor,
                    order: globalIndex,
                    names: names,
                    heroTag: heroTag,
                  );
                },
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // الدائرة المركزية "الله"
  // ═══════════════════════════════════════════════════════════
  Widget _buildCenterCircle({
    required double centerX,
    required double centerY,
    required double size,
    required Color gold,
    required bool isDark,
  }) {
    return Positioned(
      left: centerX - size / 2,
      top: centerY - size / 2,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
        builder: (_, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2A4A), const Color(0xFF0F1628)]
                      : [Colors.white, const Color(0xFFFFF8E1)],
                ),
                border: Border.all(color: gold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.2 + _glowAnimation.value * 0.4),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: gold.withOpacity(0.1),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // حلقة داخلية
                  Container(
                    width: size * 0.75,
                    height: size * 0.75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gold.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // النص
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.15),
                      child: Text(
                        'الله',
                        style: GoogleFonts.amiri(
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                          color: gold,
                          shadows: [
                            Shadow(
                              color: gold.withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // أزرار التحكم بالتكبير والتصغير
  // ═══════════════════════════════════════════════════════════
  Widget _buildZoomControls(Color gold) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: gold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(
            icon: Icons.remove_rounded,
            gold: gold,
            onTap: () {
              final current = _transformController.value.clone();
              _transformController.value = current..scale(0.85);
            },
          ),
          Container(width: 1, height: 24, color: gold.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 8)),
          _ZoomButton(
            icon: Icons.center_focus_strong_rounded,
            gold: gold,
            onTap: () => _transformController.value = Matrix4.identity(),
          ),
          Container(width: 1, height: 24, color: gold.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 8)),
          _ZoomButton(
            icon: Icons.add_rounded,
            gold: gold,
            onTap: () {
              final current = _transformController.value.clone();
              _transformController.value = current..scale(1.2);
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Widget دائرة الاسم
// ═══════════════════════════════════════════════════════════════
class _NameCircleWidget extends StatefulWidget {
  final String name;
  final String meaning;
  final double size;
  final Color borderColor;
  final bool isDark;
  final Color gold;
  final String heroTag;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;

  const _NameCircleWidget({
    required this.name,
    required this.meaning,
    required this.size,
    required this.borderColor,
    required this.isDark,
    required this.gold,
    required this.heroTag,
    required this.glowAnimation,
    required this.onTap,
  });

  @override
  State<_NameCircleWidget> createState() => _NameCircleWidgetState();
}

class _NameCircleWidgetState extends State<_NameCircleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _tapController.forward();
      },
      onTapUp: (_) {
        _tapController.reverse();
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _tapController.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_tapAnimation, widget.glowAnimation]),
        builder: (_, __) {
          return Transform.scale(
            scale: _tapAnimation.value,
            child: Hero(
              tag: widget.heroTag,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: widget.isDark
                          ? [
                        _isPressed ? const Color(0xFF2A3654) : const Color(0xFF1A2438),
                        _isPressed ? const Color(0xFF1A2438) : const Color(0xFF0F1628),
                      ]
                          : [
                        _isPressed ? const Color(0xFFFFF0D0) : Colors.white,
                        _isPressed ? Colors.white : const Color(0xFFFFF8E8),
                      ],
                    ),
                    border: Border.all(
                      color: _isPressed
                          ? widget.borderColor
                          : widget.borderColor.withOpacity(0.6),
                      width: _isPressed ? 2.0 : 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.borderColor.withOpacity(
                          _isPressed ? 0.4 : 0.08 + widget.glowAnimation.value * 0.08,
                        ),
                        blurRadius: _isPressed ? 15 : 8,
                        spreadRadius: _isPressed ? 3 : 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(widget.size * 0.08),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: widget.size * 0.32,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// زر التكبير/التصغير
// ═══════════════════════════════════════════════════════════════
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final Color gold;
  final VoidCallback onTap;

  const _ZoomButton({
    required this.icon,
    required this.gold,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: gold, size: 22),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// رسام دوائر التوهج
// ═══════════════════════════════════════════════════════════════
class _GlowRingsPainter extends CustomPainter {
  final Offset center;
  final List<double> radii;
  final Color gold;
  final double opacity;

  _GlowRingsPainter({
    required this.center,
    required this.radii,
    required this.gold,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gold.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final radius in radii) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowRingsPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

// ═══════════════════════════════════════════════════════════════
// رسام النقش الإسلامي
// ═══════════════════════════════════════════════════════════════
class _IslamicPatternPainter extends CustomPainter {
  final Color color;

  _IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const double step = 50;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final cx = x + step / 2;
        final cy = y + step / 2;

        // رسم شكل سداسي
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (pi / 3) * i - pi / 6;
          final px = cx + step * 0.4 * cos(angle);
          final py = cy + step * 0.4 * sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);

        // رسم نجمة صغيرة
        final starPaint = Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.fill;

        final starPath = Path();
        for (int i = 0; i < 12; i++) {
          final angle = (pi / 6) * i - pi / 2;
          final r = i.isEven ? step * 0.08 : step * 0.04;
          final px = cx + r * cos(angle);
          final py = cy + r * sin(angle);
          if (i == 0) {
            starPath.moveTo(px, py);
          } else {
            starPath.lineTo(px, py);
          }
        }
        starPath.close();
        canvas.drawPath(starPath, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}