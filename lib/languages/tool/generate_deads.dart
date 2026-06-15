import 'dart:convert';
import 'dart:io';

/// جميع اللغات التي تدعمها (بدون ar لأنه الأساس)
const languages = [
  'en',  // English - الإنجليزية
  'fr',  // Français - الفرنسية
  'de',  // Deutsch - الألمانية
  'es',  // Español - الإسبانية
  'it',  // Italiano - الإيطالية
  'pt',  // Português - البرتغالية
  'nl',  // Nederlands - الهولندية
  'ru',  // Русский - الروسية
  'tr',  // Türkçe - التركية
  'ur',  // اردو - الأوردية
  'id',  // Bahasa Indonesia - الإندونيسية
  'ms',  // Bahasa Melayu - الملايوية
  'hi',  // हिन्दी - الهندية
  'ja',  // 日本語 - اليابانية
  'zh',  // 中文 - الصينية
  'uz',  // Oʻzbekcha - الأوزبكية
  'sw',  // Kiswahili - السواحيلية
  'ha',  // Hausa - الهوسا
  'am',  // አማርኛ - الأمهرية
  'so',  // Soomaali - الصومالية
];

void main() async {
  final baseFile = File('assets/deeds/deeds_ar.json');

  if (!baseFile.existsSync()) {
    print('❌ ملف ar.json غير موجود');
    return;
  }

  final Map<String, dynamic> baseContent =
  jsonDecode(baseFile.readAsStringSync());

  print('📋 عدد المفاتيح في ar.json: ${baseContent.length}');
  print('─' * 50);

  for (final lang in languages) {
    final file = File('assets/deeds/deeds_$lang.json');

    if (!file.existsSync()) {
      // ═══ إنشاء ملف جديد ═══
      final newContent = _generateJsonWithComments(baseContent, lang, {});
      file.writeAsStringSync(newContent);
      print('✅ تم إنشاء $lang.json');
    } else {
      // ═══ تحديث ملف موجود ═══
      final Map<String, dynamic> existing =
      jsonDecode(file.readAsStringSync());

      int added = 0;
      int removed = 0;
      int kept = 0;

      // حساب الإحصائيات
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

      String status = (added > 0 || removed > 0) ? '⚡' : '🔄';
      print('$status $lang.json → '
          '✅ محفوظ: $kept | '
          '➕ جديد: $added | '
          '🗑️ محذوف: $removed');
    }
  }

  print('─' * 50);
  print('🎉 انتهى تحديث جميع الملفات!');
  print('');
  print('💡 المفاتيح الجديدة تبدأ بـ [lang] للتمييز');
  print('📝 التعليقات تبدأ بـ _comment_');
  print('📦 الأقسام تبدأ بـ __SECTION__');
}

/// توليد JSON مع التعليقات والفواصل
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

    // ═══ تعليق (سطر فارغ + تعليق) ═══
    if (key.startsWith('_comment_')) {
      buffer.writeln('');
      final comment = baseContent[key].toString();
      buffer.write('  "$key": "$comment"');
    }
    // ═══ فاصل قسم ═══
    else if (key.startsWith('__') && key.endsWith('__')) {
      buffer.writeln('');
      buffer.writeln('');
      final section = baseContent[key].toString();
      // ترجمة اسم القسم أو إبقاءه
      final translatedSection = existing[key]?.toString() ?? section;
      buffer.write('  "$key": "$translatedSection"');
    }
    // ═══ مفتاح عادي ═══
    else {
      String value;
      if (existing.containsKey(key)) {
        // الترجمة موجودة → نحتفظ بها
        value = _escapeJson(existing[key].toString());
      } else {
        // ترجمة جديدة مطلوبة
        value = '[$lang] $key';
      }
      buffer.write('  "$key": "$value"');
    }

    // الفاصلة
    if (!isLast) {
      buffer.writeln(',');
    } else {
      buffer.writeln('');
    }
  }

  buffer.writeln('}');
  return buffer.toString();
}

/// تهريب الأحرف الخاصة في JSON
String _escapeJson(String text) {
  return text
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\r')
      .replaceAll('\t', '\\t');
}