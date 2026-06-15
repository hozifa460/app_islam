import '../models/achievement.dart';
import 'package:flutter/material.dart';

/// كتالوج جميع الإنجازات الروحانية
final List<SpiritualAchievement> achievementsCatalog = [
  // ───────────────────────────────
  // إنجازات سلسلة الأيام (Streak)
  // ───────────────────────────────
  const SpiritualAchievement(
    id: 'streak_3',
    title: 'الانطلاقة',
    description: '3 أيام متواصلة من الصلوات الخمس',
    islamicQuote: 'أَحَبُّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
    quoteSource: 'متفق عليه',
    icon: Icons.rocket_launch,
    category: AchievementCategory.streak,
    tier: AchievementTier.bronze,
    requiredValue: 3,
    noorBonus: 50,
  ),

  const SpiritualAchievement(
    id: 'streak_7',
    title: 'أسبوع الثبات',
    description: 'أسبوع كامل من الالتزام بالصلوات الخمس',
    islamicQuote: 'مَنْ حَافَظَ عَلَى الصَّلَوَاتِ الْخَمْسِ كَانَتْ لَهُ نُورًا',
    quoteSource: 'رواه أحمد',
    icon: Icons.calendar_today,
    category: AchievementCategory.streak,
    tier: AchievementTier.bronze,
    requiredValue: 7,
    noorBonus: 100,
  ),

  const SpiritualAchievement(
    id: 'streak_21',
    title: 'بناء العادة',
    description: '21 يومًا - الصلاة أصبحت عادة',
    islamicQuote: 'إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ',
    quoteSource: 'العنكبوت: 45',
    icon: Icons.psychology,
    category: AchievementCategory.streak,
    tier: AchievementTier.silver,
    requiredValue: 21,
    noorBonus: 200,
  ),

  const SpiritualAchievement(
    id: 'streak_40',
    title: 'الأربعون يومًا',
    description: '40 يومًا من الصلاة - كما صبر موسى عليه السلام',
    islamicQuote: 'وَوَاعَدْنَا مُوسَىٰ ثَلَاثِينَ لَيْلَةً وَأَتْمَمْنَاهَا بِعَشْرٍ',
    quoteSource: 'الأعراف: 142',
    icon: Icons.auto_awesome,
    category: AchievementCategory.streak,
    tier: AchievementTier.gold,
    requiredValue: 40,
    noorBonus: 400,
  ),

  const SpiritualAchievement(
    id: 'streak_100',
    title: 'المئة يوم',
    description: '100 يوم من الثبات على الصلاة',
    islamicQuote: 'الصَّلَاةُ عِمَادُ الدِّينِ',
    quoteSource: 'حديث شريف',
    icon: Icons.military_tech,
    category: AchievementCategory.streak,
    tier: AchievementTier.platinum,
    requiredValue: 100,
    noorBonus: 1000,
  ),

  // ───────────────────────────────
  // إنجازات الفجر
  // ───────────────────────────────
  const SpiritualAchievement(
    id: 'fajr_7',
    title: 'صاحب الفجر',
    description: '7 صلوات فجر في وقتها',
    islamicQuote: 'إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا',
    quoteSource: 'الإسراء: 78',
    icon: Icons.wb_twilight,
    category: AchievementCategory.fajr,
    tier: AchievementTier.silver,
    requiredValue: 7,
    noorBonus: 150,
  ),

  const SpiritualAchievement(
    id: 'fajr_30',
    title: 'المستيقظ لله',
    description: '30 صلاة فجر في وقتها',
    islamicQuote: 'مَنْ صَلَّى الْبَرْدَيْنِ دَخَلَ الْجَنَّةَ',
    quoteSource: 'متفق عليه',
    icon: Icons.brightness_5,
    category: AchievementCategory.fajr,
    tier: AchievementTier.gold,
    requiredValue: 30,
    noorBonus: 500,
  ),

  // ───────────────────────────────
  // إنجازات المسجد
  // ───────────────────────────────
  const SpiritualAchievement(
    id: 'mosque_10',
    title: 'مرتاد المسجد',
    description: '10 صلوات في المسجد',
    islamicQuote: 'إِنَّمَا يَعْمُرُ مَسَاجِدَ اللَّهِ مَنْ آمَنَ بِاللَّهِ',
    quoteSource: 'التوبة: 18',
    icon: Icons.mosque,
    category: AchievementCategory.mosque,
    tier: AchievementTier.bronze,
    requiredValue: 10,
    noorBonus: 100,
  ),

  const SpiritualAchievement(
    id: 'mosque_50',
    title: 'قلب معلق بالمسجد',
    description: '50 صلاة في المسجد',
    islamicQuote: 'سَبْعَةٌ يُظِلُّهُمُ اللَّهُ... وَرَجُلٌ قَلْبُهُ مُعَلَّقٌ بِالْمَسَاجِدِ',
    quoteSource: 'متفق عليه',
    icon: Icons.favorite,
    category: AchievementCategory.mosque,
    tier: AchievementTier.gold,
    requiredValue: 50,
    noorBonus: 500,
  ),

  // ───────────────────────────────
  // إنجازات الخشوع
  // ───────────────────────────────
  const SpiritualAchievement(
    id: 'khushu_first',
    title: 'لحظة خشوع',
    description: 'أول صلاة تشعر فيها بالخشوع الحقيقي',
    islamicQuote: 'قَدْ أَفْلَحَ الْمُؤْمِنُونَ ۝ الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ',
    quoteSource: 'المؤمنون: 1-2',
    icon: Icons.favorite_border,
    category: AchievementCategory.khushu,
    tier: AchievementTier.silver,
    requiredValue: 1,
    noorBonus: 200,
  ),

  const SpiritualAchievement(
    id: 'khushu_10',
    title: 'الخاشع',
    description: '10 صلوات بخشوع',
    islamicQuote: 'إِنَّ اللَّهَ لَا يَنْظُرُ إِلَىٰ صُوَرِكُمْ... وَلَٰكِنْ يَنْظُرُ إِلَىٰ قُلُوبِكُمْ',
    quoteSource: 'رواه مسلم',
    icon: Icons.self_improvement,
    category: AchievementCategory.khushu,
    tier: AchievementTier.gold,
    requiredValue: 10,
    noorBonus: 500,
  ),
];

/// البحث عن إنجاز بالـ ID
SpiritualAchievement? findAchievementById(String id) {
  try {
    return achievementsCatalog.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}

/// جلب إنجازات فئة معينة
List<SpiritualAchievement> getAchievementsByCategory(
    AchievementCategory category) {
  return achievementsCatalog
      .where((a) => a.category == category)
      .toList();
}