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

  // â”€â”€â”€ ط£ظ„ظˆط§ظ† ط­ط³ط¨ ط§ظ„ظˆط¶ط¹ â”€â”€â”€
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
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.06);

  Color get _itemBg => isDark
      ? Colors.white.withValues(alpha: 0.04)
      : Colors.black.withValues(alpha: 0.02);

  Color get _itemHover => isDark
      ? primary.withValues(alpha: 0.12)
      : primary.withValues(alpha: 0.07);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      elevation: 0,
      child: Column(
        children: [
          // â”€â”€ ط§ظ„ظ‡ظٹط¯ط± â”€â”€
          _buildHeader(),

          // â”€â”€ ط§ظ„ظپط§طµظ„ â”€â”€
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // â”€â”€ ط§ظ„ظ‚ط§ط¦ظ…ط© â”€â”€
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
              physics: const BouncingScrollPhysics(),
              itemCount: features.length,
              itemBuilder: (context, index) =>
                  _buildItem(context, index),
            ),
          ),

          // â”€â”€ ط§ظ„ظپظˆطھط± â”€â”€
          _buildFooter(),
        ],
      ),
    );
  }

  // â”€â”€â”€ ط§ظ„ظ‡ظٹط¯ط± â”€â”€â”€
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
          // ط§ظ„ط£ظٹظ‚ظˆظ†ط©
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
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

          // ط§ظ„ط§ط³ظ…
          Text(
            'ط·ط±ظٹظ‚ ط§ظ„ط¥ط³ظ„ط§ظ…',
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // ط§ظ„ظˆطµظپ
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ط±ظپظٹظ‚ظƒ ط§ظ„ط¥ط³ظ„ط§ظ…ظٹ ط§ظ„ظٹظˆظ…ظٹ âœ¨',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ ط¹ظ†طµط± ط§ظ„ظ‚ط§ط¦ظ…ط© â”€â”€â”€
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
          splashColor: primary.withValues(alpha: 0.10),
          highlightColor: primary.withValues(alpha: 0.06),
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
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                // ط£ظٹظ‚ظˆظ†ط© ظ…ط¹ ط®ظ„ظپظٹط©
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 
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

                // ط§ظ„ط¹ظ†ظˆط§ظ†
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

                // ط§ظ„ط±ظ…ط² ط§ظ„طھط¹ط¨ظٹط±ظٹ
                if (badge.isNotEmpty) ...[
                  Text(
                    badge,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(width: 6),
                ],

                // ط§ظ„ط³ظ‡ظ…
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: _textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€ ط§ظ„ظپظˆطھط± â”€â”€â”€
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
                color: primary.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                'ط¨ط³ظ… ط§ظ„ظ„ظ‡ ط§ظ„ط±ط­ظ…ظ† ط§ظ„ط±ط­ظٹظ…',
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
                color: primary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}