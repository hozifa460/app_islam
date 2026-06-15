import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDrawer extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final List<Map<String, dynamic>> features;
  final Function(int) onFeatureTap;

  const HomeDrawer({
    super.key,
    required this.primary,
    required this.isDark,
    required this.features,
    required this.onFeatureTap,
  });

  // ─── ألوان حسب الوضع ───
  Color get _bg => isDark
      ? const Color(0xFF0E1714)
      : const Color(0xFFF7F3EA);

  Color get _surface => isDark
      ? const Color(0xFF13211D)
      : Colors.white;

  Color get _textPrimary => isDark
      ? Colors.white
      : const Color(0xFF1A1A2E);

  Color get _textSecondary => isDark
      ? Colors.white60
      : Colors.black54;

  Color get _divider => isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.06);

  Color get _itemBg => isDark
      ? Colors.white.withOpacity(0.04)
      : Colors.black.withOpacity(0.02);

  Color get _itemHover => isDark
      ? primary.withOpacity(0.12)
      : primary.withOpacity(0.07);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      elevation: 0,
      child: Column(
        children: [
          // ── الهيدر ──
          _buildHeader(),

          // ── الفاصل ──
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ── القائمة ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
              physics: const BouncingScrollPhysics(),
              itemCount: features.length,
              itemBuilder: (context, index) =>
                  _buildItem(context, index),
            ),
          ),

          // ── الفوتر ──
          _buildFooter(),
        ],
      ),
    );
  }

  // ─── الهيدر ───
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            Color.lerp(primary, Colors.black, 0.30)!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الأيقونة
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Image.asset(
                'assets/icon/icon.png',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.mosque_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // الاسم
          Text(
            'طريق الإسلام',
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // الوصف
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'رفيقك الإسلامي اليومي ✨',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── عنصر القائمة ───
  Widget _buildItem(BuildContext context, int index) {
    final feature = features[index];
    final title = feature['title'] as String;
    final icon = feature['icon'] as IconData;
    final badge = feature['badge'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pop(context);
            onFeatureTap(index);
          },
          splashColor: primary.withOpacity(0.10),
          highlightColor: primary.withOpacity(0.06),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: _itemBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.04),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                // أيقونة مع خلفية
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(
                      isDark ? 0.12 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    color: primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),

                // العنوان
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: _textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // الرمز التعبيري
                if (badge.isNotEmpty) ...[
                  Text(
                    badge,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(width: 6),
                ],

                // السهم
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: _textSecondary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── الفوتر ───
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _divider,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 12,
                color: primary.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                'بسم الله الرحمن الرحيم',
                style: GoogleFonts.amiri(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.favorite_rounded,
                size: 12,
                color: primary.withOpacity(0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}