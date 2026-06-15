import 'package:flutter/material.dart';
import '../../../languages/app_localizations.dart';
import '../../../models/inheritance_models.dart';

class HeirsSelectionWidget extends StatefulWidget {
  final List<SelectedHeir> availableHeirs;
  final int selectedCount;
  final bool isDarkMode;
  final Color primaryColor;
  final VoidCallback onHeirsChanged;

  const HeirsSelectionWidget({
    Key? key,
    required this.availableHeirs,
    required this.selectedCount,
    required this.isDarkMode,
    required this.primaryColor,
    required this.onHeirsChanged,
  }) : super(key: key);

  @override
  State<HeirsSelectionWidget> createState() => _HeirsSelectionWidgetState();
}

class _HeirsSelectionWidgetState extends State<HeirsSelectionWidget> {
  bool _isExpanded = false;

  bool _canHaveMultiple(HeirType type) {
    return ![
      HeirType.husband,
      HeirType.mother,
      HeirType.father,
      HeirType.grandmother,
      HeirType.grandfather,
    ].contains(type);
  }

  Map<String, List<int>> _categorizeHeirs(BuildContext context) {
    Map<String, List<int>> categories = {
      context.tr.spouseCategory: [],
      context.tr.parentsCategory: [],
      context.tr.childrenCategory: [],
      context.tr.siblingsCategory: [],
      context.tr.otherRelativesCategory: [],
    };

    for (int i = 0; i < widget.availableHeirs.length; i++) {
      var h = widget.availableHeirs[i];
      if (h.type == HeirType.husband || h.type == HeirType.wife) {
        categories[context.tr.spouseCategory]!.add(i);
      } else if ([HeirType.father, HeirType.mother, HeirType.grandfather, HeirType.grandmother].contains(h.type)) {
        categories[context.tr.parentsCategory]!.add(i);
      } else if ([HeirType.son, HeirType.daughter, HeirType.sonOfSon, HeirType.sonsDaughter].contains(h.type)) {
        categories[context.tr.childrenCategory]!.add(i);
      } else if ([HeirType.brother, HeirType.sister, HeirType.halfBrotherFather, HeirType.halfSisterFather, HeirType.halfBrotherMother, HeirType.halfSisterMother].contains(h.type)) {
        categories[context.tr.siblingsCategory]!.add(i);
      } else {
        categories[context.tr.otherRelativesCategory]!.add(i);
      }
    }
    return categories;
  }

  String _getHeirName(BuildContext context, HeirType type) {
    switch (type) {
      case HeirType.husband:
        return context.tr.husband;
      case HeirType.wife:
        return context.tr.wife;
      case HeirType.mother:
        return context.tr.mother;
      case HeirType.father:
        return context.tr.father;
      case HeirType.grandmother:
        return context.tr.grandmother;
      case HeirType.grandfather:
        return context.tr.grandfather;
      case HeirType.son:
        return context.tr.son;
      case HeirType.daughter:
        return context.tr.daughter;
      case HeirType.sonOfSon:
        return context.tr.sonOfSon;
      case HeirType.sonsDaughter:
        return context.tr.sonsDaughter;
      case HeirType.brother:
        return context.tr.brother;
      case HeirType.sister:
        return context.tr.sister;
      case HeirType.halfBrotherFather:
        return context.tr.halfBrotherFather;
      case HeirType.halfSisterFather:
        return context.tr.halfSisterFather;
      case HeirType.halfBrotherMother:
        return context.tr.halfBrotherMother;
      case HeirType.halfSisterMother:
        return context.tr.halfSisterMother;
      case HeirType.sonOfBrother:
        return context.tr.sonOfBrother;
      case HeirType.sonOfHalfBrotherFather:
        return context.tr.sonOfHalfBrotherFather;
      case HeirType.uncle:
        return context.tr.uncle;
      case HeirType.halfUncleFather:
        return context.tr.halfUncleFather;
      case HeirType.sonOfUncle:
        return context.tr.sonOfUncle;
      case HeirType.sonOfHalfUncleFather:
        return context.tr.sonOfHalfUncleFather;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDarkMode ? const Color(0xFF151B26) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final borderColor = widget.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15);
    final categories = _categorizeHeirs(context);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: widget.isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.primaryColor.withValues(alpha: widget.isDarkMode ? 0.15 : 0.08),
                    widget.primaryColor.withValues(alpha: widget.isDarkMode ? 0.08 : 0.03),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: _isExpanded ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.primaryColor, widget.primaryColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              context.tr.selectHeirs,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (widget.selectedCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [widget.primaryColor, widget.primaryColor.withValues(alpha: 0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.selectedCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (widget.selectedCount > 0)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: widget.availableHeirs
                                  .where((h) => h.isSelected)
                                  .map((h) => Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: widget.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: widget.primaryColor.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  '${_getHeirName(context, h.type)}${h.count > 1 ? " (${h.count})" : ""}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: widget.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          )
                        else
                          Text(
                            context.tr.clickToSelectHeirs,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: categories.entries
                    .where((e) => e.value.isNotEmpty)
                    .map((entry) => _buildHeirCategory(context, entry.key, entry.value, textColor))
                    .toList(),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildHeirCategory(BuildContext context, String title, List<int> indices, Color textColor) {
    final categoryColors = {
      context.tr.spouseCategory: const Color(0xFFAD1457),
      context.tr.parentsCategory: const Color(0xFF1565C0),
      context.tr.childrenCategory: const Color(0xFF2E7D32),
      context.tr.siblingsCategory: const Color(0xFF6A1B9A),
      context.tr.otherRelativesCategory: const Color(0xFF795548),
    };
    final color = categoryColors[title] ?? widget.primaryColor;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: widget.isDarkMode ? 0.2 : 0.1),
                  color.withValues(alpha: widget.isDarkMode ? 0.1 : 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '${indices.where((i) => widget.availableHeirs[i].isSelected).length}/${indices.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...indices.map((i) => _buildHeirTile(context, widget.availableHeirs[i], color)),
        ],
      ),
    );
  }

  Widget _buildHeirTile(BuildContext context, SelectedHeir heir, Color categoryColor) {
    final textColor = widget.isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    bool canMulti = _canHaveMultiple(heir.type);
    final heirName = _getHeirName(context, heir.type);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: heir.isSelected
            ? widget.primaryColor.withValues(alpha: widget.isDarkMode ? 0.12 : 0.06)
            : (widget.isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: heir.isSelected
              ? widget.primaryColor.withValues(alpha: 0.4)
              : (widget.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
          width: heir.isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            heir.isSelected = !heir.isSelected;
            if (!heir.isSelected) heir.count = 1;
          });
          widget.onHeirsChanged();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: heir.isSelected
                      ? LinearGradient(
                    colors: [widget.primaryColor, widget.primaryColor.withValues(alpha: 0.8)],
                  )
                      : null,
                  color: heir.isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: heir.isSelected ? widget.primaryColor : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: heir.isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Text(
                  heirName,
                  style: TextStyle(
                    fontWeight: heir.isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                    color: heir.isSelected ? widget.primaryColor : textColor,
                  ),
                ),
              ),

              // Counter
              if (heir.isSelected && canMulti)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCounterButton(
                      icon: Icons.remove,
                      color: Colors.red,
                      enabled: heir.count > 1,
                      onTap: () {
                        if (heir.count > 1) {
                          setState(() => heir.count--);
                          widget.onHeirsChanged();
                        }
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.primaryColor, widget.primaryColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${heir.count}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _buildCounterButton(
                      icon: Icons.add,
                      color: widget.primaryColor,
                      enabled: true,
                      onTap: () {
                        setState(() => heir.count++);
                        widget.onHeirsChanged();
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? color.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? color : Colors.grey.shade400,
        ),
      ),
    );
  }
}