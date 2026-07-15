import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
///  ط®ط¯ظ…ط© ظ…ط±ط§ظ‚ط¨ط© ط§ظ„ط§طھطµط§ظ„ ط¨ط§ظ„ط¥ظ†طھط±ظ†طھ
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class ConnectivityService extends ChangeNotifier {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._();

  ConnectivityService._() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;

  bool _isConnected = true;
  bool _isChecking = false;
  ConnectivityResult _connectionType = ConnectivityResult.none;

  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;
  ConnectivityResult get connectionType => _connectionType;

  String get connectionTypeString {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'بيانات الهاتف';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      default:
        return 'غير متصل';
    }
  }

  void _init() {
    // ظپط­طµ ط£ظˆظ„ظٹ
    checkConnectivity();

    // ط§ظ„ط§ط³طھظ…ط§ط¹ ظ„ظ„طھط؛ظٹظٹط±ط§طھ
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    debugPrint('📡 Connectivity changed: $result');
    _connectionType = result;

    if (result == ConnectivityResult.none) {
      _isConnected = false;
      notifyListeners();
    } else {
      // طھط­ظ‚ظ‚ ظپط¹ظ„ظٹ ظ…ظ† ط§ظ„ط§طھطµط§ظ„
      _verifyConnection();
    }
  }

  /// ظپط­طµ ط§ظ„ط§طھطµط§ظ„
  Future<bool> checkConnectivity() async {
    _isChecking = true;
    notifyListeners();

    try {
      final result = await _connectivity.checkConnectivity();
      _connectionType = result;

      if (result == ConnectivityResult.none) {
        _isConnected = false;
      } else {
        await _verifyConnection();
      }
    } catch (e) {
      debugPrint('❌ Connectivity check error: $e');
      _isConnected = false;
    }

    _isChecking = false;
    notifyListeners();
    return _isConnected;
  }

  /// ط§ظ„طھط­ظ‚ظ‚ ط§ظ„ظپط¹ظ„ظٹ ظ…ظ† ط§ظ„ط§طھطµط§ظ„
  Future<void> _verifyConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _isConnected = false;
    } on TimeoutException catch (_) {
      _isConnected = false;
    } catch (e) {
      _isConnected = false;
    }

    notifyListeners();
  }

  /// طھظ†ظپظٹط° ط¹ظ…ظ„ظٹط© ظ…ط¹ ط§ظ„طھط­ظ‚ظ‚ ظ…ظ† ط§ظ„ط§طھطµط§ظ„
  Future<T?> runWithConnectivity<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    bool showErrorOnFail = true,
  }) async {
    if (!_isConnected) {
      await checkConnectivity();
    }

    if (!_isConnected) {
      if (showErrorOnFail && context.mounted) {
        _showNoConnectionSnackBar(context);
      }
      return null;
    }

    return operation();
  }

  void _showNoConnectionSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'لا يوجد اتصال بالإنترنت',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          textColor: Colors.white,
          onPressed: () => checkConnectivity(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
///  ظˆظٹط¯ط¬طھ ط¹ط±ط¶ ط­ط§ظ„ط© ط§ظ„ط§طھطµط§ظ„
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, _) {
        final service = ConnectivityService.instance;

        return Column(
          children: [
            // ط¨ط§ظ†ط± ط¹ط¯ظ… ط§ظ„ط§طھطµط§ظ„
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: service.isConnected ? 0 : 40,
              child: service.isConnected
                  ? const SizedBox.shrink()
                  : Container(
                color: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'لا يوجد اتصال بالإنترنت',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (service.isChecking)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => service.checkConnectivity(),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Expanded(child: child),
          ],
        );
      },
    );
  }
}

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
///  ط´ط§ط´ط© ط¹ط¯ظ… ط§ظ„ط§طھطµط§ظ„
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class NoConnectionScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E14) : const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(w * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ط£ظٹظ‚ظˆظ†ط©
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: EdgeInsets.all(w * 0.06),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: (w * 0.15).clamp(50.0, 80.0),
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),

              SizedBox(height: w * 0.06),

              // ط§ظ„ط¹ظ†ظˆط§ظ†
              Text(
                'لا يوجد اتصال',
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.055).clamp(20.0, 28.0),
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              SizedBox(height: w * 0.02),

              // ط§ظ„ظˆطµظپ
              Text(
                'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
                style: GoogleFonts.cairo(
                  fontSize: (w * 0.035).clamp(13.0, 16.0),
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: w * 0.08),

              // ط²ط± ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©
              ListenableBuilder(
                listenable: ConnectivityService.instance,
                builder: (context, _) {
                  final isChecking = ConnectivityService.instance.isChecking;

                  return ElevatedButton(
                    onPressed: isChecking
                        ? null
                        : () async {
                      final connected = await ConnectivityService.instance.checkConnectivity();
                      if (connected && onRetry != null) {
                        onRetry!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.1,
                        vertical: w * 0.035,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isChecking
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'إعادة المحاولة',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}