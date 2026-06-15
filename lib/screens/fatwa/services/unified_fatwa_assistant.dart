
import '../models/chat_message.dart';
import '../models/fatwa_model.dart';
import 'local_search_service.dart';

class UnifiedFatwaAssistant {
  static Future<ChatMessage> getAnswer({
    required String userQuestion,
    required List<Fatwa> localFatawa,
  }) async {
    if (userQuestion.trim().isEmpty) {
      return ChatMessage.fromAssistantText(
        'أهلاً بك، اكتب سؤالك الشرعي وسأبحث لك بإذن الله.',
      );
    }

    return await LocalSearchService.search(userQuestion);
  }

  static Future<ChatMessage> onSourceSelected(
      String question,
      SourceOption selected,
      List<SourceOption> allOptions,
      ) async {
    return await LocalSearchService.onSourceSelected(
      question, selected, allOptions,
    );
  }
}