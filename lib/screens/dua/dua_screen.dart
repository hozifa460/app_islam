import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/dua_model.dart';
import 'dua_category_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
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
              color: textColor,
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: SafeArea(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: primary))
              : _categories.isEmpty
              ? Center(
            child: Text(
              'لا توجد أدعية',
              style: GoogleFonts.cairo(color: subColor),
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossCount = width > 600 ? 3 : 2;
              final cardWidth =
                  (width - 16 * 2 - 14 * (crossCount - 1)) /
                      crossCount;
              final cardHeight = cardWidth * 1.1;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
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

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration:
                    Duration(milliseconds: 400 + (index * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
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
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                              catColor.withOpacity(0.15),
                              catColor.withOpacity(0.05),
                            ]
                                : [
                              Colors.white,
                              catColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: catColor.withOpacity(
                                isDark ? 0.3 : 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : catColor.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 3,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: catColor
                                          .withOpacity(0.15),
                                      borderRadius:
                                      BorderRadius.circular(16),
                                      border: Border.all(
                                        color: catColor
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Icon(
                                      catIcon,
                                      color: catColor,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                flex: 3,
                                child: Text(
                                  cat.name,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: textColor,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                flex: 2,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: catColor
                                          .withOpacity(0.12),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${cat.duas.length} دعاء',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: catColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}