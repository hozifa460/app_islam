import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/tasbih/widgets/tasbih_beads.dart';
import '../models/tasbih_model.dart';
import '../tasbih_screen.dart';
import 'tasbih_theme.dart';

class TasbihCard extends StatelessWidget {
  final TasbihModel currentTasbih;
  final int counter;
  final int round;
  final double progress;
  final Color primaryColor;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const TasbihCard({
    super.key,
    required this.currentTasbih,
    required this.counter,
    required this.round,
    required this.progress,
    required this.primaryColor,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: TasbihTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDhikrContent(),
          const SizedBox(height: 16),
          _buildCounterRow(),
          const SizedBox(height: 14),
          _buildBeadsArea(),
        ],
      ),
    );
  }

  // ✅ محتوى الذكر
  Widget _buildDhikrContent() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: TasbihTheme.dhikrDecoration,
      child: Column(
        children: [
          Text(
            currentTasbih.text,
            textAlign: TextAlign.center,
            style: TasbihTheme.dhikrText,
          ),
          const SizedBox(height: 10),
          Text(
            currentTasbih.translation,
            textAlign: TextAlign.center,
            style: TasbihTheme.translationText,
          ),
          const SizedBox(height: 8),
          Text(
            currentTasbih.transliteration,
            textAlign: TextAlign.center,
            style: TasbihTheme.transliterationText,
          ),
        ],
      ),
    );
  }

  // ✅ صف العداد والجولة
  Widget _buildCounterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$counter / ${currentTasbih.target}',
          style: TasbihTheme.counterText,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Round: $round', style: TasbihTheme.roundText),
            const SizedBox(height: 6),
            SizedBox(
              width: TasbihTheme.progressBarWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: TasbihTheme.progressBarHeight,
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ منطقة الخرز
  Widget _buildBeadsArea() {
    return GestureDetector(
      onTap: onTap,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: TasbihTheme.beadAreaDecoration(Colors.grey.shade200),
          child: Column(
            children: [
              CurvedBeadsProgress(
                progress: progress,
                beadCount: TasbihTheme.beadCount,
                color: primaryColor,
              ),
              const SizedBox(height: 8),
              Text('اضغط للتسبيح', style: TasbihTheme.tapHint),
            ],
          ),
        ),
      ),
    );
  }
}