# Tamil Master - Learn Tamil Easily

A comprehensive Flutter mobile application designed to teach Tamil language to beginner-level students aged 4-12.

## Features

- **Tamil Letters Learning**: Interactive cards for Uyir and Mei Ezhuthukkal with audio pronunciation
- **Simple Words**: Category-based word learning (Animals, Fruits, Colors, Numbers)
- **Pronunciation Practice**: Speech-to-text functionality for pronunciation checking
- **Tamil Quiz Game**: Multiple choice questions with scoring system
- **Memory Match Game**: Card matching game with Tamil letters
- **Writing Practice**: Letter tracing with finger drawing
- **Progress Tracking**: Comprehensive progress monitoring with achievements
- **Parent Dashboard**: Detailed reports and analytics for parents

## Color Theme

The app uses a consistent **Red and White** color scheme throughout all screens and components.

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- Android/iOS device or emulator

### Installation

1. Clone or extract the project to your local machine

2. Navigate to the project directory:
   ```bash
   cd tamil_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Generate Hive adapters (if needed):
   ```bash
   flutter packages pub run build_runner build
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── constants/
│   ├── colors.dart          # App color theme constants
│   └── tamil_data.dart      # Tamil letters and words data
├── models/
│   ├── user_progress.dart   # User progress model
│   └── user_progress.g.dart # Generated Hive adapter
├── providers/
│   └── progress_provider.dart # State management
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── tamil_letters_screen.dart
│   ├── simple_words_screen.dart
│   ├── pronunciation_screen.dart
│   ├── quiz_screen.dart
│   ├── memory_game_screen.dart
│   ├── writing_practice_screen.dart
│   ├── progress_screen.dart
│   └── parent_dashboard_screen.dart
├── services/
│   └── audio_service.dart   # Audio playback service
└── main.dart                # App entry point
```

## Dependencies

- **provider**: State management
- **hive**: Local database storage
- **google_fonts**: Tamil font support
- **audioplayers**: Audio playback
- **flutter_tts**: Text-to-speech
- **speech_to_text**: Speech recognition
- **shared_preferences**: Simple data storage

## Platform Support

- ✅ Android
- ✅ iOS

## Notes

- Tamil font rendering uses Google Fonts (Noto Sans Tamil)
- Audio pronunciation uses Flutter TTS with Tamil language support
- Speech recognition requires microphone permissions
- All data is stored locally using Hive database
- No internet connection required for core functionality

## Future Enhancements

- Firebase integration for cloud sync
- Leaderboard functionality
- More interactive games
- Story mode in Tamil
- Voice assistant character

## License

This project is created for educational purposes.
