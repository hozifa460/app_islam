import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dart string literals do not contain mojibake Arabic text', () {
    final root = Directory('lib');
    final offenders = <String>[];

    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final source = entity.readAsStringSync();
      for (final literal in _stringLiterals(source)) {
        if (_looksLikeMojibake(literal)) {
          offenders.add('${entity.path}: ${_preview(literal)}');
          if (offenders.length >= 40) break;
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Found mojibake in Dart string literals:\n${offenders.join('\n')}',
    );
  });
}

bool _looksLikeMojibake(String value) {
  return RegExp(
    r'(?:[طظ][\u00A0-\u00FF\u061B\u06BE\u0679\u201A\u201E\u2020\u2026\u0192]|[Ââï][\u0080-\uFFFF]|\u064B\u06BA)',
  ).hasMatch(value);
}

String _preview(String value) {
  final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.length <= 80) return compact;
  return '${compact.substring(0, 80)}...';
}

Iterable<String> _stringLiterals(String source) sync* {
  var i = 0;
  while (i < source.length) {
    final char = source[i];
    final next = i + 1 < source.length ? source[i + 1] : '';

    if (char == '/' && next == '/') {
      i += 2;
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      continue;
    }

    if (char == '/' && next == '*') {
      i += 2;
      while (i + 1 < source.length &&
          !(source[i] == '*' && source[i + 1] == '/')) {
        i++;
      }
      i = (i + 1 < source.length) ? i + 2 : source.length;
      continue;
    }

    if (char == "'" || char == '"') {
      final quote = char;
      final triple = i + 2 < source.length &&
          source[i + 1] == quote &&
          source[i + 2] == quote;
      final start = i + (triple ? 3 : 1);
      i = start;

      final buffer = StringBuffer();
      while (i < source.length) {
        if (triple) {
          if (i + 2 < source.length &&
              source[i] == quote &&
              source[i + 1] == quote &&
              source[i + 2] == quote) {
            i += 3;
            break;
          }
        } else {
          if (source[i] == r'\') {
            if (i + 1 < source.length) {
              buffer.write(source.substring(i, i + 2));
              i += 2;
              continue;
            }
          }
          if (source[i] == quote) {
            i++;
            break;
          }
          if (source[i] == '\n') break;
        }

        buffer.write(source[i]);
        i++;
      }

      yield buffer.toString();
      continue;
    }

    i++;
  }
}
