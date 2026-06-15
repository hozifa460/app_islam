import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/surah_constants.dart';

class DownloadStatusDialog {
  static Future<void> show({
    required BuildContext context,
    required int downloadedPages,
    required bool isDownloading,
    required bool isBackgroundPreparing,
    required bool areAllPagesDownloaded,
    required String backgroundMessage,
    required VoidCallback onResumeDownload,
  }) async {
    final remainingPages = 604 - downloadedPages;
    final primary = Theme.of(context).colorScheme.primary;

    Color badgeColor;
    String title;

    if (isDownloading || isBackgroundPreparing) {
      badgeColor = Colors.orange;
      title = 'ط¬ط§ط±ظٹ طھظ†ط²ظٹظ„ طµظپط­ط§طھ ط§ظ„ظ‚ط±ط¢ظ†...';
    } else if (areAllPagesDownloaded) {
      badgeColor = Colors.green;
      title = 'طھظ… طھط­ظ…ظٹظ„ ط§ظ„ظ‚ط±ط¢ظ† ط¨ط§ظ„ظƒط§ظ…ظ„';
    } else {
      badgeColor = Colors.redAccent;
      title = 'ط§ظ„ظ‚ط±ط¢ظ† ط؛ظٹط± ظ…ظƒطھظ…ظ„ ط§ظ„طھط­ظ…ظٹظ„';
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ط­ط§ظ„ط© طھظ†ط²ظٹظ„ ط§ظ„ظ‚ط±ط¢ظ†',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primary.withValues(alpha: 0.10)),
                ),
                child: Column(
                  children: [
                    Text(
                      'ط§ظ„طµظپط­ط§طھ ط§ظ„ظ…ط­ظ…ظ‘ظ„ط©',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${SurahConstants.toArabicNum(downloadedPages)} / ظ¦ظ ظ¤',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: downloadedPages / 604,
                      minHeight: 6,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ط§ظ„ظ…طھط¨ظ‚ظٹ',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${SurahConstants.toArabicNum(remainingPages)} طµظپط­ط©',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (isDownloading || isBackgroundPreparing)
                Text(
                  backgroundMessage.isNotEmpty
                      ? backgroundMessage
                      : 'ظٹطھظ… طھظ†ط²ظٹظ„ ط§ظ„طµظپط­ط§طھ ط§ظ„ط¢ظ†...',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              if (areAllPagesDownloaded)
                Text(
                  'طھظ… طھظ†ط²ظٹظ„ ط¬ظ…ظٹط¹ طµظپط­ط§طھ ط§ظ„ظ‚ط±ط¢ظ† ظˆظٹظ…ظƒظ†ظƒ ط§ظ„ظ‚ط±ط§ط،ط© ط¨ط¯ظˆظ† ط¥ظ†طھط±ظ†طھ.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              if (!areAllPagesDownloaded && !isDownloading && !isBackgroundPreparing)
                Text(
                  'ط¨ط¹ط¶ ط§ظ„طµظپط­ط§طھ ظ„ظ… ظٹطھظ… طھظ†ط²ظٹظ„ظ‡ط§ ط¨ط¹ط¯. ظٹظ…ظƒظ†ظƒ ط§ط³طھط¦ظ†ط§ظپ ط§ظ„طھط­ظ…ظٹظ„ ط§ظ„ط¢ظ†.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ط¥ط؛ظ„ط§ظ‚', style: GoogleFonts.cairo()),
            ),
            if (!areAllPagesDownloaded && !isDownloading && !isBackgroundPreparing)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  onResumeDownload();
                },
                child: Text(
                  'ط§ط³طھط¦ظ†ط§ظپ ط§ظ„طھط­ظ…ظٹظ„',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }
}