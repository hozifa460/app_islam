import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';
import '../../more/data/muezzin_catalog.dart';
import 'muezzin_image_widget.dart';
import 'muezzin_action_row.dart';

class MuezzinCardVertical extends StatelessWidget {
  final MuezzinInfo muezzin;
  final bool downloading;
  final bool downloaded;
  final bool isBuiltIn;
  final bool isPlaying;
  final bool isPreviewLoading;
  final Color gold;
  final Color textColorMain;
  final Color textColorSub;
  final Color borderColor;
  final Color shadowColor;
  final List<Color> cardGradient;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final VoidCallback onSelect;

  const MuezzinCardVertical({
    super.key,
    required this.muezzin,
    required this.downloading,
    required this.downloaded,
    required this.isBuiltIn,
    required this.isPlaying,
    required this.isPreviewLoading,
    required this.gold,
    required this.textColorMain,
    required this.textColorSub,
    required this.borderColor,
    required this.shadowColor,
    required this.cardGradient,
    required this.onPreview,
    required this.onDownload,
    required this.onDelete,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPlaying ? gold.withOpacity(0.5) : borderColor,
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying ? gold.withOpacity(0.2) : shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 96,
              width: double.infinity,
              child: MuezzinImageWidget(muezzin: muezzin),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                children: [
                  SizedBox(
                    height: 42,
                    child: Center(
                      child: Text(
                        context.tr.t(muezzin.name),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: textColorMain,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 16,
                    child:
                    muezzin.description.trim().isNotEmpty
                        ? Text(
                      context.tr.t(muezzin.description),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        color: textColorSub,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                        : const SizedBox.shrink(),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 30,
                    child: Center(
                      child: MuezzinActionRow(
                        muezzin: muezzin,
                        downloading: downloading,
                        downloaded: downloaded,
                        isBuiltIn: isBuiltIn,
                        isPreviewLoading: isPreviewLoading,
                        isPlaying: isPlaying,
                        gold: gold,
                        textColorSub: textColorSub,
                        onPreview: onPreview,
                        onDownload: onDownload,
                        onDelete: onDelete,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold.withOpacity(0.2),
                        foregroundColor: gold,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: gold.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(
                        context.tr.selectButton, // تمت الترجمة هنا
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}