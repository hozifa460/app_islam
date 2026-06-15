import 'fatwa_model.dart';

enum MessageType {
  user,
  assistant,
  loading,
  notFound,
}

enum AnswerConfidence {
  high,
  medium,
  low,
  none,
}

class SourceOption {
  final String sourceName;
  final String title;
  final String answer;
  final String url;
  final double relevance;
  final Fatwa fatwa;

  SourceOption({
    required this.sourceName,
    required this.title,
    required this.answer,
    required this.url,
    required this.relevance,
    required this.fatwa,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final Fatwa? sourceFatwa;
  final AnswerConfidence confidence;
  final String introText;
  final String extractedAnswer;
  final List<SourceOption> sourceOptions;

  ChatMessage({
    required this.id,
    required this.text,
    required this.type,
    required this.timestamp,
    this.sourceFatwa,
    this.confidence = AnswerConfidence.none,
    this.introText = '',
    this.extractedAnswer = '',
    this.sourceOptions = const [],
  });

  factory ChatMessage.fromUser(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading',
      text: 'جاري البحث في المصادر...',
      type: MessageType.loading,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.fromAssistantText(String message) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      type: MessageType.notFound,
      timestamp: DateTime.now(),
      introText: message,
    );
  }

  factory ChatMessage.fromAssistantWithSource({
    required String introText,
    required Fatwa fatwa,
    required String extractedAnswer,
    required AnswerConfidence confidence,
    List<SourceOption> otherSources = const [],
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: extractedAnswer,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      sourceFatwa: fatwa,
      confidence: confidence,
      introText: introText,
      extractedAnswer: extractedAnswer,
      sourceOptions: otherSources,
    );
  }

  factory ChatMessage.chooseSource({
    required List<SourceOption> sources,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      introText: 'وجدت نتائج من ${sources.length} مصادر.\n'
          'اختر المصدر:',
      sourceOptions: sources,
    );
  }

  factory ChatMessage.welcome() {
    return ChatMessage(
      id: 'welcome',
      text: '',
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      introText: 'السلام عليكم ورحمة الله وبركاته 👋\n\n'
          'أنا مساعد الفتاوى الذكي.\n'
          'أبحث لك في آلاف الفتاوى من:\n\n'
          '📚 إسلام سؤال وجواب\n'
          '📚 موقع الشيخ ابن باز\n'
          '📚 الدرر السنية\n\n'
          '⚠️ أنا لا أفتي بل أنقل الفتوى من مصدرها.\n'
          'اكتب سؤالك بأي طريقة وسأفهمه بإذن الله.',
    );
  }
}