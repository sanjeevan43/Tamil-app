import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> initialize() async {
    await _flutterTts.setLanguage('ta-IN');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  static Future<void> playLetter(String letter) async {
    await _flutterTts.speak(letter);
  }

  static Future<void> playWord(String word) async {
    await _flutterTts.speak(word);
  }

  static Future<void> playAudioFile(String fileName) async {
    await _flutterTts.speak(fileName);
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }
}
