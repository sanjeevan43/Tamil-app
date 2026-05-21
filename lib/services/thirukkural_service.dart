import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
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
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      // 1. Try to fetch from Firebase first
      final snapshot = await _db.collection('daily_kurals')
          .where('date', isEqualTo: dateStr)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return Thirukkural.fromJson(data);
      }

      // 2. If not found in FireStore for today, you might want to pick a random one 
      // from the main 'kurals' collection if you have it.
      // For now, let's fall back to local as a safety check if Firebase is empty.
      return _fetchFromLocal(now);
    } catch (e) {
      return _fetchFromLocal(now);
    }
  }

  static Future<Thirukkural?> _fetchFromLocal(DateTime now) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/v_thirukkural_list.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> kuralList = data['kural'];

      if (kuralList.isEmpty) return _getFallbackKural();

      final dateValue = now.year * 10000 + now.month * 100 + now.day;
      final random = Random(dateValue);
      final index = random.nextInt(kuralList.length);

      return Thirukkural.fromJson(kuralList[index]);
    } catch (e) {
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
