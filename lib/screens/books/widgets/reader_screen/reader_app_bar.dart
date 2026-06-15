import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/books_theme.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
/// ط´ط±ظٹط· ط§ظ„طھط·ط¨ظٹظ‚ ظ„ظ‚ط§ط±ط¦ PDF - ظ†ظپط³ ط§ظ„ط´ظƒظ„ ط§ظ„ظ‚ط¯ظٹظ…
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class ReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentPage;
  final int totalPages;
  final Color primaryColor;
  final bool isTtsPlaying;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onTtsToggle;
  final VoidCallback onSearch;
  final VoidCallback onTableOfContents;
  final VoidCallback onSettings;

  const ReaderAppBar({
    super.key,
    required this.title,
    required this.currentPage,
    required this.totalPages,
    required this.primaryColor,
    required this.isTtsPlaying,
    this.isOnline = false,
    required this.onBack,
    required this.onFavorite,
    required this.onTtsToggle,
    required this.onSearch,
    required this.onTableOfContents,
    required this.onSettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      toolbarHeight: 52,
      leadingWidth: 46,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
        onPressed: onBack,
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          // ط¹ط¯ط§ط¯ ط§ظ„طµظپط­ط§طھ ط£ظˆ ط­ط§ظ„ط© ط£ظˆظ†ظ„ط§ظٹظ†
          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: isOnline
                ? Text(
              'ظ‚ط±ط§ط،ط© ط£ظˆظ†ظ„ط§ظٹظ† ًںŒگ',
              key: const ValueKey('online'),
              style: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 11,
              ),
            )
                : Text(
              'page ${currentPage + 1} / ${totalPages == 0 ? "..." : totalPages}',
              key: ValueKey(currentPage),
              style: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 11,
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.workspace_premium,
              color: Colors.white, size: 20),
          onPressed: onFavorite,
        ),
        IconButton(
          icon: Icon(
            isTtsPlaying ? Icons.volume_up : Icons.volume_off,
            color: isTtsPlaying
                ? BooksTheme.gold
                : Colors.white,
            size: 20,
          ),
          onPressed: onTtsToggle,
        ),
        IconButton(
          icon: const Icon(Icons.search,
              color: Colors.white, size: 20),
          onPressed: onSearch,
        ),
        IconButton(
          icon: const Icon(Icons.format_list_bulleted,
              color: Colors.white, size: 20),
          onPressed: onTableOfContents,
        ),
        IconButton(
          icon: const Icon(Icons.settings,
              color: Colors.white, size: 20),
          onPressed: onSettings,
        ),
      ],
    );
  }
}