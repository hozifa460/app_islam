import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/prayer_record.dart';
import '../../data/sources/spiritual_content.dart';
import '../../domain/controllers/prayer_journey_controller.dart';

/// ظپطھط­ ط´ط§ط´ط© طھط³ط¬ظٹظ„ ط§ظ„طµظ„ط§ط©
Future<LogPrayerResult?> showPrayerLogSheet(
    BuildContext context, {
      required String prayerKey,
      required String prayerName,
      required String prayerTime,
      required Color primaryColor,
    }) async {
  HapticFeedback.mediumImpact();

  return showModalBottomSheet<LogPrayerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => PrayerLogSheet(
      prayerKey: prayerKey,
      prayerName: prayerName,
      prayerTime: prayerTime,
      primaryColor: primaryColor,
    ),
  );
}

class PrayerLogSheet extends StatefulWidget {
  final String prayerKey;
  final String prayerName;
  final String prayerTime;
  final Color primaryColor;

  const PrayerLogSheet({
    super.key,
    required this.prayerKey,
    required this.prayerName,
    required this.prayerTime,
    required this.primaryColor,
  });

  @override
  State<PrayerLogSheet> createState() => _PrayerLogSheetState();
}

class _PrayerLogSheetState extends State<PrayerLogSheet> {
  // ط§ظ„ط­ط§ظ„ط©
  PrayerTiming _timing = PrayerTiming.withinTime;
  PrayerQuality _quality = PrayerQuality.normal;
  PrayerLocation _location = PrayerLocation.home;
  bool _prayedSunnahBefore = false;
  bool _prayedSunnahAfter = false;
  bool _saidAdhkar = false;
  bool _prayedWithJamaa = false;
  bool _feltKhushu = false;
  bool _isLoading = false;
  PrayerSpiritualContent? _content;

  final _gold = const Color(0xFFE6B325);

  @override
  void initState() {
    super.initState();
    _content = getRandomContentForPrayer(widget.prayerKey);
  }

  double _calculateNoorPreview() {
    double base = 100.0;

    base *= _timing.multiplier;
    base *= _quality.multiplier;
    base *= _location.bonusMultiplier.clamp(1.0, 5.0);

    if (_prayedSunnahBefore) base += 20;
    if (_prayedSunnahAfter) base += 20;
    if (_saidAdhkar) base += 15;
    if (_feltKhushu) base += 30;
    if (_prayedWithJamaa && _location != PrayerLocation.mosque) {
      base += 25;
    }

    return base;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              _buildHeader(textColor, subColor),
              const SizedBox(height: 16),

              // ط¥ط°ط§ ظƒط§ظ† ظپط¬ط±طŒ ط£ط¸ظ‡ط± ط­ط¯ظٹط«
              if (widget.prayerKey == 'Fajr') ...[
                _buildQuoteCard(_content!.hadiths.first, textColor, subColor),
                const SizedBox(height: 16),
              ],

              // Timing
              _buildTimingSection(textColor, subColor),
              const SizedBox(height: 16),

              // Location
              _buildLocationSection(textColor, subColor),
              const SizedBox(height: 16),

              // Quality
              _buildQualitySection(textColor, subColor),
              const SizedBox(height: 16),

              // Advanced Options
              _buildAdvancedSection(textColor, subColor),
              const SizedBox(height: 24),

              // Noor Preview
              _buildNoorPreview(textColor),
              const SizedBox(height: 24),

              // Submit
              _buildSubmitButton(textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color subColor) {
    return Column(
      children: [
        Icon(Icons.mosque, color: widget.primaryColor, size: 40),
        const SizedBox(height: 12),
        Text(
          'تسجيل صلاة ${widget.prayerName}',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.prayerTime,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: subColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard(QuoteItem quote, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            '❝ ${quote.text} ❞',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 14,
              color: textColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quote.source,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: subColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSection(Color textColor, Color subColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'متى صليت؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PrayerTiming.values
              .where((t) => t != PrayerTiming.missed)
              .map((timing) => _TimingChip(
            timing: timing,
            selected: _timing == timing,
            onTap: () => setState(() => _timing = timing),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection(Color textColor, Color subColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أين صليت؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: PrayerLocation.values
              .map((loc) => Expanded(
            child: _LocationChip(
              location: loc,
              selected: _location == loc,
              onTap: () {
                setState(() {
                  _location = loc;
                  if (loc == PrayerLocation.mosque) {
                    _prayedWithJamaa = true;
                  }
                });
              },
            ),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQualitySection(Color textColor, Color subColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كيف كانت صلاتك؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: PrayerQuality.values.map((quality) {
            return Expanded(
              child: _QualityChip(
                quality: quality,
                selected: _quality == quality,
                onTap: () {
                  setState(() {
                    _quality = quality;
                    if (quality == PrayerQuality.khushu) {
                      _feltKhushu = true;
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(Color textColor, Color subColor) {
    return ExpansionTile(
      title: Text(
        'تفاصيل إضافية',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      children: [
        _ToggleOption(
          title: 'صليت السنة القبلية',
          value: _prayedSunnahBefore,
          onChanged: (v) => setState(() => _prayedSunnahBefore = v),
          color: Colors.purple,
        ),
        _ToggleOption(
          title: 'صليت السنة البعدية',
          value: _prayedSunnahAfter,
          onChanged: (v) => setState(() => _prayedSunnahAfter = v),
          color: Colors.purple,
        ),
        _ToggleOption(
          title: 'قلت أذكار ما بعد الصلاة',
          value: _saidAdhkar,
          onChanged: (v) => setState(() => _saidAdhkar = v),
          color: Colors.teal,
        ),
        if (_location != PrayerLocation.mosque)
          _ToggleOption(
            title: 'صليت جماعة',
            value: _prayedWithJamaa,
            onChanged: (v) => setState(() => _prayedWithJamaa = v),
            color: Colors.blue,
          ),
        _ToggleOption(
          title: 'شعرت بالخشوع',
          value: _feltKhushu,
          onChanged: (v) => setState(() => _feltKhushu = v),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildNoorPreview(Color textColor) {
    final noor = _calculateNoorPreview();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: noor),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _gold.withValues(alpha: 0.15),
                _gold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: _gold),
                  const SizedBox(width: 8),
                  Text(
                    'نقاط النور المتوقعة',
                    style: GoogleFonts.cairo(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '+${value.toInt()}',
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _gold,
                ),
              ),
              if (noor > 150)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    noor > 300 ? '🌟 صلاة مثالية!' : '✨ أجر مضاعف!',
                    style: GoogleFonts.cairo(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(Color textColor) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          setState(() => _isLoading = true);

          final result = await PrayerJourneyController().logPrayer(
            prayerKey: widget.prayerKey,
            timing: _timing,
            quality: _quality,
            location: _location,
            prayedSunnahBefore: _prayedSunnahBefore,
            prayedSunnahAfter: _prayedSunnahAfter,
            saidAdhkar: _saidAdhkar,
            prayedWithJamaa: _prayedWithJamaa,
            feltKhushu: _feltKhushu,
          );

          if (mounted) {
            Navigator.pop(context, result);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
          color: Colors.white,
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 22),
            const SizedBox(width: 10),
            Text(
              'تسجيل الصلاة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Custom Chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TimingChip extends StatelessWidget {
  final PrayerTiming timing;
  final bool selected;
  final VoidCallback onTap;

  const _TimingChip({
    required this.timing,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? timing.color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? timing.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_circle, color: timing.color, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              timing.arabicName,
              style: GoogleFonts.cairo(
                color: selected ? timing.color : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final PrayerLocation location;
  final bool selected;
  final VoidCallback onTap;

  const _LocationChip({
    required this.location,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMosque = location == PrayerLocation.mosque;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              location.icon,
              color: selected ? Colors.blue : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              location.arabicName,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: selected ? Colors.blue : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isMosque && selected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6B325).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'أ—27',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: const Color(0xFFE6B325),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  final PrayerQuality quality;
  final bool selected;
  final VoidCallback onTap;

  const _QualityChip({
    required this.quality,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? quality.color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? quality.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              quality.icon,
              color: selected ? quality.color : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              quality.arabicName,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: selected ? quality.color : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final Color color;

  const _ToggleOption({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: color,
    );
  }
}