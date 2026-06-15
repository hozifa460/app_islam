import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuddyScreen extends StatefulWidget {
  final Color primary;

  const BuddyScreen({super.key, required this.primary});

  @override
  State<BuddyScreen> createState() => _BuddyScreenState();
}

class _BuddyScreenState extends State<BuddyScreen> {
  String buddyName = "ط£ط­ظ…ط¯";
  int buddyStreak = 12;
  int buddyToday = 3;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final bgColor =
    isDark ? const Color(0xFF0D1117) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("ط±ظپظٹظ‚ ط§ظ„طµظ„ط§ط©"),
        backgroundColor: widget.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "ًں‘¥ ط±ظپظٹظ‚ظƒ: $buddyName",
              style: GoogleFonts.cairo(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text("ًں”¥ $buddyStreak ظٹظˆظ… ظ…طھظˆط§طµظ„"),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: buddyToday / 5,
                  ),
                  const SizedBox(height: 8),
                  Text("$buddyToday / 5 طµظ„ظˆط§طھ ط§ظ„ظٹظˆظ…"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("ط°ظƒظ‘ط± ط±ظپظٹظ‚ظƒ ط¨ط§ظ„طµظ„ط§ط©"),
            )
          ],
        ),
      ),
    );
  }
}