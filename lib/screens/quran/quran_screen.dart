import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/screens/quran/quran_search_delegate.dart';
import 'package:islamic_app/screens/quran/surah_detail/surah_deatil.dart';
import 'quran_roots_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController =
  TextEditingController();
  List<Map<String, dynamic>> filteredSurahs = [];
  String selectedFilter = 'الكل';
  final Color _gold = const Color(0xFFE6B325);
  late TabController _mainTabController;
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnim;

  final List<Map<String, dynamic>> surahs = [
    {'name': 'الفاتحة', 'english': 'Al-Fatiha', 'number': 1, 'ayahs': 7, 'type': 'مكية', 'juz': 1},
    {'name': 'البقرة', 'english': 'Al-Baqarah', 'number': 2, 'ayahs': 286, 'type': 'مدنية', 'juz': 1},
    {'name': 'آل عمران', 'english': 'Aal-Imran', 'number': 3, 'ayahs': 200, 'type': 'مدنية', 'juz': 3},
    {'name': 'النساء', 'english': 'An-Nisa', 'number': 4, 'ayahs': 176, 'type': 'مدنية', 'juz': 4},
    {'name': 'المائدة', 'english': 'Al-Maidah', 'number': 5, 'ayahs': 120, 'type': 'مدنية', 'juz': 6},
    {'name': 'الأنعام', 'english': 'Al-Anam', 'number': 6, 'ayahs': 165, 'type': 'مكية', 'juz': 7},
    {'name': 'الأعراف', 'english': 'Al-Araf', 'number': 7, 'ayahs': 206, 'type': 'مكية', 'juz': 8},
    {'name': 'الأنفال', 'english': 'Al-Anfal', 'number': 8, 'ayahs': 75, 'type': 'مدنية', 'juz': 9},
    {'name': 'التوبة', 'english': 'At-Tawbah', 'number': 9, 'ayahs': 129, 'type': 'مدنية', 'juz': 10},
    {'name': 'يونس', 'english': 'Yunus', 'number': 10, 'ayahs': 109, 'type': 'مكية', 'juz': 11},
    {'name': 'هود', 'english': 'Hud', 'number': 11, 'ayahs': 123, 'type': 'مكية', 'juz': 11},
    {'name': 'يوسف', 'english': 'Yusuf', 'number': 12, 'ayahs': 111, 'type': 'مكية', 'juz': 12},
    {'name': 'الرعد', 'english': 'Ar-Rad', 'number': 13, 'ayahs': 43, 'type': 'مدنية', 'juz': 13},
    {'name': 'إبراهيم', 'english': 'Ibrahim', 'number': 14, 'ayahs': 52, 'type': 'مكية', 'juz': 13},
    {'name': 'الحجر', 'english': 'Al-Hijr', 'number': 15, 'ayahs': 99, 'type': 'مكية', 'juz': 14},
    {'name': 'النحل', 'english': 'An-Nahl', 'number': 16, 'ayahs': 128, 'type': 'مكية', 'juz': 14},
    {'name': 'الإسراء', 'english': 'Al-Isra', 'number': 17, 'ayahs': 111, 'type': 'مكية', 'juz': 15},
    {'name': 'الكهف', 'english': 'Al-Kahf', 'number': 18, 'ayahs': 110, 'type': 'مكية', 'juz': 15},
    {'name': 'مريم', 'english': 'Maryam', 'number': 19, 'ayahs': 98, 'type': 'مكية', 'juz': 16},
    {'name': 'طه', 'english': 'Ta-Ha', 'number': 20, 'ayahs': 135, 'type': 'مكية', 'juz': 16},
    {'name': 'الأنبياء', 'english': 'Al-Anbiya', 'number': 21, 'ayahs': 112, 'type': 'مكية', 'juz': 17},
    {'name': 'الحج', 'english': 'Al-Hajj', 'number': 22, 'ayahs': 78, 'type': 'مدنية', 'juz': 17},
    {'name': 'المؤمنون', 'english': 'Al-Muminun', 'number': 23, 'ayahs': 118, 'type': 'مكية', 'juz': 18},
    {'name': 'النور', 'english': 'An-Nur', 'number': 24, 'ayahs': 64, 'type': 'مدنية', 'juz': 18},
    {'name': 'الفرقان', 'english': 'Al-Furqan', 'number': 25, 'ayahs': 77, 'type': 'مكية', 'juz': 18},
    {'name': 'الشعراء', 'english': 'Ash-Shuara', 'number': 26, 'ayahs': 227, 'type': 'مكية', 'juz': 19},
    {'name': 'النمل', 'english': 'An-Naml', 'number': 27, 'ayahs': 93, 'type': 'مكية', 'juz': 19},
    {'name': 'القصص', 'english': 'Al-Qasas', 'number': 28, 'ayahs': 88, 'type': 'مكية', 'juz': 20},
    {'name': 'العنكبوت', 'english': 'Al-Ankabut', 'number': 29, 'ayahs': 69, 'type': 'مكية', 'juz': 20},
    {'name': 'الروم', 'english': 'Ar-Rum', 'number': 30, 'ayahs': 60, 'type': 'مكية', 'juz': 21},
    {'name': 'لقمان', 'english': 'Luqman', 'number': 31, 'ayahs': 34, 'type': 'مكية', 'juz': 21},
    {'name': 'السجدة', 'english': 'As-Sajdah', 'number': 32, 'ayahs': 30, 'type': 'مكية', 'juz': 21},
    {'name': 'الأحزاب', 'english': 'Al-Ahzab', 'number': 33, 'ayahs': 73, 'type': 'مدنية', 'juz': 21},
    {'name': 'سبأ', 'english': 'Saba', 'number': 34, 'ayahs': 54, 'type': 'مكية', 'juz': 22},
    {'name': 'فاطر', 'english': 'Fatir', 'number': 35, 'ayahs': 45, 'type': 'مكية', 'juz': 22},
    {'name': 'يس', 'english': 'Ya-Sin', 'number': 36, 'ayahs': 83, 'type': 'مكية', 'juz': 22},
    {'name': 'الصافات', 'english': 'As-Saffat', 'number': 37, 'ayahs': 182, 'type': 'مكية', 'juz': 23},
    {'name': 'ص', 'english': 'Sad', 'number': 38, 'ayahs': 88, 'type': 'مكية', 'juz': 23},
    {'name': 'الزمر', 'english': 'Az-Zumar', 'number': 39, 'ayahs': 75, 'type': 'مكية', 'juz': 23},
    {'name': 'غافر', 'english': 'Ghafir', 'number': 40, 'ayahs': 85, 'type': 'مكية', 'juz': 24},
    {'name': 'فصلت', 'english': 'Fussilat', 'number': 41, 'ayahs': 54, 'type': 'مكية', 'juz': 24},
    {'name': 'الشورى', 'english': 'Ash-Shura', 'number': 42, 'ayahs': 53, 'type': 'مكية', 'juz': 25},
    {'name': 'الزخرف', 'english': 'Az-Zukhruf', 'number': 43, 'ayahs': 89, 'type': 'مكية', 'juz': 25},
    {'name': 'الدخان', 'english': 'Ad-Dukhan', 'number': 44, 'ayahs': 59, 'type': 'مكية', 'juz': 25},
    {'name': 'الجاثية', 'english': 'Al-Jathiyah', 'number': 45, 'ayahs': 37, 'type': 'مكية', 'juz': 25},
    {'name': 'الأحقاف', 'english': 'Al-Ahqaf', 'number': 46, 'ayahs': 35, 'type': 'مكية', 'juz': 26},
    {'name': 'محمد', 'english': 'Muhammad', 'number': 47, 'ayahs': 38, 'type': 'مدنية', 'juz': 26},
    {'name': 'الفتح', 'english': 'Al-Fath', 'number': 48, 'ayahs': 29, 'type': 'مدنية', 'juz': 26},
    {'name': 'الحجرات', 'english': 'Al-Hujurat', 'number': 49, 'ayahs': 18, 'type': 'مدنية', 'juz': 26},
    {'name': 'ق', 'english': 'Qaf', 'number': 50, 'ayahs': 45, 'type': 'مكية', 'juz': 26},
    {'name': 'الذاريات', 'english': 'Adh-Dhariyat', 'number': 51, 'ayahs': 60, 'type': 'مكية', 'juz': 26},
    {'name': 'الطور', 'english': 'At-Tur', 'number': 52, 'ayahs': 49, 'type': 'مكية', 'juz': 27},
    {'name': 'النجم', 'english': 'An-Najm', 'number': 53, 'ayahs': 62, 'type': 'مكية', 'juz': 27},
    {'name': 'القمر', 'english': 'Al-Qamar', 'number': 54, 'ayahs': 55, 'type': 'مكية', 'juz': 27},
    {'name': 'الرحمن', 'english': 'Ar-Rahman', 'number': 55, 'ayahs': 78, 'type': 'مدنية', 'juz': 27},
    {'name': 'الواقعة', 'english': 'Al-Waqiah', 'number': 56, 'ayahs': 96, 'type': 'مكية', 'juz': 27},
    {'name': 'الحديد', 'english': 'Al-Hadid', 'number': 57, 'ayahs': 29, 'type': 'مدنية', 'juz': 27},
    {'name': 'المجادلة', 'english': 'Al-Mujadilah', 'number': 58, 'ayahs': 22, 'type': 'مدنية', 'juz': 28},
    {'name': 'الحشر', 'english': 'Al-Hashr', 'number': 59, 'ayahs': 24, 'type': 'مدنية', 'juz': 28},
    {'name': 'الممتحنة', 'english': 'Al-Mumtahanah', 'number': 60, 'ayahs': 13, 'type': 'مدنية', 'juz': 28},
    {'name': 'الصف', 'english': 'As-Saff', 'number': 61, 'ayahs': 14, 'type': 'مدنية', 'juz': 28},
    {'name': 'الجمعة', 'english': 'Al-Jumuah', 'number': 62, 'ayahs': 11, 'type': 'مدنية', 'juz': 28},
    {'name': 'المنافقون', 'english': 'Al-Munafiqun', 'number': 63, 'ayahs': 11, 'type': 'مدنية', 'juz': 28},
    {'name': 'التغابن', 'english': 'At-Taghabun', 'number': 64, 'ayahs': 18, 'type': 'مدنية', 'juz': 28},
    {'name': 'الطلاق', 'english': 'At-Talaq', 'number': 65, 'ayahs': 12, 'type': 'مدنية', 'juz': 28},
    {'name': 'التحريم', 'english': 'At-Tahrim', 'number': 66, 'ayahs': 12, 'type': 'مدنية', 'juz': 28},
    {'name': 'الملك', 'english': 'Al-Mulk', 'number': 67, 'ayahs': 30, 'type': 'مكية', 'juz': 29},
    {'name': 'القلم', 'english': 'Al-Qalam', 'number': 68, 'ayahs': 52, 'type': 'مكية', 'juz': 29},
    {'name': 'الحاقة', 'english': 'Al-Haqqah', 'number': 69, 'ayahs': 52, 'type': 'مكية', 'juz': 29},
    {'name': 'المعارج', 'english': 'Al-Maarij', 'number': 70, 'ayahs': 44, 'type': 'مكية', 'juz': 29},
    {'name': 'نوح', 'english': 'Nuh', 'number': 71, 'ayahs': 28, 'type': 'مكية', 'juz': 29},
    {'name': 'الجن', 'english': 'Al-Jinn', 'number': 72, 'ayahs': 28, 'type': 'مكية', 'juz': 29},
    {'name': 'المزمل', 'english': 'Al-Muzzammil', 'number': 73, 'ayahs': 20, 'type': 'مكية', 'juz': 29},
    {'name': 'المدثر', 'english': 'Al-Muddaththir', 'number': 74, 'ayahs': 56, 'type': 'مكية', 'juz': 29},
    {'name': 'القيامة', 'english': 'Al-Qiyamah', 'number': 75, 'ayahs': 40, 'type': 'مكية', 'juz': 29},
    {'name': 'الإنسان', 'english': 'Al-Insan', 'number': 76, 'ayahs': 31, 'type': 'مدنية', 'juz': 29},
    {'name': 'المرسلات', 'english': 'Al-Mursalat', 'number': 77, 'ayahs': 50, 'type': 'مكية', 'juz': 29},
    {'name': 'النبأ', 'english': 'An-Naba', 'number': 78, 'ayahs': 40, 'type': 'مكية', 'juz': 30},
    {'name': 'النازعات', 'english': 'An-Naziat', 'number': 79, 'ayahs': 46, 'type': 'مكية', 'juz': 30},
    {'name': 'عبس', 'english': 'Abasa', 'number': 80, 'ayahs': 42, 'type': 'مكية', 'juz': 30},
    {'name': 'التكوير', 'english': 'At-Takwir', 'number': 81, 'ayahs': 29, 'type': 'مكية', 'juz': 30},
    {'name': 'الانفطار', 'english': 'Al-Infitar', 'number': 82, 'ayahs': 19, 'type': 'مكية', 'juz': 30},
    {'name': 'المطففين', 'english': 'Al-Mutaffifin', 'number': 83, 'ayahs': 36, 'type': 'مكية', 'juz': 30},
    {'name': 'الانشقاق', 'english': 'Al-Inshiqaq', 'number': 84, 'ayahs': 25, 'type': 'مكية', 'juz': 30},
    {'name': 'البروج', 'english': 'Al-Buruj', 'number': 85, 'ayahs': 22, 'type': 'مكية', 'juz': 30},
    {'name': 'الطارق', 'english': 'At-Tariq', 'number': 86, 'ayahs': 17, 'type': 'مكية', 'juz': 30},
    {'name': 'الأعلى', 'english': 'Al-Ala', 'number': 87, 'ayahs': 19, 'type': 'مكية', 'juz': 30},
    {'name': 'الغاشية', 'english': 'Al-Ghashiyah', 'number': 88, 'ayahs': 26, 'type': 'مكية', 'juz': 30},
    {'name': 'الفجر', 'english': 'Al-Fajr', 'number': 89, 'ayahs': 30, 'type': 'مكية', 'juz': 30},
    {'name': 'البلد', 'english': 'Al-Balad', 'number': 90, 'ayahs': 20, 'type': 'مكية', 'juz': 30},
    {'name': 'الشمس', 'english': 'Ash-Shams', 'number': 91, 'ayahs': 15, 'type': 'مكية', 'juz': 30},
    {'name': 'الليل', 'english': 'Al-Layl', 'number': 92, 'ayahs': 21, 'type': 'مكية', 'juz': 30},
    {'name': 'الضحى', 'english': 'Ad-Duha', 'number': 93, 'ayahs': 11, 'type': 'مكية', 'juz': 30},
    {'name': 'الشرح', 'english': 'Ash-Sharh', 'number': 94, 'ayahs': 8, 'type': 'مكية', 'juz': 30},
    {'name': 'التين', 'english': 'At-Tin', 'number': 95, 'ayahs': 8, 'type': 'مكية', 'juz': 30},
    {'name': 'العلق', 'english': 'Al-Alaq', 'number': 96, 'ayahs': 19, 'type': 'مكية', 'juz': 30},
    {'name': 'القدر', 'english': 'Al-Qadr', 'number': 97, 'ayahs': 5, 'type': 'مكية', 'juz': 30},
    {'name': 'البينة', 'english': 'Al-Bayyinah', 'number': 98, 'ayahs': 8, 'type': 'مدنية', 'juz': 30},
    {'name': 'الزلزلة', 'english': 'Az-Zalzalah', 'number': 99, 'ayahs': 8, 'type': 'مدنية', 'juz': 30},
    {'name': 'العاديات', 'english': 'Al-Adiyat', 'number': 100, 'ayahs': 11, 'type': 'مكية', 'juz': 30},
    {'name': 'القارعة', 'english': 'Al-Qariah', 'number': 101, 'ayahs': 11, 'type': 'مكية', 'juz': 30},
    {'name': 'التكاثر', 'english': 'At-Takathur', 'number': 102, 'ayahs': 8, 'type': 'مكية', 'juz': 30},
    {'name': 'العصر', 'english': 'Al-Asr', 'number': 103, 'ayahs': 3, 'type': 'مكية', 'juz': 30},
    {'name': 'الهمزة', 'english': 'Al-Humazah', 'number': 104, 'ayahs': 9, 'type': 'مكية', 'juz': 30},
    {'name': 'الفيل', 'english': 'Al-Fil', 'number': 105, 'ayahs': 5, 'type': 'مكية', 'juz': 30},
    {'name': 'قريش', 'english': 'Quraysh', 'number': 106, 'ayahs': 4, 'type': 'مكية', 'juz': 30},
    {'name': 'الماعون', 'english': 'Al-Maun', 'number': 107, 'ayahs': 7, 'type': 'مكية', 'juz': 30},
    {'name': 'الكوثر', 'english': 'Al-Kawthar', 'number': 108, 'ayahs': 3, 'type': 'مكية', 'juz': 30},
    {'name': 'الكافرون', 'english': 'Al-Kafirun', 'number': 109, 'ayahs': 6, 'type': 'مكية', 'juz': 30},
    {'name': 'النصر', 'english': 'An-Nasr', 'number': 110, 'ayahs': 3, 'type': 'مدنية', 'juz': 30},
    {'name': 'المسد', 'english': 'Al-Masad', 'number': 111, 'ayahs': 5, 'type': 'مكية', 'juz': 30},
    {'name': 'الإخلاص', 'english': 'Al-Ikhlas', 'number': 112, 'ayahs': 4, 'type': 'مكية', 'juz': 30},
    {'name': 'الفلق', 'english': 'Al-Falaq', 'number': 113, 'ayahs': 5, 'type': 'مكية', 'juz': 30},
    {'name': 'الناس', 'english': 'An-Nas', 'number': 114, 'ayahs': 6, 'type': 'مكية', 'juz': 30},
  ];

  @override
  void initState() {
    super.initState();
    filteredSurahs = surahs;
    _mainTabController = TabController(length: 2, vsync: this);
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _headerAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutBack,
    );
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mainTabController.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  void _filterSurahs(String query) {
    setState(() {
      filteredSurahs = surahs.where((s) {
        final matchesSearch = query.isEmpty ||
            s['name'].toString().contains(query) ||
            s['number'].toString().contains(query);
        final matchesFilter =
            selectedFilter == 'الكل' || s['type'] == selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _setFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      _filterSurahs(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor =
    isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA);
    final cardColor =
    isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final textColorMain =
    isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub =
    isDark ? Colors.white54 : Colors.black54;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : _gold.withValues(alpha: 0.2);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.grey.withValues(alpha: 0.1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: isDark
                    ? const Color(0xFF0A0E17)
                    : const Color(0xFF6B3410),
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search,
                          color: Colors.white),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate:
                          QuranSearch(primaryColor: primary),
                        ).then((result) {
                          if (result != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurahDetailScreen(
                                  surahName: result['surahName'],
                                  surahNumber:
                                  result['surahNumber'],
                                  initialPage: result['page'],
                                ),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(isDark),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: _buildTabBar(isDark, textColorSub),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _mainTabController,
            children: [
              // â”€â”€ ط§ظ„طھط¨ظˆظٹط¨ ط§ظ„ط£ظˆظ„: ط§ظ„ط³ظˆط± â”€â”€
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          20, 16, 20, 0),
                      child: Column(
                        children: [
                          _buildSearchBar(cardColor, textColorMain,
                              textColorSub, borderColor, shadowColor),
                          const SizedBox(height: 16),
                          _buildFilterRow(isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildSurahCard(
                          filteredSurahs[index],
                          isDark,
                          cardColor,
                          textColorMain,
                          textColorSub,
                          borderColor,
                          shadowColor,
                        ),
                        childCount: filteredSurahs.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 20)),
                ],
              ),

              // â”€â”€ ط§ظ„طھط¨ظˆظٹط¨ ط§ظ„ط«ط§ظ†ظٹ: ط¬ط°ظˆط± ط§ظ„ظƒظ„ظ…ط§طھ â”€â”€
              const QuranRootsScreen(),
            ],
          ),
        ),
      ),
    );
  }

  // âœ… ط§ظ„ظ‡ظٹط¯ط± ط§ظ„ط¬ط¯ظٹط¯ ط§ظ„ط¬ظ…ظٹظ„
  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
            const Color(0xFF1A0A00),
            const Color(0xFF2D1200),
            const Color(0xFF0A0E17),
          ]
              : [
            const Color(0xFF4A1A05),
            const Color(0xFF8B4513),
            const Color(0xFFD4AF37),
          ],
        ),
      ),
      child: Stack(
        children: [
          // âœ… ط¯ظˆط§ط¦ط± ط²ط®ط±ظپظٹط© ظپظٹ ط§ظ„ط®ظ„ظپظٹط©
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.05),
                border: Border.all(
                    color: _gold.withValues(alpha: 0.1), width: 1),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.05),
              ),
            ),
          ),

          // âœ… ط§ظ„ظ…ط­طھظˆظ‰ ط§ظ„ط±ط¦ظٹط³ظٹ
          SafeArea(
            child: ScaleTransition(
              scale: _headerAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // âœ… ط£ظٹظ‚ظˆظ†ط© ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ط¬ط¯ظٹط¯ط©
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // ظ‡ط§ظ„ط© ط®ط§ط±ط¬ظٹط©
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      // ظ‡ط§ظ„ط© ظˆط³ط·ظ‰
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _gold.withValues(alpha: 0.08),
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // ط§ظ„ط£ظٹظ‚ظˆظ†ط©
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _gold.withValues(alpha: 0.3),
                              _gold.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '﷽',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // âœ… ط§ظ„ط¹ظ†ظˆط§ظ†
                  Text(
                    'القرآن الكريم',
                    style: GoogleFonts.amiri(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // âœ… ط§ظ„ط¢ظٹط© ط§ظ„ظƒط±ظٹظ…ط©
                  Text(
                    'إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 13,
                      color: _gold.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // âœ… ط¥ط­طµط§ط¦ظٹط§طھ طµط؛ظٹط±ط©
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      _buildStatChip('١١٤', 'سورة'),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12),
                      ),
                      _buildStatChip('٦٢٣٦', 'آية'),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12),
                      ),
                      _buildStatChip('٣٠', 'جزءاً'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // âœ… ط¥ط­طµط§ط¦ظٹط© طµط؛ظٹط±ط©
  Widget _buildStatChip(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _gold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  // âœ… ط´ط±ظٹط· ط§ظ„طھط¨ظˆظٹط¨ط§طھ ط§ظ„ط¬ظ…ظٹظ„
  Widget _buildTabBar(bool isDark, Color textColorSub) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0E17)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _mainTabController,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _gold, width: 3),
          ),
        ),
        labelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle:
        GoogleFonts.cairo(fontSize: 13),
        labelColor: _gold,
        unselectedLabelColor: textColorSub,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 18),
                SizedBox(width: 6),
                Text('السور'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_tree_outlined, size: 18),
                SizedBox(width: 6),
                Text('جذور الكلمات'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      Color cardColor,
      Color textColorMain,
      Color textColorSub,
      Color borderColor,
      Color shadowColor,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSurahs,
        style: GoogleFonts.cairo(color: textColorMain),
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة بالاسم أو الرقم...',
          hintStyle: GoogleFonts.cairo(color: textColorSub),
          prefixIcon: Icon(Icons.search, color: _gold),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon:
            Icon(Icons.clear, color: textColorSub),
            onPressed: () {
              _searchController.clear();
              _filterSurahs('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('الكل', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('مكية', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('مدنية', isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => _setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _gold.withValues(alpha: isDark ? 0.2 : 0.85)
              : (isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _gold
                : (isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.3)),
          ),
          boxShadow: isSelected && !isDark
              ? [
            BoxShadow(
                color: _gold.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected
                ? (isDark ? _gold : Colors.white)
                : (isDark
                ? Colors.white70
                : Colors.black87),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahCard(
      Map<String, dynamic> surah,
      bool isDark,
      Color cardColor,
      Color textColorMain,
      Color textColorSub,
      Color borderColor,
      Color shadowColor,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                  surahName: surah['name'],
                  surahNumber: surah['number'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.1),
                    borderRadius:
                    BorderRadius.circular(15),
                    border: Border.all(
                        color: _gold.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '${surah['number']}',
                      style: GoogleFonts.cairo(
                        color: isDark
                            ? _gold
                            : const Color(0xFFB8860B),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah['name'],
                        style: GoogleFonts.amiri(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: textColorMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildBadge(
                            surah['type'],
                            surah['type'] == 'مكية'
                                ? const Color(0xFFE67E22)
                                : const Color(0xFF3498DB),
                          ),
                          Text('${surah['ayahs']} آية',
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: textColorSub)),
                          Text('الجزء ${surah['juz']}',
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: textColorSub)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      surah['english'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: textColorSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.arrow_forward_ios,
                        size: 14,
                        color: _gold.withValues(alpha: 0.5)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}