// lib/screens/radio/widgets_surah_player/sp_mode_badge.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_colors.dart';
import 'package:islamic_app/screens/radio/widgets_surah_player_screen/theme/sp_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// بادج وضع التشغيل (أونلاين / أوفلاين)
/// ══════════════════════════════════════════════════════════════
class SpModeBadge extends StatelessWidget {
  final bool isOnline;
  final Color primary;
  final VoidCallback? onDownload;

  const SpModeBadge({
    super.key,
    required this.isOnline,
    required this.primary,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: SpShapes.modeBadge(isOnline),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            size: 13,
            color: SpColors.modeTextColor(isOnline),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              isOnline ? 'استماع بدون تحميل' : 'تشغيل من الجهاز',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: SpColors.modeTextColor(isOnline),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isOnline && onDownload != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDownload,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: SpShapes.downloadBadgeBtn(primary),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_rounded, size: 11, color: primary),
                    const SizedBox(width: 3),
                    Text(
                      'تحميل',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}