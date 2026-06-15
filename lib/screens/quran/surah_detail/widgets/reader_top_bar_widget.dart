import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/surah_constants.dart';

class ReaderTopBarWidget extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final double topPadding;
  final String surahName;
  final int currentPage;
  final int hizbQuarter;
  final bool isDownloading;
  final bool areAllPagesDownloaded;
  final bool isBackgroundPreparing;
  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final VoidCallback onDownloadStatusTap;

  const ReaderTopBarWidget({
    Key? key,
    required this.primary,
    required this.isDark,
    required this.topPadding,
    required this.surahName,
    required this.currentPage,
    required this.hizbQuarter,
    required this.isDownloading,
    required this.areAllPagesDownloaded,
    required this.isBackgroundPreparing,
    required this.onMenuTap,
    required this.onSearchTap,
    required this.onDownloadStatusTap,
  }) : super(key: key);

  IconData _getQuranDownloadStatusIcon() {
    if (isDownloading || isBackgroundPreparing) {
      return Icons.downloading_rounded;
    }
    if (areAllPagesDownloaded) {
      return Icons.cloud_done_rounded;
    }
    return Icons.cloud_download_rounded;
  }

  Color _getQuranDownloadStatusColor() {
    if (isDownloading || isBackgroundPreparing) {
      return Colors.orange;
    }
    if (areAllPagesDownloaded) {
      return Colors.green;
    }
    return primary;
  }

  Color _getQuranDownloadBadgeColor() {
    if (isDownloading || isBackgroundPreparing) {
      return Colors.orange;
    }
    if (areAllPagesDownloaded) {
      return Colors.green;
    }
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final boxColor = isDark ? const Color(0xFF232323) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    final hizb = ((hizbQuarter - 1) ~/ 4) + 1;
    final juz = ((hizbQuarter - 1) ~/ 8) + 1;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 2,
        left: 10,
        right: 10,
        bottom: 8,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          _buildSquareButtonWithBadge(
            icon: _getQuranDownloadStatusIcon(),
            onTap: onDownloadStatusTap,
            iconColorOverride: _getQuranDownloadStatusColor(),
            badgeColor: _getQuranDownloadBadgeColor(),
          ),
          const SizedBox(width: 8),
          _buildSquareButton(
            icon: Icons.search,
            onTap: onSearchTap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          surahName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'طµظپط­ط© $currentPage | ط¬ط²ط، $juz | ط­ط²ط¨ $hizb',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildSquareButton(
            icon: Icons.menu,
            onTap: onMenuTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColorOverride,
  }) {
    return Material(
      color: isDark ? const Color(0xFF232323) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: iconColorOverride ?? (isDark ? Colors.white : Colors.black87),
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButtonWithBadge({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColorOverride,
    required Color badgeColor,
  }) {
    return Material(
      color: isDark ? const Color(0xFF232323) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icon,
                  color: iconColorOverride ?? (isDark ? Colors.white : Colors.black87),
                  size: 23,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}