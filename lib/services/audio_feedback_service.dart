import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class AudioFeedbackService {
  static final AudioPlayer _player = AudioPlayer();
  static final Set<String> _existingAssets = {};
  static final Set<String> _nonExistingAssets = {};

  static Future<void> playSound(String soundPath) async {
    final fullPath = 'assets/$soundPath';
    if (_nonExistingAssets.contains(fullPath)) return;

    if (!_existingAssets.contains(fullPath)) {
      try {
        await rootBundle.load(fullPath);
        _existingAssets.add(fullPath);
      } catch (_) {
        _nonExistingAssets.add(fullPath);
        return;
      }
    }

    try {
      await _player.stop();
      await _player.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint('AudioFeedbackService: Error playing sound $soundPath: $e');
    }
  }

  static Future<void> playTap() async => playSound('audio/tap.mp3');
  static Future<void> playPop() async => playSound('audio/pop.mp3');
  static Future<void> playCoin() async => playSound('audio/coin.mp3');
  static Future<void> playSparkle() async => playSound('audio/sparkle.mp3');
  static Future<void> playBadgeUnlock() async => playSound('audio/badge_unlock.mp3');
  static Future<void> playCorrect() async => playSound('audio/correct.mp3');
  static Future<void> playWrong() async => playSound('audio/wrong.mp3');
  static Future<void> playPageComplete() async => playSound('audio/page_complete.mp3');
}
