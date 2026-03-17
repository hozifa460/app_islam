import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/prayer/muezzin_catalog.dart';
import '../../services/adahn_audio_services.dart';
import '../../services/adhan_image_cache_service.dart';
import '../../services/muazzin_store.dart';
import '../../utils/offline_muezzin_image.dart';

class MuezzinListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Color primaryColor;

  const MuezzinListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.primaryColor,
  });

  @override
  State<MuezzinListScreen> createState() => _MuezzinListScreenState();
}

class _MuezzinListScreenState extends State<MuezzinListScreen> {
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);

  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _playingPreviewId;
  bool _previewLoading = false;

  final Map<String, bool> _isDownloading = {};
  final Map<String, bool> _isDownloaded = {};

  late MuezzinCategory _category;

  @override
  void initState() {
    super.initState();
    _category = muezzinCatalog.firstWhere((c) => c.id == widget.categoryId);
    _checkDownloads();
    _cacheCategoryImages();
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _cacheCategoryImages() async {
    for (final m in _category.items) {
      if (m.imageUrl.isNotEmpty) {
        await AdhanImageCacheService.instance.getOrDownload(
          id: m.id,
          url: m.imageUrl,
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkDownloads() async {
    for (final m in _category.items) {
      final downloaded = m.isBuiltIn
          ? true
          : await AdhanAudioService.instance.isDownloaded(m.id);

      if (mounted) {
        setState(() {
          _isDownloaded[m.id] = downloaded;
        });
      }
    }
  }

  Future<void> _downloadMuezzin(MuezzinInfo m) async {
    if (m.isBuiltIn) return;

    setState(() => _isDownloading[m.id] = true);

    final path = await AdhanAudioService.instance.download(
      id: m.id,
      url: m.url,
      onProgress: (_) {},
    );

    if (!mounted) return;

    setState(() {
      _isDownloading[m.id] = false;
      _isDownloaded[m.id] = path != null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          path != null ? 'تم تحميل ${m.name} بنجاح' : 'فشل تحميل ${m.name}',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: path != null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _deleteMuezzin(MuezzinInfo m) async {
    if (m.isBuiltIn) return;

    await AdhanAudioService.instance.deleteDownloaded(m.id);
    if (!mounted) return;
    setState(() => _isDownloaded[m.id] = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف ${m.name} من الهاتف', style: GoogleFonts.cairo()),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _previewMuezzin(MuezzinInfo m) async {
    try {
      if (_playingPreviewId == m.id && _previewPlayer.playing) {
        await _previewPlayer.stop();
        if (mounted) {
          setState(() {
            _playingPreviewId = null;
            _previewLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _playingPreviewId = m.id;
          _previewLoading = true;
        });
      }

      await _previewPlayer.stop();

      if (m.isBuiltIn) {
        await _previewPlayer.setAsset('assets/adahn/${m.localSoundName}.mp3');
      } else {
        final local = await AdhanAudioService.instance.getLocalPath(m.id);

        if (local != null && local.isNotEmpty) {
          await _previewPlayer.setFilePath(local);
        } else {
          await _previewPlayer.setUrl(m.url);
        }
      }

      await _previewPlayer.play();

      if (mounted) {
        setState(() {
          _previewLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _playingPreviewId = null;
          _previewLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تشغيل المعاينة', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectAsDefault(MuezzinInfo m) async {
    await MuezzinStore.setDefault(m, resetAllCustom: true);

    if (m.imageUrl.isNotEmpty) {
      await AdhanImageCacheService.instance.getOrDownload(
        id: m.id,
        url: m.imageUrl,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم اختيار ${m.name} كمؤذن افتراضي لكل الصلوات',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: _gold,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : const Color(0xFFF5F7FA);
    final cardGradient = isDark
        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white];
    final textColorMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub = isDark ? Colors.white70 : Colors.black54;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.2);
    final shadowColor =
    isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.4);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: textColorMain,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColorMain),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 380;
          final crossAxisCount = isSmall ? 1 : 2;

          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15, top: 120),
            physics: const BouncingScrollPhysics(),
            itemCount: _category.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: isSmall ? 2.2 : 0.65,
            ),
            itemBuilder: (context, index) {
              final m = _category.items[index];
              final downloading = _isDownloading[m.id] == true;
              final downloaded = _isDownloaded[m.id] == true;
              final isBuiltIn = m.isBuiltIn;
              final isPlaying = _playingPreviewId == m.id;

              return _buildMuezzinCard(
                m,
                downloading,
                downloaded,
                isBuiltIn,
                isPlaying,
                textColorMain,
                textColorSub,
                borderColor,
                shadowColor,
                cardGradient,
                isSmall,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMuezzinCard(
      MuezzinInfo m,
      bool downloading,
      bool downloaded,
      bool isBuiltIn,
      bool isPlaying,
      Color textColorMain,
      Color textColorSub,
      Color borderColor,
      Color shadowColor,
      List<Color> cardGradient,
      bool isSmall,
      ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPlaying ? _gold.withOpacity(0.5) : borderColor,
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying ? _gold.withOpacity(0.2) : shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isSmall
          ? _buildHorizontalCardContent(
        m,
        downloading,
        downloaded,
        isBuiltIn,
        textColorMain,
        textColorSub,
      )
          : _buildVerticalCardContent(
        m,
        downloading,
        downloaded,
        isBuiltIn,
        textColorMain,
        textColorSub,
      ),
    );
  }

  Widget _buildHorizontalCardContent(
      MuezzinInfo m,
      bool downloading,
      bool downloaded,
      bool isBuiltIn,
      Color textColorMain,
      Color textColorSub,
      ) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
          child: SizedBox(
            width: 110,
            height: double.infinity,
            child: _buildMuezzinImage(m),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  m.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColorMain,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  m.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: textColorSub,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                _buildActionRow(m, downloading, downloaded, isBuiltIn, textColorSub),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectAsDefault(m),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold.withOpacity(0.2),
                      foregroundColor: _gold,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: _gold.withOpacity(0.3)),
                      ),
                    ),
                    child: Text(
                      'اختيار',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalCardContent(
      MuezzinInfo m,
      bool downloading,
      bool downloaded,
      bool isBuiltIn,
      Color textColorMain,
      Color textColorSub,
      ) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SizedBox(
            height: 108,
            width: double.infinity,
            child: _buildMuezzinImage(m),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          m.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColorMain,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const Gap(0),
                _buildActionRow(m, downloading, downloaded, isBuiltIn, textColorSub),
                const SizedBox(height: 0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectAsDefault(m),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold.withOpacity(0.2),
                      foregroundColor: _gold,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: _gold.withOpacity(0.3)),
                      ),
                    ),
                    child: Text(
                      'اختيار',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMuezzinImage(MuezzinInfo m) {
    return FutureBuilder<String?>(
      future: AdhanImageCacheService.instance.getLocalPath(m.id),
      builder: (context, snapshot) {
        final localPath = snapshot.data;

        if (localPath != null && localPath.isNotEmpty) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(localPath),
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ],
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              m.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 30),
                  ),
                );
              },
            ),
            Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionRow(
      MuezzinInfo m,
      bool downloading,
      bool downloaded,
      bool isBuiltIn,
      Color textColorSub,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'معاينة',
          onPressed: () => _previewMuezzin(m),
          icon: _previewLoading && _playingPreviewId == m.id
              ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _gold,
            ),
          )
              : Icon(
            _playingPreviewId == m.id
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_fill_rounded,
            color: _gold,
            size: 28,
          ),
        ),
        const SizedBox(width: 4),
        if (isBuiltIn)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _gold.withOpacity(0.4)),
            ),
            child: Text(
              'جاهز',
              style: GoogleFonts.cairo(
                color: _gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (downloading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (downloaded)
            GestureDetector(
              onTap: () => _deleteMuezzin(m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.4)),
                ),
                child: Text(
                  'Offline',
                  style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'تحميل',
              onPressed: () => _downloadMuezzin(m),
              icon: Icon(Icons.download_rounded, color: textColorSub, size: 22),
            ),
      ],
    );
  }
}