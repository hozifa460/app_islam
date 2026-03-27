import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'books_reader_screen.dart';
import '../hadith/hadith_book_screen.dart';

class BookVolumesScreen extends StatefulWidget {
  final String title;
  final List<dynamic> volumes;
  final Color primaryColor;

  const BookVolumesScreen({
    super.key,
    required this.title,
    required this.volumes,
    required this.primaryColor,
  });

  @override
  State<BookVolumesScreen> createState() => _BookVolumesScreenState();
}

class _BookVolumesScreenState extends State<BookVolumesScreen> {
  Map<String, bool> _downloadedVolumes = {};
  bool _loadingStatus = true;
  bool _isDownloadingAll = false;
  double _downloadAllProgress = 0.0;
  int _downloadedNowCount = 0;
  bool _cancelDownloadAll = false;
  bool _wasDownloadStopped = false;
  http.Client? _downloadClient;
  double _currentFileProgress = 0.0;
  String _currentDownloadingTitle = '';
  final Color _gold = const Color(0xFFE6B325);

  @override
  void initState() {
    super.initState();
    _checkDownloadedVolumes();
  }

  @override
  void dispose() {
    _downloadClient?.close();
    super.dispose();
  }

  void _stopDownloadAll() {
    debugPrint('⛔ Stop download requested');

    _downloadClient?.close();

    setState(() {
      _cancelDownloadAll = true;
      _wasDownloadStopped = true;
    });
  }

  Future<void> _downloadAllVolumes() async {
    if (_isDownloadingAll) return;

    setState(() {
      _isDownloadingAll = true;
      _cancelDownloadAll = false;
      _downloadAllProgress = 0.0;
      _downloadedNowCount = 0;
      _currentFileProgress = 0.0;
      _currentDownloadingTitle = '';
      _wasDownloadStopped = false;
    });

    try {
      final total = widget.volumes.length;

      for (int i = 0; i < widget.volumes.length; i++) {
        if (_cancelDownloadAll) break;

        final volume = Map<String, dynamic>.from(widget.volumes[i]);
        final id = volume['id'].toString();
        final status = _downloadedVolumes[id] ?? false;

        if (!status) {
          await _downloadSingleVolume(volume);
        }

        final currentDownloaded = i + 1;

        if (mounted) {
          setState(() {
            _downloadedNowCount = currentDownloaded;
            _downloadAllProgress = currentDownloaded / total;
          });
        }
      }

      await _checkDownloadedVolumes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _cancelDownloadAll
                  ? 'تم إيقاف التحميل، ويمكنك استكماله لاحقًا'
                  : 'تم تحميل/فحص جميع المجلدات بنجاح',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: _cancelDownloadAll ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Download all volumes error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء تحميل المجلدات',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingAll = false;
          _cancelDownloadAll = false;
          _currentFileProgress = 0.0;
          _currentDownloadingTitle = '';
        });
      }
    }
  }

  Future<void> _downloadSingleVolume(Map<String, dynamic> volume) async {
    String id = volume['id'].toString();
    if (id == 'riyad') id = 'riyadussalihin';
    if (id == 'nawawi40') id = 'forty';

    final urlString =
        volume['type'] == 'hadith'
            ? 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$id.json'
            : (volume['pdfUrl'] ?? '');

    if (urlString.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final file =
        volume['type'] == 'hadith'
            ? File('${dir.path}/hadith_${id}_v1.json')
            : File('${dir.path}/$id.pdf');

    try {
      if (mounted) {
        setState(() {
          _currentDownloadingTitle = volume['title']?.toString() ?? 'مجلد';
          _currentFileProgress = 0.0;
        });
      }

      _downloadClient = http.Client();

      final request = http.Request('GET', Uri.parse(urlString));
      final response = await _downloadClient!
          .send(request)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('فشل تحميل الملف');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        if (_cancelDownloadAll) {
          await sink.close();

          if (await file.exists()) {
            await file.delete();
          }

          debugPrint('⛔ Download canceled أثناء تحميل $id');
          return;
        }

        sink.add(chunk);
        receivedBytes += chunk.length;

        if (mounted && totalBytes > 0) {
          setState(() {
            _currentFileProgress = receivedBytes / totalBytes;
          });
        }
      }

      await sink.flush();
      await sink.close();

      if (mounted) {
        setState(() {
          _currentFileProgress = 1.0;
        });
      }

      debugPrint('✅ Finished downloading $id');
    } catch (e) {
      debugPrint('❌ Download single volume error for $id: $e');

      if (await file.exists()) {
        await file.delete();
      }
    } finally {
      _downloadClient?.close();
      _downloadClient = null;
    }
  }

  Future<void> _checkDownloadedVolumes() async {
    final dir = await getApplicationDocumentsDirectory();
    final Map<String, bool> tempStatus = {};

    for (final raw in widget.volumes) {
      final volume = Map<String, dynamic>.from(raw);

      String id = volume['id'].toString();
      if (id == 'riyad') id = 'riyadussalihin';
      if (id == 'nawawi40') id = 'forty';

      final File file =
          volume['type'] == 'hadith'
              ? File('${dir.path}/hadith_${id}_v1.json')
              : File('${dir.path}/$id.pdf');

      tempStatus[volume['id'].toString()] = await file.exists();
    }

    if (mounted) {
      setState(() {
        _downloadedVolumes = tempStatus;
        _loadingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    const gold = Color(0xFFE6B325);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.primaryColor,
                    widget.primaryColor.withOpacity(0.78),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'اختر المجلد الذي يناسبك للقراءة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.library_books_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body:
            _loadingStatus
                ? Center(
                  child: CircularProgressIndicator(color: widget.primaryColor),
                )
                : SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final small = width < 360;
                      final spacing = small ? 10.0 : 12.0;

                      final crossAxisCount = width < 430 ? 2 : 3;
                      final childAspectRatio = small ? 0.68 : 0.75;

                      final downloadedCount =
                          _downloadedVolumes.values.where((e) => e).length;

                      final totalCount = widget.volumes.length;
                      final overallProgress =
                          totalCount == 0 ? 0.0 : downloadedCount / totalCount;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.primaryColor.withOpacity(0.10),
                                    gold.withOpacity(0.10),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: gold.withOpacity(0.18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'المجلدات المتاحة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'اختر المجلد الذي تريد قراءته أو تحميله',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: gold.withOpacity(0.16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.18 : 0.05,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: gold.withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: gold.withOpacity(0.20),
                                          ),
                                        ),
                                        child: Text(
                                          '$downloadedCount / $totalCount محمّل',
                                          style: GoogleFonts.cairo(
                                            color: gold,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      _isDownloadingAll
                                          ? ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                            ),
                                            onPressed: _stopDownloadAll,
                                            icon: const Icon(
                                              Icons.stop_rounded,
                                              size: 18,
                                            ),
                                            label: Text(
                                              'إيقاف',
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                          : ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  widget.primaryColor,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                            ),
                                            onPressed: _downloadAllVolumes,
                                            icon: const Icon(
                                              Icons.download_rounded,
                                              size: 18,
                                            ),
                                            label: Text(
                                              'تحميل الكل',
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  if (_isDownloadingAll) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: LinearProgressIndicator(
                                        value: _downloadAllProgress,
                                        minHeight: 7,
                                        backgroundColor: Colors.grey
                                            .withOpacity(0.15),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              widget.primaryColor,
                                            ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        Text(
                                          '${((_isDownloadingAll ? _downloadAllProgress : overallProgress) * 100).toInt()}%',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            color:
                                                downloadedCount == totalCount
                                                    ? Colors.green
                                                    : widget.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '$downloadedCount من $totalCount مجلد',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            color: subTextColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    if (_isDownloadingAll &&
                                        _currentDownloadingTitle
                                            .isNotEmpty) ...[
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          'جاري تحميل: $_currentDownloadingTitle',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            color: subTextColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: _currentFileProgress,
                                          minHeight: 5,
                                          backgroundColor: Colors.grey
                                              .withOpacity(0.12),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _gold,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${(_currentFileProgress * 100).toInt()}%',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color: _gold,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],

                                    if (_wasDownloadStopped &&
                                        !_isDownloadingAll) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.pause_circle_outline,
                                            color: Colors.orange,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'تم إيقاف التحميل سابقًا، ويمكنك استكماله بالضغط على تحميل الكل',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.volumes.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    childAspectRatio: childAspectRatio,
                                  ),
                              itemBuilder: (context, index) {
                                final volume = Map<String, dynamic>.from(
                                  widget.volumes[index],
                                );
                                final imageUrl =
                                    volume['imageUrl']?.toString() ?? '';
                                final isDownloaded =
                                    _downloadedVolumes[volume['id']
                                        .toString()] ??
                                    false;

                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(
                                    milliseconds: 350 + (index * 60),
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 18 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () {
                                      if (volume['type'] == 'hadith') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => HadithBookScreen(
                                                  bookId: volume['id'],
                                                  bookTitle: volume['title'],
                                                  primaryColor:
                                                      widget.primaryColor,
                                                ),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => BookReaderScreen(
                                                  bookId: volume['id'],
                                                  bookTitle: volume['title'],
                                                  primaryColor:
                                                      widget.primaryColor,
                                                  pdfUrl:
                                                      volume['pdfUrl'] ?? '',
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: gold.withOpacity(0.18),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              isDark ? 0.18 : 0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      child:
                                                          imageUrl.isNotEmpty
                                                              ? CachedNetworkImage(
                                                                imageUrl:
                                                                    imageUrl,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                placeholder:
                                                                    (
                                                                      context,
                                                                      url,
                                                                    ) => Container(
                                                                      color:
                                                                          isDark
                                                                              ? Colors.white.withOpacity(
                                                                                0.04,
                                                                              )
                                                                              : Colors.grey.shade100,
                                                                      child: Center(
                                                                        child: CircularProgressIndicator(
                                                                          color:
                                                                              gold,
                                                                          strokeWidth:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                errorWidget:
                                                                    (
                                                                      context,
                                                                      url,
                                                                      error,
                                                                    ) => Container(
                                                                      color:
                                                                          isDark
                                                                              ? Colors.white.withOpacity(
                                                                                0.04,
                                                                              )
                                                                              : Colors.grey.shade100,
                                                                      child: Icon(
                                                                        Icons
                                                                            .book,
                                                                        color: gold
                                                                            .withOpacity(
                                                                              0.6,
                                                                            ),
                                                                        size:
                                                                            36,
                                                                      ),
                                                                    ),
                                                              )
                                                              : Container(
                                                                color:
                                                                    isDark
                                                                        ? Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.04,
                                                                            )
                                                                        : Colors
                                                                            .grey
                                                                            .shade100,
                                                                child: Icon(
                                                                  Icons.book,
                                                                  color: gold
                                                                      .withOpacity(
                                                                        0.6,
                                                                      ),
                                                                  size: 36,
                                                                ),
                                                              ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isDownloaded
                                                                ? Colors.green
                                                                    .withOpacity(
                                                                      0.9,
                                                                    )
                                                                : Colors.black
                                                                    .withOpacity(
                                                                      0.7,
                                                                    ),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        isDownloaded
                                                            ? Icons.check
                                                            : Icons
                                                                .cloud_download,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              volume['title'] ?? 'مجلد',
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                                fontSize: small ? 12 : 13,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isDownloaded
                                                  ? 'جاهز للقراءة'
                                                  : 'اضغط لفتح المجلد',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.cairo(
                                                color:
                                                    isDownloaded
                                                        ? Colors.green
                                                        : subTextColor,
                                                fontSize: small ? 10 : 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
