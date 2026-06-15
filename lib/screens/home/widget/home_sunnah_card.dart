import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../languages/app_localizations.dart';
import '../../sunnah/model/sunnah_model.dart';
import '../../sunnah/services/sunnah_service.dart';
import 'home_card_skeleton.dart';

class HomeSunnahCard extends StatefulWidget {
  final Color primaryColor;
  final Color gold;
  final bool isDark;
  final VoidCallback onNavigateToTracker;

  const HomeSunnahCard({
    super.key,
    required this.primaryColor,
    required this.gold,
    required this.isDark,
    required this.onNavigateToTracker,
  });

  @override
  State<HomeSunnahCard> createState() => _HomeSunnahCardState();
}

class _HomeSunnahCardState extends State<HomeSunnahCard>
    with TickerProviderStateMixin {
  final SunnahService _service = SunnahService();
  bool _isLoading = true;
  Timer? _tick;

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  // â•گâ•گ FIX #9: ط¥ط²ط§ظ„ط© _waveCtrl â€” shimmer effect ظ…ظƒظ„ظپ â•گâ•گ
  // ط§ط³طھط¨ط¯ط§ظ„ ط¨ظ€ static gradient ط¨ط¯ظˆظ† ط£ظ†ظٹظ…ظٹط´ظ† ظ…ط³طھظ…ط±

  late final _fadeAnim =
  CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  late final _pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    _load();
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _load() async {
    await _service.loadData();
    if (mounted) {
      setState(() => _isLoading = false);
      _fadeCtrl.forward();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _dk => widget.isDark;
  Color get _p => widget.primaryColor;
  Color get _g => widget.gold;
  Color get _card => _dk ? const Color(0xFF111B18) : Colors.white;
  Color get _t1 => _dk ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get _t2 => _dk ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _t3 => _dk ? Colors.white38 : const Color(0xFFCBD5E1);
  static const _em = Color(0xFF10B981);
  static const _emD = Color(0xFF047857);
  Color _hex(String h) => Color(int.parse(h.replaceFirst('#', '0xFF')));

  String get _emoji {
    final h = DateTime.now().hour;
    if (h >= 3 && h < 6) return 'ًںŒ™';
    if (h >= 6 && h < 9) return 'ًںŒ…';
    if (h >= 9 && h < 12) return 'âک€ï¸ڈ';
    if (h >= 12 && h < 15) return 'ًںŒ‍';
    if (h >= 15 && h < 17) return 'ًںŒ¤ï¸ڈ';
    if (h >= 17 && h < 19) return 'ًںŒ†';
    if (h >= 19 && h < 21) return 'ًںŒ‡';
    return 'ًںŒƒ';
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    if (_isLoading) return _skeleton();

    final list = _service.getCurrentSunnahs();
    final done = list.where((s) => s.isCompleted).length;
    final total = list.length;
    final pct = total > 0 ? done / total : 0.0;
    final allDone = pct >= 1.0;
    final period = _service.getCurrentPeriodLabel();

    SunnahModel? next;
    try {
      next = list.firstWhere((s) => !s.isCompleted);
    } catch (_) {}

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .06), end: Offset.zero)
            .animate(_fadeAnim),
        child: GestureDetector(
          onTap: widget.onNavigateToTracker,
          child: _outerShell(
            allDone: allDone,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _heroHeader(period, pct, done, total, allDone),
                if (next != null && !allDone)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: _tile(next),
                  ),
                if (total == 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: _noSunnah(),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: _cta(allDone, total),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeleton() {
    return HomeCardSkeleton(
      isDark: widget.isDark,
      height: 90,
      borderRadius: BorderRadius.circular(20),
    );
  }

  Widget _outerShell({required bool allDone, required Widget child}) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, ch) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: allDone
                ? _g.withValues(alpha: .2 + _pulseAnim.value * .12)
                : _p.withValues(alpha: .08),
            width: allDone ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (allDone ? _g : _p)
                  .withValues(alpha: .06 + (allDone ? _pulseAnim.value * .06 : 0)),
              blurRadius: allDone ? 20 : 12,
              spreadRadius: allDone ? 1 : 0,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.grey.withValues(alpha: _dk ? .10 : .45),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ch,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(color: _card, child: child),
      ),
    );
  }

  Widget _heroHeader(
      String period, double pct, int done, int total, bool allDone) {
    final accent = allDone ? _g : _p;
    final tr = context.tr;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: allDone
                      ? [
                    _g.withValues(alpha: _dk ? .20 : .14),
                    _g.withValues(alpha: _dk ? .05 : .03),
                  ]
                      : [
                    _p.withValues(alpha: _dk ? .14 : .08),
                    _p.withValues(alpha: _dk ? .03 : .02),
                  ],
                ),
              ),
            ),

            // â•گâ•گ FIX #9: ط¥ط²ط§ظ„ط© shimmer overlay â€” ظ…ظƒظ„ظپ ط¬ط¯ط§ظ‹ â•گâ•گ
            if (allDone)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        _g.withValues(alpha: .04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            Positioned(
              top: -15,
              left: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: .05),
                ),
              ),
            ),
            Positioned(
              bottom: -8,
              right: -10,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _g.withValues(alpha: .04),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              tr.sunnahOfTime,
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _dk ? Colors.white : _p,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        _liveBadge(period),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _circleProgress(pct, done, total, allDone, accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveBadge(String period) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _em.withValues(alpha: _dk ? .12 : .08),
        border: Border.all(color: _em.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // â•گâ•گ FIX: ظ†ظ‚ط·ط© ط¨ط³ظٹط·ط© ط¨ط¯ظ„ AnimatedBuilder â•گâ•گ
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _em,
                boxShadow: [
                  BoxShadow(
                    color: _em.withValues(alpha: _pulseAnim.value * .6),
                    blurRadius: 4,
                    spreadRadius: _pulseAnim.value * 1.5,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            period,
            style: GoogleFonts.cairo(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: _em,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleProgress(
      double pct, int done, int total, bool allDone, Color accent) {
    const size = 52.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 4.5,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(
                _dk ? Colors.white.withValues(alpha: .06) : Colors.black.withValues(alpha: .05),
              ),
            ),
          ),
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => CircularProgressIndicator(
                value: v,
                strokeWidth: 4.5,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
          ),
          allDone
              ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, v, __) => Transform.scale(
              scale: v,
              child: const Text('âœ…', style: TextStyle(fontSize: 18)),
            ),
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: done),
                duration: const Duration(milliseconds: 800),
                builder: (_, v, __) => Text(
                  '$v',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: accent,
                    height: 1,
                  ),
                ),
              ),
              Text(
                '/$total',
                style: GoogleFonts.cairo(fontSize: 9, color: _t2, height: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(SunnahModel s) {
    final c = _hex(s.color);
    final checked = s.isCompleted;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        await _service.toggleCompletion(s.id);
        if (mounted) setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: checked
                ? [_em.withValues(alpha: _dk ? .10 : .06), _em.withValues(alpha: _dk ? .03 : .02)]
                : [c.withValues(alpha: _dk ? .10 : .05), c.withValues(alpha: _dk ? .03 : .01)],
          ),
          border: Border.all(
            color: checked ? _em.withValues(alpha: .20) : c.withValues(alpha: .12),
          ),
        ),
        child: Row(
          children: [
            _iconBox(s, c, checked),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: checked ? _t2 : _t1,
                            decoration: checked ? TextDecoration.lineThrough : null,
                            decorationColor: _t3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      _importanceBadge(s.importance),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(fontSize: 9.5, color: _t2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _actionBtn(s, c, checked),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(SunnahModel s, Color c, bool checked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: checked
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_em, _emD],
        )
            : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.withValues(alpha: .2), c.withValues(alpha: .06)],
        ),
        border: Border.all(
          color: checked ? _em.withValues(alpha: .3) : c.withValues(alpha: .15),
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.elasticOut,
          transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w),
          child: checked
              ? const Icon(Icons.check_rounded,
              key: ValueKey(true), color: Colors.white, size: 20)
              : Text(s.icon, key: ValueKey(s.id),
              style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _importanceBadge(String imp) {
    final tr = context.tr;
    final high = imp == 'âک… ${tr.confirmed}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: high
              ? [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
              : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        ),
      ),
      child: Text(
        high ? 'âک… ${tr.confirmed}' : tr.recommended,
        style: GoogleFonts.cairo(
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _actionBtn(SunnahModel s, Color c, bool checked) {
    final tr = context.tr;
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await _service.toggleCompletion(s.id);
        if (mounted) setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: checked
              ? null
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c, c.withValues(alpha: .8)],
          ),
          color: checked
              ? (_dk ? Colors.white.withValues(alpha: .06) : Colors.grey.shade100)
              : null,
          border: checked ? Border.all(color: _t3.withValues(alpha: .3)) : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Row(
            key: ValueKey(checked),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                checked ? Icons.replay_rounded : Icons.check_rounded,
                size: 12,
                color: checked ? _t2 : Colors.white,
              ),
              const SizedBox(width: 3),
              Text(
                checked ? tr.undoAction : tr.completeAction,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: checked ? _t2 : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noSunnah() {
    final tr = context.tr;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            _g.withValues(alpha: _dk ? .07 : .04),
            _g.withValues(alpha: _dk ? .02 : .01),
          ],
        ),
        border: Border.all(color: _g.withValues(alpha: .08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ًںŒ™', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr.noSunnahNow,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: _t2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tr.browseAllSunnah,
                  style: GoogleFonts.cairo(fontSize: 10, color: _t3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cta(bool allDone, int total) {
    final tr = context.tr;
    final accent = allDone ? _g : _p;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [accent, accent.withValues(alpha: .82)],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onNavigateToTracker,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white24,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  allDone
                      ? 'ًں“‹ ${tr.viewAllSunnah}'
                      : 'ًں“‹ ${tr.viewDetailsAndMore}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .2),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â•گâ•گ FIX #9: ط¥ط²ط§ظ„ط© _shimmerText â€” ط§ط³طھط¨ط¯ط§ظ„ ط¨ظ†طµ ط¹ط§ط¯ظٹ ظ…ط¹ ظ„ظˆظ† ط°ظ‡ط¨ظٹ â•گâ•گ
  String _motive(double p, int r) {
    final tr = context.tr;
    if (r == 1) return 'âڑ، ${tr.motiveOneSunnah}';
    if (p > .7) return 'ًں”¥ ${tr.motiveAlmostDone}';
    if (p > .4) return 'ًں’ھ ${tr.motiveKeepGoing}';
    if (p > 0) return 'ًںŒ± ${tr.motiveGoodStart}';
    return 'âœ¨ ${tr.motiveStartNow}';
  }
}