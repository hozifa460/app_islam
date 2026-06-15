import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_theme.dart';
import 'settings_shared_widgets.dart';

class SettingsColorSelection extends StatelessWidget {
  final SettingsTheme theme;
  final double w;
  final List<Color> appColors;
  final List<String> colorNames;
  final int selectedColor;
  final Function(int) onSelect;

  const SettingsColorSelection({
    super.key,
    required this.theme,
    required this.w,
    required this.appColors,
    required this.colorNames,
    required this.selectedColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      theme: theme,
      w: w,
      child: Padding(
        padding: EdgeInsets.all((w * 0.04).clamp(12.0, 20.0)),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: w > 400 ? 6 : 4,
            mainAxisSpacing: (w * 0.03).clamp(10.0, 16.0),
            crossAxisSpacing: (w * 0.03).clamp(10.0, 16.0),
            childAspectRatio: 0.78,
          ),
          itemCount: appColors.length,
          itemBuilder: (context, index) {
            final color = appColors[index];
            final name = colorNames[index];
            final icon = index < SettingsTheme.colorIcons.length
                ? SettingsTheme.colorIcons[index]
                : Icons.circle;
            final isSelected = selectedColor == index;

            return GestureDetector(
              onTap: () {
                if (selectedColor != index) {
                  HapticFeedback.selectionClick();
                  onSelect(index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color
                      : color.withValues(alpha: theme.isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : color.withValues(alpha: 0.3),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 5))]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                          key: ValueKey('check'), color: Colors.white, size: 24)
                          : Icon(icon,
                          key: ValueKey('icon_$index'), color: color, size: 22),
                    ),
                    SizedBox(height: (w * 0.012).clamp(3.0, 6.0)),
                    Flexible(
                      child: Text(name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.024).clamp(8.5, 11.0),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (theme.isDark ? Colors.white70 : Colors.black87),
                          )),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}