import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../mircle/color_control/miracle_color_provider.dart';
import '../../mircle/color_control/miracle_theme.dart';
import '../../mircle/mircle_detail_screen.dart';
import '../../mircle/widgets/miracle_helpers.dart';
import '../../mircle/widgets/star_field_widget.dart';
import 'home_card_skeleton.dart';

class HomeMiracleCard extends StatefulWidget {
  final Color                 primary;
  final Color                 gold;
  final Color                 cardColor;
  final bool                  isDark;
  final Map<String, dynamic>? miracle;
  final bool                  isLoaded;

  const HomeMiracleCard({
    super.key,
    required this.primary,
    required this.gold,
    required this.cardColor,
    required this.isDark,
    required this.miracle,
    required this.isLoaded,
  });

  @override
  State<HomeMiracleCard> createState() => _HomeMiracleCardState();
}

class _HomeMiracleCardState extends State<HomeMiracleCard>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _entryController;
  late AnimationController _floatController;
  late Animation<double>   _entryFade;
  late Animation<double>   _entrySlide;
  late Animation<double>   _floatAnim;
  final List<StarParticle> _particles = [];
  final _rng = Random();

  Color get _cardBg => widget.isDark
      ? const Color(0xFF0D1829)   // Dark: ظ†ظپط³ ط§ظ„ظ„ظˆظ†
      : const Color(0xFFFFFFFFF); // Light: ط£ط¨ظٹط¶
  Color get _glass => widget.isDark
      ? const Color(0x18FFFFFF)
      : Colors.black.withValues(alpha: 0.04);

  Color get _glassBorder => widget.isDark
      ? const Color(0x30FFFFFF)
      : Colors.black.withValues(alpha: 0.08);
  Color get _textColor => widget.isDark
      ? Colors.white
      : const Color(0xFF1A1A2E);
  Color get _mutedColor => widget.isDark
      ? const Color(0x99FFFFFF)
      : Colors.black54;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _entryController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _floatController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _entryFade = CurvedAnimation(
        parent: _entryController, curve: Curves.easeOut);
    _entrySlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
          parent: _entryController, curve: Curves.easeOutCubic),
    );
    _floatAnim = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    for (int i = 0; i < 20; i++) {
      _particles.add(StarParticle.random(_rng));
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Color _getPrimary() {
    try {
      return context.read<MiracleColorProvider>().effectivePrimary;
    } catch (_) {
      return widget.primary;
    }
  }

  void _toDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MiracleDetailScreen(
          item:         item,
          primaryColor: _getPrimary(),
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end:   Offset.zero,
            ).animate(CurvedAnimation(
                parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color neonBlue = const Color(0xFF00D4FF);
    try {
      final provider = context.watch<MiracleColorProvider>();
      neonBlue = provider.effectivePrimary;
    } catch (_) {}

    if (!widget.isLoaded || widget.miracle == null) {
      return HomeCardSkeleton(
        isDark: widget.isDark,
        height: 120,
        borderRadius: BorderRadius.circular(20),
      );
    }
    return _buildCard(widget.miracle!, neonBlue);
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // LOADER â€” ط£ظ‚طµط±
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildLoader(Color neonBlue) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color:        _cardBg,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(color: _glassBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Container(
            width:  38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color:  MiracleThemeColors.neonGold.withValues(alpha: 0.08),
              border: Border.all(
                color: MiracleThemeColors.neonGold.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: MiracleThemeColors.neonGold,
              size:  18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color:        _glass,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 8,
                  width:  80,
                  decoration: BoxDecoration(
                    color:        _glass,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width:  16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth:     1.8,
              color:           neonBlue,
              backgroundColor: neonBlue.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Color _fixLightColor(Color c, Color appPrimary) {
    final hsl = HSLColor.fromColor(c);
    final primaryHsl = HSLColor.fromColor(appPrimary);

    // ط¥ط°ط§ ظƒط§ظ† ط§ظ„ظ„ظˆظ† ظˆط±ط¯ظٹ/ط£ط­ظ…ط± â†’ ط§ط³طھط¨ط¯ظ„ظ‡ ط¨ظ„ظˆظ† ط§ظ„طھط·ط¨ظٹظ‚
    if (hsl.hue >= 300 || hsl.hue <= 30) {
      return HSLColor.fromAHSL(
        1.0,
        primaryHsl.hue,                        // â†گ hue ظ…ظ† ظ„ظˆظ† ط§ظ„طھط·ط¨ظٹظ‚
        primaryHsl.saturation * 0.75,
        primaryHsl.lightness.clamp(0.30, 0.45),
      ).toColor();
    }

    // ط¨ط§ظ‚ظٹ ط§ظ„ط£ظ„ظˆط§ظ†: ط؛ظ…ظ‘ظ‚ظ‡ط§ ظپظ‚ط·
    return Color.lerp(c, const Color(0xFF1A1A2E), 0.35)!;
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // CARD â€” ظ…ظڈظ‚ظ„ظژظ‘طµ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildCard(Map<String, dynamic> item, Color neonBlue) {
    final isQuran     = item['type'] == 'quran';
    final accentColor = isQuran
        ? neonBlue
        : MiracleThemeColors.neonGold;
    final category  = (item['category'] ?? '').toString();
    final rawCatColor = MiracleHelpers.getCategoryColor(category);
    final catColor = widget.isDark
        ? rawCatColor
        : _fixLightColor(rawCatColor, widget.primary);
    final catIcon   = MiracleHelpers.getCategoryIcon(category);
    final emoji     = MiracleHelpers.getCategoryEmoji(category);
    final title     = (item['title']    ?? '').toString();
    final subtitle  = (item['subtitle'] ?? '').toString();
    final source    = (item['source']   ?? '').toString();
    final rating    = (item['rating']   ?? 0) as int;
    final scientist = (item['scientist']     ?? '').toString();
    final year      = (item['discoveryYear'] ?? '').toString();
    final sources   = item['sources'];
    final srcCount  = (sources is List) ? sources.length : 0;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (_, child) => Opacity(
        opacity: _entryFade.value.clamp(0.0, 1.0),
        child:   Transform.translate(
          offset: Offset(0, _entrySlide.value),
          child:  child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color:        _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: catColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color:      catColor.withValues(alpha: 0.06),
              blurRadius: 14,
              offset:     const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [

              // â”€â”€ ط®ظ„ظپظٹط© Light Mode â”€â”€
              if (!widget.isDark)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, __) => _buildLightBg(
                      catColor: catColor,
                      isQuran:  isQuran,
                      neonBlue: neonBlue,
                      floatVal: _floatAnim.value,
                    ),
                  ),
                ),

              // â”€â”€ gradient â”€â”€
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin:  Alignment.topRight,
                      end:    Alignment.bottomLeft,
                      colors: [
                        catColor.withValues(alpha: widget.isDark ? 0.07 : 0.05),
                        _cardBg,
                      ],
                    ),
                  ),
                ),
              ),

              // â”€â”€ Emoji watermark â”€â”€
              Positioned(
                bottom: -8,
                left:   -8,
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 55,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // â”€â”€ ظ†ط¬ظˆظ… Dark ظپظ‚ط· â”€â”€
              if (widget.isDark)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particleController,
                    builder: (_, __) => StarFieldWidget(
                      particles:           _particles,
                      animValue:           _particleController.value,
                      starOpacityFactor:   0.20,
                      nebulaOpacityFactor: 0.0,
                      primaryColor:        catColor,
                      bg1:                 _cardBg,
                    ),
                  ),
                ),

              // â”€â”€ ط§ظ„ظ…ط­طھظˆظ‰ â”€â”€
              Material(
                color:        Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor:    catColor.withValues(alpha: 0.08),
                  highlightColor: catColor.withValues(alpha: 0.04),
                  onTap: () => _toDetail(item),
                  child: Padding(
                    // âœ… padding ظ…ظڈظ‚ظ„ظژظ‘طµ
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // â”€â”€ ط§ظ„طµظپ ط§ظ„ط¹ظ„ظˆظٹ: ط¨ط§ط¯ط¬ + ط£ظٹظ‚ظˆظ†ط© + ط¹ظ†ظˆط§ظ† â”€â”€
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ط£ظٹظ‚ظˆظ†ط© ط§ظ„ظپط¦ط©
                            Container(
                              width:  44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin:  Alignment.topLeft,
                                  end:    Alignment.bottomRight,
                                  colors: [
                                    catColor.withValues(alpha: 0.2),
                                    catColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                border: Border.all(
                                    color: catColor.withValues(alpha: 0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color:     catColor.withValues(alpha: 0.10),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(catIcon, color: catColor, size: 20),
                            ),

                            const SizedBox(width: 10),

                            // ط§ظ„ط¹ظ†ظˆط§ظ† + ط§ظ„ط¨ط§ط¯ط¬
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  // ط¨ط§ط¯ط¬ ظ…ط¹ط¬ط²ط© ط§ظ„ظٹظˆظ… â€” ظ…ظڈطµط؛ظژظ‘ط±
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: MiracleThemeColors.neonGold
                                          .withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: MiracleThemeColors.neonGold
                                            .withValues(alpha: 0.22),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome_rounded,
                                          color: MiracleThemeColors.neonGold,
                                          size:  9,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'ظ…ط¹ط¬ط²ط© ط§ظ„ظٹظˆظ…',
                                          style: GoogleFonts.cairo(
                                            fontSize:   8.5,
                                            fontWeight: FontWeight.bold,
                                            color: MiracleThemeColors.neonGold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // ط§ظ„ط¹ظ†ظˆط§ظ†
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize:   13,
                                      fontWeight: FontWeight.bold,
                                      color:      _textColor,
                                      height:     1.3,
                                    ),
                                  ),

                                  // ط§ظ„ظˆطµظپ ط§ظ„ظپط±ط¹ظٹ
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.5,
                                      color:    _mutedColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // â”€â”€ Source â€” ط£ظ‚طµط± â”€â”€
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical:    8,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: accentColor.withValues(alpha: 0.10)),
                          ),
                          child: Text(
                            source,
                            maxLines:  2,
                            overflow:  TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.amiri(
                              fontSize:   12.5,
                              height:     1.6,
                              color: widget.isDark
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : const Color(0xFF1A1A2E).withValues(alpha: 0.75),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // â”€â”€ ط§ظ„طµظپ ط§ظ„ط³ظپظ„ظٹ: Tags + ط²ط± â”€â”€
                        Row(
                          children: [

                            // Tags ظپظٹ Wrap ظ…ظڈط¯ظ…ط¬ط©
                            Expanded(
                              child: Wrap(
                                spacing:    4,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [

                                  // ظ†ط¬ظˆظ… ط§ظ„طھظ‚ظٹظٹظ…
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(5, (i) => Icon(
                                      i < rating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: i < rating
                                          ? MiracleThemeColors.neonGold
                                          : widget.isDark
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : Colors.black.withValues(alpha: 0.12),
                                      size: 12,
                                    )),
                                  ),

                                  if (srcCount > 0)
                                    _Tag(
                                      icon:  Icons.link_rounded,
                                      text:  '$srcCount ظ…طµط¯ط±',
                                      color: neonBlue,
                                      isDark: widget.isDark,
                                    ),

                                  if (year.isNotEmpty)
                                    _Tag(
                                      icon:  Icons.calendar_today_rounded,
                                      text:  year,
                                      color: _mutedColor,
                                      isDark: widget.isDark,
                                    )
                                  else if (scientist.isNotEmpty)
                                    _Tag(
                                      icon:  Icons.person_rounded,
                                      text:  scientist,
                                      color: _mutedColor,
                                      isDark: widget.isDark,
                                    ),

                                  _Tag(
                                    text:   category,
                                    color:  catColor,
                                    filled: true,
                                    isDark: widget.isDark,
                                  ),

                                  _Tag(
                                    icon: isQuran
                                        ? Icons.menu_book_rounded
                                        : Icons.auto_awesome_rounded,
                                    text:   isQuran ? 'ظ‚ط±ط¢ظ†' : 'ط³ظ†ط©',
                                    color:  accentColor,
                                    filled: true,
                                    isDark: widget.isDark,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // â”€â”€ ط²ط± ط§ظ‚ط±ط£ ط§ظ„ظ…ط²ظٹط¯ â€” ظ…ظڈطµط؛ظژظ‘ط± â”€â”€
                            GestureDetector(
                              onTap: () => _toDetail(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: accentColor.withValues(alpha: 0.20)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ط§ظ„ظ…ط²ظٹط¯',
                                      style: GoogleFonts.cairo(
                                        fontSize:   10.5,
                                        fontWeight: FontWeight.bold,
                                        color:      accentColor,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size:  9,
                                      color: accentColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط®ظ„ظپظٹط© Light Mode
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildLightBg({
    required Color  catColor,
    required bool   isQuran,
    required Color  neonBlue,
    required double floatVal,
  }) {
    final icons = isQuran
        ? [
      Icons.menu_book_rounded,
      Icons.auto_awesome_rounded,
      Icons.star_rounded,
      Icons.wb_sunny_rounded,
    ]
        : [
      Icons.science_rounded,
      Icons.biotech_rounded,
      Icons.public_rounded,
      Icons.bolt_rounded,
    ];

    return Stack(
      children: [
        Positioned(
          top: -20 + floatVal,
          right: -15,
          child: _GeomCircle(size: 90,  color: catColor, opacity: 0.06),
        ),
        Positioned(
          bottom: -15 - floatVal,
          left: -20,
          child: _GeomCircle(size: 75,  color: MiracleThemeColors.neonGold, opacity: 0.05),
        ),
        Positioned(
          top: 15 + floatVal * 0.8,
          right: 50,
          child: _GeomSquare(size: 30, color: catColor, opacity: 0.05, angle: 0.4),
        ),
        Positioned(
          top: 20 + floatVal,
          left: 15,
          child: CustomPaint(
            size: const Size(40, 40),
            painter: _HexagonPainter(color: catColor, opacity: 0.06),
          ),
        ),
        Positioned(
          top: 10 + floatVal,
          right: 14,
          child: Icon(icons[0], size: 18, color: catColor.withValues(alpha: 0.10)),
        ),
        Positioned(
          top: 40 - floatVal * 0.7,
          right: 44,
          child: Icon(icons[1], size: 13, color: MiracleThemeColors.neonGold.withValues(alpha: 0.08)),
        ),
        Positioned(
          bottom: 20 + floatVal * 0.5,
          right: 18,
          child: Icon(icons[2], size: 14, color: neonBlue.withValues(alpha: 0.07)),
        ),
        Positioned(
          bottom: 15 - floatVal * 0.8,
          right: 48,
          child: Icon(icons[3], size: 11, color: catColor.withValues(alpha: 0.08)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DotGridPainter(color: catColor, opacity: 0.035),
          ),
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط£ط´ظƒط§ظ„ ظ‡ظ†ط¯ط³ظٹط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class _GeomCircle extends StatelessWidget {
  final double size, opacity;
  final Color  color;
  const _GeomCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: opacity * 2), width: 1.2),
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _GeomSquare extends StatelessWidget {
  final double size, opacity, angle;
  final Color  color;
  const _GeomSquare({
    required this.size,
    required this.color,
    required this.opacity,
    required this.angle,
  });
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width:  size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: opacity * 2), width: 1),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color  color;
  final double opacity;
  const _HexagonPainter({required this.color, required this.opacity});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) path.moveTo(x, y);
      else         path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path,
        Paint()..color = color.withValues(alpha: opacity)..style = PaintingStyle.fill);
    canvas.drawPath(path,
        Paint()
          ..color       = color.withValues(alpha: opacity * 2.5)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 1);
  }
  @override
  bool shouldRepaint(_HexagonPainter o) => false;
}

class _DotGridPainter extends CustomPainter {
  final Color  color;
  final double opacity;
  const _DotGridPainter({required this.color, required this.opacity});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    const spacing = 20.0;
    const dotSize = 1.0;
    for (double x = spacing; x < size.width;  x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }
  @override
  bool shouldRepaint(_DotGridPainter o) => false;
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// TAG
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _Tag extends StatelessWidget {
  final IconData? icon;
  final String    text;
  final Color     color;
  final bool      filled;
  final bool      isDark;

  const _Tag({
    this.icon,
    required this.text,
    required this.color,
    this.filled = false,
    this.isDark = true,
  });

  static const _glass = Color(0x18FFFFFF);

  @override
  Widget build(BuildContext context) {
    final glassBg = isDark
        ? const Color(0x18FFFFFF)
        : Colors.black.withValues(alpha: 0.04);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : glassBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 2),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize:   8.5,
                fontWeight: FontWeight.bold,
                color:      color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}