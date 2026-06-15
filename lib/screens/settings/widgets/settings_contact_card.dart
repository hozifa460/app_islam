import 'package:flutter/material.dart';
import '../../../languages/app_localizations.dart';
import 'settings_theme.dart';
import 'settings_shared_widgets.dart';

class SettingsContactCard extends StatelessWidget {
  final SettingsTheme theme;
  final double w;

  const SettingsContactCard({super.key, required this.theme, required this.w});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
      icon: Icons.star_rounded,
      color: const Color(0xFFFFB800),
      title: context.tr.rateAppTitle, // 👈 تمت الترجمة
      sub: context.tr.rateAppSub, // 👈 تمت الترجمة
      onTap: () {}
      ),
      (
      icon: Icons.share_rounded,
      color: const Color(0xFF2ECC71),
      title: context.tr.shareAppTitle, // 👈 تمت الترجمة
      sub: context.tr.shareAppSub, // 👈 تمت الترجمة
      onTap: () {}
      ),
      (
      icon: Icons.bug_report_rounded,
      color: const Color(0xFFE74C3C),
      title: context.tr.reportBugTitle, // 👈 تمت الترجمة
      sub: context.tr.reportBugSub, // 👈 تمت الترجمة
      onTap: () {}
      ),
    ];

    return SettingsCard(
      theme: theme, w: w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((e) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            SettingsActionRow(icon: e.value.icon, color: e.value.color, title: e.value.title, sub: e.value.sub, onTap: e.value.onTap, w: w, theme: theme),
            if (e.key < items.length - 1) SettingsDivider(theme: theme),
          ]);
        }).toList(),
      ),
    );
  }
}