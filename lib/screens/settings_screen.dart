// lib/screens/settings_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(int) onColorChanged;
  final bool isDarkMode;
  final int selectedColorIndex;
  final List<Color> appColors;
  final List<String> colorNames;
  final Color primaryColor;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.selectedColorIndex,
    required this.appColors,
    required this.colorNames,
    required this.primaryColor,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  static const _bgDark = Color(0xFF0A0E17);
  static const _bgLight = Color(0xFFF0F4FF);
  static const _gold = Color(0xFFE6B325);
  static const _cardDark = Color(0xFF151B26);
  static const _cardLight = Color(0xFFFFFFFF);

  // ط£ظٹظ‚ظˆظ†ط§طھ ظ„ظƒظ„ ظ„ظˆظ†
  static const List<IconData> _colorIcons = [
    Icons.mosque_rounded,        // ط£ط®ط¶ط± ط¥ط³ظ„ط§ظ…ظٹ
    Icons.park_rounded,          // ط£ط®ط¶ط± ط²ظ…ط±ط¯ظٹ
    Icons.cloud_rounded,         // ط£ط²ط±ظ‚ ط³ظ…ط§ظˆظٹ
    Icons.auto_awesome_rounded,  // ط¨ظ†ظپط³ط¬ظٹ
    Icons.favorite_rounded,      // ظˆط±ط¯ظٹ ط؛ط§ظ…ظ‚
    Icons.water_rounded,         // طھظٹظ„
    Icons.wb_sunny_rounded,      // ط¨ط±طھظ‚ط§ظ„ظٹ
    Icons.nights_stay_rounded,   // ظ†ظٹظ„ظٹ
    Icons.landscape_rounded,     // ط¨ظ†ظٹ
    Icons.filter_drama_rounded,  // ط±ظ…ط§ط¯ظٹ ظپط­ظ…ظٹ
    Icons.local_fire_department_rounded, // ط£ط­ظ…ط±
    Icons.sailing_rounded,       // ط£ط®ط¶ط± ط¨ط­ط±ظٹ
  ];

  late bool _isDark;
  late int _selectedColor;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDarkMode;
    _selectedColor = widget.selectedColorIndex;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  /// ط§ظ„ظ„ظˆظ† ط§ظ„ط±ط¦ظٹط³ظٹ ط§ظ„ط­ط§ظ„ظٹ
  Color get _currentPrimary => widget.appColors[_selectedColor];

  /// ظ„ظˆظ† ط°ظ‡ط¨ظٹ ظٹطھظƒظٹظپ ظ…ط¹ ط§ظ„ظ„ظˆظ† ط§ظ„ظ…ط®طھط§ط±
  Color get _accent => _gold;

  void _toggleTheme(bool val) {
    HapticFeedback.lightImpact();
    setState(() => _isDark = val);
    widget.onThemeChanged(val);
  }

  void _selectColor(int index) {
    if (_selectedColor == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedColor = index);
    widget.onColorChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final bg = _isDark ? _bgDark : _bgLight;
    final textColor = _isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            _buildBackground(w, size.height),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(w, textColor),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (w * 0.045).clamp(14.0, 24.0),
                        vertical: (w * 0.03).clamp(10.0, 18.0),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // â”€â”€ ظ‚ط³ظ… ط§ظ„ظ…ط¸ظ‡ط± â”€â”€
                          _buildSectionLabel(
                              'المظهر', Icons.palette_rounded, w, textColor),
                          SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                          _buildThemeCard(w, textColor),

                          SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),

                          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                          //  âک… ظ‚ط³ظ… ط§ظ„ط£ظ„ظˆط§ظ† ط§ظ„ط¬ط¯ظٹط¯ âک…
                          // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
                          _buildSectionLabel(
                              'لون التطبيق', Icons.color_lens_rounded, w, textColor),
                          SizedBox(height: (w * 0.015).clamp(4.0, 8.0)),
                          _buildColorSubtitle(w, textColor),
                          SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                          _buildColorSelectionCard(w, textColor),

                          SizedBox(height: (w * 0.03).clamp(10.0, 18.0)),

                          // â”€â”€ ظ…ط¹ط§ظٹظ†ط© ط§ظ„ظ„ظˆظ† ط§ظ„ظ…ط®طھط§ط± â”€â”€
                          _buildColorPreviewCard(w, textColor),

                          SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),

                          // â”€â”€ ط§ظ„طھط·ط¨ظٹظ‚ â”€â”€
                          _buildSectionLabel(
                              'التطبيق', Icons.info_outline_rounded, w, textColor),
                          SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                          _buildAppInfoCard(w, textColor),

                          SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),

                          // â”€â”€ ط§ظ„طھظˆط§طµظ„ â”€â”€
                          _buildSectionLabel(
                              'التواصل والدعم', Icons.support_agent_rounded, w, textColor),
                          SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                          _buildContactCard(w, textColor),

                          SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),

                          // â”€â”€ ط­ظˆظ„ ط§ظ„طھط·ط¨ظٹظ‚ â”€â”€
                          _buildAboutCard(w, textColor),

                          SizedBox(height: (w * 0.08).clamp(24.0, 48.0)),
                        ]),
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

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„ط®ظ„ظپظٹط©
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildBackground(double w, double h) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: _isDark
                    ? [
                  const Color(0xFF0D1520),
                  _bgDark,
                  const Color(0xFF0A0E17),
                ]
                    : [
                  const Color(0xFFEEF3FF),
                  _bgLight,
                  const Color(0xFFE8F0FF),
                ],
              ),
            ),
          ),
          // ط¨ظ‚ط¹ط© ط¶ظˆط¦ظٹط© ط¨ظ„ظˆظ† ط§ظ„طھط·ط¨ظٹظ‚ ط§ظ„ظ…ط®طھط§ط±
          Positioned(
            top: -w * 0.3,
            right: -w * 0.2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: w * 0.7,
              height: w * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _currentPrimary.withValues(alpha: _isDark ? 0.08 : 0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -w * 0.2,
            left: -w * 0.15,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: w * 0.55,
              height: w * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _currentPrimary.withValues(alpha: _isDark ? 0.05 : 0.04),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط§ظ„ظ‡ظٹط¯ط±
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildHeader(double w, Color textColor) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        (w * 0.045).clamp(14.0, 24.0),
        (w * 0.04).clamp(12.0, 22.0),
        (w * 0.045).clamp(14.0, 24.0),
        (w * 0.02).clamp(8.0, 16.0),
      ),
      child: Row(
        children: [
          _buildIconBtn(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
            w: w,
            textColor: textColor,
          ),
          SizedBox(width: (w * 0.035).clamp(10.0, 18.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الإعدادات',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.055).clamp(18.0, 26.0),
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  'تخصيص تجربتك',
                  style: GoogleFonts.cairo(
                    fontSize: (w * 0.03).clamp(10.0, 13.0),
                    color: textColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          // ط£ظٹظ‚ظˆظ†ط© ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ ط¨ظ„ظˆظ† ط§ظ„طھط·ط¨ظٹظ‚
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: (w * 0.11).clamp(38.0, 50.0),
            height: (w * 0.11).clamp(38.0, 50.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPrimary.withValues(alpha: 0.12),
              border: Border.all(color: _currentPrimary.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.settings_rounded,
              color: _currentPrimary,
              size: (w * 0.055).clamp(18.0, 26.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required VoidCallback onTap,
    required double w,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (w * 0.1).clamp(36.0, 46.0),
        height: (w * 0.1).clamp(36.0, 46.0),
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isDark
                ? Colors.white.withValues(alpha: 0.1)
                : _currentPrimary.withValues(alpha: 0.22),
          ),
        ),
        child: Icon(icon,
            color: textColor, size: (w * 0.045).clamp(14.0, 20.0)),
      ),
    );
  }

  // â”€â”€ ط¹ظ†ظˆط§ظ† ط§ظ„ظ‚ط³ظ… â”€â”€
  Widget _buildSectionLabel(
      String label, IconData icon, double w, Color textColor) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: (w * 0.07).clamp(24.0, 32.0),
          height: (w * 0.07).clamp(24.0, 32.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPrimary.withValues(alpha: 0.12),
            border: Border.all(color: _currentPrimary.withValues(alpha: 0.25)),
          ),
          child: Icon(icon,
              color: _currentPrimary, size: (w * 0.035).clamp(12.0, 16.0)),
        ),
        SizedBox(width: (w * 0.025).clamp(8.0, 14.0)),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: (w * 0.04).clamp(13.0, 17.0),
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        SizedBox(width: (w * 0.025).clamp(8.0, 14.0)),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _currentPrimary.withValues(alpha: 0.3),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ظ†طµ ظپط±ط¹ظٹ ظ„ظ‚ط³ظ… ط§ظ„ط£ظ„ظˆط§ظ†
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildColorSubtitle(double w, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(right: (w * 0.1).clamp(32.0, 46.0)),
      child: Text(
        'اختر اللون الرئيسي لتخصيص مظهر التطبيق بالكامل',
        style: GoogleFonts.cairo(
          fontSize: (w * 0.028).clamp(10.0, 12.5),
          color: textColor.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  âک…âک…âک… ط¨ط·ط§ظ‚ط© ط§ط®طھظٹط§ط± ط§ظ„ط£ظ„ظˆط§ظ† âک…âک…âک…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildColorSelectionCard(double w, Color textColor) {
    return _Card(
      isDark: _isDark,
      borderColor: _currentPrimary,
      w: w,
      child: Padding(
        padding: EdgeInsets.all((w * 0.04).clamp(12.0, 20.0)),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: w > 400 ? 6 : 4,
            mainAxisSpacing: (w * 0.03).clamp(10.0, 16.0),
            crossAxisSpacing: (w * 0.03).clamp(10.0, 16.0),
            childAspectRatio: 0.78,
          ),
          itemCount: widget.appColors.length,
          itemBuilder: (context, index) {
            final color = widget.appColors[index];
            final name = widget.colorNames[index];
            final icon = index < _colorIcons.length
                ? _colorIcons[index]
                : Icons.circle;
            final isSelected = _selectedColor == index;

            return GestureDetector(
              onTap: () => _selectColor(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color
                      : color.withValues(alpha: _isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : color.withValues(alpha: 0.3),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ط£ظٹظ‚ظˆظ†ط© ط£ظˆ ط¹ظ„ط§ظ…ط© طµط­
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: isSelected
                          ? const Icon(
                        Icons.check_rounded,
                        key: ValueKey('check'),
                        color: Colors.white,
                        size: 24,
                      )
                          : Icon(
                        icon,
                        key: ValueKey('icon_$index'),
                        color: color,
                        size: 22,
                      ),
                    ),
                    SizedBox(height: (w * 0.012).clamp(3.0, 6.0)),
                    // ط§ط³ظ… ط§ظ„ظ„ظˆظ†
                    Flexible(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.024).clamp(8.5, 11.0),
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (_isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  âک…âک…âک… ظ…ط¹ط§ظٹظ†ط© ط§ظ„ظ„ظˆظ† ط§ظ„ظ…ط®طھط§ط± âک…âک…âک…
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildColorPreviewCard(double w, Color textColor) {
    final iconIndex = _selectedColor < _colorIcons.length
        ? _selectedColor
        : 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: EdgeInsets.all((w * 0.05).clamp(16.0, 24.0)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _currentPrimary,
            Color.lerp(_currentPrimary, Colors.black, 0.35)!,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        boxShadow: [
          BoxShadow(
            color: _currentPrimary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ط£ظٹظ‚ظˆظ†ط© ط§ظ„ظ„ظˆظ†
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: (w * 0.14).clamp(48.0, 62.0),
                height: (w * 0.14).clamp(48.0, 62.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) =>
                      RotationTransition(turns: anim, child: child),
                  child: Icon(
                    _colorIcons[iconIndex],
                    key: ValueKey('preview_$_selectedColor'),
                    color: Colors.white,
                    size: (w * 0.07).clamp(24.0, 32.0),
                  ),
                ),
              ),

              SizedBox(width: (w * 0.04).clamp(12.0, 18.0)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اللون الحالي',
                      style: GoogleFonts.cairo(
                        fontSize: (w * 0.03).clamp(10.0, 13.0),
                        color: Colors.white70,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        widget.colorNames[_selectedColor],
                        key: ValueKey('name_$_selectedColor'),
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.05).clamp(17.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: (w * 0.04).clamp(12.0, 20.0)),

          // طµظپ ط§ظ„ظ…ط¹ط§ظٹظ†ط©
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (w * 0.04).clamp(12.0, 18.0),
                  vertical: (w * 0.03).clamp(10.0, 14.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _previewElement('الأزرار', Icons.touch_app_rounded, w),
                    _previewElement('البطاقات', Icons.credit_card_rounded, w),
                    _previewElement('الأيقونات', Icons.star_rounded, w),
                    _previewElement('الشريط', Icons.linear_scale_rounded, w),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: (w * 0.03).clamp(10.0, 16.0)),

          // ط´ط±ظٹط· ط£ظ„ظˆط§ظ† ظ…طµط؛ط±
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.appColors.length,
                  (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: i == _selectedColor ? 20 : 8,
                height: 5,
                decoration: BoxDecoration(
                  color: i == _selectedColor
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewElement(String label, IconData icon, double w) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: (w * 0.055).clamp(18.0, 24.0)),
        SizedBox(height: (w * 0.01).clamp(3.0, 6.0)),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: Colors.white70,
            fontSize: (w * 0.025).clamp(8.5, 11.0),
          ),
        ),
      ],
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط¨ط·ط§ظ‚ط© ط§ظ„ظ…ط¸ظ‡ط± (ط¯ط§ظƒظ†/ظپط§طھط­) - ط¨ط¯ظˆظ† طھط؛ظٹظٹط± ظƒط¨ظٹط±
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildThemeCard(double w, Color textColor) {
    return _Card(
      isDark: _isDark,
      borderColor: _currentPrimary,
      w: w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeToggle(w, textColor),
          _buildDivider(),
          _buildThemePreview(w, textColor),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(double w, Color textColor) {
    final iconSize = (w * 0.06).clamp(20.0, 28.0);
    final titleSize = (w * 0.038).clamp(13.0, 16.0);
    final subSize = (w * 0.028).clamp(10.0, 12.5);

    return Padding(
      padding: EdgeInsets.all((w * 0.04).clamp(12.0, 20.0)),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: (w * 0.12).clamp(42.0, 54.0),
            height: (w * 0.12).clamp(42.0, 54.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isDark
                    ? [const Color(0xFF1A2744), const Color(0xFF0D1420)]
                    : [const Color(0xFFFFF8E7), const Color(0xFFFFE082)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : _accent.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  (_isDark ? Colors.blue : _accent).withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Icon(
                key: ValueKey(_isDark),
                _isDark
                    ? Icons.nights_stay_rounded
                    : Icons.wb_sunny_rounded,
                color: _isDark ? Colors.white : _accent,
                size: iconSize,
              ),
            ),
          ),
          SizedBox(width: (w * 0.04).clamp(12.0, 18.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    key: ValueKey(_isDark),
                    _isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                    style: GoogleFonts.cairo(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  _isDark
                      ? 'مريح للعيون في الإضاءة المنخفضة'
                      : 'مناسب للإضاءة العالية',
                  style: GoogleFonts.cairo(
                    fontSize: subSize,
                    color: textColor.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: (w * 0.03).clamp(8.0, 14.0)),
          _buildSwitch(_isDark, _toggleTheme),
        ],
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value
              ? _currentPrimary
              : (_isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.25)),
          boxShadow: value
              ? [
            BoxShadow(
              color: _currentPrimary.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
              : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment:
          value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              value
                  ? Icons.nights_stay_rounded
                  : Icons.wb_sunny_rounded,
              size: 13,
              color: value ? _currentPrimary : Colors.orange.shade300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreview(double w, Color textColor) {
    final previewSize = (w * 0.03).clamp(10.0, 13.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        (w * 0.04).clamp(12.0, 20.0),
        0,
        (w * 0.04).clamp(12.0, 20.0),
        (w * 0.04).clamp(12.0, 20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'معاينة الوضع الحالي',
            style: GoogleFonts.cairo(
              fontSize: previewSize,
              color: textColor.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: (w * 0.025).clamp(8.0, 14.0)),
          Row(
            children: [
              _buildThemePreviewBox(
                isDark: true,
                isActive: _isDark,
                label: 'داكن',
                w: w,
                onTap: () => _toggleTheme(true),
              ),
              SizedBox(width: (w * 0.03).clamp(8.0, 14.0)),
              _buildThemePreviewBox(
                isDark: false,
                isActive: !_isDark,
                label: 'فاتح',
                w: w,
                onTap: () => _toggleTheme(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreviewBox({
    required bool isDark,
    required bool isActive,
    required String label,
    required double w,
    required VoidCallback onTap,
  }) {
    final boxH = (w * 0.22).clamp(70.0, 100.0);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: boxH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark ? const Color(0xFF0A0E17) : const Color(0xFFF0F4FF),
            border: Border.all(
              color: isActive ? _currentPrimary : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: _currentPrimary.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: boxH * 0.35,
                        color: isDark
                            ? const Color(0xFF151B26)
                            : Colors.white,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: boxH * 0.15,
                                height: boxH * 0.15,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPrimary.withValues(alpha: 0.3),
                                ),
                              ),
                              SizedBox(width: boxH * 0.06),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: boxH * 0.4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.4)
                                          : Colors.black.withValues(alpha: 0.2),
                                      borderRadius:
                                      BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    width: boxH * 0.25,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.black.withValues(alpha: 0.1),
                                      borderRadius:
                                      BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: isDark
                              ? const Color(0xFF0A0E17)
                              : const Color(0xFFF0F4FF),
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            children: List.generate(
                              2,
                                  (_) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: _currentPrimary.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 13),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط¨ط·ط§ظ‚ط© ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„طھط·ط¨ظٹظ‚
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildAppInfoCard(double w, Color textColor) {
    final items = [
      (
      icon: Icons.mosque_rounded,
      color: _currentPrimary,
      title: 'طريق الإسلام',
      sub: 'رفيقك في العبادة اليومية',
      ),
      (
      icon: Icons.verified_rounded,
      color: const Color(0xFF2ECC71),
      title: 'الإصدار 1.0.0',
      sub: 'آخر تحديث: 2025',
      ),
      (
      icon: Icons.language_rounded,
      color: const Color(0xFF3498DB),
      title: 'اللغة',
      sub: 'العربية',
      ),
    ];

    return _Card(
      isDark: _isDark,
      borderColor: _currentPrimary,
      w: w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow(
                icon: item.icon,
                color: item.color,
                title: item.title,
                sub: item.sub,
                w: w,
                textColor: textColor,
              ),
              if (i < items.length - 1) _buildDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط¨ط·ط§ظ‚ط© ط§ظ„طھظˆط§طµظ„
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildContactCard(double w, Color textColor) {
    final items = [
      (
      icon: Icons.star_rounded,
      color: const Color(0xFFFFB800),
      title: 'قيّم التطبيق',
      sub: 'ساعدنا في التحسين',
      onTap: () {},
      showArrow: true,
      ),
      (
      icon: Icons.share_rounded,
      color: const Color(0xFF2ECC71),
      title: 'شارك التطبيق',
      sub: 'انشر الخير مع أحبائك',
      onTap: () {
        Share.share('طريق الإسلام - رفيقك في العبادة اليومية');
      },
      showArrow: true,
      ),
      (
      icon: Icons.bug_report_rounded,
      color: const Color(0xFFE74C3C),
      title: 'الإبلاغ عن مشكلة',
      sub: 'ساعدنا في إصلاح الأخطاء',
      onTap: () {},
      showArrow: true,
      ),
    ];

    return _Card(
      isDark: _isDark,
      borderColor: _currentPrimary,
      w: w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionRow(
                icon: item.icon,
                color: item.color,
                title: item.title,
                sub: item.sub,
                onTap: item.onTap,
                showArrow: item.showArrow,
                w: w,
                textColor: textColor,
              ),
              if (i < items.length - 1) _buildDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  //  ط¨ط·ط§ظ‚ط© ط­ظˆظ„ ط§ظ„طھط·ط¨ظٹظ‚
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  Widget _buildAboutCard(double w, Color textColor) {
    final subSize = (w * 0.032).clamp(11.0, 14.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      width: double.infinity,
      padding: EdgeInsets.all((w * 0.05).clamp(16.0, 24.0)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _currentPrimary.withValues(alpha: _isDark ? 0.15 : 0.08),
            _currentPrimary.withValues(alpha: _isDark ? 0.05 : 0.03),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius:
        BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        border: Border.all(color: _currentPrimary.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: (w * 0.18).clamp(60.0, 80.0),
            height: (w * 0.18).clamp(60.0, 80.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _currentPrimary.withValues(alpha: 0.2),
                _currentPrimary.withValues(alpha: 0.05),
              ]),
              border: Border.all(
                  color: _currentPrimary.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _currentPrimary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.mosque_rounded,
              color: _currentPrimary,
              size: (w * 0.09).clamp(28.0, 40.0),
            ),
          ),
          SizedBox(height: (w * 0.03).clamp(10.0, 16.0)),
          Text(
            'طريق الإسلام',
            style: GoogleFonts.amiri(
              fontSize: (w * 0.055).clamp(18.0, 26.0),
              fontWeight: FontWeight.bold,
              color: _currentPrimary,
            ),
          ),
          SizedBox(height: (w * 0.015).clamp(5.0, 10.0)),
          Text(
            'رفيقك في العبادة اليومية',
            style: GoogleFonts.cairo(
              fontSize: subSize,
              color: textColor.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: (w * 0.02).clamp(8.0, 14.0)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: EdgeInsets.symmetric(
              horizontal: (w * 0.04).clamp(12.0, 20.0),
              vertical: (w * 0.025).clamp(8.0, 14.0),
            ),
            decoration: BoxDecoration(
              color: _currentPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _currentPrimary.withValues(alpha: 0.2)),
            ),
            child: Text(
              '﴿ وَاذْكُرُوا اللَّهَ كَثِيرًا لَعَلَّكُمْ تُفْلِحُونَ ﴾',
              style: GoogleFonts.amiri(
                fontSize: (w * 0.038).clamp(13.0, 17.0),
                color: _currentPrimary.withValues(alpha: 0.85),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: (w * 0.025).clamp(8.0, 14.0)),
          Text(
            'جميع الحقوق محفوظة © 2025',
            style: GoogleFonts.cairo(
              fontSize: (w * 0.028).clamp(9.5, 12.0),
              color: textColor.withValues(alpha: 0.35),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // â”€â”€ طµظپ ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ â”€â”€
  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String title,
    required String sub,
    required double w,
    required Color textColor,
  }) {
    final iconBoxSize = (w * 0.1).clamp(34.0, 44.0);
    final titleSize = (w * 0.036).clamp(12.0, 15.0);
    final subSize = (w * 0.028).clamp(10.0, 12.5);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (w * 0.04).clamp(12.0, 20.0),
        vertical: (w * 0.035).clamp(10.0, 16.0),
      ),
      child: Row(
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon,
                color: color, size: (w * 0.048).clamp(16.0, 22.0)),
          ),
          SizedBox(width: (w * 0.035).clamp(10.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: GoogleFonts.cairo(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(sub,
                    style: GoogleFonts.cairo(
                      fontSize: subSize,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ طµظپ ط§ظ„ط¥ط¬ط±ط§ط، â”€â”€
  Widget _buildActionRow({
    required IconData icon,
    required Color color,
    required String title,
    required String sub,
    required VoidCallback onTap,
    required bool showArrow,
    required double w,
    required Color textColor,
  }) {
    final iconBoxSize = (w * 0.1).clamp(34.0, 44.0);
    final titleSize = (w * 0.036).clamp(12.0, 15.0);
    final subSize = (w * 0.028).clamp(10.0, 12.5);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (w * 0.04).clamp(12.0, 20.0),
          vertical: (w * 0.035).clamp(10.0, 16.0),
        ),
        child: Row(
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Icon(icon,
                  color: color, size: (w * 0.048).clamp(16.0, 22.0)),
            ),
            SizedBox(width: (w * 0.035).clamp(10.0, 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: GoogleFonts.cairo(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(sub,
                      style: GoogleFonts.cairo(
                        fontSize: subSize,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: (w * 0.035).clamp(12.0, 16.0),
                color: textColor.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: _isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.05),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  ط¨ط·ط§ظ‚ط© ط¹ط§ظ…ط© - ظ…ط­ط¯ظ‘ط«ط© ظ„طھط¯ط¹ظ… borderColor ط¯ظٹظ†ط§ظ…ظٹظƒظٹ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _Card extends StatelessWidget {
  final bool isDark;
  final Color borderColor;
  final double w;
  final Widget child;

  const _Card({
    required this.isDark,
    required this.borderColor,
    required this.w,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF151B26)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius:
        BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : borderColor.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        child: child,
      ),
    );
  }
}

// â”€â”€ Share ط¨ط³ظٹط· â”€â”€
class Share {
  static void share(String text) {
    // ط§ط³طھط®ط¯ظ… share_plus ظپظٹ ظ…ط´ط±ظˆط¹ظƒ ط§ظ„ظپط¹ظ„ظٹ
  }
}