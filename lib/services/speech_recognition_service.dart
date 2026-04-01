import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognitionService {
  static final SpeechRecognitionService _instance = SpeechRecognitionService._internal();
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = '';

  factory SpeechRecognitionService() {
    return _instance;
  }

  SpeechRecognitionService._internal() {
    _speechToText = stt.SpeechToText();
  }

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  Future<bool> initialize() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => print('Error: $error'),
        onStatus: (status) => print('Status: $status'),
      );
      return available;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  Future<void> startListening({String languageCode = 'ta-IN'}) async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        _isListening = true;
        _recognizedText = '';
        _speechToText.listen(
          onResult: (result) {
            _recognizedText = result.recognizedWords;
          },
          localeId: languageCode,
        );
      }
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
    }
  }

  Future<void> cancelListening() async {
    _isListening = false;
    _recognizedText = '';
    await _speechToText.cancel();
  }

  bool isAvailable() {
    return _speechToText.isAvailable;
  }

  List<LocaleName> getLocales() {
    return _speechToText.locales;
  }

  Future<double> getSimilarity(String text1, String text2) async {
    final t1 = text1.toLowerCase().trim();
    final t2 = text2.toLowerCase().trim();

    if (t1 == t2) return 1.0;

    int matches = 0;
    int maxLength = t1.length > t2.length ? t1.length : t2.length;

    for (int i = 0; i < maxLength; i++) {
      if (i < t1.length && i < t2.length && t1[i] == t2[i]) {
        matches++;
      }
    }

    return matches / maxLength;
  }

  Future<bool> checkPronunciation(String targetWord, {double threshold = 0.7}) async {
    final similarity = await getSimilarity(targetWord, _recognizedText);
    return similarity >= threshold;
  }
}
