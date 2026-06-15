// lib/screens/radio/models/downloadable_item.dart

enum ItemDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
  error,
}

class DownloadableItemInfo {
  final String itemId;
  ItemDownloadStatus status;
  double progress;
  int downloadedCount;
  int totalCount;
  String? localPath;
  String? error;

  DownloadableItemInfo({
    required this.itemId,
    this.status = ItemDownloadStatus.notDownloaded,
    this.progress = 0,
    this.downloadedCount = 0,
    this.totalCount = 1,
    this.localPath,
    this.error,
  });

  bool get isDownloaded => status == ItemDownloadStatus.downloaded;
  bool get isDownloading => status == ItemDownloadStatus.downloading;
}