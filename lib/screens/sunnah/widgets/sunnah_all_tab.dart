import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/sunnah_model.dart';
import '../services/sunnah_service.dart';
import 'sunnah_theme.dart';
import 'sunnah_card.dart';

class SunnahAllTab extends StatelessWidget {
  final Size size;
  final SunnahTheme theme;
  final SunnahService service;
  final int selectedFilterIndex;
  final List<String> filters;
  final AnimationController pulseController;
  final Animation<double> pulseAnim;
  final Future<void> Function() onRefresh;
  final Function(int) onFilterChanged;
  final Function(SunnahModel) onShowDetails;
  final Function(int) onToggle;

  const SunnahAllTab({
    super.key,
    required this.size,
    required this.theme,
    required this.service,
    required this.selectedFilterIndex,
    required this.filters,
    required this.pulseController,
    required this.pulseAnim,
    required this.onRefresh,
    required this.onFilterChanged,
    required this.onShowDetails,
    required this.onToggle,
  });

  static const List<String> _categoryOrder = [
    'fajr', 'morning_adhkar', 'duha', 'dhuhr', 'asr',
    'evening_adhkar', 'maghrib', 'isha', 'witr', 'tahajjud',
    'sleep', 'always', 'weekly_fast', 'monthly_fast',
    'friday', 'yearly_fast', 'yearly_prayer',
  ];

  List<SunnahModel> _applyFilter(List<SunnahModel> sunnahs) {
    switch (selectedFilterIndex) {
      case 1:
        return sunnahs.where((s) => s.importance == 'مؤكدة').toList();
      case 2:
        return sunnahs.where((s) => s.importance == 'مستحبة').toList();
      case 3:
        return sunnahs.where((s) => !s.isCompleted).toList();
      default:
        return sunnahs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSunnahs = service.getAllSunnahs();
    final Map<String, List<SunnahModel>> grouped = {};
    for (var s in allSunnahs) {
      grouped.putIfAbsent(s.timeCategory, () => []).add(s);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: SunnahTheme.emerald,
      backgroundColor: theme.card,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          size.width * 0.04,
          size.height * 0.015,
          size.width * 0.04,
          size.height * 0.04,
        ),
        children: [
          _buildOverallStats(),
          SizedBox(height: size.height * 0.015),
          _buildFilterChips(allSunnahs),
          SizedBox(height: size.height * 0.015),
          ..._categoryOrder
              .where((cat) => grouped.containsKey(cat))
              .expand((category) {
            final items = _applyFilter(grouped[category]!);
            if (items.isEmpty) return <Widget>[];
            return [
              _buildCategoryHeader(category, grouped[category]!),
              SizedBox(height: size.height * 0.008),
              ...items.asMap().entries.map(
                    (e) => SunnahCard(
                  sunnah: e.value,
                  index: e.key,
                  size: size,
                  theme: theme,
                  service: service,
                  onToggle: () => onToggle(e.value.id),
                  onTap: () => onShowDetails(e.value),
                ),
              ),
              SizedBox(height: size.height * 0.01),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    final percentage = service.completionPercentage;
    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: theme.overallStatsGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: SunnahTheme.emerald.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: size.width * 0.22,
            height: size.width * 0.22,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.22,
                  height: size.width * 0.22,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage == 100
                          ? SunnahTheme.goldLight
                          : SunnahTheme.emeraldLight,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toInt()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: size.width * 0.025,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [SunnahTheme.emeraldLight, SunnahTheme.goldLight],
                  ).createShader(b),
                  child: Text(
                    'إنجازك اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                _buildStatRow(
                    '✅ أكملت', '${service.completedToday}', SunnahTheme.emeraldLight),
                SizedBox(height: size.height * 0.005),
                _buildStatRow(
                    '📋 المجموع', '${service.totalSunnahs}', SunnahTheme.blueLight),
                SizedBox(height: size.height * 0.005),
                _buildStatRow('⏳ المتبقي',
                    '${service.totalSunnahs - service.completedToday}', SunnahTheme.goldLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: size.width * 0.03,
            )),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.025, vertical: 3,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(value,
              style: TextStyle(
                color: color,
                fontSize: size.width * 0.033,
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    );
  }

  Widget _buildFilterChips(List<SunnahModel> allSunnahs) {
    final counts = [
      allSunnahs.length,
      allSunnahs.where((s) => s.importance == 'مؤكدة').length,
      allSunnahs.where((s) => s.importance == 'مستحبة').length,
      allSunnahs.where((s) => !s.isCompleted).length,
    ];

    return SizedBox(
      height: size.height * 0.045,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: size.width * 0.02),
        itemBuilder: (context, i) {
          final selected = selectedFilterIndex == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onFilterChanged(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.035, vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SunnahTheme.chipRadius),
                gradient: selected ? SunnahTheme.emeraldGradient : null,
                color: selected ? null : theme.card,
                border: Border.all(
                  color: selected ? Colors.transparent : theme.divider,
                  width: 1,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: SunnahTheme.emerald.withValues(alpha: 0.35), blurRadius: 8)]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filters[i],
                      style: TextStyle(
                        color: selected ? Colors.white : theme.textSecondary,
                        fontSize: size.width * 0.03,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      )),
                  SizedBox(width: size.width * 0.015),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white.withValues(alpha: 0.2) : theme.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${counts[i]}',
                        style: TextStyle(
                          color: selected ? Colors.white : theme.textSecondary,
                          fontSize: size.width * 0.026,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(String category, List<SunnahModel> sunnahs) {
    final label = service.getCategoryLabel(category);
    final isNow = service.getCurrentSunnahs().any((s) => s.timeCategory == category);
    final completed = sunnahs.where((s) => s.isCompleted).length;
    final total = sunnahs.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isNow
            ? LinearGradient(colors: [
          SunnahTheme.emerald.withValues(alpha: theme.isDark ? 0.18 : 0.12),
          SunnahTheme.emerald.withValues(alpha: 0.03),
        ])
            : null,
        color: isNow ? null : theme.card,
        border: Border.all(
          color: isNow ? SunnahTheme.emerald.withValues(alpha: 0.35) : theme.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(SunnahTheme.categoryIcons[category] ?? '📿',
              style: TextStyle(fontSize: size.width * 0.048)),
          SizedBox(width: size.width * 0.025),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  color: isNow ? SunnahTheme.emeraldLight : theme.textPrimary,
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.bold,
                )),
          ),
          if (isNow)
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, __) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.022, vertical: 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [SunnahTheme.gold, SunnahTheme.goldLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SunnahTheme.gold.withValues(alpha: 0.25 * pulseAnim.value),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text('● الآن',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          SizedBox(width: size.width * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$completed/$total',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: size.width * 0.028,
                  )),
              const SizedBox(height: 3),
              SizedBox(
                width: size.width * 0.1,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    backgroundColor: theme.isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isNow ? SunnahTheme.emerald : theme.textSecondary,
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