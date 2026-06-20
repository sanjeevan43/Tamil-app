import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      id: json['id'] ?? 0,
      proverb: json['proverb'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }
}

class ProverbService {
  static List<TamilProverb>? _cachedProverbs;

  static Future<TamilProverb?> getDailyProverb() async {
    try {
      if (_cachedProverbs == null) {
        final String jsonString = await rootBundle.loadString('assets/data/tamil_proverbs.json');
        final List<dynamic> data = json.decode(jsonString);
        _cachedProverbs = data.map((item) => TamilProverb.fromJson(item)).toList();
      }

      if (_cachedProverbs != null && _cachedProverbs!.isNotEmpty) {
        final now = DateTime.now();
        final startOfYear = DateTime(now.year, 1, 1);
        final dayOfYear = now.difference(startOfYear).inDays;

        // Index from 0 to list length - 1
        final int index = dayOfYear % _cachedProverbs!.length;
        return _cachedProverbs![index];
      }

      return _getFallbackProverb();
    } catch (e) {
      debugPrint('ProverbService: Error loading proverb from assets: $e');
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
