import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/global_search_action_button.dart';
import '../quran/surah_deatil.dart';
import '../search/global_search_delegate_screen.dart';
import 'mircle_detail_screen.dart';

class MiraclesScreen extends StatefulWidget {
  final Color primaryColor;

  const MiraclesScreen({
    super.key,
    required this.primaryColor,
  });

  @override
  State<MiraclesScreen> createState() => _MiraclesScreenState();
}

class _MiraclesScreenState extends State<MiraclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  List<Map<String, dynamic>> _miracles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMiracles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMiracles() async {
    try {
      final jsonString = await rootBundle.loadString('assets/mircle/miracles.json');
      final List<dynamic> data = json.decode(jsonString);

      setState(() {
        _miracles = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Miracles load error: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMiracles {
    return _miracles.where((item) {
      final matchesType =
          _selectedFilter == 'all' || item['type'] == _selectedFilter;

      final q = _searchQuery.trim();
      if (q.isEmpty) return matchesType;

      final title = (item['title'] ?? '').toString();
      final subtitle = (item['subtitle'] ?? '').toString();
      final description = (item['description'] ?? '').toString();
      final source = (item['source'] ?? '').toString();

      final matchesQuery =
          title.contains(q) ||
              subtitle.contains(q) ||
              description.contains(q) ||
              source.contains(q);

      return matchesType && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF7F6F2);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    const gold = Color(0xFFE6B325);

    if (_loading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: widget.primaryColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'المعجزات',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: CircularProgressIndicator(color: widget.primaryColor),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: widget.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'المعجزات',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            GlobalSearchActionButton(
                primaryColor: widget.primaryColor,
                iconColor: Colors.white
            ),

          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: widget.primaryColor,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: GoogleFonts.cairo(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'ابحث بين معجزات القرآن والسنة...',
                        hintStyle: GoogleFonts.cairo(color: Colors.white70),
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _filterChip(
                          label: 'الكل',
                          value: 'all',
                          selected: _selectedFilter == 'all',
                          gold: gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _filterChip(
                          label: 'القرآن',
                          value: 'quran',
                          selected: _selectedFilter == 'quran',
                          gold: gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _filterChip(
                          label: 'السنة',
                          value: 'sunnah',
                          selected: _selectedFilter == 'sunnah',
                          gold: gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredMiracles.isEmpty
                  ? Center(
                child: Text(
                  'لا توجد نتائج مطابقة',
                  style: GoogleFonts.cairo(
                    color: subTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: _filteredMiracles.length,
                itemBuilder: (context, index) {
                  final item = _filteredMiracles[index];
                  final isQuran = item['type'] == 'quran';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: (isQuran ? widget.primaryColor : gold).withOpacity(0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MiracleDetailScreen(
                              item: item,
                              primaryColor: widget.primaryColor,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isQuran ? widget.primaryColor : gold).withOpacity(0.12),
                                border: Border.all(
                                  color: (isQuran ? widget.primaryColor : gold).withOpacity(0.25),
                                ),
                              ),
                              child: Icon(
                                isQuran ? Icons.menu_book_rounded : Icons.auto_awesome_rounded,
                                color: isQuran ? widget.primaryColor : gold,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item['title'],
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['subtitle'],
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isQuran ? widget.primaryColor : gold).withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item['reference'],
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isQuran ? widget.primaryColor : gold,
                                          ),
                                        ),
                                      ),
                                      if ((item['book'] ?? '').toString().isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.10),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            item['book'],
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: subTextColor,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required String value,
    required bool selected,
    required Color gold,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? gold : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

