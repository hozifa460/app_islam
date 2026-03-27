import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'package:google_fonts/google_fonts.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen>
    with SingleTickerProviderStateMixin {
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);

  List<Map<String, dynamic>> azkarCategories = [];
  bool _loading = true;
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnim;

  final List<List<Color>> _cardGradientsDark = [
    [const Color(0xFF1A3A5C), const Color(0xFF0D1F33)],
    [const Color(0xFF2D1B4E), const Color(0xFF160D26)],
    [const Color(0xFF1A3D2E), const Color(0xFF0D1F17)],
    [const Color(0xFF3D2010), const Color(0xFF1F1008)],
    [const Color(0xFF1A2D4E), const Color(0xFF0D1726)],
    [const Color(0xFF3D1A2E), const Color(0xFF1F0D17)],
  ];

  final List<Color> _cardAccents = [
    const Color(0xFF4A9EFF),
    const Color(0xFF9B6FFF),
    const Color(0xFF4AFF9E),
    const Color(0xFFFFB84A),
    const Color(0xFF4ADEFF),
    const Color(0xFFFF4A9E),
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutBack,
    );
    _loadAzkar();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadAzkar() async {
    try {
      final jsonString =
      await rootBundle.loadString('assets/azkar/azkar.json');
      final List<dynamic> data = json.decode(jsonString);
      setState(() {
        azkarCategories =
            data.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
      _headerAnimController.forward();
    } catch (e) {
      debugPrint('azkar load error: $e');
      setState(() => _loading = false);
    }
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'wb_sunny_rounded':
        return Icons.wb_sunny_rounded;
      case 'nights_stay_rounded':
        return Icons.nights_stay_rounded;
      case 'mosque_rounded':
        return Icons.mosque_rounded;
      case 'bedtime_rounded':
        return Icons.bedtime_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : const Color(0xFFF0F4FF);

    if (_loading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: _gold, strokeWidth: 3),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل الأذكار...',
                  style: GoogleFonts.cairo(
                    color: _gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        // ✅ لا نستخدم extendBodyBehindAppBar لتجنب التداخل
        body: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverHeader(context, isDark, innerBoxIsScrolled),
          ],
          body: ListView.builder(
            padding: EdgeInsets.only(
              right: (MediaQuery.of(context).size.width * 0.045).clamp(14.0, 24.0),
              left: (MediaQuery.of(context).size.width * 0.045).clamp(14.0, 24.0),
              top: (MediaQuery.of(context).size.width * 0.03).clamp(10.0, 18.0),
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: azkarCategories.length,
            itemBuilder: (context, index) {
              final category = azkarCategories[index];
              final List<dynamic> azkarList =
              category['azkar'] as List<dynamic>;
              final accent = _cardAccents[index % _cardAccents.length];
              final gradientDark =
              _cardGradientsDark[index % _cardGradientsDark.length];

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: child,
                  ),
                ),
                child: _buildCategoryCard(
                  context,
                  category,
                  azkarList,
                  index,
                  isDark,
                  accent,
                  gradientDark,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  //  SliverAppBar بدون تداخل
  // ══════════════════════════════════════════
  Widget _buildSliverHeader(
      BuildContext context, bool isDark, bool innerBoxIsScrolled) {
    final size = MediaQuery.of(context).size;
    // ✅ ارتفاع الهيدر القابل للطي فقط (بدون AppBar)
    final expandedHeight = (size.height * 0.24).clamp(160.0, 240.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      floating: false,
      snap: false,
      stretch: false,
      // ✅ لون ثابت واضح للـ AppBar عند الطي
      backgroundColor: isDark
          ? const Color(0xFF0D1420)
          : const Color(0xFF1A2744),
      elevation: innerBoxIsScrolled ? 4 : 0,
      shadowColor: Colors.black.withOpacity(0.3),
      // ✅ زر الرجوع
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
          padding: EdgeInsets.zero,
        ),
      ),
      // ✅ العنوان يظهر فقط عند الطي
      title: AnimatedOpacity(
        opacity: innerBoxIsScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          'الأذكار',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        // ✅ لا عنوان هنا لتجنب التداخل
        titlePadding: EdgeInsets.zero,
        collapseMode: CollapseMode.parallax,
        background: _buildHeaderBackground(context, isDark, size),
      ),
    );
  }

  Widget _buildHeaderBackground(
      BuildContext context, bool isDark, Size size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xFF0D1420),
            const Color(0xFF1A2744),
            const Color(0xFF0F1B35),
          ]
              : [
            const Color(0xFF1A2744),
            const Color(0xFF2D4A8A),
            const Color(0xFF1E3A6E),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ دوائر زخرفية آمنة
          Positioned(
            top: -size.width * 0.12,
            left: -size.width * 0.12,
            child: _buildDecorativeCircle(
                size.width * 0.5, _gold.withOpacity(0.07)),
          ),
          Positioned(
            bottom: -size.width * 0.06,
            right: -size.width * 0.1,
            child: _buildDecorativeCircle(
                size.width * 0.38, _gold.withOpacity(0.05)),
          ),
          Positioned(
            top: size.height * 0.06,
            right: size.width * 0.08,
            child: _buildDecorativeCircle(
                size.width * 0.12, _gold.withOpacity(0.1)),
          ),

          // ✅ المحتوى في الوسط بشكل آمن
          SafeArea(
            bottom: false,
            child: Padding(
              // مسافة علوية لترك مكان لعناصر الـ AppBar
              padding: const EdgeInsets.only(top: kToolbarHeight - 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة مركزية
                  ScaleTransition(
                    scale: _headerAnim,
                    child: Container(
                      width: (size.width * 0.16).clamp(52.0, 80.0),
                      height: (size.width * 0.16).clamp(52.0, 80.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gold.withOpacity(0.12),
                        border: Border.all(
                            color: _gold.withOpacity(0.4), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withOpacity(0.2),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: _gold,
                          size: (size.width * 0.08).clamp(26.0, 40.0),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // الآية الكريمة
                  FadeTransition(
                    opacity: _headerAnim,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08),
                      child: Text(
                        '﴿ وَاذْكُرُوا اللَّهَ كَثِيرًا ﴾',
                        style: GoogleFonts.amiri(
                          color: _gold.withOpacity(0.95),
                          fontSize:
                          (size.width * 0.044).clamp(14.0, 20.0),
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // عدد التصنيفات
                  FadeTransition(
                    opacity: _headerAnim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1),
                      ),
                      child: Text(
                        '${azkarCategories.length} تصنيفات للأذكار',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.85),
                          fontSize:
                          (size.width * 0.032).clamp(10.0, 13.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }

  // ══════════════════════════════════════════
  //  بطاقة التصنيف
  // ══════════════════════════════════════════
  Widget _buildCategoryCard(
      BuildContext context,
      Map<String, dynamic> category,
      List<dynamic> azkarList,
      int index,
      bool isDark,
      Color accent,
      List<Color> gradientDark,
      ) {
    final size = MediaQuery.of(context).size;
    // ✅ ارتفاع ثابت آمن للبطاقة
    final cardHeight = (size.width * 0.28).clamp(90.0, 120.0);
    final iconContainerSize = (size.width * 0.15).clamp(48.0, 64.0);
    final iconSize = (size.width * 0.08).clamp(24.0, 36.0);
    final titleFontSize = (size.width * 0.044).clamp(14.0, 20.0);
    final subFontSize = (size.width * 0.03).clamp(10.0, 13.0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, anim, __) => AzkarDetailScreen(
              title: category['title'] as String,
              azkar: azkarList
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            ),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? gradientDark
                : [Colors.white, accent.withOpacity(0.04)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withOpacity(isDark ? 0.22 : 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(isDark ? 0.1 : 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ✅ دوائر زخرفية خلفية مقيدة بالحجم
              Positioned(
                left: -cardHeight * 0.3,
                top: -cardHeight * 0.3,
                child: _buildDecorativeCircle(
                    cardHeight * 0.9, accent.withOpacity(0.06)),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: _buildDecorativeCircle(
                    cardHeight * 0.55, accent.withOpacity(0.04)),
              ),

              // ✅ شريط لوني جانبي على اليمين
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withOpacity(0.9),
                        accent.withOpacity(0.15),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              // ✅ المحتوى الرئيسي بـ Row مع Expanded آمن
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (size.width * 0.038).clamp(10.0, 18.0),
                ),
                child: Row(
                  children: [
                    // أيقونة
                    Container(
                      width: iconContainerSize,
                      height: iconContainerSize,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accent.withOpacity(0.28),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.12),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _iconFromString(category['icon'] as String),
                          color: accent,
                          size: iconSize,
                        ),
                      ),
                    ),

                    SizedBox(
                        width: (size.width * 0.035).clamp(8.0, 16.0)),

                    // ✅ النصوص داخل Expanded دائماً
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // رقم التصنيف
                          Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: GoogleFonts.cairo(
                              fontSize: subFontSize * 0.9,
                              color: accent.withOpacity(0.55),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 1),

                          // ✅ العنوان بـ maxLines و overflow
                          Text(
                            category['title'] as String,
                            style: GoogleFonts.cairo(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                              fontWeight: FontWeight.w800,
                              fontSize: titleFontSize,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // عدد الأذكار
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (size.width * 0.022)
                                      .clamp(6.0, 11.0),
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  border: Border.all(
                                    color: accent.withOpacity(0.22),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.format_list_bulleted_rounded,
                                      color: accent,
                                      size: subFontSize * 1.1,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${azkarList.length} ذكر',
                                      style: GoogleFonts.cairo(
                                        fontSize: subFontSize,
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ✅ سهم التنقل بحجم ثابت آمن
                    Container(
                      width: (size.width * 0.085).clamp(26.0, 38.0),
                      height: (size.width * 0.085).clamp(26.0, 38.0),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withOpacity(0.22),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: accent,
                          size: (size.width * 0.038).clamp(11.0, 17.0),
                        ),
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
}

// ══════════════════════════════════════════════════════════════
//  شاشة التفاصيل (بدون تغيير)
// ══════════════════════════════════════════════════════════════
class AzkarDetailScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> azkar;

  const AzkarDetailScreen({
    super.key,
    required this.title,
    required this.azkar,
  });

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  late List<int> counters;
  late List<int> initialCounts;

  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _success = const Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    counters = widget.azkar.map((a) => a['count'] as int).toList();
    initialCounts = List.from(counters);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final basePadding = (screenWidth * 0.045).clamp(12.0, 24.0);
    final cardPadding = (screenWidth * 0.05).clamp(14.0, 24.0);
    final titleFontSize = (screenWidth * 0.055).clamp(18.0, 26.0);
    final zekrFontSize = (screenWidth * 0.058).clamp(18.0, 26.0);
    final infoFontSize = (screenWidth * 0.035).clamp(11.0, 14.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColorMain =
    isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  fontSize: titleFontSize,
                  color: textColorMain,
                ),
              ),
            ),
          ),
          leading: Container(
            margin: EdgeInsets.all(basePadding * 0.5),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : _gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : _gold.withOpacity(0.2),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: textColorMain,
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
              splashRadius: 20,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView.builder(
            padding: EdgeInsets.all(basePadding),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.azkar.length,
            itemBuilder: (context, index) {
              final isDone = counters[index] == 0;
              final zekr = widget.azkar[index];
              final progress = initialCounts[index] > 0
                  ? 1.0 - (counters[index] / initialCounts[index])
                  : 1.0;

              return GestureDetector(
                onTap: () {
                  if (counters[index] > 0) {
                    setState(() => counters[index]--);
                    HapticFeedback.lightImpact();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(bottom: basePadding),
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDone
                          ? [
                        _success.withOpacity(
                            isDark ? 0.15 : 0.08),
                        _success.withOpacity(
                            isDark ? 0.05 : 0.02),
                      ]
                          : [
                        isDark
                            ? const Color(0xFF1E2533)
                            : Colors.white,
                        isDark
                            ? const Color(0xFF151B26)
                            : const Color(0xFFFAFAFA),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                    BorderRadius.circular(screenWidth * 0.055),
                    border: Border.all(
                      color: isDone
                          ? _success.withOpacity(0.4)
                          : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : _gold.withOpacity(0.15)),
                      width: isDone ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDone
                            ? _success.withOpacity(0.1)
                            : (isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.08)),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        zekr['text'],
                        style: GoogleFonts.amiri(
                          fontSize: zekrFontSize,
                          height: 1.8,
                          color: isDone
                              ? (isDark
                              ? Colors.white54
                              : Colors.black45)
                              : textColorMain,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: basePadding * 0.8),
                      if ((zekr['source'] ?? '')
                          .toString()
                          .isNotEmpty)
                        _buildInfoBox(
                          context,
                          icon: Icons.menu_book_rounded,
                          text: 'المصدر: ${zekr['source']}',
                          color: _gold,
                          isDark: isDark,
                          fontSize: infoFontSize,
                          padding: basePadding,
                        ),
                      if ((zekr['benefit'] ?? '')
                          .toString()
                          .isNotEmpty)
                        _buildInfoBox(
                          context,
                          icon: Icons.lightbulb_outline_rounded,
                          text: zekr['benefit'],
                          color: _success,
                          isDark: isDark,
                          fontSize: infoFontSize,
                          padding: basePadding,
                          isBenefit: true,
                        ),
                      SizedBox(height: basePadding * 0.6),
                      _buildCounterWidget(
                        context,
                        counters[index],
                        isDone,
                        progress,
                        isDark,
                        screenWidth,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(
      BuildContext context, {
        required IconData icon,
        required String text,
        required Color color,
        required bool isDark,
        required double fontSize,
        required double padding,
        bool isBenefit = false,
      }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: padding * 0.5),
      padding: EdgeInsets.all(padding * 0.7),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border:
        Border.all(color: color.withOpacity(isDark ? 0.2 : 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: fontSize * 1.4),
          SizedBox(width: padding * 0.4),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: fontSize,
                height: 1.6,
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight:
                isBenefit ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterWidget(
      BuildContext context,
      int count,
      bool isDone,
      double progress,
      bool isDark,
      double screenWidth,
      ) {
    final size = (screenWidth * 0.22).clamp(60.0, 90.0);
    final strokeWidth = size * 0.08;

    if (isDone) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Container(
          key: const ValueKey('done'),
          padding: EdgeInsets.symmetric(
            horizontal: size * 0.3,
            vertical: size * 0.12,
          ),
          decoration: BoxDecoration(
            color: _success.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _success, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle,
                  color: _success, size: size * 0.35),
              SizedBox(width: size * 0.15),
              Text(
                'تم',
                style: GoogleFonts.cairo(
                  color: _success,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.25,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Stack(
        key: ValueKey(count),
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: _gold.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(_gold),
            ),
          ),
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              isDark ? const Color(0xFF1E2533) : Colors.white,
              border: Border.all(
                  color: _gold.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.all(size * 0.1),
                  child: Text(
                    '$count',
                    style: GoogleFonts.cairo(
                      fontSize: size * 0.45,
                      fontWeight: FontWeight.w800,
                      color: _gold,
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
}