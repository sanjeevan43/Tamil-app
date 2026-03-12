import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore persistence
import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'providers/enhanced_progress_provider.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Firestore offline persistence for better experience in low-network areas
  // This allows the app to load cached data instantly without waiting for DNS
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await AudioService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(), lazy: false),
        // Progress initialization is now handled within SplashScreen's _initialize method
        ChangeNotifierProvider(create: (_) => EnhancedProgressProvider(), lazy: false),
      ],
      child: const TamilMasterApp(),
    ),
  );
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
