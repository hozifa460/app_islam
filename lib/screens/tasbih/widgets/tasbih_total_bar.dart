import 'package:flutter/material.dart';
import 'tasbih_theme.dart';

class TasbihTotalBar extends StatelessWidget {
  final int totalCount;
  final Color primaryColor;

  const TasbihTotalBar({
    super.key,
    required this.totalCount,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: TasbihTheme.totalBarDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('الإجمالي', style: TasbihTheme.totalLabel),
          Text('$totalCount', style: TasbihTheme.totalValue(primaryColor)),
        ],
      ),
    );
  }
}