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
      title = 'جاري تنزيل صفحات القرآن...';
    } else if (areAllPagesDownloaded) {
      badgeColor = Colors.green;
      title = 'تم تحميل القرآن بالكامل';
    } else {
      badgeColor = Colors.redAccent;
      title = 'القرآن غير مكتمل التحميل';
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
                  'حالة تنزيل القرآن',
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
                      'الصفحات المحمّلة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${SurahConstants.toArabicNum(downloadedPages)} / ٦٠٤',
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
                          'المتبقي',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${SurahConstants.toArabicNum(remainingPages)} صفحة',
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
                      : 'يتم تنزيل الصفحات الآن...',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              if (areAllPagesDownloaded)
                Text(
                  'تم تنزيل جميع صفحات القرآن ويمكنك القراءة بدون إنترنت.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              if (!areAllPagesDownloaded && !isDownloading && !isBackgroundPreparing)
                Text(
                  'بعض الصفحات لم يتم تنزيلها بعد. يمكنك استئناف التحميل الآن.',
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
              child: Text('إغلاق', style: GoogleFonts.cairo()),
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
                  'استئناف التحميل',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }
}