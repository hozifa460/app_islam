import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/quran/quran_mushaf_page_service.dart';
import '../../services/quran/quran_reading_service.dart';
import '../../services/quran/quran_text_service.dart';
import 'warsh_tajweed_annotations.dart';

String _withoutInlineMushafAnnotations(String text) {
  return String.fromCharCodes(
    text.runes.where((rune) => rune < 0x06D6 || rune > 0x06ED),
  ).trim();
}

/// Text-only Madani-style page: continuous ayahs, inline ornamental verse
/// endings, plain paper background and page number at the bottom.
class QuranTextPage extends StatelessWidget {
  final int page;
  final Color primaryColor;
  final bool isDark;
  final double fontSize;
  final double bottomPadding;
  final bool isHidden;
  final int hideLevel;
  final int highlightedSurah;
  final int highlightedAyah;

  const QuranTextPage({
    super.key,
    required this.page,
    required this.primaryColor,
    required this.isDark,
    this.fontSize = 26,
    this.bottomPadding = 28,
    this.isHidden = false,
    this.hideLevel = 0,
    this.highlightedSurah = -1,
    this.highlightedAyah = -1,
  });

  @override
  Widget build(BuildContext context) {
    final ayahs = QuranTextService.getPageAyahs(page);
    if (ayahs.isEmpty) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    final groups = <List<Map<String, dynamic>>>[];
    for (final ayah in ayahs) {
      if (groups.isEmpty ||
          groups.last.first['surahNumber'] != ayah['surahNumber']) {
        groups.add([ayah]);
      } else {
        groups.last.add(ayah);
      }
    }

    final paper = isDark ? const Color(0xFF111111) : const Color(0xFFFEFDFB);
    final ink = isDark ? const Color(0xFFF5F3ED) : const Color(0xFF111111);
    final border = isDark ? Colors.white24 : const Color(0xFF7D7D7D);

    final fallbackPage = ColoredBox(
      color: paper,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 82, 5, bottomPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = (constraints.maxWidth - 20).clamp(120, 600);
            final contentHeight = (constraints.maxHeight - 38).clamp(120, 900);
            final effectiveFontSize = _fitFontSize(
              groups: groups,
              ink: ink,
              maxWidth: contentWidth.toDouble(),
              maxHeight: contentHeight.toDouble(),
            );

            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: border, width: .8),
                  right: BorderSide(color: border, width: .8),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment:
                          page <= 2 ? Alignment.center : Alignment.topCenter,
                      child: _buildPageContent(
                        groups: groups,
                        ink: ink,
                        effectiveFontSize: effectiveFontSize,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _arabicNumber(page),
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'UthmanicHafs',
                        fontSize: 15,
                        color: ink,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    Widget buildExactPage(List<Map<String, dynamic>> exactWords) {
      QuranMushafPageService.prefetchAround(page);
      return _ExactMushafPage(
        page: page,
        words: exactWords,
        pageAyahs: ayahs,
        primaryColor: primaryColor,
        paper: paper,
        ink: ink,
        border: border,
        bottomPadding: bottomPadding,
        preferredFontSize: fontSize,
        isDark: isDark,
        isHidden: isHidden,
        hideLevel: hideLevel,
        highlightedSurah: highlightedSurah,
        highlightedAyah: highlightedAyah,
      );
    }

    final cachedWords = QuranMushafPageService.getCachedPageWords(page);
    if (cachedWords != null) return buildExactPage(cachedWords);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: QuranMushafPageService.getPageWords(page),
      builder: (context, snapshot) {
        final exactWords = snapshot.data;
        if (exactWords == null || exactWords.isEmpty) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ColoredBox(
              color: paper,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                ),
              ),
            );
          }
          return fallbackPage;
        }
        return buildExactPage(exactWords);
      },
    );
  }

  Widget _buildPageContent({
    required List<List<Map<String, dynamic>>> groups,
    required Color ink,
    required double effectiveFontSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups) ...[
          if (group.first['numberInSurah'] == 1) ...[
            _SurahHeader(
              name: _cleanSurahName(group.first['surahName'] as String),
              isDark: isDark,
            ),
            if (group.first['surahNumber'] != 1 &&
                group.first['surahNumber'] != 9)
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: effectiveFontSize * .82,
                  height: 1.55,
                  color: ink,
                ),
              ),
            const SizedBox(height: 4),
          ],
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text.rich(
              TextSpan(children: _verseSpans(group, ink, effectiveFontSize)),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              softWrap: true,
              style: TextStyle(
                fontFamily: 'UthmanicHafs',
                fontSize: effectiveFontSize,
                height: 1.72,
                color: ink,
                wordSpacing: .7,
              ),
            ),
          ),
          if (group != groups.last) const SizedBox(height: 8),
        ],
      ],
    );
  }

  double _fitFontSize({
    required List<List<Map<String, dynamic>>> groups,
    required Color ink,
    required double maxWidth,
    required double maxHeight,
  }) {
    var low = 13.0;
    var high = fontSize;
    for (var iteration = 0; iteration < 12; iteration++) {
      final candidate = (low + high) / 2;
      if (_measurePage(groups, ink, candidate, maxWidth) <= maxHeight) {
        low = candidate;
      } else {
        high = candidate;
      }
    }
    return low;
  }

  double _measurePage(
    List<List<Map<String, dynamic>>> groups,
    Color ink,
    double effectiveFontSize,
    double maxWidth,
  ) {
    var height = 0.0;
    for (final group in groups) {
      if (group.first['numberInSurah'] == 1) {
        height += 46;
        if (group.first['surahNumber'] != 1 &&
            group.first['surahNumber'] != 9) {
          height += effectiveFontSize * .82 * 1.55;
        }
        height += 4;
      }
      final painter = TextPainter(
        text: TextSpan(
          children: _verseSpans(group, ink, effectiveFontSize),
          style: TextStyle(
            fontFamily: 'UthmanicHafs',
            fontSize: effectiveFontSize,
            height: 1.72,
            color: ink,
            wordSpacing: .7,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
      )..layout(maxWidth: maxWidth);
      height += painter.height;
      if (group != groups.last) height += 8;
    }
    return height;
  }

  List<InlineSpan> _verseSpans(
    List<Map<String, dynamic>> ayahs,
    Color ink,
    double effectiveFontSize,
  ) {
    return [
      for (final ayah in ayahs) ...[
        TextSpan(
          text: '${_displayText(ayah['text'] as String)} ',
          style: TextStyle(
            color: isHidden || hideLevel > 0 ? ink.withValues(alpha: .18) : ink,
            backgroundColor:
                highlightedSurah == ayah['surahNumber'] &&
                        highlightedAyah == ayah['numberInSurah']
                    ? primaryColor.withValues(alpha: .16)
                    : null,
          ),
        ),
        TextSpan(
          text: '۝${_arabicNumber(ayah['numberInSurah'] as int)} ',
          style: TextStyle(
            fontFamily: 'UthmanicHafs',
            fontSize: effectiveFontSize * .72,
            height: 1,
            color: ink,
          ),
        ),
      ],
    ];
  }

  String _cleanSurahName(String name) {
    return name.replaceFirst(RegExp(r'^سُ?و?رَ?ةُ?\s*'), '').trim();
  }

  String _displayText(String text) {
    text = _withoutInlineMushafAnnotations(text);
    if (isHidden) return text.split(RegExp(r'\s+')).map((_) => '●●').join(' ');
    if (hideLevel == 0) return text;
    return text
        .split(RegExp(r'\s+'))
        .asMap()
        .entries
        .map((entry) {
          final hide = switch (hideLevel) {
            1 => entry.key % 3 == 1,
            2 => entry.key.isEven,
            _ => true,
          };
          return hide ? '●●' : entry.value;
        })
        .join(' ');
  }

  String _arabicNumber(int value) {
    const digits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return value.toString().split('').map((digit) => digits[digit]).join();
  }
}

/// Fixed, offline page layout for Warsh 'an Nafi' (al-Azraq).  The line
/// breaks come from its own verified edition; it does not borrow Hafs layout.
class WarshTextPage extends StatelessWidget {
  final int page;
  final bool isDark;
  final double bottomPadding;
  final bool showTajweedColors;

  const WarshTextPage({
    super.key,
    required this.page,
    required this.isDark,
    this.bottomPadding = 18,
    this.showTajweedColors = true,
  });

  @override
  Widget build(BuildContext context) {
    final source = QuranReadingService.pageText(
      QuranReading.warshAnNafiAzraq,
      page,
    );
    final paper = isDark ? const Color(0xFF111111) : const Color(0xFFFEFDFB);
    final ink = isDark ? const Color(0xFFF5F3ED) : const Color(0xFF111111);
    final border = isDark ? Colors.white24 : const Color(0xFF7D7D7D);
    if (source == null) {
      return ColoredBox(
        color: paper,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final lines = source
        .split('\n')
        .map(_WarshPageLine.parse)
        .where((line) => line.hasContent)
        .toList(growable: false);
    return ColoredBox(
      color: paper,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 82, 5, bottomPadding),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: border, width: .8),
              right: BorderSide(color: border, width: .8),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const pageNumberHeight = 20.0;
              final usableHeight = constraints.maxHeight - pageNumberHeight;
              final lineHeight = usableHeight / lines.length.clamp(1, 15);
              final fontSize = (lineHeight * .62).clamp(16.0, 28.0);
              return Column(
                children: [
                  SizedBox(
                    height: usableHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final line in lines)
                          _WarshLine(
                            line: line,
                            fontSize: fontSize,
                            ink: ink,
                            paper: paper,
                            border: border,
                            showTajweedColors: showTajweedColors,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: pageNumberHeight,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _arabicPageNumber(page),
                        style: TextStyle(
                          fontFamily: 'UthmanicHafs',
                          fontSize: 15,
                          color: ink,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static String _arabicPageNumber(int value) {
    const digits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return value.toString().split('').map((digit) => digits[digit]).join();
  }
}

class _WarshLine extends StatelessWidget {
  final _WarshPageLine line;
  final double fontSize;
  final Color ink;
  final Color paper;
  final Color border;
  final bool showTajweedColors;

  const _WarshLine({
    required this.line,
    required this.fontSize,
    required this.ink,
    required this.paper,
    required this.border,
    required this.showTajweedColors,
  });

  @override
  Widget build(BuildContext context) {
    final isSurahTitle = line.plainText.startsWith('سُورَةُ');
    if (isSurahTitle) {
      return Container(
        height: fontSize * 1.42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: border, width: .8),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          line.plainText,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'UthmanicHafs',
            fontSize: fontSize * .74,
            color: ink,
          ),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: fontSize,
              height: 1,
              color: ink,
            ),
            children: line.buildSpans(
              fontSize: fontSize,
              ink: ink,
              showTajweedColors: showTajweedColors,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}

/// Replaces embedded source marks with our own ornaments. Some Android
/// fallback fonts render those source marks as filled black circles.
class _WarshPageLine {
  final List<_WarshLineToken> tokens;

  const _WarshPageLine._(this.tokens);

  factory _WarshPageLine.parse(String source) {
    final tokens = <_WarshLineToken>[];
    final text = StringBuffer();

    void flushText() {
      final value = text.toString();
      if (value.isNotEmpty) tokens.add(_WarshLineToken.text(value));
      text.clear();
    }

    var index = 0;
    while (index < source.length) {
      final code = source.codeUnitAt(index);
      if (code >= 0x0660 && code <= 0x0669) {
        flushText();
        final number = StringBuffer();
        while (index < source.length) {
          final digit = source.codeUnitAt(index);
          if (digit < 0x0660 || digit > 0x0669) break;
          number.writeCharCode(digit);
          index++;
        }
        tokens.add(_WarshLineToken.verse(number.toString()));
        continue;
      }
      if (code == 0x06DE) {
        flushText();
        tokens.add(const _WarshLineToken.quarter());
      } else if (code == 0x06E9) {
        flushText();
        tokens.add(const _WarshLineToken.sajda());
      } else if (code < 0x06D6 || code > 0x06ED) {
        text.writeCharCode(code);
      }
      index++;
    }
    flushText();
    return _WarshPageLine._(tokens);
  }

  bool get hasContent => tokens.isNotEmpty;

  String get plainText =>
      tokens
          .where((token) => token.kind == _WarshTokenKind.text)
          .map((token) => token.value)
          .join()
          .trim();

  List<InlineSpan> buildSpans({
    required double fontSize,
    required Color ink,
    required bool showTajweedColors,
  }) {
    final spans = <InlineSpan>[];
    for (final token in tokens) {
      switch (token.kind) {
        case _WarshTokenKind.text:
          spans.add(
            WarshTajweedAnnotations.buildLine(
              text: token.value,
              defaultColor: ink,
              enabled: showTajweedColors,
              style: TextStyle(
                fontFamily: 'UthmanicHafs',
                fontSize: fontSize,
                height: 1,
              ),
            ),
          );
        case _WarshTokenKind.verse:
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _VerseMarker(
                  number: token.value,
                  size: fontSize * 1.10,
                  color: ink,
                ),
              ),
            ),
          );
        case _WarshTokenKind.quarter:
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _InlineMushafMark.quarter(
                  size: fontSize * .86,
                  color: ink,
                ),
              ),
            ),
          );
        case _WarshTokenKind.sajda:
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _InlineMushafMark.sajda(
                  size: fontSize * .92,
                  color: ink,
                ),
              ),
            ),
          );
      }
    }
    return spans;
  }
}

enum _WarshTokenKind { text, verse, quarter, sajda }

class _WarshLineToken {
  final _WarshTokenKind kind;
  final String value;

  const _WarshLineToken._(this.kind, [this.value = '']);
  const _WarshLineToken.text(String value)
    : this._(_WarshTokenKind.text, value);
  const _WarshLineToken.verse(String value)
    : this._(_WarshTokenKind.verse, value);
  const _WarshLineToken.quarter() : this._(_WarshTokenKind.quarter);
  const _WarshLineToken.sajda() : this._(_WarshTokenKind.sajda);
}

class _ExactMushafPage extends StatelessWidget {
  final int page;
  final List<Map<String, dynamic>> words;
  final List<Map<String, dynamic>> pageAyahs;
  final Color primaryColor;
  final Color paper;
  final Color ink;
  final Color border;
  final double bottomPadding;
  final double preferredFontSize;
  final bool isDark;
  final bool isHidden;
  final int hideLevel;
  final int highlightedSurah;
  final int highlightedAyah;

  const _ExactMushafPage({
    required this.page,
    required this.words,
    required this.pageAyahs,
    required this.primaryColor,
    required this.paper,
    required this.ink,
    required this.border,
    required this.bottomPadding,
    required this.preferredFontSize,
    required this.isDark,
    required this.isHidden,
    required this.hideLevel,
    required this.highlightedSurah,
    required this.highlightedAyah,
  });

  @override
  Widget build(BuildContext context) {
    final lines = <int, List<Map<String, dynamic>>>{
      for (var line = 1; line <= 15; line++) line: [],
    };
    for (final word in _wordsWithGuaranteedVerseEnds()) {
      final line = word['line_number'] as int;
      lines[line]!.add(word);
    }
    final specialLines = _specialLines(lines);

    return ColoredBox(
      color: paper,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 82, 5, bottomPadding),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: border, width: .8),
              right: BorderSide(color: border, width: .8),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pageNumberHeight = 20.0;
              final linesHeight = constraints.maxHeight - pageNumberHeight;
              final lineHeight = linesHeight / 15;
              final font = math.min(preferredFontSize, lineHeight * .70);
              return Column(
                children: [
                  SizedBox(
                    height: linesHeight,
                    child: Column(
                      children: [
                        for (var line = 1; line <= 15; line++)
                          SizedBox(
                            height: lineHeight,
                            child:
                                specialLines[line] != null
                                    ? _buildSpecialLine(specialLines[line]!)
                                    : _buildWordLine(lines[line]!, font),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: pageNumberHeight,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _arabicNumber(page),
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'UthmanicHafs',
                          fontSize: 15,
                          color: ink,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _wordsWithGuaranteedVerseEnds() {
    final result = <Map<String, dynamic>>[];
    final existingEnds = <String>{
      for (final word in words)
        if (word['char_type_name'] == 'end')
          '${word['surah_number']}:${word['ayah_number']}',
    };
    for (var index = 0; index < words.length; index++) {
      final word = words[index];
      result.add(word);
      if (word['char_type_name'] == 'end') continue;

      final surah = word['surah_number'] as int;
      final ayah = word['ayah_number'] as int;
      final next = index + 1 < words.length ? words[index + 1] : null;
      if (next == null) continue;
      final nextIsSameAyah =
          next['surah_number'] == surah && next['ayah_number'] == ayah;
      if (nextIsSameAyah) continue;

      if (existingEnds.contains('$surah:$ayah')) continue;

      result.add({
        'position': (word['position'] as int? ?? 0) + 1,
        'text_uthmani': _arabicNumber(ayah),
        'line_number': word['line_number'],
        'char_type_name': 'end',
        'verse_key': '$surah:$ayah',
        'surah_number': surah,
        'ayah_number': ayah,
      });
    }
    return result;
  }

  Map<int, _MushafSpecialLine> _specialLines(
    Map<int, List<Map<String, dynamic>>> lines,
  ) {
    final result = <int, _MushafSpecialLine>{};
    final starts = <int, int>{};
    for (final word in words) {
      if (word['ayah_number'] != 1) continue;
      final surah = word['surah_number'] as int;
      final line = word['line_number'] as int;
      starts.update(
        surah,
        (current) => line < current ? line : current,
        ifAbsent: () => line,
      );
    }
    for (final entry in starts.entries) {
      final surah = entry.key;
      final firstTextLine = entry.value;
      final hasSeparateBasmala = surah != 1 && surah != 9;
      final headerLine = firstTextLine - (hasSeparateBasmala ? 2 : 1);
      if (headerLine >= 1 && (lines[headerLine]?.isEmpty ?? false)) {
        result[headerLine] = _MushafSpecialLine.header(_surahName(surah));
      }
      final basmalaLine = firstTextLine - 1;
      if (hasSeparateBasmala &&
          basmalaLine >= 1 &&
          (lines[basmalaLine]?.isEmpty ?? false)) {
        result[basmalaLine] = const _MushafSpecialLine.basmala();
      }
    }
    return result;
  }

  String _surahName(int surah) {
    for (final ayah in pageAyahs) {
      if (ayah['surahNumber'] == surah) {
        return _cleanSurahName(ayah['surahName'] as String);
      }
    }
    final ayahs = QuranTextService.getSurahAyahs(surah);
    if (ayahs.isEmpty) return '';
    return _cleanSurahName(ayahs.first['surahName'] as String);
  }

  Widget _buildSpecialLine(_MushafSpecialLine line) {
    if (line.isBasmala) {
      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: preferredFontSize * .78,
              color: ink,
            ),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: border, width: .8),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: _Ornament(color: border)),
          ColoredBox(
            color: paper,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'سُورَةُ ${line.surahName}',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 17,
                    color: ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordLine(List<Map<String, dynamic>> lineWords, double font) {
    lineWords = lineWords
        .where(
          (word) =>
              word['char_type_name'] == 'end' ||
              _cleanMushafWord(word['text_uthmani'] as String).isNotEmpty ||
              word['has_quarter_mark'] == true ||
              word['has_sajda_mark'] == true,
        )
        .toList(growable: false);
    if (lineWords.isEmpty) return const SizedBox.shrink();
    final rowChildren = <Widget>[];
    for (var index = 0; index < lineWords.length; index++) {
      if (index > 0) rowChildren.add(const SizedBox(width: 4));
      rowChildren.add(_buildWordToken(lineWords[index], font, index));
    }
    return ClipRect(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      ),
    );
  }

  Widget _buildWordToken(Map<String, dynamic> word, double font, int index) {
    final isEnd = word['char_type_name'] == 'end';
    if (isEnd) {
      return _VerseMarker(
        number: _arabicNumber(word['ayah_number'] as int),
        size: font * 1.22,
        color: ink,
      );
    }
    final cleanWord = _cleanMushafWord(word['text_uthmani'] as String);
    final hasQuarterMark = word['has_quarter_mark'] == true;
    final hasSajdaMark = word['has_sajda_mark'] == true;
    if (cleanWord.isEmpty && !hasQuarterMark && !hasSajdaMark) {
      return const SizedBox.shrink();
    }
    final surah = word['surah_number'] as int;
    final ayah = word['ayah_number'] as int;
    final highlighted = highlightedSurah == surah && highlightedAyah == ayah;
    final wordWidget =
        cleanWord.isEmpty
            ? const SizedBox.shrink()
            : Text(
              _displayWord(cleanWord, index),
              maxLines: 1,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'UthmanicHafs',
                fontSize: font,
                height: 1,
                color:
                    isHidden || hideLevel > 0
                        ? ink.withValues(alpha: .18)
                        : ink,
                backgroundColor:
                    highlighted ? primaryColor.withValues(alpha: .16) : null,
              ),
            );
    if (!hasQuarterMark && !hasSajdaMark) return wordWidget;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasQuarterMark)
          _InlineMushafMark.quarter(size: font * .74, color: ink),
        if (hasSajdaMark) _InlineMushafMark.sajda(size: font * .74, color: ink),
        if (cleanWord.isNotEmpty) const SizedBox(width: 2),
        wordWidget,
      ],
    );
  }

  String _displayWord(String word, int index) {
    if (isHidden) return '●●';
    final hide = switch (hideLevel) {
      0 => false,
      1 => index % 3 == 1,
      2 => index.isEven,
      _ => true,
    };
    return hide ? '●●' : word;
  }

  String _cleanMushafWord(String word) {
    return _withoutInlineMushafAnnotations(word);
  }

  String _cleanSurahName(String name) {
    return name.replaceFirst(RegExp(r'^سُ?و?رَ?ةُ?\s*'), '').trim();
  }

  String _arabicNumber(int value) {
    const digits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return value.toString().split('').map((digit) => digits[digit]).join();
  }
}

class _VerseMarker extends StatelessWidget {
  final String number;
  final double size;
  final Color color;

  const _VerseMarker({
    required this.number,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _VerseMarkerPainter(color),
        child: Center(
          child: Text(
            number,
            maxLines: 1,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: size * .58,
              height: 1,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerseMarkerPainter extends CustomPainter {
  final Color color;

  const _VerseMarkerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final paint =
        Paint()
          ..color = color.withValues(alpha: .72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .75;
    canvas.drawCircle(center, radius * .78, paint);
    canvas.drawCircle(center, radius * .60, paint);
    for (var index = 0; index < 8; index++) {
      final angle = -math.pi / 2 + index * math.pi / 4;
      final inner = Offset(
        center.dx + math.cos(angle) * radius * .61,
        center.dy + math.sin(angle) * radius * .61,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * radius * .96,
        center.dy + math.sin(angle) * radius * .96,
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VerseMarkerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _InlineMushafMark extends StatelessWidget {
  final bool sajda;
  final double size;
  final Color color;

  const _InlineMushafMark._({
    required this.sajda,
    required this.size,
    required this.color,
  });

  const _InlineMushafMark.quarter({required double size, required Color color})
    : this._(sajda: false, size: size, color: color);

  const _InlineMushafMark.sajda({required double size, required Color color})
    : this._(sajda: true, size: size, color: color);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _InlineMushafMarkPainter(color, sajda)),
    );
  }
}

class _InlineMushafMarkPainter extends CustomPainter {
  final Color color;
  final bool sajda;

  const _InlineMushafMarkPainter(this.color, this.sajda);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = color.withValues(alpha: .78)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .85;
    if (sajda) {
      final rect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * .08),
        width: size.width * .70,
        height: size.height * .58,
      );
      canvas.drawArc(rect, math.pi, math.pi, false, paint);
      canvas.drawLine(
        Offset(size.width * .15, size.height * .66),
        Offset(size.width * .85, size.height * .66),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx, size.height * .24),
        Offset(center.dx, size.height * .73),
        paint,
      );
      return;
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    final side = size.shortestSide * .54;
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: side, height: side),
      paint,
    );
    canvas.restore();
    canvas.drawCircle(center, size.shortestSide * .19, paint);
    canvas.drawLine(
      Offset(center.dx - size.width * .33, center.dy),
      Offset(center.dx + size.width * .33, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size.height * .33),
      Offset(center.dx, center.dy + size.height * .33),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _InlineMushafMarkPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.sajda != sajda;
  }
}

class _MushafSpecialLine {
  final String surahName;
  final bool isBasmala;

  const _MushafSpecialLine.header(this.surahName) : isBasmala = false;
  const _MushafSpecialLine.basmala() : surahName = '', isBasmala = true;
}

class _SurahHeader extends StatelessWidget {
  final String name;
  final bool isDark;

  const _SurahHeader({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? Colors.white38 : const Color(0xFF787878);
    final ink = isDark ? Colors.white : Colors.black;
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Row(
              children: [
                Expanded(child: _Ornament(color: border)),
                const SizedBox(width: 150),
                Expanded(child: _Ornament(color: border)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
            color: isDark ? const Color(0xFF111111) : const Color(0xFFFEFDFB),
            child: Text(
              'سُورَةُ $name',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'UthmanicHafs',
                fontSize: 19,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  final Color color;

  const _Ornament({required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _OrnamentPainter(color));
}

class _OrnamentPainter extends CustomPainter {
  final Color color;

  const _OrnamentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7;
    final center = Offset(size.width / 2, size.height / 2);
    for (var index = 0; index < 4; index++) {
      final inset = 3.0 + index * 3;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: (size.width - inset * 2).clamp(2, size.width).toDouble(),
          height: (size.height - inset * 2).clamp(2, size.height).toDouble(),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrnamentPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
