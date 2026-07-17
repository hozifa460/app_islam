import 'package:islamic_app/utils/quran/warsh_tajweed_annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const textStyle = TextStyle(fontSize: 24);

  List<String> colouredSegments(String text) {
    final root = WarshTajweedAnnotations.buildLine(
      text: text,
      style: textStyle,
      defaultColor: Colors.black,
      enabled: true,
    );
    final children = root.children;
    if (children == null) return const [];
    return [
      for (final span in children.whereType<TextSpan>())
        if (span.style?.color == WarshTajweedAnnotations.maddBadal &&
            span.text != null)
          span.text!,
    ];
  }

  test('marks only the three matching forms of madd al-badal', () {
    expect(colouredSegments('ءَامَنَ إِيمَانٌ أُوتُوا'), ['ءَا', 'إِي', 'أُو']);
  });

  test('does not mark a vowelled letter or shaddah as a letter of madd', () {
    expect(colouredSegments('أُمُورٌ إِيَّاكَ أَوْ'), isEmpty);
  });

  test('supports the precomposed alif-madd form', () {
    expect(colouredSegments('آمَنَّا'), ['آ']);
  });
}
