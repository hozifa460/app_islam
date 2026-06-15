import 'package:flutter/material.dart';

class SunnahHeaderWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  const SunnahHeaderWidget({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF0A0E1A),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderBackground(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _SearchBar(
          controller: searchController,
          onSearch: onSearch,
        ),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A2540),
            Color(0xFF0A0E1A),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ظ†ط¬ظˆظ… ط®ظ„ظپظٹط©
          ..._buildStars(),
          // ط§ظ„ظ…ط­طھظˆظ‰
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // ط£ظٹظ‚ظˆظ†ط© ظ…طھط­ط±ظƒط©
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ظ…ط§ط°ط§ ظƒط§ظ† ظٹظپط¹ظ„ ï·؛',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Text(
                    'ط³ظ†ظ† ظ†ط¨ظˆظٹط© ظ…ظˆط«ظ‚ط© ظ…ظ† ط§ظ„طµط­ط§ط­ ظˆط§ظ„ظ…ط³ط§ظ†ظٹط¯',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // ط´ط±ظٹط· ط°ظ‡ط¨ظٹ
                Container(
                  width: 60,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.transparent, Color(0xFFD4AF37), Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars() {
    const stars = [
      [0.1, 0.1], [0.9, 0.15], [0.3, 0.25],
      [0.7, 0.3], [0.5, 0.1], [0.15, 0.5],
      [0.85, 0.45], [0.4, 0.6], [0.6, 0.55],
      [0.25, 0.7], [0.75, 0.65],
    ];

    return stars.asMap().entries.map((entry) {
      final i = entry.key;
      final pos = entry.value;
      final size = i % 3 == 0 ? 3.0 : (i % 3 == 1 ? 2.0 : 1.5);
      return Positioned(
        left: pos[0] * 400,
        top: pos[1] * 260,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.4 + (i % 3) * 0.1),
          ),
        ),
      );
    }).toList();
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  const _SearchBar({
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1A),
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearch,
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'ط§ط¨ط­ط« ط¹ظ† ط³ظ†ط©...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white38),
            onPressed: () {
              controller.clear();
              onSearch('');
            },
          )
              : null,
          filled: true,
          fillColor: const Color(0xFF1A2540),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF2A3550),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFD4AF37),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}