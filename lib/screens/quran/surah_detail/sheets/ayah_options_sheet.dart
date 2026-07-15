import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../services/quran/quran_text_service.dart';
import '../constants/surah_constants.dart';
import '../widgets/sheet_widgets.dart';

class AyahOptionsSheet {
  static void show({
    required BuildContext context,
    required int surahNumber,
    required int ayahNumber,
    required Color primary,
    required VoidCallback onPlayTap,
    required VoidCallback onRepeatTap,
    required VoidCallback onRecitateTap,
    required VoidCallback onBookmarkTap,
  }) {
    final text = QuranTextService.getAyahText(surahNumber, ayahNumber) ?? '';
    final surahIdx = surahNumber - 1;
    final surahName = surahIdx < SurahConstants.surahNames.length
        ? SurahConstants.surahNames[surahIdx]
        : '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetWidgets.buildSheetHeader(
                title: '$surahName - آية ${SurahConstants.toArabicNum(ayahNumber)}',
                primary: primary,
                icon: Icons.format_quote_rounded,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 22,
                    height: 2.0,
                  ),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  SheetWidgets.buildAyahOptionBtn(
                    icon: Icons.play_circle_filled,
                    label: 'تشغيل',
                    color: primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      onPlayTap();
                    },
                  ),
                  SheetWidgets.buildAyahOptionBtn(
                    icon: Icons.repeat,
                    label: 'تكرار ×3',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(ctx);
                      onRepeatTap();
                    },
                  ),
                  SheetWidgets.buildAyahOptionBtn(
                    icon: Icons.mic,
                    label: 'تسميع',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(ctx);
                      onRecitateTap();
                    },
                  ),
                  SheetWidgets.buildAyahOptionBtn(
                    icon: Icons.copy,
                    label: 'نسخ',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(ctx);
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم النسخ', style: GoogleFonts.cairo()),
                        ),
                      );
                    },
                  ),
                  SheetWidgets.buildAyahOptionBtn(
                    icon: Icons.bookmark_add,
                    label: 'علامة',
                    color: Colors.amber.shade700,
                    onTap: () {
                      Navigator.pop(ctx);
                      onBookmarkTap();
                    },
                  ),
                  SheetWidgets.buildAyahOptionBtn(
                    icon: Icons.share,
                    label: 'مشاركة',
                    color: Colors.purple,
                    onTap: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}