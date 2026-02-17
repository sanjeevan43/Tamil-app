# Flutter APK Build Guide

Follow these steps to build the APK for the Tamil Master app on your local machine.

## Prerequisites
1. **Flutter SDK**: Ensure Flutter is installed and added to your PATH.
   - Run `flutter --version` to check.
2. **Android SDK**: Ensure Android SDK and Build Tools are installed.
3. **Java (JDK)**: Ensure JDK 11 or 17 is installed and `JAVA_HOME` is set.

## Steps to Build

### 1. Recreate Android Files (If missing)
If the `android` folder is missing or corrupted, run:
```powershell
flutter create --platforms=android .
```

### 2. Get Dependencies
```powershell
flutter pub get
```

### 3. Build Release APK
Run the following command in your terminal:
```powershell
flutter build apk --release
```

### 4. Locate the APK
Once the build is successful, you can find the APK file here:
`build\app\outputs\flutter-apk\app-release.apk`

## Troubleshooting

### Gradle Errors
If you see "Unsupported Gradle project" or "Minimum SDK version" errors:
1. Open `android/app/build.gradle`.
2. Ensure `minSdkVersion` is at least `21`.
3. Run `flutter clean` then try again.

### Missing KeyStore
If you want to upload to Play Store, you need a signed APK. For testing, the command above creates a debug-signed release APK which can be installed on any Android phone.

## Installing on Phone
1. Copy the `app-release.apk` to your phone.
2. Open the file on your phone.
3. If prompted, "Allow installation from unknown sources".
4. Install and enjoy learning Tamil!
