// lib/widgets/quran_text_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/quran/quran_text_service.dart';
import '../../services/quran/audio_recitation_service.dart';

class QuranTextPage extends StatelessWidget {
  final int page;
  final Color primaryColor;
  final bool isDark;
  final double fontSize;
  final bool isHidden;
  final int hideLevel;
  final bool isReciting;
  final List<WordMatch> wordMatches;
  final int revealedWordCount;
  final int highlightedSurah;
  final int highlightedAyah;
  final Function(int surah, int ayah)? onAyahTap;
  final Function(int surah, int ayah)? onAyahLongPress;

  const QuranTextPage({
    super.key,
    required this.page,
    required this.primaryColor,
    required this.isDark,
    this.fontSize = 24,
    this.isHidden = false,
    this.hideLevel = 0,
    this.isReciting = false,
    this.wordMatches = const [],
    this.revealedWordCount = 0,
    this.highlightedSurah = -1,
    this.highlightedAyah = -1,
    this.onAyahTap,
    this.onAyahLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final ayahs = QuranTextService.getPageAyahs(page);

    if (ayahs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل النص...',
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // â•گâ•گâ•گâ•گ ظˆط¶ط¹ ط§ظ„طھط³ظ…ظٹط¹ â•گâ•گâ•گâ•گ
    if (isReciting) {
      return _RecitationView(
        ayahs: ayahs,
        primaryColor: primaryColor,
        isDark: isDark,
        fontSize: fontSize,
        wordMatches: wordMatches,
        revealedWordCount: revealedWordCount,
      );
    }

    // â•گâ•گâ•گâ•گ ط§ظ„ظˆط¶ط¹ ط§ظ„ط¹ط§ط¯ظٹ â•گâ•گâ•گâ•گ
    return _NormalView(
      ayahs: ayahs,
      primaryColor: primaryColor,
      isDark: isDark,
      fontSize: fontSize,
      isHidden: isHidden,
      hideLevel: hideLevel,
      highlightedSurah: highlightedSurah,
      highlightedAyah: highlightedAyah,
      onAyahTap: onAyahTap,
      onAyahLongPress: onAyahLongPress,
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط§ظ„ط¹ط±ط¶ ط§ظ„ط¹ط§ط¯ظٹ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _NormalView extends StatelessWidget {
  final List<Map<String, dynamic>> ayahs;
  final Color primaryColor;
  final bool isDark;
  final double fontSize;
  final bool isHidden;
  final int hideLevel;
  final int highlightedSurah;
  final int highlightedAyah;
  final Function(int, int)? onAyahTap;
  final Function(int, int)? onAyahLongPress;

  const _NormalView({
    required this.ayahs,
    required this.primaryColor,
    required this.isDark,
    required this.fontSize,
    required this.isHidden,
    required this.hideLevel,
    required this.highlightedSurah,
    required this.highlightedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 90, bottom: 170, left: 14, right: 14,
      ),
      itemCount: ayahs.length,
      itemBuilder: (context, index) {
        final ayah = ayahs[index];
        final surahNum = ayah['surahNumber'] as int;
        final ayahNum = ayah['numberInSurah'] as int;
        final text = ayah['text'] as String;
        final surahName = ayah['surahName'] ?? '';
        final isHL = highlightedSurah == surahNum &&
            highlightedAyah == ayahNum;
        final isFirst = ayahNum == 1;

        // ط§ظ„ظ†طµ ط§ظ„ظ…ط¹ط±ظˆط¶
        final effectiveHide = isHidden ? 3 : hideLevel;
        String display = effectiveHide > 0
            ? _hide(text, effectiveHide)
            : text;

        Color txtColor = effectiveHide > 0
            ? Colors.grey.withValues(alpha: 0.2)
            : isHL
            ? primaryColor
            : (isDark ? Colors.white : Colors.black87);

        return Column(
          children: [
            // ط¹ظ†ظˆط§ظ† ط§ظ„ط³ظˆط±ط©
            if (isFirst && index > 0)
              const SizedBox(height: 20),

            if (isFirst)
              _surahBanner(surahName),

            if (isFirst && surahNum != 1 && surahNum != 9)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FittedBox(
                  child: Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: GoogleFonts.amiri(
                      fontSize: fontSize * 0.75,
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                  ),
                ),
              ),

            // ط§ظ„ط¢ظٹط©
            GestureDetector(
              onTap: () => onAyahTap?.call(surahNum, ayahNum),
              onLongPress: () => onAyahLongPress?.call(surahNum, ayahNum),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isHL
                      ? primaryColor.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isHL
                      ? Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                  )
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ط±ظ‚ظ… ط§ظ„ط¢ظٹط©
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _ar(ayahNum),
                        style: GoogleFonts.cairo(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ط§ظ„ظ†طµ
                    Expanded(
                      child: Text(
                        display,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.amiri(
                          fontSize: fontSize,
                          height: 1.85,
                          color: txtColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _surahBanner(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withValues(alpha: 0.85), primaryColor],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'سورة $name',
          style: GoogleFonts.amiri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _hide(String text, int level) {
    final w = text.split(' ');
    switch (level) {
      case 1: return w.asMap().entries.map((e) => e.key % 3 == 1 ? '●●' : e.value).join(' ');
      case 2: return w.asMap().entries.map((e) => e.key.isEven ? '●●' : e.value).join(' ');
      case 3: return w.map((_) => '●●').join(' ');
      default: return text;
    }
  }

  String _ar(int n) {
    const d = {'0':'٠','1':'ظ،','2':'٢','3':'٣','4':'٤','5':'٥','6':'٦','7':'٧','8':'٨','9':'٩'};
    String s = n.toString();
    d.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط¹ط±ط¶ ط§ظ„طھط³ظ…ظٹط¹ ط§ظ„ط°ظƒظٹ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _RecitationView extends StatelessWidget {
  final List<Map<String, dynamic>> ayahs;
  final Color primaryColor;
  final bool isDark;
  final double fontSize;
  final List<WordMatch> wordMatches;
  final int revealedWordCount;

  const _RecitationView({
    required this.ayahs,
    required this.primaryColor,
    required this.isDark,
    required this.fontSize,
    required this.wordMatches,
    required this.revealedWordCount,
  });

  @override
  Widget build(BuildContext context) {
    // طھط¬ظ…ظٹط¹ ظƒظ„ ط§ظ„ظƒظ„ظ…ط§طھ
    List<_Word> allWords = [];

    for (final ayah in ayahs) {
      final text = (ayah['text'] as String)
          .replaceAll(RegExp(r'[\u06D6-\u06ED]'), '')
          .trim();
      final ayahNum = ayah['numberInSurah'] as int;
      final words = text.split(RegExp(r'\s+'));

      for (int i = 0; i < words.length; i++) {
        if (words[i].isEmpty) continue;
        allWords.add(_Word(
          text: words[i],
          ayahNumber: ayahNum,
          isFirstInAyah: i == 0,
        ));
      }
    }

    final progress = allWords.isEmpty
        ? 0.0
        : revealedWordCount / allWords.length;

    return ListView(
      padding: const EdgeInsets.only(
        top: 90, bottom: 170, left: 14, right: 14,
      ),
      children: [
        // â”€â”€â”€ ط¨ط§ظ†ط± ط§ظ„طھط³ظ…ظٹط¹ â”€â”€â”€
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, color: Colors.green.shade600, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'اقرأ بصوتك وستظهر الكلمات تلقائياً',
                  style: GoogleFonts.cairo(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // â”€â”€â”€ ط´ط±ظٹط· ط§ظ„طھظ‚ط¯ظ… â”€â”€â”€
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.grey.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_ar(revealedWordCount)} / ${_ar(allWords.length)} كلمة',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // â”€â”€â”€ ط§ظ„ظƒظ„ظ…ط§طھ â”€â”€â”€
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 6,
            children: List.generate(allWords.length, (i) {
              final word = allWords[i];
              bool revealed = false;
              bool correct = false;
              bool wrong = false;

              if (i < wordMatches.length) {
                revealed = wordMatches[i].isRevealed;
                correct = wordMatches[i].isCorrect;
                wrong = revealed && !correct;
              }

              List<Widget> items = [];

              // ظپط§طµظ„ ط¢ظٹط©
              if (word.isFirstInAyah && i > 0) {
                items.add(
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            _ar(allWords[i > 0 ? i - 1 : 0].ayahNumber),
                            style: TextStyle(
                              fontSize: 8,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // ط§ظ„ظƒظ„ظ…ط©
              items.add(
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3, vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: correct
                        ? Colors.green.withValues(alpha: 0.12)
                        : wrong
                        ? Colors.red.withValues(alpha: 0.12)
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    revealed ? word.text : '●●',
                    style: GoogleFonts.amiri(
                      fontSize: fontSize * 0.9,
                      height: 1.7,
                      color: correct
                          ? Colors.green.shade700
                          : wrong
                          ? Colors.red.shade600
                          : Colors.grey.withValues(alpha: 0.2),
                      fontWeight: revealed
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: items,
              );
            }),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  String _ar(int n) {
    const d = {'0':'٠','1':'ظ،','2':'٢','3':'٣','4':'٤','5':'٥','6':'٦','7':'٧','8':'٨','9':'٩'};
    String s = n.toString();
    d.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }
}

class _Word {
  final String text;
  final int ayahNumber;
  final bool isFirstInAyah;

  _Word({
    required this.text,
    required this.ayahNumber,
    required this.isFirstInAyah,
  });
}