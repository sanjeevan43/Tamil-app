import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class Thirukkural {
  final int number;
  final String line1;
  final String line2;
  final String explanation;

  Thirukkural({
    required this.number,
    required this.line1,
    required this.line2,
    required this.explanation,
  });

  factory Thirukkural.fromJson(Map<String, dynamic> json) {
    return Thirukkural(
      number: int.parse(json['number'].toString()),
      line1: json['line1'] ?? '',
      line2: json['line2'] ?? '',
      explanation: json['tam_exp'] ?? '',
    );
  }
}

class ThirukkuralService {
  static const String _baseUrl = 'https://thirukkural-api.vercel.app/api';

  static Future<Thirukkural?> fetchDailyKural() async {
    try {
      // Get today's date to use as a seed for the random number
      final now = DateTime.now();
      final dateValue = now.year * 10000 + now.month * 100 + now.day;
      
      // Select a number between 1 and 1330 based on the date
      final random = Random(dateValue);
      final kuralNumber = random.nextInt(1330) + 1;

      final response = await http.get(Uri.parse('$_baseUrl?num=$kuralNumber'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Thirukkural.fromJson(data);
      }
    } catch (e) {
      print('Error fetching Thirukkural: $e');
    }
    return null;
  }
}
