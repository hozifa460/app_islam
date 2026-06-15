// lib/screens/home/widget/home_reorder_sheet.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/home_cards_order_service.dart';

class HomeReorderSheet extends StatefulWidget {
  final List<HomeCard> cards;
  final Color primary;
  final bool isDark;

  const HomeReorderSheet({
    super.key,
    required this.cards,
    required this.primary,
    required this.isDark,
  });

  /// يعرض الشيت ويرجع القائمة الجديدة أو null إن تم الإلغاء
  static Future<List<HomeCard>?> show(
      BuildContext context, {
        required List<HomeCard> cards,
        required Color primary,
        required bool isDark,
      }) {
    return showModalBottomSheet<List<HomeCard>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeReorderSheet(
        cards: cards
            .map((c) => HomeCard(
          id: c.id,
          title: c.title,
          icon: c.icon,
          isVisible: c.isVisible,
        ))
            .toList(),
        primary: primary,
        isDark: isDark,
      ),
    );
  }

  @override
  State<HomeReorderSheet> createState() => _HomeReorderSheetState();
}

class _HomeReorderSheetState extends State<HomeReorderSheet> {
  late List<HomeCard> _cards;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _cards = widget.cards;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _cards.removeAt(oldIndex);
      _cards.insert(newIndex, item);
      _hasChanges = true;
    });
    HapticFeedback.lightImpact();
  }

  void _toggleVisibility(int index) {
    setState(() {
      _cards[index].isVisible = !_cards[index].isVisible;
      _hasChanges = true;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor:
          widget.isDark ? const Color(0xFF1A2332) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.restore_rounded, color: widget.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'إعادة الترتيب الافتراضي',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'سيتم إعادة ترتيب البطاقات وإظهارها جميعاً كما كانت.\nهل تريد المتابعة؟',
            style: GoogleFonts.cairo(fontSize: 13.5, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: widget.isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'إعادة تعيين',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      setState(() {
        _cards = HomeCardsOrderService.defaultCards;
        _hasChanges = true;
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _saveAndClose() {
    Navigator.pop(context, _cards);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
    widget.isDark ? const Color(0xFF0F1923) : const Color(0xFFF7F3EA);
    final cardColor =
    widget.isDark ? const Color(0xFF1A2332) : Colors.white;
    final textColor =
    widget.isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = widget.isDark ? Colors.white60 : Colors.black45;

    final visibleCount = _cards.where((c) => c.isVisible).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // ─── المقبض ───
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: subTextColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ─── الهيدر ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      color: widget.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ترتيب البطاقات',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '$visibleCount من ${_cards.length} بطاقة ظاهرة',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _resetToDefault,
                    tooltip: 'إعادة الترتيب الافتراضي',
                    icon: Icon(
                      Icons.restore_rounded,
                      color: subTextColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // ─── تعليمات ───
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: widget.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.primary.withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: widget.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'اسحب البطاقة لتغيير ترتيبها، أو اضغط على العين لإخفائها',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: widget.primary.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── قائمة البطاقات ───
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _cards.length,
                onReorder: _onReorder,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: lerpDouble(0, 8, animation.value)!,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    shadowColor: widget.primary.withOpacity(0.3),
                    child: Transform.scale(
                      scale: lerpDouble(1, 1.03, animation.value)!,
                      child: child,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final isVisible = card.isVisible;

                  return Container(
                    key: ValueKey(card.id),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isVisible
                          ? cardColor
                          : cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isVisible
                            ? widget.primary.withOpacity(0.12)
                            : subTextColor.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            widget.isDark ? 0.15 : 0.04,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isVisible
                              ? widget.primary.withOpacity(0.08)
                              : subTextColor.withOpacity(0.06),
                        ),
                        child: Center(
                          child: Text(
                            card.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      title: Text(
                        card.title,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isVisible ? textColor : subTextColor,
                          decoration: isVisible
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(
                        isVisible ? 'ظاهرة' : 'مخفية',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isVisible
                              ? widget.primary.withOpacity(0.7)
                              : Colors.redAccent.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _toggleVisibility(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isVisible
                                    ? widget.primary.withOpacity(0.1)
                                    : Colors.redAccent.withOpacity(0.1),
                              ),
                              child: Icon(
                                isVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: isVisible
                                    ? widget.primary
                                    : Colors.redAccent,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ReorderableDragStartListener(
                            index: index,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: subTextColor.withOpacity(0.08),
                              ),
                              child: Icon(
                                Icons.drag_handle_rounded,
                                color: subTextColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ─── أزرار الحفظ ───
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      widget.isDark ? 0.3 : 0.08,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasChanges
                                ? widget.primary
                                : widget.primary.withOpacity(0.5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _hasChanges ? _saveAndClose : null,
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: Text(
                            'حفظ التغييرات',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: subTextColor,
                          side: BorderSide(
                            color: subTextColor.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
      ),
    );
  }
}