import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../languages/app_localizations.dart';
import '../more/data/muezzin_catalog.dart';
import '../more/services/adahn_audio_services.dart';
import '../more/services/adhan_image_cache_service.dart';
import '../more/services/muazzin_store.dart';

import 'widgets/muezzin_card_vertical.dart';

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

  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _playingPreviewId;
  bool _previewLoading = false;

  final Map<String, bool> _isDownloading = {};
  final Map<String, bool> _isDownloaded = {};

  late MuezzinCategory _category;

  @override
  void initState() {
    super.initState();
    _category =
        muezzinCatalog.firstWhere((c) => c.id == widget.categoryId);
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
        await AdhanImageCacheService.instance
            .getOrDownload(id: m.id, url: m.imageUrl);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _checkDownloads() async {
    for (final m in _category.items) {
      final downloaded = m.isBuiltIn
          ? true
          : await AdhanAudioService.instance.isDownloaded(m.id);
      if (mounted) {
        setState(() => _isDownloaded[m.id] = downloaded);
      }
    }
  }

  Future<void> _downloadMuezzin(MuezzinInfo m) async {
    if (m.isBuiltIn) return;
    setState(() => _isDownloading[m.id] = true);
    final path = await AdhanAudioService.instance
        .download(id: m.id, url: m.url, onProgress: (_) {});
    if (!mounted) return;
    setState(() {
      _isDownloading[m.id] = false;
      _isDownloaded[m.id] = path != null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          path != null
              ? context.tr.downloadSuccess(m.name)
              : context.tr.downloadFailed(m.name),
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
        content: Text(
            context.tr.deleteSuccess(m.name),
            style: GoogleFonts.cairo()),
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
        await _previewPlayer
            .setAsset('assets/adahn/${m.localSoundName}.mp3');
      } else {
        final local =
        await AdhanAudioService.instance.getLocalPath(m.id);
        if (local != null && local.isNotEmpty) {
          await _previewPlayer.setFilePath(local);
        } else {
          await _previewPlayer.setUrl(m.url);
        }
      }
      await _previewPlayer.play();
      if (mounted) setState(() => _previewLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _playingPreviewId = null;
          _previewLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.previewFailed, style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectAsDefault(MuezzinInfo m) async {
    await MuezzinStore.setDefault(m, resetAllCustom: true);
    if (m.imageUrl.isNotEmpty) {
      await AdhanImageCacheService.instance
          .getOrDownload(id: m.id, url: m.imageUrl);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr.setAsDefaultSuccess(m.name),
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
    final bgColor =
    isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FA);
    final textColorMain =
    isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textColorSub = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : _gold.withOpacity(0.2);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.grey.withOpacity(0.4);
    final cardGradient = isDark
        ? [
      Colors.white.withOpacity(0.08),
      Colors.white.withOpacity(0.02)
    ]
        : [Colors.white, Colors.white];

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
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : _gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: textColorMain),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width < 360 ? 1 : 2;

          return GridView.builder(
            padding: const EdgeInsets.only(
                bottom: 15, left: 15, right: 15, top: 120),
            physics: const BouncingScrollPhysics(),
            itemCount: _category.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio:
              crossAxisCount == 1 ? 0.95 : 0.64,
            ),
            itemBuilder: (context, index) {
              final m = _category.items[index];
              final downloading = _isDownloading[m.id] == true;
              final downloaded = _isDownloaded[m.id] == true;
              final isBuiltIn = m.isBuiltIn;
              final isPlaying = _playingPreviewId == m.id;

              return MuezzinCardVertical(
                muezzin: m,
                downloading: downloading,
                downloaded: downloaded,
                isBuiltIn: isBuiltIn,
                isPlaying: isPlaying,
                isPreviewLoading:
                _previewLoading && _playingPreviewId == m.id,
                gold: _gold,
                textColorMain: textColorMain,
                textColorSub: textColorSub,
                borderColor: borderColor,
                shadowColor: shadowColor,
                cardGradient: cardGradient,
                onPreview: () => _previewMuezzin(m),
                onDownload: () => _downloadMuezzin(m),
                onDelete: () => _deleteMuezzin(m),
                onSelect: () => _selectAsDefault(m),
              );
            },
          );
        },
      ),
    );
  }
}