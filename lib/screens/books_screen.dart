import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'books_reader_screen.dart';
import 'hadith/hadith_book_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BooksScreen extends StatefulWidget {
  final Color primaryColor;

  const BooksScreen({super.key, required this.primaryColor});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // الألوان الأساسية
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);

  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  Map<String, bool> _downloadedBooks = {};
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categoriesList = [
    'الكل', 'الحديث النبوي', 'التفسير وعلوم القرآن', 'العقيدة والتزكية', 'الفقه وأصوله', 'السيرة والتاريخ'
  ];

  final List<Map<String, dynamic>> _dailyBanners = [
    {'text': 'اتقوا الله\nفي النساء', 'colors': [const Color(0xFF151B26), const Color(0xFF0A0E17)]},
    {'text': 'خيركم من تعلم\nالقرآن وعلمه', 'colors': [const Color(0xFFE6B325).withOpacity(0.4), const Color(0xFF151B26)]},
    {'text': 'الدين\nالنصيحة', 'colors': [Colors.blueGrey.shade900, const Color(0xFF0A0E17)]},
    {'text': 'الكلمة الطيبة\nصدقة', 'colors': [const Color(0xFF1E3C3B), const Color(0xFF0A0E17)]},
    {'text': 'إنما الأعمال\nبالنيات', 'colors': [Colors.brown.shade900, const Color(0xFF151B26)]},
  ];

  // ✅ القائمة الكاملة كما أرسلتها بدون أي حذف
  final Map<String, List<Map<String, dynamic>>> _libraryCategories = {
    'الحديث النبوي': [
      {'id': 'bukhari', 'title': 'صحيح البخاري',
        'calligraphy': 'صحيح\nالبخاري',
        'color': const Color(0xFF287D6D),
        'bottomColor': const Color(0xFF1F6B5C),
        'type': 'hadith',
        'imageUrl' : 'https://ia801906.us.archive.org/BookReader/BookReaderImages.php?zip=/9/items/20200818_20200818_0816/%D8%B5%D8%AD%D9%8A%D8%AD%20%D8%A7%D9%84%D8%A8%D8%AE%D8%A7%D8%B1%D9%8A_jp2.zip&file=%D8%B5%D8%AD%D9%8A%D8%AD%20%D8%A7%D9%84%D8%A8%D8%AE%D8%A7%D8%B1%D9%8A_jp2/%D8%B5%D8%AD%D9%8A%D8%AD%20%D8%A7%D9%84%D8%A8%D8%AE%D8%A7%D8%B1%D9%8A_0000.jp2&id=20200818_20200818_0816&scale=4&rotate=0',
      },
      {'id': 'muslim',
        'title': 'صحيح مسلم',
        'calligraphy': 'صحيح\nمُسلِم',
        'color': const Color(0xFF4C75A3),
        'bottomColor': const Color(0xFF3B5E87),
        'type': 'hadith',
        'imageUrl' : 'https://ia801800.us.archive.org/BookReader/BookReaderImages.php?zip=/12/items/20201125_20201125_2312/%D8%B5%D8%AD%D9%8A%D8%AD%20%D9%85%D8%B3%D9%84%D9%85_jp2.zip&file=%D8%B5%D8%AD%D9%8A%D8%AD%20%D9%85%D8%B3%D9%84%D9%85_jp2/%D8%B5%D8%AD%D9%8A%D8%AD%20%D9%85%D8%B3%D9%84%D9%85_0000.jp2&id=20201125_20201125_2312&scale=4&rotate=0',
      },
      {'id': 'abudawud',
        'title': 'سنن أبي داود',
        'calligraphy': 'سنن\nأبي داود',
        'color': const Color(0xFF6B7290),
        'bottomColor': const Color(0xFF565C7A),
        'type': 'hadith',
        'imageUrl' : 'https://tse2.mm.bing.net/th/id/OIP.QTykxy8BqK1re_2srE3fagHaK7?w=976&h=1440&rs=1&pid=ImgDetMain&o=7&rm=3',
      },
      {'id': 'tirmidhi', 'title': 'جامع الترمذي',
        'calligraphy': 'جامع\nالترمذي', 'color': const Color(0xFF8E5961),
        'bottomColor': const Color(0xFF75454C), 'type': 'hadith',
        'imageUrl' : 'https://ia801306.us.archive.org/BookReader/BookReaderImages.php?zip=/8/items/termizi-dar-alsalam/%D8%AC%D8%A7%D9%85%D8%B9%20%D8%A7%D9%84%D8%AA%D8%B1%D9%85%D8%B0%D9%8A%20-%20%D8%B7%20%D8%AF%D8%A7%D8%B1%20%D8%A7%D9%84%D8%B3%D9%84%D8%A7%D9%85_jp2.zip&file=%D8%AC%D8%A7%D9%85%D8%B9%20%D8%A7%D9%84%D8%AA%D8%B1%D9%85%D8%B0%D9%8A%20-%20%D8%B7%20%D8%AF%D8%A7%D8%B1%20%D8%A7%D9%84%D8%B3%D9%84%D8%A7%D9%85_jp2/%D8%AC%D8%A7%D9%85%D8%B9%20%D8%A7%D9%84%D8%AA%D8%B1%D9%85%D8%B0%D9%8A%20-%20%D8%B7%20%D8%AF%D8%A7%D8%B1%20%D8%A7%D9%84%D8%B3%D9%84%D8%A7%D9%85_0000.jp2&id=termizi-dar-alsalam&scale=8&rotate=0',
      },
      {'id': 'nasai', 'title': 'سنن النسائي',
        'calligraphy': 'سنن\nالنسائي', 'color': const Color(0xFF6F6E6F),
        'bottomColor': const Color(0xFF5A595A), 'type': 'hadith',
        'imageUrl' : 'https://ia600308.us.archive.org/BookReader/BookReaderImages.php?zip=/10/items/sonan.al.nsaei.t.twiq_201908/sonan.al.nsaei.t.twiq_jp2.zip&file=sonan.al.nsaei.t.twiq_jp2/sonan.al.nsaei.t.twiq_0000.jp2&id=sonan.al.nsaei.t.twiq_201908&scale=4&rotate=0',
      },
      {'id': 'ibnmajah', 'title': 'سنن ابن ماجه',
        'calligraphy': 'سنن\nابن ماجه', 'color': const Color(0xFF865278),
        'bottomColor': const Color(0xFF6D3F60), 'type': 'hadith',
        'imageUrl' : 'https://ia800504.us.archive.org/BookReader/BookReaderImages.php?zip=/33/items/sounnan-ibn-madjih_202309/Sounnan%20Ibn%20Madjih-%D8%B3%D9%86%D9%86%20%D8%A7%D8%A8%D9%86%20%D9%85%D8%A7%D8%AC%D9%87_jp2.zip&file=Sounnan%20Ibn%20Madjih-%D8%B3%D9%86%D9%86%20%D8%A7%D8%A8%D9%86%20%D9%85%D8%A7%D8%AC%D9%87_jp2/Sounnan%20Ibn%20Madjih-%D8%B3%D9%86%D9%86%20%D8%A7%D8%A8%D9%86%20%D9%85%D8%A7%D8%AC%D9%87_0000.jp2&id=sounnan-ibn-madjih_202309&scale=4&rotate=0',
      },
      {'id': 'riyad', 'title': 'رياض الصالحين', 'calligraphy': 'رياض\nالصالحين',
        'color': const Color(0xFF3F6C51), 'bottomColor': const Color(0xFF325740),
        'type': 'custom',
        'pdfUrl' : 'https://archive.org/compress/20230705_20230705_1536/formats=TEXT%20PDF&file=/20230705_20230705_1536.zip',
        'imageUrl' : 'https://ia600603.us.archive.org/BookReader/BookReaderImages.php?zip=/10/items/20230705_20230705_1536/%D8%B4%D8%B1%D8%AD%20%D8%B1%D9%8A%D8%A7%D8%B6%20%D8%A7%D9%84%D8%B5%D8%A7%D9%84%D8%AD%D9%8A%D9%86%D9%A1%20-%20%D8%A7%D8%A8%D9%86%20%D8%A8%D8%A7%D8%B2_jp2.zip&file=%D8%B4%D8%B1%D8%AD%20%D8%B1%D9%8A%D8%A7%D8%B6%20%D8%A7%D9%84%D8%B5%D8%A7%D9%84%D8%AD%D9%8A%D9%86%D9%A1%20-%20%D8%A7%D8%A8%D9%86%20%D8%A8%D8%A7%D8%B2_jp2/%D8%B4%D8%B1%D8%AD%20%D8%B1%D9%8A%D8%A7%D8%B6%20%D8%A7%D9%84%D8%B5%D8%A7%D9%84%D8%AD%D9%8A%D9%86%D9%A1%20-%20%D8%A7%D8%A8%D9%86%20%D8%A8%D8%A7%D8%B2_0000.jp2&id=20230705_20230705_1536&scale=4&rotate=0',
      },
      {'id': 'nawawi40', 'title': 'الأربعون النووية', 'calligraphy': 'الأربعون\nالنووية',
        'color': const Color(0xFF9E4E45), 'bottomColor': const Color(0xFF823D35),
        'type': 'custom','pdfUrl': 'https://archive.org/download/20200924_20200924_0912/%D8%A7%D9%84%D8%A7%D8%B1%D8%A8%D8%B9%D9%88%D9%86%20%D8%A7%D9%84%D9%86%D9%88%D9%88%D9%8A%D8%A9%20%D9%84%D8%B5%D8%A7%D9%84%D8%AD%20%D8%A7%D9%84%20%D8%B4%D9%8A%D8%AE.pdf',
        'imageUrl' : 'https://ia803203.us.archive.org/BookReader/BookReaderImages.php?zip=/27/items/20200924_20200924_0912/%D8%A7%D9%84%D8%A7%D8%B1%D8%A8%D8%B9%D9%88%D9%86%20%D8%A7%D9%84%D9%86%D9%88%D9%88%D9%8A%D8%A9%20%D9%84%D8%B5%D8%A7%D9%84%D8%AD%20%D8%A7%D9%84%20%D8%B4%D9%8A%D8%AE_jp2.zip&file=%D8%A7%D9%84%D8%A7%D8%B1%D8%A8%D8%B9%D9%88%D9%86%20%D8%A7%D9%84%D9%86%D9%88%D9%88%D9%8A%D8%A9%20%D9%84%D8%B5%D8%A7%D9%84%D8%AD%20%D8%A7%D9%84%20%D8%B4%D9%8A%D8%AE_jp2/%D8%A7%D9%84%D8%A7%D8%B1%D8%A8%D8%B9%D9%88%D9%86%20%D8%A7%D9%84%D9%86%D9%88%D9%88%D9%8A%D8%A9%20%D9%84%D8%B5%D8%A7%D9%84%D8%AD%20%D8%A7%D9%84%20%D8%B4%D9%8A%D8%AE_0000.jp2&id=20200924_20200924_0912&scale=4&rotate=0',
      },
    ],
    'التفسير وعلوم القرآن': [
      {'id': 'tafsir_saadi',
        'title': 'تفسير السعدي',
        'calligraphy': 'تفسير\nالسعدي',
        'color': const Color(0xFF6B4226),
        'bottomColor': const Color(0xFF4A2E1A),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/download/20220616_20220616_2004/%D8%AA%D9%81%D8%B3%D9%8A%D8%B1%20%D8%A7%D9%84%D8%B3%D8%B9%D8%AF%D9%8A.pdf',
        'imageUrl': 'https://ia800402.us.archive.org/BookReader/BookReaderImages.php?zip=/25/items/20220616_20220616_2004/%D8%AA%D9%81%D8%B3%D9%8A%D8%B1%20%D8%A7%D9%84%D8%B3%D8%B9%D8%AF%D9%8A_jp2.zip&file=%D8%AA%D9%81%D8%B3%D9%8A%D8%B1%20%D8%A7%D9%84%D8%B3%D8%B9%D8%AF%D9%8A_jp2/%D8%AA%D9%81%D8%B3%D9%8A%D8%B1%20%D8%A7%D9%84%D8%B3%D8%B9%D8%AF%D9%8A_0000.jp2&id=20220616_20220616_2004&scale=4&rotate=0',
      },
      {'id': 'tafsir_ibnkathir',
        'title': 'تفسير ابن كثير',
        'calligraphy': 'تفسير\nابن كثير',
        'color': const Color(0xFF8B5A2B),
        'bottomColor': const Color(0xFF694320), 'type': 'custom',
        'pdfUrl': 'https://archive.org/download/20220903_20220903_1830/%D8%AA%D9%81%D8%B3%D9%8A%D8%B1%20%D8%A8%D9%86%20%D9%83%D8%AB%D9%8A%D8%B1.pdf',
        'imageUrl' : 'https://abjjadst.blob.core.windows.net/pub/9abd3fb6-d09e-499b-aee5-f4303c53c193.jpg'
      },
      {'id': 'atqan',
        'title': 'الإتقان في علوم القرآن',
        'calligraphy': 'الإتقان',
        'color': const Color(0xFF5C4033),
        'bottomColor': const Color(0xFF3D2B22),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/download/itkan_20160827/%D8%A7%D9%84%D8%A7%D8%AA%D9%82%D8%A7%D9%86%20%D9%81%D9%8A%20%D8%B9%D9%84%D9%88%D9%85%20%D8%A7%D9%84%D9%82%D8%B1%D8%A7%D9%86.pdf',
        'imageUrl': 'https://ia800504.us.archive.org/BookReader/BookReaderImages.php?zip=/22/items/itkan_20160827/%D8%A7%D9%84%D8%A7%D8%AA%D9%82%D8%A7%D9%86%20%D9%81%D9%8A%20%D8%B9%D9%84%D9%88%D9%85%20%D8%A7%D9%84%D9%82%D8%B1%D8%A7%D9%86_jp2.zip&file=%D8%A7%D9%84%D8%A7%D8%AA%D9%82%D8%A7%D9%86%20%D9%81%D9%8A%20%D8%B9%D9%84%D9%88%D9%85%20%D8%A7%D9%84%D9%82%D8%B1%D8%A7%D9%86_jp2/%D8%A7%D9%84%D8%A7%D8%AA%D9%82%D8%A7%D9%86%20%D9%81%D9%8A%20%D8%B9%D9%84%D9%88%D9%85%20%D8%A7%D9%84%D9%82%D8%B1%D8%A7%D9%86_0000.jp2&id=itkan_20160827&scale=8&rotate=0',
      },
    ],
    'العقيدة والتزكية': [
      {'id': 'tawheed',
        'title': 'كتاب التوحيد',
        'calligraphy': 'كتاب\nالتوحيد',
        'color': const Color(0xFF2F4F4F),
        'bottomColor': const Color(0xFF1C2F2F),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/download/01282-pdf/01282%20%D9%83%D8%AA%D8%A7%D8%A8%20%20%20%20%20pdf%20%20%D8%A7%D9%84%D8%B4%D9%8A%D8%AE%20%D9%85%D8%AD%D9%85%D8%AF%20%D8%A8%D9%86%20%D8%B9%D8%A8%D8%AF%20%D8%A7%D9%84%D9%88%D9%87%D8%A7%D8%A8%20%20%20%D9%83%D8%AA%D8%A7%D8%A8%20%D8%A7%D9%84%D8%AA%D9%88%D8%AD%D9%8A%D8%AF.pdf',
        'imageUrl':'https://ia801705.us.archive.org/BookReader/BookReaderImages.php?zip=/32/items/01282-pdf/01282%20%D9%83%D8%AA%D8%A7%D8%A8%20%20%20%20%20pdf%20%20%D8%A7%D9%84%D8%B4%D9%8A%D8%AE%20%D9%85%D8%AD%D9%85%D8%AF%20%D8%A8%D9%86%20%D8%B9%D8%A8%D8%AF%20%D8%A7%D9%84%D9%88%D9%87%D8%A7%D8%A8%20%20%20%D9%83%D8%AA%D8%A7%D8%A8%20%D8%A7%D9%84%D8%AA%D9%88%D8%AD%D9%8A%D8%AF_jp2.zip&file=01282%20%D9%83%D8%AA%D8%A7%D8%A8%20%20%20%20%20pdf%20%20%D8%A7%D9%84%D8%B4%D9%8A%D8%AE%20%D9%85%D8%AD%D9%85%D8%AF%20%D8%A8%D9%86%20%D8%B9%D8%A8%D8%AF%20%D8%A7%D9%84%D9%88%D9%87%D8%A7%D8%A8%20%20%20%D9%83%D8%AA%D8%A7%D8%A8%20%D8%A7%D9%84%D8%AA%D9%88%D8%AD%D9%8A%D8%AF_jp2/01282%20%D9%83%D8%AA%D8%A7%D8%A8%20%20%20%20%20pdf%20%20%D8%A7%D9%84%D8%B4%D9%8A%D8%AE%20%D9%85%D8%AD%D9%85%D8%AF%20%D8%A8%D9%86%20%D8%B9%D8%A8%D8%AF%20%D8%A7%D9%84%D9%88%D9%87%D8%A7%D8%A8%20%20%20%D9%83%D8%AA%D8%A7%D8%A8%20%D8%A7%D9%84%D8%AA%D9%88%D8%AD%D9%8A%D8%AF_0000.jp2&id=01282-pdf&scale=8&rotate=0'
      },
      {'id': 'wasitiyyah',
        'title': 'العقيدة الواسطية',
        'calligraphy': 'العقيدة\nالواسطية',
        'color': const Color(0xFF4A708B),
        'bottomColor': const Color(0xFF365266),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/compress/ErhELAQIDETILWASITIJJETI01MuhammedB.SalihElUsejmin/formats=IMAGE%20CONTAINER%20PDF&file=/ErhELAQIDETILWASITIJJETI01MuhammedB.SalihElUsejmin.zip',
        'imageUrl': 'https://ia803400.us.archive.org/BookReader/BookReaderImages.php?zip=/2/items/ErhELAQIDETILWASITIJJETI01MuhammedB.SalihElUsejmin/%C5%A0erh%20EL-%27AQIDETI-L-WASITIJJETI%20%2001%20%20%20-%20%20%20Muhammed%20b.%20Salih%20el-%27Usejmin_jp2.zip&file=%C5%A0erh%20EL-%27AQIDETI-L-WASITIJJETI%20%2001%20%20%20-%20%20%20Muhammed%20b.%20Salih%20el-%27Usejmin_jp2/%C5%A0erh%20EL-%27AQIDETI-L-WASITIJJETI%20%2001%20%20%20-%20%20%20Muhammed%20b.%20Salih%20el-%27Usejmin_0000.jp2&id=ErhELAQIDETILWASITIJJETI01MuhammedB.SalihElUsejmin&scale=8&rotate=0',
      },
      {'id': 'madarij',
        'title': 'مدارج السالكين',
        'calligraphy': 'مدارج\nالسالكين',
        'color': const Color(0xFF556B2F),
        'bottomColor': const Color(0xFF3E4E22),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/compress/1_20240911_20240911/formats=IMAGE%20CONTAINER%20PDF&file=/1_20240911_20240911.zip',
        'imageUrl' : 'https://ia600802.us.archive.org/BookReader/BookReaderImages.php?zip=/32/items/1_20240911_20240911/1_jp2.zip&file=1_jp2/1_0000.jp2&id=1_20240911_20240911&scale=4&rotate=0',
      },
    ],
    'الفقه وأصوله': [
      {'id': 'bulugh',
        'title': 'بلوغ المرام',
        'calligraphy': 'بلوغ\nالمرام',
        'color': const Color(0xFF8B4513),
        'bottomColor': const Color(0xFF66330E),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/download/145220/145220.pdf',
        'imageUrl' : 'https://ia903208.us.archive.org/BookReader/BookReaderImages.php?zip=/31/items/145220/145220_jp2.zip&file=145220_jp2/145220_0000.jp2&id=145220&scale=8&rotate=0',
      },
      {'id': 'zad',
        'title': 'زاد المستقنع',
        'calligraphy': 'زاد\nالمستقنع',
        'color': const Color(0xFFA0522D),
        'bottomColor': const Color(0xFF7A3E22),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/download/20250611_20250611_1217/%D8%A7%D9%84%D8%B4%D8%B1%D8%AD%20%D8%A7%D9%84%D9%85%D9%85%D8%AA%D8%B9%20%D9%84%D8%A7%D8%A8%D9%86%20%D8%B9%D8%AB%D9%8A%D9%85%D9%8A%D9%86%20%D9%85%D9%81%D9%87%D8%B1%D8%B3.pdf',
        'imageUrl' : 'https://ia801701.us.archive.org/BookReader/BookReaderImages.php?zip=/7/items/20240928_20240928_1138/%D8%A7%D9%84%D8%B4%D8%B1%D8%AD%20%D8%A7%D9%84%D9%85%D9%85%D8%AA%D8%B9%20%D8%B9%D9%84%D9%89%20%D8%B2%D8%A7%D8%AF%20%D8%A7%D9%84%D9%85%D8%B3%D8%AA%D9%82%D9%86%D8%B9%D9%A1%20-%20%D8%A7%D8%A8%D9%86%20%D8%B9%D8%AB%D9%8A%D9%85%D9%8A%D9%86_jp2.zip&file=%D8%A7%D9%84%D8%B4%D8%B1%D8%AD%20%D8%A7%D9%84%D9%85%D9%85%D8%AA%D8%B9%20%D8%B9%D9%84%D9%89%20%D8%B2%D8%A7%D8%AF%20%D8%A7%D9%84%D9%85%D8%B3%D8%AA%D9%82%D9%86%D8%B9%D9%A1%20-%20%D8%A7%D8%A8%D9%86%20%D8%B9%D8%AB%D9%8A%D9%85%D9%8A%D9%86_jp2/%D8%A7%D9%84%D8%B4%D8%B1%D8%AD%20%D8%A7%D9%84%D9%85%D9%85%D8%AA%D8%B9%20%D8%B9%D9%84%D9%89%20%D8%B2%D8%A7%D8%AF%20%D8%A7%D9%84%D9%85%D8%B3%D8%AA%D9%82%D9%86%D8%B9%D9%A1%20-%20%D8%A7%D8%A8%D9%86%20%D8%B9%D8%AB%D9%8A%D9%85%D9%8A%D9%86_0000.jp2&id=20240928_20240928_1138&scale=8&rotate=0',
      },
      {'id': 'umdah',
        'title': 'عمدة الأحكام',
        'calligraphy': 'عمدة\nالأحكام',
        'color': const Color(0xFFCD853F),
        'bottomColor': const Color(0xFF99632F),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/download/01_20240926_202409/%D8%B4%D8%B1%D8%AD%20%D8%B9%D9%85%D8%AF%D8%A9%20%D8%A7%D9%84%D8%A7%D8%AD%D9%83%D8%A7%D9%85-01.pdf',
        'imageUrl' : 'https://ia800601.us.archive.org/BookReader/BookReaderImages.php?zip=/11/items/01_20240926_202409/%D8%B4%D8%B1%D8%AD%20%D8%B9%D9%85%D8%AF%D8%A9%20%D8%A7%D9%84%D8%A7%D8%AD%D9%83%D8%A7%D9%85-01_jp2.zip&file=%D8%B4%D8%B1%D8%AD%20%D8%B9%D9%85%D8%AF%D8%A9%20%D8%A7%D9%84%D8%A7%D8%AD%D9%83%D8%A7%D9%85-01_jp2/%D8%B4%D8%B1%D8%AD%20%D8%B9%D9%85%D8%AF%D8%A9%20%D8%A7%D9%84%D8%A7%D8%AD%D9%83%D8%A7%D9%85-01_0000.jp2&id=01_20240926_202409&scale=2&rotate=0',
      },
    ],
    'السيرة والتاريخ': [
      {'id': 'raheeq',
        'title': 'الرحيق المختوم',
        'calligraphy': 'الرحيق\nالمختوم',
        'color': const Color(0xFF483D8B),
        'bottomColor': const Color(0xFF352D66),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/download/rahiq_makhtoum/%D8%A7%D9%84%D8%B1%D8%AD%D9%8A%D9%82%20%D8%A7%D9%84%D9%85%D8%AE%D8%AA%D9%88%D9%85.pdf',
        'imageUrl' : 'https://ia601208.us.archive.org/BookReader/BookReaderImages.php?zip=/28/items/rahiq_makhtoum/%D8%A7%D9%84%D8%B1%D8%AD%D9%8A%D9%82%20%D8%A7%D9%84%D9%85%D8%AE%D8%AA%D9%88%D9%85_jp2.zip&file=%D8%A7%D9%84%D8%B1%D8%AD%D9%8A%D9%82%20%D8%A7%D9%84%D9%85%D8%AE%D8%AA%D9%88%D9%85_jp2/%D8%A7%D9%84%D8%B1%D8%AD%D9%8A%D9%82%20%D8%A7%D9%84%D9%85%D8%AE%D8%AA%D9%88%D9%85_0000.jp2&id=rahiq_makhtoum&scale=8&rotate=0',
      },
      {'id': 'bidayah',
        'title': 'البداية والنهاية',
        'calligraphy': 'البداية\nوالنهاية',
        'color': const Color(0xFF6A5ACD),
        'bottomColor': const Color(0xFF4C4199),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/compress/04-160924_202207/formats=IMAGE%20CONTAINER%20PDF&file=/04-160924_202207.zip',
        'imageUrl' : 'https://ia601003.us.archive.org/BookReader/BookReaderImages.php?zip=/19/items/04-160924_202207/00_160921_jp2.zip&file=00_160921_jp2/00_160921_0000.jp2&id=04-160924_202207&scale=1&rotate=0',
      },
      {'id': 'siyar',
        'title': 'سير أعلام النبلاء',
        'calligraphy': 'سير أعلام\nالنبلاء',
        'color': const Color(0xFF4B0082),
        'bottomColor': const Color(0xFF36005E),
        'type': 'custom',
        'pdfUrl': 'https://archive.org/download/20230215_20230215_2008/%D8%B3%D9%8A%D8%B1%20%D8%A7%D8%B9%D9%84%D8%A7%D9%85%20%D8%A7%D9%84%D9%86%D8%A8%D9%84%D8%A7%D8%A1.pdf',
        'imageUrl' : 'https://ia801605.us.archive.org/BookReader/BookReaderImages.php?zip=/13/items/20230215_20230215_2008/%D8%B3%D9%8A%D8%B1%20%D8%A7%D8%B9%D9%84%D8%A7%D9%85%20%D8%A7%D9%84%D9%86%D8%A8%D9%84%D8%A7%D8%A1_jp2.zip&file=%D8%B3%D9%8A%D8%B1%20%D8%A7%D8%B9%D9%84%D8%A7%D9%85%20%D8%A7%D9%84%D9%86%D8%A8%D9%84%D8%A7%D8%A1_jp2/%D8%B3%D9%8A%D8%B1%20%D8%A7%D8%B9%D9%84%D8%A7%D9%85%20%D8%A7%D9%84%D9%86%D8%A8%D9%84%D8%A7%D8%A1_0000.jp2&id=20230215_20230215_2008&scale=4&rotate=0',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _checkDownloadedBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkDownloadedBooks() async {
    final dir = await getApplicationDocumentsDirectory();
    Map<String, bool> tempStatus = {};

    _libraryCategories.forEach((category, books) {
      for (var book in books) {
        String id = book['id'];
        if (id == 'riyad') id = 'riyadussalihin';
        if (id == 'nawawi40') id = 'forty';

        File file;
        if (book['type'] == 'hadith') {
          file = File('${dir.path}/hadith_${id}_v1.json');
        } else {
          file = File('${dir.path}/$id.pdf');
        }
        tempStatus[book['id']] = file.existsSync();
      }
    });

    if (mounted) {
      setState(() {
        _downloadedBooks = tempStatus;
      });
    }
  }

  Future<void> _downloadBookFile(Map<String, dynamic> book) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('بدأ تحميل كتاب ${book['title']}...', style: GoogleFonts.cairo()), backgroundColor: _gold, duration: const Duration(seconds: 2)),
    );

    try {
      String id = book['id'];
      if (id == 'riyad') id = 'riyadussalihin';
      if (id == 'nawawi40') id = 'forty';

      String urlString;
      if (book['type'] == 'hadith') {
        urlString = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$id.json';
      } else {
        urlString = book['pdfUrl'] ?? '';
      }

      final response = await http.get(Uri.parse(urlString)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        File file = File('${dir.path}/${book['type'] == 'hadith' ? 'hadith_${id}_v1.json' : '$id.pdf'}');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _downloadedBooks[book['id']] = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم التحميل بنجاح!', style: GoogleFonts.cairo()), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحميل. تأكد من الإنترنت.', style: GoogleFonts.cairo()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBookFile(Map<String, dynamic> book) async {
    try {
      String id = book['id'];
      if (id == 'riyad') id = 'riyadussalihin';
      if (id == 'nawawi40') id = 'forty';

      final dir = await getApplicationDocumentsDirectory();
      File filePdf = File('${dir.path}/$id.pdf');
      File fileJson = File('${dir.path}/hadith_${id}_v1.json');

      if (await filePdf.exists()) await filePdf.delete();
      if (await fileJson.exists()) await fileJson.delete();

      setState(() {
        _downloadedBooks[book['id']] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الكتاب.', style: GoogleFonts.cairo()), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      // Ignore
    }
  }

  // ✅ متغيرات التصميم الديناميكي كدوال Getter للحصول عليها بسهولة
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? _bgDark : const Color(0xFFF5F7FA);
  Color get textColorMain => isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get textColorSub => isDark ? Colors.white54 : Colors.black54;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('المكتبة الإسلامية', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24, color: textColorMain)),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColorMain),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // مربع البحث والفلاتر
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2)),
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          style: GoogleFonts.cairo(color: textColorMain),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن كتاب...',
                            hintStyle: GoogleFonts.cairo(color: textColorSub),
                            prefixIcon: Icon(Icons.search, color: _gold),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // فلاتر الأقسام
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categoriesList.map((category) => _buildFilterChip(category)).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // بانر الآية/الحديث
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildDailyBanner(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 25)),

              // قوائم الكتب حسب الأقسام
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final entry = _libraryCategories.entries.elementAt(index);
                    if (_selectedCategory != 'الكل' && entry.key != _selectedCategory) {
                      return const SizedBox.shrink();
                    }

                    List<Map<String, dynamic>> searchedBooks = entry.value.where((book) {
                      return book['title'].toString().contains(_searchQuery);
                    }).toList();

                    if (searchedBooks.isEmpty) return const SizedBox.shrink();

                    return _buildCategorySection(entry.key, searchedBooks);
                  },
                  childCount: _libraryCategories.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _gold.withOpacity(isDark ? 0.2 : 0.8) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _gold.withOpacity(isDark ? 0.5 : 1.0) : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3))),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? (isDark ? _gold : Colors.white) : textColorSub,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyBanner() {
    int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    Map<String, dynamic> todayBanner = _dailyBanners[dayOfYear % _dailyBanners.length];

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: todayBanner['colors'], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Center(
        child: Text(
          todayBanner['text'],
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String categoryName, List<Map<String, dynamic>> books) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 24, decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Text(categoryName, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: textColorMain)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.60, // تجنب الـ Overflow
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return _buildGridBookCard(books[index] as Map<String, dynamic>, isDark, textColorMain);
            },
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildGridBookCard(Map<String, dynamic> book, bool isDark, Color mainText) {
    final bool isDownloaded = _downloadedBooks[book['id']] ?? false;
    final String imageUrl = book['imageUrl'] ?? '';

    return GestureDetector(
      onTap: () {
        if (book['type'] == 'hadith') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HadithBookScreen(bookId: book['id'], bookTitle: book['title'], primaryColor: widget.primaryColor)))
              .then((_) => _checkDownloadedBooks());
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BookReaderScreen(bookId: book['id'], bookTitle: book['title'], primaryColor: widget.primaryColor, pdfUrl: book['pdfUrl'] ?? '')))
              .then((_) => _checkDownloadedBooks());
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // للتأكد من أخذ العرض كامل
        children: [
          // 1. منطقة الغلاف (تأخذ المساحة الأكبر)
          Expanded(
            child: Stack(
              children: [
                // الغلاف الزجاجي/الظل
                Container(
                  width: double.infinity,
                  height: double.infinity, // لضمان التساوي التام
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: isDark ? Colors.black54 : Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: _bgCard, child: Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 2))),
                      errorWidget: (context, url, error) => Container(color: _bgCard, child: Icon(Icons.book, color: _gold.withOpacity(0.5), size: 40)),
                    )
                        : Container(color: _bgCard, child: Icon(Icons.book, color: _gold.withOpacity(0.5), size: 40)),
                  ),
                ),

                // أيقونة التحميل المدمجة
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (!isDownloaded) _downloadBookFile(book);
                      else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: _bgCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _gold.withOpacity(0.3))),
                            title: Text('إدارة التنزيلات', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                            content: Text('هل ترغب في حذف هذا الكتاب لتوفير المساحة؟', style: GoogleFonts.cairo(color: Colors.white70)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey))),
                              TextButton(onPressed: () { Navigator.pop(context); _deleteBookFile(book); }, child: Text('حذف', style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDownloaded ? Colors.green.withOpacity(0.9) : Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(isDownloaded ? Icons.check : Icons.cloud_download, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // 2. منطقة النص (ارتفاع ثابت لضمان التساوي بين كل البطاقات)
          SizedBox(
            height: 45, // ارتفاع ثابت يسمح بسطرين كحد أقصى (لا يتغير بين الكتب)
            child: Text(
              book['title'],
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(color: mainText, fontSize: 12, fontWeight: FontWeight.bold, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // لضمان عدم حدوث Overflow
            ),
          ),

        ],
      ),
    );
  }

}