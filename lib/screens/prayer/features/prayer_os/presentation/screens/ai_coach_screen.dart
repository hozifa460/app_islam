import 'package:flutter/material.dart';

import '../../../../core/services/ai/ml_model.dart';
import '../../../../core/services/ai/ml_predictor.dart';
import '../../data/repositories/prayer_repository.dart';

class AICoachScreen extends StatefulWidget {
  final Color primary;
  const AICoachScreen({super.key, required this.primary});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {

  List<String> chat = [];

  void talk() async {
    final predictor = MLPredictor(
      PrayerRepository.instance,
      MLModel(),
    );

    final msg = await predictor.generateMessage("Fajr", DateTime.now());

    setState(() {
      chat.add("🤖 $msg");
      chat.add("📊 Confidence: ${(predictor.model.predict(
        missHistory: 0.3,
        timeOfDay: 0.2,
        dayOfWeek: 0.4,
      ) * 100).toStringAsFixed(0)}%");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Coach"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: chat.map((e) => Text(e)).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: talk,
            child: const Text("تحدث"),
          )
        ],
      ),
    );
  }
}