import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  // حالة التسبيح
  int counter = 0;
  int round = 1;
  int totalCount = 0;
  int selectedIndex = 0;

  // Animation
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> tasbihList = [
    {
      'text': 'سُبْحَانَ اللَّهِ',
      'target': 33,
      'translation': 'Glory be to Allah',
      'transliteration': 'Subhan Allah',
    },
    {
      'text': 'الْحَمْدُ لِلَّهِ',
      'target': 33,
      'translation': 'All praise is for Allah',
      'transliteration': 'Alhamdu lillah',
    },
    {
      'text': 'اللَّهُ أَكْبَرُ',
      'target': 34,
      'translation': 'Allah is the Greatest',
      'transliteration': 'Allahu Akbar',
    },
    {
      'text': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'target': 100,
      'translation': 'There is no deity but Allah',
      'transliteration': 'La ilaha illa Allah',
    },
    {
      'text': 'أَسْتَغْفِرُ اللَّهَ',
      'target': 100,
      'translation': 'I seek Allah’s forgiveness',
      'transliteration': 'Astaghfirullah',
    },
    {
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'target': 100,
      'translation': 'Glory be to Allah and praise is His',
      'transliteration': 'Subhan Allah wa bihamdih',
    },
  ];

  // مفاتيح الحفظ
  static const _kTotal = 'totalTasbih';
  static const _kSelected = 'tasbih_selectedIndex';
  static const _kCounter = 'tasbih_counter';
  static const _kRound = 'tasbih_round';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 130),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _loadState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // -------------------------
  // Persistence
  // -------------------------
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalCount = prefs.getInt(_kTotal) ?? 0;
      selectedIndex = prefs.getInt(_kSelected) ?? 0;
      counter = prefs.getInt(_kCounter) ?? 0;
      round = prefs.getInt(_kRound) ?? 1;
      if (round < 1) round = 1;
      if (selectedIndex < 0 || selectedIndex >= tasbihList.length) {
        selectedIndex = 0;
      }
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTotal, totalCount);
    await prefs.setInt(_kSelected, selectedIndex);
    await prefs.setInt(_kCounter, counter);
    await prefs.setInt(_kRound, round);
  }

  // -------------------------
  // Actions
  // -------------------------
  void _increment() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());

    final target = tasbihList[selectedIndex]['target'] as int;

    setState(() {
      counter++;
      totalCount++;
    });

    _saveState();

    if (counter >= target) {
      HapticFeedback.heavyImpact();
      _showCompletedDialog(target);
    }
  }

  void _resetCurrent() {
    setState(() {
      counter = 0;
      round = 1;
    });
    _saveState();
  }

  void _switchTasbih(int index) {
    setState(() {
      selectedIndex = index;
      counter = 0;
      round = 1;
    });
    _saveState();
  }

  void _showCompletedDialog(int target) {
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'تمت الجولة بنجاح',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أكملت $target تسبيحة',
                  style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            counter = 0;
                            round = 1;
                          });
                          _saveState();
                        },
                        child: Text('إعادة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            counter = 0;
                            round += 1;
                          });
                          _saveState();
                        },
                        child: Text('جولة جديدة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final target = tasbihList[selectedIndex]['target'] as int;
    final progress = (target == 0) ? 0.0 : (counter / target).clamp(0.0, 1.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('التسبيح', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'إعادة ضبط',
              icon: const Icon(Icons.refresh),
              onPressed: _resetCurrent,
            ),
          ],
        ),
        body: Stack(
          children: [
            // خلفية متدرجة
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B5E20), Color(0xFF66BB6A), Color(0xFFF7FBF7)],
                ),
              ),
            ),

            // ظل مسجد بسيط (بدون صور)
            Positioned(
              left: -40,
              bottom: -20,
              child: Icon(Icons.mosque, size: 240, color: Colors.white.withOpacity(0.08)),
            ),
            Positioned(
              right: -30,
              bottom: 40,
              child: Icon(Icons.mosque, size: 200, color: Colors.white.withOpacity(0.06)),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // العنوان مثل الصورة (Tasbih + وصف صغير)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tasbih',
                              style: GoogleFonts.cairo(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                          Text('Electronic tasbih and prayer beads',
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // شريط اختيار الأذكار
                  SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tasbihList.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedIndex;
                        return GestureDetector(
                          onTap: () => _switchTasbih(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tasbihList[index]['text'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFF1B5E20) : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // كارت الهاتف / الذكر
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // الكارت الأبيض
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 10)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // المحتوى
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5EEE6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        tasbihList[selectedIndex]['text'],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.amiri(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          height: 1.7,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        tasbihList[selectedIndex]['translation'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: Colors.black87,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        tasbihList[selectedIndex]['transliteration'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // عداد مثل الصورة: 0/33 و Round
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$counter / $target',
                                      style: GoogleFonts.cairo(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Round: $round',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: 120,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(999),
                                            child: LinearProgressIndicator(
                                              minHeight: 8,
                                              value: progress,
                                              backgroundColor: Colors.grey.shade200,
                                              valueColor: AlwaysStoppedAnimation(primary),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // “خرز” المسبحة + الضغط للتسبيح
                                GestureDetector(
                                  onTap: _increment,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        children: [
                                          CurvedBeadsProgress(
                                            progress: progress,
                                            beadCount: 16,
                                            color: primary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'اضغط للتسبيح',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // إجمالي التسبيح
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withOpacity(0.7)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('الإجمالي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                Text(
                                  '$totalCount',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
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

/// خرز مسبحة فخم (يعبّر عن النسبة، ليس بعدد الهدف الكامل)
class CurvedBeadsProgress extends StatelessWidget {
  final double progress; // 0..1
  final int beadCount;
  final Color color;

  const CurvedBeadsProgress({
    super.key,
    required this.progress,
    this.beadCount = 16,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // TweenAnimationBuilder يعطي حركة ناعمة للخرز عند كل تسبيحة
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return SizedBox(
          height: 90,
          width: double.infinity,
          child: CustomPaint(
            painter: _CurvedBeadsPainter(
              progress: value,
              beadCount: beadCount,
              beadColor: color,
            ),
          ),
        );
      },
    );
  }
}

class _CurvedBeadsPainter extends CustomPainter {
  final double progress;
  final int beadCount;
  final Color beadColor;

  _CurvedBeadsPainter({
    required this.progress,
    required this.beadCount,
    required this.beadColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = beadCount.clamp(6, 40);
    final filled = (progress * count).round().clamp(0, count);

    // منحنى مثل الصورة: من أسفل يسار إلى أعلى يمين
    final start = Offset(size.width * 0.05, size.height * 0.75);
    final end   = Offset(size.width * 0.95, size.height * 0.25);
    final c1    = Offset(size.width * 0.35, size.height * 0.95);
    final c2    = Offset(size.width * 0.65, size.height * 0.05);

    // خيط المسبحة
    final stringPaint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    canvas.drawPath(path, stringPaint);

    // دالة تعطي نقطة على المنحنى حسب t
    Offset pointOnCubic(double t) {
      // cubic bezier formula
      final mt = (1 - t);
      final a = mt * mt * mt;
      final b = 3 * mt * mt * t;
      final c = 3 * mt * t * t;
      final d = t * t * t;

      return Offset(
        a * start.dx + b * c1.dx + c * c2.dx + d * end.dx,
        a * start.dy + b * c1.dy + c * c2.dy + d * end.dy,
      );
    }

    // رسم الخرز
    for (int i = 0; i < count; i++) {
      final t = (count == 1) ? 0.0 : i / (count - 1);
      final p = pointOnCubic(t);

      final active = i < filled;
      final r = active ? 12.0 : 11.0;

      // ظل خفيف للخرز النشط
      if (active) {
        final shadowPaint = Paint()
          ..color = beadColor.withOpacity(0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(p.translate(0, 4), r, shadowPaint);
      }

      // تدرج يعطي شكل "خرزة" فخم
      final base = active ? beadColor : const Color(0xFFD8D8D8);
      final gradient = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.9,
        colors: [
          Colors.white.withOpacity(active ? 0.65 : 0.40),
          base.withOpacity(active ? 0.95 : 0.85),
          base.withOpacity(active ? 0.70 : 0.65),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

      final beadPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: p, radius: r));

      canvas.drawCircle(p, r, beadPaint);

      // لمعة صغيرة
      final highlightPaint = Paint()..color = Colors.white.withOpacity(active ? 0.55 : 0.35);
      canvas.drawCircle(p.translate(-r * 0.35, -r * 0.35), r * 0.20, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedBeadsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.beadCount != beadCount ||
        oldDelegate.beadColor != beadColor;
  }
}