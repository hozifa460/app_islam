import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../prayer/more/data/quran_roots_data.dart';

class QuranRootsScreen extends StatefulWidget {
  const QuranRootsScreen({super.key});

  @override
  State<QuranRootsScreen> createState() => _QuranRootsScreenState();
}

class _QuranRootsScreenState extends State<QuranRootsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // âœ… ظ†ط³ط®ط© ط­ظ‚ظٹظ‚ظٹط© ظ…ظ† ط§ظ„ظ‚ط§ط¦ظ…ط©
  late List<QuranRoot> _filtered;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // âœ… طھظ‡ظٹط¦ط© ط§ظ„ظ‚ط§ط¦ظ…ط© ظ‡ظ†ط§ ظˆظ„ظٹط³ ظپظٹ ط§ظ„طھط¹ط±ظٹظپ
    _filtered = List.from(quranRoots);
    debugPrint('âœ… ط¹ط¯ط¯ ط§ظ„ط¬ط°ظˆط±: ${quranRoots.length}'); // ظƒظ… ظٹط·ط¨ط¹طں
    debugPrint('âœ… filtered: ${_filtered.length}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        // âœ… ط¥ط°ط§ ط§ظ„ط¨ط­ط« ظپط§ط±ط؛ ط£ط±ط¬ط¹ ظƒظ„ ط§ظ„ظ‚ط§ط¦ظ…ط©
        _filtered = List.from(quranRoots);
      } else {
        _filtered = quranRoots.where((r) {
          return r.root.contains(query) ||
              r.meaning.contains(query) ||
              r.examples.any((e) => e.contains(query));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // âœ… ط´ط±ظٹط· ط§ظ„ط¨ط­ط«
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B4513).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'ط§ط¨ط­ط« ط¹ظ† ط¬ط°ط± ط£ظˆ ظ…ط¹ظ†ظ‰...',
              hintStyle: GoogleFonts.cairo(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF8B4513),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _onSearch('');
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),

        // âœ… ط¹ط¯ط§ط¯ ط§ظ„ظ†طھط§ط¦ط¬
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filtered.length} ط¬ط°ط±',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // âœ… ط§ظ„ظ‚ط§ط¦ظ…ط©
        Expanded(
          child: _filtered.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'ظ„ط§ طھظˆط¬ط¯ ظ†طھط§ط¦ط¬',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              return _RootCard(root: _filtered[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _RootCard extends StatefulWidget {
  final QuranRoot root;
  const _RootCard({required this.root});

  @override
  State<_RootCard> createState() => _RootCardState();
}

class _RootCardState extends State<_RootCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B4513).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ط£ظٹظ‚ظˆظ†ط© ط§ظ„ط¬ط°ط±
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B4513), Color(0xFFD4AF37)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'âˆڑ',
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.root.root,
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.root.meaning,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.root.occurrences}أ—',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xFF8B4513).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDetails(),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: const Color(0xFF8B4513).withValues(alpha: 0.1)),
          const SizedBox(height: 8),
          Text(
            'ط£ظ…ط«ظ„ط© ظ…ظ† ط§ظ„ظƒظ„ظ…ط§طھ ط§ظ„ظ…ط´طھظ‚ط©:',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.root.examples.map((example) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B4513), Color(0xFFD4AF37)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  example,
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ظˆط±ط¯ ظ‡ط°ط§ ط§ظ„ط¬ط°ط± ${widget.root.occurrences} ظ…ط±ط© ظپظٹ ط§ظ„ظ‚ط±ط¢ظ† ط§ظ„ظƒط±ظٹظ…',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}