class AIMemory {
  static int missedFajrCount = 0;
  static int missedTotal = 0;
  static int goodDays = 0;
  static int lastStreak = 0;
  static String lastEmotion = "neutral";

  static void resetDaily() {
    missedTotal = 0;
    goodDays = 0;
  }
}