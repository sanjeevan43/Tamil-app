import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("Initializing Firebase...");
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
    
    // Enable Firestore offline persistence for better experience in low-network areas
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    print("Firestore settings applied");

    await AudioService.initialize();
    print("Audio Service initialized");
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService(), lazy: false),
          ChangeNotifierProvider(create: (_) => EnhancedProgressProvider(), lazy: false),
          ChangeNotifierProvider(create: (_) => LessonProvider(), lazy: false), // Add the new LessonProvider
        ],
        child: const TamilMasterApp(),
      ),
    );
  } catch (e, stackTrace) {
    print("CRITICAL INITIALIZATION ERROR: $e");
    print("Stack Trace: $stackTrace");
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
      title: 'அகரவளம்',
      debugShowCheckedModeBanner: false,
      // Use the centralized theme data from AppTheme for consistent styling
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
