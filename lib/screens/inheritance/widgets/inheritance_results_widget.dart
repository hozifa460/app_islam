import 'package:flutter/material.dart';
import '../../../languages/app_localizations.dart';
import '../../../models/inheritance_models.dart';

class InheritanceResultsWidget extends StatelessWidget {
  final InheritanceResult result;
  final FullInheritanceResult fullResult;
  final bool isDarkMode;
  final Color primaryColor;

  const InheritanceResultsWidget({
    Key? key,
    required this.result,
    required this.fullResult,
    required this.isDarkMode,
    required this.primaryColor,
  }) : super(key: key);

  String _getCaseTypeName(BuildContext context, String caseType) {
    switch (caseType) {
      case 'ط¹ظˆظ„':
        return context.tr.awlCase;
      case 'ط±ط¯':
        return context.tr.raddCase;
      default:
        return context.tr.normalCase;
    }
  }

  String _getHeirName(BuildContext context, HeirType type) {
    switch (type) {
      case HeirType.husband:
        return context.tr.husband;
      case HeirType.wife:
        return context.tr.wife;
      case HeirType.mother:
        return context.tr.mother;
      case HeirType.father:
        return context.tr.father;
      case HeirType.grandmother:
        return context.tr.grandmother;
      case HeirType.grandfather:
        return context.tr.grandfather;
      case HeirType.son:
        return context.tr.son;
      case HeirType.daughter:
        return context.tr.daughter;
      case HeirType.sonOfSon:
        return context.tr.sonOfSon;
      case HeirType.sonsDaughter:
        return context.tr.sonsDaughter;
      case HeirType.brother:
        return context.tr.brother;
      case HeirType.sister:
        return context.tr.sister;
      case HeirType.halfBrotherFather:
        return context.tr.halfBrotherFather;
      case HeirType.halfSisterFather:
        return context.tr.halfSisterFather;
      case HeirType.halfBrotherMother:
        return context.tr.halfBrotherMother;
      case HeirType.halfSisterMother:
        return context.tr.halfSisterMother;
      case HeirType.sonOfBrother:
        return context.tr.sonOfBrother;
      case HeirType.sonOfHalfBrotherFather:
        return context.tr.sonOfHalfBrotherFather;
      case HeirType.uncle:
        return context.tr.uncle;
      case HeirType.halfUncleFather:
        return context.tr.halfUncleFather;
      case HeirType.sonOfUncle:
        return context.tr.sonOfUncle;
      case HeirType.sonOfHalfUncleFather:
        return context.tr.sonOfHalfUncleFather;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCaseTypeCard(context),
        const SizedBox(height: 16),
        if (fullResult.moneyAmount != null && fullResult.moneyAmount! > 0) ...[
          _buildMoneyResults(context),
          const SizedBox(height: 16),
        ],
        if (fullResult.landShares != null && fullResult.landShares!.isNotEmpty) ...[
          _buildLandResults(context),
          const SizedBox(height: 16),
        ],
        _buildBlockedHeirs(context),
      ],
    );
  }

  Widget _buildCaseTypeCard(BuildContext context) {
    Color caseColor;
    IconData caseIcon;
    String caseEmoji;

    switch (result.caseType) {
      case 'ط¹ظˆظ„':
        caseColor = Colors.orange.shade700;
        caseIcon = Icons.trending_up_rounded;
        caseEmoji = 'ًں“ˆ';
        break;
      case 'ط±ط¯':
        caseColor = Colors.blue.shade700;
        caseIcon = Icons.trending_down_rounded;
        caseEmoji = 'ًں“‰';
        break;
      default:
        caseColor = primaryColor;
        caseIcon = Icons.check_circle_rounded;
        caseEmoji = 'âœ…';
    }

    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: caseColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: caseColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Case type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [caseColor, caseColor.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: caseColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(caseEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '${context.tr.caseType}: ${_getCaseTypeName(context, result.caseType)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: caseColor.withValues(alpha: isDarkMode ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.explanation,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Base denominator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: caseColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.pie_chart_rounded, color: caseColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                '${context.tr.baseDenominator}: ',
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: caseColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${result.baseDenominator}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyResults(BuildContext context) {
    List<Heir> activeHeirs = result.heirs.where((h) => !h.isBlocked && h.actualShare > 0).toList();
    double totalMoney = fullResult.moneyAmount!;
    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    const moneyColor = Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: moneyColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [moneyColor, Color(0xFF1B5E20)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr.moneyDistribution,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${context.tr.totalAmount}: ${totalMoney.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: moneyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activeHeirs.map((heir) {
            double share = heir.actualShare * totalMoney;
            double perPerson = share / heir.count;
            return _buildMoneyShareTile(context, heir, share, perPerson, textColor);
          }),
        ],
      ),
    );
  }

  Widget _buildMoneyShareTile(BuildContext context, Heir heir, double total, double perPerson, Color textColor) {
    final heirName = _getHeirName(context, heir.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E7D32).withValues(alpha: isDarkMode ? 0.1 : 0.05),
            const Color(0xFF2E7D32).withValues(alpha: isDarkMode ? 0.05 : 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$heirName${heir.count > 1 ? " (${heir.count})" : ""}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    Text(
                      heir.shareDescription,
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    total.toStringAsFixed(2),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(heir.actualShare * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (heir.count > 1) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: isDarkMode ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Color(0xFF1565C0)),
                  const SizedBox(width: 6),
                  Text(
                    '${context.tr.sharePerPerson}: ${perPerson.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLandResults(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    const landColor = Color(0xFF795548);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: landColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [landColor, Color(0xFF5D4037)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.landscape_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr.landDistribution,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${context.tr.totalAmount}: ${fullResult.totalLand!.formatted}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: landColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fullResult.landShares!.map((share) => _buildLandShareTile(context, share, textColor)),
        ],
      ),
    );
  }

  Widget _buildLandShareTile(BuildContext context, HeirLandShare share, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF795548).withValues(alpha: isDarkMode ? 0.1 : 0.05),
            const Color(0xFF795548).withValues(alpha: isDarkMode ? 0.05 : 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF795548).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${share.heirName}${share.count > 1 ? " (${share.count})" : ""}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF795548).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${share.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF795548),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLandChip('ًںŒ¾', context.tr.feddan, '${share.landShare.feddans}', const Color(0xFF2E7D32)),
              _buildLandChip('ًں“گ', context.tr.qirat, '${share.landShare.qirats}', const Color(0xFF795548)),
              _buildLandChip('ًں“ڈ', context.tr.sahm, '${share.landShare.sahms}', const Color(0xFFE65100)),
              _buildLandChip('ًں“چ', 'ظ…آ²', share.landShare.totalInMeters.toStringAsFixed(1), const Color(0xFF1565C0)),
            ],
          ),
          if (share.count > 1) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: isDarkMode ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ًں‘¤', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '${context.tr.sharePerPerson}: ${share.perPersonShare.formatted}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLandChip(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$value $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedHeirs(BuildContext context) {
    List<Heir> blocked = result.heirs.where((h) => h.isBlocked).toList();
    if (blocked.isEmpty) return const SizedBox.shrink();

    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person_off_rounded, color: Colors.red, size: 20),
        ),
        title: Row(
          children: [
            Text(
              context.tr.blockedHeirs,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${blocked.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        children: blocked
            .map((h) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: isDarkMode ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.block, color: Colors.red, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_getHeirName(context, h.type)} - ${context.tr.blocked}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }
}