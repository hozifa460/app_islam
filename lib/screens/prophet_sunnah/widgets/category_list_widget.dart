import 'package:flutter/material.dart';
import '../Constants/sunnah_theme.dart';
import '../models/sunnah_category.dart';
import 'category_card_widget.dart';

class CategoryListWidget extends StatelessWidget {
  final List<SunnahCategory> categories;
  final bool isDark;

  const CategoryListWidget({
    super.key,
    required this.categories,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyWidget(isDark: isDark),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => CategoryCardWidget(
            category: categories[index],
            index: index,
            isDark: isDark,
          ),
          childCount: categories.length,
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final bool isDark;
  const _EmptyWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 72,
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              color: SunnahTheme.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرّب البحث بكلمة مختلفة',
            style: TextStyle(
              color: SunnahTheme.textSecondary(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}