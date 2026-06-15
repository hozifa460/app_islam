import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../models/deed_model.dart';

class DeedsService {
  static Future<List<DeedModel>> loadDeeds(String langCode) async {
    try {
      // 1. قراءة الملف حسب لغة المستخدم (تأكد من مسار الملف الصحيح لديك)
      final String jsonString = await rootBundle.loadString('assets/deeds/deeds_$langCode.json');

      // 2. تحويله إلى Map
      final Map<String, dynamic> tr = json.decode(jsonString);

      // 3. بناء قائمة الأعمال المطابقة تماماً لموديل DeedModel
      return [
        DeedModel(
          title: tr['deed_1_title'] ?? '', reward: tr['deed_1_reward'] ?? '', hadith: tr['deed_1_hadith'] ?? '', source: tr['deed_1_source'] ?? '',
          type: 'palm', icon: '🌴', target: 1, color: int.parse('0xFF4CAF50'),
        ),
        DeedModel(
          title: tr['deed_2_title'] ?? '', reward: tr['deed_2_reward'] ?? '', hadith: tr['deed_2_hadith'] ?? '', source: tr['deed_2_source'] ?? '',
          type: 'scale', icon: '⚖️', target: 1, color: int.parse('0xFF9C27B0'),
        ),
        DeedModel(
          title: tr['deed_3_title'] ?? '', reward: tr['deed_3_reward'] ?? '', hadith: tr['deed_3_hadith'] ?? '', source: tr['deed_3_source'] ?? '',
          type: 'hasana', icon: '🌊', target: 100, hasanaValue: 1, color: int.parse('0xFF00BCD4'),
        ),
        DeedModel(
          title: tr['deed_4_title'] ?? '', reward: tr['deed_4_reward'] ?? '', hadith: tr['deed_4_hadith'] ?? '', source: tr['deed_4_source'] ?? '',
          type: 'palace', icon: '🏰', target: 10, color: int.parse('0xFFFF9800'),
        ),
        DeedModel(
          title: tr['deed_5_title'] ?? '', reward: tr['deed_5_reward'] ?? '', hadith: tr['deed_5_hadith'] ?? '', source: tr['deed_5_source'] ?? '',
          type: 'jewel', icon: '💎', target: 1, color: int.parse('0xFF2196F3'),
        ),
        DeedModel(
          title: tr['deed_6_title'] ?? '', reward: tr['deed_6_reward'] ?? '', hadith: tr['deed_6_hadith'] ?? '', source: tr['deed_6_source'] ?? '',
          type: 'hasana', icon: '📿', target: 1, hasanaValue: 100, color: int.parse('0xFF009688'),
        ),
        DeedModel(
          title: tr['deed_7_title'] ?? '', reward: tr['deed_7_reward'] ?? '', hadith: tr['deed_7_hadith'] ?? '', source: tr['deed_7_source'] ?? '',
          type: 'light', icon: '✨', target: 1, color: int.parse('0xFFFFC107'),
        ),
        DeedModel(
          title: tr['deed_8_title'] ?? '', reward: tr['deed_8_reward'] ?? '', hadith: tr['deed_8_hadith'] ?? '', source: tr['deed_8_source'] ?? '',
          type: 'hasana', icon: '🤲', target: 1, hasanaValue: 10, color: int.parse('0xFF8BC34A'),
        ),
        DeedModel(
          title: tr['deed_9_title'] ?? '', reward: tr['deed_9_reward'] ?? '', hadith: tr['deed_9_hadith'] ?? '', source: tr['deed_9_source'] ?? '',
          type: 'door', icon: '🚪', target: 5, color: int.parse('0xFF795548'),
        ),
        DeedModel(
          title: tr['deed_10_title'] ?? '', reward: tr['deed_10_reward'] ?? '', hadith: tr['deed_10_hadith'] ?? '', source: tr['deed_10_source'] ?? '',
          type: 'scale', icon: '⚖️', target: 1, color: int.parse('0xFFE91E63'),
        ),
        DeedModel(
          title: tr['deed_11_title'] ?? '', reward: tr['deed_11_reward'] ?? '', hadith: tr['deed_11_hadith'] ?? '', source: tr['deed_11_source'] ?? '',
          type: 'hasana', icon: '📿', target: 1, hasanaValue: 50, color: int.parse('0xFF3F51B5'),
        ),
        DeedModel(
          title: tr['deed_12_title'] ?? '', reward: tr['deed_12_reward'] ?? '', hadith: tr['deed_12_hadith'] ?? '', source: tr['deed_12_source'] ?? '',
          type: 'light', icon: '🌟', target: 1, color: int.parse('0xFFFF5722'),
        ),
        DeedModel(
          title: tr['deed_13_title'] ?? '', reward: tr['deed_13_reward'] ?? '', hadith: tr['deed_13_hadith'] ?? '', source: tr['deed_13_source'] ?? '',
          type: 'scale', icon: '⚖️', target: 1, color: int.parse('0xFF607D8B'),
        ),
        DeedModel(
          title: tr['deed_14_title'] ?? '', reward: tr['deed_14_reward'] ?? '', hadith: tr['deed_14_hadith'] ?? '', source: tr['deed_14_source'] ?? '',
          type: 'shield', icon: '🛡️', target: 3, color: int.parse('0xFF00695C'),
        ),
        DeedModel(
          title: tr['deed_15_title'] ?? '', reward: tr['deed_15_reward'] ?? '', hadith: tr['deed_15_hadith'] ?? '', source: tr['deed_15_source'] ?? '',
          type: 'shield', icon: '🛡️', target: 3, color: int.parse('0xFF37474F'),
        ),
      ];
    } catch (e) {
      debugPrint("Error loading deeds translation file: $e");
      return [];
    }
  }
}