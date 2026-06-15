import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'color_control/miracle_color_provider.dart';
import 'color_control/miracle_theme.dart';
import 'widgets/miracle_helpers.dart';
import 'widgets/star_field_widget.dart';

class MiracleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color primaryColor;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const MiracleDetailScreen({
    super.key,
    required this.item,
    required this.primaryColor,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  State<MiracleDetailScreen> createState() => _MiracleDetailScreenState();
}

class _MiracleDetailScreenState extends State<MiracleDetailScreen>
    with TickerProviderStateMixin {
  // â”€â”€ Controllers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late AnimationController _animController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;

  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late bool _isFav;
  final List<StarParticle> _particles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    for (int i = 0; i < 55; i++) {
      _particles.add(StarParticle.random(_rng));
    }

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ACTIONS
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareContent() {
    final item = widget.item;
    final buffer = StringBuffer();
    buffer.writeln('âœ¨ ${item['title']}');
    buffer.writeln('${item['subtitle']}');
    buffer.writeln();
    buffer.writeln('ًں“– ${item['source']}');
    buffer.writeln('ًں“Œ ${item['reference']}');
    buffer.writeln();
    buffer.writeln('ًں“‌ ${item['description']}');

    final sciExp = (item['scientificExplanation'] ?? '').toString();
    if (sciExp.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('ًں”¬ $sciExp');
    }

    final scientist = (item['scientist'] ?? '').toString();
    final year = (item['discoveryYear'] ?? '').toString();
    if (scientist.isNotEmpty || year.isNotEmpty) {
      buffer.writeln();
      if (scientist.isNotEmpty) buffer.writeln('ًں‘¤ ط§ظ„ط¹ط§ظ„ظ…: $scientist');
      if (year.isNotEmpty) buffer.writeln('ًں“… ط³ظ†ط© ط§ظ„ط§ظƒطھط´ط§ظپ: $year');
    }

    final sourcesList = item['sources'];
    if (sourcesList is List && sourcesList.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('ًں“ڑ ط§ظ„ظ…طµط§ط¯ط±:');
      for (final src in sourcesList) {
        if (src is Map) {
          buffer.writeln('â€¢ ${src['name'] ?? ''}: ${src['url'] ?? ''}');
        }
      }
    }

    buffer.writeln();
    buffer.writeln('â€” طھط·ط¨ظٹظ‚ ط§ظ„ط¥ط¹ط¬ط§ط² ط§ظ„ط¹ظ„ظ…ظٹ');
    Share.share(buffer.toString().trim());
  }

  void _copyToClipboard() {
    final item = widget.item;
    final buffer = StringBuffer();
    buffer.writeln(item['title']);
    buffer.writeln(item['source']);
    buffer.writeln(item['reference']);
    buffer.writeln(item['description']);

    final sciExp = (item['scientificExplanation'] ?? '').toString();
    if (sciExp.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(sciExp);
    }

    Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'طھظ… ط§ظ„ظ†ط³ط® ط¨ظ†ط¬ط§ط­ âœ“',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: MiracleTheme.neonBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  BUILD
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = MiracleTheme.of(isDark);

    final item = widget.item;
    final isQuran = item['type'] == 'quran';
    final accentColor =
        isQuran ? const Color(0xFF4FC3F7) : MiracleTheme.neonGold;
    final category = (item['category'] ?? '').toString();
    final catColor = MiracleHelpers.getCategoryColor(category);
    final catIcon = MiracleHelpers.getCategoryIcon(category);
    final emoji = MiracleHelpers.getCategoryEmoji(category);
    final engCategory = MiracleHelpers.getCategoryEnglish(category);
    final sciExp = (item['scientificExplanation'] ?? '').toString();
    final discoveryYear = (item['discoveryYear'] ?? '').toString();
    final scientist = (item['scientist'] ?? '').toString();
    final youtubeUrl = (item['youtubeUrl'] ?? '').toString();
    final videoUrl = (item['videoUrl'] ?? '').toString();
    final book = (item['book'] ?? '').toString();
    final rating = (item['rating'] ?? 0) as int;

    final sourcesList = item['sources'];
    final List<Map<String, dynamic>> sources = [];
    if (sourcesList is List) {
      for (final src in sourcesList) {
        if (src is Map) sources.add(Map<String, dynamic>.from(src));
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: t.bg1,
          child: Stack(
            children: [
              // ط®ظ„ظپظٹط© ظ…طھط­ط±ظƒط©
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  color: t.bg1,
                ),
              ),
              // ظ†ط¬ظˆظ…
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder:
                      (_, __) => StarFieldWidget(
                        particles: _particles,
                        animValue: _particleController.value,
                        starOpacityFactor: t.starOpacityFactor,
                        nebulaOpacityFactor: t.nebulaOpacityFactor,
                        primaryColor: t.neonBlue,
                        bg1: t.bg1,
                      ),
                ),
              ),
              // Scaffold ط´ظپط§ظپ ظ„ظ„ظ€ AppBar ظپظ‚ط·
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    // â”€â”€ Star field â”€â”€
                    AnimatedBuilder(
                      animation: _particleController,
                      builder:
                          (_, __) => StarFieldWidget(
                            particles: _particles,
                            animValue: _particleController.value,
                            starOpacityFactor: t.starOpacityFactor,
                            nebulaOpacityFactor: t.nebulaOpacityFactor,
                            primaryColor: t.neonBlue,
                            bg1: t.bg1,
                          ),
                    ),

                    // â”€â”€ Content â”€â”€
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // â”€â”€ App Bar â”€â”€
                          _buildAppBar(
                            t: t,
                            catColor: catColor,
                            catIcon: catIcon,
                            emoji: emoji,
                            engCategory: engCategory,
                            isQuran: isQuran,
                            accentColor: accentColor,
                            item: item,
                          ),

                          // â”€â”€ Body â”€â”€
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: Column(
                                children: [
                                  // Tags row
                                  _buildAnimated(
                                    delay: 0,
                                    child: _TagsRow(
                                      catColor: catColor,
                                      catIcon: catIcon,
                                      category: category,
                                      accentColor: accentColor,
                                      isQuran: isQuran,
                                      rating: rating,
                                      t: t,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Source card
                                  _buildAnimated(
                                    delay: 80,
                                    child: _SourceCard(
                                      item: item,
                                      accentColor: accentColor,
                                      isQuran: isQuran,
                                      book: book,
                                      t: t,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Description
                                  _buildAnimated(
                                    delay: 160,
                                    child: _SectionCard(
                                      icon: Icons.description_rounded,
                                      title: 'ظˆط¬ظ‡ ط§ظ„ط¥ط¹ط¬ط§ط²',
                                      content:
                                          (item['description'] ?? '')
                                              .toString(),
                                      color: MiracleTheme.neonBlue,
                                      t: t,
                                    ),
                                  ),

                                  // Scientific explanation
                                  if (sciExp.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    _buildAnimated(
                                      delay: 240,
                                      child: _SectionCard(
                                        icon: Icons.science_rounded,
                                        title: 'ط§ظ„طھظپط³ظٹط± ط§ظ„ط¹ظ„ظ…ظٹ',
                                        content: sciExp,
                                        color: const Color(0xFFCE93D8),
                                        t: t,
                                      ),
                                    ),
                                  ],

                                  // Discovery info
                                  if (discoveryYear.isNotEmpty ||
                                      scientist.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    _buildAnimated(
                                      delay: 320,
                                      child: _DiscoveryCard(
                                        discoveryYear: discoveryYear,
                                        scientist: scientist,
                                        t: t,
                                      ),
                                    ),
                                  ],

                                  // Sources
                                  if (sources.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    _buildAnimated(
                                      delay: 400,
                                      child: _SourcesCard(
                                        sources: sources,
                                        t: t,
                                        onOpenUrl: _openUrl,
                                      ),
                                    ),
                                  ],

                                  // Video links
                                  if (youtubeUrl.isNotEmpty ||
                                      videoUrl.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    _buildAnimated(
                                      delay: 480,
                                      child: _VideoCard(
                                        youtubeUrl: youtubeUrl,
                                        videoUrl: videoUrl,
                                        accentColor: accentColor,
                                        t: t,
                                        onOpenUrl: _openUrl,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // â”€â”€ Bottom bar â”€â”€
                bottomNavigationBar: _BottomBar(
                  isFav: _isFav,
                  accentColor: accentColor,
                  t: t,
                  onShare: _shareContent,
                  onCopy: _copyToClipboard,
                  onToggleFav: () {
                    setState(() => _isFav = !_isFav);
                    widget.onToggleFavorite?.call();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  APP BAR
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildAppBar({
    required MiracleThemeColors t,
    required Color catColor,
    required IconData catIcon,
    required String emoji,
    required String engCategory,
    required bool isQuran,
    required Color accentColor,
    required Map<String, dynamic> item,
  }) {
    final expandedH = MediaQuery.of(context).size.height * 0.30;

    return SliverAppBar(
      expandedHeight: expandedH,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: t.bg1.withValues(alpha: 0.95),

      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: t.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.glassBorder),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),

      actions: [
        _buildActionBtn(
          icon: _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _isFav ? MiracleTheme.neonRed : Colors.white,
          t: t,
          onTap: () {
            setState(() => _isFav = !_isFav);
            widget.onToggleFavorite?.call();
          },
        ),
        _buildActionBtn(
          icon: Icons.copy_rounded,
          color: Colors.white,
          t: t,
          onTap: _copyToClipboard,
        ),
        _buildActionBtn(
          icon: Icons.share_rounded,
          color: Colors.white,
          t: t,
          onTap: _shareContent,
        ),
        const SizedBox(width: 4),
      ],

      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 14),
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: Text(
            (item['title'] ?? '').toString(),
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              shadows: [
                Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        background: _DetailAppBarBackground(
          t: t,
          catColor: catColor,
          catIcon: catIcon,
          emoji: emoji,
          engCategory: engCategory,
          pulseAnim: _pulseAnim,
          isQuran: isQuran,
          accentColor: accentColor,
          item: item,
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required Color color,
    required MiracleThemeColors t,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: t.glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.glassBorder),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _buildAnimated({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder:
          (_, value, __) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - value)),
              child: child,
            ),
          ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  APP BAR BACKGROUND
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _DetailAppBarBackground extends StatelessWidget {
  final MiracleThemeColors t;
  final Color catColor;
  final IconData catIcon;
  final String emoji;
  final String engCategory;
  final Animation<double> pulseAnim;
  final bool isQuran;
  final Color accentColor;
  final Map<String, dynamic> item;

  const _DetailAppBarBackground({
    required this.t,
    required this.catColor,
    required this.catIcon,
    required this.emoji,
    required this.engCategory,
    required this.pulseAnim,
    required this.isQuran,
    required this.accentColor,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [catColor.withValues(alpha: 0.3), t.bg2, t.bg1],
        ),
      ),
      child: Stack(
        children: [
          // Emoji watermark
          Positioned(
            top: -10,
            right: -10,
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 150,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Glow orbs
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [catColor.withValues(alpha: 0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MiracleTheme.neonBlue.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Centre content
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 55),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing icon
                  AnimatedBuilder(
                    animation: pulseAnim,
                    builder:
                        (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    catColor.withValues(alpha: 
                                      0.18 * pulseAnim.value,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.07),
                                border: Border.all(
                                  color: catColor.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: catColor.withValues(alpha: 
                                      0.28 * pulseAnim.value,
                                    ),
                                    blurRadius: 22,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(catIcon, color: catColor, size: 30),
                            ),
                          ],
                        ),
                  ),

                  const SizedBox(height: 8),

                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      isQuran ? 'ًں“– ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ…' : 'âکھ ط§ظ„ط³ظ†ط© ط§ظ„ظ†ط¨ظˆظٹط©',
                      style: GoogleFonts.cairo(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  TAGS ROW
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _TagsRow extends StatelessWidget {
  final Color catColor;
  final IconData catIcon;
  final String category;
  final Color accentColor;
  final bool isQuran;
  final int rating;
  final MiracleThemeColors t;

  const _TagsRow({
    required this.catColor,
    required this.catIcon,
    required this.category,
    required this.accentColor,
    required this.isQuran,
    required this.rating,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Category tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: catColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(catIcon, size: 13, color: catColor),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  category,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: catColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Type tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            isQuran ? 'ًں“– ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ…' : 'âکھ ط§ظ„ط³ظ†ط© ط§ظ„ظ†ط¨ظˆظٹط©',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ),

        // Rating stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color:
                  i < rating
                      ? MiracleTheme.neonGold
                      : Colors.white.withValues(alpha: 0.2),
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  SOURCE CARD  (ط¢ظٹط© / ط­ط¯ظٹط«)
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _SourceCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color accentColor;
  final bool isQuran;
  final String book;
  final MiracleThemeColors t;

  const _SourceCard({
    required this.item,
    required this.accentColor,
    required this.isQuran,
    required this.book,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  isQuran
                      ? Icons.menu_book_rounded
                      : Icons.format_quote_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isQuran ? 'ط§ظ„ظ†طµ ط§ظ„ظ‚ط±ط¢ظ†ظٹ' : 'ط§ظ„ط­ط¯ظٹط« ط§ظ„ظ†ط¨ظˆظٹ',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Source text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.12)),
            ),
            child: Text(
              (item['source'] ?? '').toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 20,
                height: 1.9,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Reference + book
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GlassTag(
                text: (item['reference'] ?? '').toString(),
                color: accentColor,
                t: t,
              ),
              if (book.isNotEmpty)
                _GlassTag(text: book, color: Colors.white54, t: t),
            ],
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  SECTION CARD  (description / scientific)
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final MiracleThemeColors t;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              height: 1.95,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  DISCOVERY CARD
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _DiscoveryCard extends StatelessWidget {
  final String discoveryYear;
  final String scientist;
  final MiracleThemeColors t;

  const _DiscoveryCard({
    required this.discoveryYear,
    required this.scientist,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MiracleTheme.neonGold.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: MiracleTheme.neonGold.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: MiracleTheme.neonGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MiracleTheme.neonGold.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.history_edu_rounded,
                  color: MiracleTheme.neonGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ط§ظƒطھط´ط§ظپ',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: MiracleTheme.neonGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (discoveryYear.isNotEmpty)
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'ط³ظ†ط© ط§ظ„ط§ظƒطھط´ط§ظپ',
              value: discoveryYear,
              color: MiracleTheme.neonGold,
            ),

          if (discoveryYear.isNotEmpty && scientist.isNotEmpty)
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 20),

          if (scientist.isNotEmpty)
            _InfoRow(
              icon: Icons.person_rounded,
              label: 'ط§ظ„ط¹ط§ظ„ظ… / ط§ظ„ظ…ظƒطھط´ظپ',
              value: scientist,
              color: MiracleTheme.neonGold,
            ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  SOURCES CARD
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _SourcesCard extends StatelessWidget {
  final List<Map<String, dynamic>> sources;
  final MiracleThemeColors t;
  final Future<void> Function(String) onOpenUrl;

  const _SourcesCard({
    required this.sources,
    required this.t,
    required this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<MiracleColorProvider>();
    final t = MiracleTheme.of(isDark, provider: provider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MiracleTheme.neonBlue.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: MiracleTheme.neonBlue.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: MiracleTheme.neonBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MiracleTheme.neonBlue.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.source_rounded,
                  color: MiracleTheme.neonBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ط§ظ„ظ…طµط§ط¯ط± ظˆط§ظ„ظ…ط±ط§ط¬ط¹',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: MiracleTheme.neonBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: MiracleTheme.neonBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${sources.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: MiracleTheme.neonBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Source items
          ...sources.asMap().entries.map((entry) {
            final index = entry.key;
            final source = entry.value;
            final name = (source['name'] ?? '').toString();
            final url = (source['url'] ?? '').toString();
            final isLast = index == sources.length - 1;

            return Column(
              children: [
                GestureDetector(
                  onTap: url.isNotEmpty ? () => onOpenUrl(url) : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MiracleTheme.neonBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MiracleTheme.neonBlue.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Index circle
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MiracleTheme.neonBlue.withValues(alpha: 0.1),
                            border: Border.all(
                              color: MiracleTheme.neonBlue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: MiracleTheme.neonBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Name + URL
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (url.isNotEmpty)
                                Text(
                                  url,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: MiracleTheme.neonBlue.withValues(alpha: 
                                      0.7,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                        if (url.isNotEmpty)
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 14,
                            color: MiracleTheme.neonBlue.withValues(alpha: 0.7),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!isLast) const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  VIDEO CARD
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _VideoCard extends StatelessWidget {
  final String youtubeUrl;
  final String videoUrl;
  final Color accentColor;
  final MiracleThemeColors t;
  final Future<void> Function(String) onOpenUrl;

  const _VideoCard({
    required this.youtubeUrl,
    required this.videoUrl,
    required this.accentColor,
    required this.t,
    required this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  Icons.video_library_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ظ…ط­طھظˆظ‰ ظ…ط±ط¦ظٹ ظ…ط±طھط¨ط·',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // YouTube button
          if (youtubeUrl.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => onOpenUrl(youtubeUrl),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                label: Text(
                  'ظ…ط´ط§ظ‡ط¯ط© ط¹ظ„ظ‰ ظٹظˆطھظٹظˆط¨',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ),

          if (youtubeUrl.isNotEmpty && videoUrl.isNotEmpty)
            const SizedBox(height: 10),

          // Direct video button
          if (videoUrl.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => onOpenUrl(videoUrl),
                icon: const Icon(Icons.video_library_rounded, size: 20),
                label: Text(
                  'ظ…ط´ط§ظ‡ط¯ط© ط§ظ„ظپظٹط¯ظٹظˆ ط§ظ„ظ…ط¨ط§ط´ط±',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  BOTTOM BAR
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _BottomBar extends StatelessWidget {
  final bool isFav;
  final Color accentColor;
  final MiracleThemeColors t;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onToggleFav;

  const _BottomBar({
    required this.isFav,
    required this.accentColor,
    required this.t,
    required this.onShare,
    required this.onCopy,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: t.bg2,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 320;

            return Row(
              children: [
                // Share
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor.withValues(alpha: 0.15),
                        foregroundColor: accentColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: onShare,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ظ…ط´ط§ط±ظƒط©',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 11 : 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Copy
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MiracleTheme.neonBlue.withValues(alpha: 
                          0.12,
                        ),
                        foregroundColor: MiracleTheme.neonBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: MiracleTheme.neonBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ظ†ط³ط®',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 11 : 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Favorite toggle
                GestureDetector(
                  onTap: onToggleFav,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          isFav
                              ? MiracleTheme.neonRed.withValues(alpha: 0.15)
                              : t.glass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            isFav
                                ? MiracleTheme.neonRed.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.15),
                        width: isFav ? 1.5 : 1,
                      ),
                      boxShadow:
                          isFav
                              ? [
                                BoxShadow(
                                  color: MiracleTheme.neonRed.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                ),
                              ]
                              : [],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder:
                            (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(isFav),
                          color: isFav ? MiracleTheme.neonRed : Colors.white38,
                          size: 20,
                        ),
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
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  SMALL REUSABLE WIDGETS
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _GlassTag extends StatelessWidget {
  final String text;
  final Color color;
  final MiracleThemeColors t;

  const _GlassTag({required this.text, required this.color, required this.t});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
