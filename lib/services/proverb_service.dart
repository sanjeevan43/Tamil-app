import 'dart:convert';
import 'package:flutter/services.dart';

class TamilProverb {
  final int id;
  final String proverb;
  final String meaning;

  TamilProverb({
    required this.id,
    required this.proverb,
    required this.meaning,
  });

  factory TamilProverb.fromJson(Map<String, dynamic> json) {
    return TamilProverb(
      id: json['id'],
      proverb: json['proverb'],
      meaning: json['meaning'],
    );
  }
}

class ProverbService {
  static Future<TamilProverb?> getDailyProverb() async {
    try {
      final String response = await rootBundle.loadString('assets/data/tamil_proverbs.json');
      final List<dynamic> data = json.decode(response);
      final List<TamilProverb> proverbs = data.map((json) => TamilProverb.fromJson(json)).toList();

      if (proverbs.isEmpty) return null;

      // Calculate the day of the year
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final diff = now.difference(startOfYear);
      final dayOfYear = diff.inDays;

      // Select proverb using modulo
      final index = dayOfYear % proverbs.length;
      return proverbs[index];
    } catch (e) {
      print('Error loading proverbs: $e');
      return _getFallbackProverb();
    }
  }

  static TamilProverb _getFallbackProverb() {
    return TamilProverb(
      id: 1,
      proverb: 'முயற்சி திருவினையாக்கும்.',
      meaning: 'Effort leads to success.',
    );
  }
}
