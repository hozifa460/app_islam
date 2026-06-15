import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// تأكد من مسار الترجمة الصحيح
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
        // 👈 جعل الاتجاه ديناميكي حسب اللغة
        textDirection: context.tr.textDirection,
        child: AlertDialog(
          backgroundColor: bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: gold.withOpacity(0.3)),
          ),
          title: Text(
            context.tr.resetCountersTitle, // 👈 تمت الترجمة
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            context.tr.resetCountersMsg, // 👈 تمت الترجمة
            style: GoogleFonts.cairo(
                fontSize: 15, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.tr.dialogCancel, // 👈 الترجمة موجودة مسبقاً من حوار الصلاحيات
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                onReset();
                Navigator.pop(ctx);
              },
              child: Text(
                context.tr.resetBtn, // 👈 تمت الترجمة
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