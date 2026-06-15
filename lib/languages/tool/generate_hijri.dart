import 'dart:convert';
import 'dart:io';

/// ط¬ظ…ظٹط¹ ط§ظ„ظ„ط؛ط§طھ ط§ظ„طھظٹ طھط¯ط¹ظ…ظ‡ط§ (ط¨ط¯ظˆظ† ar ظ„ط£ظ†ظ‡ ط§ظ„ط£ط³ط§ط³)
const languages = [
  'en',  // English - ط§ظ„ط¥ظ†ط¬ظ„ظٹط²ظٹط©
  'fr',  // Franأ§ais - ط§ظ„ظپط±ظ†ط³ظٹط©
  'de',  // Deutsch - ط§ظ„ط£ظ„ظ…ط§ظ†ظٹط©
  'es',  // Espaأ±ol - ط§ظ„ط¥ط³ط¨ط§ظ†ظٹط©
  'it',  // Italiano - ط§ظ„ط¥ظٹط·ط§ظ„ظٹط©
  'pt',  // Portuguأھs - ط§ظ„ط¨ط±طھط؛ط§ظ„ظٹط©
  'nl',  // Nederlands - ط§ظ„ظ‡ظˆظ„ظ†ط¯ظٹط©
  'ru',  // ذ رƒرپرپذ؛ذ¸ذ¹ - ط§ظ„ط±ظˆط³ظٹط©
  'tr',  // Tأ¼rkأ§e - ط§ظ„طھط±ظƒظٹط©
  'ur',  // ط§ط±ط¯ظˆ - ط§ظ„ط£ظˆط±ط¯ظٹط©
  'id',  // Bahasa Indonesia - ط§ظ„ط¥ظ†ط¯ظˆظ†ظٹط³ظٹط©
  'ms',  // Bahasa Melayu - ط§ظ„ظ…ظ„ط§ظٹظˆظٹط©
  'hi',  // à¤¹à¤؟à¤¨à¥چà¤¦à¥€ - ط§ظ„ظ‡ظ†ط¯ظٹط©
  'ja',  // و—¥وœ¬èھ‍ - ط§ظ„ظٹط§ط¨ط§ظ†ظٹط©
  'zh',  // ن¸­و–‡ - ط§ظ„طµظٹظ†ظٹط©
  'uz',  // Oت»zbekcha - ط§ظ„ط£ظˆط²ط¨ظƒظٹط©
  'sw',  // Kiswahili - ط§ظ„ط³ظˆط§ط­ظٹظ„ظٹط©
  'ha',  // Hausa - ط§ظ„ظ‡ظˆط³ط§
  'am',  // لٹ لˆ›لˆ­لٹ› - ط§ظ„ط£ظ…ظ‡ط±ظٹط©
  'so',  // Soomaali - ط§ظ„طµظˆظ…ط§ظ„ظٹط©
];

void main() async {
  final baseFile = File('assets/hijri/hijri_ar.json');

  if (!baseFile.existsSync()) {
    print('â‌Œ ظ…ظ„ظپ ar.json ط؛ظٹط± ظ…ظˆط¬ظˆط¯');
    return;
  }

  final Map<String, dynamic> baseContent =
  jsonDecode(baseFile.readAsStringSync());

  print('ًں“‹ ط¹ط¯ط¯ ط§ظ„ظ…ظپط§طھظٹط­ ظپظٹ ar.json: ${baseContent.length}');
  print('â”€' * 50);

  for (final lang in languages) {
    final file = File('assets/hijri/hijri_$lang.json');

    if (!file.existsSync()) {
      // â•گâ•گâ•گ ط¥ظ†ط´ط§ط، ظ…ظ„ظپ ط¬ط¯ظٹط¯ â•گâ•گâ•گ
      final newContent = _generateJsonWithComments(baseContent, lang, {});
      file.writeAsStringSync(newContent);
      print('âœ… طھظ… ط¥ظ†ط´ط§ط، $lang.json');
    } else {
      // â•گâ•گâ•گ طھط­ط¯ظٹط« ظ…ظ„ظپ ظ…ظˆط¬ظˆط¯ â•گâ•گâ•گ
      final Map<String, dynamic> existing =
      jsonDecode(file.readAsStringSync());

      int added = 0;
      int removed = 0;
      int kept = 0;

      // ط­ط³ط§ط¨ ط§ظ„ط¥ط­طµط§ط¦ظٹط§طھ
      for (var key in baseContent.keys) {
        if (!key.startsWith('_')) {
          if (existing.containsKey(key)) {
            kept++;
          } else {
            added++;
          }
        }
      }

      for (var key in existing.keys) {
        if (!key.startsWith('_') && !baseContent.containsKey(key)) {
          removed++;
        }
      }

      final newContent = _generateJsonWithComments(baseContent, lang, existing);
      file.writeAsStringSync(newContent);

      String status = (added > 0 || removed > 0) ? 'âڑ،' : 'ًں”„';
      print('$status $lang.json â†’ '
          'âœ… ظ…ط­ظپظˆط¸: $kept | '
          'â‍• ط¬ط¯ظٹط¯: $added | '
          'ًں—‘ï¸ڈ ظ…ط­ط°ظˆظپ: $removed');
    }
  }

  print('â”€' * 50);
  print('ًںژ‰ ط§ظ†طھظ‡ظ‰ طھط­ط¯ظٹط« ط¬ظ…ظٹط¹ ط§ظ„ظ…ظ„ظپط§طھ!');
  print('');
  print('ًں’، ط§ظ„ظ…ظپط§طھظٹط­ ط§ظ„ط¬ط¯ظٹط¯ط© طھط¨ط¯ط£ ط¨ظ€ [lang] ظ„ظ„طھظ…ظٹظٹط²');
  print('ًں“‌ ط§ظ„طھط¹ظ„ظٹظ‚ط§طھ طھط¨ط¯ط£ ط¨ظ€ _comment_');
  print('ًں“¦ ط§ظ„ط£ظ‚ط³ط§ظ… طھط¨ط¯ط£ ط¨ظ€ __SECTION__');
}

/// طھظˆظ„ظٹط¯ JSON ظ…ط¹ ط§ظ„طھط¹ظ„ظٹظ‚ط§طھ ظˆط§ظ„ظپظˆط§طµظ„
String _generateJsonWithComments(
    Map<String, dynamic> baseContent,
    String lang,
    Map<String, dynamic> existing,
    ) {
  final buffer = StringBuffer();
  buffer.writeln('{');

  final keys = baseContent.keys.toList();

  for (int i = 0; i < keys.length; i++) {
    final key = keys[i];
    final isLast = (i == keys.length - 1);

    // â•گâ•گâ•گ طھط¹ظ„ظٹظ‚ (ط³ط·ط± ظپط§ط±ط؛ + طھط¹ظ„ظٹظ‚) â•گâ•گâ•گ
    if (key.startsWith('_comment_')) {
      buffer.writeln('');
      final comment = baseContent[key].toString();
      buffer.write('  "$key": "$comment"');
    }
    // â•گâ•گâ•گ ظپط§طµظ„ ظ‚ط³ظ… â•گâ•گâ•گ
    else if (key.startsWith('__') && key.endsWith('__')) {
      buffer.writeln('');
      buffer.writeln('');
      final section = baseContent[key].toString();
      // طھط±ط¬ظ…ط© ط§ط³ظ… ط§ظ„ظ‚ط³ظ… ط£ظˆ ط¥ط¨ظ‚ط§ط،ظ‡
      final translatedSection = existing[key]?.toString() ?? section;
      buffer.write('  "$key": "$translatedSection"');
    }
    // â•گâ•گâ•گ ظ…ظپطھط§ط­ ط¹ط§ط¯ظٹ â•گâ•گâ•گ
    else {
      String value;
      if (existing.containsKey(key)) {
        // ط§ظ„طھط±ط¬ظ…ط© ظ…ظˆط¬ظˆط¯ط© â†’ ظ†ط­طھظپط¸ ط¨ظ‡ط§
        value = _escapeJson(existing[key].toString());
      } else {
        // طھط±ط¬ظ…ط© ط¬ط¯ظٹط¯ط© ظ…ط·ظ„ظˆط¨ط©
        value = '[$lang] $key';
      }
      buffer.write('  "$key": "$value"');
    }

    // ط§ظ„ظپط§طµظ„ط©
    if (!isLast) {
      buffer.writeln(',');
    } else {
      buffer.writeln('');
    }
  }

  buffer.writeln('}');
  return buffer.toString();
}

/// طھظ‡ط±ظٹط¨ ط§ظ„ط£ط­ط±ظپ ط§ظ„ط®ط§طµط© ظپظٹ JSON
String _escapeJson(String text) {
  return text
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\r')
      .replaceAll('\t', '\\t');
}