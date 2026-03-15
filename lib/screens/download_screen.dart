import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/quran_services.dart';

class DownloadScreen extends StatefulWidget {
  final VoidCallback onDownloadComplete;

  const DownloadScreen({super.key, required this.onDownloadComplete});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen>
    with SingleTickerProviderStateMixin {
  bool isDownloading = false;
  bool isError = false;
  bool isChecking = true;
  String errorMessage = '';
  int currentSurah = 0;
  int totalSurahs = 114;
  String currentSurahName = '';

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final List<String> surahNames = [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف',
    'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
    'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه', 'الأنبياء', 'الحج', 'المؤمنون',
    'النور', 'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس', 'الصافات', 'ص',
    'الزمر', 'غافر', 'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية',
    'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق', 'الذاريات', 'الطور', 'النجم',
    'القمر', 'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
    'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم', 'الملك',
    'القلم', 'الحاقة', 'المعارج', 'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة',
    'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس', 'التكوير', 'الانفطار',
    'المطففين', 'الانشقاق', 'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر',
    'البلد', 'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق', 'القدر',
    'البينة', 'الزلزلة', 'العاديات', 'القارعة', 'التكاثر', 'العصر', 'الهمزة',
    'الفيل', 'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر', 'المسد',
    'الإخلاص', 'الفلق', 'الناس'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startProcess();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startProcess() async {
    setState(() {
      isChecking = true;
      isError = false;
    });

    // التحقق من وجود البيانات محلياً
    final isDownloaded = await QuranService.isDataDownloaded();
    if (isDownloaded) {
      widget.onDownloadComplete();
      return;
    }

    // التحقق من الاتصال بالإنترنت
    setState(() {
      isChecking = false;
    });

    final hasInternet = await QuranService.hasInternetConnection();

    if (!hasInternet) {
      setState(() {
        isError = true;
        errorMessage = 'لا يوجد اتصال بالإنترنت\n\nيرجى التأكد من:\n• تشغيل الواي فاي أو بيانات الهاتف\n• وجود اتصال فعّال بالإنترنت';
      });
      return;
    }

    // بدء التحميل
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      isDownloading = true;
      isError = false;
      currentSurah = 0;
    });

    final result = await QuranService.downloadAndSaveQuran(
      onProgress: (current, total) {
        if (mounted) {
          setState(() {
            currentSurah = current;
            totalSurahs = total;
            if (current > 0 && current <= surahNames.length) {
              currentSurahName = surahNames[current - 1];
            }
          });
        }
      },
    );

    if (result != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onDownloadComplete();
    } else {
      if (mounted) {
        setState(() {
          isDownloading = false;
          isError = true;
          errorMessage = 'فشل في تحميل البيانات\n\nيرجى التأكد من اتصال الإنترنت والمحاولة مرة أخرى';
        });
      }
    }
  }

  // ✅ تجاوز التحقق وبدء التحميل مباشرة
  Future<void> _forceDownload() async {
    setState(() {
      isError = false;
    });
    _startDownload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة القرآن
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B4513), Color(0xFFD4AF37)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B4513).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'القرآن الكريم',
                  style: GoogleFonts.amiri(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B4513),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'تحميل البيانات لأول مرة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: const Color(0xFF8B4513).withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 50),

                // أثناء التحقق
                if (isChecking) ...[
                  const CircularProgressIndicator(color: Color(0xFF8B4513)),
                  const SizedBox(height: 16),
                  Text(
                    'جاري التحقق...',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],

                // أثناء التحميل
                if (isDownloading) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'جاري التحميل...',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '$currentSurah / $totalSurahs',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8B4513),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalSurahs > 0 ? currentSurah / totalSurahs : 0,
                            backgroundColor: const Color(0xFF8B4513).withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF8B4513)),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'سورة $currentSurahName',
                          style: GoogleFonts.amiri(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${totalSurahs > 0 ? ((currentSurah / totalSurahs) * 100).toStringAsFixed(0) : 0}%',
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'يرجى الانتظار وعدم إغلاق التطبيق',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],

                // عند حدوث خطأ
                if (isError) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 50,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // زر إعادة المحاولة
                  ElevatedButton.icon(
                    onPressed: _startProcess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'إعادة المحاولة',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ✅ زر المحاولة بدون تحقق
                  TextButton(
                    onPressed: _forceDownload,
                    child: Text(
                      'تجربة التحميل مباشرة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: const Color(0xFF8B4513),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}