import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareContent() {
    final item = widget.item;
    final buffer = StringBuffer();
    buffer.writeln('✨ ${item['title']}');
    buffer.writeln('${item['subtitle']}');
    buffer.writeln();
    buffer.writeln('📖 ${item['source']}');
    buffer.writeln('📌 ${item['reference']}');
    buffer.writeln();
    buffer.writeln('📝 ${item['description']}');

    final sciExp = (item['scientificExplanation'] ?? '').toString();
    if (sciExp.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('🔬 $sciExp');
    }

    final scientist = (item['scientist'] ?? '').toString();
    final year = (item['discoveryYear'] ?? '').toString();
    if (scientist.isNotEmpty || year.isNotEmpty) {
      buffer.writeln();
      if (scientist.isNotEmpty) buffer.writeln('👤 العالم: $scientist');
      if (year.isNotEmpty) buffer.writeln('📅 سنة الاكتشاف: $year');
    }

    // Add sources
    final sourcesList = item['sources'];
    if (sourcesList is List && sourcesList.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('📚 المصادر:');
      for (final src in sourcesList) {
        if (src is Map) {
          buffer.writeln('• ${src['name'] ?? ''}: ${src['url'] ?? ''}');
        }
      }
    }

    buffer.writeln();
    buffer.writeln('— تطبيق الإعجاز العلمي');

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم النسخ بنجاح',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'علم الفلك':
        return Icons.stars_rounded;
      case 'علم الأجنة':
        return Icons.child_care_rounded;
      case 'علم البحار':
        return Icons.water_rounded;
      case 'علم الجيولوجيا':
        return Icons.terrain_rounded;
      case 'علم الفيزياء':
        return Icons.science_rounded;
      case 'علم المياه':
        return Icons.water_drop_rounded;
      case 'علم النبات':
        return Icons.local_florist_rounded;
      case 'علم الأحياء':
        return Icons.biotech_rounded;
      case 'علم الأحياء الدقيقة':
        return Icons.coronavirus_rounded;
      case 'علم الطب':
        return Icons.medical_services_rounded;
      case 'علم الأعصاب':
        return Icons.psychology_rounded;
      case 'علم الجغرافيا':
        return Icons.public_rounded;
      case 'علم النفس':
        return Icons.self_improvement_rounded;
      case 'علم الحشرات':
        return Icons.bug_report_rounded;
      case 'علم التغذية':
        return Icons.restaurant_rounded;
      case 'علم الصحة العامة':
        return Icons.health_and_safety_rounded;
      case 'إعجاز غيبي':
        return Icons.visibility_rounded;
      case 'إعجاز تاريخي':
        return Icons.history_edu_rounded;
      case 'معجزات نبوية':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'علم الفلك':
        return const Color(0xFF5C6BC0);
      case 'علم الأجنة':
        return const Color(0xFFEC407A);
      case 'علم البحار':
        return const Color(0xFF039BE5);
      case 'علم الجيولوجيا':
        return const Color(0xFF795548);
      case 'علم الفيزياء':
        return const Color(0xFF7E57C2);
      case 'علم المياه':
        return const Color(0xFF00ACC1);
      case 'علم النبات':
        return const Color(0xFF43A047);
      case 'علم الأحياء':
        return const Color(0xFF66BB6A);
      case 'علم الأحياء الدقيقة':
        return const Color(0xFFEF5350);
      case 'علم الطب':
        return const Color(0xFFE53935);
      case 'علم الأعصاب':
        return const Color(0xFFAB47BC);
      case 'علم الجغرافيا':
        return const Color(0xFF26A69A);
      case 'علم النفس':
        return const Color(0xFF8D6E63);
      case 'علم الحشرات':
        return const Color(0xFFFF7043);
      case 'علم التغذية':
        return const Color(0xFFFFA726);
      case 'علم الصحة العامة':
        return const Color(0xFF29B6F6);
      case 'إعجاز غيبي':
        return const Color(0xFFFFCA28);
      case 'إعجاز تاريخي':
        return const Color(0xFF8D6E63);
      case 'معجزات نبوية':
        return const Color(0xFFE6B325);
      default:
        return widget.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F5F0);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    const gold = Color(0xFFE6B325);

    final item = widget.item;
    final isQuran = item['type'] == 'quran';
    final accentColor = isQuran ? widget.primaryColor : gold;
    final youtubeUrl = (item['youtubeUrl'] ?? '').toString();
    final videoUrl = (item['videoUrl'] ?? '').toString();
    final book = (item['book'] ?? '').toString();
    final category = (item['category'] ?? '').toString();
    final catColor = _getCategoryColor(category);
    final catIcon = _getCategoryIcon(category);
    final scientificExplanation =
        (item['scientificExplanation'] ?? '').toString();
    final discoveryYear = (item['discoveryYear'] ?? '').toString();
    final scientist = (item['scientist'] ?? '').toString();
    final rating = (item['rating'] ?? 0) as int;

    // Parse sources list
    final sourcesList = item['sources'];
    final List<Map<String, dynamic>> sources = [];
    if (sourcesList is List) {
      for (final src in sourcesList) {
        if (src is Map) {
          sources.add(Map<String, dynamic>.from(src));
        }
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App Bar ───
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.28,
              pinned: true,
              backgroundColor: widget.primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      _isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(_isFav),
                      color: _isFav ? Colors.redAccent : Colors.white,
                      size: 22,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _isFav = !_isFav);
                    widget.onToggleFavorite?.call();
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: _copyToClipboard,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: _shareContent,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(
                  bottom: 14,
                  left: 60,
                  right: 60,
                ),
                title: Text(
                  item['title'] ?? '',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [catColor.withOpacity(0.6), widget.primaryColor],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: gold.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: Icon(catIcon, color: gold, size: 34),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Content ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Tags Row ──
                    _buildAnimatedWidget(
                      delay: 0,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(catIcon, size: 14, color: catColor),
                                const SizedBox(width: 4),
                                Flexible(
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isQuran ? '📖 القرآن الكريم' : '☪ السنة النبوية',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color:
                                    i < rating
                                        ? gold
                                        : subTextColor.withOpacity(0.2),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Source Card ──
                    _buildAnimatedWidget(
                      delay: 100,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.2 : 0.06,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isQuran
                                      ? Icons.menu_book_rounded
                                      : Icons.format_quote_rounded,
                                  color: accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isQuran ? 'النص القرآني' : 'الحديث النبوي',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: accentColor.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                item['source'] ?? '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.amiri(
                                  fontSize: 20,
                                  height: 1.9,
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: [
                                Flexible(
                                  child: _buildTag(
                                    item['reference'] ?? '',
                                    accentColor,
                                  ),
                                ),
                                if (book.isNotEmpty)
                                  Flexible(
                                    child: _buildTag(book, subTextColor),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Description Card ──
                    _buildAnimatedWidget(
                      delay: 200,
                      child: _buildSectionCard(
                        icon: Icons.description_rounded,
                        title: 'وجه الإعجاز',
                        content: item['description'] ?? '',
                        color: widget.primaryColor,
                        cardColor: cardColor,
                        textColor: textColor,
                        isDark: isDark,
                      ),
                    ),

                    // ── Scientific Explanation Card ──
                    if (scientificExplanation.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildAnimatedWidget(
                        delay: 300,
                        child: _buildSectionCard(
                          icon: Icons.science_rounded,
                          title: 'التفسير العلمي',
                          content: scientificExplanation,
                          color: const Color(0xFF7E57C2),
                          cardColor: cardColor,
                          textColor: textColor,
                          isDark: isDark,
                        ),
                      ),
                    ],

                    // ── Discovery Info Card ──
                    if (discoveryYear.isNotEmpty || scientist.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildAnimatedWidget(
                        delay: 400,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: gold.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.15 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history_edu_rounded,
                                    color: gold,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'معلومات الاكتشاف',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: gold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (discoveryYear.isNotEmpty)
                                _buildInfoRow(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'سنة الاكتشاف',
                                  value: discoveryYear,
                                  color: gold,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                ),
                              if (discoveryYear.isNotEmpty &&
                                  scientist.isNotEmpty)
                                Divider(
                                  color: subTextColor.withOpacity(0.1),
                                  height: 20,
                                ),
                              if (scientist.isNotEmpty)
                                _buildInfoRow(
                                  icon: Icons.person_rounded,
                                  label: 'العالم / المكتشف',
                                  value: scientist,
                                  color: gold,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // ── Sources / References Card ──
                    if (sources.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildAnimatedWidget(
                        delay: 450,
                        child: _buildSourcesCard(
                          sources: sources,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          isDark: isDark,
                        ),
                      ),
                    ],

                    // ── Video Links ──
                    if (youtubeUrl.isNotEmpty || videoUrl.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildAnimatedWidget(
                        delay: 500,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: gold.withOpacity(0.18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.video_library_rounded,
                                    color: widget.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'محتوى مرئي مرتبط',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: widget.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (youtubeUrl.isNotEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _openUrl(youtubeUrl),
                                    icon: const Icon(
                                      Icons.play_circle_fill_rounded,
                                    ),
                                    label: Text(
                                      'مشاهدة على يوتيوب',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (youtubeUrl.isNotEmpty && videoUrl.isNotEmpty)
                                const SizedBox(height: 10),
                              if (videoUrl.isNotEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: widget.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      side: BorderSide(
                                        color: widget.primaryColor.withOpacity(
                                          0.25,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () => _openUrl(videoUrl),
                                    icon: const Icon(
                                      Icons.video_library_rounded,
                                    ),
                                    label: Text(
                                      'مشاهدة الفيديو المباشر',
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

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ─── Bottom Action Bar ───
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 320;

                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: _shareContent,
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'مشاركة',
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
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.primaryColor,
                            side: BorderSide(
                              color: widget.primaryColor.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'نسخ',
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
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Material(
                        color: _isFav
                            ? Colors.redAccent.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() => _isFav = !_isFav);
                            widget.onToggleFavorite?.call();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isFav
                                    ? Colors.redAccent.withOpacity(0.3)
                                    : subTextColor.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  _isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(_isFav),
                                  color: _isFav
                                      ? Colors.redAccent
                                      : subTextColor.withOpacity(0.5),
                                  size: 20,
                                ),
                              ),
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
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  SOURCES CARD (NEW)
  // ═══════════════════════════════════════════════
  Widget _buildSourcesCard({
    required List<Map<String, dynamic>> sources,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.source_rounded,
                  color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'المصادر والمراجع',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${sources.length}',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...sources.asMap().entries.map((entry) {
            final index = entry.key;
            final source = entry.value;
            final name = (source['name'] ?? '').toString();
            final url = (source['url'] ?? '').toString();
            final isLast = index == sources.length - 1;

            return Column(
              children: [
                InkWell(
                  onTap: url.isNotEmpty ? () => _openUrl(url) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.08)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          child: Center(
                            child: FittedBox(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (url.isNotEmpty)
                                Text(
                                  url,
                                  style: GoogleFonts.cairo(
                                    fontSize: 9.5,
                                    color: Colors.blue.shade400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (url.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 14,
                            color: Colors.blue.shade400,
                          ),
                        ],
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

  // ═══════════════════════════════════════════════
  //  HELPER WIDGETS
  // ═══════════════════════════════════════════════
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
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
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
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
              height: 1.9,
              color: textColor.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
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
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: subTextColor,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedWidget({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
