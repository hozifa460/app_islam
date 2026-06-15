import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/surah_constants.dart';
import 'hizb_quarter_painter.dart';

class MushafPageWidget extends StatelessWidget {
  final int page;
  final Color bgColor;
  final Color textColor;
  final Color primary;
  final bool isDark;
  final String surahName;
  final int hizbQuarter;
  final int currentQuarterInHizb;
  final String? localPath;
  final Future<String?> Function(int) getLocalPagePath;

  const MushafPageWidget({
    Key? key,
    required this.page,
    required this.bgColor,
    required this.textColor,
    required this.primary,
    required this.isDark,
    required this.surahName,
    required this.hizbQuarter,
    required this.currentQuarterInHizb,
    this.localPath,
    required this.getLocalPagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hizb = ((hizbQuarter - 1) ~/ 4) + 1;
    final juz = ((hizbQuarter - 1) ~/ 8) + 1;

    return FutureBuilder<String?>(
      future: getLocalPagePath(page),
      builder: (context, snapshot) {
        final localPath = snapshot.data;

        Widget imageWidget;

        if (localPath != null) {
          imageWidget = Image.file(
            File(localPath),
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
          );
        } else {
          imageWidget = CachedNetworkImage(
            imageUrl: SurahConstants.getPageImageUrl(page),
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
            fadeInDuration: const Duration(milliseconds: 150),
            placeholder: (context, url) => Container(
              color: bgColor,
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: primary),
            ),
            errorWidget: (context, url, error) {
              return Container(
                color: bgColor,
                alignment: Alignment.center,
                child: Text(
                  'تعذر تحميل الصفحة ${SurahConstants.toArabicNum(page)}',
                  style: GoogleFonts.cairo(
                    color: primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            return Container(
              color: bgColor,
              width: double.infinity,
              height: double.infinity,
              child: ClipRect(
                child: SizedBox(
                  width: availableWidth,
                  height: availableHeight,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 960,
                      height: 1760,
                      child: Stack(
                        children: [
                          Positioned.fill(top: 120, child: imageWidget),
                          Positioned(
                            top: 38,
                            left: 26,
                            right: 26,
                            child: Row(
                              children: [
                                Text(
                                  surahName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'جزء ${SurahConstants.toArabicNum(juz)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildHizbProgressCircle(),
                                const SizedBox(width: 8),
                                Text(
                                  'حزب ${SurahConstants.toArabicNum(hizb)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 34,
                            right: 28,
                            child: Text(
                              SurahConstants.toArabicNum(page),
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHizbProgressCircle() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: HizbQuarterPainter(
          quarter: currentQuarterInHizb,
          activeColor: primary,
          inactiveColor: isDark
              ? Colors.white.withOpacity(0.14)
              : Colors.black.withOpacity(0.10),
        ),
        child: Center(
          child: Container(
            width: 5.5,
            height: 5.5,
            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}