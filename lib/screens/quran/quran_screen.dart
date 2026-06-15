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
  String selectedFilter = 'ط§ظ„ظƒظ„';
  final Color _gold = const Color(0xFFE6B325);
  late TabController _mainTabController;
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnim;

  final List<Map<String, dynamic>> surahs = [
    {'name': 'ط§ظ„ظپط§طھط­ط©', 'english': 'Al-Fatiha', 'number': 1, 'ayahs': 7, 'type': 'ظ…ظƒظٹط©', 'juz': 1},
    {'name': 'ط§ظ„ط¨ظ‚ط±ط©', 'english': 'Al-Baqarah', 'number': 2, 'ayahs': 286, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 1},
    {'name': 'ط¢ظ„ ط¹ظ…ط±ط§ظ†', 'english': 'Aal-Imran', 'number': 3, 'ayahs': 200, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 3},
    {'name': 'ط§ظ„ظ†ط³ط§ط،', 'english': 'An-Nisa', 'number': 4, 'ayahs': 176, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 4},
    {'name': 'ط§ظ„ظ…ط§ط¦ط¯ط©', 'english': 'Al-Maidah', 'number': 5, 'ayahs': 120, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 6},
    {'name': 'ط§ظ„ط£ظ†ط¹ط§ظ…', 'english': 'Al-Anam', 'number': 6, 'ayahs': 165, 'type': 'ظ…ظƒظٹط©', 'juz': 7},
    {'name': 'ط§ظ„ط£ط¹ط±ط§ظپ', 'english': 'Al-Araf', 'number': 7, 'ayahs': 206, 'type': 'ظ…ظƒظٹط©', 'juz': 8},
    {'name': 'ط§ظ„ط£ظ†ظپط§ظ„', 'english': 'Al-Anfal', 'number': 8, 'ayahs': 75, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 9},
    {'name': 'ط§ظ„طھظˆط¨ط©', 'english': 'At-Tawbah', 'number': 9, 'ayahs': 129, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 10},
    {'name': 'ظٹظˆظ†ط³', 'english': 'Yunus', 'number': 10, 'ayahs': 109, 'type': 'ظ…ظƒظٹط©', 'juz': 11},
    {'name': 'ظ‡ظˆط¯', 'english': 'Hud', 'number': 11, 'ayahs': 123, 'type': 'ظ…ظƒظٹط©', 'juz': 11},
    {'name': 'ظٹظˆط³ظپ', 'english': 'Yusuf', 'number': 12, 'ayahs': 111, 'type': 'ظ…ظƒظٹط©', 'juz': 12},
    {'name': 'ط§ظ„ط±ط¹ط¯', 'english': 'Ar-Rad', 'number': 13, 'ayahs': 43, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 13},
    {'name': 'ط¥ط¨ط±ط§ظ‡ظٹظ…', 'english': 'Ibrahim', 'number': 14, 'ayahs': 52, 'type': 'ظ…ظƒظٹط©', 'juz': 13},
    {'name': 'ط§ظ„ط­ط¬ط±', 'english': 'Al-Hijr', 'number': 15, 'ayahs': 99, 'type': 'ظ…ظƒظٹط©', 'juz': 14},
    {'name': 'ط§ظ„ظ†ط­ظ„', 'english': 'An-Nahl', 'number': 16, 'ayahs': 128, 'type': 'ظ…ظƒظٹط©', 'juz': 14},
    {'name': 'ط§ظ„ط¥ط³ط±ط§ط،', 'english': 'Al-Isra', 'number': 17, 'ayahs': 111, 'type': 'ظ…ظƒظٹط©', 'juz': 15},
    {'name': 'ط§ظ„ظƒظ‡ظپ', 'english': 'Al-Kahf', 'number': 18, 'ayahs': 110, 'type': 'ظ…ظƒظٹط©', 'juz': 15},
    {'name': 'ظ…ط±ظٹظ…', 'english': 'Maryam', 'number': 19, 'ayahs': 98, 'type': 'ظ…ظƒظٹط©', 'juz': 16},
    {'name': 'ط·ظ‡', 'english': 'Ta-Ha', 'number': 20, 'ayahs': 135, 'type': 'ظ…ظƒظٹط©', 'juz': 16},
    {'name': 'ط§ظ„ط£ظ†ط¨ظٹط§ط،', 'english': 'Al-Anbiya', 'number': 21, 'ayahs': 112, 'type': 'ظ…ظƒظٹط©', 'juz': 17},
    {'name': 'ط§ظ„ط­ط¬', 'english': 'Al-Hajj', 'number': 22, 'ayahs': 78, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 17},
    {'name': 'ط§ظ„ظ…ط¤ظ…ظ†ظˆظ†', 'english': 'Al-Muminun', 'number': 23, 'ayahs': 118, 'type': 'ظ…ظƒظٹط©', 'juz': 18},
    {'name': 'ط§ظ„ظ†ظˆط±', 'english': 'An-Nur', 'number': 24, 'ayahs': 64, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 18},
    {'name': 'ط§ظ„ظپط±ظ‚ط§ظ†', 'english': 'Al-Furqan', 'number': 25, 'ayahs': 77, 'type': 'ظ…ظƒظٹط©', 'juz': 18},
    {'name': 'ط§ظ„ط´ط¹ط±ط§ط،', 'english': 'Ash-Shuara', 'number': 26, 'ayahs': 227, 'type': 'ظ…ظƒظٹط©', 'juz': 19},
    {'name': 'ط§ظ„ظ†ظ…ظ„', 'english': 'An-Naml', 'number': 27, 'ayahs': 93, 'type': 'ظ…ظƒظٹط©', 'juz': 19},
    {'name': 'ط§ظ„ظ‚طµطµ', 'english': 'Al-Qasas', 'number': 28, 'ayahs': 88, 'type': 'ظ…ظƒظٹط©', 'juz': 20},
    {'name': 'ط§ظ„ط¹ظ†ظƒط¨ظˆطھ', 'english': 'Al-Ankabut', 'number': 29, 'ayahs': 69, 'type': 'ظ…ظƒظٹط©', 'juz': 20},
    {'name': 'ط§ظ„ط±ظˆظ…', 'english': 'Ar-Rum', 'number': 30, 'ayahs': 60, 'type': 'ظ…ظƒظٹط©', 'juz': 21},
    {'name': 'ظ„ظ‚ظ…ط§ظ†', 'english': 'Luqman', 'number': 31, 'ayahs': 34, 'type': 'ظ…ظƒظٹط©', 'juz': 21},
    {'name': 'ط§ظ„ط³ط¬ط¯ط©', 'english': 'As-Sajdah', 'number': 32, 'ayahs': 30, 'type': 'ظ…ظƒظٹط©', 'juz': 21},
    {'name': 'ط§ظ„ط£ط­ط²ط§ط¨', 'english': 'Al-Ahzab', 'number': 33, 'ayahs': 73, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 21},
    {'name': 'ط³ط¨ط£', 'english': 'Saba', 'number': 34, 'ayahs': 54, 'type': 'ظ…ظƒظٹط©', 'juz': 22},
    {'name': 'ظپط§ط·ط±', 'english': 'Fatir', 'number': 35, 'ayahs': 45, 'type': 'ظ…ظƒظٹط©', 'juz': 22},
    {'name': 'ظٹط³', 'english': 'Ya-Sin', 'number': 36, 'ayahs': 83, 'type': 'ظ…ظƒظٹط©', 'juz': 22},
    {'name': 'ط§ظ„طµط§ظپط§طھ', 'english': 'As-Saffat', 'number': 37, 'ayahs': 182, 'type': 'ظ…ظƒظٹط©', 'juz': 23},
    {'name': 'طµ', 'english': 'Sad', 'number': 38, 'ayahs': 88, 'type': 'ظ…ظƒظٹط©', 'juz': 23},
    {'name': 'ط§ظ„ط²ظ…ط±', 'english': 'Az-Zumar', 'number': 39, 'ayahs': 75, 'type': 'ظ…ظƒظٹط©', 'juz': 23},
    {'name': 'ط؛ط§ظپط±', 'english': 'Ghafir', 'number': 40, 'ayahs': 85, 'type': 'ظ…ظƒظٹط©', 'juz': 24},
    {'name': 'ظپطµظ„طھ', 'english': 'Fussilat', 'number': 41, 'ayahs': 54, 'type': 'ظ…ظƒظٹط©', 'juz': 24},
    {'name': 'ط§ظ„ط´ظˆط±ظ‰', 'english': 'Ash-Shura', 'number': 42, 'ayahs': 53, 'type': 'ظ…ظƒظٹط©', 'juz': 25},
    {'name': 'ط§ظ„ط²ط®ط±ظپ', 'english': 'Az-Zukhruf', 'number': 43, 'ayahs': 89, 'type': 'ظ…ظƒظٹط©', 'juz': 25},
    {'name': 'ط§ظ„ط¯ط®ط§ظ†', 'english': 'Ad-Dukhan', 'number': 44, 'ayahs': 59, 'type': 'ظ…ظƒظٹط©', 'juz': 25},
    {'name': 'ط§ظ„ط¬ط§ط«ظٹط©', 'english': 'Al-Jathiyah', 'number': 45, 'ayahs': 37, 'type': 'ظ…ظƒظٹط©', 'juz': 25},
    {'name': 'ط§ظ„ط£ط­ظ‚ط§ظپ', 'english': 'Al-Ahqaf', 'number': 46, 'ayahs': 35, 'type': 'ظ…ظƒظٹط©', 'juz': 26},
    {'name': 'ظ…ط­ظ…ط¯', 'english': 'Muhammad', 'number': 47, 'ayahs': 38, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 26},
    {'name': 'ط§ظ„ظپطھط­', 'english': 'Al-Fath', 'number': 48, 'ayahs': 29, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 26},
    {'name': 'ط§ظ„ط­ط¬ط±ط§طھ', 'english': 'Al-Hujurat', 'number': 49, 'ayahs': 18, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 26},
    {'name': 'ظ‚', 'english': 'Qaf', 'number': 50, 'ayahs': 45, 'type': 'ظ…ظƒظٹط©', 'juz': 26},
    {'name': 'ط§ظ„ط°ط§ط±ظٹط§طھ', 'english': 'Adh-Dhariyat', 'number': 51, 'ayahs': 60, 'type': 'ظ…ظƒظٹط©', 'juz': 26},
    {'name': 'ط§ظ„ط·ظˆط±', 'english': 'At-Tur', 'number': 52, 'ayahs': 49, 'type': 'ظ…ظƒظٹط©', 'juz': 27},
    {'name': 'ط§ظ„ظ†ط¬ظ…', 'english': 'An-Najm', 'number': 53, 'ayahs': 62, 'type': 'ظ…ظƒظٹط©', 'juz': 27},
    {'name': 'ط§ظ„ظ‚ظ…ط±', 'english': 'Al-Qamar', 'number': 54, 'ayahs': 55, 'type': 'ظ…ظƒظٹط©', 'juz': 27},
    {'name': 'ط§ظ„ط±ط­ظ…ظ†', 'english': 'Ar-Rahman', 'number': 55, 'ayahs': 78, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 27},
    {'name': 'ط§ظ„ظˆط§ظ‚ط¹ط©', 'english': 'Al-Waqiah', 'number': 56, 'ayahs': 96, 'type': 'ظ…ظƒظٹط©', 'juz': 27},
    {'name': 'ط§ظ„ط­ط¯ظٹط¯', 'english': 'Al-Hadid', 'number': 57, 'ayahs': 29, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 27},
    {'name': 'ط§ظ„ظ…ط¬ط§ط¯ظ„ط©', 'english': 'Al-Mujadilah', 'number': 58, 'ayahs': 22, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„ط­ط´ط±', 'english': 'Al-Hashr', 'number': 59, 'ayahs': 24, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„ظ…ظ…طھط­ظ†ط©', 'english': 'Al-Mumtahanah', 'number': 60, 'ayahs': 13, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„طµظپ', 'english': 'As-Saff', 'number': 61, 'ayahs': 14, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„ط¬ظ…ط¹ط©', 'english': 'Al-Jumuah', 'number': 62, 'ayahs': 11, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„ظ…ظ†ط§ظپظ‚ظˆظ†', 'english': 'Al-Munafiqun', 'number': 63, 'ayahs': 11, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„طھط؛ط§ط¨ظ†', 'english': 'At-Taghabun', 'number': 64, 'ayahs': 18, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„ط·ظ„ط§ظ‚', 'english': 'At-Talaq', 'number': 65, 'ayahs': 12, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„طھط­ط±ظٹظ…', 'english': 'At-Tahrim', 'number': 66, 'ayahs': 12, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 28},
    {'name': 'ط§ظ„ظ…ظ„ظƒ', 'english': 'Al-Mulk', 'number': 67, 'ayahs': 30, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ظ‚ظ„ظ…', 'english': 'Al-Qalam', 'number': 68, 'ayahs': 52, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ط­ط§ظ‚ط©', 'english': 'Al-Haqqah', 'number': 69, 'ayahs': 52, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ظ…ط¹ط§ط±ط¬', 'english': 'Al-Maarij', 'number': 70, 'ayahs': 44, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ظ†ظˆط­', 'english': 'Nuh', 'number': 71, 'ayahs': 28, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ط¬ظ†', 'english': 'Al-Jinn', 'number': 72, 'ayahs': 28, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ظ…ط²ظ…ظ„', 'english': 'Al-Muzzammil', 'number': 73, 'ayahs': 20, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ظ…ط¯ط«ط±', 'english': 'Al-Muddaththir', 'number': 74, 'ayahs': 56, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ظ‚ظٹط§ظ…ط©', 'english': 'Al-Qiyamah', 'number': 75, 'ayahs': 40, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ط¥ظ†ط³ط§ظ†', 'english': 'Al-Insan', 'number': 76, 'ayahs': 31, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ظ…ط±ط³ظ„ط§طھ', 'english': 'Al-Mursalat', 'number': 77, 'ayahs': 50, 'type': 'ظ…ظƒظٹط©', 'juz': 29},
    {'name': 'ط§ظ„ظ†ط¨ط£', 'english': 'An-Naba', 'number': 78, 'ayahs': 40, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ†ط§ط²ط¹ط§طھ', 'english': 'An-Naziat', 'number': 79, 'ayahs': 46, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط¹ط¨ط³', 'english': 'Abasa', 'number': 80, 'ayahs': 42, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„طھظƒظˆظٹط±', 'english': 'At-Takwir', 'number': 81, 'ayahs': 29, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط§ظ†ظپط·ط§ط±', 'english': 'Al-Infitar', 'number': 82, 'ayahs': 19, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ…ط·ظپظپظٹظ†', 'english': 'Al-Mutaffifin', 'number': 83, 'ayahs': 36, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط§ظ†ط´ظ‚ط§ظ‚', 'english': 'Al-Inshiqaq', 'number': 84, 'ayahs': 25, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط¨ط±ظˆط¬', 'english': 'Al-Buruj', 'number': 85, 'ayahs': 22, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط·ط§ط±ظ‚', 'english': 'At-Tariq', 'number': 86, 'ayahs': 17, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط£ط¹ظ„ظ‰', 'english': 'Al-Ala', 'number': 87, 'ayahs': 19, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط؛ط§ط´ظٹط©', 'english': 'Al-Ghashiyah', 'number': 88, 'ayahs': 26, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظپط¬ط±', 'english': 'Al-Fajr', 'number': 89, 'ayahs': 30, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط¨ظ„ط¯', 'english': 'Al-Balad', 'number': 90, 'ayahs': 20, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط´ظ…ط³', 'english': 'Ash-Shams', 'number': 91, 'ayahs': 15, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ„ظٹظ„', 'english': 'Al-Layl', 'number': 92, 'ayahs': 21, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط¶ط­ظ‰', 'english': 'Ad-Duha', 'number': 93, 'ayahs': 11, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط´ط±ط­', 'english': 'Ash-Sharh', 'number': 94, 'ayahs': 8, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„طھظٹظ†', 'english': 'At-Tin', 'number': 95, 'ayahs': 8, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط¹ظ„ظ‚', 'english': 'Al-Alaq', 'number': 96, 'ayahs': 19, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ‚ط¯ط±', 'english': 'Al-Qadr', 'number': 97, 'ayahs': 5, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط¨ظٹظ†ط©', 'english': 'Al-Bayyinah', 'number': 98, 'ayahs': 8, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط²ظ„ط²ظ„ط©', 'english': 'Az-Zalzalah', 'number': 99, 'ayahs': 8, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط¹ط§ط¯ظٹط§طھ', 'english': 'Al-Adiyat', 'number': 100, 'ayahs': 11, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ‚ط§ط±ط¹ط©', 'english': 'Al-Qariah', 'number': 101, 'ayahs': 11, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„طھظƒط§ط«ط±', 'english': 'At-Takathur', 'number': 102, 'ayahs': 8, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط¹طµط±', 'english': 'Al-Asr', 'number': 103, 'ayahs': 3, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ‡ظ…ط²ط©', 'english': 'Al-Humazah', 'number': 104, 'ayahs': 9, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظپظٹظ„', 'english': 'Al-Fil', 'number': 105, 'ayahs': 5, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ظ‚ط±ظٹط´', 'english': 'Quraysh', 'number': 106, 'ayahs': 4, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ…ط§ط¹ظˆظ†', 'english': 'Al-Maun', 'number': 107, 'ayahs': 7, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظƒظˆط«ط±', 'english': 'Al-Kawthar', 'number': 108, 'ayahs': 3, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظƒط§ظپط±ظˆظ†', 'english': 'Al-Kafirun', 'number': 109, 'ayahs': 6, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ†طµط±', 'english': 'An-Nasr', 'number': 110, 'ayahs': 3, 'type': 'ظ…ط¯ظ†ظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ…ط³ط¯', 'english': 'Al-Masad', 'number': 111, 'ayahs': 5, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ط¥ط®ظ„ط§طµ', 'english': 'Al-Ikhlas', 'number': 112, 'ayahs': 4, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظپظ„ظ‚', 'english': 'Al-Falaq', 'number': 113, 'ayahs': 5, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
    {'name': 'ط§ظ„ظ†ط§ط³', 'english': 'An-Nas', 'number': 114, 'ayahs': 6, 'type': 'ظ…ظƒظٹط©', 'juz': 30},
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
            selectedFilter == 'ط§ظ„ظƒظ„' || s['type'] == selectedFilter;
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
                            'ï·½',
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
                    'ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ…',
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
                    'ط¥ظگظ†ظژظ‘ط§ ظ†ظژط­ظ’ظ†ظڈ ظ†ظژط²ظژظ‘ظ„ظ’ظ†ظژط§ ط§ظ„ط°ظگظ‘ظƒظ’ط±ظژ ظˆظژط¥ظگظ†ظژظ‘ط§ ظ„ظژظ‡ظڈ ظ„ظژط­ظژط§ظپظگط¸ظڈظˆظ†ظژ',
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
                      _buildStatChip('ظ،ظ،ظ¤', 'ط³ظˆط±ط©'),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12),
                      ),
                      _buildStatChip('ظ¦ظ¢ظ£ظ¦', 'ط¢ظٹط©'),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12),
                      ),
                      _buildStatChip('ظ£ظ ', 'ط¬ط²ط،ط§ظ‹'),
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
                Text('ط§ظ„ط³ظˆط±'),
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
                Text('ط¬ط°ظˆط± ط§ظ„ظƒظ„ظ…ط§طھ'),
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
          hintText: 'ط§ط¨ط­ط« ط¹ظ† ط³ظˆط±ط© ط¨ط§ظ„ط§ط³ظ… ط£ظˆ ط§ظ„ط±ظ‚ظ…...',
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
          _buildFilterChip('ط§ظ„ظƒظ„', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('ظ…ظƒظٹط©', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('ظ…ط¯ظ†ظٹط©', isDark),
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
                            surah['type'] == 'ظ…ظƒظٹط©'
                                ? const Color(0xFFE67E22)
                                : const Color(0xFF3498DB),
                          ),
                          Text('${surah['ayahs']} ط¢ظٹط©',
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: textColorSub)),
                          Text('ط§ظ„ط¬ط²ط، ${surah['juz']}',
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