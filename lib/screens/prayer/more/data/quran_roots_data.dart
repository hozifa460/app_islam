class QuranRoot {
  final String root;
  final String meaning;
  final List<String> examples;
  final int occurrences;

  const QuranRoot({
    required this.root,
    required this.meaning,
    required this.examples,
    required this.occurrences,
  });
}

const List<QuranRoot> quranRoots = [
  QuranRoot(
    root: 'ع - ل - م',
    meaning: 'العلم والمعرفة والإدراك',
    examples: ['عَلِمَ', 'يَعْلَمُ', 'عَالِم', 'عِلْم', 'مَعْلُوم'],
    occurrences: 854,
  ),
  QuranRoot(
    root: 'ك - ت - ب',
    meaning: 'الكتابة والتدوين والفرض',
    examples: ['كَتَبَ', 'كِتَاب', 'كَاتِب', 'مَكْتُوب', 'يَكْتُبُ'],
    occurrences: 319,
  ),
  QuranRoot(
    root: 'ق - و - ل',
    meaning: 'القول والكلام والنطق',
    examples: ['قَالَ', 'يَقُولُ', 'قَوْل', 'مَقَال', 'أَقْوَال'],
    occurrences: 1722,
  ),
  QuranRoot(
    root: 'أ - م - ر',
    meaning: 'الأمر والشأن والسلطة',
    examples: ['أَمَرَ', 'أَمْر', 'يَأْمُرُ', 'أُمُور', 'مَأْمُور'],
    occurrences: 248,
  ),
  QuranRoot(
    root: 'ر - ح - م',
    meaning: 'الرحمة واللطف والعطف',
    examples: ['رَحِمَ', 'رَحْمَة', 'رَحِيم', 'رَحْمَن', 'أَرْحَام'],
    occurrences: 339,
  ),
  QuranRoot(
    root: 'ع - ب - د',
    meaning: 'العبادة والخضوع والطاعة',
    examples: ['عَبَدَ', 'عَبْد', 'عِبَادَة', 'عَابِد', 'يَعْبُدُ'],
    occurrences: 275,
  ),
  QuranRoot(
    root: 'ح - ق - ق',
    meaning: 'الحق والصدق والثبوت',
    examples: ['حَقَّ', 'حَق', 'حَقِيق', 'يَحِق', 'حَقِيقَة'],
    occurrences: 287,
  ),
  QuranRoot(
    root: 'ن - ف - س',
    meaning: 'النفس والروح والذات',
    examples: ['نَفْس', 'أَنْفُس', 'نَفِيس', 'تَنَفَّسَ', 'نُفُوس'],
    occurrences: 298,
  ),
  QuranRoot(
    root: 'خ - ل - ق',
    meaning: 'الخلق والإيجاد والتصوير',
    examples: ['خَلَقَ', 'خَلْق', 'خَالِق', 'مَخْلُوق', 'يَخْلُقُ'],
    occurrences: 261,
  ),
  QuranRoot(
    root: 'ر - ب - ب',
    meaning: 'الرب والتربية والسيادة',
    examples: ['رَبَّ', 'رَب', 'رَبَّانِي', 'يَرُب', 'أَرْبَاب'],
    occurrences: 980,
  ),
  QuranRoot(
    root: 'ص - ل - ح',
    meaning: 'الصلاح والإصلاح والاستقامة',
    examples: ['صَلَحَ', 'صَالِح', 'صَلَاح', 'مُصْلِح', 'إِصْلَاح'],
    occurrences: 180,
  ),
  QuranRoot(
    root: 'ك - ف - ر',
    meaning: 'الكفر والجحود والتغطية',
    examples: ['كَفَرَ', 'كَافِر', 'كُفْر', 'يَكْفُرُ', 'كُفَّار'],
    occurrences: 525,
  ),
  QuranRoot(
    root: 'آ - م - ن',
    meaning: 'الإيمان والأمان والتصديق',
    examples: ['آمَنَ', 'مُؤْمِن', 'إِيمَان', 'أَمَان', 'يُؤْمِنُ'],
    occurrences: 879,
  ),
  QuranRoot(
    root: 'ج - ه - د',
    meaning: 'الجهد والمشقة والسعي',
    examples: ['جَهَدَ', 'جِهَاد', 'مُجَاهِد', 'جَهْد', 'يَجْهَدُ'],
    occurrences: 41,
  ),
  QuranRoot(
    root: 'ح - م - د',
    meaning: 'الحمد والثناء والشكر',
    examples: ['حَمِدَ', 'حَمْد', 'مَحْمُود', 'أَحْمَد', 'حَامِد'],
    occurrences: 68,
  ),
  QuranRoot(
    root: 'س - ب - ح',
    meaning: 'التسبيح والتنزيه والسباحة',
    examples: ['سَبَّحَ', 'سُبْحَان', 'تَسْبِيح', 'يُسَبِّحُ', 'سَبَّاح'],
    occurrences: 92,
  ),
  QuranRoot(
    root: 'ق - ر - أ',
    meaning: 'القراءة والتلاوة والجمع',
    examples: ['قَرَأَ', 'قُرْآن', 'قِرَاءَة', 'قَارِئ', 'يَقْرَأُ'],
    occurrences: 88,
  ),
  QuranRoot(
    root: 'ص - ل - و',
    meaning: 'الصلاة والدعاء والرحمة',
    examples: ['صَلَّى', 'صَلَاة', 'مُصَلِّي', 'صَلَوَات', 'يُصَلِّي'],
    occurrences: 99,
  ),
  QuranRoot(
    root: 'ز - ك - و',
    meaning: 'الزكاة والنمو والطهارة',
    examples: ['زَكَّى', 'زَكَاة', 'زَكِيّ', 'تَزْكِيَة', 'يَزْكُو'],
    occurrences: 59,
  ),
  QuranRoot(
    root: 'ت - و - ب',
    meaning: 'التوبة والرجوع والإنابة',
    examples: ['تَابَ', 'تَوْبَة', 'تَوَّاب', 'يَتُوبُ', 'مُتَاب'],
    occurrences: 87,
  ),
  QuranRoot(
    root: 'ه - د - ي',
    meaning: 'الهداية والإرشاد والدلالة',
    examples: ['هَدَى', 'هُدَى', 'هِدَايَة', 'هَادِي', 'يَهْدِي'],
    occurrences: 316,
  ),
  QuranRoot(
    root: 'ذ - ك - ر',
    meaning: 'الذكر والتذكر والتذكير',
    examples: ['ذَكَرَ', 'ذِكْر', 'ذَكَّرَ', 'تَذَكَّرَ', 'مُذَكِّر'],
    occurrences: 292,
  ),
  QuranRoot(
    root: 'ش - ك - ر',
    meaning: 'الشكر والامتنان والثناء',
    examples: ['شَكَرَ', 'شُكْر', 'شَكُور', 'يَشْكُرُ', 'شَاكِر'],
    occurrences: 75,
  ),
  QuranRoot(
    root: 'ص - ب - ر',
    meaning: 'الصبر والتحمل والثبات',
    examples: ['صَبَرَ', 'صَبْر', 'صَابِر', 'صَبُور', 'يَصْبِرُ'],
    occurrences: 103,
  ),
  QuranRoot(
    root: 'ف - ت - ح',
    meaning: 'الفتح والنصر والافتتاح',
    examples: ['فَتَحَ', 'فَتْح', 'فَاتِح', 'مِفْتَاح', 'يَفْتَحُ'],
    occurrences: 51,
  ),
  QuranRoot(
    root: 'ن - ص - ر',
    meaning: 'النصر والمعاونة والمساعدة',
    examples: ['نَصَرَ', 'نَصْر', 'نَاصِر', 'مَنْصُور', 'يَنْصُرُ'],
    occurrences: 158,
  ),
  QuranRoot(
    root: 'ع - ز - ز',
    meaning: 'العزة والقوة والمنعة',
    examples: ['عَزَّ', 'عَزِيز', 'عِزَّة', 'يَعِزُّ', 'أَعَزَّ'],
    occurrences: 92,
  ),
  QuranRoot(
    root: 'ح - ك - م',
    meaning: 'الحكمة والحكم والقضاء',
    examples: ['حَكَمَ', 'حِكْمَة', 'حَكِيم', 'حُكْم', 'يَحْكُمُ'],
    occurrences: 210,
  ),
  QuranRoot(
    root: 'ع - ل - و',
    meaning: 'العلو والارتفاع والسمو',
    examples: ['عَلَا', 'عَلِيّ', 'عُلُوّ', 'أَعْلَى', 'يَعْلُو'],
    occurrences: 94,
  ),
  QuranRoot(
    root: 'ب - ص - ر',
    meaning: 'البصر والرؤية والإبصار',
    examples: ['بَصَرَ', 'بَصِير', 'بَصَر', 'أَبْصَار', 'يُبْصِرُ'],
    occurrences: 148,
  ),
];