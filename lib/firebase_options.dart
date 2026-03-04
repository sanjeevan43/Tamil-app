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
    apiKey: 'AIzaSyDw-pCDEHyBs2lPnpVsLZXD1i6hh65L95k',
    appId: '1:356453132420:web:256c9c8127289bcc96bad1',
    messagingSenderId: '356453132420',
    projectId: 'h3-tamil-app',
    authDomain: 'h3-tamil-app.firebaseapp.com',
    storageBucket: 'h3-tamil-app.firebasestorage.app',
    measurementId: 'G-XFC0SQ0ZTJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlo9dFwBwh0bUjt8KLuh12fFYctSyOfG0',
    appId: '1:356453132420:android:3e590c5a61028cc096bad1',
    messagingSenderId: '356453132420',
    projectId: 'h3-tamil-app',
    storageBucket: 'h3-tamil-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDw-pCDEHyBs2lPnpVsLZXD1i6hh65L95k', // fallback
    appId: '1:356453132420:ios:app_id_here',
    messagingSenderId: '356453132420',
    projectId: 'h3-tamil-app',
    storageBucket: 'h3-tamil-app.firebasestorage.app',
    iosBundleId: 'com.example.tamil_app',
  );
}
