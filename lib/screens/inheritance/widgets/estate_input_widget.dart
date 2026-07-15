import 'package:flutter/material.dart';
import '../../../languages/app_localizations.dart';
import '../../../models/inheritance_models.dart';
import '../../../services/inheritance/land_calculator.dart';

class EstateInputWidget extends StatelessWidget {
  final EstateType estateType;
  final TextEditingController estateController;
  final TextEditingController feddanController;
  final TextEditingController qiratController;
  final TextEditingController sahmController;
  final bool isDarkMode;
  final VoidCallback onChanged;

  const EstateInputWidget({
    Key? key,
    required this.estateType,
    required this.estateController,
    required this.feddanController,
    required this.qiratController,
    required this.sahmController,
    required this.isDarkMode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (estateType == EstateType.money || estateType == EstateType.both)
          _buildMoneyInput(context),
        if (estateType == EstateType.both) const SizedBox(height: 16),
        if (estateType == EstateType.land || estateType == EstateType.both)
          _buildLandInput(context),
      ],
    );
  }

  Widget _buildMoneyInput(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15);
    const moneyColor = Color(0xFF2E7D32);

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
                  gradient: LinearGradient(
                    colors: [moneyColor, moneyColor.withValues(alpha: 0.7)],
                  ),
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
                      context.tr.cashMoney,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      context.tr.afterDebtsAndWills,
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
          TextField(
            controller: estateController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: context.tr.enterTotalAmount,
              hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: moneyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.attach_money, color: moneyColor, size: 20),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: moneyColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandInput(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15);
    const landColor = Color(0xFF795548);

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
                  gradient: const LinearGradient(
                    colors: [landColor, Color(0xFF5D4037)],
                  ),
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
                      context.tr.landArea,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: landColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.tr.landUnitsInfo,
                        style: const TextStyle(fontSize: 10, color: landColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildLandField(
                  context: context,
                  controller: feddanController,
                  label: context.tr.feddan,
                  emoji: '🌾',
                  hint: '0',
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLandField(
                  context: context,
                  controller: qiratController,
                  label: context.tr.qirat,
                  emoji: '📐',
                  hint: '0-23',
                  color: landColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLandField(
                  context: context,
                  controller: sahmController,
                  label: context.tr.sahm,
                  emoji: '📏',
                  hint: '0-23',
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLiveConversion(context),
        ],
      ),
    );
  }

  Widget _buildLandField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String emoji,
    required String hint,
    required Color color,
  }) {
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onChanged: (_) => onChanged(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: color.withValues(alpha: 0.3)),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveConversion(BuildContext context) {
    int feddans = int.tryParse(feddanController.text) ?? 0;
    int qirats = int.tryParse(qiratController.text) ?? 0;
    int sahms = int.tryParse(sahmController.text) ?? 0;

    if (feddans == 0 && qirats == 0 && sahms == 0) return const SizedBox.shrink();

    LandEstate estate = LandEstate(feddans: feddans, qirats: qirats, sahms: sahms);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF795548).withValues(alpha: isDarkMode ? 0.15 : 0.08),
            const Color(0xFF795548).withValues(alpha: isDarkMode ? 0.08 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF795548).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sync_alt, size: 14, color: const Color(0xFF795548).withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                context.tr.liveConversion,
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF795548).withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildConvChip(context.tr.inQirats, '${estate.totalInQirats.toStringAsFixed(2)} ق', const Color(0xFF795548)),
              _buildConvChip(context.tr.inSahms, '${estate.totalInSahms.toStringAsFixed(0)} س', const Color(0xFFE65100)),
              _buildConvChip(context.tr.inMeters, '${estate.totalInMeters.toStringAsFixed(1)} م²', const Color(0xFF1565C0)),
              _buildConvChip(context.tr.inFeddan, '${estate.totalInFeddans.toStringAsFixed(4)} ظپ', const Color(0xFF2E7D32)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConvChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? color.withValues(alpha: 0.15) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
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
}