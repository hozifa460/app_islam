import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookReaderScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final Color primaryColor;
  final String pdfUrl;

  const BookReaderScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.primaryColor,
    required this.pdfUrl,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  String? localPdfPath;
  bool _isLoading = true;
  String _statusMessage = 'جاري تحضير الكتاب...';
  bool _hasError = false;

  PDFViewController? _pdfViewController;
  int _currentPage = 0;
  int _totalPages = 0;
  int _savedPage = 0;

  bool _showSettingsBar = false;
  bool _isLocked = false;
  bool _isTtsPlaying = false;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _initPdfBook();
  }

  @override
  void dispose() {
    // لم نعد نمسح الملف هنا لكي يفتح بسرعة في المرة القادمة
    super.dispose();
  }

  Future<void> _initPdfBook() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedPage = prefs.getInt('pdf_bookmark_${widget.bookId}') ?? 0;

      // 1. فحص الذاكرة الدائمة (إذا حمله المستخدم بيده عبر زر السحابة)
      final permDir = await getApplicationDocumentsDirectory();
      final permFile = File('${permDir.path}/${widget.bookId}.pdf');

      if (await permFile.exists()) {
        if (mounted) {
          setState(() {
            localPdfPath = permFile.path;
            _isLoading = false;
          });
        }
        return;
      }

      // 2. فحص الذاكرة المؤقتة الكاش (إذا قرأه أونلاين مسبقاً)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${widget.bookId}.pdf');

      // ✅ التعديل هنا: إذا وجده في الكاش، سيفتحه في ثانية واحدة ولن يعيد التحميل!
      if (await tempFile.exists()) {
        if (mounted) {
          setState(() {
            localPdfPath = tempFile.path;
            _isLoading = false;
          });
        }
        return;
      }

      // 3. إذا لم يجده أبداً، يقوم بتحميله كـ (كاش أونلاين)
      if (mounted) setState(() => _statusMessage = 'جاري جلب الكتاب لأول مرة...\n(سيفتح فوراً في المرات القادمة)');

      final response = await http.get(Uri.parse(widget.pdfUrl)).timeout(const Duration(minutes: 5));
      if (response.statusCode == 200) {
        await tempFile.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            localPdfPath = tempFile.path;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('فشل التحميل');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _statusMessage = 'عذراً، تعذر تحميل ملف الكتاب.\nتأكد من الرابط أو اتصال الإنترنت.';
        });
      }
    }
  }

  Future<void> _saveProgress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pdf_bookmark_${widget.bookId}', index);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontFamily: 'Cairo')), duration: const Duration(seconds: 2)),
    );
  }

  void _openTableOfContents() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('فهرس الكتاب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: Center(child: Text('هذه الميزة تعمل مع الكتب النصية فقط', style: TextStyle(color: Colors.grey.shade600))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFFDF8EE),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: widget.primaryColor),
                const SizedBox(height: 20),
                Text(_statusMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: widget.primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }

    if (_hasError || localPdfPath == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(backgroundColor: widget.primaryColor),
          body: Center(child: Text(_statusMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.red))),
        ),
      );
    }

    double safeMaxSliderValue = (_totalPages > 0 ? _totalPages - 1 : 0).toDouble();
    double safeCurrentSliderValue = _currentPage.toDouble();
    if (safeCurrentSliderValue > safeMaxSliderValue) {
      safeCurrentSliderValue = safeMaxSliderValue;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE0E0E0),

        appBar: _showUI ? AppBar(
          backgroundColor: widget.primaryColor,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(icon: const Icon(Icons.workspace_premium, color: Colors.white), onPressed: () => _showSnackBar('تمت الإضافة للمفضلة')),
            IconButton(
              icon: Icon(_isTtsPlaying ? Icons.volume_up : Icons.volume_off, color: Colors.white),
              onPressed: () {
                setState(() => _isTtsPlaying = !_isTtsPlaying);
                _showSnackBar(_isTtsPlaying ? 'بدأ القراءة الصوتية...' : 'تم إيقاف القراءة الصوتية');
              },
            ),
            IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () => _showSnackBar('جاري فتح البحث...')),
            IconButton(icon: const Icon(Icons.format_list_bulleted, color: Colors.white), onPressed: _openTableOfContents),
            IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () => setState(() => _showSettingsBar = !_showSettingsBar)),
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () => _showSnackBar('خيارات إضافية')),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bookTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'page ${_currentPage + 1} / ${_totalPages == 0 ? "..." : _totalPages}',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
        ) : null,

        body: Stack(
          children: [
            PDFView(
              filePath: localPdfPath,
              enableSwipe: !_isLocked,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              defaultPage: _savedPage,
              onRender: (pages) {
                setState(() => _totalPages = pages ?? 0);
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfViewController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  setState(() => _currentPage = page);
                  _saveProgress(page);
                }
              },
            ),

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() => _showUI = !_showUI);
                },
                child: Container(),
              ),
            ),

            if (_showSettingsBar && _showUI)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('إعدادات القراءة', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.keyboard_arrow_up, color: Colors.grey), onPressed: () => setState(() => _showSettingsBar = false)),
                    ],
                  ),
                ),
              ),

            if (_showUI)
              Positioned(
                right: 16, bottom: 40,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isLocked = !_isLocked);
                    _showSnackBar(_isLocked ? 'تم قفل الشاشة لمنع التمرير' : 'تم إلغاء القفل');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isLocked ? Icons.lock : Icons.swap_horiz, color: Colors.black54),
                        const SizedBox(height: 4),
                        Text('Lock', style: TextStyle(fontSize: 10, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),

        bottomNavigationBar: _showUI ? Container(
          color: widget.primaryColor,
          padding: const EdgeInsets.only(bottom: 20, top: 10, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbColor: Colors.white, activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.3), trackHeight: 3.0,
                ),
                child: Slider(
                  value: safeCurrentSliderValue,
                  min: 0,
                  max: safeMaxSliderValue,
                  onChanged: (value) {
                    _pdfViewController?.setPage(value.toInt());
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sync, color: Colors.white),
                    onPressed: () {
                      _pdfViewController?.setPage(0);
                      _showSnackBar('العودة لبداية الكتاب');
                    },
                  ),
                  Text(
                    '${_currentPage + 1} of ${_totalPages == 0 ? "..." : _totalPages}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.ltr,
                  ),
                  IconButton(icon: const Icon(Icons.push_pin, color: Colors.white), onPressed: () => _showSnackBar('تم حفظ العلامة المرجعية')),
                ],
              ),
            ],
          ),
        ) : null,
      ),
    );
  }
}