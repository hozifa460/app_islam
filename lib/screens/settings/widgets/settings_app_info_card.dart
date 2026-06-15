import 'package:flutter/material.dart';
import '../../../languages/app_localizations.dart';
import 'settings_theme.dart';
import 'settings_shared_widgets.dart';

class SettingsAppInfoCard extends StatelessWidget {
  final SettingsTheme theme;
  final double w;

  const SettingsAppInfoCard({super.key, required this.theme, required this.w});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.mosque_rounded, color: theme.currentPrimary,
      title: context.tr.developer,
      sub: 'حذيفة محمد عبد الظاهر'),
      (icon: Icons.verified_rounded, color: const Color(0xFF2ECC71),
      title: context.tr.versionWithNumber('1.0.0'), // 👈 رقم الإصدار كمتغير
      sub: context.tr.lastUpdateYear('2025'), // 👈 سنة التحديث كمتغير
      ),
    ];

    return SettingsCard(
      theme: theme, w: w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((e) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            SettingsInfoRow(icon: e.value.icon, color: e.value.color, title: e.value.title, sub: e.value.sub, w: w, theme: theme),
            if (e.key < items.length - 1) SettingsDivider(theme: theme),
          ]);
        }).toList(),
      ),
    );
  }
}