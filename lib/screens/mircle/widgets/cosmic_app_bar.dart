import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/global_search_action_button.dart';
import '../color_control/miracle_theme.dart';

class CosmicAppBar extends StatelessWidget {
  final MiracleThemeColors t;
  final Color    primaryColor;
  final bool     showFavoritesOnly;
  final bool     showSearch;
  final Animation<double> pulseAnim;
  final double   expandedHeight;
  final VoidCallback onBack;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onSearchToggle;

  const CosmicAppBar({
    super.key,
    required this.t,
    required this.primaryColor,
    required this.showFavoritesOnly,
    required this.showSearch,
    required this.pulseAnim,
    required this.expandedHeight,
    required this.onBack,
    required this.onFavoriteToggle,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating:  false,
      pinned:    true,
      elevation: 0,
      backgroundColor: t.bg1.withOpacity(0.95),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: onBack,
          child: Container(
            decoration: BoxDecoration(
              color:        t.glass,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: t.glassBorder),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: t.text, size: 18),
          ),
        ),
      ),
      actions: [
        _ActionBtn(
          icon:  showFavoritesOnly
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: showFavoritesOnly ? MiracleTheme.neonRed : t.text,
          t:     t,
          onTap: onFavoriteToggle,
        ),
        _ActionBtn(
          icon:  showSearch
              ? Icons.search_off_rounded
              : Icons.search_rounded,
          color: showSearch ? MiracleTheme.neonBlue : t.text,
          t:     t,
          onTap: onSearchToggle,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: GlobalSearchActionButton(
            primaryColor: primaryColor,
            iconColor:    t.text,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle:  true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: _AppBarTitle(t: t),
        background: _AppBarBackground(t: t, pulseAnim: pulseAnim),
      ),
    );
  }
}

// ── Small action button ───────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final MiracleThemeColors t;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width:  40,
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:        t.glass,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: t.glassBorder),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

// ── Title (two lines: Arabic + English) ──────────────────────────────────────
class _AppBarTitle extends StatelessWidget {
  final MiracleThemeColors t;
  const _AppBarTitle({required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'الإعجاز العلمي',
          style: GoogleFonts.cairo(
            color:      Colors.white,
            fontWeight: FontWeight.bold,
            fontSize:   17,
            shadows: [
              Shadow(
                color:     MiracleTheme.neonBlue.withOpacity(0.6),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        Text(
          'Scientific Miracles in Islam',
          style: GoogleFonts.poppins(
            color:        MiracleTheme.neonBlue.withOpacity(0.8),
            fontSize:     8,
            fontWeight:   FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Flexible background with cosmic orbs + pulsing icon ──────────────────────
class _AppBarBackground extends StatelessWidget {
  final MiracleThemeColors t;
  final Animation<double>  pulseAnim;

  const _AppBarBackground({required this.t, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          colors: [t.bg2, t.bg1],
        ),
      ),
      child: Stack(
        children: [
          // Orbs
          Positioned(
            top: -50, right: -50,
            child: _Orb(size: 180, color: MiracleTheme.neonBlue.withOpacity(0.07)),
          ),
          Positioned(
            top: 20, left: -40,
            child: _Orb(size: 120, color: MiracleTheme.neonPurple.withOpacity(0.08)),
          ),
          Positioned(
            bottom: 20, right: 60,
            child: _Orb(size: 70, color: MiracleTheme.neonGold.withOpacity(0.06)),
          ),

          // Centre pulsing icon
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 55),
              child: AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          MiracleTheme.neonBlue
                              .withOpacity(0.15 * pulseAnim.value),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                    Container(
                      width: 58, height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                        border: Border.all(
                          color: MiracleTheme.neonBlue.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: MiracleTheme.neonBlue
                                .withOpacity(0.25 * pulseAnim.value),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: MiracleTheme.neonGold,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color  color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape:    BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent]),
    ),
  );
}