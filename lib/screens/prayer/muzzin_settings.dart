import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/utils/radio_widget.dart';

import '../../data/prayer/muezzin_catalog.dart';
import 'muezzin_list_screen.dart';

class MuezzinSettingsScreen extends StatelessWidget {
  final Color primaryColor;

  MuezzinSettingsScreen({super.key, required this.primaryColor});

  final _gold = const Color(0xFFE6B325);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F5F5);
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final shadowColor =
    isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'اختيار المؤذن',
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
                : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'اختر القسم',
                      style: GoogleFonts.cairo(color: subTextColor, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    ...muezzinCatalog.map((cat) {
                      final isSheikhs = cat.id == 'sheikhs';

                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 450),
                        builder: (context, v, child) => Transform.translate(
                          offset: Offset(0, 18 * (1 - v)),
                          child: Opacity(opacity: v, child: child),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MuezzinListScreen(
                                  categoryId: cat.id,
                                  categoryName: cat.name,
                                  primaryColor: primaryColor,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSheikhs
                                    ? [_gold.withOpacity(0.2), _gold.withOpacity(0.05)]
                                    : cardGradient,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSheikhs
                                    ? _gold.withOpacity(0.5)
                                    : borderColor,
                                width: isSheikhs ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Column(
                                children: [
                                  Container(
                                    height: 140,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: cat.imageAsset != null
                                            ? AssetImage(cat.imageAsset!)
                                            : NetworkImage(cat.imageUrl)
                                        as ImageProvider,
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.3),
                                          BlendMode.darken,
                                        ),

                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.name,
                                                style: GoogleFonts.amiri(
                                                  fontSize: 22,
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                cat.description,
                                                style: GoogleFonts.cairo(
                                                  color: subTextColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSheikhs)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _gold.withOpacity(0.2),
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              border: Border.all(
                                                color: _gold.withOpacity(0.4),
                                              ),
                                            ),
                                            child: Text(
                                              'مشايخ',
                                              style: GoogleFonts.cairo(
                                                color: _gold,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    RadioMiniPlayer(gold: _gold),
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