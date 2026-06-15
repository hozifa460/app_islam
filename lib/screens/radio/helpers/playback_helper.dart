// lib/screens/radio/helpers/playback_helper.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/recitation_categories_data.dart';
import '../models/radio_station.dart';
import '../services/audio_coordinator.dart';
import '../widgets_recitations_screen/rec_item_player_screen.dart';
import '../widgets_recitations_screen/services/item_download_service.dart';

class PlaybackHelper {
  PlaybackHelper._();

  // ══════════════════════════════════════════════════════
  // تشغيل ملف محلي
  // ══════════════════════════════════════════════════════

  static Future<void> playLocalFile({
    required BuildContext context,
    required RecitationItem item,
    required String localPath,
    required Color primary,
  }) async {
    // ✅ التحقق من وجود الملف
    final file = File(localPath);
    final exists = await file.exists();

    if (!exists) {
      if (!context.mounted) return;

      // ✅ حذف المسار الفاسد
      final itemId = ItemDownloadService.itemIdFromRecitationItem(item);
      context.read<ItemDownloadService>().deleteDownload(itemId);

      _showErrorSnack(context, 'الملف غير موجود، أعد تحميله');
      return;
    }

    final coordinator = context.read<AudioCoordinator>();
    final station = _buildTempStation(
      item: item,
      url: localPath,
      isLocal: true,
    );

    await coordinator.playLocalItem(station: station);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecItemPlayerScreen(
          item: item,
          primary: primary,
          station: station,
          isLocal: true,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // تشغيل أونلاين
  // ══════════════════════════════════════════════════════

  static void playOnline({
    required BuildContext context,
    required RecitationItem item,
    required Color primary,
  }) {
    if (item.audioUrl == null || item.audioUrl!.isEmpty) {
      _showErrorSnack(context, 'الرابط غير متاح حالياً');
      return;
    }

    final coordinator = context.read<AudioCoordinator>();
    final station = _buildTempStation(
      item: item,
      url: item.audioUrl!,
      isLocal: false,
    );

    coordinator.playOnlineRadio(station);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecItemPlayerScreen(
          item: item,
          primary: primary,
          station: station,
          isLocal: false,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // تشغيل تلقائي (يحدد المصدر المناسب)
  // ══════════════════════════════════════════════════════

  static Future<void> playAuto({
    required BuildContext context,
    required RecitationItem item,
    required Color primary,
    required ItemDownloadService downloadService,
  }) async {
    // ✅ تحقق من التحميل أولاً
    final itemId = ItemDownloadService.itemIdFromRecitationItem(item);
    final localPath = downloadService.getLocalPath(itemId);

    if (localPath != null) {
      await playLocalFile(
        context: context,
        item: item,
        localPath: localPath,
        primary: primary,
      );
      return;
    }

    // ✅ تشغيل أونلاين
    if (item.audioUrl != null && item.audioUrl!.isNotEmpty) {
      playOnline(
        context: context,
        item: item,
        primary: primary,
      );
      return;
    }

    if (context.mounted) {
      _showErrorSnack(context, 'الرابط غير متاح حالياً');
    }
  }

  // ══════════════════════════════════════════════════════
  // مساعدات داخلية
  // ══════════════════════════════════════════════════════

  static IslamicRadioStation _buildTempStation({
    required RecitationItem item,
    required String url,
    required bool isLocal,
  }) {
    return IslamicRadioStation(
      id: url.hashCode.abs(),
      name: item.title,
      nameEn: item.title,
      url: url,
      category: 'تلاوات',
      categoryEn: 'Recitations',
      description: isLocal
          ? '${item.subtitle} • أوفلاين'
          : item.subtitle,
      descriptionEn: item.subtitle,
      iconEmoji: item.emoji,
      imageUrl: item.imageUrl,
    );
  }

  static void _showErrorSnack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ══ مساعد لبناء station من SubItem ══
  static IslamicRadioStation stationFromSubItem({
    required RecitationSubItem subItem,
    required RecitationItem parentItem,
    String? localPath,
  }) {
    final url = localPath ?? subItem.audioUrl;
    return IslamicRadioStation(
      id: url.hashCode.abs(),
      name: subItem.title,
      nameEn: subItem.title,
      url: url,
      category: parentItem.title,
      categoryEn: 'Recitations',
      description: localPath != null
          ? '${subItem.subtitle} • أوفلاين'
          : subItem.subtitle,
      descriptionEn: subItem.subtitle,
      iconEmoji: subItem.emoji,
      imageUrl: subItem.imageUrl ?? parentItem.imageUrl,
    );
  }

  // ══ مساعد لبناء RecitationItem من SubItem ══
  static RecitationItem itemFromSubItem({
    required RecitationSubItem subItem,
    required RecitationItem parentItem,
    String? localPath,
  }) {
    return RecitationItem(
      title: subItem.title,
      subtitle: subItem.subtitle,
      emoji: subItem.emoji,
      imageUrl: subItem.imageUrl ?? parentItem.imageUrl,
      audioUrl: localPath ?? subItem.audioUrl,
    );
  }
}