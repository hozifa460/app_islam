import 'package:flutter/material.dart';
import '../models/tasbih_model.dart';
import 'tasbih_theme.dart';

class TasbihSelector extends StatelessWidget {
  final List<TasbihModel> tasbihList;
  final int selectedIndex;
  final Function(int) onSelected;

  const TasbihSelector({
    super.key,
    required this.tasbihList,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TasbihTheme.chipHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tasbihList.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: TasbihTheme.chipDecoration(isSelected),
              child: Center(
                child: Text(
                  tasbihList[index].text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TasbihTheme.chipText(isSelected),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}