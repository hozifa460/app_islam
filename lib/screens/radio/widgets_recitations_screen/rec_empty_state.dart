// lib/screens/radio/widgets_recitations/rec_empty_state.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// حالة عدم وجود نتائج
/// ══════════════════════════════════════════════════════════════
class RecEmptyState extends StatelessWidget {
  const RecEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            'لا توجد نتائج',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: RecColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}