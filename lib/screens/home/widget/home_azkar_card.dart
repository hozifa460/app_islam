import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import '../../Azkar/azkar_detail_screen.dart';

class HomeAzkarCard extends StatelessWidget {
  final Color primary;
  final Color gold;
  final Color cardColor;
  final bool isDark;
  final String currentTitle;
  final IconData currentIcon;
  final Map<String, dynamic>? currentCategory;
  final bool isMorning;

  const HomeAzkarCard({
    super.key,
    required this.primary,
    required this.gold,
    required this.cardColor,
    required this.isDark,
    required this.currentTitle,
    required this.currentIcon,
    required this.currentCategory,
    required this.isMorning,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final List<dynamic> currentAzkarList = currentCategory?['azkar'] as List<dynamic>? ?? [];
    final String previewText = currentAzkarList.isNotEmpty
        ? (currentAzkarList.first['text']?.toString() ?? '')
        : tr.loadingAzkar;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final small = width < 360;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (currentCategory == null) return;
            Navigator.push(context, MaterialPageRoute(builder: (_) => AzkarDetailScreen(
              title: currentCategory!['title'] as String,
              azkar: List<Map<String, dynamic>>.from(currentAzkarList),
            )));
          },
          child: Container(
            padding: EdgeInsets.all(small ? 12 : 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13211D) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primary.withValues(alpha: 0.10)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary, foregroundColor: Colors.white, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.symmetric(horizontal: small ? 14 : 18, vertical: small ? 9 : 10),
                      ),
                      onPressed: () {
                        if (currentCategory == null) return;
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AzkarDetailScreen(
                          title: currentCategory!['title'] as String,
                          azkar: List<Map<String, dynamic>>.from(currentAzkarList),
                        )));
                      },
                      child: Text(tr.read, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: small ? 12 : 13)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            Icon(currentIcon, color: gold, size: 20),
                            const SizedBox(width: 8),
                            Text(currentTitle, style: GoogleFonts.cairo(fontSize: small ? 14 : 16, fontWeight: FontWeight.bold, color: gold)),
                          ]),
                          const SizedBox(height: 8),
                          Text(previewText, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(fontSize: small ? 11 : 12, color: isDark ? Colors.white70 : Colors.black87, height: 1.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(value: isMorning ? 0.55 : 0.75, minHeight: small ? 5 : 6, backgroundColor: gold.withValues(alpha: 0.15), valueColor: AlwaysStoppedAnimation<Color>(gold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}