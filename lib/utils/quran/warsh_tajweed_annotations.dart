import 'package:flutter/material.dart';

/// Conservative, text-native annotations for Warsh 'an Nafi' (al-Azraq).
///
/// The reader only colours a rule when it can be identified from the written
/// word itself.  Reading-specific word differences are deliberately kept out
/// of this matcher until they are supplied as a reviewed, ayah-addressed map.
class WarshTajweedAnnotations {
  const WarshTajweedAnnotations._();

  /// The selected educational face: tawassut of madd al-badal (four counts).
  static const Color maddBadal = Color(0xFFFF6D00);
  static const Color idgham = Color(0xFF155EEF);
  static const Color hafsDifference = Color(0xFFD946EF);
  static const Color naql = Color(0xFF0EA5A8);
  static const Color taqlil = Color(0xFF22A06B);
  static const Color tarqiqRa = Color(0xFF6BAE26);
  static const Color mimPlural = Color(0xFFB5474B);

  static const List<WarshLegendRule> legendRules = [
    WarshLegendRule(
      color: maddBadal,
      title: 'مد البدل — توسط',
      subtitle: 'الوجه المعروض: أربع حركات.',
      isEnabled: true,
    ),
    WarshLegendRule(
      color: idgham,
      title: 'الإدغام',
      subtitle: 'نون ساكنة أو تنوين قبل حروف الإدغام بين كلمتين.',
      isEnabled: true,
    ),
    WarshLegendRule(
      color: hafsDifference,
      title: 'أحرف الخلاف عن حفص',
      subtitle: 'تُفعّل بعد ربط كل موضع بخريطة فروق مراجَعة.',
      isEnabled: false,
    ),
    WarshLegendRule(
      color: naql,
      title: 'النقل',
      subtitle: 'يحتاج خريطة مواضع خاصة بطريق الأزرق.',
      isEnabled: false,
    ),
    WarshLegendRule(
      color: taqlil,
      title: 'التقليل',
      subtitle: 'يحتاج خريطة مواضع مراجَعة.',
      isEnabled: false,
    ),
    WarshLegendRule(
      color: tarqiqRa,
      title: 'ترقيق الراء',
      subtitle: 'يحتاج معالجة سياق الكلمة والوقف.',
      isEnabled: false,
    ),
    WarshLegendRule(
      color: mimPlural,
      title: 'صلة ميم الجمع',
      subtitle: 'يحتاج معالجة وصل الآية وسياقها.',
      isEnabled: false,
    ),
  ];

  static TextSpan buildLine({
    required String text,
    required TextStyle style,
    required Color defaultColor,
    required bool enabled,
  }) {
    if (!enabled) return TextSpan(text: text, style: style);

    final ranges = [..._maddBadalRanges(text), ..._idghamRanges(text)]
      ..sort((a, b) => a.start.compareTo(b.start));
    if (ranges.isEmpty) return TextSpan(text: text, style: style);

    final children = <InlineSpan>[];
    var cursor = 0;
    for (final range in ranges) {
      if (range.start < cursor) continue;
      if (range.start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, range.start)));
      }
      children.add(
        TextSpan(
          text: text.substring(range.start, range.end),
          style: style.copyWith(color: range.color),
        ),
      );
      cursor = range.end;
    }
    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }
    return TextSpan(
      style: style.copyWith(color: defaultColor),
      children: children,
    );
  }

  /// A madd badal is a hamzah followed in the same word by its matching true
  /// letter of madd: a fathah then alif, a kasrah then sakin yaa, or a dammah
  /// then sakin waw. This covers: ءَامَنُوا، إِيمَان، أُوتُوا and excludes
  /// forms such as أُمُور where the following waw is vowelled.
  static List<_TextRange> _maddBadalRanges(String text) {
    final ranges = <_TextRange>[];
    var index = 0;
    while (index < text.length) {
      final code = text.codeUnitAt(index);
      if (code == 0x0622) {
        // U+0622 is the pre-composed form of a fathah-hamzah followed by alif.
        ranges.add(_TextRange(index, index + 1, maddBadal));
      } else if (_isHamzah(code)) {
        final vowel = _followingVowel(text, index);
        final letterIndex = _nextBaseLetter(text, index + 1);
        if (letterIndex != null &&
            _isMatchingMaddLetter(
              letter: text.codeUnitAt(letterIndex),
              hamzahVowel: vowel,
              text: text,
              index: letterIndex,
            )) {
          ranges.add(
            _TextRange(index, _letterEnd(text, letterIndex), maddBadal),
          );
          index = letterIndex;
        }
      }
      index++;
    }
    return ranges;
  }

  static bool _isHamzah(int code) =>
      code == 0x0621 || // ء
      code == 0x0623 || // أ
      code == 0x0624 || // ؤ
      code == 0x0625 || // إ
      code == 0x0626; // ئ

  static int? _followingVowel(String text, int hamzahIndex) {
    var index = hamzahIndex + 1;
    while (index < text.length && _isArabicMark(text.codeUnitAt(index))) {
      final mark = text.codeUnitAt(index);
      if (mark == 0x064E || mark == 0x0650 || mark == 0x064F) return mark;
      index++;
    }
    return null;
  }

  static int? _nextBaseLetter(String text, int from) {
    var index = from;
    while (index < text.length && _isArabicMark(text.codeUnitAt(index))) {
      index++;
    }
    return index < text.length ? index : null;
  }

  static bool _isMatchingMaddLetter({
    required int letter,
    required int? hamzahVowel,
    required String text,
    required int index,
  }) {
    if (hamzahVowel == 0x064E) {
      return letter == 0x0627 || letter == 0x0649;
    }
    if (hamzahVowel == 0x0650) {
      return (letter == 0x064A || letter == 0x06D2) && _isSakin(text, index);
    }
    if (hamzahVowel == 0x064F) {
      return letter == 0x0648 && _isSakin(text, index);
    }
    return false;
  }

  /// In Unicode Mushaf text a letter of madd can either carry an explicit
  /// sukun or be left without a vowel mark. Both are sakin; a short vowel or
  /// shaddah makes it a consonant and therefore not a letter of madd.
  static bool _isSakin(String text, int letterIndex) {
    var index = letterIndex + 1;
    while (index < text.length && _isArabicMark(text.codeUnitAt(index))) {
      final mark = text.codeUnitAt(index);
      if (mark == 0x0652) return true;
      if (mark == 0x064B ||
          mark == 0x064C ||
          mark == 0x064D ||
          mark == 0x064E ||
          mark == 0x064F ||
          mark == 0x0650 ||
          mark == 0x0651) {
        return false;
      }
      index++;
    }
    return true;
  }

  static int _letterEnd(String text, int letterIndex) {
    var index = letterIndex + 1;
    while (index < text.length && _isArabicMark(text.codeUnitAt(index))) {
      index++;
    }
    return index;
  }

  static bool _isArabicMark(int code) =>
      (code >= 0x064B && code <= 0x065F) ||
      code == 0x0670 ||
      (code >= 0x06D6 && code <= 0x06ED);

  static List<_TextRange> _idghamRanges(String text) {
    const targets = {0x064A, 0x0631, 0x0645, 0x0644, 0x0648, 0x0646};
    const tanween = {0x064B, 0x064C, 0x064D};
    final ranges = <_TextRange>[];
    for (var index = 0; index < text.length; index++) {
      final code = text.codeUnitAt(index);
      final startsWithSakinNoon =
          code == 0x0646 &&
          index + 1 < text.length &&
          text.codeUnitAt(index + 1) == 0x0652;
      final startsWithTanween = tanween.contains(code);
      if (!startsWithSakinNoon && !startsWithTanween) continue;

      var next = index + 1;
      var crossedWordBoundary = false;
      while (next < text.length) {
        final nextCode = text.codeUnitAt(next);
        if (_isArabicMark(nextCode)) {
          next++;
          continue;
        }
        if (String.fromCharCode(nextCode).trim().isEmpty) {
          crossedWordBoundary = true;
          next++;
          continue;
        }
        break;
      }
      if (crossedWordBoundary &&
          next < text.length &&
          targets.contains(text.codeUnitAt(next))) {
        final start =
            startsWithSakinNoon ? index : _previousBaseLetter(text, index);
        ranges.add(_TextRange(start, index + 1, idgham));
      }
    }
    return ranges;
  }

  static int _previousBaseLetter(String text, int from) {
    var index = from - 1;
    while (index > 0 && _isArabicMark(text.codeUnitAt(index))) {
      index--;
    }
    return index;
  }
}

class _TextRange {
  final int start;
  final int end;
  final Color color;

  const _TextRange(this.start, this.end, this.color);
}

class WarshLegendRule {
  final Color color;
  final String title;
  final String subtitle;
  final bool isEnabled;

  const WarshLegendRule({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
  });
}
