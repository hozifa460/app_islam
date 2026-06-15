import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// طھط£ظƒط¯ ظ…ظ† ظ…ط³ط§ط± ط§ظ„طھط±ط¬ظ…ط© ط§ظ„طµط­ظٹط­
import '../../../../../languages/app_localizations.dart';

class HasanatDialogs {
  static void showResetDialog({
    required BuildContext context,
    required Color bgCard,
    required Color gold,
    required VoidCallback onReset,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        // ًں‘ˆ ط¬ط¹ظ„ ط§ظ„ط§طھط¬ط§ظ‡ ط¯ظٹظ†ط§ظ…ظٹظƒظٹ ط­ط³ط¨ ط§ظ„ظ„ط؛ط©
        textDirection: context.tr.textDirection,
        child: AlertDialog(
          backgroundColor: bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: gold.withValues(alpha: 0.3)),
          ),
          title: Text(
            context.tr.resetCountersTitle, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            context.tr.resetCountersMsg, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
            style: GoogleFonts.cairo(
                fontSize: 15, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.tr.dialogCancel, // ًں‘ˆ ط§ظ„طھط±ط¬ظ…ط© ظ…ظˆط¬ظˆط¯ط© ظ…ط³ط¨ظ‚ط§ظ‹ ظ…ظ† ط­ظˆط§ط± ط§ظ„طµظ„ط§ط­ظٹط§طھ
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                onReset();
                Navigator.pop(ctx);
              },
              child: Text(
                context.tr.resetBtn, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                style: GoogleFonts.cairo(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}