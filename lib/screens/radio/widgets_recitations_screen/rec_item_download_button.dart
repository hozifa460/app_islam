// lib/screens/radio/widgets_recitations_screen/rec_item_download_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/recitation_categories_data.dart';
import '../video/services/video_size_service.dart';
import 'models/downloadable_item.dart';
import 'services/item_download_service.dart';
import 'theme/rec_colors.dart';

class RecItemDownloadButton extends StatelessWidget {
  final RecitationItem item;
  final Color primary;
  final bool isTablet;

  const RecItemDownloadButton({
    super.key,
    required this.item,
    required this.primary,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // ظپظ‚ط· ط§ظ„ط¹ظ†ط§طµط± ط§ظ„طھظٹ ظ„ط¯ظٹظ‡ط§ ط±ط§ط¨ط· طµظˆطھ
    if (item.audioUrl == null || item.audioUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemId = ItemDownloadService.itemIdFromRecitationItem(item);

    return Consumer<ItemDownloadService>(
      builder: (_, service, __) {
        final status = service.getStatus(itemId);
        final progress = service.getProgress(itemId);

        return GestureDetector(
          onTap: () => _handleTap(context, service, itemId, status),
          child: _buildContent(context, status, progress, service, itemId),
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context,
      ItemDownloadStatus status,
      double progress,
      ItemDownloadService service,
      String itemId,
      ) {
    switch (status) {
    // â•گâ•گ ط؛ظٹط± ظ…ط­ظ…ظ‘ظ„ â•گâ•گ
      case ItemDownloadStatus.notDownloaded:
        return _DownloadWithSize(
          item: item,
          primary: primary,
          onTap: () => _handleTap(context, service, itemId, status),
        );

    // â•گâ•گ ط¬ط§ط±ظٹ ط§ظ„طھط­ظ…ظٹظ„ â•گâ•گ
      case ItemDownloadStatus.downloading:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress : null,
                  strokeWidth: 1.8,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                progress > 0
                    ? '${(progress * 100).toInt()}%'
                    : '...',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => service.cancelDownload(itemId),
                child: const Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );

    // â•گâ•گ ظ…ط­ظ…ظ‘ظ„ â•گâ•گ
      case ItemDownloadStatus.downloaded:
        return GestureDetector(
          onTap: () => _showDownloadedOptions(context, service, itemId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.download_done_rounded,
                  size: 12,
                  color: Colors.green,
                ),
                const SizedBox(width: 3),
                Text(
                  'محمّل',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );

    // â•گâ•گ ط®ط·ط£ â•گâ•گ
      case ItemDownloadStatus.error:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded, size: 12, color: Colors.red),
              const SizedBox(width: 3),
              Text(
                'إعادة',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
    }
  }

  void _handleTap(
      BuildContext context,
      ItemDownloadService service,
      String itemId,
      ItemDownloadStatus status,
      ) {
    switch (status) {
      case ItemDownloadStatus.notDownloaded:
      case ItemDownloadStatus.error:
        _showDownloadConfirm(context, service);
        break;
      case ItemDownloadStatus.downloading:
        service.cancelDownload(itemId);
        break;
      case ItemDownloadStatus.downloaded:
        _showDownloadedOptions(context, service, itemId);
        break;
    }
  }

  void _showDownloadConfirm(
      BuildContext context,
      ItemDownloadService service,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: RecColors.cardBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'تحميل للاستماع أوفلاين',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            color: RecColors.textPrimary(context),
            fontSize: 16,
          ),
          textDirection: TextDirection.rtl,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                color: primary,
                fontSize: 14,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              '• سيتم تحميل الملف الصوتي\n'
                  '• يمكنك الاستماع بدون إنترنت\n'
                  '• يمكن حذفه لاحقاً',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: RecColors.textSecondary(context),
                height: 1.8,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              service.downloadItem(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'تحميل',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadedOptions(
      BuildContext context,
      ItemDownloadService service,
      String itemId,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RecColors.cardBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RecColors.textHint(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: RecColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            FutureBuilder<String>(
              future: service.getFileSize(itemId),
              builder: (_, snap) => Text(
                'الحجم: ${snap.data ?? '...'}',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: RecColors.textSecondary(context),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ط²ط± ط§ظ„ط­ط°ظپ
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                service.deleteDownload(itemId);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'حذف التحميل',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DownloadWithSize extends StatefulWidget {
  final RecitationItem item;
  final Color primary;
  final VoidCallback onTap;

  const _DownloadWithSize({
    required this.item,
    required this.primary,
    required this.onTap,
  });

  @override
  State<_DownloadWithSize> createState() => _DownloadWithSizeState();
}

class _DownloadWithSizeState extends State<_DownloadWithSize> {
  int? _size;

  @override
  void initState() {
    super.initState();
    _loadSize();
  }

  Future<void> _loadSize() async {
    if (widget.item.audioUrl == null || widget.item.audioUrl!.isEmpty) return;

    final size = await VideoSizeService().getSize(widget.item.audioUrl!);
    if (mounted && size != null) {
      setState(() => _size = size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: RecColors.primary(widget.primary, 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: RecColors.primary(widget.primary, 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded,
                size: 12, color: widget.primary),
            const SizedBox(width: 3),
            Text(
              _size != null
                  ? VideoSizeService.formatBytes(_size)
                  : 'تحميل',
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: widget.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}