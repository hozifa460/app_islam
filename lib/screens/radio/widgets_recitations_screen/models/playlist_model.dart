// lib/screens/radio/models/playlist_model.dart

import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';

class PlaylistItem {
  final String title;
  final String subtitle;
  final String emoji;
  final String audioUrl;
  final String? imageUrl;
  final bool isLocal;
  final String? localPath;

  const PlaylistItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.audioUrl,
    this.imageUrl,
    this.isLocal = false,
    this.localPath,
  });

  /// من RecitationSubItem
  factory PlaylistItem.fromSubItem(
      RecitationSubItem sub, {
        String? parentImageUrl,
        String? localPath,
      }) {
    return PlaylistItem(
      title: sub.title,
      subtitle: sub.subtitle,
      emoji: sub.emoji,
      audioUrl: sub.audioUrl,
      imageUrl: sub.imageUrl ?? parentImageUrl,
      isLocal: localPath != null,
      localPath: localPath,
    );
  }

  /// من RecitationItem (تلاوة مفردة)
  factory PlaylistItem.fromRecitationItem(
      RecitationItem item, {
        String? localPath,
      }) {
    return PlaylistItem(
      title: item.title,
      subtitle: item.subtitle,
      emoji: item.emoji,
      audioUrl: item.audioUrl ?? '',
      imageUrl: item.imageUrl,
      isLocal: localPath != null,
      localPath: localPath,
    );
  }
}