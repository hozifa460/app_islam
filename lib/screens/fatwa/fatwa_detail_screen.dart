// screens/fatwa_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/fatwa_model.dart';

class FatwaDetailScreen extends StatelessWidget {
  final Fatwa fatwa;

  const FatwaDetailScreen({super.key, required this.fatwa});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C2520) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0E1714) : const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            'تفاصيل الفتوى',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(0xFF1B5E20),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareFatwa(context),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => _saveFatwa(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ظپطھظˆظ‰
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    _infoChip(Icons.person, fatwa.scholar),
                    const SizedBox(width: 12),
                    _infoChip(Icons.menu_book, fatwa.book),
                    const SizedBox(width: 12),
                    _infoChip(Icons.category, fatwa.category),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ط§ظ„ط³ط¤ط§ظ„
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'السؤال',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fatwa.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ط§ظ„ط¬ظˆط§ط¨
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'الجواب',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fatwa.answer,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontFamily: 'Cairo',
                        height: 2.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ط£ط²ط±ط§ط± ط§ظ„طھظپط§ط¹ظ„
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyFatwa(context),
                      icon: const Icon(Icons.copy),
                      label: const Text(
                        'نسخ',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareFatwa(context),
                      icon: const Icon(Icons.share),
                      label: const Text(
                        'مشاركة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
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

  Widget _infoChip(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String get _fatwaText =>
      '${fatwa.question}\n\n${fatwa.answer}\n\nالمصدر: ${fatwa.scholar} - ${fatwa.book}';

  Future<void> _shareFatwa(BuildContext context) async {
    await Share.share(_fatwaText);
  }

  Future<void> _saveFatwa(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_fatwa_ids') ?? <String>[];
    if (!saved.contains(fatwa.id)) saved.add(fatwa.id);
    await prefs.setStringList('saved_fatwa_ids', saved);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الفتوى', style: TextStyle(fontFamily: 'Cairo')),
      ),
    );
  }

  Future<void> _copyFatwa(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _fatwaText));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الفتوى', style: TextStyle(fontFamily: 'Cairo')),
      ),
    );
  }
}
