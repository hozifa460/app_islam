import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/sunnah_model.dart';
import '../services/sunnah_service.dart';
import 'sunnah_theme.dart';

class SunnahCard extends StatelessWidget {
  final SunnahModel sunnah;
  final int index;
  final Size size;
  final SunnahTheme theme;
  final SunnahService service;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const SunnahCard({
    super.key,
    required this.sunnah,
    required this.index,
    required this.size,
    required this.theme,
    required this.service,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = SunnahTheme.hexToColor(sunnah.color);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 40).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (_, val, child) => Transform.translate(
        offset: Offset(0, 16 * (1 - val)),
        child: Opacity(opacity: val.clamp(0.0, 1.0), child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: size.height * 0.012),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SunnahTheme.cardRadius),
            color: theme.card,
            gradient: sunnah.isCompleted
                ? LinearGradient(colors: [
              SunnahTheme.emerald
                  .withOpacity(theme.isDark ? 0.07 : 0.05),
              theme.card,
            ])
                : LinearGradient(
              colors: [
                theme.card,
                Color.lerp(theme.card, cardColor,
                    theme.isDark ? 0.04 : 0.02)!,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: sunnah.isCompleted
                  ? SunnahTheme.emerald.withOpacity(0.25)
                  : theme.divider,
              width: 1,
            ),
            boxShadow: [
              theme.cardShadow(
                  sunnah.isCompleted ? SunnahTheme.emerald : cardColor),
              theme.cardShadow2,
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 10,
                bottom: 10,
                child: Container(
                  width: SunnahTheme.accentLineWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: sunnah.isCompleted
                          ? [SunnahTheme.emeraldLight, SunnahTheme.emeraldDark]
                          : [cardColor, cardColor.withOpacity(0.2)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  size.height * 0.015,
                  size.width * 0.05,
                  size.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopRow(cardColor),
                    SizedBox(height: size.height * 0.012),
                    Divider(color: theme.divider, height: 1),
                    SizedBox(height: size.height * 0.01),
                    _buildBottomRow(cardColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(Color cardColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardIcon(cardColor),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      sunnah.name,
                      style: TextStyle(
                        color: sunnah.isCompleted
                            ? theme.textSecondary
                            : theme.textPrimary,
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.bold,
                        decoration: sunnah.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: theme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  buildImportanceBadge(sunnah.importance, size, theme),
                ],
              ),
              SizedBox(height: size.height * 0.005),
              Text(
                sunnah.description,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: size.width * 0.03,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardIcon(Color color) {
    final iconSize = size.width * 0.13;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: sunnah.isCompleted
            ? SunnahTheme.emeraldGradient
            : LinearGradient(colors: [
          color.withOpacity(theme.isDark ? 0.2 : 0.12),
          color.withOpacity(theme.isDark ? 0.06 : 0.04),
        ]),
        border: Border.all(
          color: sunnah.isCompleted
              ? SunnahTheme.emerald.withOpacity(0.4)
              : color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (sunnah.isCompleted ? SunnahTheme.emerald : color)
                .withOpacity(0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: sunnah.isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
            : Text(sunnah.icon,
            style: TextStyle(fontSize: size.width * 0.058)),
      ),
    );
  }

  Widget _buildBottomRow(Color cardColor) {
    return Row(
      children: [
        buildMiniTag(sunnah.type, cardColor, size, theme),
        if (sunnah.rakaat > 0) ...[
          SizedBox(width: size.width * 0.015),
          buildMiniTag('${sunnah.rakaat} ركعات', SunnahTheme.blue, size, theme),
        ],
        const Spacer(),
        _buildCompleteBtn(cardColor),
      ],
    );
  }

  Widget _buildCompleteBtn(Color cardColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.035,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: sunnah.isCompleted
              ? theme.completedBtnGradient()
              : LinearGradient(colors: [
            cardColor,
            Color.lerp(cardColor, Colors.black, 0.15)!,
          ]),
          boxShadow: [
            BoxShadow(
              color: (sunnah.isCompleted ? Colors.grey : cardColor)
                  .withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sunnah.isCompleted ? Icons.close_rounded : Icons.check_rounded,
              color: sunnah.isCompleted
                  ? (theme.isDark ? theme.textSecondary : Colors.black45)
                  : Colors.white,
              size: 14,
            ),
            SizedBox(width: size.width * 0.015),
            Text(
              sunnah.isCompleted ? 'إلغاء' : 'أكمل',
              style: TextStyle(
                color: sunnah.isCompleted
                    ? (theme.isDark ? theme.textSecondary : Colors.black54)
                    : Colors.white,
                fontSize: size.width * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Static helpers used by other widgets too
  static Widget buildImportanceBadge(
      String importance, Size size, SunnahTheme theme) {
    final isHigh = importance == 'مؤكدة';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SunnahTheme.badgeRadius),
        gradient: isHigh
            ? SunnahTheme.highImportanceGradient
            : SunnahTheme.normalImportanceGradient,
        boxShadow: [
          BoxShadow(
            color: (isHigh ? SunnahTheme.purple : SunnahTheme.blue)
                .withOpacity(0.25),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        isHigh ? '★ مؤكدة' : '◆ مستحبة',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.024,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget buildMiniTag(
      String text, Color color, Size size, SunnahTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SunnahTheme.badgeRadius),
        color: color.withOpacity(theme.isDark ? 0.12 : 0.08),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.028,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}