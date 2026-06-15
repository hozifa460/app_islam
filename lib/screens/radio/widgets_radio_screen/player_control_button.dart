// lib/screens/radio/widgets/player_control_button.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// زر تحكم المشغل (سابق / تالي)
/// ══════════════════════════════════════════════════════════════
class PlayerControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const PlayerControlButton({
    super.key,
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          color: RadioColors.iconColor(context),
          size: size * 0.55,
        ),
      ),
    );
  }
}