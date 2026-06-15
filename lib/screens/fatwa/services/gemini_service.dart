class GeminiService {
  static Future<List<String>> generateSearchQueries(String userQuestion) async {
    return [userQuestion];
  }

  static Future<String> summarizeFatwa({
    required String userQuestion,
    required String fatwaText,
    required String source,
  }) async {
    return fatwaText;
  }
}
