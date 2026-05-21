import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  bool get isListening => _isListening;
  String get text => _text;

  Future<bool> initialize() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        debugPrint('onStatus: $val');
        if (val == 'done' || val == 'notListening') {
          _isListening = false;
          notifyListeners();
        }
      },
      onError: (val) => debugPrint('onError: $val'),
    );
    return available;
  }

  void listen({required Function(String) onResult}) async {
    if (!_isListening) {
      bool available = await initialize();
      if (available) {
        _isListening = true;
        _text = '';
        notifyListeners();
        
        _speech.listen(
          onResult: (val) {
            _text = val.recognizedWords;
            onResult(_text);
            notifyListeners();
          },
          localeId: 'en_US', // English learning app
        );
      }
    } else {
      stop();
    }
  }

  void stop() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }
}

// MARK: - Reusable Speaking Button Widget
class SpeakingButtonWidget extends StatefulWidget {
  final Function(String) onFinalResult;
  const SpeakingButtonWidget({super.key, required this.onFinalResult});

  @override
  State<SpeakingButtonWidget> createState() => _SpeakingButtonWidgetState();
}

class _SpeakingButtonWidgetState extends State<SpeakingButtonWidget> {
  final SpeechToTextService _speechService = SpeechToTextService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Text(
            _speechService.text.isEmpty ? 'பேசத் தயாராக உள்ளது... (Ready to speak...)' : _speechService.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () {
            if (_speechService.isListening) {
              _speechService.stop();
              widget.onFinalResult(_speechService.text);
            } else {
              _speechService.listen(onResult: (res) {
                setState(() {});
              });
            }
          },
          child: AnimatedScale(
            scale: _speechService.isListening ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: _speechService.isListening ? Colors.red : Colors.blue,
              child: Icon(
                _speechService.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _speechService.isListening ? 'நிறுத்துவதற்கு மீண்டும் தட்டவும் (Tap to stop)' : 'பேசுவதற்கு தட்டவும் (Tap to speak)',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}
