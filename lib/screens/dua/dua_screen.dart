import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/dua_model.dart';
import 'dua_category_screen.dart';
import 'widgets/dua_animations.dart';
import 'widgets/dua_styled_widgets.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  List<DuaCategory> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDuas();
  }

  Future<void> _loadDuas() async {
    try {
      final String response =
      await rootBundle.loadString('assets/json/duas.json');
      final data = json.decode(response);
      final List<dynamic> categoriesJson = data['categories'];

      setState(() {
        _categories =
            categoriesJson.map((c) => DuaCategory.fromJson(c)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading duas: $e');
      setState(() => _loading = false);
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'healing':
        return Icons.healing_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'local_hospital':
        return Icons.local_hospital_rounded;
      case 'today':
        return Icons.today_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  Color _getColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFFE6B325);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DuaTheme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الأدعية',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: theme.textColor,
            ),
          ),
          leading: DuaBackButton(
            isDark: theme.isDark,
            primary: theme.primary,
          ),
        ),
        body: SafeArea(
          child: _buildBody(theme),
        ),
      ),
    );
  }

  Widget _buildBody(DuaTheme theme) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: theme.primary),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Text(
          'لا توجد أدعية',
          style: GoogleFonts.cairo(color: theme.subColor),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossCount = width > 600 ? 3 : 2;
        final cardWidth = (width - 16 * 2 - 14 * (crossCount - 1)) / crossCount;
        final cardHeight = cardWidth * 1.1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: cardHeight,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final catColor = _getColor(cat.color);
            final catIcon = _getIcon(cat.icon);

            return AnimatedGridItem(
              index: index,
              child: DuaCategoryCard(
                name: cat.name,
                icon: catIcon,
                color: catColor,
                duasCount: cat.duas.length,
                isDark: theme.isDark,
                textColor: theme.textColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DuaCategoryScreen(
                        category: cat,
                        catColor: catColor,
                        catIcon: catIcon,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}