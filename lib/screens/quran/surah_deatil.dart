import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'quran_search_delegate.dart';

class SurahDetailScreen extends StatefulWidget {
  final String surahName;
  final int surahNumber;
  final int? initialPage;
  final int? targetPage;
  final String? searchQuery;

  const SurahDetailScreen({
    super.key,
    required this.surahName,
    required this.surahNumber,
    this.initialPage,
    this.targetPage,
    this.searchQuery,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late PageController _pageController;
  late AudioPlayer _audioPlayer;
  late stt.SpeechToText _speech;

  final Map<int, List<dynamic>> _pageAyahsCache = {};
  final Map<int, int> _pageToHizbQuarter = {};
  final TransformationController _zoomController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  static const String _kQuranPagesFullyDownloadedKey =
      'quran_pages_fully_downloaded';

  bool _areAllPagesDownloaded = false;

  bool _showControls = false;
  bool _isPlaying = false;
  bool _isListening = false;
  bool _hideVerses = false;
  bool _isPreparingQuran = true;
  bool _isBackgroundPreparing = false;
  bool _isInitialPageReady = false;
  int? _selectedAyahNumber;
  bool _isDownloadingAllPages = false;
  String _downloadStatusMessage = '';
  final Map<int, String> _localPagePaths = {};

  String _backgroundPrepareMessage = '';
  String _quranLoadingMessage = 'ط¬ط§ط±ظٹ ط¥ط¹ط¯ط§ط¯ ط§ظ„ظ‚ط±ط¢ظ†...';
  double _quranLoadingProgress = 0.0;
  late int _currentPage;
  String _spokenText = '';
  String _selectedReciter = 'ar.alafasy';
  String _selectedReciterName = 'ظ…ط´ط§ط±ظٹ ط§ظ„ط¹ظپط§ط³ظٹ';

  static const String _kLastPageKey = 'quran_last_page';
  static const String _kLastSurahKey = 'quran_last_surah_name';
  static const String _kBookmarkPageKey = 'quran_bookmark_page';
  static const String _kBookmarkSurahKey = 'quran_bookmark_surah_name';
  static const String _quranPagesBaseUrl =
      'https://raw.githubusercontent.com/rn0x/Quran-Data/version-2.0/data/quran_image';

  String _getPageImageUrl(int page) {
    return '$_quranPagesBaseUrl/$page.png';
  }

  final List<Map<String, String>> _reciters = const [
    {'id': 'ar.alafasy', 'name': 'ظ…ط´ط§ط±ظٹ ط§ظ„ط¹ظپط§ط³ظٹ'},
    {'id': 'ar.husary', 'name': 'ظ…ط­ظ…ظˆط¯ ط®ظ„ظٹظ„ ط§ظ„ط­طµط±ظٹ'},
    {'id': 'ar.abdulbasitmurattal', 'name': 'ط¹ط¨ط¯ط§ظ„ط¨ط§ط³ط· ط¹ط¨ط¯ط§ظ„طµظ…ط¯'},
    {'id': 'ar.minshawi', 'name': 'ظ…ط­ظ…ط¯ طµط¯ظٹظ‚ ط§ظ„ظ…ظ†ط´ط§ظˆظٹ'},
    {'id': 'ar.mahermuaiqly', 'name': 'ظ…ط§ظ‡ط± ط§ظ„ظ…ط¹ظٹظ‚ظ„ظٹ'},
  ];

  final List<String> _surahNames = const [
    'ط§ظ„ظپط§طھط­ط©', 'ط§ظ„ط¨ظ‚ط±ط©', 'ط¢ظ„ ط¹ظ…ط±ط§ظ†', 'ط§ظ„ظ†ط³ط§ط،', 'ط§ظ„ظ…ط§ط¦ط¯ط©', 'ط§ظ„ط£ظ†ط¹ط§ظ…', 'ط§ظ„ط£ط¹ط±ط§ظپ',
    'ط§ظ„ط£ظ†ظپط§ظ„', 'ط§ظ„طھظˆط¨ط©', 'ظٹظˆظ†ط³', 'ظ‡ظˆط¯', 'ظٹظˆط³ظپ', 'ط§ظ„ط±ط¹ط¯', 'ط¥ط¨ط±ط§ظ‡ظٹظ…', 'ط§ظ„ط­ط¬ط±',
    'ط§ظ„ظ†ط­ظ„', 'ط§ظ„ط¥ط³ط±ط§ط،', 'ط§ظ„ظƒظ‡ظپ', 'ظ…ط±ظٹظ…', 'ط·ظ‡', 'ط§ظ„ط£ظ†ط¨ظٹط§ط،', 'ط§ظ„ط­ط¬', 'ط§ظ„ظ…ط¤ظ…ظ†ظˆظ†',
    'ط§ظ„ظ†ظˆط±', 'ط§ظ„ظپط±ظ‚ط§ظ†', 'ط§ظ„ط´ط¹ط±ط§ط،', 'ط§ظ„ظ†ظ…ظ„', 'ط§ظ„ظ‚طµطµ', 'ط§ظ„ط¹ظ†ظƒط¨ظˆطھ', 'ط§ظ„ط±ظˆظ…',
    'ظ„ظ‚ظ…ط§ظ†', 'ط§ظ„ط³ط¬ط¯ط©', 'ط§ظ„ط£ط­ط²ط§ط¨', 'ط³ط¨ط£', 'ظپط§ط·ط±', 'ظٹط³', 'ط§ظ„طµط§ظپط§طھ', 'طµ',
    'ط§ظ„ط²ظ…ط±', 'ط؛ط§ظپط±', 'ظپطµظ„طھ', 'ط§ظ„ط´ظˆط±ظ‰', 'ط§ظ„ط²ط®ط±ظپ', 'ط§ظ„ط¯ط®ط§ظ†', 'ط§ظ„ط¬ط§ط«ظٹط©', 'ط§ظ„ط£ط­ظ‚ط§ظپ',
    'ظ…ط­ظ…ط¯', 'ط§ظ„ظپطھط­', 'ط§ظ„ط­ط¬ط±ط§طھ', 'ظ‚', 'ط§ظ„ط°ط§ط±ظٹط§طھ', 'ط§ظ„ط·ظˆط±', 'ط§ظ„ظ†ط¬ظ…', 'ط§ظ„ظ‚ظ…ط±',
    'ط§ظ„ط±ط­ظ…ظ†', 'ط§ظ„ظˆط§ظ‚ط¹ط©', 'ط§ظ„ط­ط¯ظٹط¯', 'ط§ظ„ظ…ط¬ط§ط¯ظ„ط©', 'ط§ظ„ط­ط´ط±', 'ط§ظ„ظ…ظ…طھط­ظ†ط©', 'ط§ظ„طµظپ',
    'ط§ظ„ط¬ظ…ط¹ط©', 'ط§ظ„ظ…ظ†ط§ظپظ‚ظˆظ†', 'ط§ظ„طھط؛ط§ط¨ظ†', 'ط§ظ„ط·ظ„ط§ظ‚', 'ط§ظ„طھط­ط±ظٹظ…', 'ط§ظ„ظ…ظ„ظƒ', 'ط§ظ„ظ‚ظ„ظ…',
    'ط§ظ„ط­ط§ظ‚ط©', 'ط§ظ„ظ…ط¹ط§ط±ط¬', 'ظ†ظˆط­', 'ط§ظ„ط¬ظ†', 'ط§ظ„ظ…ط²ظ…ظ„', 'ط§ظ„ظ…ط¯ط«ط±', 'ط§ظ„ظ‚ظٹط§ظ…ط©',
    'ط§ظ„ط¥ظ†ط³ط§ظ†', 'ط§ظ„ظ…ط±ط³ظ„ط§طھ', 'ط§ظ„ظ†ط¨ط£', 'ط§ظ„ظ†ط§ط²ط¹ط§طھ', 'ط¹ط¨ط³', 'ط§ظ„طھظƒظˆظٹط±', 'ط§ظ„ط¥ظ†ظپط·ط§ط±',
    'ط§ظ„ظ…ط·ظپظپظٹظ†', 'ط§ظ„ط¥ظ†ط´ظ‚ط§ظ‚', 'ط§ظ„ط¨ط±ظˆط¬', 'ط§ظ„ط·ط§ط±ظ‚', 'ط§ظ„ط£ط¹ظ„ظ‰', 'ط§ظ„ط؛ط§ط´ظٹط©', 'ط§ظ„ظپط¬ط±',
    'ط§ظ„ط¨ظ„ط¯', 'ط§ظ„ط´ظ…ط³', 'ط§ظ„ظ„ظٹظ„', 'ط§ظ„ط¶ط­ظ‰', 'ط§ظ„ط´ط±ط­', 'ط§ظ„طھظٹظ†', 'ط§ظ„ط¹ظ„ظ‚', 'ط§ظ„ظ‚ط¯ط±',
    'ط§ظ„ط¨ظٹظ†ط©', 'ط§ظ„ط²ظ„ط²ظ„ط©', 'ط§ظ„ط¹ط§ط¯ظٹط§طھ', 'ط§ظ„ظ‚ط§ط±ط¹ط©', 'ط§ظ„طھظƒط§ط«ط±', 'ط§ظ„ط¹طµط±', 'ط§ظ„ظ‡ظ…ط²ط©',
    'ط§ظ„ظپظٹظ„', 'ظ‚ط±ظٹط´', 'ط§ظ„ظ…ط§ط¹ظˆظ†', 'ط§ظ„ظƒظˆط«ط±', 'ط§ظ„ظƒط§ظپط±ظˆظ†', 'ط§ظ„ظ†طµط±', 'ط§ظ„ظ…ط³ط¯',
    'ط§ظ„ط¥ط®ظ„ط§طµ', 'ط§ظ„ظپظ„ظ‚', 'ط§ظ„ظ†ط§ط³'
  ];

  final List<int> _surahStartPages = const [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267,
    282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411,
    415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502,
    507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551,
    553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578,
    580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595,
    595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602,
    602, 602, 603, 603, 603, 604, 604, 604
  ];

  @override
  void initState() {
    super.initState();

    _currentPage = widget.initialPage ?? _surahStartPages[widget.surahNumber - 1];
    _pageController = PageController(initialPage: _currentPage - 1);
    _audioPlayer = AudioPlayer();
    _speech = stt.SpeechToText();

    _saveLastReadingPosition();
    _initAudioListeners();
    _loadPagesDownloadedState();
    _fastPrepareIfPossible();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _speech.stop();
    _zoomController.dispose();
    super.dispose();
  }

  IconData _getQuranDownloadStatusIcon() {
    if (_isDownloadingAllPages || _isBackgroundPreparing) {
      return Icons.downloading_rounded;
    }

    if (_areAllPagesDownloaded) {
      return Icons.cloud_done_rounded;
    }

    return Icons.cloud_download_rounded;
  }

  Color _getQuranDownloadStatusColor(Color primary) {
    if (_isDownloadingAllPages || _isBackgroundPreparing) {
      return Colors.orange;
    }

    if (_areAllPagesDownloaded) {
      return Colors.green;
    }

    return primary;
  }

  Color _getQuranDownloadBadgeColor() {
    if (_isDownloadingAllPages || _isBackgroundPreparing) {
      return Colors.orange;
    }

    if (_areAllPagesDownloaded) {
      return Colors.green;
    }

    return Colors.redAccent;
  }

  Future<void> _showQuranDownloadStatusDialog() async {
    final title = _getQuranDownloadStatusText();
    final badgeColor = _getQuranDownloadBadgeColor();
    final downloadedPages = await _getDownloadedPagesCount();
    final remainingPages = 604 - downloadedPages;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ط­ط§ظ„ط© طھظ†ط²ظٹظ„ ط§ظ„ظ‚ط±ط¢ظ†',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'ط§ظ„طµظپط­ط§طھ ط§ظ„ظ…ط­ظ…ظ‘ظ„ط©',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_toArabicNum(downloadedPages)} / ظ¦ظ ظ¤',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: downloadedPages / 604,
                      minHeight: 6,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ط§ظ„ظ…طھط¨ظ‚ظٹ',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${_toArabicNum(remainingPages)} طµظپط­ط©',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (_isDownloadingAllPages || _isBackgroundPreparing)
                Text(
                  _backgroundPrepareMessage.isNotEmpty
                      ? _backgroundPrepareMessage
                      : 'ظٹطھظ… طھظ†ط²ظٹظ„ ط§ظ„طµظپط­ط§طھ ط§ظ„ط¢ظ†...',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),

              if (_areAllPagesDownloaded)
                Text(
                  'طھظ… طھظ†ط²ظٹظ„ ط¬ظ…ظٹط¹ طµظپط­ط§طھ ط§ظ„ظ‚ط±ط¢ظ† ظˆظٹظ…ظƒظ†ظƒ ط§ظ„ظ‚ط±ط§ط،ط© ط¨ط¯ظˆظ† ط¥ظ†طھط±ظ†طھ.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),

              if (!_areAllPagesDownloaded &&
                  !_isDownloadingAllPages &&
                  !_isBackgroundPreparing)
                Text(
                  'ط¨ط¹ط¶ ط§ظ„طµظپط­ط§طھ ظ„ظ… ظٹطھظ… طھظ†ط²ظٹظ„ظ‡ط§ ط¨ط¹ط¯. ظٹظ…ظƒظ†ظƒ ط§ط³طھط¦ظ†ط§ظپ ط§ظ„طھط­ظ…ظٹظ„ ط§ظ„ط¢ظ†.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'ط¥ط؛ظ„ط§ظ‚',
                style: GoogleFonts.cairo(),
              ),
            ),
            if (!_areAllPagesDownloaded &&
                !_isDownloadingAllPages &&
                !_isBackgroundPreparing)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _handleQuranDownloadStatusTap();
                },
                child: Text(
                  'ط§ط³طھط¦ظ†ط§ظپ ط§ظ„طھط­ظ…ظٹظ„',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getQuranDownloadStatusText() {
    if (_isDownloadingAllPages || _isBackgroundPreparing) {
      return 'ط¬ط§ط±ظٹ طھظ†ط²ظٹظ„ طµظپط­ط§طھ ط§ظ„ظ‚ط±ط¢ظ†...';
    }

    if (_areAllPagesDownloaded) {
      return 'طھظ… طھط­ظ…ظٹظ„ ط§ظ„ظ‚ط±ط¢ظ† ط¨ط§ظ„ظƒط§ظ…ظ„';
    }

    return 'ط§ظ„ظ‚ط±ط¢ظ† ط؛ظٹط± ظ…ظƒطھظ…ظ„ ط§ظ„طھط­ظ…ظٹظ„';
  }

  Future<void> _handleQuranDownloadStatusTap() async {
    await _showQuranDownloadStatusDialog();
  }

  Future<int> _getDownloadedPagesCount() async {
    int count = 0;

    for (int page = 1; page <= 604; page++) {
      final file = await _getLocalPageFile(page);
      if (await file.exists()) {
        count++;
      }
    }

    return count;
  }

  void _handleDoubleTap() {
    if (_zoomController.value != Matrix4.identity()) {
      _zoomController.value = Matrix4.identity();
    } else {
      final position =
          _doubleTapDetails?.localPosition ?? const Offset(200, 200);

      _zoomController.value = Matrix4.identity()
        ..translate(-position.dx * 1.2, -position.dy * 1.2)
        ..scale(2.2);
    }
  }

  Future<void> _fastPrepareIfPossible() async {
    try {
      final localPath = await _getLocalPagePathIfExists(_currentPage);

      if (localPath != null) {
        final ayahs = await _getPageAyahs(_currentPage);

        if (ayahs.isNotEmpty) {
          final hizbQuarter = ayahs.first['hizbQuarter'];
          _pageToHizbQuarter[_currentPage] = hizbQuarter;
        }

        if (mounted) {
          setState(() {
            _isInitialPageReady = true;
            _isPreparingQuran = false;
          });
        }

        _preloadNearbyPages(_currentPage);
        _downloadAllPagesInBackground();
        return;
      }

      // ط¥ط°ط§ ط§ظ„طµظپط­ط© ط؛ظٹط± ظ…ظˆط¬ظˆط¯ط© ظ…ط­ظ„ظٹظ‹ط§طŒ ط£ظƒظ…ظ„ ط§ظ„ظ…ط³ط§ط± ط§ظ„ط¹ط§ط¯ظٹ
      await _prepareInitialSelectedPage().then((_) {
        _downloadAllPagesInBackground();
      });
    } catch (e) {
      debugPrint('fastPrepareIfPossible error: $e');

      await _prepareInitialSelectedPage().then((_) {
        _downloadAllPagesInBackground();
      });
    }
  }

  int _getCurrentPageHizbQuarterSync(int page) {
    final cached = _pageAyahsCache[page];
    if (cached != null && cached.isNotEmpty) {
      return cached.first['hizbQuarter'] ?? 1;
    }

    return _pageToHizbQuarter[page] ?? 1;
  }

  Future<void> _loadPagesDownloadedState() async {
    final prefs = await SharedPreferences.getInstance();
    final ready = prefs.getBool(_kQuranPagesFullyDownloadedKey) ?? false;

    if (mounted) {
      setState(() {
        _areAllPagesDownloaded = ready;
      });
    }
  }

  Future<void> _setPagesDownloadedState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kQuranPagesFullyDownloadedKey, value);

    if (mounted) {
      setState(() {
        _areAllPagesDownloaded = value;
      });
    }
  }

  Future<File> _getLocalPageFile(int page) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/quran_pages/$page.png');
  }

  Future<String?> _getLocalPagePathIfExists(int page) async {
    if (_localPagePaths.containsKey(page)) {
      return _localPagePaths[page];
    }

    final file = await _getLocalPageFile(page);
    if (await file.exists()) {
      _localPagePaths[page] = file.path;
      return file.path;
    }

    return null;
  }

  Future<String?> _downloadPageAndSave(int page) async {
    try {
      final url = _getPageImageUrl(page);
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final file = await _getLocalPageFile(page);

        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }

        await file.writeAsBytes(response.bodyBytes, flush: true);
        _localPagePaths[page] = file.path;
        return file.path;
      }
    } catch (e) {
      debugPrint('Download page $page error: $e');
    }

    return null;
  }

  Future<void> _prepareInitialSelectedPage() async {
    final localPath = await _getLocalPagePathIfExists(_currentPage);

    // ظ†ط­ظ…ظ„ ط¨ظٹط§ظ†ط§طھ ط§ظ„طµظپط­ط© ط§ظ„ظ†طµظٹط© ط£ظˆظ„ط§ظ‹ ط­طھظ‰ ظٹط¸ظ‡ط± ط§ظ„ط­ط²ط¨ ظˆط§ظ„ط¬ط²ط، ط§ظ„طµط­ظٹط­ط§ظ† ظپظˆط±ظ‹ط§
    try {
      final ayahs = await _getPageAyahs(_currentPage);

      if (ayahs.isNotEmpty) {
        final hizbQuarter = ayahs.first['hizbQuarter'];
        _pageToHizbQuarter[_currentPage] = hizbQuarter;
      }
    } catch (e) {
      debugPrint('Initial page ayahs preload error: $e');
    }

    if (localPath != null) {
      if (mounted) {
        setState(() {
          _isInitialPageReady = true;
          _isPreparingQuran = false;
        });
      }
      return;
    }

    await _downloadPageAndSave(_currentPage);

    if (mounted) {
      setState(() {
        _isInitialPageReady = true;
        _isPreparingQuran = false;
      });
    }
  }

  Future<void> _downloadAllPagesInBackground() async {
    if (_isDownloadingAllPages || _areAllPagesDownloaded) return;

    if (mounted) {
      setState(() {
        _isDownloadingAllPages = true;
        _isBackgroundPreparing = true;
        _backgroundPrepareMessage = 'ط¬ط§ط±ظٹ طھظ†ط²ظٹظ„ طµظپط­ط§طھ ط§ظ„ظ‚ط±ط¢ظ† ظپظٹ ط§ظ„ط®ظ„ظپظٹط©...';
      });
    }

    try {
      for (int page = 1; page <= 604; page++) {
        final localPath = await _getLocalPagePathIfExists(page);
        if (localPath == null) {
          await _downloadPageAndSave(page);
        }

        if (mounted && page % 20 == 0) {
          setState(() {
            _backgroundPrepareMessage =
            'ط¬ط§ط±ظٹ طھظ†ط²ظٹظ„ طµظپط­ط§طھ ط§ظ„ظ‚ط±ط¢ظ†... (${_toArabicNum(page)}/ظ¦ظ ظ¤)';
          });
        }
      }

      await _setPagesDownloadedState(true);

      if (mounted) {
        setState(() {
          _isBackgroundPreparing = false;
          _isDownloadingAllPages = false;
          _backgroundPrepareMessage = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'طھظ… طھظ†ط²ظٹظ„ طµظپط­ط§طھ ط§ظ„ظ‚ط±ط¢ظ† ط¨ط§ظ„ظƒط§ظ…ظ„ ظ„ظ„ط¹ظ…ظ„ ط¨ط¯ظˆظ† ط¥ظ†طھط±ظ†طھ',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Download all pages error: $e');

      if (mounted) {
        setState(() {
          _isBackgroundPreparing = false;
          _isDownloadingAllPages = false;
          _backgroundPrepareMessage = '';
        });
      }
    }
  }

  Future<void> _initAudioListeners() async {
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _prepareInitialPage() async {
    try {
      await _getPageAyahs(_currentPage);
      _preloadNearbyPages(_currentPage);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isPreparingQuran = false;
      });
    }
  }

  void _jumpToPage(int page) {
    if (page < 1 || page > 604) return;

    _pageController.jumpToPage(page - 1);

    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    _preloadNearbyPages(page);
    _saveLastReadingPosition();
  }

  void _showReciterDialog(Color primary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHeader(
                title: 'ط§ط®طھظٹط§ط± ط§ظ„ظ‚ط§ط±ط¦',
                subtitle: 'ط§ط®طھط± ظ‚ط§ط±ط¦ ط§ظ„طھظ„ط§ظˆط©',
                primary: primary,
                icon: Icons.record_voice_over_rounded,
              ),
              ..._reciters.map(
                    (r) => _buildModernSheetTile(
                  icon: Icons.person_rounded,
                  title: r['name']!,
                  subtitle: _selectedReciter == r['id'] ? 'ط§ظ„ظ‚ط§ط±ط¦ ط§ظ„ط­ط§ظ„ظٹ' : null,
                  primary: primary,
                  trailing: _selectedReciter == r['id']
                      ? Icon(Icons.check_circle, color: primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedReciter = r['id']!;
                      _selectedReciterName = r['name']!;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickJumpSheet() {
    final primary = Theme.of(context).colorScheme.primary;
    final controller = TextEditingController(text: _currentPage.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSheetHeader(
                    title: 'ط§ظ„ط§ظ†طھظ‚ط§ظ„ ط§ظ„ط³ط±ظٹط¹',
                    subtitle: 'ط§ط°ظ‡ط¨ ط¥ظ„ظ‰ طµظپط­ط© ظ…ط­ط¯ط¯ط©',
                    primary: primary,
                    icon: Icons.swap_horiz_rounded,
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ط£ط¯ط®ظ„ ط±ظ‚ظ… ط§ظ„طµظپط­ط©',
                      hintStyle: GoogleFonts.cairo(),
                      filled: true,
                      fillColor: primary.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary.withValues(alpha: 0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final page = int.tryParse(controller.text.trim());

                        if (page == null || page < 1 || page > 604) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'ط£ط¯ط®ظ„ ط±ظ‚ظ… طµظپط­ط© طµط­ظٹط­ ظ…ظ† 1 ط¥ظ„ظ‰ 604',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(ctx);

                        _pageController.jumpToPage(page - 1);
                        setState(() {
                          _currentPage = page;
                          _showControls = true;
                        });

                        _preloadNearbyPages(page);
                        await _saveLastReadingPosition();
                      },
                      child: Text(
                        'ط§ظ„ط§ظ†طھظ‚ط§ظ„ ط¥ظ„ظ‰ ط§ظ„طµظپط­ط©',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAdvancedIndexSheet() async {
    final primary = Theme.of(context).colorScheme.primary;
    final saved = await _getSavedReadingMeta();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DefaultTabController(
          length: 4,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.82,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          'ظپظ‡ط±ط³ ط§ظ„ظ…طµط­ظپ',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _quickJumpCard(
                                title: 'ط¢ط®ط± ظ…ظˆط¶ط¹',
                                value: saved['lastPage'] != null
                                    ? 'طµظپط­ط© ${_toArabicNum(saved['lastPage'])}'
                                    : 'ط؛ظٹط± ظ…طھظˆظپط±',
                                icon: Icons.history_rounded,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _goToLastReadingPosition();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _quickJumpCard(
                                title: 'ط§ظ„ط¹ظ„ط§ظ…ط©',
                                value: saved['bookmarkPage'] != null
                                    ? 'طµظپط­ط© ${_toArabicNum(saved['bookmarkPage'])}'
                                    : 'ط؛ظٹط± ظ…طھظˆظپط±',
                                icon: Icons.bookmark_rounded,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _goToBookmark();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    labelColor: primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: primary,
                    labelStyle: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'طµظپط­ط§طھ'),
                      Tab(text: 'ط§ظ„ط³ظˆط±'),
                      Tab(text: 'ط§ظ„ط£ط¬ط²ط§ط،'),
                      Tab(text: 'ط§ظ„ط£ط­ط²ط§ط¨'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPagesTab(ctx),
                        _buildSurahsTab(ctx),
                        _buildJuzTab(ctx),
                        _buildHizbTab(ctx),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> _getPageAyahs(int page) async {
    if (_pageAyahsCache.containsKey(page)) {
      return _pageAyahsCache[page]!;
    }

    final response = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/page/$page/quran-uthmani'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahs = List<dynamic>.from(data['data']['ayahs']);

      _pageAyahsCache[page] = ayahs;

      if (ayahs.isNotEmpty) {
        final hizbQuarter = ayahs.first['hizbQuarter'];
        _pageToHizbQuarter.putIfAbsent(page, () => hizbQuarter);
      }

      return ayahs;
    }

    throw Exception('طھط¹ط°ط± طھط­ظ…ظٹظ„ ط§ظ„طµظپط­ط©');
  }

  void _preloadNearbyPages(int page) {
    final nearbyPages = [page - 1, page + 1, page + 2, page - 2];

    for (final p in nearbyPages) {
      if (p >= 1 && p <= 604 && !_pageAyahsCache.containsKey(p)) {
        _getPageAyahs(p);
      }
    }
  }

  int _getCurrentHizb() {
    final hizbQuarter = _getCurrentPageHizbQuarterSync(_currentPage);
    return ((hizbQuarter - 1) ~/ 4) + 1;
  }

  int _getCurrentQuarterInHizb() {
    final hizbQuarter = _getCurrentPageHizbQuarterSync(_currentPage);
    return ((hizbQuarter - 1) % 4) + 1;
  }

  int _getPageForJuz(int juz) {
    const juzStartPages = [
      1, 22, 42, 62, 82, 102, 121, 142, 162, 182,
      201, 222, 242, 262, 282, 302, 322, 342, 362, 382,
      402, 422, 442, 462, 482, 502, 522, 542, 562, 582,
    ];
    return juzStartPages[juz - 1];
  }

  int _getPageForHizb(int hizb) {
    final targetQuarter = ((hizb - 1) * 4) + 1;

    for (final entry in _pageToHizbQuarter.entries) {
      if (entry.value == targetQuarter) {
        return entry.key;
      }
    }

    return 1;
  }

  String _toArabicNum(int n) {
    const nums = {
      '0': 'ظ ',
      '1': 'ظ،',
      '2': 'ظ¢',
      '3': 'ظ£',
      '4': 'ظ¤',
      '5': 'ظ¥',
      '6': 'ظ¦',
      '7': 'ظ§',
      '8': 'ظ¨',
      '9': 'ظ©',
    };

    String s = n.toString();
    nums.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }

  List<List<dynamic>> _splitAyahsIntoFixedVisualLines(
      List<dynamic> ayahs, {
        int maxLines = 15,
      }) {
    final List<List<dynamic>> lines = [];
    List<dynamic> currentLine = [];
    int currentLength = 0;

    // ط·ظˆظ„ طھظ‚ط±ظٹط¨ظٹ ط£ظ‚ظ„ ظ„طھظˆظ„ظٹط¯ ط£ط³ط·ط± ط£ظƒط«ط± ظˆط§ظ†طھط¸ط§ظ…ظ‹ط§
    const int maxCharsPerLine = 34;

    for (final ayah in ayahs) {
      final text = ayah['text'].toString();
      final estimatedLength = text.length;

      if (currentLine.isNotEmpty && currentLength + estimatedLength > maxCharsPerLine) {
        lines.add(currentLine);
        currentLine = [];
        currentLength = 0;
      }

      currentLine.add(ayah);
      currentLength += estimatedLength;
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    // ظ„ظˆ ط¹ط¯ط¯ ط§ظ„ط£ط³ط·ط± ط£ظ‚ظ„ ظ…ظ† ط§ظ„ظ…ط·ظ„ظˆط¨ ظ†ط¶ظٹظپ ط£ط³ط·ط± ظپط§ط±ط؛ط©
    while (lines.length < maxLines) {
      lines.add([]);
    }

    return lines.take(maxLines).toList();
  }

  Future<void> _saveLastReadingPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastPageKey, _currentPage);
    await prefs.setString(_kLastSurahKey, widget.surahName);
  }

  Future<void> _saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBookmarkPageKey, _currentPage);
    await prefs.setString(_kBookmarkSurahKey, widget.surahName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'طھظ… ط­ظپط¸ ط¹ظ„ط§ظ…ط© ط¹ظ†ط¯ ط§ظ„طµظپط­ط© $_currentPage',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _goToLastReadingPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_kLastPageKey);

    if (page == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ظ„ط§ ظٹظˆط¬ط¯ ظ…ظˆط¶ط¹ ظ…ط­ظپظˆط¸ ط³ط§ط¨ظ‚ظ‹ط§', style: GoogleFonts.cairo()),
        ),
      );
      return;
    }

    _pageController.jumpToPage(page - 1);
    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    _preloadNearbyPages(page);
    await _saveLastReadingPosition();
  }

  Future<void> _goToBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_kBookmarkPageKey);

    if (page == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ظ„ط§ طھظˆط¬ط¯ ط¹ظ„ط§ظ…ط© ظ…ط­ظپظˆط¸ط©', style: GoogleFonts.cairo()),
        ),
      );
      return;
    }

    _pageController.jumpToPage(page - 1);
    setState(() {
      _currentPage = page;
      _showControls = true;
    });

    _preloadNearbyPages(page);
    await _saveLastReadingPosition();
  }

  Future<Map<String, dynamic>> _getSavedReadingMeta() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'lastPage': prefs.getInt(_kLastPageKey),
      'lastSurah': prefs.getString(_kLastSurahKey),
      'bookmarkPage': prefs.getInt(_kBookmarkPageKey),
      'bookmarkSurah': prefs.getString(_kBookmarkSurahKey),
    };
  }

  Future<void> _playSequence() async {
    try {
      final url =
          'https://cdn.islamic.network/quran/audio/128/$_selectedReciter/${widget.surahNumber}.mp3';
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (_) {}
  }

  Future<void> _listen() async {
    try {
      if (_isListening) {
        await _speech.stop();
        if (mounted) {
          setState(() {
            _isListening = false;
            _spokenText = '';
          });
        }
        return;
      }

      var permission = await Permission.microphone.status;
      if (!permission.isGranted) {
        permission = await Permission.microphone.request();
      }

      if (!permission.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ظ„ظ… ظٹطھظ… ظ…ظ†ط­ ط¥ط°ظ† ط§ظ„ظ…ظٹظƒط±ظˆظپظˆظ†',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ط®ط·ط£ ظپظٹ ط§ظ„ظ…ظٹظƒط±ظˆظپظˆظ†: ${error.errorMsg}',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
      );

      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ط®ط¯ظ…ط© ط§ظ„طھط¹ط±ظپ ط§ظ„طµظˆطھظٹ ط؛ظٹط± ظ…طھط§ط­ط© ط¹ظ„ظ‰ ظ‡ط°ط§ ط§ظ„ط¬ظ‡ط§ط²',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (mounted) {
        setState(() {
          _isListening = true;
          _spokenText = '';
        });
      }

      await _speech.listen(
        localeId: 'ar_SA',
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        onResult: (result) {
          if (mounted) {
            setState(() {
              _spokenText = result.recognizedWords;
            });
          }
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'طھط¹ط°ط± طھط´ط؛ظٹظ„ ط§ظ„ظ…ظٹظƒط±ظˆظپظˆظ†',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showPageTafsir() async {
    final primary = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/page/$_currentPage/ar.muyassar'))
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahs = data['data']['ayahs'] as List;
        final tafsirText = ayahs.map((a) => a['text'].toString()).join('\n\n');

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF171A1E)
              : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => SafeArea(
              top: false,
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                children: [
                  _buildSheetHeader(
                    title: 'طھظپط³ظٹط± ط§ظ„طµظپط­ط©',
                    subtitle: 'ط§ظ„طµظپط­ط© $_currentPage â€¢ ط§ظ„طھظپط³ظٹط± ط§ظ„ظ…ظٹط³ط±',
                    primary: primary,
                    icon: Icons.menu_book_rounded,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: primary.withValues(alpha: 0.10)),
                    ),
                    child: Text(
                      tafsirText,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        height: 1.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('طھط¹ط°ط± طھط­ظ…ظٹظ„ طھظپط³ظٹط± ط§ظ„طµظپط­ط©', style: GoogleFonts.cairo()),
          ),
        );
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ط­ط¯ط« ط®ط·ط£ ط£ط«ظ†ط§ط، طھط­ظ…ظٹظ„ ط§ظ„طھظپط³ظٹط±', style: GoogleFonts.cairo()),
        ),
      );
    }
  }

  void _showImageReaderMenu() async {
    final primary = Theme.of(context).colorScheme.primary;
    final saved = await _getSavedReadingMeta();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF171A1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHeader(
                title: 'ط®ظٹط§ط±ط§طھ ط§ظ„ظ…طµط­ظپ',
                subtitle: widget.surahName,
                primary: primary,
                icon: Icons.menu_book_rounded,
              ),
              _buildModernSheetTile(
                icon: Icons.list_alt_rounded,
                title: 'ظپظ‡ط±ط³ ط§ظ„ظ…طµط­ظپ',
                subtitle: 'ط§ظ„ط³ظˆط±طŒ ط§ظ„ط£ط¬ط²ط§ط،طŒ ط§ظ„ط£ط­ط²ط§ط¨طŒ ط§ظ„طµظپط­ط§طھ',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  _showAdvancedIndexSheet();
                },
              ),
              _buildModernSheetTile(
                icon: Icons.search_rounded,
                title: 'ط§ظ„ط¨ط­ط« ظپظٹ ط§ظ„ظ‚ط±ط¢ظ†',
                subtitle: 'ط§ط¨ط­ط« ط¹ظ† ظƒظ„ظ…ط© ط£ظˆ ط¢ظٹط©',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  showSearch(
                    context: context,
                    delegate: QuranSearch(primaryColor: primary),
                  ).then((result) {
                    if (result != null) {
                      _pageController.jumpToPage(result['page'] - 1);
                      setState(() {
                        _currentPage = result['page'];
                        _showControls = true;
                      });
                      _saveLastReadingPosition();
                    }
                  });
                },
              ),
              _buildModernSheetTile(
                icon: Icons.swap_horiz_rounded,
                title: 'ط§ظ„ط§ظ†طھظ‚ط§ظ„ ط§ظ„ط³ط±ظٹط¹',
                subtitle: 'ط§ط°ظ‡ط¨ ظ…ط¨ط§ط´ط±ط© ط¥ظ„ظ‰ طµظپط­ط© ظ…ط¹ظٹظ†ط©',
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  _showQuickJumpSheet();
                },
              ),
              _buildModernSheetTile(
                icon: Icons.history_rounded,
                title: 'ط¢ط®ط± ظ…ظˆط¶ط¹',
                subtitle: saved['lastPage'] != null
                    ? 'ط§ظ„طµظپط­ط© ${saved['lastPage']}'
                    : 'ظ„ط§ ظٹظˆط¬ط¯ ظ…ظˆط¶ط¹ ظ…ط­ظپظˆط¸',
                primary: primary,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _goToLastReadingPosition();
                },
              ),
              _buildModernSheetTile(
                icon: Icons.bookmark_rounded,
                title: 'ط§ظ„ط°ظ‡ط§ط¨ ط¥ظ„ظ‰ ط§ظ„ط¹ظ„ط§ظ…ط©',
                subtitle: saved['bookmarkPage'] != null
                    ? 'ط§ظ„طµظپط­ط© ${saved['bookmarkPage']}'
                    : 'ظ„ط§ طھظˆط¬ط¯ ط¹ظ„ط§ظ…ط© ظ…ط­ظپظˆط¸ط©',
                primary: primary,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _goToBookmark();
                },
              ),
              _buildModernSheetTile(
                icon: Icons.record_voice_over_rounded,
                title: 'ط§ط®طھظٹط§ط± ط§ظ„ظ‚ط§ط±ط¦',
                subtitle: _selectedReciterName,
                primary: primary,
                onTap: () {
                  Navigator.pop(ctx);
                  _showReciterDialog(primary);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMushafPage(
      int page,
      Color bg,
      Color text,
      Color primary,
      bool isDark,
      ) {
    final hizbQuarter = _getCurrentPageHizbQuarterSync(page);
    final hizb = ((hizbQuarter - 1) ~/ 4) + 1;
    final juz = ((hizbQuarter - 1) ~/ 8) + 1;

    return FutureBuilder<String?>(
      future: _getLocalPagePathIfExists(page),
      builder: (context, snapshot) {
        final localPath = snapshot.data;

        Widget imageWidget;

        if (localPath != null) {
          imageWidget = Image.file(
            File(localPath),
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
          );
        } else {
          imageWidget = CachedNetworkImage(
            imageUrl: _getPageImageUrl(page),
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
            fadeInDuration: const Duration(milliseconds: 150),
            placeholder: (context, url) => Container(
              color: bg,
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: primary),
            ),
            errorWidget: (context, url, error) {
              return Container(
                color: bg,
                alignment: Alignment.center,
                child: Text(
                  'طھط¹ط°ط± طھط­ظ…ظٹظ„ ط§ظ„طµظپط­ط© ${_toArabicNum(page)}',
                  style: GoogleFonts.cairo(
                    color: primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            final currentPageAyahs = _pageAyahsCache[page];
            final currentSurahName = (currentPageAyahs != null && currentPageAyahs.isNotEmpty)
                ? (currentPageAyahs.first['surah']?['name']?.toString() ?? widget.surahName)
                : widget.surahName;

            return Container(
              color: bg,
              width: double.infinity,
              height: double.infinity,
              child: ClipRect(
                child: SizedBox(
                  width: availableWidth,
                  height: availableHeight,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 960,
                      height: 1760,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            top: 120,
                              child: imageWidget
                          ),
                          Positioned(
                            top: 38,
                            left: 26,
                            right: 26,
                            child: Row(
                              children: [
                                Text(
                              currentSurahName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'ط¬ط²ط، ${_toArabicNum(juz)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildHizbProgressCircle(
                                  primary: primary,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ط­ط²ط¨ ${_toArabicNum(hizb)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            bottom: 34,
                            right: 28,
                            child: Text(
                              _toArabicNum(page),
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHizbProgressCircle({
    required Color primary,
    required bool isDark,
  }) {
    final quarter = _getCurrentQuarterInHizb();

    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: HizbQuarterPainter(
          quarter: quarter,
          activeColor: primary,
          inactiveColor: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.black.withValues(alpha: 0.10),
        ),
        child: Center(
          child: Container(
            width: 5.5,
            height: 5.5,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPreparingBanner(Color primary) {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _backgroundPrepareMessage,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pageBg = isDark ? const Color(0xFF121212) : const Color(0xFFFDFDFD);
    final textColor = isDark ? Colors.white : const Color(0xFF222222);

    final media = MediaQuery.of(context);
    final topPadding = media.padding.top;
    final bottomPadding = media.padding.bottom;

    final topBarHeight = topPadding + 68.0;
    final bottomOverlayHeight = bottomPadding + 88.0;

    if (_isPreparingQuran && !_isInitialPageReady) {
      return Scaffold(
        backgroundColor: pageBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(
                          value: _quranLoadingProgress > 0 && _quranLoadingProgress < 1
                              ? _quranLoadingProgress
                              : null,
                          strokeWidth: 4,
                          color: primary,
                          backgroundColor: primary.withValues(alpha: 0.15),
                        ),
                      ),
                      Icon(
                        Icons.menu_book_rounded,
                        color: primary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _quranLoadingMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _quranLoadingProgress > 0 && _quranLoadingProgress <= 1
                        ? _quranLoadingProgress
                        : null,
                    minHeight: 7,
                    backgroundColor: primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(_quranLoadingProgress * 100).clamp(0, 100).toInt()}%',
                  style: GoogleFonts.cairo(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPadding,
                  bottom: bottomPadding,
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 604,
                  reverse: true,
                  physics: widget.targetPage != null
                      ? const ClampingScrollPhysics()
                      : const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    final newPage = index + 1;

                    if (widget.targetPage != null && newPage > widget.targetPage!) {
                      _pageController.jumpToPage(widget.targetPage! - 1);
                      return;
                    }

                    if (widget.initialPage != null && newPage < widget.initialPage!) {
                      _pageController.jumpToPage(widget.initialPage! - 1);
                      return;
                    }

                    setState(() {
                      _currentPage = newPage;
                    });

                    _preloadNearbyPages(newPage);
                    _saveLastReadingPosition();
                  },
                  itemBuilder: (context, index) {
                    final page = index + 1;
                    return _buildMushafPage(
                      page,
                      pageBg,
                      textColor,
                      primary,
                      isDark,
                    );
                  },
                ),
              ),
            ),
          ),
          if (_isBackgroundPreparing && _backgroundPrepareMessage.isNotEmpty)
            _buildBackgroundPreparingBanner(primary),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -(topBarHeight + 10),
            left: 0,
            right: 0,
            height: topBarHeight,
            child: _buildReaderStyleTopBar(
              primary: primary,
              isDark: isDark,
              topPadding: topPadding,
            ),
          ),
          if (_spokenText.isNotEmpty && _isListening)
            Positioned(
              left: 16,
              right: 16,
              bottom: (bottomPadding > 0 ? bottomPadding : 8) + 90,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _spokenText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            bottom: _showControls ? 10 : -(bottomOverlayHeight + 20),
            left: 0,
            right: 0,
            height: bottomOverlayHeight,
            child: _buildReaderStyleBottomOverlay(
              primary: primary,
              isDark: isDark,
              bottomPadding: bottomPadding,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader({
    required String title,
    String? subtitle,
    required Color primary,
    IconData? icon,
  }) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 14),
        if (icon != null) Icon(icon, color: primary, size: 24),
        if (icon != null) const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Divider(
          height: 1,
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReaderStyleTopBar({
    required Color primary,
    required bool isDark,
    required double topPadding,
  }) {
    final boxColor = isDark ? const Color(0xFF232323) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    final hizbQuarter = _getCurrentPageHizbQuarterSync(_currentPage);
    final hizb = ((hizbQuarter - 1) ~/ 4) + 1;
    final juz = ((hizbQuarter - 1) ~/ 8) + 1;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 2,
        left: 10,
        right: 10,
        bottom: 8,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          _readerTopSquareButtonWithBadge(
            icon: _getQuranDownloadStatusIcon(),
            onTap: _handleQuranDownloadStatusTap,
            isDark: isDark,
            iconColorOverride: _getQuranDownloadStatusColor(primary),
            badgeColor: _getQuranDownloadBadgeColor(),
          ),
          const SizedBox(width: 8),
          _readerTopSquareButton(
            icon: Icons.search,
            onTap: () {
              final primary = Theme.of(context).colorScheme.primary;
              showSearch(
                context: context,
                delegate: QuranSearch(primaryColor: primary),
              ).then((result) {
                if (result != null) {
                  _pageController.jumpToPage(result['page'] - 1);
                  setState(() {
                    _currentPage = result['page'];
                    _showControls = true;
                  });
                  _saveLastReadingPosition();
                }
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.surahName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'طµظپط­ط© $_currentPage | ط¬ط²ط، $juz | ط­ط²ط¨ $hizb',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _readerTopSquareButton(
            icon: Icons.menu,
            onTap: _showImageReaderMenu,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _readerTopSquareButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColorOverride,
  }) {
    return Material(
      color: isDark ? const Color(0xFF232323) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: iconColorOverride ?? (isDark ? Colors.white : Colors.black87),
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildReaderStyleBottomOverlay({
    required Color primary,
    required bool isDark,
    required double bottomPadding,
  }) {
    final barColor = isDark ? const Color(0xFF232323) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        bottom: bottomPadding > 0 ? bottomPadding : 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _bottomPillButton(
                    isHighlighted: true,
                    icon: Icons.error_outline_rounded,
                    label: 'ط£ط®ط·ط§ط،',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'ظ…ظٹط²ط© ط§ظ„ط£ط®ط·ط§ط،/ط§ظ„طھط³ظ…ظٹط¹ ط³طھظڈظپط¹ظ‘ظ„ ظ„ط§ط­ظ‚ظ‹ط§',
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _bottomPillButton(
                    icon: Icons.menu_book_outlined,
                    label: 'طھظپط³ظٹط±',
                    isDark: isDark,
                    onTap: _showPageTafsir,
                  ),
                  const SizedBox(width: 4),
                  _bottomPillButton(
                    icon: _hideVerses
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    label: _hideVerses ? 'ط¥ط¸ظ‡ط§ط±' : 'ط¥ط®ظپط§ط،',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _hideVerses = !_hideVerses;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Material(
            color: primary.withValues(alpha: 0.14),
            shape: const CircleBorder(),
            elevation: 8,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ظ…ظٹط²ط© ط§ظ„ظ…ظٹظƒط±ظˆظپظˆظ† ط³طھظڈظپط¹ظ‘ظ„ ظ„ط§ط­ظ‚ظ‹ط§',
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                );
              },
              child: Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFC8F8D1),
                      Color(0xFF8AF0AB),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomPillButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final iconColor = isHighlighted
        ? const Color(0xFFD6A300)
        : (isDark ? Colors.white70 : Colors.black87);

    final textColor = isHighlighted
        ? const Color(0xFFD6A300)
        : (isDark ? Colors.white70 : Colors.black87);

    final pillColor = isHighlighted
        ? const Color(0xFFFFF4D6)
        : isDark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF7F7F7);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: iconColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSheetTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color primary,
    VoidCallback? onTap,
    Widget? trailing,
    bool danger = false,
  }) {
    final color = danger ? Colors.red : primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: Colors.grey,
        ),
      )
          : null,
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildPagesTab(BuildContext ctx) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: 604,
      itemBuilder: (context, index) {
        final page = index + 1;
        final selected = page == _currentPage;
        final primary = Theme.of(context).colorScheme.primary;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pop(ctx);
            _jumpToPage(page);
          },
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? primary.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? primary : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _toArabicNum(page),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahsTab(BuildContext ctx) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _surahNames.length,
      itemBuilder: (context, index) {
        final surahNumber = index + 1;
        final page = _surahStartPages[index];

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            _surahNames[index],
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'طھط¨ط¯ط£ ظ…ظ† طµظپط­ط© ${_toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          trailing: Text(
            _toArabicNum(surahNumber),
            style: GoogleFonts.cairo(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pop(ctx);
            _jumpToPage(page);
          },
        );
      },
    );
  }

  Widget _buildJuzTab(BuildContext ctx) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juz = index + 1;
        final page = _getPageForJuz(juz);

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'ط§ظ„ط¬ط²ط، ${_toArabicNum(juz)}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'ظٹط¨ط¯ط£ ظ…ظ† طµظپط­ط© ${_toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          onTap: () {
            Navigator.pop(ctx);
            _jumpToPage(page);
          },
        );
      },
    );
  }

  Widget _buildHizbTab(BuildContext ctx) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 60,
      itemBuilder: (context, index) {
        final hizb = index + 1;
        final page = _getPageForHizb(hizb);

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'ط§ظ„ط­ط²ط¨ ${_toArabicNum(hizb)}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'ظٹط¨ط¯ط£ ظ…ظ† طµظپط­ط© ${_toArabicNum(page)}',
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          onTap: () {
            Navigator.pop(ctx);
            _jumpToPage(page);
          },
        );
      },
    );
  }

  Widget _quickJumpCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readerTopSquareButtonWithBadge({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColorOverride,
    required Color badgeColor,
  }) {
    return Material(
      color: isDark ? const Color(0xFF232323) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icon,
                  color: iconColorOverride ?? (isDark ? Colors.white : Colors.black87),
                  size: 23,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
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

class HizbQuarterPainter extends CustomPainter {
  final int quarter;
  final Color activeColor;
  final Color inactiveColor;

  HizbQuarterPainter({
    required this.quarter,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.2;
    const gap = 0.18;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const fullQuarter = 1.57079632679;
    const startBase = -1.57079632679;
    final sweep = fullQuarter - gap;

    for (int i = 0; i < 4; i++) {
      final startAngle = startBase + (i * fullQuarter) + (gap / 2);

      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        i < quarter ? activePaint : inactivePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HizbQuarterPainter oldDelegate) {
    return oldDelegate.quarter != quarter ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}