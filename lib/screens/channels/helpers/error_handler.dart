import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

/// ═══════════════════════════════════════════════════════════════
///  معالج الأخطاء المركزي
/// ═══════════════════════════════════════════════════════════════
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._();
  static ErrorHandler get instance => _instance;

  ErrorHandler._();

  // سجل الأخطاء
  final List<AppError> _errorLog = [];
  List<AppError> get errorLog => List.unmodifiable(_errorLog);

  // Callbacks
  Function(AppError)? onError;

  /// تسجيل خطأ
  void logError(AppError error) {
    _errorLog.add(error);

    // الاحتفاظ بآخر 100 خطأ فقط
    if (_errorLog.length > 100) {
      _errorLog.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('❌ [${error.type.name}] ${error.message}');
      if (error.stackTrace != null) {
        debugPrint('Stack: ${error.stackTrace}');
      }
    }

    onError?.call(error);
  }

  /// معالجة استثناء
  AppError handleException(dynamic exception, [StackTrace? stackTrace]) {
    AppError error;

    if (exception is SocketException) {
      error = AppError(
        type: ErrorType.network,
        message: 'لا يوجد اتصال بالإنترنت',
        originalError: exception,
        stackTrace: stackTrace,
      );
    } else if (exception is TimeoutException) {
      error = AppError(
        type: ErrorType.timeout,
        message: 'انتهت مهلة الاتصال',
        originalError: exception,
        stackTrace: stackTrace,
      );
    } else if (exception is FormatException) {
      error = AppError(
        type: ErrorType.parsing,
        message: 'خطأ في تنسيق البيانات',
        originalError: exception,
        stackTrace: stackTrace,
      );
    } else if (exception is HttpException) {
      error = AppError(
        type: ErrorType.server,
        message: 'خطأ من الخادم',
        originalError: exception,
        stackTrace: stackTrace,
      );
    } else {
      error = AppError(
        type: ErrorType.unknown,
        message: exception.toString(),
        originalError: exception,
        stackTrace: stackTrace,
      );
    }

    logError(error);
    return error;
  }

  /// تنفيذ عملية مع معالجة الأخطاء
  /// تنفيذ عملية مع معالجة الأخطاء (يدعم nullable)
  Future<T?> runSafe<T>({
    required Future<T?> Function() operation,  // ← تغيير هنا
    required String operationName,
    T? fallback,
    int retries = 0,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts <= retries) {
      try {
        return await operation();
      } catch (e, stack) {
        attempts++;

        final error = handleException(e, stack);

        if (attempts <= retries && _shouldRetry(error.type)) {
          debugPrint('⚠️ Retry $attempts/$retries for $operationName');
          await Future.delayed(retryDelay * attempts);
        } else {
          debugPrint('❌ $operationName failed after $attempts attempts');
          return fallback;
        }
      }
    }

    return fallback;
  }

  /// تنفيذ عملية مع معالجة الأخطاء (non-nullable مع fallback إجباري)
  Future<T> runSafeWithFallback<T>({
    required Future<T> Function() operation,
    required String operationName,
    required T fallback,
    int retries = 0,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts <= retries) {
      try {
        return await operation();
      } catch (e, stack) {
        attempts++;

        final error = handleException(e, stack);

        if (attempts <= retries && _shouldRetry(error.type)) {
          debugPrint('⚠️ Retry $attempts/$retries for $operationName');
          await Future.delayed(retryDelay * attempts);
        } else {
          debugPrint('❌ $operationName failed after $attempts attempts');
          return fallback;
        }
      }
    }

    return fallback;
  }

  bool _shouldRetry(ErrorType type) {
    return type == ErrorType.network ||
        type == ErrorType.timeout ||
        type == ErrorType.server;
  }

  /// مسح سجل الأخطاء
  void clearLog() {
    _errorLog.clear();
  }

  /// عرض رسالة خطأ
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// عرض dialog خطأ
  static Future<void> showErrorDialog(
      BuildContext context, {
        required String title,
        required String message,
        VoidCallback? onRetry,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
            height: 1.5,
          ),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF0D9488),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
///  نموذج الخطأ
/// ═══════════════════════════════════════════════════════════════
class AppError {
  final ErrorType type;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  String get userFriendlyMessage {
    switch (type) {
      case ErrorType.network:
        return 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
      case ErrorType.timeout:
        return 'استغرق الاتصال وقتاً طويلاً، حاول مرة أخرى';
      case ErrorType.server:
        return 'حدث خطأ في الخادم، حاول لاحقاً';
      case ErrorType.parsing:
        return 'حدث خطأ في معالجة البيانات';
      case ErrorType.notFound:
        return 'لم يتم العثور على المحتوى المطلوب';
      case ErrorType.rateLimit:
        return 'تم تجاوز الحد المسموح، حاول لاحقاً';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}

enum ErrorType {
  network,
  timeout,
  server,
  parsing,
  notFound,
  rateLimit,
  permission,
  unknown,
}