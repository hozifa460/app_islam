import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/youtube_service.dart';

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
///  ط®ط¯ظ…ط© ط§ظ„ظ…ط´ط§ط±ظƒط© ط§ظ„ظ…طھظ‚ط¯ظ…ط©
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class ShareService {

  /// ظ…ط´ط§ط±ظƒط© ظپظٹط¯ظٹظˆ
  static Future<void> shareVideo(YoutubeVideo video, {BuildContext? context}) async {
    final text = '''
ًںژ¬ ${video.title}

ًں“؛ ${video.channelTitle}
ًں‘پï¸ڈ ${YoutubeService.formatViews(video.viewCount)} ظ…ط´ط§ظ‡ط¯ط©

ًں”— ${video.url}

â€” طھظ… ط§ظ„ظ…ط´ط§ط±ظƒط© ظ…ظ† طھط·ط¨ظٹظ‚ ط§ظ„ظ‚ظ†ظˆط§طھ ط§ظ„ط¹ظ„ظ…ظٹط©
''';

    await Share.share(
      text,
      subject: video.title,
    );
  }

  /// ظ…ط´ط§ط±ظƒط© ظ‚ظ†ط§ط©
  static Future<void> shareChannel(Map<String, dynamic> channel) async {
    final name = channel['name'] ?? '';
    final url = channel['url'] ?? '';
    final title = channel['title'] ?? '';

    final text = '''
ًں“؛ $name
${title.isNotEmpty ? 'ًں“‌ $title\n' : ''}
ًں”— $url

â€” طھظ… ط§ظ„ظ…ط´ط§ط±ظƒط© ظ…ظ† طھط·ط¨ظٹظ‚ ط§ظ„ظ‚ظ†ظˆط§طھ ط§ظ„ط¹ظ„ظ…ظٹط©
''';

    await Share.share(
      text,
      subject: name,
    );
  }

  /// ظ†ط³ط® ط§ظ„ط±ط§ط¨ط·
  static Future<void> copyLink(String url, {BuildContext? context}) async {
    await Clipboard.setData(ClipboardData(text: url));

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text('طھظ… ظ†ط³ط® ط§ظ„ط±ط§ط¨ط·'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// ظ…ط´ط§ط±ظƒط© ط¹ط¨ط± ظˆط§طھط³ط§ط¨
  static Future<void> shareToWhatsApp(String text) async {
    final encoded = Uri.encodeComponent(text);
    final url = 'whatsapp://send?text=$encoded';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to web WhatsApp
      final webUrl = 'https://wa.me/?text=$encoded';
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  /// ظ…ط´ط§ط±ظƒط© ط¹ط¨ط± طھظ„ظٹط¬ط±ط§ظ…
  static Future<void> shareToTelegram(String text) async {
    final encoded = Uri.encodeComponent(text);
    final url = 'https://t.me/share/url?url=$encoded';

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// ظ…ط´ط§ط±ظƒط© ط¹ط¨ط± طھظˆظٹطھط±
  static Future<void> shareToTwitter(String text, {String? url}) async {
    final encodedText = Uri.encodeComponent(text);
    final encodedUrl = url != null ? Uri.encodeComponent(url) : '';

    final twitterUrl = 'https://twitter.com/intent/tweet?text=$encodedText${url != null ? '&url=$encodedUrl' : ''}';

    await launchUrl(Uri.parse(twitterUrl), mode: LaunchMode.externalApplication);
  }

  /// ظپطھط­ ط®ظٹط§ط±ط§طھ ط§ظ„ظ…ط´ط§ط±ظƒط© ط§ظ„ظ…طھظ‚ط¯ظ…ط©
  static void showShareOptions({
    required BuildContext context,
    required YoutubeVideo video,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ShareOptionsSheet(
        video: video,
        isDark: isDark,
      ),
    );
  }
}

/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
///  ط´ط§ط´ط© ط®ظٹط§ط±ط§طھ ط§ظ„ظ…ط´ط§ط±ظƒط©
/// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
class _ShareOptionsSheet extends StatelessWidget {
  final YoutubeVideo video;
  final bool isDark;

  const _ShareOptionsSheet({
    required this.video,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2332);
    final subColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ط§ظ„ظ…ظ‚ط¨ط¶
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: subColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ط§ظ„ط¹ظ†ظˆط§ظ†
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.share_rounded, color: textColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ظ…ط´ط§ط±ظƒط© ط§ظ„ظپظٹط¯ظٹظˆ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ط®ظٹط§ط±ط§طھ ط§ظ„ظ…ط´ط§ط±ظƒط©
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareButton(
                    icon: Icons.copy_rounded,
                    label: 'ظ†ط³ط®',
                    color: const Color(0xFF64748B),
                    onTap: () {
                      Navigator.pop(context);
                      ShareService.copyLink(video.url, context: context);
                    },
                  ),
                  _ShareButton(
                    icon: Icons.message_rounded,
                    label: 'ظˆط§طھط³ط§ط¨',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(context);
                      ShareService.shareToWhatsApp(
                          '${video.title}\n${video.url}'
                      );
                    },
                  ),
                  _ShareButton(
                    icon: Icons.send_rounded,
                    label: 'طھظ„ظٹط¬ط±ط§ظ…',
                    color: const Color(0xFF0088CC),
                    onTap: () {
                      Navigator.pop(context);
                      ShareService.shareToTelegram(
                          '${video.title}\n${video.url}'
                      );
                    },
                  ),
                  _ShareButton(
                    icon: Icons.tag_rounded,
                    label: 'طھظˆظٹطھط±',
                    color: const Color(0xFF1DA1F2),
                    onTap: () {
                      Navigator.pop(context);
                      ShareService.shareToTwitter(
                        video.title,
                        url: video.url,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ط²ط± ط§ظ„ظ…ط´ط§ط±ظƒط© ط§ظ„ط¹ط§ظ…ط©
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ShareService.shareVideo(video, context: context);
                  },
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: const Text('ط§ظ„ظ…ط²ظٹط¯ ظ…ظ† ط§ظ„ط®ظٹط§ط±ط§طھ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}