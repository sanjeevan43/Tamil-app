import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Thirukkural {
  final int number;
  final String line1;
  final String line2;
  final String explanation;
  final String englishMeaning;

  Thirukkural({
    required this.number,
    required this.line1,
    required this.line2,
    required this.explanation,
    required this.englishMeaning,
  });

  factory Thirukkural.fromJson(Map<String, dynamic> json) {
    return Thirukkural(
      number: json['Number'] ?? json['number'] ?? 0,
      line1: json['Line1'] ?? json['line1'] ?? '',
      line2: json['Line2'] ?? json['line2'] ?? '',
      explanation: json['mv'] ?? json['explanation_tamil'] ?? json['explanation'] ?? '',
      englishMeaning: json['explanation'] ?? json['explanation_english'] ?? '',
    );
  }
}

class ThirukkuralService {
  static List<Thirukkural>? _cachedKurals;

  static Future<Thirukkural?> fetchDailyKural() async {
    try {
      if (_cachedKurals == null) {
        final String jsonString = await rootBundle.loadString('assets/data/v_thirukkural_list.json');
        final Map<String, dynamic> data = json.decode(jsonString);
        if (data.containsKey('kural')) {
          final List<dynamic> kuralList = data['kural'];
          _cachedKurals = kuralList.map((item) => Thirukkural.fromJson(item)).toList();
        }
      }

      if (_cachedKurals != null && _cachedKurals!.isNotEmpty) {
        final now = DateTime.now();
        final startOfYear = DateTime(now.year, 1, 1);
        final dayOfYear = now.difference(startOfYear).inDays;

        // Index from 0 to list length - 1
        final int index = dayOfYear % _cachedKurals!.length;
        return _cachedKurals![index];
      }

      return _getFallbackKural();
    } catch (e) {
      debugPrint('ThirukkuralService: Error loading Kural from assets: $e');
      return _getFallbackKural();
    }
  }

  static Thirukkural _getFallbackKural() {
    return Thirukkural(
      number: 1,
      line1: 'அகர முதல எழுத்தெல்லாம் ஆதி',
      line2: 'பகவன் முதற்றே உலகு.',
      explanation: 'எழுத்துக்கள் எல்லாம் அகரத்தை அடிப்படையாக கொண்டிருக்கின்றன. அதுபோல உலகம் கடவுளை அடிப்படையாக கொண்டிருக்கிறது.',
      englishMeaning: 'As the letter A is the first of all letters, so the eternal God is first in the world',
    );
  }
}
