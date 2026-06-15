import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/youtube_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  خدمة المشاركة المتقدمة
/// ═══════════════════════════════════════════════════════════════
class ShareService {

  /// مشاركة فيديو
  static Future<void> shareVideo(YoutubeVideo video, {BuildContext? context}) async {
    final text = '''
🎬 ${video.title}

📺 ${video.channelTitle}
👁️ ${YoutubeService.formatViews(video.viewCount)} مشاهدة

🔗 ${video.url}

— تم المشاركة من تطبيق القنوات العلمية
''';

    await Share.share(
      text,
      subject: video.title,
    );
  }

  /// مشاركة قناة
  static Future<void> shareChannel(Map<String, dynamic> channel) async {
    final name = channel['name'] ?? '';
    final url = channel['url'] ?? '';
    final title = channel['title'] ?? '';

    final text = '''
📺 $name
${title.isNotEmpty ? '📝 $title\n' : ''}
🔗 $url

— تم المشاركة من تطبيق القنوات العلمية
''';

    await Share.share(
      text,
      subject: name,
    );
  }

  /// نسخ الرابط
  static Future<void> copyLink(String url, {BuildContext? context}) async {
    await Clipboard.setData(ClipboardData(text: url));

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text('تم نسخ الرابط'),
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

  /// مشاركة عبر واتساب
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

  /// مشاركة عبر تليجرام
  static Future<void> shareToTelegram(String text) async {
    final encoded = Uri.encodeComponent(text);
    final url = 'https://t.me/share/url?url=$encoded';

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// مشاركة عبر تويتر
  static Future<void> shareToTwitter(String text, {String? url}) async {
    final encodedText = Uri.encodeComponent(text);
    final encodedUrl = url != null ? Uri.encodeComponent(url) : '';

    final twitterUrl = 'https://twitter.com/intent/tweet?text=$encodedText${url != null ? '&url=$encodedUrl' : ''}';

    await launchUrl(Uri.parse(twitterUrl), mode: LaunchMode.externalApplication);
  }

  /// فتح خيارات المشاركة المتقدمة
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

/// ═══════════════════════════════════════════════════════════════
///  شاشة خيارات المشاركة
/// ═══════════════════════════════════════════════════════════════
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
            // المقبض
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: subColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // العنوان
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.share_rounded, color: textColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'مشاركة الفيديو',
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

            // خيارات المشاركة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareButton(
                    icon: Icons.copy_rounded,
                    label: 'نسخ',
                    color: const Color(0xFF64748B),
                    onTap: () {
                      Navigator.pop(context);
                      ShareService.copyLink(video.url, context: context);
                    },
                  ),
                  _ShareButton(
                    icon: Icons.message_rounded,
                    label: 'واتساب',
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
                    label: 'تليجرام',
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
                    label: 'تويتر',
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

            // زر المشاركة العامة
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
                  label: const Text('المزيد من الخيارات'),
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2)),
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