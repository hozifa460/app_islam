import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';

class HomeQuickGrid extends StatelessWidget {
  final Color primary;
  final Color gold;
  final Color cardColor;
  final bool isDark;
  final Function(int) onItemTap;

  const HomeQuickGrid({super.key,
    required this.primary,
    required this.gold,
    required this.cardColor,
    required this.isDark,
    required this.onItemTap
  });

  List<Map<String, dynamic>> _items(AppLocalizations tr) => [
    {'title': tr.quickQuran, 'icon': Icons.menu_book_rounded, 'index': 0},
    {'title': tr.quickHadith, 'icon': Icons.format_quote_rounded, 'index': 4},
    {'title': tr.quickAzkar, 'icon': Icons.auto_awesome_rounded, 'index': 2},
    {'title': tr.quickQibla, 'icon': Icons.explore_rounded, 'index': 8},
    {'title': tr.quickAsmaAllah, 'icon': Icons.numbers_rounded, 'index': 12},
    {'title': tr.quickTasbih, 'icon': Icons.touch_app_rounded, 'index': 3},
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final homeItems = _items(tr);

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final small = width < 360;
      const crossAxisCount = 3;
      final spacing = small ? 10.0 : 12.0;
      final itemWidth = (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;
      final itemHeight = small ? itemWidth * 1.05 : itemWidth * 1.10;
      final childAspectRatio = itemWidth / itemHeight;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: homeItems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: spacing, crossAxisSpacing: spacing, childAspectRatio: childAspectRatio),
        itemBuilder: (context, index) {
          final item = homeItems[index];
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onItemTap(item['index'] as int),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF13211D) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withValues(alpha: 0.10)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 8 : 10),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: small ? 44 : 52, height: small ? 44 : 52,
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                    child: Icon(item['icon'] as IconData, color: isDark ? Colors.white70 : primary, size: small ? 24 : 28),
                  ),
                  SizedBox(height: small ? 8 : 10),
                  FittedBox(fit: BoxFit.scaleDown, child: Text(item['title'] as String, textAlign: TextAlign.center, maxLines: 1,
                      style: GoogleFonts.cairo(fontSize: small ? 11.5 : 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : primary))),
                ]),
              ),
            ),
          );
        },
      );
    });
  }
}