import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<TamilProverb?> getDailyProverb() async {
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      // 1. Try to fetch from Firebase first
      final snapshot = await _db.collection('daily_proverbs')
          .where('date', isEqualTo: dateStr)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return TamilProverb.fromJson(data);
      }

      // 2. Fallback to local
      return _fetchFromLocal();
    } catch (e) {
      debugPrint('Firebase Proverb Fetch Error: $e');
      return _fetchFromLocal();
    }
  }

  static Future<TamilProverb?> _fetchFromLocal() async {
    try {
      final String response = await rootBundle.loadString('assets/data/tamil_proverbs.json');
      final List<dynamic> data = json.decode(response);
      final List<TamilProverb> proverbs = data.map((json) => TamilProverb.fromJson(json)).toList();

      if (proverbs.isEmpty) return _getFallbackProverb();

      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final dayOfYear = now.difference(startOfYear).inDays;

      final index = dayOfYear % proverbs.length;
      return proverbs[index];
    } catch (e) {
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
