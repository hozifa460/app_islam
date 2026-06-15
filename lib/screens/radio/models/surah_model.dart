// lib/screens/radio/models/surah_model.dart

class SurahModel {
  final int number;
  final String name;
  final String nameEn;
  final int juzNumber;
  final int versesCount;
  final bool isMakki;

  const SurahModel({
    required this.number,
    required this.name,
    required this.nameEn,
    required this.juzNumber,
    required this.versesCount,
    required this.isMakki,
  });

  // اسم الملف
  String get fileName => '${number.toString().padLeft(3, '0')}.mp3';

  // الحجم التقريبي بالميغابايت (بجودة 64kbps)
  double get approximateSizeMB {
    // حساب تقريبي بناءً على عدد الآيات
    // متوسط 30 ثانية لكل آية × 64kbps
    final seconds = versesCount * 30.0;
    final bytes = (seconds * 64 * 1000) / 8;
    return bytes / (1024 * 1024);
  }

  String get approximateSizeStr {
    final size = approximateSizeMB;
    if (size < 1) return '${(size * 1024).toStringAsFixed(0)} KB';
    return '${size.toStringAsFixed(1)} MB';
  }
}

class JuzModel {
  final int number;
  final String name;
  final int startSurah;
  final int endSurah;

  const JuzModel({
    required this.number,
    required this.name,
    required this.startSurah,
    required this.endSurah,
  });

  // السور التي يحتويها الجزء
  List<int> get surahNumbers {
    return List.generate(
      endSurah - startSurah + 1,
          (i) => startSurah + i,
    );
  }

  // الحجم التقريبي
  double approximateSizeMB(List<SurahModel> allSurahs) {
    double total = 0;
    for (final num in surahNumbers) {
      final surah = allSurahs.firstWhere(
            (s) => s.number == num,
        orElse: () => allSurahs.first,
      );
      total += surah.approximateSizeMB;
    }
    return total;
  }

  String approximateSizeStr(List<SurahModel> allSurahs) {
    final size = approximateSizeMB(allSurahs);
    return '${size.toStringAsFixed(0)} MB';
  }
}