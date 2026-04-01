import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final FlutterTts _flutterTts = FlutterTts();

  // Mapping for dotted consonants (Mei Ezhuthukkal) to ensure correct pronunciation
  static const Map<String, String> _phoneticMap = {
    'க்': 'இக்', 'ங்': 'இங்', 'ச்': 'இச்', 'ஞ்': 'இஞ்', 'ட்': 'இட்', 'ண்': 'இண்',
    'த்': 'இத்', 'ந்': 'இந்', 'ப்': 'இப்', 'ம்': 'இம்', 'ய்': 'இய்', 'ர்': 'இர்',
    'ல்': 'இல்', 'வ்': 'இவ்', 'ழ்': 'இழ்', 'ள்': 'இள்', 'ற்': 'இற்', 'ன்': 'இன்',
    'ஃ': 'அக்',
  };

  static Future<void> initialize() async {
    try {
      await _flutterTts.setLanguage('ta-IN');
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // Attempt to set a more natural voice if available
      var voices = await _flutterTts.getVoices;
      if (voices != null) {
        for (var voice in voices) {
          if (voice['locale'].toString().startsWith('ta')) {
            await _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
            break;
          }
        }
      }
    } catch (e) {
      print("TTS Initialization Error: $e");
    }
  }

  static Future<void> playLetter(String letter, {String? phonetic}) async {
    // Priority: 1. Manual phonetic text, 2. Map lookup (for dotted letters), 3. Original letter
    String textToSpeak = phonetic ?? _phoneticMap[letter] ?? letter;
    await _flutterTts.speak(textToSpeak);
  }

  static Future<void> playWord(String word) async {
    await _flutterTts.speak(word);
  }

  static Future<void> playAudioFile(String fileName) async {
    // If it's a file name, we might want to play an actual asset, but for now we speak the name
    await _flutterTts.speak(fileName);
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  static Future<void> pause() async {
    await _flutterTts.pause();
  }

  static Future<void> resume() async {
    await _flutterTts.speak('');
  }

  static Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  static Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  static Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

}
