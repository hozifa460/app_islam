import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/sunnah_model.dart';
import '../services/sunnah_service.dart';
import 'sunnah_theme.dart';
import 'sunnah_card.dart';

class SunnahDetailsSheet {
  static void show({
    required BuildContext context,
    required SunnahModel sunnah,
    required Size size,
    required SunnahTheme theme,
    required SunnahService service,
    required VoidCallback onStateChanged,
  }) {
    final cardColor = SunnahTheme.hexToColor(sunnah.color);
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.62,
          maxChildSize: 0.92,
          minChildSize: 0.42,
          builder: (ctx, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SunnahTheme.detailSheetRadius)),
              border: Border.all(
                  color: cardColor.withValues(alpha: 0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollCtrl,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  _buildHeaderSection(sunnah, cardColor, size, theme),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailCard(
                          icon: '📝',
                          title: 'الوصف',
                          content: sunnah.description,
                          color: cardColor,
                          size: size,
                          theme: theme,
                        ),
                        SizedBox(height: size.height * 0.014),
                        _buildDetailCard(
                          icon: '📖',
                          title: 'الدليل من السنة',
                          content: sunnah.hadith,
                          color: SunnahTheme.gold,
                          size: size,
                          theme: theme,
                        ),
                        SizedBox(height: size.height * 0.014),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoTile(
                                service.getCategoryLabel(sunnah.timeCategory),
                                'وقت السنة',
                                '🕐',
                                cardColor,
                                size,
                                theme,
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: _buildInfoTile(
                                sunnah.importance,
                                'الأهمية',
                                sunnah.importance == 'مؤكدة' ? '⭐' : '💫',
                                sunnah.importance == 'مؤكدة'
                                    ? SunnahTheme.gold
                                    : SunnahTheme.blue,
                                size,
                                theme,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildActionButton(
                            context, sunnah, service, size, theme, onStateChanged),
                        SizedBox(height: size.height * 0.006),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('إغلاق',
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: size.width * 0.035,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildHeaderSection(
      SunnahModel sunnah, Color cardColor, Size size, SunnahTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.06),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cardColor.withValues(alpha: theme.isDark ? 0.12 : 0.08),
            cardColor.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: size.width * 0.2,
            height: size.width * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(colors: [
                cardColor.withValues(alpha: 0.25),
                cardColor.withValues(alpha: 0.08),
              ]),
              border: Border.all(
                  color: cardColor.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(sunnah.icon,
                  style: TextStyle(fontSize: size.width * 0.1)),
            ),
          ),
          SizedBox(height: size.height * 0.018),
          Text(sunnah.name,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: size.width * 0.048,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center),
          SizedBox(height: size.height * 0.012),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              SunnahCard.buildMiniTag(sunnah.type, cardColor, size, theme),
              SunnahCard.buildImportanceBadge(sunnah.importance, size, theme),
              if (sunnah.rakaat > 0)
                SunnahCard.buildMiniTag(
                    '${sunnah.rakaat} ركعات', SunnahTheme.blue, size, theme),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailCard({
    required String icon,
    required String title,
    required String content,
    required Color color,
    required Size size,
    required SunnahTheme theme,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.isDark ? SunnahTheme.darkBg : const Color(0xFFF9FAFB),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: TextStyle(fontSize: size.width * 0.04)),
            SizedBox(width: size.width * 0.02),
            Text(title,
                style: TextStyle(
                  color: color,
                  fontSize: size.width * 0.034,
                  fontWeight: FontWeight.bold,
                )),
          ]),
          SizedBox(height: size.height * 0.009),
          Text(content,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: size.width * 0.033,
                height: 1.7,
              )),
        ],
      ),
    );
  }

  static Widget _buildInfoTile(String value, String label, String icon,
      Color color, Size size, SunnahTheme theme) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.isDark ? SunnahTheme.darkBg : const Color(0xFFF9FAFB),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(children: [
        Text(icon, style: TextStyle(fontSize: size.width * 0.055)),
        SizedBox(height: size.height * 0.006),
        Text(value,
            style: TextStyle(
              color: color,
              fontSize: size.width * 0.034,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center),
        Text(label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: size.width * 0.028,
            )),
      ]),
    );
  }

  static Widget _buildActionButton(
      BuildContext context,
      SunnahModel sunnah,
      SunnahService service,
      Size size,
      SunnahTheme theme,
      VoidCallback onStateChanged) {
    return StatefulBuilder(
      builder: (ctx, setSheet) => GestureDetector(
        onTap: () async {
          HapticFeedback.mediumImpact();
          await service.toggleCompletion(sunnah.id);
          setSheet(() {});
          onStateChanged();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: sunnah.isCompleted
                ? theme.completedBtnGradient()
                : SunnahTheme.emeraldGradient,
            boxShadow: [
              BoxShadow(
                color: (sunnah.isCompleted ? Colors.grey : SunnahTheme.emerald)
                    .withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                sunnah.isCompleted
                    ? Icons.replay_rounded
                    : Icons.check_circle_rounded,
                color: sunnah.isCompleted
                    ? (theme.isDark ? theme.textSecondary : Colors.black54)
                    : Colors.white,
                size: 22,
              ),
              SizedBox(width: size.width * 0.025),
              Text(
                sunnah.isCompleted ? 'إلغاء الإكمال' : '✨ علّم كمكتمل',
                style: TextStyle(
                  color: sunnah.isCompleted
                      ? (theme.isDark ? theme.textSecondary : Colors.black54)
                      : Colors.white,
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}