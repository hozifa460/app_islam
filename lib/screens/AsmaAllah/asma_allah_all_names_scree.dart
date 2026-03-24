import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Asma_Allah_Detail_Screen.dart';
import 'asma_allah_screen.dart';

class AsmaAllahAllNamesScreen extends StatefulWidget {
  final Color primaryColor;
  final List<Map<String, String>> names;

  const AsmaAllahAllNamesScreen({
    super.key,
    required this.primaryColor,
    required this.names,
  });

  @override
  State<AsmaAllahAllNamesScreen> createState() =>
      _AsmaAllahAllNamesScreenState();
}

class _AsmaAllahAllNamesScreenState extends State<AsmaAllahAllNamesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF8F6F1);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    const gold = Color(0xFFE6B325);

    final filteredNames =
        widget.names.where((item) {
          final name = item['name'] ?? '';
          final meaning = item['meaning'] ?? '';
          return name.contains(_searchQuery) || meaning.contains(_searchQuery);
        }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: widget.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'جميع الأسماء',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final spacing = width < 360 ? 10.0 : 12.0;
              final crossAxisCount = width < 430 ? 2 : 3;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: gold.withOpacity(0.18)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.18 : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'ابحث عن اسم أو معنى...',
                          hintStyle: GoogleFonts.cairo(color: subTextColor),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.search_rounded,
                            color: widget.primaryColor,
                          ),
                        ),
                        style: GoogleFonts.cairo(color: textColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          filteredNames.isEmpty
                              ? Center(
                                child: Text(
                                  'لا توجد نتائج مطابقة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    color: subTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              : LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final innerWidth = innerConstraints.maxWidth;
                                  final small = innerWidth < 360;
                                  final spacing = small ? 10.0 : 12.0;
                                  final crossAxisCount =
                                      innerWidth < 430 ? 2 : 3;

                                  final usableWidth =
                                      innerWidth -
                                      (spacing * (crossAxisCount - 1));
                                  final itemWidth =
                                      usableWidth / crossAxisCount;

                                  // ✅ ارتفاع مدروس للبطاقات
                                  final itemHeight = small ? 190.0 : 205.0;
                                  final childAspectRatio =
                                      itemWidth / itemHeight;

                                  return GridView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: filteredNames.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: spacing,
                                          mainAxisSpacing: spacing,
                                          childAspectRatio: childAspectRatio,
                                        ),
                                    itemBuilder: (context, index) {
                                      final item = filteredNames[index];
                                      final originalIndex =
                                          widget.names.indexOf(item) + 1;

                                      return InkWell(
                                        borderRadius: BorderRadius.circular(22),
                                        onTap: () {
                                          final heroTag =
                                              'asma_name_$originalIndex';

                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 500,
                                                  ),
                                              reverseTransitionDuration:
                                                  const Duration(
                                                    milliseconds: 350,
                                                  ),
                                              pageBuilder: (
                                                _,
                                                animation,
                                                secondaryAnimation,
                                              ) {
                                                return AsmaAllahDetailScreen(
                                                  name: item['name']!,
                                                  meaning: item['meaning']!,
                                                  primaryColor:
                                                      widget.primaryColor,
                                                  order: originalIndex,
                                                  names: widget.names,
                                                  heroTag: heroTag,
                                                );
                                              },
                                              transitionsBuilder: (
                                                _,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                final curved = CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOutCubic,
                                                );

                                                return FadeTransition(
                                                  opacity: curved,
                                                  child: SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(
                                                        0,
                                                        0.04,
                                                      ),
                                                      end: Offset.zero,
                                                    ).animate(curved),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            border: Border.all(
                                              color: gold.withOpacity(0.18),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  isDark ? 0.18 : 0.05,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 8,
                                                left: 8,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: widget.primaryColor
                                                        .withOpacity(0.10),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '$originalIndex',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          widget.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Hero(
                                                      tag:
                                                          'asma_name_$originalIndex',
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: Container(
                                                          width:
                                                              small ? 50 : 58,
                                                          height:
                                                              small ? 50 : 58,
                                                          decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: gold
                                                                .withOpacity(
                                                                  0.12,
                                                                ),
                                                            border: Border.all(
                                                              color: gold
                                                                  .withOpacity(
                                                                    0.25,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .auto_awesome_rounded,
                                                            color: gold,
                                                            size:
                                                                small ? 22 : 26,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        item['name']!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: GoogleFonts.amiri(
                                                          fontSize:
                                                              small ? 19 : 21,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              widget
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Expanded(
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Text(
                                                          item['meaning']!,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 4,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              GoogleFonts.cairo(
                                                                fontSize:
                                                                    small
                                                                        ? 10.5
                                                                        : 11.5,
                                                                color:
                                                                    subTextColor,
                                                                height: 1.45,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
