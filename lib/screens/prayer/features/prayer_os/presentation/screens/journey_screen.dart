import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JourneyScreen extends StatefulWidget {
  final Color primary;

  const JourneyScreen({super.key, required this.primary});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  int currentDay = 7;

  final List<Map<String, String>> journeySteps = const [
    {"goal": "صلِّ صلاة واحدة فقط", "verse": "لا يكلف الله نفسًا إلا وسعها"},
    {"goal": "صلِّ صلاتين", "verse": "وأقم الصلاة"},
    {"goal": "صلِّ الفجر", "verse": "إن قرآن الفجر كان مشهودا"},
    {"goal": "صلِّ 3 صلوات", "verse": "إن مع العسر يسرا"},
    {"goal": "صلِّ كل الصلوات", "verse": "حافظوا على الصلوات"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("رحلة 30 يوم"),
        backgroundColor: widget.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "🌱 اليوم $currentDay من رحلتك",
              style: GoogleFonts.cairo(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: journeySteps.length,
                itemBuilder: (context, index) {
                  final step = journeySteps[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.flag),
                      title: Text(step["goal"]!),
                      subtitle: Text(step["verse"]!),
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
}