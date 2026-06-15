import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import '../widgets/asma_theme.dart';

class AsmaDetailNavButtons extends StatelessWidget {
  final int order;
  final int totalNames;
  final bool isDark;
  final bool isSmall;
  final Function(int) onNavigate;

  const AsmaDetailNavButtons({
    super.key,
    required this.order,
    required this.totalNames,
    required this.isDark,
    required this.isSmall,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrevious = order > 1;
    final hasNext = order < totalNames;

    return Row(
      children: [
        Expanded(
            child: _buildBtn(
                label: context.tr.btnPrevious, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                icon: Icons.arrow_back_ios_new_rounded,
                isEnabled: hasPrevious,
                isPrimary: false,
                onTap: hasPrevious ? () => onNavigate(order - 1) : null
            )
        ),
        SizedBox(width: isSmall ? 10 : 14),
        Expanded(
            child: _buildBtn(
                label: context.tr.btnNext, // ًں‘ˆ طھظ…طھ ط§ظ„طھط±ط¬ظ…ط©
                icon: Icons.arrow_forward_ios_rounded,
                isEnabled: hasNext,
                isPrimary: true,
                onTap: hasNext ? () => onNavigate(order + 1) : null,
                iconAtEnd: true
            )
        ),
      ],
    );
  }

  Widget _buildBtn({required String label, required IconData icon, required bool isEnabled, required bool isPrimary, VoidCallback? onTap, bool iconAtEnd = false}) {
    final enabledBg = isPrimary ? AsmaTheme.gold : (isDark ? const Color(0xFF1A2438) : Colors.white);
    final disabledBg = isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1);
    final enabledText = isPrimary ? Colors.white : (isDark ? Colors.white : AsmaTheme.goldDark);
    final disabledText = isDark ? Colors.white38 : Colors.grey;

    return Material(
      color: isEnabled ? enabledBg : disabledBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isSmall ? 14 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEnabled ? (isPrimary ? AsmaTheme.gold : AsmaTheme.gold.withValues(alpha: isDark ? 0.3 : 0.25)) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isEnabled && isPrimary ? [BoxShadow(color: AsmaTheme.gold.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!iconAtEnd) Icon(icon, size: isSmall ? 16 : 18, color: isEnabled ? enabledText : disabledText),
              if (!iconAtEnd) SizedBox(width: isSmall ? 6 : 8),
              Text(label, style: GoogleFonts.cairo(fontSize: isSmall ? 14 : 16, fontWeight: FontWeight.bold, color: isEnabled ? enabledText : disabledText)),
              if (iconAtEnd) SizedBox(width: isSmall ? 6 : 8),
              if (iconAtEnd) Icon(icon, size: isSmall ? 16 : 18, color: isEnabled ? enabledText : disabledText),
            ],
          ),
        ),
      ),
    );
  }
}