import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../languages/app_localizations.dart';
import '../../more/data/iqama_catalog.dart';
import 'prayer_models.dart';

class PrayerCustomizeSheet extends StatefulWidget {
  final PrayerRow row;
  final PrayerCustomization initialConfig;
  final String currentMuezzinName;
  final Color gold;
  final Future<String?> Function() onChangeMuezzin;
  final Future<void> Function(String soundName) onPreviewReminder;
  final Future<void> Function(String soundId) onPreviewIqama;
  final Future<void> Function(PrayerCustomization config) onSave;
  final Future<void> Function() onResetDefault;

  const PrayerCustomizeSheet({
    super.key,
    required this.row,
    required this.initialConfig,
    required this.currentMuezzinName,
    required this.gold,
    required this.onChangeMuezzin,
    required this.onPreviewReminder,
    required this.onPreviewIqama,
    required this.onSave,
    required this.onResetDefault,
  });

  @override
  State<PrayerCustomizeSheet> createState() => _PrayerCustomizeSheetState();
}

class _PrayerCustomizeSheetState extends State<PrayerCustomizeSheet> {
  late PrayerCustomization config;
  late String _muezzinName;

  @override
  void initState() {
    super.initState();
    config = widget.initialConfig;
    _muezzinName = widget.currentMuezzinName;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenH = MediaQuery.of(context).size.height;

    final bg = isDark ? const Color(0xFF0D1117) : Colors.white;
    final cardBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.92),
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: widget.gold.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(row: widget.row, gold: widget.gold,
                textColor: textColor, subColor: subColor, divColor: divColor),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    // â”€â”€ ط§ظ„ظ…ط¤ط°ظ† â”€â”€
                    _SectionCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      divColor: divColor,
                      icon: Icons.record_voice_over_rounded,
                      iconColor: widget.gold,
                      label: context.tr.currentMuezzinSettingsTitle,
                      child: _MuezzinRow(
                        name: _muezzinName,
                        gold: widget.gold,
                        textColor: textColor,
                        subColor: subColor,
                        changeLabel: context.tr.changeMuezzin,
                        onTap: () async {
                          final newName = await widget.onChangeMuezzin();
                          if (newName != null && mounted) {
                            setState(() => _muezzinName = newName);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // â”€â”€ ط§ظ„ط£ط°ط§ظ† â”€â”€
                    _SectionCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      divColor: divColor,
                      icon: Icons.mosque_rounded,
                      iconColor: widget.gold,
                      label: context.tr.adhanSettingsTitle,
                      child: _ToggleRow(
                        label: context.tr.enableAdhanForThisPrayer,
                        value: config.adhanEnabled,
                        activeColor: widget.gold,
                        textColor: textColor,
                        subColor: subColor,
                        onChanged: (v) =>
                            setState(() => config = config.copyWith(adhanEnabled: v)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // â”€â”€ ط§ظ„طھظ†ط¨ظٹظ‡ â”€â”€
                    _SectionCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      divColor: divColor,
                      icon: Icons.notifications_active_rounded,
                      iconColor: Colors.blue,
                      label: context.tr.reminderMinutesAmount,
                      child: Column(
                        children: [
                          _DropRow<int>(
                            label: context.tr.minutesBefore,
                            isDark: isDark,
                            gold: widget.gold,
                            bg: bg,
                            textColor: textColor,
                            subColor: subColor,
                            value: config.reminderEnabled
                                ? config.reminderOffset
                                : 0,
                            items: {
                              0: context.tr.disablePreReminder,
                              5: context.tr.xMinutes(5),
                              10: context.tr.xMinutes(10),
                              15: context.tr.xMinutes(15),
                              20: context.tr.xMinutes(20),
                            },
                            onChanged: (v) async {
                              setState(() => config = config.copyWith(
                                reminderEnabled: v > 0,
                                reminderOffset: v == 0 ? 10 : v,
                              ));
                              if (v > 0) {
                                await widget
                                    .onPreviewReminder(config.reminderSound);
                              }
                            },
                          ),
                          if (config.reminderEnabled) ...[
                            const SizedBox(height: 10),
                            _DropRow<String>(
                              label: context.tr.preReminderSound,
                              isDark: isDark,
                              gold: widget.gold,
                              bg: bg,
                              textColor: textColor,
                              subColor: subColor,
                              value: ['hayalaaslah', 'prayfajr']
                                  .contains(config.reminderSound)
                                  ? config.reminderSound
                                  : 'hayalaaslah',
                              items: {
                                'hayalaaslah':
                                context.tr.soundHayyaAlasalah,
                                'prayfajr': context.tr.soundPrayFajr,
                              },
                              onChanged: (v) async {
                                setState(() => config =
                                    config.copyWith(reminderSound: v));
                                await widget.onPreviewReminder(v);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // â”€â”€ ط§ظ„ط¥ظ‚ط§ظ…ط© â”€â”€
                    _SectionCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      divColor: divColor,
                      icon: Icons.timer_rounded,
                      iconColor: Colors.purple,
                      label: context.tr.iqamaLabel,
                      child: Column(
                        children: [
                          _DropRow<int>(
                            label: context.tr.iqamaTimeAfterAdhan,
                            isDark: isDark,
                            gold: widget.gold,
                            bg: bg,
                            textColor: textColor,
                            subColor: subColor,
                            value:
                            config.iqamaEnabled ? config.iqamaDelay : 0,
                            items: {
                              0: context.tr.disableIqama,
                              5: context.tr.xMinutesAfterAdhan(5),
                              10: context.tr.xMinutesAfterAdhan(10),
                              15: context.tr.xMinutesAfterAdhan(15),
                              20: context.tr.xMinutesAfterAdhan(20),
                              25: context.tr.xMinutesAfterAdhan(25),
                              30: context.tr.xMinutesAfterAdhan(30),
                            },
                            onChanged: (v) async {
                              setState(() => config = config.copyWith(
                                iqamaEnabled: v > 0,
                                iqamaDelay: v == 0 ? 10 : v,
                              ));
                              if (v > 0) {
                                await widget.onPreviewIqama(config.iqamaSound);
                              }
                            },
                          ),
                          if (config.iqamaEnabled) ...[
                            const SizedBox(height: 10),
                            _DropRow<String>(
                              label: context.tr.iqamaSound,
                              isDark: isDark,
                              gold: widget.gold,
                              bg: bg,
                              textColor: textColor,
                              subColor: subColor,
                              value: iqamaCatalog
                                  .any((s) => s.id == config.iqamaSound)
                                  ? config.iqamaSound
                                  : iqamaCatalog.first.id,
                              items: {
                                for (final s in iqamaCatalog) s.id: s.name
                              },
                              onChanged: (v) async {
                                setState(() =>
                                config = config.copyWith(iqamaSound: v));
                                await widget.onPreviewIqama(v);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _Buttons(
                      gold: widget.gold,
                      resetLabel: context.tr.resetToDefault,
                      saveLabel: context.tr.saveCustomization,
                      onReset: () async {
                        await widget.onResetDefault();
                        setState(() => config = PrayerCustomization.defaults());
                      },
                      onSave: () => widget.onSave(config),
                    ),
                    const SizedBox(height: 4),
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

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… ط§ظ„ظ‡ظٹط¯ط±
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _Header extends StatelessWidget {
  final PrayerRow row;
  final Color gold;
  final Color textColor;
  final Color subColor;
  final Color divColor;

  const _Header({
    required this.row,
    required this.gold,
    required this.textColor,
    required this.subColor,
    required this.divColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ط´ط±ظٹط· ط§ظ„ط³ط­ط¨
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // ط£ظٹظ‚ظˆظ†ط© ط§ظ„طµظ„ط§ط©
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gold.withValues(alpha: 0.25),
                      gold.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: gold.withValues(alpha: 0.25)),
                ),
                child: Icon(row.icon, color: gold, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.name,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 13, color: gold.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          row.time,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: subColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ط´ط§ط±ط© ط§ظ„طھط®طµظٹطµ
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: gold.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'تخصيص',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: gold,
                    fontWeight: FontWeight.bold,
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

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… ط¨ط·ط§ظ‚ط© ط§ظ„ظ‚ط³ظ…
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _SectionCard extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color divColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  const _SectionCard({
    required this.isDark,
    required this.cardBg,
    required this.divColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ط¹ظ†ظˆط§ظ† ط§ظ„ظ‚ط³ظ…
          Padding(
            padding:
            const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: divColor),
          // ط§ظ„ظ…ط­طھظˆظ‰
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… طµظپ ط§ظ„ظ…ط¤ط°ظ†
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _MuezzinRow extends StatelessWidget {
  final String name;
  final Color gold;
  final Color textColor;
  final Color subColor;
  final String changeLabel;
  final VoidCallback onTap;

  const _MuezzinRow({
    required this.name,
    required this.gold,
    required this.textColor,
    required this.subColor,
    required this.changeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // âœ… ط§ط³ظ… ط§ظ„ظ…ط¤ط°ظ† ظƒط§ظ…ظ„ط§ظ‹ ظپظٹ ط³ط·ط± ظ…ظ†ظپطµظ„
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gold.withValues(alpha: 0.3),
                    gold.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.person_rounded, color: gold, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المؤذن الحالي',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: subColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // âœ… ط§ط³ظ… ط§ظ„ظ…ط¤ط°ظ† ظƒط§ظ…ظ„ط§ظ‹ ط¨ط¯ظˆظ† overflow
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    // âœ… ظٹظƒط³ط± ط§ظ„ط³ط·ط± ط¥ط°ط§ ط§ط­طھط§ط¬
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // âœ… ط²ط± ط§ظ„طھط؛ظٹظٹط± ظپظٹ ط³ط·ط± ظ…ظ†ظپطµظ„ ط¨ط¹ط±ط¶ ظƒط§ظ…ظ„
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gold, gold.withValues(alpha: 0.85)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    changeLabel,
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… طµظپ طھط¨ط¯ظٹظ„
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final Color textColor;
  final Color subColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.textColor,
    required this.subColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: value ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    value ? 'مفعّل' : 'معطّل',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: value ? Colors.green : subColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.88,
          child: Switch(
            value: value,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… طµظپ Dropdown - ط¨ط¯ظˆظ† overflow
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _DropRow<T> extends StatelessWidget {
  final String label;
  final bool isDark;
  final Color gold;
  final Color bg;
  final Color textColor;
  final Color subColor;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  const _DropRow({
    required this.label,
    required this.isDark,
    required this.gold,
    required this.bg,
    required this.textColor,
    required this.subColor,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: subColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            dropdownColor: bg,
            borderRadius: BorderRadius.circular(14),
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: gold, size: 20),
            style: GoogleFonts.cairo(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            selectedItemBuilder: (context) => items.keys.map((k) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  items[k]!,
                  style: GoogleFonts.cairo(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            items: items.entries.map((e) {
              final isSelected = e.key == value;
              return DropdownMenuItem<T>(
                value: e.key,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 4, horizontal: 4),
                  child: Row(
                    children: [
                      if (isSelected)
                        Icon(Icons.check_rounded,
                            color: gold, size: 16)
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? gold : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
        Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.07),
        ),
      ],
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// âœ… ط§ظ„ط£ط²ط±ط§ط±
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _Buttons extends StatelessWidget {
  final Color gold;
  final String resetLabel;
  final String saveLabel;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const _Buttons({
    required this.gold,
    required this.resetLabel,
    required this.saveLabel,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ط²ط± ط¥ط¹ط§ط¯ط© ط§ظ„ط¶ط¨ط·
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.red, size: 17),
            label: Text(
              resetLabel,
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onPressed: onReset,
          ),
        ),
        const SizedBox(width: 10),
        // ط²ط± ط§ظ„ط­ظپط¸
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gold, gold.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              icon: const Icon(Icons.check_circle_rounded,
                  color: Colors.black, size: 18),
              label: Text(
                saveLabel,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              onPressed: onSave,
            ),
          ),
        ),
      ],
    );
  }
}