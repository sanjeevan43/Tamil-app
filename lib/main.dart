import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_theme.dart';
import 'providers/enhanced_progress_provider.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AudioService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EnhancedProgressProvider()..initializeProgress()),
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
