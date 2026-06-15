// lib/screens/radio/widgets_surahs/rs_search_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_colors.dart';
import 'package:islamic_app/screens/radio/widgets_recitation_surahs_screen/theme/rs_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// شريط البحث
/// ══════════════════════════════════════════════════════════════
class RsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Color primary;
  final ValueChanged<String> onChanged;

  const RsSearchBar({
    super.key,
    required this.controller,
    required this.primary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: RsShapes.searchBar(primary,context),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        onChanged: onChanged,
        style: GoogleFonts.cairo(
          fontSize: 13,
          color: RsColors.searchText(context), // ✅ من RsColors
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة...',
          hintStyle: GoogleFonts.cairo(
            color: RsColors.searchHint(context), // ✅ من RsColors
            fontSize: RsSizes.searchHintSize,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: RsColors.primary(primary, 0.5), // ✅ من RsColors
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}