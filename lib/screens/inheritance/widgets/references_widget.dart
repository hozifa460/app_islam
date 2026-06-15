import 'package:flutter/material.dart';

import '../../../languages/app_localizations.dart';

class ReferencesWidget extends StatelessWidget {
  final bool isDarkMode;

  const ReferencesWidget({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final borderColor = isDarkMode ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15);
    const greenColor = Color(0xFF1B5E20);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [greenColor, Color(0xFF2E7D32)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
        ),
        title: Text(
          context.tr.referencesTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          context.tr.referencesSubtitle,
          style: TextStyle(
            fontSize: 11,
            color: textColor.withOpacity(0.5),
          ),
        ),
        children: [
          _buildRefSection(
            context: context,
            icon: Icons.auto_stories,
            title: context.tr.quranReferencesTitle,
            color: const Color(0xFFD4A847),
            items: [
              context.tr.quranRef1,
              context.tr.quranRef2,
              context.tr.quranRef3,
              context.tr.quranRef4,
            ],
          ),
          const SizedBox(height: 16),
          _buildRefSection(
            context: context,
            icon: Icons.mosque,
            title: context.tr.sunnahReferencesTitle,
            color: greenColor,
            items: [
              context.tr.sunnahRef1,
              context.tr.sunnahRef2,
              context.tr.sunnahRef3,
              context.tr.sunnahRef4,
              context.tr.sunnahRef5,
            ],
          ),
          const SizedBox(height: 16),
          _buildRefSection(
            context: context,
            icon: Icons.book,
            title: context.tr.fiqhReferencesTitle,
            color: const Color(0xFF795548),
            items: [
              context.tr.fiqhRef1,
              context.tr.fiqhRef2,
              context.tr.fiqhRef3,
              context.tr.fiqhRef4,
              context.tr.fiqhRef5,
              context.tr.fiqhRef6,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDarkMode ? 0.12 : 0.06),
            color.withOpacity(isDarkMode ? 0.06 : 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}