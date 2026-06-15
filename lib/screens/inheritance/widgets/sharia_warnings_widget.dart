import 'package:flutter/material.dart';

import '../../../languages/app_localizations.dart';

class ShariaWarningsWidget extends StatelessWidget {
  final bool isDarkMode;

  const ShariaWarningsWidget({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
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
            gradient: LinearGradient(
              colors: [Colors.orange.shade700, Colors.orange.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
        ),
        title: Text(
          context.tr.shariaWarningsTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          context.tr.shariaWarningsCount,
          style: TextStyle(
            fontSize: 11,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
        children: [
          _buildWarningItem(
            context: context,
            number: 'ظ،',
            icon: Icons.account_balance,
            title: context.tr.warning1Title,
            content: context.tr.warning1Content,
            color: const Color(0xFF1565C0),
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ¢',
            icon: Icons.dangerous,
            title: context.tr.warning2Title,
            content: context.tr.warning2Content,
            color: Colors.red,
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ£',
            icon: Icons.compare_arrows,
            title: context.tr.warning3Title,
            content: context.tr.warning3Content,
            color: const Color(0xFF6A1B9A),
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ¤',
            icon: Icons.link_off,
            title: context.tr.warning4Title,
            content: context.tr.warning4Content,
            color: Colors.brown,
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ¥',
            icon: Icons.pregnant_woman,
            title: context.tr.warning5Title,
            content: context.tr.warning5Content,
            color: const Color(0xFF00695C),
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ¦',
            icon: Icons.person_search,
            title: context.tr.warning6Title,
            content: context.tr.warning6Content,
            color: const Color(0xFF37474F),
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ§',
            icon: Icons.help_outline,
            title: context.tr.warning7Title,
            content: context.tr.warning7Content,
            color: const Color(0xFF4E342E),
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ¨',
            icon: Icons.description,
            title: context.tr.warning8Title,
            content: context.tr.warning8Content,
            color: const Color(0xFFAD1457),
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ©',
            icon: Icons.gavel,
            title: context.tr.warning9Title,
            content: context.tr.warning9Content,
            color: const Color(0xFFB71C1C),
          ),
          _buildWarningItem(
            context: context,
            number: 'ظ،ظ ',
            icon: Icons.school,
            title: context.tr.warning10Title,
            content: context.tr.warning10Content,
            color: const Color(0xFF1B5E20),
          ),
          const SizedBox(height: 16),
          _buildInheritanceBlockersBox(context),
          const SizedBox(height: 12),
          _buildInheritanceConditionsBox(context),
        ],
      ),
    );
  }

  Widget _buildWarningItem({
    required BuildContext context,
    required String number,
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        color: color.withValues(alpha: isDarkMode ? 0.08 : 0.03),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13,
                height: 1.7,
                color: isDarkMode ? Colors.white70 : const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInheritanceBlockersBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: isDarkMode ? 0.15 : 0.08),
            Colors.red.withValues(alpha: isDarkMode ? 0.08 : 0.03),
          ],
        ),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.block, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr.inheritanceBlockersTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBlockerRow(context, 'ظ،', context.tr.blocker1, context.tr.blocker1Desc),
          _buildBlockerRow(context, 'ظ¢', context.tr.blocker2, context.tr.blocker2Desc),
          _buildBlockerRow(context, 'ظ£', context.tr.blocker3, context.tr.blocker3Desc),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              context.tr.blockersPoem,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.6,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockerRow(BuildContext context, String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInheritanceConditionsBox(BuildContext context) {
    const greenColor = Color(0xFF1B5E20);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            greenColor.withValues(alpha: isDarkMode ? 0.15 : 0.08),
            greenColor.withValues(alpha: isDarkMode ? 0.08 : 0.03),
          ],
        ),
        border: Border.all(color: greenColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr.inheritanceConditionsTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: greenColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCondRow(context, 'ظ،', context.tr.condition1, context.tr.condition1Desc),
          _buildCondRow(context, 'ظ¢', context.tr.condition2, context.tr.condition2Desc),
          _buildCondRow(context, 'ظ£', context.tr.condition3, context.tr.condition3Desc),
          _buildCondRow(context, 'ظ¤', context.tr.condition4, context.tr.condition4Desc),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.inheritanceCausesTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: greenColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${context.tr.cause1}\n${context.tr.cause2}\n${context.tr.cause3}',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCondRow(BuildContext context, String num, String title, String desc) {
    const greenColor = Color(0xFF1B5E20);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: greenColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: greenColor,
                    ),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}