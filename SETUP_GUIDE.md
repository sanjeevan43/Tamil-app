# Tamil Master - Setup & Run Guide

## Quick Start

### 1. Prerequisites Check
Ensure you have Flutter installed:
```bash
flutter doctor
```

### 2. Install Dependencies
Navigate to project directory and run:
```bash
cd c:\HS\tamil_app
flutter pub get
```

### 3. Run the App

**For Android:**
```bash
flutter run
```

**For iOS (macOS only):**
```bash
flutter run
```

**For specific device:**
```bash
flutter devices
flutter run -d <device-id>
```

## Project Features Implemented

### ✅ Core Screens (All with Red & White Theme)
1. **Splash Screen** - Animated logo with gradient background
2. **Home Screen** - 8 main options in grid layout
3. **Tamil Letters Screen** - Interactive letter cards with audio
4. **Simple Words Screen** - Category-based word learning
5. **Pronunciation Practice** - Speech recognition functionality
6. **Quiz Screen** - Multiple choice questions with scoring
7. **Memory Match Game** - Card matching game
8. **Writing Practice** - Letter tracing with finger drawing
9. **Progress Screen** - Achievement tracking
10. **Parent Dashboard** - Progress reports and analytics

### ✅ Technical Implementation
- **State Management**: Provider pattern
- **Local Storage**: Hive database
- **Audio**: Flutter TTS for Tamil pronunciation
- **Speech Recognition**: speech_to_text package
- **Fonts**: Google Fonts (Noto Sans Tamil)
- **Theme**: Consistent red and white color scheme

### ✅ Features
- Daily streak tracking
- Star and coin rewards
- Achievement badges
- Progress monitoring
- Offline functionality
- Responsive UI design

## Troubleshooting

### Issue: Dependencies not installing
```bash
flutter clean
flutter pub get
```

### Issue: Hive adapter errors
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Issue: Permission errors on Android
Ensure AndroidManifest.xml includes:
- RECORD_AUDIO permission
- INTERNET permission

### Issue: iOS microphone not working
Check Info.plist includes:
- NSMicrophoneUsageDescription
- NSSpeechRecognitionUsageDescription

## Building for Release

### Android APK:
```bash
flutter build apk --release
```

### iOS IPA (macOS only):
```bash
flutter build ios --release
```

## Project Structure Overview

```
tamil_app/
├── lib/
│   ├── constants/        # Colors and Tamil data
│   ├── models/           # Data models
│   ├── providers/        # State management
│   ├── screens/          # All UI screens
│   ├── services/         # Audio and other services
│   └── main.dart         # App entry point
├── assets/
│   ├── audio/            # Audio files (optional)
│   ├── fonts/            # Tamil fonts
│   └── images/           # Images and icons
├── android/              # Android configuration
├── ios/                  # iOS configuration
└── pubspec.yaml          # Dependencies
```

## Color Theme

The entire app uses a consistent **Red and White** color palette:
- Primary Red: #E53935
- Dark Red: #C62828
- Light Red: #EF5350
- Accent Red: #FF5252
- White: #FFFFFF

All screens, buttons, cards, and interactive elements follow this theme.

## Next Steps

1. Add custom images to `assets/images/`
2. Add custom audio files to `assets/audio/` (optional)
3. Download Tamil font to `assets/fonts/` (optional, uses Google Fonts as fallback)
4. Customize Tamil data in `lib/constants/tamil_data.dart`
5. Test on physical devices for best experience

## Support

For issues or questions:
- Check Flutter documentation: https://flutter.dev/docs
- Review package documentation in pubspec.yaml
- Ensure all permissions are granted on device

---

**Ready to run!** Execute `flutter run` to start the app.
