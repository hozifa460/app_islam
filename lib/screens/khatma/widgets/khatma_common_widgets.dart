import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../languages/app_localizations.dart';

// ✅ زر دائري (+ / -) — بدون تغيير
class KhatmaCircleButton extends StatelessWidget {
  final IconData icon;
  final Color primaryColor;
  final VoidCallback onTap;

  const KhatmaCircleButton({
    super.key,
    required this.icon,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth < 360 ? 44.0 : 52.0;
    final iconSize = screenWidth < 360 ? 24.0 : 28.0;

    return Material(
      color: primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(icon, color: primaryColor, size: iconSize),
        ),
      ),
    );
  }
}

// ✅ صف ملخص الخطة — بدون تغيير
class KhatmaSummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primaryColor;

  const KhatmaSummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 280;
        return Row(
          children: [
            Icon(icon,
                size: isSmall ? 16 : 18,
                color: primaryColor.withOpacity(0.7)),
            SizedBox(width: isSmall ? 8 : 10),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.cairo(
                    fontSize: isSmall ? 12 : 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 12 : 14,
                      color: primaryColor,
                    )),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ✅ بطاقة الصفحة (بداية / نهاية) — بدون تغيير
class KhatmaPageCard extends StatelessWidget {
  final String label;
  final int page;
  final int surahIdx;
  final bool isDark;
  final Color primaryColor;
  final String Function(int) toArabicNum;
  final List<String> surahNames;

  const KhatmaPageCard({
    super.key,
    required this.label,
    required this.page,
    required this.surahIdx,
    required this.isDark,
    required this.primaryColor,
    required this.toArabicNum,
    required this.surahNames,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 120;
        return Container(
          padding: EdgeInsets.all(isSmall ? 10 : 14),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    style: GoogleFonts.cairo(
                        fontSize: isSmall ? 10 : 12,
                        color: Colors.grey)),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('ص ${toArabicNum(page)}',
                    style: GoogleFonts.amiri(
                      fontSize: isSmall ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    )),
              ),
              const SizedBox(height: 4),
              Container(
                constraints:
                BoxConstraints(maxWidth: constraints.maxWidth - 20),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(surahNames[surahIdx - 1],
                      style: GoogleFonts.cairo(
                        fontSize: isSmall ? 10 : 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ✅ صف الإحصائيات — بدون تغيير
class KhatmaStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color primaryColor;

  const KhatmaStatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 300;
        return Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmall ? 6 : 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: isSmall ? 16 : 18, color: primaryColor),
            ),
            SizedBox(width: isSmall ? 10 : 14),
            Expanded(
              flex: 2,
              child: Text(label,
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: isSmall ? 12 : 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(value,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 12 : 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.end),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ✅ إحصائيات الداشبورد — هنا كان الخطأ!
// ══════════════════════════════════════════════════════════════
class KhatmaDashboardStats extends StatelessWidget {
  final int currentPage;
  final int remainingPages;
  final int Function() getDaysRemaining;
  final bool isNarrow;
  final bool isTight;

  const KhatmaDashboardStats({
    super.key,
    required this.currentPage,
    required this.remainingPages,
    required this.getDaysRemaining,
    required this.isNarrow,
    required this.isTight,
  });

  @override
  Widget build(BuildContext context) {
    // ══════════════════════════════════════
    // ✅ الإصلاح: context.tr بدل context.read
    // ══════════════════════════════════════
    final tr = context.tr;
    final statFontSize = isTight ? 16.0 : (isNarrow ? 18.0 : 22.0);
    final labelFontSize = isTight ? 9.0 : (isNarrow ? 10.0 : 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 8 : 16,
        vertical: isTight ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _dashStatItem(
                  tr.t('khatmaCompleted'),
                  '${currentPage - 1}',
                  tr.t('pageWord'),
                  statFontSize, labelFontSize),
            ),
            VerticalDivider(
              color: Colors.white30,
              thickness: 1,
              width: isNarrow ? 16 : 24,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: _dashStatItem(
                  tr.t('khatmaRemaining'),
                  '$remainingPages',
                  tr.t('pageWord'),
                  statFontSize, labelFontSize),
            ),
            VerticalDivider(
              color: Colors.white30,
              thickness: 1,
              width: isNarrow ? 16 : 24,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: _dashStatItem(
                  tr.t('khatmaDaysLeft'),
                  '${getDaysRemaining()}',
                  tr.t('khatmaPagesRemaining'),
                  statFontSize, labelFontSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashStatItem(String label, String value, String unit,
      double valueFontSize, double labelFontSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label,
              style: GoogleFonts.cairo(
                  color: Colors.white70, fontSize: labelFontSize)),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
              )),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(unit,
              style: GoogleFonts.cairo(
                  color: Colors.white70, fontSize: labelFontSize)),
        ),
      ],
    );
  }
}