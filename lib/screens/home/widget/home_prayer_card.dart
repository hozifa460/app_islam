import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../languages/app_localizations.dart';
import '../../prayer/features/prayer_os/domain/controllers/prayer_journey_controller.dart';
import '../../prayer/features/prayer_os/presentation/widgets/prayer_log_sheet.dart';
import 'home_card_skeleton.dart';

class HomePrayerCard extends StatefulWidget {
  final Color primary;
  final Color gold;
  final Color cardColor;
  final bool isDark;
  final Map<String, String> prayerTimes;
  final String cityName;
  final bool isPrayerLoading;
  final String nextPrayerName;
  final String timeLeft;
  final List<Map<String, dynamic>> prayerInfo;
  final Animation<double> prayerPulseAnim;
  final VoidCallback onTap;

  const HomePrayerCard({
    super.key,
    required this.primary,
    required this.gold,
    required this.cardColor,
    required this.isDark,
    required this.prayerTimes,
    required this.cityName,
    required this.isPrayerLoading,
    required this.nextPrayerName,
    required this.timeLeft,
    required this.prayerInfo,
    required this.prayerPulseAnim,
    required this.onTap,
  });

  @override
  State<HomePrayerCard> createState() => _HomePrayerCardState();
}

class _HomePrayerCardState extends State<HomePrayerCard>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _breatheController;
  late Animation<double> _starAnim;
  late Animation<double> _breatheAnim;
  late List<_StarData> _stars;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _starAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
    final rng = Random(42);
    _stars = List.generate(20, (i) => _StarData(
      x: rng.nextDouble(),
      y: rng.nextDouble() * 0.5,
      size: 0.5 + rng.nextDouble() * 1.6,
      phase: rng.nextDouble() * 2 * pi,
    ));
  }

  @override
  void dispose() {
    _starController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط­ط³ط§ط¨ط§طھ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  double _calculateProgress() {
    if (widget.prayerTimes.isEmpty) return 0.0;
    try {
      final now = DateTime.now();
      DateTime? prev, next;
      final keys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      for (int i = 0; i < keys.length; i++) {
        final t = _parseTime(widget.prayerTimes[keys[i]] ?? '');
        if (t.isAfter(now)) {
          next = t;
          prev = i > 0
              ? _parseTime(widget.prayerTimes[keys[i - 1]] ?? '')
              : _parseTime(widget.prayerTimes['Isha'] ?? '')
              .subtract(const Duration(days: 1));
          break;
        }
      }
      if (next == null) {
        next = _parseTime(widget.prayerTimes['Fajr'] ?? '')
            .add(const Duration(days: 1));
        prev = _parseTime(widget.prayerTimes['Isha'] ?? '');
      }
      if (prev != null) {
        final total = next.difference(prev).inMinutes;
        final elapsed = now.difference(prev).inMinutes;
        return total <= 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);
      }
    } catch (_) {}
    return 0.5;
  }

  DateTime _parseTime(String t) {
    final now = DateTime.now();
    try {
      final p = t.split(' ')[0].split(':');
      return DateTime(now.year, now.month, now.day,
          int.parse(p[0]), int.parse(p[1]));
    } catch (_) {
      return now;
    }
  }

  String _formatAMPM(String t24) {
    if (t24.isEmpty || t24 == '--:--') return '--:--';
    try {
      final p = t24.split(' ')[0].split(':');
      int h = int.parse(p[0]);
      final m = int.parse(p[1]);
      final period = h >= 12 ? 'ظ…' : 'طµ';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return t24;
    }
  }

  String _getCurrentKey() {
    final now = DateTime.now();
    final keys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final k in keys) {
      if (_parseTime(widget.prayerTimes[k] ?? '').isAfter(now)) return k;
    }
    return 'Fajr';
  }

  ({String name, String time}) _getAfterNext() {
    final keys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final idx = keys.indexOf(_getCurrentKey());
    final nextKey = keys[(idx + 1) % keys.length];
    String name = '';
    for (final p in widget.prayerInfo) {
      if (p['key'] == nextKey) {
        name = p['name'] as String;
        break;
      }
    }
    return (
    name: name,
    time: _formatAMPM(widget.prayerTimes[nextKey] ?? '')
    );
  }

  IconData _timeIcon() {
    final h = DateTime.now().hour;
    if (h >= 4 && h < 7) return Icons.nightlight_round;
    if (h >= 7 && h < 12) return Icons.wb_sunny_rounded;
    if (h >= 12 && h < 15) return Icons.light_mode_rounded;
    if (h >= 15 && h < 17) return Icons.wb_sunny_outlined;
    if (h >= 17 && h < 20) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_rounded;
  }
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// طھط­ط¯ظٹط¯ ط§ظ„ظپطھط±ط© ط§ظ„ط­ط§ظ„ظٹط© ط¨ظ†ط§ط،ظ‹ ط¹ظ„ظ‰ ظ…ظˆط§ظ‚ظٹطھ ط§ظ„طµظ„ط§ط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  String _getCurrentPeriod() {
    if (widget.prayerTimes.isEmpty) {
      // fallback ظ„ظ„ظˆظ‚طھ ط§ظ„ط¹ط§ظ… ط¥ط°ط§ ظ„ظ… طھظڈط­ظ…ظ„ ط§ظ„ظ…ظˆط§ظ‚ظٹطھ ط¨ط¹ط¯
      final h = DateTime.now().hour;
      if (h >= 4 && h < 7)  return 'fajr';
      if (h >= 7 && h < 12) return 'day';
      if (h >= 12 && h < 15) return 'noon';
      if (h >= 15 && h < 17) return 'asr';
      if (h >= 17 && h < 20) return 'dusk';
      return 'night';
    }

    final now = DateTime.now();

    final fajr    = _parseTime(widget.prayerTimes['Fajr']    ?? '');
    final sunrise = _parseTime(widget.prayerTimes['Sunrise'] ?? '');
    final dhuhr   = _parseTime(widget.prayerTimes['Dhuhr']   ?? '');
    final asr     = _parseTime(widget.prayerTimes['Asr']     ?? '');
    final maghrib = _parseTime(widget.prayerTimes['Maghrib'] ?? '');
    final isha    = _parseTime(widget.prayerTimes['Isha']    ?? '');

    // ظ‚ط¨ظ„ ط§ظ„ظپط¬ط± = ظ„ظٹظ„
    if (now.isBefore(fajr)) return 'night';

    // ظپط¬ط± â†’ ط´ط±ظˆظ‚
    if (now.isAfter(fajr) && now.isBefore(sunrise)) return 'fajr';

    // ط´ط±ظˆظ‚ â†’ ط¸ظ‡ط± (ظ†طµظپ ط§ظ„ظ…ط³ط§ظپط© ط¨ظٹظ† ط§ظ„ط´ط±ظˆظ‚ ظˆط§ظ„ط¸ظ‡ط± = ط¶ط­ظ‰)
    if (now.isAfter(sunrise) && now.isBefore(dhuhr)) {
      final midMorning = sunrise.add(
        Duration(
          minutes: dhuhr.difference(sunrise).inMinutes ~/ 2,
        ),
      );
      return now.isBefore(midMorning) ? 'day' : 'noon_before';
    }

    // ط¸ظ‡ط± â†’ ط¹طµط±
    if (now.isAfter(dhuhr) && now.isBefore(asr)) return 'noon';

    // ط¹طµط± â†’ ظ…ط؛ط±ط¨
    if (now.isAfter(asr) && now.isBefore(maghrib)) {
      // ظ†طµظپ ط§ظ„ظ…ط³ط§ظپط© ط¨ظٹظ† ط§ظ„ط¹طµط± ظˆط§ظ„ظ…ط؛ط±ط¨ = ظ„ط­ط¸ط© ظ‚ط±ظٹط¨ط© ظ…ظ† ط§ظ„ط؛ط±ظˆط¨
      final midEvening = asr.add(
        Duration(
          minutes: maghrib.difference(asr).inMinutes ~/ 2,
        ),
      );
      return now.isBefore(midEvening) ? 'asr' : 'dusk_before';
    }

    // ظ…ط؛ط±ط¨ â†’ ط¹ط´ط§ط،
    if (now.isAfter(maghrib) && now.isBefore(isha)) return 'dusk';

    // ط¨ط¹ط¯ ط§ظ„ط¹ط´ط§ط، = ظ„ظٹظ„
    return 'night';
  }

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// طµظˆط±ط© ط§ظ„ط®ظ„ظپظٹط© ط­ط³ط¨ ظ…ظˆط§ظ‚ظٹطھ ط§ظ„طµظ„ط§ط© ط§ظ„ظپط¹ظ„ظٹط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  String _bgImage() {
    final period = _getCurrentPeriod();
    switch (period) {
      case 'fajr':
        return 'assets/images/mosque_fajr.jpg';
      case 'day':
      case 'noon_before':
        return 'assets/images/mosque_day.jpg';
      case 'noon':
        return 'assets/images/mosque_noon.jpg';
      case 'asr':
        return 'assets/images/mosque_asr.jpg';
      case 'dusk_before':
      case 'dusk':
        return 'assets/images/mosque_dusk.jpg';
      case 'night':
      default:
        return 'assets/images/mosque_night.jpg';
    }
  }

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط§ظ„ظ€ overlay ط­ط³ط¨ ظ…ظˆط§ظ‚ظٹطھ ط§ظ„طµظ„ط§ط© ط§ظ„ظپط¹ظ„ظٹط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  List<Color> _overlayColors() {
    final period = _getCurrentPeriod();

    if (!widget.isDark) {
      // Light Mode: ط£ظ„ظˆط§ظ† ط«ط§ط¨طھط© ط­ط³ط¨ ط§ظ„ظپطھط±ط©
      switch (period) {
        case 'fajr':
          return [
            const Color(0xFF1A237E).withValues(alpha: 0.40),
            const Color(0xFF1A237E).withValues(alpha: 0.35),
            const Color(0xFF1A237E).withValues(alpha: 0.50),
          ];
        case 'day':
        case 'noon_before':
          return [
            const Color(0xFF0D47A1).withValues(alpha: 0.35),
            const Color(0xFF0D47A1).withValues(alpha: 0.30),
            const Color(0xFF0D47A1).withValues(alpha: 0.45),
          ];
        case 'noon':
          return [
            const Color(0xFF01579B).withValues(alpha: 0.35),
            const Color(0xFF01579B).withValues(alpha: 0.30),
            const Color(0xFF01579B).withValues(alpha: 0.45),
          ];
        case 'asr':
          return [
            const Color(0xFF4A148C).withValues(alpha: 0.38),
            const Color(0xFF8B5E3C).withValues(alpha: 0.35),
            const Color(0xFF4A148C).withValues(alpha: 0.50),
          ];
        case 'dusk_before':
        case 'dusk':
          return [
            const Color(0xFF880E4F).withValues(alpha: 0.40),
            const Color(0xFF8B3A1A).withValues(alpha: 0.35),
            const Color(0xFF880E4F).withValues(alpha: 0.55),
          ];
        case 'night':
        default:
          return [
            const Color(0xFF0D1B2A).withValues(alpha: 0.45),
            const Color(0xFF0D1B2A).withValues(alpha: 0.40),
            const Color(0xFF0D1B2A).withValues(alpha: 0.55),
          ];
      }
    } else {
      // Dark Mode: ط£ظ„ظˆط§ظ† ط؛ط§ظ…ظ‚ط© ط­ط³ط¨ ط§ظ„ظپطھط±ط©
      switch (period) {
        case 'fajr':
          return [
            const Color(0xFF0A0F1E).withValues(alpha: 0.85),
            const Color(0xFF1B1F4A).withValues(alpha: 0.80),
            const Color(0xFF2D1B69).withValues(alpha: 0.90),
          ];
        case 'day':
        case 'noon_before':
          return [
            const Color(0xFF0D1B2A).withValues(alpha: 0.82),
            const Color(0xFF1A3A5C).withValues(alpha: 0.78),
            const Color(0xFF1E4D7B).withValues(alpha: 0.88),
          ];
        case 'noon':
          return [
            const Color(0xFF0D1B2A).withValues(alpha: 0.82),
            const Color(0xFF1E3A5F).withValues(alpha: 0.78),
            const Color(0xFF2A5E8C).withValues(alpha: 0.88),
          ];
        case 'asr':
          return [
            const Color(0xFF1A1205).withValues(alpha: 0.83),
            const Color(0xFF3D2C0A).withValues(alpha: 0.80),
            const Color(0xFF5A3A0F).withValues(alpha: 0.90),
          ];
        case 'dusk_before':
        case 'dusk':
          return [
            const Color(0xFF0D0810).withValues(alpha: 0.83),
            const Color(0xFF3D1030).withValues(alpha: 0.80),
            const Color(0xFF7A2010).withValues(alpha: 0.90),
          ];
        case 'night':
        default:
          return [
            const Color(0xFF020508).withValues(alpha: 0.88),
            const Color(0xFF080C14).withValues(alpha: 0.85),
            const Color(0xFF0F1520).withValues(alpha: 0.92),
          ];
      }
    }
  }

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط§ظ„ظ†ط¬ظˆظ… طھط¸ظ‡ط± ط­ط³ط¨ ظ…ظˆط§ظ‚ظٹطھ ط§ظ„طµظ„ط§ط© ط§ظ„ظپط¹ظ„ظٹط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  bool _showStars() {
    final period = _getCurrentPeriod();
    return period == 'night' || period == 'fajr';
  }
  Color _accentColor() {
    final h = DateTime.now().hour;
    if (!widget.isDark) {
      if (h >= 4 && h < 7) return const Color(0xFFD4DCFF);
      if (h >= 7 && h < 12) return const Color(0xFFFFE5A0);
      if (h >= 12 && h < 15) return const Color(0xFFFFE080);
      if (h >= 15 && h < 17) return const Color(0xFFFFCC80);
      if (h >= 17 && h < 20) return const Color(0xFFFFAA70);
      return const Color(0xFFE8C86A);
    } else {
      if (h >= 4 && h < 7) return const Color(0xFF9AA8E8);
      if (h >= 7 && h < 12) return const Color(0xFFFFD085);
      if (h >= 12 && h < 15) return const Color(0xFFFFC857);
      if (h >= 15 && h < 17) return const Color(0xFFFFAA44);
      if (h >= 17 && h < 20) return const Color(0xFFFF7043);
      return const Color(0xFFC8A44D);
    }
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // BUILD
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    if (widget.isPrayerLoading) return _buildSkeleton();

    final journey = context.watch<PrayerJourneyController>();
    final isLogged = journey.isPrayerLogged(_getCurrentKey());
    final accent = _accentColor();
    final progress = _calculateProgress();
    final after = _getAfterNext();

    return GestureDetector(
      onTap: () async {
        if (!isLogged) {
          final r = await showPrayerLogSheet(
            context,
            prayerKey: _getCurrentKey(),
            prayerName: widget.nextPrayerName,
            prayerTime: widget.prayerTimes[_getCurrentKey()] ?? '--:--',
            primaryColor: widget.primary,
          );
          if (r != null && r.success && mounted) {
            await journey.initialize();
          }
        } else {
          widget.onTap();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_starAnim, _breatheAnim]),
        builder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.isDark
                      ? Colors.black.withValues(alpha: 0.50)
                      : widget.primary.withValues(alpha: 0.18),
                  blurRadius: widget.isDark ? 20 : 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  _buildBackground(),
                  if (_showStars() && widget.isDark)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _StarsPainter(
                          stars: _stars,
                          twinkle: _starAnim.value,
                        ),
                      ),
                    ),
                  _buildContent(tr, accent, progress, after),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط®ظ„ظپظٹط© + overlay
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        _bgImage(),
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        errorBuilder: (_, __, ___) {
          final fallbackColors = widget.isDark
              ? [const Color(0xFF080C14), const Color(0xFF1B2838)]
              : [widget.primary.withValues(alpha: 0.8), widget.primary];
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: fallbackColors,
              ),
            ),
          );
        },
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظ…ط­طھظˆظ‰ â€” ظ…ط³ط§ظپط§طھ ظ…ظڈظ‚ظ„ظ‘طµط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildContent(
      AppLocalizations tr,
      Color accent,
      double progress,
      ({String name, String time}) after,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ط§ظ„ظ…ظˆظ‚ط¹ + ط£ظٹظ‚ظˆظ†ط©
          _buildTopRow(accent),
          const SizedBox(height: 10),

          // ط§ط³ظ… ط§ظ„طµظ„ط§ط© + ط§ظ„ط¹ط¯ط§ط¯
          _buildMainSection(tr, accent),
          const SizedBox(height: 10),

          // ط´ط±ظٹط· ط§ظ„طھظ‚ط¯ظ…
          _buildProgressBar(progress, accent),
          const SizedBox(height: 8),

          // ط§ظ„طµظ„ط§ط© ط§ظ„طھط§ظ„ظٹط©
          if (after.name.isNotEmpty) ...[
            _buildAfterNext(tr, accent, after),
            const SizedBox(height: 8),
          ],

          // طµظپ ظˆط§ط­ط¯ ظ„ط£ظˆظ‚ط§طھ ط§ظ„طµظ„ظˆط§طھ ط¨ط¯ظ„ طµظپظٹظ†
          _buildPrayerRow6(accent),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„ظ…ظˆظ‚ط¹ + ط£ظٹظ‚ظˆظ†ط© â€” ط£طµط؛ط±
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildTopRow(Color accent) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.40),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: accent, size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.cityName,
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.20),
            shape: BoxShape.circle,
            border: Border.all(
              color: accent.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Icon(_timeIcon(), color: accent, size: 14),
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„طµظ„ط§ط© ط§ظ„طھط§ظ„ظٹط© + ط§ظ„ط¹ط¯ط§ط¯ â€” ظپظٹ طµظپ ظˆط§ط­ط¯ ظ…ظڈط¯ظ…ط¬
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildMainSection(AppLocalizations tr, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ط§ط³ظ… ط§ظ„طµظ„ط§ط©
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr.nextPrayerLabel,
                style: GoogleFonts.cairo(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  widget.nextPrayerName.isEmpty
                      ? '...'
                      : widget.nextPrayerName,
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // ط¹ط¯ط§ط¯ ظ…ظڈط¯ظ…ط¬ ط£طµط؛ط±
        _buildTimerBadge(accent),
      ],
    );
  }

  Widget _buildTimerBadge(Color accent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isDark
                ? accent.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isDark
                  ? accent.withValues(alpha: 0.28)
                  : Colors.white.withValues(alpha: 0.45),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, color: accent, size: 13),
              const SizedBox(width: 5),
              Text(
                widget.timeLeft.isEmpty ? '--:--' : widget.timeLeft,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط´ط±ظٹط· ط§ظ„طھظ‚ط¯ظ… â€” ط£ظ†ط­ظپ
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildProgressBar(double progress, Color accent) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (_, val, __) {
        return LayoutBuilder(builder: (_, bc) {
          final totalW = bc.maxWidth.isFinite ? bc.maxWidth : 200.0;
          final fillW = (totalW * val).clamp(0.0, totalW);
          const barH = 4.0;
          const dotSize = 8.0;

          return SizedBox(
            width: totalW,
            height: dotSize + 2,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // track
                Positioned(
                  left: 0,
                  right: 0,
                  top: (dotSize + 2 - barH) / 2,
                  child: Container(
                    height: barH,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // fill
                if (fillW > 0)
                  Positioned(
                    left: 0,
                    top: (dotSize + 2 - barH) / 2,
                    child: Container(
                      width: fillW,
                      height: barH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.60),
                            Colors.white,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.20),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                // ظ†ظ‚ط·ط©
                if (val > 0.03)
                  Positioned(
                    left: (fillW - dotSize / 2)
                        .clamp(0.0, totalW - dotSize),
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„طµظ„ط§ط© ط§ظ„طھط§ظ„ظٹط© â€” ط£طµط؛ط±
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildAfterNext(
      AppLocalizations tr,
      Color accent,
      ({String name, String time}) after,
      ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.30),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.skip_next_rounded,
                color: Colors.white.withValues(alpha: 0.50),
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${after.name} ${tr.willStartAt}',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  after.time,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // âœ… طµظپ ظˆط§ط­ط¯ ظ„ظƒظ„ ط§ظ„طµظ„ظˆط§طھ ط§ظ„ط³طھط© â€” ط¨ط¯ظˆظ† overflow
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildPrayerRow6(Color accent) {
    return Row(
      children: widget.prayerInfo.asMap().entries.map((e) {
        final i = e.key;
        final p = e.value;
        final isNext =
        widget.nextPrayerName.contains(p['name'] as String);
        final time =
        _formatAMPM(widget.prayerTimes[p['key']] ?? '--:--');

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
            child: _buildPrayerCell(
              p: p,
              time: time,
              isNext: isNext,
              accent: accent,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrayerCell({
    required Map<String, dynamic> p,
    required String time,
    required bool isNext,
    required Color accent,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: isNext
            ? accent.withValues(alpha: widget.isDark ? 0.16 : 0.20)
            : Colors.white.withValues(alpha: widget.isDark ? 0.05 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isNext
              ? accent.withValues(alpha: widget.isDark ? 0.35 : 0.40)
              : Colors.white.withValues(alpha: widget.isDark ? 0.06 : 0.20),
          width: isNext ? 1 : 0.6,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            p['icon'] as IconData,
            size: 13,
            color: isNext
                ? accent
                : Colors.white.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              p['name'] as String,
              style: GoogleFonts.cairo(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: isNext
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              style: GoogleFonts.cairo(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isNext
                    ? accent
                    : Colors.white.withValues(alpha: 0.50),
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // ط§ظ„طھط­ظ…ظٹظ„
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  Widget _buildSkeleton() {
    return HomeCardSkeleton(
      isDark: widget.isDark,
      height: 180,
      borderRadius: BorderRadius.circular(24),
    );
  }


}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط±ط³ط§ظ… ط§ظ„ظ†ط¬ظˆظ…
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class _StarData {
  final double x, y, size, phase;
  _StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
  });
}

class _StarsPainter extends CustomPainter {
  final List<_StarData> stars;
  final double twinkle;
  _StarsPainter({required this.stars, required this.twinkle});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final o = (0.2 + 0.8 * sin(s.phase + twinkle * pi * 2))
          .clamp(0.05, 1.0);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        Paint()
          ..color = Colors.white.withValues(alpha: o)
          ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, s.size * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter o) => o.twinkle != twinkle;
}