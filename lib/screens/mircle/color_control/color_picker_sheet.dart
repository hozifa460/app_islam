import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'miracle_color_provider.dart';
import 'miracle_theme.dart';

class ColorPickerSheet extends StatefulWidget {
  const ColorPickerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<MiracleColorProvider>(),
        child: const ColorPickerSheet(),
      ),
    );
  }

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  double _brightnessShift = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _brightnessShift =
              context.read<MiracleColorProvider>().brightnessShift;
        });
      }
    });
  }

  // ← هذا يجب أن يتطابق مع _adjustAccentColor في Provider
  Color _applyBrightness(Color base, double shift) {
    final hsl = HSLColor.fromColor(base);

    if (shift < 0.5) {
      final factor  = shift / 0.5;
      final darkest = hsl
          .withLightness((hsl.lightness * 0.25).clamp(0.02, 0.5))
          .withSaturation((hsl.saturation * 0.6).clamp(0.0, 1.0))
          .toColor();
      return Color.lerp(darkest, base, factor)!;
    } else if (shift > 0.5) {
      final factor   = (shift - 0.5) / 0.5;
      final lightest = hsl
          .withLightness((hsl.lightness + 0.3).clamp(0.0, 0.95))
          .withSaturation((hsl.saturation * 0.8).clamp(0.0, 1.0))
          .toColor();
      return Color.lerp(base, lightest, factor)!;
    } else {
      return base;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider     = context.watch<MiracleColorProvider>();
    final selected     = provider.selectedIndex;
    final preset       = provider.current;
    final previewColor = _applyBrightness(
        preset.primary, _brightnessShift);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color:        const Color(0xFF0D1829),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
              color: previewColor.withOpacity(0.4), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color:      previewColor.withOpacity(0.15),
            blurRadius: 30,
            offset:     const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width:  48,
                height: 4,
                decoration: BoxDecoration(
                  color:        previewColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ── Header ──
                    Row(
                      children: [
                        Container(
                          width:  44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:        previewColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: previewColor.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.palette_rounded,
                              color: previewColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تخصيص اللون',
                                style: GoogleFonts.cairo(
                                  color:      Colors.white,
                                  fontSize:   17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Color Theme',
                                style: GoogleFonts.poppins(
                                  color:        previewColor.withOpacity(0.7),
                                  fontSize:     10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width:  38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: previewColor,
                            boxShadow: [
                              BoxShadow(
                                color:        previewColor.withOpacity(0.5),
                                blurRadius:   12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Selected Banner ──
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width:   double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color:        previewColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: previewColor.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Text(preset.emoji,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset.name,
                                  style: GoogleFonts.cairo(
                                    color:      Colors.white,
                                    fontSize:   14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  preset.nameEn,
                                  style: GoogleFonts.poppins(
                                    color:    previewColor.withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:        previewColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: previewColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              'محدد ✓',
                              style: GoogleFonts.cairo(
                                color:      previewColor,
                                fontSize:   11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Color Grid ──
                    _ColorGrid(
                      selected:        selected,
                      brightness:      _brightnessShift,
                      applyBrightness: _applyBrightness,
                      onSelect: (index) {
                        context
                            .read<MiracleColorProvider>()
                            .selectPreset(index);
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Brightness Slider ──
                    _BrightnessSlider(
                      preset:          preset,
                      brightnessShift: _brightnessShift,
                      previewColor:    previewColor,
                      applyBrightness: _applyBrightness,
                      // ← يُحدِّث Provider فوراً أثناء السحب
                      onChanged: (val) {
                        setState(() => _brightnessShift = val);
                        context
                            .read<MiracleColorProvider>()
                            .setBrightnessShiftImmediate(val);
                      },
                      // ← يحفظ عند الانتهاء
                      onChangeEnd: (val) {
                        context
                            .read<MiracleColorProvider>()
                            .saveBrightnessShift(val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Preview Strip ──
                    _PreviewStrip(
                      preset:          preset,
                      previewColor:    previewColor,
                      brightnessShift: _brightnessShift,
                      applyBrightness: _applyBrightness,
                    ),
                    const SizedBox(height: 16),

                    // ── Apply Button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: previewColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'تطبيق اللون',
                          style: GoogleFonts.cairo(
                            fontSize:   15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  COLOR GRID
// ══════════════════════════════════════════════
class _ColorGrid extends StatelessWidget {
  final int      selected;
  final double   brightness;
  final Color Function(Color, double) applyBrightness;
  final ValueChanged<int> onSelect;

  const _ColorGrid({
    required this.selected,
    required this.brightness,
    required this.applyBrightness,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const cols    = 4;
      const spacing = 8.0;
      final itemW   =
          (constraints.maxWidth - spacing * (cols - 1)) / cols;
      // ارتفاع محسوب بدقة:
      // circle=28 + gap=3 + emoji=16 + gap=2 + text=12 + padding=16 = 77
      const itemH = 95.0;

      return Wrap(
        spacing:    spacing,
        runSpacing: spacing,
        children: List.generate(
          kMiracleColorPresets.length,
              (index) {
            final preset     = kMiracleColorPresets[index];
            final color      = applyBrightness(preset.primary, brightness);
            final isSelected = selected == index;

            return GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width:  itemW,
                height: itemH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: isSelected
                        ? color.withOpacity(0.7)
                        : Colors.white.withOpacity(0.08),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color:        color.withOpacity(0.28),
                      blurRadius:   10,
                      spreadRadius: 1,
                    ),
                  ]
                      : [],
                ),
                // ← ClipRect يقطع أي overflow
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical:   6,
                      horizontal: 4,
                    ),
                    child: Column(
                      mainAxisSize:      MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Color Circle ──
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow
                            if (isSelected)
                              Container(
                                width:  38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    color.withOpacity(0.28),
                                    Colors.transparent,
                                  ]),
                                ),
                              ),
                            // Circle
                            Container(
                              width:  28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                boxShadow: [
                                  BoxShadow(
                                    color:     color.withOpacity(0.35),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size:  13,
                              )
                                  : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        // ── Emoji ──
                        Text(
                          preset.emoji,
                          style: const TextStyle(
                            fontSize: 13,
                            height:   1.0,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // ── Name ──
                        SizedBox(
                          width: itemW - 10,
                          child: Text(
                            preset.name,
                            style: GoogleFonts.cairo(
                              color: isSelected
                                  ? color
                                  : Colors.white54,
                              fontSize:   7.5,
                              height:     1.1,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines:  1,
                            overflow:  TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════
//  BRIGHTNESS SLIDER
// ══════════════════════════════════════════════
class _BrightnessSlider extends StatelessWidget {
  final MiracleColorPreset preset;
  final double             brightnessShift;
  final Color              previewColor;
  final Color Function(Color, double) applyBrightness;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _BrightnessSlider({
    required this.preset,
    required this.brightnessShift,
    required this.previewColor,
    required this.applyBrightness,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    // ألوان التدرج من داكن لفاتح
    final darkColor  = applyBrightness(preset.primary, 0.0);
    final midColor   = applyBrightness(preset.primary, 0.5);
    final lightColor = applyBrightness(preset.primary, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: previewColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.brightness_6_rounded,
                  color: previewColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'درجة اللون',
                style: GoogleFonts.cairo(
                  color:      Colors.white,
                  fontSize:   13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Value label
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color:        previewColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: previewColor.withOpacity(0.25)),
                ),
                child: Text(
                  _getBrightnessLabel(brightnessShift),
                  style: GoogleFonts.cairo(
                    color:      previewColor,
                    fontSize:   11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Gradient bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                colors: [darkColor, midColor, lightColor],
              ),
              boxShadow: [
                BoxShadow(
                  color:      previewColor.withOpacity(0.2),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight:          2,
              thumbColor:           previewColor,
              activeTrackColor:     Colors.transparent,
              inactiveTrackColor:   Colors.transparent,
              overlayColor:         previewColor.withOpacity(0.15),
              thumbShape:           const RoundSliderThumbShape(
                enabledThumbRadius: 12,
              ),
              overlayShape:         const RoundSliderOverlayShape(
                overlayRadius: 20,
              ),
            ),
            child: Slider(
              value:       brightnessShift,
              min:         0.0,
              max:         1.0,
              divisions:   20,
              onChanged:   onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),

          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'داكن',
                style: GoogleFonts.cairo(
                  color:    darkColor,
                  fontSize: 10,
                ),
              ),
              Text(
                'أصلي',
                style: GoogleFonts.cairo(
                  color:    Colors.white54,
                  fontSize: 10,
                ),
              ),
              Text(
                'فاتح',
                style: GoogleFonts.cairo(
                  color:    lightColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getBrightnessLabel(double val) {
    if (val < 0.2)       return 'داكن جداً';
    if (val < 0.4)       return 'داكن';
    if (val < 0.6)       return 'أصلي';
    if (val < 0.8)       return 'فاتح';
    return 'فاتح جداً';
  }
}

// ══════════════════════════════════════════════
//  PREVIEW STRIP
// ══════════════════════════════════════════════
class _PreviewStrip extends StatelessWidget {
  final MiracleColorPreset preset;
  final Color              previewColor;
  final double             brightnessShift;
  final Color Function(Color, double) applyBrightness;

  const _PreviewStrip({
    required this.preset,
    required this.previewColor,
    required this.brightnessShift,
    required this.applyBrightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معاينة مباشرة',
            style: GoogleFonts.cairo(
              color:      Colors.white60,
              fontSize:   11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // BG preview
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: applyBrightness(
                        preset.bg1, brightnessShift * 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: previewColor.withOpacity(0.15)),
                  ),
                  child: Center(
                    child: Text(
                      'خلفية',
                      style: GoogleFonts.cairo(
                        color:    Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Glass card preview
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: previewColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      'بطاقة',
                      style: GoogleFonts.cairo(
                        color:      previewColor,
                        fontSize:   10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Accent preview
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        previewColor,
                        applyBrightness(
                            preset.neonAccent, brightnessShift),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color:      previewColor.withOpacity(0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'رئيسي',
                      style: GoogleFonts.cairo(
                        color:      Colors.white,
                        fontSize:   10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}