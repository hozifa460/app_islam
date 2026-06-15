import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../languages/app_localizations.dart';
import '../../languages/locale_provider.dart';
import 'widgets/settings_theme.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_theme_card.dart';
import 'widgets/settings_color_selection.dart';
import 'widgets/settings_color_preview.dart';
import 'widgets/settings_app_info_card.dart';
import 'widgets/settings_contact_card.dart';
import 'widgets/settings_about_card.dart';
import 'widgets/settings_shared_widgets.dart';

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
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Color get _currentPrimary => widget.appColors[_selectedColor];

  void _toggleTheme(bool val) {
    HapticFeedback.lightImpact();
    setState(() => _isDark = val);
    widget.onThemeChanged(val);
  }

  void _selectColor(int index) {
    setState(() => _selectedColor = index);
    widget.onColorChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final theme =
    SettingsTheme(isDark: _isDark, currentPrimary: _currentPrimary);
    final tr = context.tr; // â†گ ط§ط³طھط®ط¯ط§ظ… ط§ظ„طھط±ط¬ظ…ط©

    // â•گâ•گâ•گ ط£ط³ظ…ط§ط، ط§ظ„ط£ظ„ظˆط§ظ† ظ…طھط±ط¬ظ…ط© â•گâ•گâ•گ
    final translatedColorNames = tr.colorNames;

    return Scaffold(
      backgroundColor: theme.bg,
      body: Stack(children: [
        _buildBackground(theme, w, size.height),
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SettingsHeader(
                    theme: theme,
                    w: w,
                    onBack: () => Navigator.pop(context),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (w * 0.045).clamp(14.0, 24.0),
                    vertical: (w * 0.03).clamp(10.0, 18.0),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // â•گâ•گâ•گ ط§ظ„ظ…ط¸ظ‡ط± â•گâ•گâ•گ
                      SettingsSectionLabel(
                        label: tr.appearance,
                        icon: Icons.palette_rounded,
                        w: w,
                        theme: theme,
                      ),
                      SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                      SettingsThemeCard(
                        theme: theme,
                        w: w,
                        isDark: _isDark,
                        onToggle: _toggleTheme,
                      ),

                      // â•گâ•گâ•گ ط§ظ„ظ„ط؛ط© â•گâ•گâ•گ
                      SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),
                      SettingsSectionLabel(
                        label: tr.language,
                        icon: Icons.language_rounded,
                        w: w,
                        theme: theme,
                      ),
                      SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                      _LanguageCard(theme: theme, w: w),

                      // â•گâ•گâ•گ ظ„ظˆظ† ط§ظ„طھط·ط¨ظٹظ‚ â•گâ•گâ•گ
                      SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),
                      SettingsSectionLabel(
                        label: tr.appColor,
                        icon: Icons.color_lens_rounded,
                        w: w,
                        theme: theme,
                      ),
                      SizedBox(height: (w * 0.015).clamp(4.0, 8.0)),
                      Padding(
                        padding: EdgeInsets.only(
                            right: (w * 0.1).clamp(32.0, 46.0)),
                        child: Text(
                          tr.appColorDesc,
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.028).clamp(10.0, 12.5),
                            color: theme.textColor.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                      SettingsColorSelection(
                        theme: theme,
                        w: w,
                        appColors: widget.appColors,
                        colorNames: translatedColorNames,
                        selectedColor: _selectedColor,
                        onSelect: _selectColor,
                      ),

                      SizedBox(height: (w * 0.03).clamp(10.0, 18.0)),
                      SettingsColorPreview(
                        theme: theme,
                        w: w,
                        appColors: widget.appColors,
                        colorNames: translatedColorNames,
                        selectedColor: _selectedColor,
                      ),

                      // â•گâ•گâ•گ ط§ظ„طھط·ط¨ظٹظ‚ â•گâ•گâ•گ
                      SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),
                      SettingsSectionLabel(
                        label: tr.theApp,
                        icon: Icons.info_outline_rounded,
                        w: w,
                        theme: theme,
                      ),
                      SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                      SettingsAppInfoCard(theme: theme, w: w),

                      // â•گâ•گâ•گ ط§ظ„طھظˆط§طµظ„ ظˆط§ظ„ط¯ط¹ظ… â•گâ•گâ•گ
                      SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),
                      SettingsSectionLabel(
                        label: tr.contactSupport,
                        icon: Icons.support_agent_rounded,
                        w: w,
                        theme: theme,
                      ),
                      SizedBox(height: (w * 0.02).clamp(6.0, 12.0)),
                      SettingsContactCard(theme: theme, w: w),

                      SizedBox(height: (w * 0.05).clamp(16.0, 28.0)),
                      SettingsAboutCard(theme: theme, w: w),

                      SizedBox(height: (w * 0.08).clamp(24.0, 48.0)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildBackground(SettingsTheme theme, double w, double h) {
    return Positioned.fill(
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: theme.bgGradient,
            ),
          ),
        ),
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
      ]),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  ظˆظٹط¯ط¬طھ ط§ط®طھظٹط§ط± ط§ظ„ظ„ط؛ط©
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _LanguageCard extends StatelessWidget {
  final dynamic theme;
  final double w;

  const _LanguageCard({required this.theme, required this.w});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final tr = context.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular((w * 0.04).clamp(12.0, 20.0)),
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // â•گâ•گâ•گ ط§ظ„ظ„ط؛ط© ط§ظ„ط­ط§ظ„ظٹط© â•گâ•گâ•گ
          Padding(
            padding: EdgeInsets.all((w * 0.04).clamp(12.0, 20.0)),
            child: Row(
              children: [
                Container(
                  width: (w * 0.1).clamp(36.0, 48.0),
                  height: (w * 0.1).clamp(36.0, 48.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.15),
                        Colors.blue.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      localeProvider.currentFlag,
                      style: TextStyle(
                        fontSize: (w * 0.055).clamp(20.0, 28.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (w * 0.03).clamp(10.0, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.language,
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.035).clamp(13.0, 16.0),
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        localeProvider.currentLangName,
                        style: GoogleFonts.cairo(
                          fontSize: (w * 0.028).clamp(10.0, 13.0),
                          color: isDark
                              ? Colors.white54
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: (w * 0.04).clamp(14.0, 18.0),
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),

          // â•گâ•گâ•گ ظ‚ط§ط¦ظ…ط© ط§ظ„ظ„ط؛ط§طھ â•گâ•گâ•گ
          Padding(
            padding: EdgeInsets.all((w * 0.025).clamp(8.0, 14.0)),
            child: Wrap(
              spacing: (w * 0.02).clamp(6.0, 10.0),
              runSpacing: (w * 0.02).clamp(6.0, 10.0),
              children: AppLocalizations.supportedLanguages.map((lang) {
                final isSelected =
                    localeProvider.locale.languageCode == lang.code;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    localeProvider.setLocale(lang.code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: (w * 0.03).clamp(10.0, 16.0),
                      vertical: (w * 0.02).clamp(6.0, 10.0),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15)
                          : isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.grey.withValues(alpha: 0.08),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: isSelected ? 1.5 : 0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang.flag,
                          style: TextStyle(
                            fontSize: (w * 0.04).clamp(16.0, 22.0),
                          ),
                        ),
                        SizedBox(width: (w * 0.015).clamp(4.0, 8.0)),
                        Text(
                          lang.nativeName,
                          style: GoogleFonts.cairo(
                            fontSize: (w * 0.03).clamp(11.0, 14.0),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : isDark
                                ? Colors.white70
                                : Colors.black87,
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: (w * 0.01).clamp(3.0, 6.0)),
                          Icon(
                            Icons.check_circle_rounded,
                            size: (w * 0.035).clamp(13.0, 17.0),
                            color:
                            Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}