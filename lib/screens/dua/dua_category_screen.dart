import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/dua_model.dart';

class DuaCategoryScreen extends StatelessWidget {
  final DuaCategory category;
  final Color catColor;
  final IconData catIcon;

  const DuaCategoryScreen({
    super.key,
    required this.category,
    required this.catColor,
    required this.catIcon,
  });

  void _copyDua(BuildContext context, Dua dua) {
    final text = '${dua.title}\n\n${dua.text}\n\n📖 ${dua.source}'
        '${dua.reward.isNotEmpty ? '\n\n⭐ ${dua.reward}' : ''}';

    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الدعاء', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareDua(Dua dua) {
    final text = '${dua.title}\n\n${dua.text}\n\n📖 ${dua.source}'
        '${dua.reward.isNotEmpty ? '\n\n⭐ ${dua.reward}' : ''}'
        '\n\n— تطبيق طريق الإسلام';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardBg = isDark ? const Color(0xFF151B26) : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final duaFontSize = isSmall ? 18.0 : 22.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: catColor,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 14),
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      category.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        catColor,
                        catColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(catIcon, size: 90, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final dua = category.duas[index];

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 80)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : catColor.withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            childrenPadding: EdgeInsets.zero,
                            iconColor: catColor,
                            collapsedIconColor: catColor.withOpacity(0.6),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: catColor.withOpacity(0.25),
                                ),
                              ),
                              child: Center(
                                child: FittedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.cairo(
                                        color: catColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              dua.title,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmall ? 14 : 16,
                                color: textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                dua.source,
                                style: GoogleFonts.cairo(
                                  fontSize: isSmall ? 10 : 11,
                                  color: catColor.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 6),
                                child: Divider(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.grey.withOpacity(0.15),
                                  height: 1,
                                ),
                              ),

                              // نص الدعاء
                              Padding(
                                padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 14),
                                child: Text(
                                  dua.text,
                                  style: GoogleFonts.amiri(
                                    fontSize: duaFontSize,
                                    height: 2.0,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // المصدر
                              if (dua.source.isNotEmpty)
                                Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: catColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: catColor.withOpacity(0.15),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.menu_book_rounded,
                                          color: catColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            dua.source,
                                            style: GoogleFonts.cairo(
                                              fontSize: isSmall ? 11 : 12,
                                              color: catColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // الفضل
                              if (dua.reward.isNotEmpty)
                                Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.amber.withOpacity(0.08)
                                          : Colors.amber.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.amber.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber.shade700,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            dua.reward,
                                            style: GoogleFonts.cairo(
                                              fontSize: isSmall ? 11 : 12,
                                              color: isDark
                                                  ? Colors.amber.shade300
                                                  : Colors.amber.shade800,
                                              fontWeight: FontWeight.w600,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // أزرار النسخ والمشاركة
                              Padding(
                                padding:
                                const EdgeInsets.fromLTRB(16, 4, 16, 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 36,
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _copyDua(context, dua),
                                          icon: Icon(
                                            Icons.copy_rounded,
                                            size: 14,
                                            color: catColor,
                                          ),
                                          label: FittedBox(
                                            child: Text(
                                              'نسخ',
                                              style: GoogleFonts.cairo(
                                                color: catColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            side: BorderSide(
                                              color:
                                              catColor.withOpacity(0.3),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SizedBox(
                                        height: 36,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _shareDua(dua),
                                          icon: Icon(
                                            Icons.share_rounded,
                                            size: 14,
                                            color: catColor,
                                          ),
                                          label: FittedBox(
                                            child: Text(
                                              'مشاركة',
                                              style: GoogleFonts.cairo(
                                                color: catColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            side: BorderSide(
                                              color:
                                              catColor.withOpacity(0.3),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
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
                      ),
                    );
                  },
                  childCount: category.duas.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}