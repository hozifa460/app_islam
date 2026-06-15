// lib/screens/radio/widgets/back_button_widget.dart

import 'package:flutter/material.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_colors.dart';
import 'package:islamic_app/screens/radio/widgets_radio_screen/theme/radio_shapes.dart';

/// ══════════════════════════════════════════════════════════════
/// زر الرجوع المخصص
/// ══════════════════════════════════════════════════════════════
class RadioBackButton extends StatelessWidget {
  final Color primary;

  const RadioBackButton({super.key, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: RadioSizes.backButtonSize,
        height: RadioSizes.backButtonSize,
        decoration: RadioShapes.backButtonDecoration(context),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: RadioColors.iconColor(context),
          size: 17,
        ),
      ),
    );
  }
}