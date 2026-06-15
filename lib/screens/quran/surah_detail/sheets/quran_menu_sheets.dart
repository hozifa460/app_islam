import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/surah_constants.dart';
import '../widgets/sheet_widgets.dart';

class QuranMenuSheets {
  // ─── القائمة الرئيسية ───
  static void showMainMenu({
    required BuildContext context,
    required String surahName,
    required String selectedReciterName,
    required Map<String, dynamic> savedMeta,
    required Color primary,
    required VoidCallback onIndexTap,
    required VoidCallback onSearchTap,
    required VoidCallback onQuickJumpTap,
    required VoidCallback onLastPositionTap,
    required VoidCallback onBookmarkTap,
    required VoidCallback onReciterTap,
  }) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetWidgets.buildSheetHeader(
                title: 'خيارات المصحف',
                subtitle: surahName,
                primary: primary,
                icon: Icons.menu_book_rounded,
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.list_alt_rounded,
                title: 'فهرس المصحف',
                subtitle: 'السور، الأجزاء، الأحزاب، الصفحات',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onIndexTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.search_rounded,
                title: 'البحث في القرآن',
                subtitle: 'ابحث عن كلمة أو آية',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onSearchTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.swap_horiz_rounded,
                title: 'الانتقال السريع',
                subtitle: 'اذهب مباشرة إلى صفحة معينة',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onQuickJumpTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.history_rounded,
                title: 'آخر موضع',
                subtitle: savedMeta['lastPage'] != null
                    ? 'الصفحة ${savedMeta['lastPage']}'
                    : 'لا يوجد موضع محفوظ',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onLastPositionTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.bookmark_rounded,
                title: 'الذهاب إلى العلامة',
                subtitle: savedMeta['bookmarkPage'] != null
                    ? 'الصفحة ${savedMeta['bookmarkPage']}'
                    : 'لا توجد علامة محفوظة',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onBookmarkTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.record_voice_over_rounded,
                title: 'اختيار القارئ',
                subtitle: selectedReciterName,
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onReciterTap();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── اختيار القارئ ───
  static void showReciterDialog({
    required BuildContext context,
    required String selectedReciterId,
    required Color primary,
    required Function(String id, String name) onReciterSelected,
  }) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetWidgets.buildSheetHeader(
                title: 'اختيار القارئ',
                subtitle: 'اختر قارئ التلاوة',
                primary: primary,
                icon: Icons.record_voice_over_rounded,
              ),
              ...SurahConstants.reciters.map(
                    (r) => SheetWidgets.buildModernSheetTile(
                  icon: Icons.person_rounded,
                  title: r['name']!,
                  subtitle: selectedReciterId == r['id'] ? 'القارئ الحالي' : null,
                  primary: primary,
                  trailing: selectedReciterId == r['id']
                      ? Icon(Icons.check_circle, color: primary)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    onReciterSelected(r['id']!, r['name']!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── الانتقال السريع ───
  static void showQuickJump({
    required BuildContext context,
    required int currentPage,
    required Color primary,
    required Function(int) onPageSelected,
  }) {
    final controller = TextEditingController(text: currentPage.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SheetWidgets.buildSheetHeader(
                    title: 'الانتقال السريع',
                    subtitle: 'اذهب إلى صفحة محددة',
                    primary: primary,
                    icon: Icons.swap_horiz_rounded,
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم الصفحة',
                      hintStyle: GoogleFonts.cairo(),
                      filled: true,
                      fillColor: primary.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary.withOpacity(0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary.withOpacity(0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final page = int.tryParse(controller.text.trim());

                        if (page == null || page < 1 || page > 604) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'أدخل رقم صفحة صحيح من 1 إلى 604',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(ctx);
                        onPageSelected(page);
                      },
                      child: Text(
                        'الانتقال إلى الصفحة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── وضع العرض ───
  static void showViewMode({
    required BuildContext context,
    required String currentMode,
    required Color primary,
    required Function(String) onModeSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF171A1E) : Colors.white,
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
                title: 'وضع العرض',
                subtitle: 'اختر طريقة عرض المصحف',
                primary: primary,
                icon: Icons.view_compact_rounded,
              ),
              SheetWidgets.buildViewModeTile(
                context: context,
                icon: Icons.image_rounded,
                title: 'وضع الصور',
                subtitle: 'عرض صفحات المصحف كصور',
                isSelected: currentMode == 'image',
                onTap: () {
                  Navigator.pop(ctx);
                  onModeSelected('image');
                },
              ),
              SheetWidgets.buildViewModeTile(
                context: context,
                icon: Icons.text_fields_rounded,
                title: 'وضع النص',
                subtitle: 'عرض نصي مع تظليل وتشغيل آية بآية',
                isSelected: currentMode == 'text',
                onTap: () {
                  Navigator.pop(ctx);
                  onModeSelected('text');
                },
              ),
              SheetWidgets.buildViewModeTile(
                context: context,
                icon: Icons.school_rounded,
                title: 'وضع الحفظ',
                subtitle: 'إخفاء الآيات تدريجياً للتسميع والحفظ',
                isSelected: currentMode == 'memorize',
                onTap: () {
                  Navigator.pop(ctx);
                  onModeSelected('memorize');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}