import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class AsmaAllahDetailScreen extends StatefulWidget {
  final String name;
  final String meaning;
  final Color primaryColor;
  final int order;
  final List<Map<String, String>> names;
  final String heroTag;

  const AsmaAllahDetailScreen({
    super.key,
    required this.name,
    required this.meaning,
    required this.primaryColor,
    required this.order,
    required this.names,
    required this.heroTag,
  });

  @override
  State<AsmaAllahDetailScreen> createState() => _AsmaAllahDetailScreenState();
}

class _AsmaAllahDetailScreenState extends State<AsmaAllahDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeTop;
  late Animation<double> _fadeCard;
  late Animation<double> _fadeButtons;
  late Animation<Offset> _slideTop;
  late Animation<Offset> _slideCard;
  late Animation<Offset> _slideButtons;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeTop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _fadeCard = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.75, curve: Curves.easeOut),
    );

    _fadeButtons = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    _slideTop = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _slideCard = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _slideButtons = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shareName() async {
    await Share.share('${widget.name}\n\n${widget.meaning}');
  }

  void _goToName(BuildContext context, int newIndex) {
    final item = widget.names[newIndex - 1];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => AsmaAllahDetailScreen(
              name: item['name']!,
              meaning: item['meaning']!,
              primaryColor: widget.primaryColor,
              order: newIndex,
              names: widget.names,
              heroTag: 'asma_name_$newIndex',
            ),
      ),
    );
  }

  String _getReflectionForName(String name) {
    switch (name) {
      case 'الرحمن':
        return 'اسأل الله من رحمته الواسعة، واستشعر لطفه بك في كل حال.';
      case 'الرحيم':
        return 'تأمل كيف يرحم الله عباده، وأحسن إلى الناس كما تحب أن تُرحم.';
      case 'الغفور':
        return 'أكثر من الاستغفار، فباب المغفرة مفتوح لمن رجع إلى الله بصدق.';
      case 'الرزاق':
        return 'اطمئن، فما قُسم لك من رزق سيأتيك في وقته بحكمة الله.';
      case 'السميع':
        return 'ارفع دعاءك بيقين، فالله يسمع همسك ونداء قلبك.';
      case 'البصير':
        return 'استحضر نظر الله إليك، وأحسن عملك في السر والعلن.';
      case 'الهادي':
        return 'سل الله الهداية والثبات، فهو الهادي إلى الصراط المستقيم.';
      case 'العفو':
        return 'ارجُ عفو الله دائمًا، فهو يحب من عباده الرجوع والإنابة.';
      default:
        return 'تدبر هذا الاسم، وادعُ الله به، واستحضر أثره في حياتك اليومية.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reflection = _getReflectionForName(widget.name);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF8F6F1);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    const gold = Color(0xFFE6B325);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(86),
          child: AppBar(
            backgroundColor: widget.primaryColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.primaryColor,
                    widget.primaryColor.withOpacity(0.82),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 18,
                    child: Icon(
                      Icons.nightlight_round,
                      size: 34,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                  Positioned(
                    top: 28,
                    left: 48,
                    child: Icon(
                      Icons.star_rounded,
                      size: 10,
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 22,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    widget.name,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'الاسم رقم ${widget.order} من ${widget.names.length}',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          color: Colors.white.withOpacity(0.80),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 44,
                                      height: 10,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: 1.2,
                                            width: 44,
                                            color: Colors.white.withOpacity(0.22),
                                          ),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE6B325),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.55),
                                                width: 1,
                                              ),
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

                          const SizedBox(width: 10),

                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.share_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: _shareName,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.35,
                  child: CustomPaint(
                    painter: _AsmaSubtlePatternPainter(
                      color: widget.primaryColor.withOpacity(0.08),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final small = width < 360;

                  final circleSize = small ? 100.0 : 120.0;
                  final circleText = small ? 23.0 : 28.0;
                  final quoteText = small ? 18.0 : 22.0;
                  final titleText = small ? 15.0 : 16.0;
                  final bodyText = small ? 13.0 : 15.0;
                  final hintText = small ? 11.0 : 12.0;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        FadeTransition(
                          opacity: _fadeTop,
                          child: SlideTransition(
                            position: _slideTop,
                            child: Hero(
                              tag: widget.heroTag,
                              child: Material(
                                color: Colors.transparent,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: circleSize,
                                      height: circleSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: gold.withOpacity(0.12),
                                        border: Border.all(
                                          color: gold.withOpacity(0.25),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              widget.name,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.amiri(
                                                fontSize: circleText,
                                                fontWeight: FontWeight.bold,
                                                color: widget.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.primaryColor
                                              .withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '${widget.order}',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: widget.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        FadeTransition(
                          opacity: _fadeCard,
                          child: SlideTransition(
                            position: _slideCard,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Center(
                                  child: Container(
                                    width: 80,
                                    height: 12,
                                    alignment: Alignment.center,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 1.2,
                                          color: gold.withOpacity(0.35),
                                        ),
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: widget.primaryColor
                                                .withOpacity(0.85),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: gold.withOpacity(0.7),
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          widget.primaryColor.withOpacity(0.08),
                                          gold.withOpacity(0.10),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: gold.withOpacity(0.24),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            isDark ? 0.16 : 0.05,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: -4,
                                          left: -2,
                                          child: Icon(
                                            Icons.format_quote_rounded,
                                            size: 40,
                                            color: gold.withOpacity(0.18),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'المعنى',
                                                style: GoogleFonts.cairo(
                                                  fontSize: titleText,
                                                  fontWeight: FontWeight.bold,
                                                  color: widget.primaryColor,
                                                  ),
                                                ),

                                              const SizedBox(height: 10),
                                              Text(
                                                widget.meaning,
                                                textAlign: TextAlign.right,
                                                style: GoogleFonts.cairo(
                                                  fontSize: bodyText,
                                                  height: 1.8,
                                                  color: textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'تدبر هذا الاسم واستحضر أثره في قلبك ودعائك.',
                                                textAlign: TextAlign.right,
                                                style: GoogleFonts.cairo(
                                                  fontSize: hintText,
                                                  color: subTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: SizedBox(
                                      width: small ? 70 : 80,
                                      height: 12,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: small ? 70 : 80,
                                            height: 1.2,
                                            color: gold.withOpacity(0.35),
                                          ),
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: widget.primaryColor
                                                  .withOpacity(0.85),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: gold.withOpacity(0.7),
                                                width: 1.2,
                                              ),
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
                        ),

                        const SizedBox(height: 10),

                        FadeTransition(
                          opacity: _fadeCard,
                          child: SlideTransition(
                            position: _slideCard,
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      widget.primaryColor.withOpacity(0.08),
                                      gold.withOpacity(0.10),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: gold.withOpacity(0.24),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.16 : 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -4,
                                      left: -2,
                                      child: Icon(
                                        Icons.format_quote_rounded,
                                        size: 40,
                                        color: gold.withOpacity(0.18),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome_rounded,
                                              color: gold,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'تأمل ودعاء',
                                              style: GoogleFonts.cairo(
                                                fontSize: titleText,
                                                fontWeight: FontWeight.bold,
                                                color: widget.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '“$reflection”',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.amiri(
                                            fontSize: quoteText,
                                            height: 1.9,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : const Color(0xFF2E2415),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        FadeTransition(
                          opacity: _fadeButtons,
                          child: SlideTransition(
                            position: _slideButtons,
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: widget.primaryColor.withOpacity(
                                          0.25,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed:
                                        widget.order > 1
                                            ? () => _goToName(
                                              context,
                                              widget.order - 1,
                                            )
                                            : null,
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'السابق',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: widget.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed:
                                        widget.order < widget.names.length
                                            ? () => _goToName(
                                              context,
                                              widget.order + 1,
                                            )
                                            : null,
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'التالي',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AsmaSubtlePatternPainter extends CustomPainter {
  final Color color;

  _AsmaSubtlePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    const step = 80.0;

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
  bool shouldRepaint(covariant _AsmaSubtlePatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
