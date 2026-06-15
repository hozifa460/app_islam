// lib/screens/radio/widgets_recitations/rec_search_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_shapes.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// شريط البحث
/// ══════════════════════════════════════════════════════════════
class RecSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Color primary;
  final ValueChanged<String> onChanged;

  const RecSearchBar({
    super.key,
    required this.controller,
    required this.primary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 42,
        decoration: RecShapes.searchBar(context, primary),
        child: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          onChanged: onChanged,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: RecColors.searchText(context),
          ),
          decoration: InputDecoration(
            hintText: 'ابحث...',
            hintStyle: GoogleFonts.cairo(
              color: RecColors.searchHint(context),
              fontSize: 12,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: RecColors.primary(primary, 0.5),
              size: 18,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }
}