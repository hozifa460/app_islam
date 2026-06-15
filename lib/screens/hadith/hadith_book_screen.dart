import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

class HadithBookScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final Color primaryColor;
  final dynamic initialHadithNumber;
  final String? searchQuery;

  const HadithBookScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.primaryColor,
    this.searchQuery,
    this.initialHadithNumber,
  });

  @override
  State<HadithBookScreen> createState() => _HadithBookScreenState();
}

class _HadithBookScreenState extends State<HadithBookScreen>
    with TickerProviderStateMixin {
  List<dynamic> _allHadiths = [];
  List<dynamic> _displayedHadiths = [];

  bool _isLoading = true;
  bool _isDownloading = false;
  bool _hasError = false;
  String _statusMessage = 'ط¬ط§ط±ظٹ ط§ظ„طھظ‡ظٹط¦ط©...';

  int _currentMax = 20;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final TextEditingController _searchController = TextEditingController();

  bool _showScrollToTop = false;
  bool _isSearchExpanded = false;
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _fabAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _loadingRotation;

  final Color _gold = const Color(0xFFD4A847);

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOutBack),
    );

    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadingRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _loadingAnimationController, curve: Curves.linear),
    );

    _itemPositionsListener.itemPositions.addListener(_onScroll);
    _initOfflineBook();
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final firstVisible = positions.reduce((a, b) => a.index < b.index ? a : b);
    final shouldShow = firstVisible.index > 3;

    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
      if (shouldShow) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fabAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _jumpToInitialHadith() {
    if (widget.initialHadithNumber == null) return;
    if (_displayedHadiths.isEmpty) return;

    final index = _displayedHadiths.indexWhere((h) {
      final number = h['hadithnumber'] ?? h['number'] ?? h['id'];
      return number.toString() == widget.initialHadithNumber.toString();
    });

    if (index == -1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_itemScrollController.isAttached) return;

      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _normalizeText(String text) {
    if (text.isEmpty) return "";
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '')
        .replaceAll(RegExp(r'[ط£ط¥ط¢ط§ظ±ظ°]'), 'ط§')
        .replaceAll(RegExp(r'[ظٹظ‰ط¦]'), 'ظٹ')
        .replaceAll(RegExp(r'[ط©ظ‡]'), 'ظ‡')
        .replaceAll('ط¤', 'ظˆ')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  List<TextSpan> _buildHighlightedHadithText(String text, String? keyword, Color textColor) {
    if (keyword == null || keyword.trim().isEmpty) {
      return [TextSpan(text: text, style: GoogleFonts.amiri(fontSize: 20, height: 1.9, color: textColor))];
    }

    List<TextSpan> spans = [];
    List<String> words = text.split(' ');
    String cleanKeyword = _normalizeText(keyword);

    for (String word in words) {
      String cleanWord = _normalizeText(word);
      if (cleanWord.contains(cleanKeyword)) {
        spans.add(TextSpan(
          text: '$word ',
          style: GoogleFonts.amiri(
            fontSize: 20,
            height: 1.9,
            color: Colors.black87,
            backgroundColor: _gold.withValues(alpha: 0.4),
            fontWeight: FontWeight.bold,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: '$word ',
          style: GoogleFonts.amiri(fontSize: 20, height: 1.9, color: textColor),
        ));
      }
    }
    return spans;
  }

  Future<void> _initOfflineBook() async {
    try {
      String apiId = widget.bookId;
      if (apiId == 'riyad') apiId = 'riyadussalihin';
      if (apiId == 'nawawi40') apiId = 'forty';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/hadith_${apiId}_v1.json');

      if (await file.exists()) {
        setState(() {
          _statusMessage = 'ط¬ط§ط±ظٹ ظپطھط­ ط§ظ„ظƒطھط§ط¨...';
        });
        final jsonString = await file.readAsString();
        _processData(json.decode(jsonString));
      } else {
        setState(() {
          _isDownloading = true;
          _statusMessage = 'ط¬ط§ط±ظٹ طھظ†ط²ظٹظ„ ط§ظ„ظƒطھط§ط¨ ظ„ط£ظˆظ„ ظ…ط±ط©...\nط³ظٹط¹ظ…ظ„ ط¨ط¯ظˆظ† ط¥ظ†طھط±ظ†طھ ظ„ط§ط­ظ‚ط§ظ‹.';
        });

        final url = Uri.parse('https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$apiId.json');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes);
          await file.writeAsString(decodedBody);
          _processData(json.decode(decodedBody));
        } else {
          throw Exception('ظپط´ظ„ ظپظٹ ط§ظ„طھط­ظ…ظٹظ„');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDownloading = false;
          _hasError = true;
          _statusMessage = 'طھط£ظƒط¯ ظ…ظ† ط§طھطµط§ظ„ظƒ ط¨ط§ظ„ط¥ظ†طھط±ظ†طھ ظپظٹ ط§ظ„ظ…ط±ط© ط§ظ„ط£ظˆظ„ظ‰';
        });
      }
    }
  }

  void _processData(dynamic data) {
    List<dynamic> rawList = [];
    if (data is Map && data.containsKey('hadiths')) {
      rawList = data['hadiths'];
    } else if (data is List) {
      rawList = data;
    }

    List<dynamic> validList = [];

    for (var h in rawList) {
      String rawText = h['text'] ?? h['body'] ?? h['hadithArabic'] ?? '';
      String cleanText = rawText.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      String reference = '';
      if (h['reference'] != null && h['reference'] is Map) {
        reference = h['reference']['book']?.toString() ?? '';
      }

      if (cleanText.length > 5) {
        h['originalText'] = cleanText;
        h['searchableText'] = _normalizeText(cleanText);
        h['chapter'] = reference;
        validList.add(h);
      }
    }

    if (mounted) {
      setState(() {
        _allHadiths = validList;
        _displayedHadiths = _allHadiths;
        _currentMax = _displayedHadiths.length;
        _isLoading = false;
        _isDownloading = false;
        _hasError = false;
      });

      _jumpToInitialHadith();
    }
  }

  void _loadMore() {
    if (_currentMax < _displayedHadiths.length) {
      setState(() {
        _currentMax += 20;
      });
    }
  }

  void _filterHadiths(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _displayedHadiths = _allHadiths;
        _currentMax = _displayedHadiths.length;
      });
      return;
    }

    String normalizedQuery = _normalizeText(query);

    setState(() {
      _displayedHadiths = _allHadiths.where((hadith) {
        final searchableText = hadith['searchableText'] ?? '';
        final number = hadith['hadithnumber'].toString();
        return searchableText.contains(normalizedQuery) || number.contains(normalizedQuery);
      }).toList();
      _currentMax = _displayedHadiths.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F3EE);
    final textColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // â”€â”€â”€ Header â”€â”€â”€
            _buildSliverAppBar(isDark, bgColor),

            // â”€â”€â”€ Body â”€â”€â”€
            SliverFillRemaining(
              child: _buildBody(isDark, textColor, bgColor),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingButtons(isDark),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark, Color bgColor) {
    return SliverAppBar(
      expandedHeight: _isSearchExpanded ? 140 : 120,
      pinned: true,
      floating: false,
      backgroundColor: isDark ? const Color(0xFF111827) : widget.primaryColor,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        // Search toggle button
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _isSearchExpanded ? Icons.close : Icons.search,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = !_isSearchExpanded;
                  if (!_isSearchExpanded) {
                    _searchController.clear();
                    _filterHadiths('');
                    _searchFocusNode.unfocus();
                  } else {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _searchFocusNode.requestFocus();
                    });
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background pattern
            CustomPaint(
              painter: _HeaderPatternPainter(
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(60, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _gold.withValues(alpha: 0.3)),
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: _gold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.bookTitle,
                                style: GoogleFonts.amiri(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!_isLoading && !_hasError)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${_allHadiths.length} ط­ط¯ظٹط«',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: _gold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (_searchController.text.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _gold.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${_displayedHadiths.length} ظ†طھظٹط¬ط©',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Search bar (animated)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _isSearchExpanded ? 56 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isSearchExpanded ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildSearchField(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom curve
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _filterHadiths,
        style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'ط§ط¨ط­ط« ط¨ط§ظ„ظƒظ„ظ…ط© ط£ظˆ ط±ظ‚ظ… ط§ظ„ط­ط¯ظٹط«...',
          hintStyle: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: _gold, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
            onPressed: () {
              _searchController.clear();
              _filterHadiths('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, Color textColor, Color bgColor) {
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;

    if (_isLoading || _isDownloading) {
      return _buildLoadingState(isDark);
    }

    if (_hasError) {
      return _buildErrorState(isDark, textColor);
    }

    if (_displayedHadiths.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _displayedHadiths.length,
      itemBuilder: (context, index) {
        final hadith = _displayedHadiths[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index % 5) * 50),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildHadithCard(hadith, index, isDark, cardColor, textColor),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          AnimatedBuilder(
            animation: _loadingRotation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Transform.rotate(
                    angle: _loadingRotation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.primaryColor.withValues(alpha: 0.2),
                          width: 3,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _ArcPainter(
                          color: widget.primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                  // Inner icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isDownloading ? Icons.cloud_download_rounded : Icons.menu_book_rounded,
                      color: widget.primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: widget.primaryColor,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
          if (_isDownloading) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: widget.primaryColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(widget.primaryColor),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 50,
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'طھط¹ط°ط± طھط­ظ…ظٹظ„ ط§ظ„ظƒطھط§ط¨',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _initOfflineBook,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: _gold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ظ„ط§ طھظˆط¬ط¯ ظ†طھط§ط¦ط¬',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ط¬ط±ظ‘ط¨ ط§ظ„ط¨ط­ط« ط¨ظƒظ„ظ…ط§طھ ظ…ط®طھظ„ظپط©',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(
      dynamic hadith,
      int index,
      bool isDark,
      Color cardColor,
      Color textColor,
      ) {
    final body = hadith['originalText'];
    final hadithNumber = hadith['hadithnumber'];
    final chapter = hadith['chapter'];
    List grades = hadith['grades'] ?? [];

    String narrator = '';
    if (body.startsWith('ط¹ظ†') || body.startsWith('ط­ط¯ط«ظ†ط§')) {
      int firstComma = body.indexOf('طŒ');
      int firstColon = body.indexOf(':');
      int splitIndex = -1;

      if (firstComma != -1 && firstColon != -1) {
        splitIndex = firstComma < firstColon ? firstComma : firstColon;
      } else if (firstComma != -1) {
        splitIndex = firstComma;
      } else if (firstColon != -1) {
        splitIndex = firstColon;
      }

      if (splitIndex > 0 && splitIndex < 100) {
        narrator = body.substring(0, splitIndex).trim();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [widget.primaryColor.withValues(alpha: 0.15), widget.primaryColor.withValues(alpha: 0.05)]
                    : [widget.primaryColor.withValues(alpha: 0.08), widget.primaryColor.withValues(alpha: 0.02)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Number badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.primaryColor, widget.primaryColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tag, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$hadithNumber',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Chapter
                Expanded(
                  child: Text(
                    chapter.isNotEmpty ? chapter : widget.bookTitle,
                    style: GoogleFonts.cairo(
                      color: widget.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Actions
                _buildActionButton(
                  icon: Icons.copy_rounded,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: '$body\n\n[${widget.bookTitle} - ط±ظ‚ظ…: $hadithNumber]'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('طھظ… ظ†ط³ط® ط§ظ„ط­ط¯ظٹط«', style: GoogleFonts.cairo()),
                        backgroundColor: widget.primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 4),
                _buildActionButton(
                  icon: Icons.share_rounded,
                  onTap: () {
                    Share.share('$body\n\n[${widget.bookTitle} - ط±ظ‚ظ…: $hadithNumber]');
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Hadith text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: SelectableText.rich(
              TextSpan(
                children: [
                  if (narrator.isNotEmpty)
                    TextSpan(
                      text: '$narrator\n',
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        color: widget.primaryColor,
                        fontWeight: FontWeight.bold,
                        height: 1.8,
                      ),
                    ),
                  ..._buildHighlightedHadithText(
                    narrator.isNotEmpty
                        ? body.substring(narrator.length).trim().replaceFirst(RegExp(r'^[طŒ:]'), '').trim()
                        : body,
                    _searchController.text,
                    textColor,
                  ),
                ],
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ),

          // Grades
          if (grades.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: grades.map<Widget>((grade) {
                      return _buildGradeChip(grade, isDark);
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildGradeChip(dynamic grade, bool isDark) {
    String gradeText = grade['grade'].toString().trim();
    String gradeName = grade['name'].toString().trim();

    Color chipBg;
    Color chipText;
    IconData gradeIcon;

    if (gradeText.toLowerCase().contains('sahih')) {
      chipBg = isDark ? const Color(0xFF0D3B2E) : Colors.green.shade50;
      chipText = isDark ? Colors.green.shade300 : Colors.green.shade700;
      gradeIcon = Icons.verified_rounded;
      gradeText = 'طµط­ظٹط­';
    } else if (gradeText.toLowerCase().contains('hasan')) {
      chipBg = isDark ? const Color(0xFF1E3A5F) : Colors.blue.shade50;
      chipText = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      gradeIcon = Icons.check_circle_rounded;
      gradeText = 'ط­ط³ظ†';
    } else if (gradeText.toLowerCase().contains('daif')) {
      chipBg = isDark ? const Color(0xFF4A2C00) : Colors.orange.shade50;
      chipText = isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      gradeIcon = Icons.info_rounded;
      gradeText = 'ط¶ط¹ظٹظپ';
    } else {
      chipBg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
      chipText = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
      gradeIcon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: chipText.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(gradeIcon, size: 14, color: chipText),
          const SizedBox(width: 6),
          Text(
            '$gradeName: $gradeText',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: chipText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scroll to top button
        ScaleTransition(
          scale: _fabScaleAnimation,
          child: FloatingActionButton.small(
            heroTag: 'scrollTop',
            backgroundColor: widget.primaryColor,
            onPressed: _scrollToTop,
            child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),

        // Quick search button (when search is not expanded)
        if (!_isSearchExpanded)
          FloatingActionButton(
            heroTag: 'search',
            backgroundColor: _gold,
            onPressed: () {
              setState(() => _isSearchExpanded = true);
              Future.delayed(const Duration(milliseconds: 300), () {
                _searchFocusNode.requestFocus();
              });
            },
            child: const Icon(Icons.search_rounded, color: Colors.white),
          ),
      ],
    );
  }
}

// â”€â”€â”€ Header Pattern Painter â”€â”€â”€
class _HeaderPatternPainter extends CustomPainter {
  final Color color;

  _HeaderPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 40.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawOctagon(canvas, Offset(x, y), spacing * 0.3, paint);
      }
    }
  }

  void _drawOctagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) - pi / 8;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// â”€â”€â”€ Arc Painter for Loading â”€â”€â”€
class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ArcPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, pi * 0.7, false, paint);
    canvas.drawArc(rect, pi, pi * 0.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}