// screens/fatwa_detail_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/fatwa_model.dart';

class FatwaDetailScreen extends StatelessWidget {
  final Fatwa fatwa;

  const FatwaDetailScreen({Key? key, required this.fatwa}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('طھظپط§طµظٹظ„ ط§ظ„ظپطھظˆظ‰',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: const Color(0xFF1B5E20),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareFatwa(),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => _saveFatwa(),
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
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
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
                  color: Colors.white,
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
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ط§ظ„ط³ط¤ط§ظ„',
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
                  color: Colors.white,
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
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ط§ظ„ط¬ظˆط§ط¨',
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
                        color: Colors.grey[800],
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
                      onPressed: () => _copyFatwa(),
                      icon: const Icon(Icons.copy),
                      label: const Text('ظ†ط³ط®',
                          style: TextStyle(fontFamily: 'Cairo')),
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
                      onPressed: () => _shareFatwa(),
                      icon: const Icon(Icons.share),
                      label: const Text('ظ…ط´ط§ط±ظƒط©',
                          style: TextStyle(fontFamily: 'Cairo')),
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
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _shareFatwa() {}
  void _saveFatwa() {}
  void _copyFatwa() {}
}