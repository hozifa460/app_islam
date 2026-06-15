import 'package:flutter/material.dart';

/// محتوى روحاني لكل صلاة
class PrayerSpiritualContent {
  final String prayerKey;
  final List<QuoteItem> verses;
  final List<QuoteItem> hadiths;
  final List<String> tips;
  final List<String> duaAfter;
  final String meaning;

  const PrayerSpiritualContent({
    required this.prayerKey,
    required this.verses,
    required this.hadiths,
    required this.tips,
    required this.duaAfter,
    required this.meaning,
  });
}

class QuoteItem {
  final String text;
  final String source;
  final String? explanation;

  const QuoteItem({
    required this.text,
    required this.source,
    this.explanation,
  });
}

/// المحتوى الروحاني الكامل
final Map<String, PrayerSpiritualContent> spiritualContentByPrayer = {
  'Fajr': const PrayerSpiritualContent(
    prayerKey: 'Fajr',
    meaning: 'بداية يوم جديد مع الله، لحظة هدوء قبل صخب الحياة',
    verses: [
      QuoteItem(
        text: 'إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا',
        source: 'الإسراء: 78',
        explanation: 'الملائكة تشهد صلاة الفجر',
      ),
    ],
    hadiths: [
      QuoteItem(
        text: 'رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا',
        source: 'رواه مسلم',
      ),
      QuoteItem(
        text: 'مَنْ صَلَّى الصُّبْحَ فَهُوَ فِي ذِمَّةِ اللَّهِ',
        source: 'رواه مسلم',
      ),
    ],
    tips: [
      'نم مبكرًا لتستيقظ بنشاط',
      'اجعل منبهك بعيدًا عن السرير',
      'ادعُ الله بعد الأذان',
    ],
    duaAfter: [
      'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
      'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
    ],
  ),

  'Dhuhr': const PrayerSpiritualContent(
    prayerKey: 'Dhuhr',
    meaning: 'استراحة في منتصف اليوم، فرصة لتجديد الطاقة الروحية',
    verses: [
      QuoteItem(
        text: 'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ',
        source: 'البقرة: 238',
      ),
    ],
    hadiths: [
      QuoteItem(
        text: 'مَنْ حَافَظَ عَلَى أَرْبَعِ رَكَعَاتٍ قَبْلَ الظُّهْرِ وَأَرْبَعٍ بَعْدَهَا حَرَّمَهُ اللَّهُ عَلَى النَّارِ',
        source: 'رواه الترمذي',
      ),
    ],
    tips: [
      'خذ استراحة قصيرة من العمل',
      'استحضر معية الله في صلاتك',
    ],
    duaAfter: [
      'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    ],
  ),

  'Asr': const PrayerSpiritualContent(
    prayerKey: 'Asr',
    meaning: 'صلاة الوسطى، وقت محاسبة النفس قبل نهاية اليوم',
    verses: [
      QuoteItem(
        text: 'وَالْعَصْرِ ۝ إِنَّ الْإِنسَانَ لَفِي خُسْرٍ',
        source: 'سورة العصر',
      ),
    ],
    hadiths: [
      QuoteItem(
        text: 'مَنْ تَرَكَ صَلَاةَ الْعَصْرِ فَقَدْ حَبِطَ عَمَلُهُ',
        source: 'رواه البخاري',
      ),
    ],
    tips: [
      'لا تشغلك الدنيا عن العصر',
      'راجع يومك قبل العصر',
    ],
    duaAfter: [
      'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
    ],
  ),

  'Maghrib': const PrayerSpiritualContent(
    prayerKey: 'Maghrib',
    meaning: 'شكر الله على يوم انقضى، وقت إجابة الدعاء',
    verses: [
      QuoteItem(
        text: 'فَسُبْحَانَ اللَّهِ حِينَ تُمْسُونَ وَحِينَ تُصْبِحُونَ',
        source: 'الروم: 17',
      ),
    ],
    hadiths: [
      QuoteItem(
        text: 'صَلُّوا قَبْلَ الْمَغْرِبِ، صَلُّوا قَبْلَ الْمَغْرِبِ',
        source: 'رواه البخاري',
      ),
    ],
    tips: [
      'لا تؤخر المغرب',
      'المغرب وقت إجابة الدعاء',
    ],
    duaAfter: [
      'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
    ],
  ),

  'Isha': const PrayerSpiritualContent(
    prayerKey: 'Isha',
    meaning: 'ختام اليوم مع الله، استعداد للنوم على طهارة',
    verses: [
      QuoteItem(
        text: 'وَمِنَ اللَّيْلِ فَسَبِّحْهُ وَإِدْبَارَ النُّجُومِ',
        source: 'الطور: 49',
      ),
    ],
    hadiths: [
      QuoteItem(
        text: 'مَنْ صَلَّى الْعِشَاءَ فِي جَمَاعَةٍ فَكَأَنَّمَا قَامَ نِصْفَ اللَّيْلِ',
        source: 'رواه مسلم',
      ),
    ],
    tips: [
      'اختم يومك بصلاة وذكر',
      'صلِّ الوتر قبل النوم',
    ],
    duaAfter: [
      'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    ],
  ),
};

/// جلب محتوى عشوائي لصلاة معينة
PrayerSpiritualContent getRandomContentForPrayer(String prayerKey) {
  final content = spiritualContentByPrayer[prayerKey];
  return content ?? spiritualContentByPrayer['Fajr']!;
}