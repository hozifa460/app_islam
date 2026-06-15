import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';
import '../../more/data/muezzin_catalog.dart';
import 'prayer_models.dart';

class MuezzinPickerSheet extends StatelessWidget {
  final Color gold;
  final Color bg;
  final String title;
  final String currentId;

  const MuezzinPickerSheet({
    super.key,
    required this.gold,
    required this.bg,
    required this.title,
    required this.currentId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final cardColor =
    isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white54 : Colors.black54;

    final all = <PickItem>[];

    all.add(
      PickItem(
        isHeader: false,
        categoryName: '',
        m: MuezzinInfo(
          id: '__DEFAULT__',
          name: context.tr.useDefaultMuezzin,
          url: '',
          description: context.tr.cancelCustomization,
          imageUrl: '',
          localSoundName: 'makkah',
        ),
      ),
    );

    for (final cat in muezzinCatalog) {
      all.add(PickItem(isHeader: true, categoryName: cat.name, m: null));
      for (final m in cat.items) {
        all.add(PickItem(isHeader: false, categoryName: cat.name, m: m));
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Icon(Icons.record_voice_over_rounded, color: gold, size: 26),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr.chooseDifferentMuezzin,
                    style: GoogleFonts.cairo(color: subColor, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.withOpacity(0.15), height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                physics: const BouncingScrollPhysics(),
                itemCount: all.length,
                itemBuilder: (context, i) {
                  final it = all[i];

                  if (it.isHeader) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            it.categoryName,
                            style: GoogleFonts.cairo(
                              color: gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final m = it.m as MuezzinInfo;
                  final isDefaultOption = m.id == '__DEFAULT__';
                  final isSel = (!isDefaultOption && m.id == currentId);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSel ? gold.withOpacity(0.6) : borderColor,
                        width: isSel ? 1.8 : 1,
                      ),
                      boxShadow: isSel
                          ? [
                        BoxShadow(
                          color: gold.withOpacity(0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: gold.withOpacity(0.22)),
                        ),
                        child: Icon(
                          isDefaultOption
                              ? Icons.restore_rounded
                              : Icons.person_rounded,
                          color: gold,
                        ),
                      ),
                      title: Text(
                        context.tr.t(m.name),
                        style: GoogleFonts.cairo(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        isDefaultOption
                            ? context.tr.t(m.description)
                            : '${context.tr.t(it.categoryName)} • ${context.tr.t(m.description)}',
                        style: GoogleFonts.cairo(color: subColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSel
                          ? Icon(Icons.check_circle_rounded, color: gold)
                          : Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: subColor,
                      ),
                      onTap: () => Navigator.pop(context, m),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}