import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/surah_constants.dart';
import 'sheet_widgets.dart';

class AdvancedIndexSheet extends StatelessWidget {
  final int currentPage;
  final Map<String, dynamic> savedMeta;
  final Function(int) onPageSelected;
  final VoidCallback onGoToLastPosition;
  final VoidCallback onGoToBookmark;
  final int Function(int) getPageForHizb;

  const AdvancedIndexSheet({
    Key? key,
    required this.currentPage,
    required this.savedMeta,
    required this.onPageSelected,
    required this.onGoToLastPosition,
    required this.onGoToBookmark,
    required this.getPageForHizb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 4,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'ظپظ‡ط±ط³ ط§ظ„ظ…طµط­ظپ',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SheetWidgets.buildQuickJumpCard(
                            context: context,
                            title: 'ط¢ط®ط± ظ…ظˆط¶ط¹',
                            value: savedMeta['lastPage'] != null
                                ? 'طµظپط­ط© ${SurahConstants.toArabicNum(savedMeta['lastPage'])}'
                                : 'ط؛ظٹط± ظ…طھظˆظپط±',
                            icon: Icons.history_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              onGoToLastPosition();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SheetWidgets.buildQuickJumpCard(
                            context: context,
                            title: 'ط§ظ„ط¹ظ„ط§ظ…ط©',
                            value: savedMeta['bookmarkPage'] != null
                                ? 'طµظپط­ط© ${SurahConstants.toArabicNum(savedMeta['bookmarkPage'])}'
                                : 'ط؛ظٹط± ظ…طھظˆظپط±',
                            icon: Icons.bookmark_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              onGoToBookmark();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                labelColor: primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primary,
                labelStyle: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'طµظپط­ط§طھ'),
                  Tab(text: 'ط§ظ„ط³ظˆط±'),
                  Tab(text: 'ط§ظ„ط£ط¬ط²ط§ط،'),
                  Tab(text: 'ط§ظ„ط£ط­ط²ط§ط¨'),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: TabBarView(
                  children: [
                    _PagesTab(
                      currentPage: currentPage,
                      onPageSelected: onPageSelected,
                    ),
                    _SurahsTab(onPageSelected: onPageSelected),
                    _JuzTab(onPageSelected: onPageSelected),
                    _HizbTab(
                      onPageSelected: onPageSelected,
                      getPageForHizb: getPageForHizb,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Pages Tab â”€â”€â”€
class _PagesTab extends StatelessWidget {
  final int currentPage;
  final Function(int) onPageSelected;

  const _PagesTab({
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: 604,
      itemBuilder: (context, index) {
        final page = index + 1;
        final selected = page == currentPage;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pop(context);
            onPageSelected(page);
          },
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? primary.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? primary : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              SurahConstants.toArabicNum(page),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

// â”€â”€â”€ Surahs Tab â”€â”€â”€
class _SurahsTab extends StatelessWidget {
  final Function(int) onPageSelected;

  const _SurahsTab({required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: SurahConstants.surahNames.length,
      itemBuilder: (context, index) {
        final surahNumber = index + 1;
        final page = SurahConstants.surahStartPages[index];

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            SurahConstants.surahNames[index],
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'طھط¨ط¯ط£ ظ…ظ† طµظپط­ط© ${SurahConstants.toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          trailing: Text(
            SurahConstants.toArabicNum(surahNumber),
            style: GoogleFonts.cairo(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            onPageSelected(page);
          },
        );
      },
    );
  }
}

// â”€â”€â”€ Juz Tab â”€â”€â”€
class _JuzTab extends StatelessWidget {
  final Function(int) onPageSelected;

  const _JuzTab({required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juz = index + 1;
        final page = SurahConstants.getPageForJuz(juz);

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'ط§ظ„ط¬ط²ط، ${SurahConstants.toArabicNum(juz)}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'ظٹط¨ط¯ط£ ظ…ظ† طµظپط­ط© ${SurahConstants.toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          onTap: () {
            Navigator.pop(context);
            onPageSelected(page);
          },
        );
      },
    );
  }
}

// â”€â”€â”€ Hizb Tab â”€â”€â”€
class _HizbTab extends StatelessWidget {
  final Function(int) onPageSelected;
  final int Function(int) getPageForHizb;

  const _HizbTab({
    required this.onPageSelected,
    required this.getPageForHizb,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 60,
      itemBuilder: (context, index) {
        final hizb = index + 1;
        final page = getPageForHizb(hizb);

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'ط§ظ„ط­ط²ط¨ ${SurahConstants.toArabicNum(hizb)}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'ظٹط¨ط¯ط£ ظ…ظ† طµظپط­ط© ${SurahConstants.toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          onTap: () {
            Navigator.pop(context);
            onPageSelected(page);
          },
        );
      },
    );
  }
}