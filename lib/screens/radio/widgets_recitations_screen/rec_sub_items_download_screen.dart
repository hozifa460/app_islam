// lib/screens/radio/widgets_recitations_screen/rec_sub_items_download_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/models/downloadable_item.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:provider/provider.dart';

import 'theme/rec_colors.dart';

class RecSubItemsDownloadScreen extends StatefulWidget {
  final RecitationItem parentItem;
  final Color primary;

  const RecSubItemsDownloadScreen({
    super.key,
    required this.parentItem,
    required this.primary,
  });

  @override
  State<RecSubItemsDownloadScreen> createState() =>
      _RecSubItemsDownloadScreenState();
}

class _RecSubItemsDownloadScreenState
    extends State<RecSubItemsDownloadScreen> {
  final Set<int> _selectedIndices = {};

  late final List<RecitationSubItem> _subItems;
  late final Map<int, RecitationItem> _tempItemsByIndex;
  late final Map<int, String> _itemIdsByIndex;

  @override
  void initState() {
    super.initState();

    _subItems = widget.parentItem.allSubItems;
    _tempItemsByIndex = {};
    _itemIdsByIndex = {};

    for (int i = 0; i < _subItems.length; i++) {
      final sub = _subItems[i];
      final tempItem = RecitationItem(
        title: sub.title,
        subtitle: sub.subtitle,
        emoji: sub.emoji,
        audioUrl: sub.audioUrl,
        imageUrl: sub.imageUrl ?? widget.parentItem.imageUrl,
      );
      _tempItemsByIndex[i] = tempItem;
      _itemIdsByIndex[i] = ItemDownloadService.itemIdFromRecitationItem(tempItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    final bgColors = RecColors.bgGradient(context).colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RecColors.background(context),
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _DlBgPainter(
                    primary: widget.primary,
                    backgroundColors: bgColors,
                  ),
                ),
              ),
            ),

            Selector<ItemDownloadService, _SubDownloadsSnapshot>(
              selector: (_, service) {
                final downloadedIndices = <int>{};
                final downloadingIndices = <int>{};
                final progressByIndex = <int, double>{};

                for (final entry in _itemIdsByIndex.entries) {
                  final index = entry.key;
                  final itemId = entry.value;

                  if (service.isDownloaded(itemId)) {
                    downloadedIndices.add(index);
                  }

                  final status = service.getStatus(itemId);
                  if (status == ItemDownloadStatus.downloading) {
                    downloadingIndices.add(index);
                    progressByIndex[index] = service.getProgress(itemId);
                  }
                }

                return _SubDownloadsSnapshot(
                  downloadedIndices: downloadedIndices,
                  downloadingIndices: downloadingIndices,
                  progressByIndex: progressByIndex,
                );
              },
              builder: (_, snapshot, __) {
                return Column(
                  children: [
                    SizedBox(height: safePadding.top),
                    _buildAppBar(),
                    _buildParentInfo(snapshot),
                    _buildQuickSelect(snapshot),
                    Expanded(child: _buildItemsList(snapshot)),
                    _buildDownloadButton(snapshot),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: RecColors.iconBackground(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: RecColors.iconBorder(context),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: RecColors.iconColor(context),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'تحميل التلاوات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: RecColors.textPrimary(context),
              ),
            ),
          ),
          if (_selectedIndices.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: RecColors.primary(widget.primary, 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: RecColors.primary(widget.primary, 0.4),
                ),
              ),
              child: Text(
                '${_selectedIndices.length} تلاوة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParentInfo(_SubDownloadsSnapshot snapshot) {
    final downloadedCount = snapshot.downloadedIndices.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RecColors.cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RecColors.primary(widget.primary, 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: RecColors.black(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  RecColors.primary(widget.primary, 0.2),
                  RecColors.goldOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                widget.parentItem.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.parentItem.title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: RecColors.textPrimary(context),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (downloadedCount > 0) ...[
                      const Icon(
                        Icons.download_done_rounded,
                        size: 13,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$downloadedCount/${_subItems.length} محملة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else
                      Text(
                        '${_subItems.length} تلاوة متاحة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: RecColors.textSecondary(context),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelect(_SubDownloadsSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _quickBtn(
            label: 'تحديد الكل',
            icon: Icons.select_all_rounded,
            onTap: () {
              setState(() {
                for (int i = 0; i < _subItems.length; i++) {
                  if (!snapshot.downloadedIndices.contains(i) &&
                      !snapshot.downloadingIndices.contains(i)) {
                    _selectedIndices.add(i);
                  }
                }
              });
            },
          ),
          const SizedBox(width: 8),
          _quickBtn(
            label: 'إلغاء الكل',
            icon: Icons.deselect_rounded,
            onTap: () => setState(() => _selectedIndices.clear()),
          ),
        ],
      ),
    );
  }

  Widget _quickBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: RecColors.primary(widget.primary, 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RecColors.primary(widget.primary, 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: widget.primary),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: widget.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(_SubDownloadsSnapshot snapshot) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: _subItems.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (_, i) {
        final sub = _subItems[i];
        final isDownloaded = snapshot.downloadedIndices.contains(i);
        final isDownloading = snapshot.downloadingIndices.contains(i);
        final progress = snapshot.progressByIndex[i] ?? 0;
        final isSelected = _selectedIndices.contains(i);

        return GestureDetector(
          onTap: () {
            if (isDownloaded || isDownloading) return;
            setState(() {
              if (isSelected) {
                _selectedIndices.remove(i);
              } else {
                _selectedIndices.add(i);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? RecColors.primary(widget.primary, 0.1)
                  : isDownloaded
                  ? Colors.green.withOpacity(0.06)
                  : RecColors.cardBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? RecColors.primary(widget.primary, 0.35)
                    : isDownloaded
                    ? Colors.green.withOpacity(0.2)
                    : RecColors.primary(widget.primary, 0.06),
                width: isSelected ? 1.2 : 0.6,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? RecColors.primary(widget.primary, 0.15)
                            : isDownloaded
                            ? Colors.green.withOpacity(0.12)
                            : RecColors.iconBackground(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isDownloaded
                            ? const Icon(
                          Icons.download_done_rounded,
                          size: 16,
                          color: Colors.green,
                        )
                            : isSelected
                            ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: widget.primary,
                        )
                            : Text(
                          '${i + 1}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: RecColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.title,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? widget.primary
                                  : isDownloaded
                                  ? Colors.green
                                  : RecColors.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${sub.subtitle}${sub.durationStr.isNotEmpty ? ' • ${sub.durationStr}' : ''}',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: RecColors.textHint(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      isDownloaded ? '✓' : '',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDownloaded
                            ? Colors.green
                            : RecColors.textHint(context),
                      ),
                    ),
                  ],
                ),
                if (isDownloading) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress > 0 ? progress : null,
                            backgroundColor:
                            RecColors.primary(widget.primary, 0.1),
                            valueColor:
                            AlwaysStoppedAnimation(widget.primary),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        progress > 0 ? '${(progress * 100).toInt()}%' : '...',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context
                            .read<ItemDownloadService>()
                            .cancelDownload(_itemIdsByIndex[i]!),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadButton(_SubDownloadsSnapshot snapshot) {
    final actualSelected = _selectedIndices
        .where((i) =>
    !snapshot.downloadedIndices.contains(i) &&
        !snapshot.downloadingIndices.contains(i))
        .length;

    final anyDownloading = snapshot.downloadingIndices.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: RecColors.cardBackground(context),
        border: Border(
          top: BorderSide(
            color: RecColors.primary(widget.primary, 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (actualSelected > 0 && !anyDownloading) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: RecColors.primary(widget.primary, 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem(
                    'سيُحمَّل',
                    '$actualSelected تلاوة',
                    widget.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (anyDownloading)
            _actionBtn(
              label: 'جاري التحميل...',
              icon: Icons.hourglass_top_rounded,
              color: Colors.orange,
              onTap: () {},
            )
          else if (actualSelected > 0)
            _actionBtn(
              label: 'تحميل $actualSelected تلاوة',
              icon: Icons.download_rounded,
              color: widget.primary,
              onTap: _startDownload,
            )
          else
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: RecColors.iconBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'اختر تلاوات للتحميل',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: RecColors.textHint(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10,
            color: RecColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: RecColors.primary(color, 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startDownload() {
    final service = context.read<ItemDownloadService>();

    for (final i in _selectedIndices) {
      final tempItem = _tempItemsByIndex[i];
      if (tempItem != null) {
        service.downloadItem(tempItem);
      }
    }

    setState(() => _selectedIndices.clear());
  }
}

class _SubDownloadsSnapshot {
  final Set<int> downloadedIndices;
  final Set<int> downloadingIndices;
  final Map<int, double> progressByIndex;

  const _SubDownloadsSnapshot({
    required this.downloadedIndices,
    required this.downloadingIndices,
    required this.progressByIndex,
  });

  @override
  bool operator ==(Object other) {
    return other is _SubDownloadsSnapshot &&
        setEquals(other.downloadedIndices, downloadedIndices) &&
        setEquals(other.downloadingIndices, downloadingIndices) &&
        mapEquals(other.progressByIndex, progressByIndex);
  }

  @override
  int get hashCode => Object.hash(
    downloadedIndices.length,
    downloadingIndices.length,
    progressByIndex.length,
  );
}

class _DlBgPainter extends CustomPainter {
  final Color primary;
  final List<Color> backgroundColors;

  _DlBgPainter({
    required this.primary,
    required this.backgroundColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        colors: backgroundColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bg,
    );

    final glow = Paint()..style = PaintingStyle.fill;
    glow.shader = RadialGradient(
      colors: [
        primary.withOpacity(0.06),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, 0),
        radius: size.width * 0.8,
      ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.5, 0),
      size.width * 0.8,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _DlBgPainter old) =>
      old.primary != primary ||
          old.backgroundColors != backgroundColors;
}