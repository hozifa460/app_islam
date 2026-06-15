import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeCard {
  final String id;
  final String title;
  final String icon;
  bool isVisible;

  HomeCard({
    required this.id,
    required this.title,
    required this.icon,
    this.isVisible = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon,
    'isVisible': isVisible,
  };

  factory HomeCard.fromJson(Map<String, dynamic> json) => HomeCard(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    icon: json['icon'] ?? '',
    isVisible: json['isVisible'] ?? true,
  );
}

class HomeCardsOrderService {
  static const String _key = 'home_cards_order_v4';

  static List<HomeCard> get defaultCards => [
    HomeCard(id: 'header_slider', title: 'أعلام المسلمين', icon: '🏛️', isVisible: true),
    HomeCard(id: 'prayer', title: 'مواقيت الصلاة', icon: '🕌', isVisible: true),
    HomeCard(id: 'miracle', title: 'معجزة اليوم', icon: '✨', isVisible: true),
    HomeCard(id: 'channels', title: 'القنوات الإسلامية', icon: '🔴', isVisible: true),
    HomeCard(id: 'sunnah', title: 'تتبع السنن', icon: '🎯', isVisible: true),
    HomeCard(id: 'radio', title: 'الراديو الإسلامي', icon: '📻', isVisible: true),
    HomeCard(id: 'verse', title: 'آية اليوم', icon: '📖', isVisible: true),
    HomeCard(id: 'azkar', title: 'الأذكار', icon: '🤲', isVisible: true),
    HomeCard(id: 'quick_grid', title: 'الوصول السريع', icon: '⚡', isVisible: true),
    HomeCard(id: 'hadith', title: 'حديث اليوم', icon: '📜', isVisible: true),
  ];

  static Future<List<HomeCard>> loadOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr == null) return defaultCards;

      final List<dynamic> list = json.decode(jsonStr);
      final saved = list.map((e) => HomeCard.fromJson(e)).toList();

      // تأكد من وجود جميع البطاقات
      final savedIds = saved.map((e) => e.id).toSet();
      for (final dc in defaultCards) {
        if (!savedIds.contains(dc.id)) {
          saved.add(dc);
        }
      }

      return saved;
    } catch (_) {
      return defaultCards;
    }
  }

  static Future<void> saveOrder(List<HomeCard> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        json.encode(cards.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }
}