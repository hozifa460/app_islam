import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';
import '../../more/data/muezzin_catalog.dart';

class MuezzinActionRow extends StatelessWidget {
  final MuezzinInfo muezzin;
  final bool downloading;
  final bool downloaded;
  final bool isBuiltIn;
  final bool isPreviewLoading;
  final bool isPlaying;
  final Color gold;
  final Color textColorSub;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const MuezzinActionRow({
    super.key,
    required this.muezzin,
    required this.downloading,
    required this.downloaded,
    required this.isBuiltIn,
    required this.isPreviewLoading,
    required this.isPlaying,
    required this.gold,
    required this.textColorSub,
    required this.onPreview,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: context.tr.previewTooltip,
          onPressed: onPreview,
          icon: isPreviewLoading && isPlaying
              ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: gold),
          )
              : Icon(
            isPlaying
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_fill_rounded,
            color: gold,
            size: 28,
          ),
        ),
        const SizedBox(width: 4),
        if (isBuiltIn)
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: gold.withOpacity(0.4)),
            ),
            child: Text(
              context.tr.readyStatus,
              style: GoogleFonts.cairo(
                color: gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (downloading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (downloaded)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: Colors.green.withOpacity(0.4)),
                ),
                child: Text(
                  context.tr.offlineStatus,
                  style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            IconButton(
              tooltip: context.tr.downloadTooltip,
              onPressed: onDownload,
              icon: Icon(Icons.download_rounded,
                  color: textColorSub, size: 22),
            ),
      ],
    );
  }
}