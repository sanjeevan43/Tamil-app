import 'dart:convert';
import 'dart:math';
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
      number: json['Number'] ?? 0,
      line1: json['Line1'] ?? '',
      line2: json['Line2'] ?? '',
      explanation: json['mv'] ?? json['sp'] ?? json['mk'] ?? '',
      englishMeaning: json['explanation'] ?? '',
    );
  }
}

class ThirukkuralService {
  static Future<Thirukkural?> fetchDailyKural() async {
    try {
      // Load local JSON from assets
      final String jsonString = await rootBundle.loadString('assets/data/v_thirukkural_list.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> kuralList = data['kural'];

      if (kuralList.isEmpty) {
        return _getFallbackKural();
      }

      // Get today's date to use as a seed for the random number
      final now = DateTime.now();
      final dateValue = now.year * 10000 + now.month * 100 + now.day;
      
      // Select a number between 0 and length-1 based on the date
      final random = Random(dateValue);
      final index = random.nextInt(kuralList.length);

      return Thirukkural.fromJson(kuralList[index]);
    } catch (e) {
      print('Error fetching local Thirukkural: $e');
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
