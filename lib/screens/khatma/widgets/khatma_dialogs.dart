import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';

class KhatmaDialogs {
  // ✅ حوار التهنئة
  static void showCongratsDialog({
    required BuildContext context,
    required Color primaryColor,
    required VoidCallback onReset,
  }) {
    final tr = context.tr; // ✅ الصحيح

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.amber.shade300,
                    Colors.amber.shade600,
                  ]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events,
                    size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(tr.t('khatmaCongratsTitle'),
                  style: GoogleFonts.cairo(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                tr.t('khatmaCongratsMsg'),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                    color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onReset();
                  },
                  child: Text(tr.t('khatmaStartNew'),
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(tr.t('khatmaLater'),
                    style: GoogleFonts.cairo(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ حوار إعادة الختمة
  static void showResetDialog({
    required BuildContext context,
    required VoidCallback onReset,
  }) {
    final tr = context.tr; // ✅ الصحيح

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 10),
            Text(tr.t('khatmaConfirmReset'),
                style:
                GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          tr.t('khatmaResetWarning'),
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.t('khatmaCancel'),
                style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              onReset();
            },
            child: Text(tr.t('khatmaReset'),
                style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}