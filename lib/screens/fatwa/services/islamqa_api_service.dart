import 'package:http/http.dart' as http;

class IslamQAResult {
  final String title;
  final String question;
  final String answer;
  final String source;
  final String url;
  final double relevance;

  IslamQAResult({
    required this.title,
    required this.question,
    required this.answer,
    required this.source,
    required this.url,
    this.relevance = 0.0,
  });

  IslamQAResult copyWith({
    String? title,
    String? question,
    String? answer,
    String? source,
    String? url,
    double? relevance,
  }) {
    return IslamQAResult(
      title: title ?? this.title,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      source: source ?? this.source,
      url: url ?? this.url,
      relevance: relevance ?? this.relevance,
    );
  }
}

class IslamQAApiService {
  // ══════════════════════════════════════
  // البحث في إسلام سؤال وجواب عبر DuckDuckGo HTML
  // ══════════════════════════════════════
  static Future<List<IslamQAResult>> searchIslamQA(String query) async {
    try {
      final searchQuery = Uri.encodeComponent(
        'site:islamqa.info/ar/answers $query',
      );

      final searchUrl = 'https://html.duckduckgo.com/html/?q=$searchQuery';

      print('🔍 جاري البحث عبر DuckDuckGo: $searchUrl');

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Status: ${response.statusCode}');
      print('📝 Body length: ${response.body.length}');

      if (response.statusCode != 200 || response.body.isEmpty) {
        return [];
      }

      final links = _extractDuckDuckGoLinks(response.body);

      print('📎 تم العثور على ${links.length} رابط فتوى من DuckDuckGo');

      if (links.isEmpty) return [];

      final results = <IslamQAResult>[];

      for (final link in links.take(3)) {
        final fatwa = await _fetchFullFatwa(
          link['url']!,
          link['title']!,
        );
        if (fatwa != null) {
          results.add(fatwa);
        }
      }

      return results;
    } catch (e) {
      print('❌ searchIslamQA error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════
  // استخراج روابط نتائج DuckDuckGo
  // ══════════════════════════════════════
  static List<Map<String, String>> _extractDuckDuckGoLinks(String html) {
    final results = <Map<String, String>>[];

    final pattern = RegExp(
      r'<a[^>]*class="[^"]*result__a[^"]*"[^>]*href="([^"]+)"[^>]*>(.*?)</a>',
      dotAll: true,
    );

    for (final match in pattern.allMatches(html)) {
      final rawHref = match.group(1) ?? '';
      final rawTitle = match.group(2) ?? '';

      final title = _cleanHtml(rawTitle);
      final decodedUrl = _decodeDuckDuckGoUrl(rawHref);

      if (decodedUrl.contains('islamqa.info/ar/answers/') &&
          title.isNotEmpty &&
          title.length > 5) {
        if (!results.any((e) => e['url'] == decodedUrl)) {
          results.add({
            'url': decodedUrl,
            'title': title,
          });
          print('  📎 وجد: $title');
        }
      }

      if (results.length >= 5) break;
    }

    return results;
  }

  // ══════════════════════════════════════
  // فك رابط DuckDuckGo
  // ══════════════════════════════════════
  static String _decodeDuckDuckGoUrl(String href) {
    try {
      String normalized = href;
      if (href.startsWith('//')) {
        normalized = 'https:$href';
      } else if (href.startsWith('/')) {
        normalized = 'https://duckduckgo.com$href';
      }

      final uri = Uri.parse(normalized);
      final uddg = uri.queryParameters['uddg'];

      if (uddg != null && uddg.isNotEmpty) {
        return Uri.decodeFull(uddg);
      }

      return normalized;
    } catch (_) {
      return href;
    }
  }

  // ══════════════════════════════════════
  // جلب الفتوى كاملة من صفحة إسلام سؤال وجواب
  // ══════════════════════════════════════
  static Future<IslamQAResult?> _fetchFullFatwa(
      String url,
      String fallbackTitle,
      ) async {
    try {
      print('📖 جاري جلب الفتوى: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 || response.body.isEmpty) {
        return null;
      }

      final html = response.body;

      String title = _extractTitle(html);
      if (title.isEmpty) {
        title = fallbackTitle;
      }

      String answer = _extractFatwaText(html);

      if (answer.isEmpty || answer.length < 80) {
        return null;
      }

      return IslamQAResult(
        title: title,
        question: title,
        answer: answer,
        source: 'إسلام سؤال وجواب',
        url: url,
      );
    } catch (e) {
      print('❌ _fetchFullFatwa error: $e');
      return null;
    }
  }

  // ══════════════════════════════════════
  // استخراج العنوان
  // ══════════════════════════════════════
  static String _extractTitle(String html) {
    final patterns = [
      RegExp(r'<title>(.*?)</title>', dotAll: true),
      RegExp(r'<h1[^>]*>(.*?)</h1>', dotAll: true),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(html);
      if (match != null) {
        final title = _cleanHtml(match.group(1) ?? '')
            .replaceAll(' - الإسلام سؤال وجواب', '')
            .trim();
        if (title.isNotEmpty) return title;
      }
    }

    return '';
  }

  // ══════════════════════════════════════
  // استخراج نص الفتوى
  // ══════════════════════════════════════
  static String _extractFatwaText(String html) {
    String cleaned = html;

    // إزالة السكربتات والستايلات
    cleaned = cleaned.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<nav[^>]*>.*?</nav>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<header[^>]*>.*?</header>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<footer[^>]*>.*?</footer>', dotAll: true),
      '',
    );

    // استخراج الفقرات
    final pPattern = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);
    final paragraphs = <String>[];

    for (final match in pPattern.allMatches(cleaned)) {
      final text = _cleanHtml(match.group(1) ?? '');
      if (text.length > 30) {
        paragraphs.add(text);
      }
    }

    if (paragraphs.isNotEmpty) {
      String result = paragraphs.join('\n\n');

      if (result.length > 2500) {
        result = '${result.substring(0, 2500)}...';
      }

      return result.trim();
    }

    // fallback
    final bodyText = _cleanHtml(cleaned);
    if (bodyText.length > 2500) {
      return '${bodyText.substring(0, 2500)}...';
    }
    return bodyText.trim();
  }

  // ══════════════════════════════════════
  // تنظيف HTML
  // ══════════════════════════════════════
  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ══════════════════════════════════════
  // البحث في إسلام ويب عبر DuckDuckGo HTML
  // ══════════════════════════════════════
  static Future<List<IslamQAResult>> searchIslamWeb(String query) async {
    try {
      final searchQuery = Uri.encodeComponent(
        'site:islamweb.net/ar/fatwa $query',
      );

      final searchUrl = 'https://html.duckduckgo.com/html/?q=$searchQuery';

      print('🔍 جاري البحث في إسلام ويب عبر DuckDuckGo...');
      print('🔗 $searchUrl');

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 IslamWeb Status: ${response.statusCode}');
      print('📝 IslamWeb Body length: ${response.body.length}');

      if (response.statusCode != 200 || response.body.isEmpty) {
        return [];
      }

      final links = _extractDuckDuckGoDomainLinks(
        response.body,
        domainMustContain: 'islamweb.net',
        pathMustContain: '/ar/fatwa/',
      );

      print('📎 تم العثور على ${links.length} رابط فتوى من إسلام ويب');

      if (links.isEmpty) return [];

      final results = <IslamQAResult>[];

      for (final link in links.take(3)) {
        final fatwa = await _fetchFullIslamWebFatwa(
          link['url']!,
          link['title']!,
        );
        if (fatwa != null) {
          results.add(fatwa);
        }
      }

      return results;
    } catch (e) {
      print('❌ searchIslamWeb error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════
  // استخراج روابط DuckDuckGo بحسب دومين ومسار محدد
  // ══════════════════════════════════════
  static List<Map<String, String>> _extractDuckDuckGoDomainLinks(
      String html, {
        required String domainMustContain,
        required String pathMustContain,
      }) {
    final results = <Map<String, String>>[];

    final pattern = RegExp(
      r'<a[^>]*class="[^"]*result__a[^"]*"[^>]*href="([^"]+)"[^>]*>(.*?)</a>',
      dotAll: true,
    );

    for (final match in pattern.allMatches(html)) {
      final rawHref = match.group(1) ?? '';
      final rawTitle = match.group(2) ?? '';

      final title = _cleanHtml(rawTitle);
      final decodedUrl = _decodeDuckDuckGoUrl(rawHref);

      if (decodedUrl.contains(domainMustContain) &&
          decodedUrl.contains(pathMustContain) &&
          title.isNotEmpty &&
          title.length > 5) {
        if (!results.any((e) => e['url'] == decodedUrl)) {
          results.add({
            'url': decodedUrl,
            'title': title,
          });
          print('  📎 وجد: $title');
        }
      }

      if (results.length >= 5) break;
    }

    return results;
  }

  // ══════════════════════════════════════
  // جلب الفتوى كاملة من إسلام ويب
  // ══════════════════════════════════════
  static Future<IslamQAResult?> _fetchFullIslamWebFatwa(
      String url,
      String fallbackTitle,
      ) async {
    try {
      print('📖 جاري جلب فتوى إسلام ويب: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 || response.body.isEmpty) {
        return null;
      }

      final html = response.body;

      String title = _extractIslamWebTitle(html);
      if (title.isEmpty) {
        title = fallbackTitle;
      }

      final qa = _extractIslamWebQuestionAnswer(html);
      String question = qa['question'] ?? title;
      String answer = qa['answer'] ?? '';

      if (answer.isEmpty || answer.length < 60) {
        answer = _extractGenericParagraphs(html);
      }

      answer = _trimAtMarkers(answer, [
        'مواد ذات صلة',
        'اقرأ أيضا',
        'المزيد من الفتاوى',
        'انظر أيضا',
      ]);

      if (answer.isEmpty || answer.length < 60) {
        return null;
      }

      if (answer.length > 2500) {
        answer = '${answer.substring(0, 2500)}...';
      }

      return IslamQAResult(
        title: title,
        question: question,
        answer: answer,
        source: 'إسلام ويب',
        url: url,
      );
    } catch (e) {
      print('❌ _fetchFullIslamWebFatwa error: $e');
      return null;
    }
  }

  // ══════════════════════════════════════
  // استخراج عنوان فتوى إسلام ويب
  // ══════════════════════════════════════
  static String _extractIslamWebTitle(String html) {
    final patterns = [
      RegExp(r'<title>(.*?)</title>', dotAll: true),
      RegExp(r'<h1[^>]*>(.*?)</h1>', dotAll: true),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(html);
      if (match != null) {
        final title = _cleanHtml(match.group(1) ?? '')
            .replaceAll(' - إسلام ويب - مركز الفتوى', '')
            .replaceAll(' - إسلام ويب', '')
            .trim();
        if (title.isNotEmpty) return title;
      }
    }

    return '';
  }

  // ══════════════════════════════════════
  // استخراج السؤال والجواب من فتوى إسلام ويب
  // ══════════════════════════════════════
  static Map<String, String> _extractIslamWebQuestionAnswer(String html) {
    final stripped = _stripHtmlBoilerplate(html);
    final fullText = _cleanHtml(stripped);

    // إسلام ويب غالبًا فيه "السؤال" ثم "الإجابــة"
    final patterns = [
      RegExp(r'السؤال\s*(.*?)\s*الإجاب(?:ة|ــة)\s*(.*)', dotAll: true),
      RegExp(r'السؤال\s*(.*?)\s*الاجابة\s*(.*)', dotAll: true),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(fullText);
      if (match != null) {
        final question = (match.group(1) ?? '').trim();
        final answer = (match.group(2) ?? '').trim();

        if (question.length > 5 && answer.length > 30) {
          return {
            'question': question,
            'answer': answer,
          };
        }
      }
    }

    return {};
  }

  // ══════════════════════════════════════
  // استخراج الفقرات العامة كخطة احتياطية
  // ══════════════════════════════════════
  static String _extractGenericParagraphs(String html) {
    final cleaned = _stripHtmlBoilerplate(html);
    final pPattern = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);
    final paragraphs = <String>[];

    for (final match in pPattern.allMatches(cleaned)) {
      final text = _cleanHtml(match.group(1) ?? '');
      if (text.length > 25) {
        paragraphs.add(text);
      }
    }

    if (paragraphs.isNotEmpty) {
      return paragraphs.join('\n\n').trim();
    }

    return _cleanHtml(cleaned);
  }

  // ══════════════════════════════════════
  // إزالة العناصر غير المهمة من الصفحة
  // ══════════════════════════════════════
  static String _stripHtmlBoilerplate(String html) {
    String cleaned = html;

    cleaned = cleaned.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<nav[^>]*>.*?</nav>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<header[^>]*>.*?</header>', dotAll: true),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<footer[^>]*>.*?</footer>', dotAll: true),
      '',
    );

    return cleaned;
  }

  // ══════════════════════════════════════
  // قص النص عند عبارات لاحقة غير مفيدة
  // ══════════════════════════════════════
  static String _trimAtMarkers(String text, List<String> markers) {
    String result = text;
    for (final marker in markers) {
      if (result.contains(marker)) {
        result = result.split(marker).first.trim();
      }
    }
    return result;
  }

  // ══════════════════════════════════════
  // البحث في موقع الشيخ ابن باز
  // ══════════════════════════════════════
  static Future<List<IslamQAResult>> searchBinBaz(String query) async {
    try {
      final searchQuery = Uri.encodeComponent(
        'site:binbaz.org.sa $query',
      );
      final searchUrl = 'https://html.duckduckgo.com/html/?q=$searchQuery';

      print('🔍 جاري البحث في موقع ابن باز...');

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 || response.body.isEmpty) return [];

      final links = _extractDuckDuckGoDomainLinks(
        response.body,
        domainMustContain: 'binbaz.org.sa',
        pathMustContain: '/',
      );

      print('📎 ابن باز: ${links.length} رابط');

      final results = <IslamQAResult>[];
      for (final link in links.take(3)) {
        final fatwa = await _fetchGenericFatwa(
          link['url']!,
          link['title']!,
          'موقع الشيخ ابن باز',
        );
        if (fatwa != null) results.add(fatwa);
      }

      return results;
    } catch (e) {
      print('❌ searchBinBaz error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════
  // البحث في موقع الشيخ ابن عثيمين
  // ══════════════════════════════════════
  static Future<List<IslamQAResult>> searchBinOthaimeen(String query) async {
    try {
      final searchQuery = Uri.encodeComponent(
        'site:binothaimeen.net $query',
      );
      final searchUrl = 'https://html.duckduckgo.com/html/?q=$searchQuery';

      print('🔍 جاري البحث في موقع ابن عثيمين...');

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 || response.body.isEmpty) return [];

      final links = _extractDuckDuckGoDomainLinks(
        response.body,
        domainMustContain: 'binothaimeen.net',
        pathMustContain: '/',
      );

      print('📎 ابن عثيمين: ${links.length} رابط');

      final results = <IslamQAResult>[];
      for (final link in links.take(3)) {
        final fatwa = await _fetchGenericFatwa(
          link['url']!,
          link['title']!,
          'موقع الشيخ ابن عثيمين',
        );
        if (fatwa != null) results.add(fatwa);
      }

      return results;
    } catch (e) {
      print('❌ searchBinOthaimeen error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════
  // البحث في حراس العقيدة
  // ══════════════════════════════════════
  static Future<List<IslamQAResult>> searchHorasAlAqidah(String query) async {
    try {
      final searchQuery = Uri.encodeComponent(
        'site:al-aqidah.com $query',
      );
      final searchUrl = 'https://html.duckduckgo.com/html/?q=$searchQuery';

      print('🔍 جاري البحث في حراس العقيدة...');

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 || response.body.isEmpty) return [];

      final links = _extractDuckDuckGoDomainLinks(
        response.body,
        domainMustContain: 'al-aqidah.com',
        pathMustContain: '/',
      );

      print('📎 حراس العقيدة: ${links.length} رابط');

      final results = <IslamQAResult>[];
      for (final link in links.take(3)) {
        final fatwa = await _fetchGenericFatwa(
          link['url']!,
          link['title']!,
          'حراس العقيدة',
        );
        if (fatwa != null) results.add(fatwa);
      }

      return results;
    } catch (e) {
      print('❌ searchHorasAlAqidah error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════
  // جلب فتوى من أي موقع عام
  // ══════════════════════════════════════
  static Future<IslamQAResult?> _fetchGenericFatwa(
      String url,
      String fallbackTitle,
      String sourceName,
      ) async {
    try {
      print('📖 جاري جلب: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 || response.body.isEmpty) return null;

      final html = response.body;

      // استخراج العنوان
      String title = '';
      final titlePatterns = [
        RegExp(r'<title>(.*?)</title>', dotAll: true),
        RegExp(r'<h1[^>]*>(.*?)</h1>', dotAll: true),
        RegExp(r'<h2[^>]*>(.*?)</h2>', dotAll: true),
      ];

      for (final p in titlePatterns) {
        final match = p.firstMatch(html);
        if (match != null) {
          title = _cleanHtml(match.group(1) ?? '').trim();
          if (title.isNotEmpty && title.length > 5) break;
        }
      }

      if (title.isEmpty) title = fallbackTitle;

      // استخراج المحتوى
      String content = _extractGenericContent(html);

      if (content.isEmpty || content.length < 60) return null;

      // تنظيف
      content = _removeBoilerplate(content, sourceName);

      if (content.length > 2500) {
        content = '${content.substring(0, 2500)}...';
      }

      print('✅ تم جلب: ${title.substring(0, title.length.clamp(0, 50))}');

      return IslamQAResult(
        title: title,
        question: title,
        answer: content,
        source: sourceName,
        url: url,
      );
    } catch (e) {
      print('❌ _fetchGenericFatwa error: $e');
      return null;
    }
  }

  // ══════════════════════════════════════
  // استخراج المحتوى العام من أي صفحة
  // ══════════════════════════════════════
  static String _extractGenericContent(String html) {
    // إزالة العناصر غير المهمة
    String cleaned = html;

    cleaned = cleaned.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<nav[^>]*>.*?</nav>', dotAll: true), '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<header[^>]*>.*?</header>', dotAll: true), '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<footer[^>]*>.*?</footer>', dotAll: true), '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<aside[^>]*>.*?</aside>', dotAll: true), '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<form[^>]*>.*?</form>', dotAll: true), '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<!--.*?-->', dotAll: true), '',
    );

    // محاولة 1: استخراج من article
    final articlePattern = RegExp(
      r'<article[^>]*>(.*?)</article>',
      dotAll: true,
    );
    final articleMatch = articlePattern.firstMatch(cleaned);
    if (articleMatch != null) {
      final text = _extractParagraphs(articleMatch.group(1) ?? '');
      if (text.length > 60) return text;
    }

    // محاولة 2: استخراج من div.content أو div.entry
    final divPatterns = [
      RegExp(r'<div[^>]*class="[^"]*(?:content|entry|fatwa|answer|post-body|article-body)[^"]*"[^>]*>(.*?)</div>\s*</div>', dotAll: true),
      RegExp(r'<div[^>]*class="[^"]*(?:content|entry|fatwa|answer)[^"]*"[^>]*>(.*?)</div>', dotAll: true),
    ];

    for (final p in divPatterns) {
      final match = p.firstMatch(cleaned);
      if (match != null) {
        final text = _extractParagraphs(match.group(1) ?? '');
        if (text.length > 60) return text;
      }
    }

    // محاولة 3: جمع كل الفقرات
    final text = _extractParagraphs(cleaned);
    if (text.length > 60) return text;

    // محاولة 4: النص الكامل بعد تنظيف HTML
    return _cleanHtml(cleaned);
  }

  // ══════════════════════════════════════
  // استخراج الفقرات من HTML
  // ══════════════════════════════════════
  static String _extractParagraphs(String html) {
    final pPattern = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);
    final paragraphs = <String>[];

    for (final match in pPattern.allMatches(html)) {
      final text = _cleanHtml(match.group(1) ?? '');
      if (text.length > 25) {
        paragraphs.add(text);
      }
    }

    return paragraphs.join('\n\n').trim();
  }

  // ══════════════════════════════════════
  // إزالة نصوص غير مرغوبة حسب المصدر
  // ══════════════════════════════════════
  static String _removeBoilerplate(String text, String source) {
    final unwanted = [
      RegExp(r'مشاركة.*?تويتر', dotAll: true),
      RegExp(r'شارك.*?فيسبوك', dotAll: true),
      RegExp(r'تم النشر.*?\d{4}', dotAll: true),
      RegExp(r'عدد الزيارات.*?\d+', dotAll: true),
      RegExp(r'التصنيف.*?\n', dotAll: true),
      RegExp(r'المصدر.*?\n', dotAll: true),
      RegExp(r'مواد ذات صلة.*', dotAll: true),
      RegExp(r'اقرأ أيضا.*', dotAll: true),
      RegExp(r'المزيد من الفتاوى.*', dotAll: true),
      RegExp(r'الرابط المختصر.*', dotAll: true),
      RegExp(r'حقوق النشر.*', dotAll: true),
      RegExp(r'جميع الحقوق.*', dotAll: true),
    ];

    String result = text;
    for (final pattern in unwanted) {
      result = result.replaceAll(pattern, '');
    }

    return result.trim();
  }

}