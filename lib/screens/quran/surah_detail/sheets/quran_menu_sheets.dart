import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/surah_constants.dart';
import '../widgets/sheet_widgets.dart';

class QuranMenuSheets {
  // â”€â”€â”€ ط§ظ„ظ‚ط§ط¦ظ…ط© ط§ظ„ط±ط¦ظٹط³ظٹط© â”€â”€â”€
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
                title: 'ط®ظٹط§ط±ط§طھ ط§ظ„ظ…طµط­ظپ',
                subtitle: surahName,
                primary: primary,
                icon: Icons.menu_book_rounded,
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.list_alt_rounded,
                title: 'ظپظ‡ط±ط³ ط§ظ„ظ…طµط­ظپ',
                subtitle: 'ط§ظ„ط³ظˆط±طŒ ط§ظ„ط£ط¬ط²ط§ط،طŒ ط§ظ„ط£ط­ط²ط§ط¨طŒ ط§ظ„طµظپط­ط§طھ',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onIndexTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.search_rounded,
                title: 'ط§ظ„ط¨ط­ط« ظپظٹ ط§ظ„ظ‚ط±ط¢ظ†',
                subtitle: 'ط§ط¨ط­ط« ط¹ظ† ظƒظ„ظ…ط© ط£ظˆ ط¢ظٹط©',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onSearchTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.swap_horiz_rounded,
                title: 'ط§ظ„ط§ظ†طھظ‚ط§ظ„ ط§ظ„ط³ط±ظٹط¹',
                subtitle: 'ط§ط°ظ‡ط¨ ظ…ط¨ط§ط´ط±ط© ط¥ظ„ظ‰ طµظپط­ط© ظ…ط¹ظٹظ†ط©',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onQuickJumpTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.history_rounded,
                title: 'ط¢ط®ط± ظ…ظˆط¶ط¹',
                subtitle: savedMeta['lastPage'] != null
                    ? 'ط§ظ„طµظپط­ط© ${savedMeta['lastPage']}'
                    : 'ظ„ط§ ظٹظˆط¬ط¯ ظ…ظˆط¶ط¹ ظ…ط­ظپظˆط¸',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onLastPositionTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.bookmark_rounded,
                title: 'ط§ظ„ط°ظ‡ط§ط¨ ط¥ظ„ظ‰ ط§ظ„ط¹ظ„ط§ظ…ط©',
                subtitle: savedMeta['bookmarkPage'] != null
                    ? 'ط§ظ„طµظپط­ط© ${savedMeta['bookmarkPage']}'
                    : 'ظ„ط§ طھظˆط¬ط¯ ط¹ظ„ط§ظ…ط© ظ…ط­ظپظˆط¸ط©',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onBookmarkTap();
                },
              ),
              SheetWidgets.buildModernSheetTile(
                icon: Icons.record_voice_over_rounded,
                title: 'ط§ط®طھظٹط§ط± ط§ظ„ظ‚ط§ط±ط¦',
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

  // â”€â”€â”€ ط§ط®طھظٹط§ط± ط§ظ„ظ‚ط§ط±ط¦ â”€â”€â”€
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
                title: 'ط§ط®طھظٹط§ط± ط§ظ„ظ‚ط§ط±ط¦',
                subtitle: 'ط§ط®طھط± ظ‚ط§ط±ط¦ ط§ظ„طھظ„ط§ظˆط©',
                primary: primary,
                icon: Icons.record_voice_over_rounded,
              ),
              ...SurahConstants.reciters.map(
                    (r) => SheetWidgets.buildModernSheetTile(
                  icon: Icons.person_rounded,
                  title: r['name']!,
                  subtitle: selectedReciterId == r['id'] ? 'ط§ظ„ظ‚ط§ط±ط¦ ط§ظ„ط­ط§ظ„ظٹ' : null,
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

  // â”€â”€â”€ ط§ظ„ط§ظ†طھظ‚ط§ظ„ ط§ظ„ط³ط±ظٹط¹ â”€â”€â”€
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
                    title: 'ط§ظ„ط§ظ†طھظ‚ط§ظ„ ط§ظ„ط³ط±ظٹط¹',
                    subtitle: 'ط§ط°ظ‡ط¨ ط¥ظ„ظ‰ طµظپط­ط© ظ…ط­ط¯ط¯ط©',
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
                      hintText: 'ط£ط¯ط®ظ„ ط±ظ‚ظ… ط§ظ„طµظپط­ط©',
                      hintStyle: GoogleFonts.cairo(),
                      filled: true,
                      fillColor: primary.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary.withValues(alpha: 0.15)),
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
                                'ط£ط¯ط®ظ„ ط±ظ‚ظ… طµظپط­ط© طµط­ظٹط­ ظ…ظ† 1 ط¥ظ„ظ‰ 604',
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
                        'ط§ظ„ط§ظ†طھظ‚ط§ظ„ ط¥ظ„ظ‰ ط§ظ„طµظپط­ط©',
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

  // â”€â”€â”€ ظˆط¶ط¹ ط§ظ„ط¹ط±ط¶ â”€â”€â”€
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
                title: 'ظˆط¶ط¹ ط§ظ„ط¹ط±ط¶',
                subtitle: 'ط§ط®طھط± ط·ط±ظٹظ‚ط© ط¹ط±ط¶ ط§ظ„ظ…طµط­ظپ',
                primary: primary,
                icon: Icons.view_compact_rounded,
              ),
              SheetWidgets.buildViewModeTile(
                context: context,
                icon: Icons.image_rounded,
                title: 'ظˆط¶ط¹ ط§ظ„طµظˆط±',
                subtitle: 'ط¹ط±ط¶ طµظپط­ط§طھ ط§ظ„ظ…طµط­ظپ ظƒطµظˆط±',
                isSelected: currentMode == 'image',
                onTap: () {
                  Navigator.pop(ctx);
                  onModeSelected('image');
                },
              ),
              SheetWidgets.buildViewModeTile(
                context: context,
                icon: Icons.text_fields_rounded,
                title: 'ظˆط¶ط¹ ط§ظ„ظ†طµ',
                subtitle: 'ط¹ط±ط¶ ظ†طµظٹ ظ…ط¹ طھط¸ظ„ظٹظ„ ظˆطھط´ط؛ظٹظ„ ط¢ظٹط© ط¨ط¢ظٹط©',
                isSelected: currentMode == 'text',
                onTap: () {
                  Navigator.pop(ctx);
                  onModeSelected('text');
                },
              ),
              SheetWidgets.buildViewModeTile(
                context: context,
                icon: Icons.school_rounded,
                title: 'ظˆط¶ط¹ ط§ظ„ط­ظپط¸',
                subtitle: 'ط¥ط®ظپط§ط، ط§ظ„ط¢ظٹط§طھ طھط¯ط±ظٹط¬ظٹط§ظ‹ ظ„ظ„طھط³ظ…ظٹط¹ ظˆط§ظ„ط­ظپط¸',
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