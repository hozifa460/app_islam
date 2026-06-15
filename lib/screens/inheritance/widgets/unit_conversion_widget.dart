import 'package:flutter/material.dart';

import '../../../languages/app_localizations.dart';

class UnitConversionWidget extends StatelessWidget {
  final bool isDarkMode;

  const UnitConversionWidget({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final borderColor = isDarkMode ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15);
    const brownColor = Color(0xFF795548);

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
            gradient: const LinearGradient(colors: [brownColor, Color(0xFF5D4037)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.straighten_rounded, color: Colors.white, size: 20),
        ),
        title: Text(
          context.tr.unitConversionTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          context.tr.unitConversionDesc,
          style: TextStyle(
            fontSize: 11,
            color: textColor.withOpacity(0.5),
          ),
        ),
        children: [
          // Units definitions
          _buildUnitRow(
            context: context,
            emoji: '🌾',
            title: context.tr.feddanUnit,
            definition: context.tr.feddanDef,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 10),
          _buildUnitRow(
            context: context,
            emoji: '📐',
            title: context.tr.qiratUnit,
            definition: context.tr.qiratDef,
            color: brownColor,
          ),
          const SizedBox(height: 10),
          _buildUnitRow(
            context: context,
            emoji: '📏',
            title: context.tr.sahmUnit,
            definition: context.tr.sahmDef,
            color: const Color(0xFFE65100),
          ),
          const SizedBox(height: 10),
          _buildUnitRow(
            context: context,
            emoji: '📍',
            title: context.tr.meterUnit,
            definition: context.tr.meterDef,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 16),

          // Examples
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  brownColor.withOpacity(isDarkMode ? 0.12 : 0.06),
                  brownColor.withOpacity(isDarkMode ? 0.06 : 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: brownColor.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: brownColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lightbulb_outline, color: brownColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr.conversionExamples,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: brownColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildExampleRow(
                  context: context,
                  label: context.tr.example1Feddan,
                  result: context.tr.example1Result,
                ),
                const SizedBox(height: 8),
                _buildExampleRow(
                  context: context,
                  label: context.tr.exampleHalfFeddan,
                  result: context.tr.exampleHalfResult,
                ),
                const SizedBox(height: 8),
                _buildExampleRow(
                  context: context,
                  label: context.tr.exampleQuarterFeddan,
                  result: context.tr.exampleQuarterResult,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitRow({
    required BuildContext context,
    required String emoji,
    required String title,
    required String definition,
    required Color color,
  }) {
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  definition,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleRow({
    required BuildContext context,
    required String label,
    required String result,
  }) {
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF795548),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.8),
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF795548),
                  ),
                ),
                TextSpan(text: result),
              ],
            ),
          ),
        ),
      ],
    );
  }
}