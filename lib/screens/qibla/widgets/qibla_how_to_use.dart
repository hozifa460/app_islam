import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qibla_theme.dart';

class QiblaHowToUse extends StatelessWidget {
  final QiblaTheme theme;
  const QiblaHowToUse({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (icon: Icons.phone_android_rounded, color: QiblaTheme.blue, title: 'أمسك الهاتف أفقياً', desc: 'ضع الهاتف موازياً للأرض للحصول على أفضل دقة'),
      (icon: Icons.rotate_right_rounded, color: QiblaTheme.gold, title: 'دوّر جسمك ببطء', desc: 'استدر ببطء حتى تشير الإبرة الخضراء ▲ للأعلى'),
      (icon: Icons.check_circle_rounded, color: QiblaTheme.green, title: 'الدقة 95%+ = القبلة', desc: 'ستشعر باهتزاز الهاتف عند مواجهة القبلة بدقة'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(QiblaTheme.howToUseRadius),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.help_outline_rounded, color: QiblaTheme.gold, size: 17),
              const SizedBox(width: 7),
              Text('كيف تستخدم البوصلة؟',
                  style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.w800, color: theme.textColor)),
            ]),
            const SizedBox(height: 11),
            ...steps.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.color.withValues(alpha: 0.13),
                        border: Border.all(color: s.color.withValues(alpha: 0.38)),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: s.color)),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: theme.textColor)),
                          Text(s.desc, style: GoogleFonts.cairo(fontSize: 10.5, color: theme.textColor.withValues(alpha: 0.52), height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}