class TimeFormatHelper {
  static String timeAgoArabic(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'الآن';

    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      if (m == 1) return 'قبل دقيقة';
      if (m == 2) return 'قبل دقيقتين';
      if (m <= 10) return 'قبل $m دقائق';
      return 'قبل $m دقيقة';
    }

    if (diff.inHours < 24) {
      final h = diff.inHours;
      if (h == 1) return 'قبل ساعة';
      if (h == 2) return 'قبل ساعتين';
      if (h <= 10) return 'قبل $h ساعات';
      return 'قبل $h ساعة';
    }

    if (diff.inDays < 7) {
      final d = diff.inDays;
      if (d == 1) return 'قبل يوم';
      if (d == 2) return 'قبل يومين';
      if (d <= 10) return 'قبل $d أيام';
      return 'قبل $d يوم';
    }

    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      if (w <= 1) return 'قبل أسبوع';
      if (w == 2) return 'قبل أسبوعين';
      if (w <= 10) return 'قبل $w أسابيع';
      return 'قبل $w أسبوع';
    }

    if (diff.inDays < 365) {
      final m = (diff.inDays / 30).floor();
      if (m <= 1) return 'قبل شهر';
      if (m == 2) return 'قبل شهرين';
      if (m <= 10) return 'قبل $m أشهر';
      return 'قبل $m شهر';
    }

    final y = (diff.inDays / 365).floor();
    if (y <= 1) return 'قبل سنة';
    if (y == 2) return 'قبل سنتين';
    if (y <= 10) return 'قبل $y سنوات';
    return 'قبل $y سنة';
  }

  static String shortTimeAgoArabic(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return 'منذ ${diff.inDays ~/ 365} سنة';
    if (diff.inDays > 30) return 'منذ ${diff.inDays ~/ 30} شهر';
    if (diff.inDays > 7) return 'منذ ${diff.inDays ~/ 7} أسبوع';
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }

  static String watchedAtArabic(DateTime? watchedAt) {
    if (watchedAt == null) return '';
    final diff = DateTime.now().difference(watchedAt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${diff.inDays ~/ 7} أسبوع';
  }
}