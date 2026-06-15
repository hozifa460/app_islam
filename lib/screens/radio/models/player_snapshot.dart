// lib/screens/radio/models/player_snapshot.dart

class PlayerSnapshot {
  final bool hasActivePlayer;
  final String name;
  final String subtitle;
  final String emoji;
  final String? imageUrl;
  final String? imageAsset;
  final bool isPlaying;
  final bool isBuffering;
  final bool isOnline;
  final String sourceKey;

  const PlayerSnapshot({
    required this.hasActivePlayer,
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.imageUrl,
    required this.imageAsset,
    required this.isPlaying,
    required this.isBuffering,
    required this.isOnline,
    required this.sourceKey,
  });

  static const empty = PlayerSnapshot(
    hasActivePlayer: false,
    name: '',
    subtitle: '',
    emoji: '📻',
    imageUrl: null,
    imageAsset: null,
    isPlaying: false,
    isBuffering: false,
    isOnline: false,
    sourceKey: 'none',
  );

  @override
  bool operator ==(Object other) {
    return other is PlayerSnapshot &&
        other.hasActivePlayer == hasActivePlayer &&
        other.name == name &&
        other.subtitle == subtitle &&
        other.emoji == emoji &&
        other.imageUrl == imageUrl &&
        other.imageAsset == imageAsset &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering &&
        other.isOnline == isOnline &&
        other.sourceKey == sourceKey;
  }

  @override
  int get hashCode => Object.hash(
    hasActivePlayer,
    name,
    subtitle,
    emoji,
    imageUrl,
    imageAsset,
    isPlaying,
    isBuffering,
    isOnline,
    sourceKey,
  );
}