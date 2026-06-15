import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'theme/azkar_theme.dart';
import 'widgets/azkar_loading_widget.dart';
import 'widgets/azkar_header_widget.dart';
import 'widgets/azkar_category_card.dart';
import 'azkar_detail_screen.dart';
import 'animations/azkar_animations.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// شاشة الأذكار الرئيسية
/// ═══════════════════════════════════════════════════════════════════════════
class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> azkarCategories = [];
  bool _loading = true;
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutBack,
    );
    _loadAzkar();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadAzkar() async {
    try {
      final jsonString = await rootBundle.loadString('assets/azkar/azkar.json');
      final List<dynamic> data = json.decode(jsonString);
      setState(() {
        azkarCategories = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
      _headerAnimController.forward();
    } catch (e) {
      debugPrint('azkar load error: $e');
      setState(() => _loading = false);
    }
  }

  void _navigateToDetail(Map<String, dynamic> category, List<dynamic> azkarList) {
    Navigator.push(
      context,
      AzkarPageRoute(
        page: AzkarDetailScreen(
          title: category['title'] as String,
          azkar: azkarList.map((e) => Map<String, dynamic>.from(e)).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AzkarTheme.getBackgroundColor(isDark);

    if (_loading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: const AzkarLoadingWidget(),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            AzkarSliverHeader(
              isDark: isDark,
              innerBoxIsScrolled: innerBoxIsScrolled,
              headerAnimation: _headerAnim,
              categoriesCount: azkarCategories.length,
            ),
          ],
          body: _buildCategoriesList(isDark),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(bool isDark) {
    final size = MediaQuery.of(context).size;
    final sizes = AzkarSizes(size);

    return ListView.builder(
      padding: EdgeInsets.only(
        right: sizes.basePadding,
        left: sizes.basePadding,
        top: sizes.basePadding * 0.7,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: azkarCategories.length,
      itemBuilder: (context, index) {
        final category = azkarCategories[index];
        final List<dynamic> azkarList = category['azkar'] as List<dynamic>;

        return AzkarCategoryCard(
          category: category,
          azkarList: azkarList,
          index: index,
          isDark: isDark,
          onTap: () => _navigateToDetail(category, azkarList),
        );
      },
    );
  }
}