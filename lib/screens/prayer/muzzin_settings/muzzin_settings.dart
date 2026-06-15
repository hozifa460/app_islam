import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../more/data/muezzin_catalog.dart';
import '../prayer_times_screen/widgets/radio_widget.dart';
import '../muezzin_list_screen/muezzin_list_screen.dart';
import 'widgets/muezzin_category_card.dart';

// ط§ط³طھط¯ط¹ط§ط، ظ…ظ„ظپ ط§ظ„طھط±ط¬ظ…ط© (طھط£ظƒط¯ ظ…ظ† ط§ظ„ظ…ط³ط§ط± ط§ظ„ط®ط§طµ ط¨ظƒ)
import '../../../../languages/app_localizations.dart';

class MuezzinSettingsScreen extends StatelessWidget {
  final Color primaryColor;

  MuezzinSettingsScreen({super.key, required this.primaryColor});

  final _gold = const Color(0xFFE6B325);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
    isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr.chooseMuezzinTitle, // طھظ…طھ ط§ظ„طھط±ط¬ظ…ط© ظ‡ظ†ط§
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
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
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
                      context.tr.chooseCategorySubtitle, // طھظ…طھ ط§ظ„طھط±ط¬ظ…ط© ظ‡ظ†ط§
                      style: GoogleFonts.cairo(
                          color: subTextColor, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    ...muezzinCatalog.map((cat) {
                      return MuezzinCategoryCard(
                        category: cat,
                        gold: _gold,
                        isDark: isDark,
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