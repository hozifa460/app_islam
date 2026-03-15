import 'package:flutter/material.dart';
import 'package:islamic_app/screens/home/screen/HomeScreen.dart';

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'القرآن الكريم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B4513)),
        useMaterial3: true,
      ),
      home: HomeScreen(
        onThemeChanged: (bool p1) {  },
        onColorChanged: (int p1) {  }
        , isDarkMode: false,
        selectedColorIndex: 0,
        appColors: const [],
        colorNames: const [],
      ),
    );
  }
}