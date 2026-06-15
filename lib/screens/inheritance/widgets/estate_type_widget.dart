import 'package:flutter/material.dart';
import '../../../languages/app_localizations.dart';
import '../../../models/inheritance_models.dart';

class EstateTypeWidget extends StatelessWidget {
  final EstateType estateType;
  final bool isDarkMode;
  final Function(EstateType) onTypeChanged;

  const EstateTypeWidget({
    Key? key,
    required this.estateType,
    required this.isDarkMode,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category_rounded, color: Color(0xFF1565C0), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr.estateType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      context.tr.selectEstateType,
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 320) {
                return Column(
                  children: [
                    _buildTypeCard(EstateType.money, context.tr.moneyEstate, Icons.payments_rounded, const Color(0xFF2E7D32)),
                    const SizedBox(height: 10),
                    _buildTypeCard(EstateType.land, context.tr.landEstate, Icons.landscape_rounded, const Color(0xFF795548)),
                    const SizedBox(height: 10),
                    _buildTypeCard(EstateType.both, context.tr.bothEstates, Icons.account_balance_rounded, const Color(0xFF1565C0)),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildTypeCard(EstateType.money, context.tr.moneyEstate, Icons.payments_rounded, const Color(0xFF2E7D32))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTypeCard(EstateType.land, context.tr.landEstateShort, Icons.landscape_rounded, const Color(0xFF795548))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTypeCard(EstateType.both, context.tr.bothEstatesShort, Icons.account_balance_rounded, const Color(0xFF1565C0))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(EstateType type, String label, IconData icon, Color color) {
    final isSelected = estateType == type;

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
              : null,
          color: isSelected ? null : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : (isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.grey.shade700),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}