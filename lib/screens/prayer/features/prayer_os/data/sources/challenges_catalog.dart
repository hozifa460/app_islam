import '../models/challenge.dart';
import 'package:flutter/material.dart';

/// كتالوج التحديات اليومية
const List<DailyChallenge> challengesCatalog = [
  // ───────────────────────────────
  // تحديات سهلة
  // ───────────────────────────────
  DailyChallenge(
    id: 'pray_all_today',
    title: 'المحافظ',
    description: 'صلِّ جميع الصلوات الخمس اليوم',
    islamicMotivation: 'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ',
    icon: Icons.check_circle,
    type: ChallengeType.prayer,
    difficulty: ChallengeDifficulty.easy,
    targetValue: 5,
    noorReward: 100,
  ),

  DailyChallenge(
    id: 'fajr_on_time',
    title: 'صاحب الفجر',
    description: 'صلِّ الفجر في وقته اليوم',
    islamicMotivation: 'إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا',
    icon: Icons.wb_twilight,
    type: ChallengeType.prayer,
    difficulty: ChallengeDifficulty.easy,
    targetValue: 1,
    noorReward: 50,
  ),

  DailyChallenge(
    id: 'say_adhkar',
    title: 'الذاكر',
    description: 'قل أذكار ما بعد الصلاة في صلاة واحدة على الأقل',
    islamicMotivation: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    icon: Icons.auto_awesome,
    type: ChallengeType.dhikr,
    difficulty: ChallengeDifficulty.easy,
    targetValue: 1,
    noorReward: 30,
  ),

  // ───────────────────────────────
  // تحديات متوسطة
  // ───────────────────────────────
  DailyChallenge(
    id: 'all_on_time',
    title: 'الحريص',
    description: 'صلِّ جميع الصلوات في أول وقتها اليوم',
    islamicMotivation: 'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
    icon: Icons.access_time_filled,
    type: ChallengeType.prayer,
    difficulty: ChallengeDifficulty.medium,
    targetValue: 5,
    noorReward: 200,
  ),

  DailyChallenge(
    id: 'pray_sunnah',
    title: 'صاحب الرواتب',
    description: 'صلِّ السنن الرواتب كاملة اليوم (12 ركعة)',
    islamicMotivation: 'مَا مِنْ عَبْدٍ يُصَلِّي لِلَّهِ تَعَالَى كُلَّ يَوْمٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً تَطَوُّعًا إِلَّا بَنَى اللَّهُ لَهُ بَيْتًا فِي الْجَنَّةِ',
    icon: Icons.home,
    type: ChallengeType.sunnah,
    difficulty: ChallengeDifficulty.medium,
    targetValue: 12,
    noorReward: 150,
  ),

  // ───────────────────────────────
  // تحديات صعبة
  // ───────────────────────────────
  DailyChallenge(
    id: 'perfect_day',
    title: 'اليوم المثالي',
    description: 'يوم كامل: كل الصلوات في وقتها + السنن + الأذكار',
    islamicMotivation: 'وَمَنْ أَحْسَنُ قَوْلًا مِّمَّن دَعَا إِلَى اللَّهِ وَعَمِلَ صَالِحًا',
    icon: Icons.workspace_premium,
    type: ChallengeType.special,
    difficulty: ChallengeDifficulty.hard,
    targetValue: 1,
    noorReward: 500,
  ),

  DailyChallenge(
    id: 'all_mosque',
    title: 'قلب معلق',
    description: 'صلِّ جميع الصلوات الخمس في المسجد اليوم',
    islamicMotivation: 'وَرَجُلٌ قَلْبُهُ مُعَلَّقٌ بِالْمَسَاجِدِ',
    icon: Icons.favorite_border,
    type: ChallengeType.mosque,
    difficulty: ChallengeDifficulty.hard,
    targetValue: 5,
    noorReward: 400,
  ),
];

/// البحث عن تحدي بالـ ID
DailyChallenge? findChallengeById(String id) {
  try {
    return challengesCatalog.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

/// جلب 3 تحديات يومية عشوائية (متنوعة)
List<DailyChallenge> getTodaysChallenges() {
  final now = DateTime.now();
  final seed = now.year * 10000 + now.month * 100 + now.day;

  final daily = challengesCatalog.where((c) => c.isDaily).toList();

  final indices = <int>[];
  for (int i = 0; i < 3; i++) {
    indices.add((seed + i * 7) % daily.length);
  }

  return indices.map((i) => daily[i]).toList();
}