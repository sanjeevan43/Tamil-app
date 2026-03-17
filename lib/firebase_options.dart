import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('VITE_FIREBASE_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('VITE_FIREBASE_APP_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment('VITE_FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('VITE_FIREBASE_PROJECT_ID', defaultValue: ''),
    authDomain: String.fromEnvironment('VITE_FIREBASE_AUTH_DOMAIN', defaultValue: ''),
    storageBucket: String.fromEnvironment('VITE_FIREBASE_STORAGE_BUCKET', defaultValue: ''),
    measurementId: String.fromEnvironment('VITE_FIREBASE_MEASUREMENT_ID', defaultValue: ''),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY_ANDROID', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_APP_ID_ANDROID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment('VITE_FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('VITE_FIREBASE_PROJECT_ID', defaultValue: ''),
    storageBucket: String.fromEnvironment('VITE_FIREBASE_STORAGE_BUCKET', defaultValue: ''),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('VITE_FIREBASE_API_KEY', defaultValue: ''), // fallback
    appId: String.fromEnvironment('FIREBASE_APP_ID_IOS', defaultValue: ''),
    messagingSenderId: String.fromEnvironment('VITE_FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('VITE_FIREBASE_PROJECT_ID', defaultValue: ''),
    storageBucket: String.fromEnvironment('VITE_FIREBASE_STORAGE_BUCKET', defaultValue: ''),
    iosBundleId: 'com.example.tamil_app',
  );
}
