import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatelessWidget {
  final Color primary;

  const LeaderboardScreen({super.key, required this.primary});

  final List<Map<String, dynamic>> users = const [
    {"name": "أحمد", "streak": 120},
    {"name": "محمد", "streak": 90},
    {"name": "أنت", "streak": 45},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الترتيب العالمي"),
        backgroundColor: primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return Card(
            child: ListTile(
              leading: Text(
                "${index + 1}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              title: Text(user["name"]),
              trailing: Text("🔥 ${user["streak"]}"),
            ),
          );
        },
      ),
    );
  }
}