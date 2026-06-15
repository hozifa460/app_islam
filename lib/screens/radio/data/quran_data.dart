// lib/screens/radio/data/quran_data.dart

import '../models/surah_model.dart';

class QuranData {
  QuranData._();

  static const List<SurahModel> surahs = [
    SurahModel(number: 1,   name: 'الفاتحة',    nameEn: 'Al-Fatihah',    juzNumber: 1,  versesCount: 7,   isMakki: true),
    SurahModel(number: 2,   name: 'البقرة',     nameEn: 'Al-Baqarah',    juzNumber: 1,  versesCount: 286, isMakki: false),
    SurahModel(number: 3,   name: 'آل عمران',   nameEn: 'Aal-Imran',     juzNumber: 3,  versesCount: 200, isMakki: false),
    SurahModel(number: 4,   name: 'النساء',     nameEn: 'An-Nisa',       juzNumber: 4,  versesCount: 176, isMakki: false),
    SurahModel(number: 5,   name: 'المائدة',    nameEn: 'Al-Maidah',     juzNumber: 6,  versesCount: 120, isMakki: false),
    SurahModel(number: 6,   name: 'الأنعام',    nameEn: 'Al-Anam',       juzNumber: 7,  versesCount: 165, isMakki: true),
    SurahModel(number: 7,   name: 'الأعراف',    nameEn: 'Al-Araf',       juzNumber: 8,  versesCount: 206, isMakki: true),
    SurahModel(number: 8,   name: 'الأنفال',    nameEn: 'Al-Anfal',      juzNumber: 9,  versesCount: 75,  isMakki: false),
    SurahModel(number: 9,   name: 'التوبة',     nameEn: 'At-Tawbah',     juzNumber: 10, versesCount: 129, isMakki: false),
    SurahModel(number: 10,  name: 'يونس',       nameEn: 'Yunus',         juzNumber: 11, versesCount: 109, isMakki: true),
    SurahModel(number: 11,  name: 'هود',        nameEn: 'Hud',           juzNumber: 11, versesCount: 123, isMakki: true),
    SurahModel(number: 12,  name: 'يوسف',       nameEn: 'Yusuf',         juzNumber: 12, versesCount: 111, isMakki: true),
    SurahModel(number: 13,  name: 'الرعد',      nameEn: 'Ar-Rad',        juzNumber: 13, versesCount: 43,  isMakki: false),
    SurahModel(number: 14,  name: 'إبراهيم',    nameEn: 'Ibrahim',       juzNumber: 13, versesCount: 52,  isMakki: true),
    SurahModel(number: 15,  name: 'الحجر',      nameEn: 'Al-Hijr',       juzNumber: 14, versesCount: 99,  isMakki: true),
    SurahModel(number: 16,  name: 'النحل',      nameEn: 'An-Nahl',       juzNumber: 14, versesCount: 128, isMakki: true),
    SurahModel(number: 17,  name: 'الإسراء',    nameEn: 'Al-Isra',       juzNumber: 15, versesCount: 111, isMakki: true),
    SurahModel(number: 18,  name: 'الكهف',      nameEn: 'Al-Kahf',       juzNumber: 15, versesCount: 110, isMakki: true),
    SurahModel(number: 19,  name: 'مريم',       nameEn: 'Maryam',        juzNumber: 16, versesCount: 98,  isMakki: true),
    SurahModel(number: 20,  name: 'طه',         nameEn: 'Ta-Ha',         juzNumber: 16, versesCount: 135, isMakki: true),
    SurahModel(number: 21,  name: 'الأنبياء',   nameEn: 'Al-Anbiya',     juzNumber: 17, versesCount: 112, isMakki: true),
    SurahModel(number: 22,  name: 'الحج',       nameEn: 'Al-Hajj',       juzNumber: 17, versesCount: 78,  isMakki: false),
    SurahModel(number: 23,  name: 'المؤمنون',   nameEn: 'Al-Muminun',    juzNumber: 18, versesCount: 118, isMakki: true),
    SurahModel(number: 24,  name: 'النور',      nameEn: 'An-Nur',        juzNumber: 18, versesCount: 64,  isMakki: false),
    SurahModel(number: 25,  name: 'الفرقان',    nameEn: 'Al-Furqan',     juzNumber: 18, versesCount: 77,  isMakki: true),
    SurahModel(number: 26,  name: 'الشعراء',    nameEn: 'Ash-Shuara',    juzNumber: 19, versesCount: 227, isMakki: true),
    SurahModel(number: 27,  name: 'النمل',      nameEn: 'An-Naml',       juzNumber: 19, versesCount: 93,  isMakki: true),
    SurahModel(number: 28,  name: 'القصص',      nameEn: 'Al-Qasas',      juzNumber: 20, versesCount: 88,  isMakki: true),
    SurahModel(number: 29,  name: 'العنكبوت',   nameEn: 'Al-Ankabut',    juzNumber: 20, versesCount: 69,  isMakki: true),
    SurahModel(number: 30,  name: 'الروم',      nameEn: 'Ar-Rum',        juzNumber: 21, versesCount: 60,  isMakki: true),
    SurahModel(number: 31,  name: 'لقمان',      nameEn: 'Luqman',        juzNumber: 21, versesCount: 34,  isMakki: true),
    SurahModel(number: 32,  name: 'السجدة',     nameEn: 'As-Sajdah',     juzNumber: 21, versesCount: 30,  isMakki: true),
    SurahModel(number: 33,  name: 'الأحزاب',    nameEn: 'Al-Ahzab',      juzNumber: 21, versesCount: 73,  isMakki: false),
    SurahModel(number: 34,  name: 'سبأ',        nameEn: 'Saba',          juzNumber: 22, versesCount: 54,  isMakki: true),
    SurahModel(number: 35,  name: 'فاطر',       nameEn: 'Fatir',         juzNumber: 22, versesCount: 45,  isMakki: true),
    SurahModel(number: 36,  name: 'يس',         nameEn: 'Ya-Sin',        juzNumber: 22, versesCount: 83,  isMakki: true),
    SurahModel(number: 37,  name: 'الصافات',    nameEn: 'As-Saffat',     juzNumber: 23, versesCount: 182, isMakki: true),
    SurahModel(number: 38,  name: 'ص',          nameEn: 'Sad',           juzNumber: 23, versesCount: 88,  isMakki: true),
    SurahModel(number: 39,  name: 'الزمر',      nameEn: 'Az-Zumar',      juzNumber: 23, versesCount: 75,  isMakki: true),
    SurahModel(number: 40,  name: 'غافر',       nameEn: 'Ghafir',        juzNumber: 24, versesCount: 85,  isMakki: true),
    SurahModel(number: 41,  name: 'فصلت',       nameEn: 'Fussilat',      juzNumber: 24, versesCount: 54,  isMakki: true),
    SurahModel(number: 42,  name: 'الشورى',     nameEn: 'Ash-Shuraa',    juzNumber: 25, versesCount: 53,  isMakki: true),
    SurahModel(number: 43,  name: 'الزخرف',     nameEn: 'Az-Zukhruf',    juzNumber: 25, versesCount: 89,  isMakki: true),
    SurahModel(number: 44,  name: 'الدخان',     nameEn: 'Ad-Dukhan',     juzNumber: 25, versesCount: 59,  isMakki: true),
    SurahModel(number: 45,  name: 'الجاثية',    nameEn: 'Al-Jathiyah',   juzNumber: 25, versesCount: 37,  isMakki: true),
    SurahModel(number: 46,  name: 'الأحقاف',    nameEn: 'Al-Ahqaf',      juzNumber: 26, versesCount: 35,  isMakki: true),
    SurahModel(number: 47,  name: 'محمد',       nameEn: 'Muhammad',      juzNumber: 26, versesCount: 38,  isMakki: false),
    SurahModel(number: 48,  name: 'الفتح',      nameEn: 'Al-Fath',       juzNumber: 26, versesCount: 29,  isMakki: false),
    SurahModel(number: 49,  name: 'الحجرات',    nameEn: 'Al-Hujurat',    juzNumber: 26, versesCount: 18,  isMakki: false),
    SurahModel(number: 50,  name: 'ق',          nameEn: 'Qaf',           juzNumber: 26, versesCount: 45,  isMakki: true),
    SurahModel(number: 51,  name: 'الذاريات',   nameEn: 'Adh-Dhariyat',  juzNumber: 26, versesCount: 60,  isMakki: true),
    SurahModel(number: 52,  name: 'الطور',      nameEn: 'At-Tur',        juzNumber: 27, versesCount: 49,  isMakki: true),
    SurahModel(number: 53,  name: 'النجم',      nameEn: 'An-Najm',       juzNumber: 27, versesCount: 62,  isMakki: true),
    SurahModel(number: 54,  name: 'القمر',      nameEn: 'Al-Qamar',      juzNumber: 27, versesCount: 55,  isMakki: true),
    SurahModel(number: 55,  name: 'الرحمن',     nameEn: 'Ar-Rahman',     juzNumber: 27, versesCount: 78,  isMakki: true),
    SurahModel(number: 56,  name: 'الواقعة',    nameEn: 'Al-Waqiah',     juzNumber: 27, versesCount: 96,  isMakki: true),
    SurahModel(number: 57,  name: 'الحديد',     nameEn: 'Al-Hadid',      juzNumber: 27, versesCount: 29,  isMakki: false),
    SurahModel(number: 58,  name: 'المجادلة',   nameEn: 'Al-Mujadila',   juzNumber: 28, versesCount: 22,  isMakki: false),
    SurahModel(number: 59,  name: 'الحشر',      nameEn: 'Al-Hashr',      juzNumber: 28, versesCount: 24,  isMakki: false),
    SurahModel(number: 60,  name: 'الممتحنة',   nameEn: 'Al-Mumtahanah', juzNumber: 28, versesCount: 13,  isMakki: false),
    SurahModel(number: 61,  name: 'الصف',       nameEn: 'As-Saf',        juzNumber: 28, versesCount: 14,  isMakki: false),
    SurahModel(number: 62,  name: 'الجمعة',     nameEn: 'Al-Jumuah',     juzNumber: 28, versesCount: 11,  isMakki: false),
    SurahModel(number: 63,  name: 'المنافقون',  nameEn: 'Al-Munafiqun',  juzNumber: 28, versesCount: 11,  isMakki: false),
    SurahModel(number: 64,  name: 'التغابن',    nameEn: 'At-Taghabun',   juzNumber: 28, versesCount: 18,  isMakki: false),
    SurahModel(number: 65,  name: 'الطلاق',     nameEn: 'At-Talaq',      juzNumber: 28, versesCount: 12,  isMakki: false),
    SurahModel(number: 66,  name: 'التحريم',    nameEn: 'At-Tahrim',     juzNumber: 28, versesCount: 12,  isMakki: false),
    SurahModel(number: 67,  name: 'الملك',      nameEn: 'Al-Mulk',       juzNumber: 29, versesCount: 30,  isMakki: true),
    SurahModel(number: 68,  name: 'القلم',      nameEn: 'Al-Qalam',      juzNumber: 29, versesCount: 52,  isMakki: true),
    SurahModel(number: 69,  name: 'الحاقة',     nameEn: 'Al-Haqqah',     juzNumber: 29, versesCount: 52,  isMakki: true),
    SurahModel(number: 70,  name: 'المعارج',    nameEn: 'Al-Maarij',     juzNumber: 29, versesCount: 44,  isMakki: true),
    SurahModel(number: 71,  name: 'نوح',        nameEn: 'Nuh',           juzNumber: 29, versesCount: 28,  isMakki: true),
    SurahModel(number: 72,  name: 'الجن',       nameEn: 'Al-Jinn',       juzNumber: 29, versesCount: 28,  isMakki: true),
    SurahModel(number: 73,  name: 'المزمل',     nameEn: 'Al-Muzzammil',  juzNumber: 29, versesCount: 20,  isMakki: true),
    SurahModel(number: 74,  name: 'المدثر',     nameEn: 'Al-Muddathir',  juzNumber: 29, versesCount: 56,  isMakki: true),
    SurahModel(number: 75,  name: 'القيامة',    nameEn: 'Al-Qiyamah',    juzNumber: 29, versesCount: 40,  isMakki: true),
    SurahModel(number: 76,  name: 'الإنسان',    nameEn: 'Al-Insan',      juzNumber: 29, versesCount: 31,  isMakki: false),
    SurahModel(number: 77,  name: 'المرسلات',   nameEn: 'Al-Mursalat',   juzNumber: 29, versesCount: 50,  isMakki: true),
    SurahModel(number: 78,  name: 'النبأ',      nameEn: 'An-Naba',       juzNumber: 30, versesCount: 40,  isMakki: true),
    SurahModel(number: 79,  name: 'النازعات',   nameEn: 'An-Naziat',     juzNumber: 30, versesCount: 46,  isMakki: true),
    SurahModel(number: 80,  name: 'عبس',        nameEn: 'Abasa',         juzNumber: 30, versesCount: 42,  isMakki: true),
    SurahModel(number: 81,  name: 'التكوير',    nameEn: 'At-Takwir',     juzNumber: 30, versesCount: 29,  isMakki: true),
    SurahModel(number: 82,  name: 'الانفطار',   nameEn: 'Al-Infitar',    juzNumber: 30, versesCount: 19,  isMakki: true),
    SurahModel(number: 83,  name: 'المطففين',   nameEn: 'Al-Mutaffifin', juzNumber: 30, versesCount: 36,  isMakki: true),
    SurahModel(number: 84,  name: 'الانشقاق',   nameEn: 'Al-Inshiqaq',   juzNumber: 30, versesCount: 25,  isMakki: true),
    SurahModel(number: 85,  name: 'البروج',     nameEn: 'Al-Buruj',      juzNumber: 30, versesCount: 22,  isMakki: true),
    SurahModel(number: 86,  name: 'الطارق',     nameEn: 'At-Tariq',      juzNumber: 30, versesCount: 17,  isMakki: true),
    SurahModel(number: 87,  name: 'الأعلى',     nameEn: 'Al-Ala',        juzNumber: 30, versesCount: 19,  isMakki: true),
    SurahModel(number: 88,  name: 'الغاشية',    nameEn: 'Al-Ghashiyah',  juzNumber: 30, versesCount: 26,  isMakki: true),
    SurahModel(number: 89,  name: 'الفجر',      nameEn: 'Al-Fajr',       juzNumber: 30, versesCount: 30,  isMakki: true),
    SurahModel(number: 90,  name: 'البلد',      nameEn: 'Al-Balad',      juzNumber: 30, versesCount: 20,  isMakki: true),
    SurahModel(number: 91,  name: 'الشمس',      nameEn: 'Ash-Shams',     juzNumber: 30, versesCount: 15,  isMakki: true),
    SurahModel(number: 92,  name: 'الليل',      nameEn: 'Al-Layl',       juzNumber: 30, versesCount: 21,  isMakki: true),
    SurahModel(number: 93,  name: 'الضحى',      nameEn: 'Ad-Duha',       juzNumber: 30, versesCount: 11,  isMakki: true),
    SurahModel(number: 94,  name: 'الشرح',      nameEn: 'Ash-Sharh',     juzNumber: 30, versesCount: 8,   isMakki: true),
    SurahModel(number: 95,  name: 'التين',      nameEn: 'At-Tin',        juzNumber: 30, versesCount: 8,   isMakki: true),
    SurahModel(number: 96,  name: 'العلق',      nameEn: 'Al-Alaq',       juzNumber: 30, versesCount: 19,  isMakki: true),
    SurahModel(number: 97,  name: 'القدر',      nameEn: 'Al-Qadr',       juzNumber: 30, versesCount: 5,   isMakki: true),
    SurahModel(number: 98,  name: 'البينة',     nameEn: 'Al-Bayyinah',   juzNumber: 30, versesCount: 8,   isMakki: false),
    SurahModel(number: 99,  name: 'الزلزلة',    nameEn: 'Az-Zalzalah',   juzNumber: 30, versesCount: 8,   isMakki: false),
    SurahModel(number: 100, name: 'العاديات',   nameEn: 'Al-Adiyat',     juzNumber: 30, versesCount: 11,  isMakki: true),
    SurahModel(number: 101, name: 'القارعة',    nameEn: 'Al-Qariah',     juzNumber: 30, versesCount: 11,  isMakki: true),
    SurahModel(number: 102, name: 'التكاثر',    nameEn: 'At-Takathur',   juzNumber: 30, versesCount: 8,   isMakki: true),
    SurahModel(number: 103, name: 'العصر',      nameEn: 'Al-Asr',        juzNumber: 30, versesCount: 3,   isMakki: true),
    SurahModel(number: 104, name: 'الهمزة',     nameEn: 'Al-Humazah',    juzNumber: 30, versesCount: 9,   isMakki: true),
    SurahModel(number: 105, name: 'الفيل',      nameEn: 'Al-Fil',        juzNumber: 30, versesCount: 5,   isMakki: true),
    SurahModel(number: 106, name: 'قريش',       nameEn: 'Quraysh',       juzNumber: 30, versesCount: 4,   isMakki: true),
    SurahModel(number: 107, name: 'الماعون',    nameEn: 'Al-Maun',       juzNumber: 30, versesCount: 7,   isMakki: true),
    SurahModel(number: 108, name: 'الكوثر',     nameEn: 'Al-Kawthar',    juzNumber: 30, versesCount: 3,   isMakki: true),
    SurahModel(number: 109, name: 'الكافرون',   nameEn: 'Al-Kafirun',    juzNumber: 30, versesCount: 6,   isMakki: true),
    SurahModel(number: 110, name: 'النصر',      nameEn: 'An-Nasr',       juzNumber: 30, versesCount: 3,   isMakki: false),
    SurahModel(number: 111, name: 'المسد',      nameEn: 'Al-Masad',      juzNumber: 30, versesCount: 5,   isMakki: true),
    SurahModel(number: 112, name: 'الإخلاص',    nameEn: 'Al-Ikhlas',     juzNumber: 30, versesCount: 4,   isMakki: true),
    SurahModel(number: 113, name: 'الفلق',      nameEn: 'Al-Falaq',      juzNumber: 30, versesCount: 5,   isMakki: true),
    SurahModel(number: 114, name: 'الناس',      nameEn: 'An-Nas',        juzNumber: 30, versesCount: 6,   isMakki: true),
  ];

  static const List<JuzModel> juzList = [
    JuzModel(number: 1,  name: 'الجزء الأول',           startSurah: 1,  endSurah: 2),
    JuzModel(number: 2,  name: 'الجزء الثاني',          startSurah: 2,  endSurah: 2),
    JuzModel(number: 3,  name: 'الجزء الثالث',          startSurah: 2,  endSurah: 3),
    JuzModel(number: 4,  name: 'الجزء الرابع',          startSurah: 3,  endSurah: 4),
    JuzModel(number: 5,  name: 'الجزء الخامس',          startSurah: 4,  endSurah: 4),
    JuzModel(number: 6,  name: 'الجزء السادس',          startSurah: 4,  endSurah: 5),
    JuzModel(number: 7,  name: 'الجزء السابع',          startSurah: 5,  endSurah: 6),
    JuzModel(number: 8,  name: 'الجزء الثامن',          startSurah: 6,  endSurah: 7),
    JuzModel(number: 9,  name: 'الجزء التاسع',          startSurah: 7,  endSurah: 8),
    JuzModel(number: 10, name: 'الجزء العاشر',          startSurah: 8,  endSurah: 9),
    JuzModel(number: 11, name: 'الجزء الحادي عشر',      startSurah: 9,  endSurah: 11),
    JuzModel(number: 12, name: 'الجزء الثاني عشر',      startSurah: 11, endSurah: 12),
    JuzModel(number: 13, name: 'الجزء الثالث عشر',      startSurah: 12, endSurah: 14),
    JuzModel(number: 14, name: 'الجزء الرابع عشر',      startSurah: 15, endSurah: 16),
    JuzModel(number: 15, name: 'الجزء الخامس عشر',      startSurah: 17, endSurah: 18),
    JuzModel(number: 16, name: 'الجزء السادس عشر',      startSurah: 18, endSurah: 20),
    JuzModel(number: 17, name: 'الجزء السابع عشر',      startSurah: 21, endSurah: 22),
    JuzModel(number: 18, name: 'الجزء الثامن عشر',      startSurah: 23, endSurah: 25),
    JuzModel(number: 19, name: 'الجزء التاسع عشر',      startSurah: 25, endSurah: 27),
    JuzModel(number: 20, name: 'الجزء العشرون',         startSurah: 27, endSurah: 29),
    JuzModel(number: 21, name: 'الجزء الحادي والعشرون', startSurah: 29, endSurah: 33),
    JuzModel(number: 22, name: 'الجزء الثاني والعشرون', startSurah: 33, endSurah: 36),
    JuzModel(number: 23, name: 'الجزء الثالث والعشرون', startSurah: 36, endSurah: 39),
    JuzModel(number: 24, name: 'الجزء الرابع والعشرون', startSurah: 39, endSurah: 41),
    JuzModel(number: 25, name: 'الجزء الخامس والعشرون', startSurah: 41, endSurah: 45),
    JuzModel(number: 26, name: 'الجزء السادس والعشرون', startSurah: 46, endSurah: 51),
    JuzModel(number: 27, name: 'الجزء السابع والعشرون', startSurah: 51, endSurah: 57),
    JuzModel(number: 28, name: 'الجزء الثامن والعشرون', startSurah: 58, endSurah: 66),
    JuzModel(number: 29, name: 'الجزء التاسع والعشرون', startSurah: 67, endSurah: 77),
    JuzModel(number: 30, name: 'جزء عمّ',               startSurah: 78, endSurah: 114),
  ];

  // ══════════════════════════════════════════════════════
  // ✅ Maps للوصول السريع O(1) بدل firstWhere O(n)
  // ══════════════════════════════════════════════════════

  static final Map<int, SurahModel> _surahByNumberMap = {
    for (final s in surahs) s.number: s,
  };

  static final Map<int, JuzModel> _juzByNumberMap = {
    for (final j in juzList) j.number: j,
  };

  // ✅ Map السور حسب الجزء
  static final Map<int, List<SurahModel>> _surahsByJuzMap = () {
    final map = <int, List<SurahModel>>{};
    for (final s in surahs) {
      map.putIfAbsent(s.juzNumber, () => []).add(s);
    }
    return map;
  }();

  // ✅ Map السور المكية/المدنية - للبحث السريع
  static final List<SurahModel> makkiSurahs =
  surahs.where((s) => s.isMakki).toList();

  static final List<SurahModel> madaniSurahs =
  surahs.where((s) => !s.isMakki).toList();

  // ══ دوال الوصول ══

  /// O(1) بدل O(n)
  static SurahModel surahByNumber(int number) {
    assert(number >= 1 && number <= 114,
    'surahByNumber: رقم السورة يجب أن يكون بين 1 و 114');
    return _surahByNumberMap[number] ?? surahs.first;
  }

  /// O(1) بدل O(n)
  static JuzModel juzByNumber(int number) {
    assert(number >= 1 && number <= 30,
    'juzByNumber: رقم الجزء يجب أن يكون بين 1 و 30');
    return _juzByNumberMap[number] ?? juzList.first;
  }

  /// O(1) بدل O(n)
  static List<SurahModel> surahsByJuz(int juzNumber) {
    return _surahsByJuzMap[juzNumber] ?? [];
  }

  /// البحث في السور - مُحسَّن
  static List<SurahModel> searchSurahs(String query) {
    if (query.isEmpty) return surahs;
    final q = query.trim().toLowerCase();
    return surahs.where((s) {
      return s.name.contains(query) ||
          s.nameEn.toLowerCase().contains(q);
    }).toList();
  }

  /// حجم الجزء التقريبي - O(1)
  static String juzApproximateSize(int juzNumber) {
    final juzSurahs = surahsByJuz(juzNumber);
    final totalMB = juzSurahs.fold<double>(
      0.0,
          (sum, s) => sum + s.approximateSizeMB,
    );
    return '${totalMB.toStringAsFixed(0)} MB';
  }

  /// التحقق من صحة رقم السورة
  static bool isValidSurahNumber(int number) =>
      number >= 1 && number <= 114;

  /// التحقق من صحة رقم الجزء
  static bool isValidJuzNumber(int number) =>
      number >= 1 && number <= 30;
}