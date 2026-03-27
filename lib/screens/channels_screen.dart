import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ChannelsScreen extends StatefulWidget {
  final Color? primaryColor;
  const ChannelsScreen({super.key, this.primaryColor});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  static const _bgDark  = Color(0xFF0A0E17);
  static const _bgLight = Color(0xFFF0F4FF);
  static const _gold    = Color(0xFFE6B325);

  int  _selectedCategory = 0;
  bool _loading          = true;

  List<Map<String, dynamic>> _scholars   = [];
  List<String>               _categories = ['الكل'];

  @override
  void initState() {
    super.initState();
    _loadScholars();
  }

  Future<void> _loadScholars() async {
    try {
      final jsonStr = await rootBundle
          .loadString('assets/json/channels.json');
      final List<dynamic> data = json.decode(jsonStr);
      final scholars =
      data.map((e) => Map<String, dynamic>.from(e)).toList();

      final cats = <String>{'الكل'};
      for (final s in scholars) {
        cats.add(s['category'] as String);
      }

      setState(() {
        _scholars   = scholars;
        _categories = cats.toList();
        _loading    = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedCategory == 0) return _scholars;
    final cat = _categories[_selectedCategory];
    return _scholars.where((s) => s['category'] == cat).toList();
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  IconData _platformIcon(String icon) {
    switch (icon) {
      case 'youtube':  return Icons.play_circle_filled_rounded;
      case 'tiktok':   return Icons.music_note_rounded;
      case 'twitter':  return Icons.alternate_email_rounded;
      case 'facebook': return Icons.facebook_rounded;
      case 'telegram': return Icons.send_rounded;
      default:         return Icons.link_rounded;
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('لا يمكن فتح الرابط',
              style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final size      = MediaQuery.of(context).size;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    // ✅ أحجام متجاوبة
    final w = size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? _bgDark : _bgLight,
        body: Stack(
          children: [
            // خلفية
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [const Color(0xFF0D1520), _bgDark]
                        : [const Color(0xFFEEF3FF), _bgLight],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: _loading
                  ? _buildLoading(isDark)
                  : Column(
                children: [
                  _buildHeader(isDark, textColor, w),
                  SizedBox(height: w * 0.025),
                  _buildCategoryFilter(isDark, textColor, w),
                  SizedBox(height: w * 0.02),
                  Expanded(
                    child: _buildList(isDark, textColor, w),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── تحميل ──
  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _gold, strokeWidth: 3),
          const SizedBox(height: 14),
          Text('جارٍ تحميل البيانات...',
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              )),
        ],
      ),
    );
  }

  // ── هيدر ──
  Widget _buildHeader(bool isDark, Color textColor, double w) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          w * 0.04, w * 0.02, w * 0.04, 0),
      child: Row(
        children: [
          // زر الرجوع
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : _gold.withOpacity(0.25),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: textColor,
                  size: (w * 0.045).clamp(16.0, 22.0)),
              onPressed: () => Navigator.pop(context),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),

          SizedBox(width: w * 0.03),

          // العنوان
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'قنوات العلماء والدعاة',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.048).clamp(15.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_scholars.length} شيخ وعالم',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.028).clamp(10.0, 13.0),
                    color: textColor.withOpacity(0.48),
                  ),
                ),
              ],
            ),
          ),

          // شارة LIVE
          _LiveBadge(
            dotSize:  (w * 0.022).clamp(7.0, 10.0),
            fontSize: (w * 0.028).clamp(10.0, 13.0),
            px:       w * 0.025,
            py:       w * 0.014,
          ),
        ],
      ),
    );
  }

  // ── فلتر التصنيفات ──
  Widget _buildCategoryFilter(
      bool isDark, Color textColor, double w) {
    return SizedBox(
      height: (w * 0.088).clamp(32.0, 42.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: w * 0.04),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final active = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.only(left: w * 0.02),
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.035,
                vertical: w * 0.012,
              ),
              decoration: BoxDecoration(
                color: active
                    ? _gold
                    : (isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.white.withOpacity(0.88)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? _gold
                      : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : _gold.withOpacity(0.2)),
                ),
                boxShadow: active
                    ? [
                  BoxShadow(
                    color: _gold.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Text(
                _categories[i],
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.03).clamp(10.0, 13.0),
                  fontWeight: FontWeight.w700,
                  color: active
                      ? Colors.white
                      : textColor.withOpacity(0.65),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── القائمة ──
  Widget _buildList(
      bool isDark, Color textColor, double w) {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد علماء في هذا التصنيف',
          style: GoogleFonts.cairo(
              color: textColor.withOpacity(0.5),
              fontSize: (w * 0.035).clamp(12.0, 16.0)),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
          w * 0.04, w * 0.01, w * 0.04, w * 0.07),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 260 + i * 50),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - v)),
              child: child,
            ),
          ),
          child: _ScholarCard(
            scholar:    list[i],
            isDark:     isDark,
            textColor:  textColor,
            gold:       _gold,
            w:          w,
            hexToColor: _hexToColor,
            iconFor:    _platformIcon,
            onOpen:     _openUrl,
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  بطاقة الشيخ - محمية بالكامل من الـ Overflow
// ══════════════════════════════════════════════════════════════
class _ScholarCard extends StatelessWidget {
  final Map<String, dynamic> scholar;
  final bool     isDark;
  final Color    textColor;
  final Color    gold;
  final double   w;
  final Color    Function(String)        hexToColor;
  final IconData Function(String)        iconFor;
  final Future<void> Function(String)    onOpen;

  const _ScholarCard({
    required this.scholar,
    required this.isDark,
    required this.textColor,
    required this.gold,
    required this.w,
    required this.hexToColor,
    required this.iconFor,
    required this.onOpen,
  });

  List<Map<String, dynamic>> get _platforms =>
      (scholar['platforms'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  @override
  Widget build(BuildContext context) {
    final hasLive = _platforms.any((p) => p.containsKey('live_url'));

    return Container(
      margin: EdgeInsets.only(bottom: w * 0.035),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : gold.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.14 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(hasLive),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
          _buildPlatformsSection(),
        ],
      ),
    );
  }

  // ── رأس البطاقة ──
  Widget _buildHeader(bool hasLive) {
    final avatarSize = (w * 0.15).clamp(52.0, 68.0);
    final nameFontSize = (w * 0.038).clamp(13.0, 17.0);
    final subFontSize  = (w * 0.028).clamp(10.0, 13.0);
    final tagFontSize  = (w * 0.025).clamp(9.0, 11.5);

    return Padding(
      padding: EdgeInsets.all(w * 0.035),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── الأفاتار ──
          _buildAvatar(avatarSize),

          SizedBox(width: w * 0.03),

          // ── المعلومات ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // الاسم + LIVE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        scholar['name'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasLive) ...[
                      SizedBox(width: w * 0.015),
                      _LiveBadge(
                        dotSize:  (w * 0.016).clamp(5.0, 8.0),
                        fontSize: (w * 0.024).clamp(8.0, 11.0),
                        px:       w * 0.018,
                        py:       w * 0.008,
                      ),
                    ],
                  ],
                ),

                SizedBox(height: w * 0.01),

                // الوصف
                Text(
                  scholar['title'] as String,
                  style: GoogleFonts.cairo(
                    fontSize: subFontSize,
                    color: textColor.withOpacity(0.52),
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: w * 0.018),

                // التصنيف + الدولة
                Wrap(
                  spacing: w * 0.015,
                  runSpacing: w * 0.01,
                  children: [
                    // التصنيف
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.022,
                        vertical: w * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: gold.withOpacity(0.25)),
                      ),
                      child: Text(
                        scholar['category'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: tagFontSize,
                          fontWeight: FontWeight.w700,
                          color: gold,
                        ),
                      ),
                    ),

                    // الدولة
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.022,
                        vertical: w * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            scholar['flag'] as String,
                            style: TextStyle(
                                fontSize: tagFontSize),
                          ),
                          SizedBox(width: w * 0.01),
                          Flexible(
                            child: Text(
                              scholar['country'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: tagFontSize,
                                fontWeight: FontWeight.w600,
                                color:
                                textColor.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  // ── الأفاتار مع أعلام المنصات ──
  Widget _buildAvatar(double avatarSize) {
    final visible = _platforms.take(3).toList();
    final flagSize = (avatarSize * 0.34).clamp(14.0, 22.0);

    return SizedBox(
      width: avatarSize + flagSize * 0.5,
      height: avatarSize + flagSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // صورة الشيخ
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: gold.withOpacity(0.45),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  scholar['image'] as String,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: gold.withOpacity(0.08),
                      child: Center(
                        child: SizedBox(
                          width: avatarSize * 0.35,
                          height: avatarSize * 0.35,
                          child: CircularProgressIndicator(
                            color: gold,
                            strokeWidth: 2,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: gold.withOpacity(0.08),
                    child: Icon(Icons.person_rounded,
                        color: gold, size: avatarSize * 0.45),
                  ),
                ),
              ),
            ),
          ),

          // أعلام المنصات في الأسفل
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: visible.asMap().entries.map((e) {
                final i = e.key;
                final p = e.value;
                final pColor = hexToColor(p['color'] as String);
                final img = p['channel_image'] as String? ?? '';

                return Transform.translate(
                  offset: Offset(i * -(flagSize * 0.35), 0),
                  child: Container(
                    width: flagSize,
                    height: flagSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF0A0E17)
                            : Colors.white,
                        width: 1.5,
                      ),
                      color: pColor.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: pColor.withOpacity(0.18),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: img.isNotEmpty
                          ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _iconFallback(pColor, p, flagSize),
                      )
                          : _iconFallback(pColor, p, flagSize),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconFallback(
      Color pColor, Map<String, dynamic> p, double size) {
    return Container(
      color: pColor.withOpacity(0.15),
      child: Icon(
        iconFor(p['icon'] as String),
        color: pColor,
        size: size * 0.55,
      ),
    );
  }

  // ── قسم المنصات ──
  Widget _buildPlatformsSection() {
    final labelFontSize = (w * 0.027).clamp(9.5, 12.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        w * 0.035,
        w * 0.025,
        w * 0.035,
        w * 0.035,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'المنصات المتاحة:',
            style: GoogleFonts.cairo(
              fontSize: labelFontSize,
              color: textColor.withOpacity(0.42),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: w * 0.02),
          // ✅ Wrap يمنع الـ Overflow تلقائياً
          Wrap(
            spacing: w * 0.02,
            runSpacing: w * 0.02,
            children: _platforms.map((p) {
              return _PlatformItem(
                platform:   p,
                scholar:    scholar,
                isDark:     isDark,
                textColor:  textColor,
                gold:       gold,
                w:          w,
                hexToColor: hexToColor,
                iconFor:    iconFor,
                onOpen:     onOpen,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  عنصر المنصة - مستقل وآمن من الـ Overflow
// ══════════════════════════════════════════════════════════════
class _PlatformItem extends StatelessWidget {
  final Map<String, dynamic>           platform;
  final Map<String, dynamic>           scholar;
  final bool                           isDark;
  final Color                          textColor;
  final Color                          gold;
  final double                         w;
  final Color    Function(String)      hexToColor;
  final IconData Function(String)      iconFor;
  final Future<void> Function(String)  onOpen;

  const _PlatformItem({
    required this.platform,
    required this.scholar,
    required this.isDark,
    required this.textColor,
    required this.gold,
    required this.w,
    required this.hexToColor,
    required this.iconFor,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final pColor     = hexToColor(platform['color'] as String);
    final isLive     = platform.containsKey('live_url');
    final channelImg = platform['channel_image'] as String? ?? '';
    final subscribers = platform['subscribers'] as String? ?? '';
    final imgSize    = (w * 0.072).clamp(26.0, 36.0);
    final flagSize   = (w * 0.034).clamp(12.0, 17.0);
    final nameFontSize = (w * 0.029).clamp(10.0, 13.0);
    final subFontSize  = (w * 0.024).clamp(8.5, 11.0);

    return Wrap(
      spacing: w * 0.018,
      runSpacing: w * 0.015,
      children: [
        // ── زر المنصة ──
        GestureDetector(
          onTap: () => onOpen(platform['url'] as String),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.028,
              vertical: w * 0.018,
            ),
            decoration: BoxDecoration(
              color: pColor.withOpacity(isDark ? 0.13 : 0.07),
              borderRadius:
              BorderRadius.circular((w * 0.03).clamp(10.0, 14.0)),
              border: Border.all(color: pColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── صورة القناة + علم الدولة ──
                SizedBox(
                  width: imgSize + flagSize * 0.5,
                  height: imgSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // صورة القناة
                      Container(
                        width: imgSize,
                        height: imgSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pColor.withOpacity(0.15),
                          border: Border.all(
                            color: pColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: channelImg.isNotEmpty
                              ? Image.network(
                            channelImg,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _fallback(pColor, imgSize),
                          )
                              : _fallback(pColor, imgSize),
                        ),
                      ),

                      // علم الدولة
                      Positioned(
                        bottom: -flagSize * 0.2,
                        left: -flagSize * 0.1,
                        child: Container(
                          width: flagSize,
                          height: flagSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF0A0E17)
                                : Colors.white,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.grey.withOpacity(0.22),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              scholar['flag'] as String,
                              style: TextStyle(
                                  fontSize: flagSize * 0.65),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: w * 0.022),

                // النصوص
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      platform['name'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w700,
                        color: pColor,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          platform['handle'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: subFontSize,
                            color: textColor.withOpacity(0.45),
                          ),
                        ),
                        if (subscribers.isNotEmpty) ...[
                          SizedBox(width: w * 0.01),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: textColor.withOpacity(0.28),
                            ),
                          ),
                          SizedBox(width: w * 0.01),
                          Text(
                            subscribers,
                            style: GoogleFonts.cairo(
                              fontSize: subFontSize,
                              fontWeight: FontWeight.w700,
                              color: pColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── زر البث المباشر ──
        if (isLive)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onOpen(platform['live_url'] as String);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.028,
                vertical: w * 0.018,
              ),
              decoration: BoxDecoration(
                color: Colors.red
                    .withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(
                    (w * 0.03).clamp(10.0, 14.0)),
                border: Border.all(
                    color: Colors.red.withOpacity(0.32)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingDot(
                      size: (w * 0.02).clamp(6.0, 9.0)),
                  SizedBox(width: w * 0.014),
                  Text(
                    'بث مباشر',
                    style: GoogleFonts.cairo(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallback(Color pColor, double size) {
    return Container(
      color: pColor.withOpacity(0.15),
      child: Icon(
        iconFor(platform['icon'] as String),
        color: pColor,
        size: size * 0.5,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  نقطة البث المتحركة
// ══════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  final double size;
  const _PulsingDot({required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width:  widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withOpacity(_anim.value),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(_anim.value * 0.4),
              blurRadius: widget.size,
              spreadRadius: widget.size * 0.2,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  شارة LIVE
// ══════════════════════════════════════════════════════════════
class _LiveBadge extends StatelessWidget {
  final double dotSize;
  final double fontSize;
  final double px;
  final double py;

  const _LiveBadge({
    required this.dotSize,
    required this.fontSize,
    required this.px,
    required this.py,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(size: dotSize),
          SizedBox(width: dotSize * 0.6),
          Text(
            'LIVE',
            style: GoogleFonts.cairo(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}