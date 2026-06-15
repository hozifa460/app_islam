
import '../models/chat_message.dart';
import '../models/fatwa_model.dart';
import 'advanced_search_service.dart';

class FatwaAssistantService {

  static Future<ChatMessage> getAnswer({
    required String userQuestion,
    required List<Fatwa> fatawa,
  }) async {
    final cleanQuestion = _cleanQuestion(userQuestion);

    final results = await AdvancedSearchService.search(
      cleanQuestion,
      fatawa,
      topK: 5,
    );

    if (results.isEmpty) {
      return ChatMessage.fromAssistantText(
        'لم أجد فتوى في المصادر المتاحة تجيب على سؤالك.\n'
            'أنصحك بسؤال أهل العلم مباشرة.',
      );
    }

    final bestResult = results.first;
    final fatwa = bestResult.fatwa;
    final score = bestResult.relevanceScore;

    // ═══════════════════════════════════════
    // الفلتر الصارم: 3 شروط يجب تحققها كلها
    // ═══════════════════════════════════════

    // الشرط 1: النقطة يجب أن تكون عالية
    if (score < 8.0) {
      return ChatMessage.fromAssistantText(
        'لم أجد فتوى صريحة مطابقة لسؤالك في المصادر المتاحة.\n'
            'أنصحك بسؤال أهل العلم مباشرة.',
      );
    }

    // الشرط 2: يجب أن تحتوي الفتوى على كلمات مهمة من السؤال
    final importantWords = _getImportantWords(cleanQuestion);
    final fatwaText = _normalize(
        '${fatwa.question} ${fatwa.answer}'
    );

    int matchedCount = 0;
    for (var word in importantWords) {
      if (fatwaText.contains(word)) {
        matchedCount++;
      }
    }

    // يجب تطابق نصف الكلمات المهمة على الأقل
    if (importantWords.isNotEmpty) {
      double matchRatio = matchedCount / importantWords.length;
      if (matchRatio < 0.4) {
        return ChatMessage.fromAssistantText(
          'لم أجد فتوى مطابقة لسؤالك في المصادر الحالية.\n'
              'أنصحك بسؤال أهل العلم مباشرة.',
        );
      }
    }

    // الشرط 3: تحقق يدوي من التشابه الفعلي
    if (!_isActuallyRelevant(cleanQuestion, fatwa)) {
      return ChatMessage.fromAssistantText(
        'وجدت بعض النتائج لكنها لا تتعلق بسؤالك بشكل مباشر.\n'
            'أنصحك بسؤال أهل العلم مباشرة.',
      );
    }

    // ═══════════════════════════════════════
    // الفتوى مطابقة فعلاً، نعرضها
    // ═══════════════════════════════════════
    final confidence = _getConfidence(score, matchedCount, importantWords.length);

    final introText = _buildIntroText(
      fatwa: fatwa,
      confidence: confidence,
    );

    return ChatMessage.fromAssistantWithSource(
      introText: introText,
      fatwa: fatwa,
      extractedAnswer: fatwa.answer,
      confidence: confidence,
    );
  }

  // ═══════════════════════════════════════
  // تحقق يدوي من التشابه الفعلي
  // ═══════════════════════════════════════
  static bool _isActuallyRelevant(String question, Fatwa fatwa) {
    final qWords = _getImportantWords(question);
    final fQuestion = _normalize(fatwa.question);
    final fAnswer = _normalize(fatwa.answer);
    final fAll = '$fQuestion $fAnswer';

    if (qWords.isEmpty) return false;

    // عدّ الكلمات المهمة الموجودة فعلاً
    int strongMatches = 0;
    for (var word in qWords) {
      // كلمة طويلة (4+ حروف) = تطابق قوي
      if (word.length >= 4 && fAll.contains(word)) {
        strongMatches++;
      }
      // كلمة قصيرة لكنها موجودة في السؤال الأصلي = تطابق قوي
      else if (word.length >= 3 && fQuestion.contains(word)) {
        strongMatches++;
      }
    }

    // يجب وجود كلمتين مهمتين على الأقل
    return strongMatches >= 2;
  }

  // ═══════════════════════════════════════
  // استخراج الكلمات المهمة فقط
  // ═══════════════════════════════════════
  static List<String> _getImportantWords(String question) {
    // كلمات عامة جداً موجودة في كل الفتاوى
    const generalWords = {
      'هل', 'ما', 'من', 'في', 'على', 'عن', 'الى', 'مع',
      'يجوز', 'حكم', 'يمكن', 'كيف', 'متى', 'لماذا', 'هو',
      'هي', 'ان', 'كان', 'لا', 'لم', 'قد', 'او', 'ثم',
      'هذا', 'هذه', 'ذلك', 'التي', 'الذي', 'بين',
      'الله', 'رسول', 'النبي', 'صلى', 'عليه', 'وسلم',
      'شيخ', 'فضيلة', 'سؤال', 'جواب', 'الاسلام',
      'عمل', 'قال', 'يقول', 'كل', 'بعض', 'اي',
      'وما', 'ومن', 'وهل', 'فما', 'فهل',
      'شخص', 'انسان', 'رجل', 'امراة', 'ناس', 'احد',
    };

    final normalized = _normalize(question);

    return normalized
        .split(RegExp(r'[\s،؟!.,؛:()]+'))
        .map((w) => w.trim())
        .where((w) => w.length > 2 && !generalWords.contains(w))
        .toList();
  }

  // ═══════════════════════════════════════
  // تنظيف النص العربي
  // ═══════════════════════════════════════
  static String _normalize(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll(RegExp(r'[ًٌٍَُِّْٰ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ═══════════════════════════════════════
  // تنظيف سؤال المستخدم
  // ═══════════════════════════════════════
  static String _cleanQuestion(String question) {
    final dialectMap = {
      'وش': 'ما',
      'ايش': 'ما',
      'ليش': 'لماذا',
      'بالصلاة': 'في الصلاه',
      'بالصيام': 'في الصيام',
      'اللي': 'الذي',
      'يقدر': 'يستطيع',
      'لازم': 'يجب',
      'ما يجوز': 'لا يجوز',
    };

    String cleaned = question;
    for (var entry in dialectMap.entries) {
      cleaned = cleaned.replaceAll(entry.key, entry.value);
    }
    return cleaned;
  }

  // ═══════════════════════════════════════
  // تحديد الثقة بناءً على التطابق الفعلي
  // ═══════════════════════════════════════
  static AnswerConfidence _getConfidence(
      double score,
      int matchedWords,
      int totalImportantWords,
      ) {
    if (totalImportantWords == 0) return AnswerConfidence.low;

    double matchRatio = matchedWords / totalImportantWords;

    if (score >= 15.0 && matchRatio >= 0.7) {
      return AnswerConfidence.high;
    }
    if (score >= 10.0 && matchRatio >= 0.5) {
      return AnswerConfidence.medium;
    }
    return AnswerConfidence.low;
  }

  // ═══════════════════════════════════════
  // بناء النص التمهيدي
  // ═══════════════════════════════════════
  static String _buildIntroText({
    required Fatwa fatwa,
    required AnswerConfidence confidence,
  }) {
    switch (confidence) {
      case AnswerConfidence.high:
        return 'وجدت فتوى مطابقة لسؤالك في كتاب '
            '"${fatwa.book}" '
            'للشيخ ${fatwa.scholar} رحمه الله، '
            'وهذا نصها:';

      case AnswerConfidence.medium:
        return 'وجدت هذه الفتوى في كتاب '
            '"${fatwa.book}" '
            'للشيخ ${fatwa.scholar}، '
            'وأرى أنها الأقرب لسؤالك:';

      case AnswerConfidence.low:
        return 'لم أجد فتوى مطابقة تماماً، '
            'لكن هذه الفتوى من كتاب '
            '"${fatwa.book}" '
            'قد تكون ذات صلة:';

      default:
        return 'هذا ما وجدته:';
    }
  }
}