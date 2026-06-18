import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore persistence
import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'providers/enhanced_progress_provider.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'providers/lesson_provider.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the system navigation bar color to match the premium dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: AppTheme.secondary,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
  ));
  
  await dotenv.load(fileName: '.env');
  
  try {
    debugPrint('Initializing Firebase...');
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    // Initialize Google Sign-In
    await GoogleSignIn.instance.initialize();
    debugPrint('Google Sign-In initialized successfully');
    
    // Enable Firestore offline persistence with a reasonable cache limit to prevent RAM bloat and UI freezes
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 50 * 1024 * 1024, // 50 MB cache limit
    );
    debugPrint('Firestore settings applied with 50MB cache limit');

    // Run database auto-seeding in the background only when explicitly needed.
    // Disabled on client launch to prevent massive RAM usage, CPU locks, and unnecessary network requests.
    // _autoSeedDatabase();

    // Initialize non-blocking services after basic setup
    AudioService.initialize().then((_) {
      debugPrint('Audio Service initialized successfully in background');
    }).catchError((e) {
      debugPrint('Non-critical service error (AudioService): $e');
    });
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService(), lazy: false),
          ChangeNotifierProvider(create: (_) => EnhancedProgressProvider(), lazy: false),
          ChangeNotifierProvider(create: (_) => LessonProvider(), lazy: false),
        ],
        child: const TamilMasterApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('CRITICAL INITIALIZATION ERROR: $e');
    debugPrint('Stack Trace: $stackTrace');
    // Still run the app but maybe show an error screen? 
    // For now, just rethrow to let it crash but with info
    rethrow;
  }
}

class TamilMasterApp extends StatelessWidget {
  const TamilMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamil Kids Park',
      debugShowCheckedModeBanner: false,
      // Use the centralized theme data from AppTheme for consistent styling
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}

