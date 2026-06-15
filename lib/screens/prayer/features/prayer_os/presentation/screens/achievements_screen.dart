import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  final Color primary;
  const AchievementsScreen({super.key, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإنجازات"),
        backgroundColor: primary,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.star),
            title: Text("أسبوع كامل"),
          ),
          ListTile(
            leading: Icon(Icons.military_tech),
            title: Text("30 يوم"),
          ),
        ],
      ),
    );
  }
}