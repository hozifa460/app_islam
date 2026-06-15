import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  final Color primary;
  const InsightsScreen({super.key, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تحليلات"),
        backgroundColor: primary,
      ),
      body: Column(
        children: const [
          Text("تحليل الأسبوع"),
          SizedBox(height: 20),
          LinearProgressIndicator(value: 0.6),
        ],
      ),
    );
  }
}