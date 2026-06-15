import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/tasbih_model.dart';

class TasbihDataService {
  static List<TasbihModel>? _cache;

  static Future<List<TasbihModel>> loadTasbihList() async {
    if (_cache != null) return _cache!;

    final String jsonString =
    await rootBundle.loadString('assets/json/tasbih_list.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    _cache = jsonList.map((e) => TasbihModel.fromJson(e)).toList();
    return _cache!;
  }

  static void clearCache() => _cache = null;
}