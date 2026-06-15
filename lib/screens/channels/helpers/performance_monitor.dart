import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// ═══════════════════════════════════════════════════════════════
///  مراقب أداء التطبيق
/// ═══════════════════════════════════════════════════════════════
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();

  PerformanceMonitor._();

  final List<FrameTiming> _frameTimings = [];
  final int _maxFrames = 120;

  Duration? _lastOperationDuration;
  final Map<String, Duration> _operationDurations = {};

  /// بدء مراقبة الأداء
  void startMonitoring() {
    if (kDebugMode) {
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
      debugPrint('📊 Performance monitoring started');
    }
  }

  /// إيقاف مراقبة الأداء
  void stopMonitoring() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    _frameTimings.addAll(timings);

    // الاحتفاظ بآخر N إطار فقط
    while (_frameTimings.length > _maxFrames) {
      _frameTimings.removeAt(0);
    }
  }

  /// الحصول على متوسط FPS
  double get averageFps {
    if (_frameTimings.isEmpty) return 60.0;

    final totalDuration = _frameTimings.fold<Duration>(
      Duration.zero,
          (sum, timing) => sum + timing.totalSpan,
    );

    final avgFrameTime = totalDuration.inMicroseconds / _frameTimings.length;
    return 1000000.0 / avgFrameTime;
  }

  /// قياس مدة عملية
  Future<T> measureOperation<T>({
    required String name,
    required Future<T> Function() operation,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      _lastOperationDuration = stopwatch.elapsed;
      _operationDurations[name] = stopwatch.elapsed;

      if (kDebugMode) {
        debugPrint('⏱️ $name: ${stopwatch.elapsedMilliseconds}ms');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  /// قياس عملية متزامنة
  T measureSync<T>({
    required String name,
    required T Function() operation,
  }) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      _lastOperationDuration = stopwatch.elapsed;
      _operationDurations[name] = stopwatch.elapsed;

      if (kDebugMode) {
        debugPrint('⏱️ $name: ${stopwatch.elapsedMilliseconds}ms');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  /// طباعة تقرير الأداء
  void printReport() {
    if (!kDebugMode) return;

    debugPrint('═══════════════════════════════════════');
    debugPrint('📊 Performance Report');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Average FPS: ${averageFps.toStringAsFixed(1)}');
    debugPrint('');
    debugPrint('Operation Durations:');
    _operationDurations.forEach((name, duration) {
      debugPrint('  $name: ${duration.inMilliseconds}ms');
    });
    debugPrint('═══════════════════════════════════════');
  }

  /// مسح البيانات
  void clear() {
    _frameTimings.clear();
    _operationDurations.clear();
    _lastOperationDuration = null;
  }
}

/// ═══════════════════════════════════════════════════════════════
///  Extension لقياس أداء الـ Future
/// ═══════════════════════════════════════════════════════════════
extension FuturePerformance<T> on Future<T> {
  Future<T> measurePerformance(String name) async {
    return PerformanceMonitor.instance.measureOperation(
      name: name,
      operation: () => this,
    );
  }
}