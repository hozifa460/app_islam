import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ScholarProfileTiktokScreen extends StatefulWidget {
  final Map<String, dynamic> tiktokData;

  const ScholarProfileTiktokScreen({
    super.key,
    required this.tiktokData,
  });

  @override
  State<ScholarProfileTiktokScreen> createState() =>
      _ScholarProfileTiktokScreenState();
}

class _ScholarProfileTiktokScreenState
    extends State<ScholarProfileTiktokScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _hasError = false;
  int _progress = 0;
  String _currentUrl = '';

  String get _name =>
      widget.tiktokData['scholarName']?.toString() ?? 'TikTok';

  String get _handle =>
      widget.tiktokData['handle']?.toString() ?? '';

  String get _url {
    final direct = widget.tiktokData['url']?.toString() ?? '';
    if (direct.isNotEmpty) return direct;

    final clean = _handle.startsWith('@') ? _handle.substring(1) : _handle;
    return 'https://www.tiktok.com/@$clean';
  }

  @override
  void initState() {
    super.initState();
    _currentUrl = _url;
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/125.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _currentUrl = url;
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (url) async {
            _currentUrl = url;
            await _injectCleaner();
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          },
          onWebResourceError: (error) {
            debugPrint('TikTok WebView error: ${error.description}');
            if (!mounted) return;
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();

            if (url.startsWith('intent://') ||
                url.startsWith('market://') ||
                url.startsWith('snssdk') ||
                url.startsWith('tiktok://') ||
                url.contains('play.google.com') ||
                url.contains('apps.apple.com') ||
                url.contains('itunes.apple.com')) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  Future<void> _injectCleaner() async {
    try {
      await _controller.runJavaScript(r'''
        (function() {
          try {
            var style = document.getElementById('flutter_tiktok_cleaner_full');
            if (!style) {
              style = document.createElement('style');
              style.id = 'flutter_tiktok_cleaner_full';
              style.innerHTML = `
                [class*="DivTopBanner"],
                [class*="DivBottomBanner"],
                [class*="DivOpenApp"],
                [class*="DivDownload"],
                [class*="DivGuide"],
                [class*="DivLogin"],
                [class*="DivModal"],
                [class*="DivFooterContainer"],
                [class*="DivCookie"],
                [class*="RecommendList"],
                [class*="recommend"],
                [class*="Footer"],
                [class*="footer"],
                [data-e2e="top-login-button"],
                [data-e2e="bottom-banner"],
                [data-e2e="cookie-banner"],
                [data-e2e="login-guide"],
                .bottom-banner,
                .open-app,
                .download-app {
                  display: none !important;
                  visibility: hidden !important;
                  opacity: 0 !important;
                  pointer-events: none !important;
                }

                html, body {
                  overflow-x: hidden !important;
                  background: #000 !important;
                  margin: 0 !important;
                  padding: 0 !important;
                }

                * {
                  -webkit-tap-highlight-color: transparent !important;
                }
              `;
              document.head.appendChild(style);
            }
          } catch(e) {}
        })();
      ''');
    } catch (_) {}
  }

  Future<void> _reloadPage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _progress = 0;
    });
    await _controller.reload();
  }

  Future<void> _openInTikTok() async {
    final handle = _handle.startsWith('@') ? _handle.substring(1) : _handle;
    final appUri = Uri.parse('tiktok://user?username=$handle');
    final webUri = Uri.parse(_url);

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openExternal() async {
    try {
      await launchUrl(
        Uri.parse(_currentUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  Future<void> _pullToRefresh() async {
    await _reloadPage();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF000000);
    const textColor = Colors.white;
    final borderColor = Colors.white.withValues(alpha: 0.08);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: WillPopScope(
          onWillPop: _handleBack,
          child: Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ط´ط±ظٹط· ط¹ظ„ظˆظٹ ط¨ط³ظٹط· ط¬ط¯ط§ظ‹ ظ…ط«ظ„ ط§ظ„طھط·ط¨ظٹظ‚ط§طھ ط§ظ„ط­ط¯ظٹط«ط©
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border(
                        bottom: BorderSide(color: borderColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (await _controller.canGoBack()) {
                              await _controller.goBack();
                            } else {
                              if (mounted) Navigator.pop(context);
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: textColor,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              if (_handle.isNotEmpty)
                                Text(
                                  _handle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _openInTikTok,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFFE2C55),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'ظپطھط­ ظپظٹ TikTok',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _openExternal,
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isLoading)
                    LinearProgressIndicator(
                      value: _progress > 0 && _progress < 100
                          ? _progress / 100
                          : null,
                      minHeight: 2.5,
                      backgroundColor: Colors.transparent,
                      color: const Color(0xFFFE2C55),
                    ),

                  Expanded(
                    child: _hasError
                        ? _buildErrorView()
                        : RefreshIndicator(
                      onRefresh: _pullToRefresh,
                      color: const Color(0xFFFE2C55),
                      backgroundColor: const Color(0xFF161823),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: WebViewWidget(controller: _controller),
                          ),
                          if (_isLoading && _progress < 20)
                            Container(
                              color: bgColor,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 34,
                                      height: 34,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.8,
                                        color: Color(0xFFFE2C55),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'ط¬ط§ط±ظٹ طھط­ظ…ظٹظ„ طµظپط­ط© TikTok...',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white60,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 14),
              Text(
                'طھط¹ط°ط± طھط­ظ…ظٹظ„ طµظپط­ط© TikTok',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'ظٹظ…ظƒظ†ظƒ ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط© ط£ظˆ ظپطھط­ ط§ظ„ط­ط³ط§ط¨ ظپظٹ طھط·ط¨ظٹظ‚ TikTok.',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _reloadPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE2C55),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: Text(
                        'ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _openInTikTok,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        'ظپطھط­ ظپظٹ TikTok',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}