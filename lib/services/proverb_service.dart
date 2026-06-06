import 'package:flutter/foundation.dart';
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
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final dayOfYear = now.difference(startOfYear).inDays;

      // Pseudo-random index from 1 to 30 based on day of the year
      final int index = (dayOfYear % 30) + 1;

      // Fetch specific proverb document directly by ID
      final doc = await _db.collection('proverbs').doc(index.toString()).get();
      if (doc.exists && doc.data() != null) {
        return TamilProverb.fromJson(doc.data()!);
      }
      return _getFallbackProverb();
    } catch (e) {
      debugPrint('ProverbService: Error fetching proverb from Firestore: $e');
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
