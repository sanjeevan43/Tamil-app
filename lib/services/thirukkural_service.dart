import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      englishMeaning: json['explanation_english'] ?? json['explanation'] ?? '',
    );
  }
}

class ThirukkuralService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<Thirukkural?> fetchDailyKural() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final dayOfYear = now.difference(startOfYear).inDays;

      // Pseudo-random index from 1 to 1330 based on day of the year
      final int index = (dayOfYear % 1330) + 1;

      // Fetch the specific thirukkural document directly by ID (fast & offline cached)
      final doc = await _db.collection('kurals').doc(index.toString()).get();
      if (doc.exists && doc.data() != null) {
        return Thirukkural.fromJson(doc.data()!);
      }
      return _getFallbackKural();
    } catch (e) {
      debugPrint('ThirukkuralService: Error fetching Kural from Firestore: $e');
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
