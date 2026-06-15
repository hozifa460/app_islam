import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
///  ظ…ط¹ط§ظ„ط¬ ط§ظ„ط£ط®ط·ط§ط، ط§ظ„ظ…ط±ظƒط²ظٹ
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._();
  static ErrorHandler get instance => _instance;

  ErrorHandler._();

  // ط³ط¬ظ„ ط§ظ„ط£ط®ط·ط§ط،
  final List<AppError> _errorLog = [];
  List<AppError> get errorLog => List.unmodifiable(_errorLog);

  // Callbacks
  Function(AppError)? onError;

  /// طھط³ط¬ظٹظ„ ط®ط·ط£
  void logError(AppError error) {
    _errorLog.add(error);

    // ط§ظ„ط§ط­طھظپط§ط¸ ط¨ط¢ط®ط± 100 ط®ط·ط£ ظپظ‚ط·
    if (_errorLog.length > 100) {
      _errorLog.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('â‌Œ [${error.type.name}] ${error.message}');
      if (error.stackTrace != null) {
        debugPrint('Stack: ${error.stackTrace}');
      }
    }

    onError?.call(error);
  }

  /// ظ…ط¹ط§ظ„ط¬ط© ط§ط³طھط«ظ†ط§ط،
  AppError handleException(dynamic exception, [StackTrace? stackTrace]) {
    AppError error;

    if (exception is SocketException) {
      error = AppError(
        type: ErrorType.network,
        message: 'ظ„ط§ ظٹظˆط¬ط¯ ط§طھطµط§ظ„ ط¨ط§ظ„ط¥ظ†طھط±ظ†طھ',
        originalError: exception,
        stackTrace: stackTrace,
      );
    } else if (exception is TimeoutException) {
      error = AppError(
        type: ErrorType.timeout,
        message: 'ط§ظ†طھظ‡طھ ظ…ظ‡ظ„ط© ط§ظ„ط§طھطµط§ظ„',
        originalError: exception,
        stackTrace: stackTrace,
      );
    } else if (exception is FormatException) {
      error = AppError(
        type: ErrorType.parsing,
        message: 'ط®ط·ط£ ظپظٹ طھظ†ط³ظٹظ‚ ط§ظ„ط¨ظٹط§ظ†ط§طھ',
        originalError: exception,
        stackTrace: stackTrace,
      );
    } else if (exception is HttpException) {
      error = AppError(
        type: ErrorType.server,
        message: 'ط®ط·ط£ ظ…ظ† ط§ظ„ط®ط§ط¯ظ…',
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

  /// طھظ†ظپظٹط° ط¹ظ…ظ„ظٹط© ظ…ط¹ ظ…ط¹ط§ظ„ط¬ط© ط§ظ„ط£ط®ط·ط§ط،
  /// طھظ†ظپظٹط° ط¹ظ…ظ„ظٹط© ظ…ط¹ ظ…ط¹ط§ظ„ط¬ط© ط§ظ„ط£ط®ط·ط§ط، (ظٹط¯ط¹ظ… nullable)
  Future<T?> runSafe<T>({
    required Future<T?> Function() operation,  // â†گ طھط؛ظٹظٹط± ظ‡ظ†ط§
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
          debugPrint('âڑ ï¸ڈ Retry $attempts/$retries for $operationName');
          await Future.delayed(retryDelay * attempts);
        } else {
          debugPrint('â‌Œ $operationName failed after $attempts attempts');
          return fallback;
        }
      }
    }

    return fallback;
  }

  /// طھظ†ظپظٹط° ط¹ظ…ظ„ظٹط© ظ…ط¹ ظ…ط¹ط§ظ„ط¬ط© ط§ظ„ط£ط®ط·ط§ط، (non-nullable ظ…ط¹ fallback ط¥ط¬ط¨ط§ط±ظٹ)
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
          debugPrint('âڑ ï¸ڈ Retry $attempts/$retries for $operationName');
          await Future.delayed(retryDelay * attempts);
        } else {
          debugPrint('â‌Œ $operationName failed after $attempts attempts');
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

  /// ظ…ط³ط­ ط³ط¬ظ„ ط§ظ„ط£ط®ط·ط§ط،
  void clearLog() {
    _errorLog.clear();
  }

  /// ط¹ط±ط¶ ط±ط³ط§ظ„ط© ط®ط·ط£
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
          label: 'ط­ط³ظ†ط§ظ‹',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// ط¹ط±ط¶ dialog ط®ط·ط£
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
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
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
                'ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF0D9488),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ط¥ط؛ظ„ط§ظ‚',
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

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
///  ظ†ظ…ظˆط°ط¬ ط§ظ„ط®ط·ط£
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
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
        return 'طھط­ظ‚ظ‚ ظ…ظ† ط§طھطµط§ظ„ظƒ ط¨ط§ظ„ط¥ظ†طھط±ظ†طھ ظˆط­ط§ظˆظ„ ظ…ط±ط© ط£ط®ط±ظ‰';
      case ErrorType.timeout:
        return 'ط§ط³طھط؛ط±ظ‚ ط§ظ„ط§طھطµط§ظ„ ظˆظ‚طھط§ظ‹ ط·ظˆظٹظ„ط§ظ‹طŒ ط­ط§ظˆظ„ ظ…ط±ط© ط£ط®ط±ظ‰';
      case ErrorType.server:
        return 'ط­ط¯ط« ط®ط·ط£ ظپظٹ ط§ظ„ط®ط§ط¯ظ…طŒ ط­ط§ظˆظ„ ظ„ط§ط­ظ‚ط§ظ‹';
      case ErrorType.parsing:
        return 'ط­ط¯ط« ط®ط·ط£ ظپظٹ ظ…ط¹ط§ظ„ط¬ط© ط§ظ„ط¨ظٹط§ظ†ط§طھ';
      case ErrorType.notFound:
        return 'ظ„ظ… ظٹطھظ… ط§ظ„ط¹ط«ظˆط± ط¹ظ„ظ‰ ط§ظ„ظ…ط­طھظˆظ‰ ط§ظ„ظ…ط·ظ„ظˆط¨';
      case ErrorType.rateLimit:
        return 'طھظ… طھط¬ط§ظˆط² ط§ظ„ط­ط¯ ط§ظ„ظ…ط³ظ…ظˆط­طŒ ط­ط§ظˆظ„ ظ„ط§ط­ظ‚ط§ظ‹';
      default:
        return 'ط­ط¯ط« ط®ط·ط£ ط؛ظٹط± ظ…طھظˆظ‚ط¹';
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