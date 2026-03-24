import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  List<Map<String, dynamic>> azkarCategories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }

  Future<void> _loadAzkar() async {
    try {
      final jsonString = await rootBundle.loadString('assets/azkar/azkar.json');
      final List<dynamic> data = json.decode(jsonString);

      setState(() {
        azkarCategories = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('azkar load error: $e');
      setState(() {
        _loading = false;
      });
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

    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub = isDark ? Colors.white70 : Colors.black54;
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);

    if (_loading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: CircularProgressIndicator(color: _gold),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الأذكار',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: textColorMain,
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColorMain),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: azkarCategories.length,
            itemBuilder: (context, index) {
              final category = azkarCategories[index];
              final List<dynamic> azkarList = category['azkar'] as List<dynamic>;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AzkarDetailScreen(
                          title: category['title'] as String,
                          azkar: azkarList
                              .map((e) => Map<String, dynamic>.from(e))
                              .toList(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: cardGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _gold.withOpacity(0.3)),
                          ),
                          child: Icon(
                            _iconFromString(category['icon'] as String),
                            color: _gold,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['title'] as String,
                                style: GoogleFonts.cairo(
                                  color: textColorMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : _gold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${azkarList.length} أذكار',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: _gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: textColorSub.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
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

  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);

  @override
  void initState() {
    super.initState();
    counters = widget.azkar.map((a) => a['count'] as int).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 📱 الحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;

    // 📐 حساب الأحجام المتجاوبة
    final basePadding = screenWidth * 0.04;
    final cardPadding = screenWidth * 0.05;
    final titleFontSize = isTablet ? 26.0 : (isSmallPhone ? 18.0 : 22.0);
    final textFontSize = isTablet ? 26.0 : (isSmallPhone ? 18.0 : 22.0);
    final smallFontSize = isTablet ? 16.0 : (isSmallPhone ? 11.0 : 12.5);
    final counterSize = screenWidth * (isTablet ? 0.12 : 0.15);
    final counterFontSize = isTablet ? 28.0 : (isSmallPhone ? 20.0 : 24.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);

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
            child: Text(
              widget.title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
                color: textColorMain,
              ),
            ),
          ),
          leading: Container(
            margin: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: textColorMain,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => Navigator.pop(context),
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

              return GestureDetector(
                onTap: () {
                  if (counters[index] > 0) {
                    setState(() {
                      counters[index]--;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(bottom: basePadding),
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDone
                          ? [
                        Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                        Colors.green.withOpacity(isDark ? 0.05 : 0.02)
                      ]
                          : cardGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    border: Border.all(
                      color: isDone ? Colors.green.withOpacity(0.5) : borderColor,
                      width: isDone ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDone ? shadowColor : Colors.grey.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 📝 نص الذكر
                      Text(
                        zekr['text'],
                        style: GoogleFonts.amiri(
                          fontSize: textFontSize,
                          height: 2.1,
                          color: isDone
                              ? (isDark ? Colors.white54 : Colors.black54)
                              : textColorMain,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: basePadding),

                      // 📖 المصدر
                      if ((zekr['source'] ?? '').toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(basePadding * 0.7),
                          margin: EdgeInsets.only(bottom: basePadding * 0.5),
                          decoration: BoxDecoration(
                            color: _gold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _gold.withOpacity(0.18)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                color: _gold,
                                size: isTablet ? 22 : 18,
                              ),
                              SizedBox(width: basePadding * 0.4),
                              Flexible(
                                child: Text(
                                  'المصدر: ${zekr['source']}',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.cairo(
                                    fontSize: smallFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: _gold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 💡 الفائدة
                      if ((zekr['benefit'] ?? '').toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(basePadding * 0.8),
                          margin: EdgeInsets.only(bottom: basePadding * 0.7),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.green.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Colors.green.shade600,
                                size: isTablet ? 22 : 18,
                              ),
                              SizedBox(width: basePadding * 0.4),
                              Expanded(
                                child: Text(
                                  zekr['benefit'],
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.cairo(
                                    fontSize: smallFontSize,
                                    height: 1.7,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 🔢 العداد
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: isDone
                            ? Container(
                          key: const ValueKey('done'),
                          padding: EdgeInsets.symmetric(
                            horizontal: basePadding,
                            vertical: basePadding * 0.4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: isTablet ? 24 : 20,
                              ),
                              SizedBox(width: basePadding * 0.4),
                              Text(
                                'تم',
                                style: GoogleFonts.cairo(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18 : 14,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Container(
                          key: ValueKey(counters[index]),
                          width: counterSize,
                          height: counterSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withOpacity(0.15),
                            border: Border.all(
                              color: _gold.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${counters[index]}',
                                  style: GoogleFonts.cairo(
                                    fontSize: counterFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: _gold,
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }
}