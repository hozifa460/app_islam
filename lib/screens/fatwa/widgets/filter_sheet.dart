// widgets/filter_sheet.dart
import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final Function(String? scholar, String? category) onFilter;
  final String? selectedScholar;
  final String? selectedCategory;

  const FilterSheet({
    super.key,
    required this.onFilter,
    this.selectedScholar,
    this.selectedCategory,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selectedScholar;
  String? _selectedCategory;

  final List<String> _scholars = [
    'الكل',
    'ابن باز',
    'ابن عثيمين',
    'ابن القيم',
    'الألباني',
    'ابن تيمية',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'الكل', 'icon': Icons.all_inclusive},
    {'name': 'صلاة', 'icon': Icons.mosque},
    {'name': 'زكاة', 'icon': Icons.volunteer_activism},
    {'name': 'صيام', 'icon': Icons.nights_stay},
    {'name': 'حج', 'icon': Icons.location_city},
    {'name': 'طهارة', 'icon': Icons.water_drop},
    {'name': 'بيوع', 'icon': Icons.store},
    {'name': 'نكاح', 'icon': Icons.favorite},
    {'name': 'أذكار', 'icon': Icons.auto_stories},
    {'name': 'عقيدة', 'icon': Icons.star},
    {'name': 'جنائز', 'icon': Icons.sentiment_very_dissatisfied},
  ];

  @override
  void initState() {
    super.initState();
    _selectedScholar = widget.selectedScholar ?? 'الكل';
    _selectedCategory = widget.selectedCategory ?? 'الكل';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â•گâ•گâ•گ Handle â•گâ•گâ•گ
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // â•گâ•گâ•گ Title â•گâ•گâ•گ
            Row(
              children: [
                const Icon(Icons.filter_list, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                const Text(
                  'تصفية النتائج',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedScholar = 'الكل';
                      _selectedCategory = 'الكل';
                    });
                  },
                  child: const Text(
                    'إعادة تعيين',
                    style: TextStyle(color: Colors.red, fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),

            const Divider(),
            const SizedBox(height: 10),

            // â•گâ•گâ•گ Scholar Filter â•گâ•گâ•گ
            const Text(
              'العالم / المفتي',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _scholars.map((scholar) {
                    final isSelected = _selectedScholar == scholar;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedScholar = scholar);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          scholar,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontFamily: 'Cairo',
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),

            // â•گâ•گâ•گ Category Filter â•گâ•گâ•گ
            const Text(
              'التصنيف',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat['name']);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(
                                    0xFF2E7D32,
                                  ).withValues(alpha: 0.1)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 16,
                              color:
                                  isSelected
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey[700],
                                fontFamily: 'Cairo',
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // â•گâ•گâ•گ Apply Button â•گâ•گâ•گ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onFilter(
                    _selectedScholar == 'الكل' ? null : _selectedScholar,
                    _selectedCategory == 'الكل' ? null : _selectedCategory,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'تطبيق الفلتر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
