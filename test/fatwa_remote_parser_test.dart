import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/screens/fatwa/services/local_search_service.dart';

void main() {
  test('remote fatwa parser emits complete objects across partial chunks', () {
    final values = <Map<String, dynamic>>[];
    final parser = RemoteFatwaStreamParser(
      parsedBytes: 0,
      onObject: values.add,
    );
    final json = jsonEncode([
      {
        'id': 1,
        'question': 'ما الحكم؟',
        'answer': 'جواب يحتوي على {قوس} داخل النص',
      },
      {
        'id': 2,
        'question': 'سؤال ثان',
        'answer': 'نص به علامة اقتباس: "اختبار"',
      },
    ]);

    for (var index = 0; index < json.length; index += 7) {
      final end = index + 7 < json.length ? index + 7 : json.length;
      parser.add(json.substring(index, end));
    }

    expect(values, hasLength(2));
    expect(values.first['id'], 1);
    expect(values.last['id'], 2);
    expect(parser.parsedBytes, greaterThan(0));
  });

  test('remote progress separates provider name from file name', () {
    const progress = RemoteFileProgress(
      fileName: 'GitHub::islam_fatawa/part_001.json',
      status: 'يتم التحميل',
      downloadedBytes: 50,
      totalBytes: 100,
      parsedCount: 10,
    );

    expect(progress.sourceName, 'GitHub');
    expect(progress.displayName, 'part_001.json');
    expect(progress.fraction, 0.5);
  });
}
