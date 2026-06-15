import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'theme/books_theme.dart';
import 'animations/books_animations.dart';
import 'widgets/common/animated_gradient_header.dart';
import 'widgets/volumes_screen/download_progress_widget.dart';
import 'widgets/volumes_screen/volume_grid_item.dart';
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

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

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
    debugPrint('â›” Stop download requested');
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
                  ? 'طھظ… ط¥ظٹظ‚ط§ظپ ط§ظ„طھط­ظ…ظٹظ„طŒ ظˆظٹظ…ظƒظ†ظƒ ط§ط³طھظƒظ…ط§ظ„ظ‡ ظ„ط§ط­ظ‚ظ‹ط§'
                  : 'طھظ… طھط­ظ…ظٹظ„/ظپط­طµ ط¬ظ…ظٹط¹ ط§ظ„ظ…ط¬ظ„ط¯ط§طھ ط¨ظ†ط¬ط§ط­',
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
            content: Text('ط­ط¯ط« ط®ط·ط£ ط£ط«ظ†ط§ط، طھط­ظ…ظٹظ„ ط§ظ„ظ…ط¬ظ„ط¯ط§طھ',
                style: GoogleFonts.cairo()),
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

    final urlString = volume['type'] == 'hadith'
        ? 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-$id.json'
        : (volume['pdfUrl'] ?? '');

    if (urlString.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = volume['type'] == 'hadith'
        ? File('${dir.path}/hadith_${id}_v1.json')
        : File('${dir.path}/$id.pdf');

    try {
      if (mounted) {
        setState(() {
          _currentDownloadingTitle = volume['title']?.toString() ?? 'ظ…ط¬ظ„ط¯';
          _currentFileProgress = 0.0;
        });
      }

      _downloadClient = http.Client();

      final request = http.Request('GET', Uri.parse(urlString));
      final response = await _downloadClient!
          .send(request)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('ظپط´ظ„ طھط­ظ…ظٹظ„ ط§ظ„ظ…ظ„ظپ');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        if (_cancelDownloadAll) {
          await sink.close();
          if (await file.exists()) await file.delete();
          debugPrint('â›” Download canceled ط£ط«ظ†ط§ط، طھط­ظ…ظٹظ„ $id');
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
        setState(() => _currentFileProgress = 1.0);
      }

      debugPrint('âœ… Finished downloading $id');
    } catch (e) {
      debugPrint('â‌Œ Download single volume error for $id: $e');
      if (await file.exists()) await file.delete();
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

      final File file = volume['type'] == 'hadith'
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

  void _navigateToVolume(Map<String, dynamic> volume) {
    if (volume['type'] == 'hadith') {
      Navigator.push(
        context,
        BooksPageRoute(
          page: HadithBookScreen(
            bookId: volume['id'],
            bookTitle: volume['title'],
            primaryColor: widget.primaryColor,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        BooksPageRoute(
          page: BookReaderScreen(
            bookId: volume['id'],
            bookTitle: volume['title'],
            primaryColor: widget.primaryColor,
            pdfUrl: volume['pdfUrl'] ?? '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = BooksTheme.getBackgroundColor(isDark);
    final textColor = BooksTheme.getTextColor(isDark);
    final subTextColor = BooksTheme.getSubTextColor(isDark);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AnimatedGradientHeader(
          title: widget.title,
          subtitle: 'ط§ط®طھط± ط§ظ„ظ…ط¬ظ„ط¯ ط§ظ„ط°ظٹ ظٹظ†ط§ط³ط¨ظƒ ظ„ظ„ظ‚ط±ط§ط،ط©',
          primaryColor: widget.primaryColor,
          icon: Icons.library_books_rounded,
          onBack: () => Navigator.pop(context),
        ),
        body: _loadingStatus
            ? Center(
          child: CircularProgressIndicator(color: widget.primaryColor),
        )
            : SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sizes = BooksSizes(MediaQuery.of(context).size);
              final downloadedCount =
                  _downloadedVolumes.values.where((e) => e).length;
              final totalCount = widget.volumes.length;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ط±ط£ط³ ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ
                    _InfoHeader(
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 14),

                    // ظ‚ط³ظ… ط§ظ„طھط­ظ…ظٹظ„
                    DownloadProgressWidget(
                      downloadedCount: downloadedCount,
                      totalCount: totalCount,
                      isDownloading: _isDownloadingAll,
                      downloadProgress: _downloadAllProgress,
                      currentFileProgress: _currentFileProgress,
                      currentDownloadingTitle: _currentDownloadingTitle,
                      wasDownloadStopped: _wasDownloadStopped,
                      primaryColor: widget.primaryColor,
                      isDark: isDark,
                      onDownloadAll: _downloadAllVolumes,
                      onStop: _stopDownloadAll,
                    ),
                    const SizedBox(height: 16),

                    // ط´ط¨ظƒط© ط§ظ„ظ…ط¬ظ„ط¯ط§طھ
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.volumes.length,
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: sizes.gridCrossAxisCount,
                        crossAxisSpacing: sizes.gridSpacing,
                        mainAxisSpacing: sizes.gridSpacing,
                        childAspectRatio: sizes.gridChildAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final volume = Map<String, dynamic>.from(
                            widget.volumes[index]);
                        final isDownloaded = _downloadedVolumes[
                        volume['id'].toString()] ??
                            false;

                        return VolumeGridItem(
                          volume: volume,
                          isDownloaded: isDownloaded,
                          index: index,
                          isDark: isDark,
                          isSmall: sizes.isSmall,
                          onTap: () => _navigateToVolume(volume),
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

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
// ط±ط£ط³ ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _InfoHeader extends StatefulWidget {
  final bool isDark;
  final Color textColor;
  final Color subTextColor;

  const _InfoHeader({
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  State<_InfoHeader> createState() => _InfoHeaderState();
}

class _InfoHeaderState extends State<_InfoHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BooksTheme.gold.withValues(alpha: 0.10),
                BooksTheme.gold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: BooksTheme.gold.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    color: BooksTheme.gold,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ط§ظ„ظ…ط¬ظ„ط¯ط§طھ ط§ظ„ظ…طھط§ط­ط©',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'ط§ط®طھط± ط§ظ„ظ…ط¬ظ„ط¯ ط§ظ„ط°ظٹ طھط±ظٹط¯ ظ‚ط±ط§ط،طھظ‡ ط£ظˆ طھط­ظ…ظٹظ„ظ‡',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: widget.subTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}