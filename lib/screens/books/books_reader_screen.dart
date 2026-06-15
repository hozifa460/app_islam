import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookReaderScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final Color primaryColor;
  final String pdfUrl;
  final ValueChanged<int>? onPageChangedCallback;
  final ValueChanged<int>? onRenderPagesCallback;

  const BookReaderScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.primaryColor,
    required this.pdfUrl, this.onPageChangedCallback, this.onRenderPagesCallback,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  String? localPdfPath;
  bool _isLoading = true;
  String _statusMessage = 'ط¬ط§ط±ظٹ طھط­ط¶ظٹط± ط§ظ„ظƒطھط§ط¨...';
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
    // ظ„ظ… ظ†ط¹ط¯ ظ†ظ…ط³ط­ ط§ظ„ظ…ظ„ظپ ظ‡ظ†ط§ ظ„ظƒظٹ ظٹظپطھط­ ط¨ط³ط±ط¹ط© ظپظٹ ط§ظ„ظ…ط±ط© ط§ظ„ظ‚ط§ط¯ظ…ط©
    super.dispose();
  }

  Future<void> _initPdfBook() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedPage = prefs.getInt('pdf_bookmark_${widget.bookId}') ?? 0;

      // 1. ظپط­طµ ط§ظ„ط°ط§ظƒط±ط© ط§ظ„ط¯ط§ط¦ظ…ط© (ط¥ط°ط§ ط­ظ…ظ„ظ‡ ط§ظ„ظ…ط³طھط®ط¯ظ… ط¨ظٹط¯ظ‡ ط¹ط¨ط± ط²ط± ط§ظ„ط³ط­ط§ط¨ط©)
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

      // 2. ظپط­طµ ط§ظ„ط°ط§ظƒط±ط© ط§ظ„ظ…ط¤ظ‚طھط© ط§ظ„ظƒط§ط´ (ط¥ط°ط§ ظ‚ط±ط£ظ‡ ط£ظˆظ†ظ„ط§ظٹظ† ظ…ط³ط¨ظ‚ط§ظ‹)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${widget.bookId}.pdf');

      // âœ… ط§ظ„طھط¹ط¯ظٹظ„ ظ‡ظ†ط§: ط¥ط°ط§ ظˆط¬ط¯ظ‡ ظپظٹ ط§ظ„ظƒط§ط´طŒ ط³ظٹظپطھط­ظ‡ ظپظٹ ط«ط§ظ†ظٹط© ظˆط§ط­ط¯ط© ظˆظ„ظ† ظٹط¹ظٹط¯ ط§ظ„طھط­ظ…ظٹظ„!
      if (await tempFile.exists()) {
        if (mounted) {
          setState(() {
            localPdfPath = tempFile.path;
            _isLoading = false;
          });
        }
        return;
      }

      // 3. ط¥ط°ط§ ظ„ظ… ظٹط¬ط¯ظ‡ ط£ط¨ط¯ط§ظ‹طŒ ظٹظ‚ظˆظ… ط¨طھط­ظ…ظٹظ„ظ‡ ظƒظ€ (ظƒط§ط´ ط£ظˆظ†ظ„ط§ظٹظ†)
      if (mounted) setState(() => _statusMessage = 'ط¬ط§ط±ظٹ ط¬ظ„ط¨ ط§ظ„ظƒطھط§ط¨ ظ„ط£ظˆظ„ ظ…ط±ط©...\n(ط³ظٹظپطھط­ ظپظˆط±ط§ظ‹ ظپظٹ ط§ظ„ظ…ط±ط§طھ ط§ظ„ظ‚ط§ط¯ظ…ط©)');

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
        throw Exception('ظپط´ظ„ ط§ظ„طھط­ظ…ظٹظ„');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _statusMessage = 'ط¹ط°ط±ط§ظ‹طŒ طھط¹ط°ط± طھط­ظ…ظٹظ„ ظ…ظ„ظپ ط§ظ„ظƒطھط§ط¨.\nطھط£ظƒط¯ ظ…ظ† ط§ظ„ط±ط§ط¨ط· ط£ظˆ ط§طھطµط§ظ„ ط§ظ„ط¥ظ†طھط±ظ†طھ.';
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
                const Text('ظپظ‡ط±ط³ ط§ظ„ظƒطھط§ط¨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: Center(child: Text('ظ‡ط°ظ‡ ط§ظ„ظ…ظٹط²ط© طھط¹ظ…ظ„ ظ…ط¹ ط§ظ„ظƒطھط¨ ط§ظ„ظ†طµظٹط© ظپظ‚ط·', style: TextStyle(color: Colors.grey.shade600))),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: widget.primaryColor),
                  const SizedBox(height: 20),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: widget.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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

        appBar: _showUI
            ? AppBar(
          backgroundColor: widget.primaryColor,
          elevation: 0,
          toolbarHeight: 52,
          leadingWidth: 46,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.bookTitle,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'page ${_currentPage + 1} / ${_totalPages == 0 ? "..." : _totalPages}',
                style: GoogleFonts.cairo(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 11,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
              onPressed: () => _showSnackBar('طھظ…طھ ط§ظ„ط¥ط¶ط§ظپط© ظ„ظ„ظ…ظپط¶ظ„ط©'),
            ),
            IconButton(
              icon: Icon(
                _isTtsPlaying ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() => _isTtsPlaying = !_isTtsPlaying);
                _showSnackBar(_isTtsPlaying
                    ? 'ط¨ط¯ط£طھ ط§ظ„ظ‚ط±ط§ط،ط© ط§ظ„طµظˆطھظٹط©...'
                    : 'طھظ… ط¥ظٹظ‚ط§ظپ ط§ظ„ظ‚ط±ط§ط،ط© ط§ظ„طµظˆطھظٹط©');
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: () => _showSnackBar('ط¬ط§ط±ظٹ ظپطھط­ ط§ظ„ط¨ط­ط«...'),
            ),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted, color: Colors.white, size: 20),
              onPressed: _openTableOfContents,
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 20),
              onPressed: () => setState(() => _showSettingsBar = !_showSettingsBar),
            ),
          ],
        )
            : null,

        body: Stack(
          children: [
            PDFView(
              filePath: localPdfPath,
              enableSwipe: !_isLocked,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: false,
              fitPolicy: FitPolicy.BOTH,
              defaultPage: _savedPage,
              onRender: (pages) {
                setState(() => _totalPages = pages ?? 0);
                if (pages != null) {
                  widget.onRenderPagesCallback?.call(pages);
                }
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfViewController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  setState(() => _currentPage = page);
                  _saveProgress(page);
                  widget.onPageChangedCallback?.call(page);
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
                      const Text('ط¥ط¹ط¯ط§ط¯ط§طھ ط§ظ„ظ‚ط±ط§ط،ط©', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.keyboard_arrow_up, color: Colors.grey), onPressed: () => setState(() => _showSettingsBar = false)),
                    ],
                  ),
                ),
              ),

            if (_showUI)
              Positioned(
                right: 12,
                bottom: 82,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isLocked = !_isLocked);
                    _showSnackBar(_isLocked ? 'طھظ… ظ‚ظپظ„ ط§ظ„ط´ط§ط´ط© ظ„ظ…ظ†ط¹ ط§ظ„طھظ…ط±ظٹط±' : 'طھظ… ط¥ظ„ط؛ط§ط، ط§ظ„ظ‚ظپظ„');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLocked ? Icons.lock : Icons.swap_vert,
                          color: Colors.black54,
                          size: 18,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Lock',
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),

        bottomNavigationBar: _showUI
            ? SafeArea(
          top: false,
          child: Container(
            color: widget.primaryColor,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: Colors.white,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    trackHeight: 2.6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restart_alt, color: Colors.white, size: 20),
                      onPressed: () {
                        _pdfViewController?.setPage(0);
                        _showSnackBar('ط§ظ„ط¹ظˆط¯ط© ظ„ط¨ط¯ط§ظٹط© ط§ظ„ظƒطھط§ط¨');
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${_currentPage + 1} / ${_totalPages == 0 ? "..." : _totalPages}',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.push_pin, color: Colors.white, size: 20),
                      onPressed: () => _showSnackBar('طھظ… ط­ظپط¸ ط§ظ„ط¹ظ„ط§ظ…ط© ط§ظ„ظ…ط±ط¬ط¹ظٹط©'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
            : null,
      ),
    );
  }
}