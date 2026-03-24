import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'books_reader_screen.dart';

class CombinedBookReaderScreen extends StatefulWidget {
  final String title;
  final List<dynamic> volumes;
  final Color primaryColor;

  const CombinedBookReaderScreen({
    super.key,
    required this.title,
    required this.volumes,
    required this.primaryColor,
  });

  @override
  State<CombinedBookReaderScreen> createState() =>
      _CombinedBookReaderScreenState();
}

class _CombinedBookReaderScreenState extends State<CombinedBookReaderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentVolumeIndex = 0;
  int _currentPageInVolume = 0;
  final Map<int, int> _volumePagesCount = {};

  int get _totalPagesAllVolumes {
    if (_volumePagesCount.isEmpty) return 0;
    return _volumePagesCount.values.fold(0, (a, b) => a + b);
  }

  int get _globalCurrentPage {
    int pagesBefore = 0;
    for (int i = 0; i < _currentVolumeIndex; i++) {
      pagesBefore += _volumePagesCount[i] ?? 0;
    }
    return pagesBefore + _currentPageInVolume + 1;
  }

  void _openVolumeByIndex(int index) {
    setState(() {
      _currentVolumeIndex = index;
      _currentPageInVolume = 0;
    });
    Navigator.pop(context);
  }

  void _goNextVolume() {
    if (_currentVolumeIndex < widget.volumes.length - 1) {
      setState(() {
        _currentVolumeIndex++;
        _currentPageInVolume = 0;
      });
    }
  }

  void _goPreviousVolume() {
    if (_currentVolumeIndex > 0) {
      setState(() {
        _currentVolumeIndex--;
        _currentPageInVolume = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentVolume =
    Map<String, dynamic>.from(widget.volumes[_currentVolumeIndex]);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.grey.shade200;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'مجلدات الكتاب',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.volumes.length,
                  itemBuilder: (context, index) {
                    final volume =
                    Map<String, dynamic>.from(widget.volumes[index]);
                    final selected = index == _currentVolumeIndex;
                    final pagesCount = _volumePagesCount[index];

                    return ListTile(
                      selected: selected,
                      title: Text(
                        volume['title'] ?? 'مجلد',
                        style: GoogleFonts.cairo(
                          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      subtitle: pagesCount != null
                          ? Text(
                        '$pagesCount صفحة',
                        style: GoogleFonts.cairo(fontSize: 12),
                      )
                          : null,
                      trailing: selected
                          ? Icon(Icons.check_circle, color: widget.primaryColor)
                          : null,
                      onTap: () => _openVolumeByIndex(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              _totalPagesAllVolumes > 0
                  ? 'صفحة $_globalCurrentPage / $_totalPagesAllVolumes'
                  : currentVolume['title'] ?? '',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: BookReaderScreen(
        key: ValueKey(currentVolume['id']),
        bookId: currentVolume['id'],
        bookTitle: currentVolume['title'],
        primaryColor: widget.primaryColor,
        pdfUrl: currentVolume['pdfUrl'] ?? '',
        onPageChangedCallback: (page) {
          if (mounted) {
            setState(() {
              _currentPageInVolume = page;
            });
          }
        },
        onRenderPagesCallback: (pages) {
          if (mounted) {
            setState(() {
              _volumePagesCount[_currentVolumeIndex] = pages;
            });
          }
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: widget.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _currentVolumeIndex > 0 ? _goPreviousVolume : null,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  label: Text(
                    'المجلد السابق',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: widget.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _currentVolumeIndex < widget.volumes.length - 1
                      ? _goNextVolume
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  label: Text(
                    'المجلد التالي',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}