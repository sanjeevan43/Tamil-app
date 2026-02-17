import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_theme.dart';
import 'providers/enhanced_progress_provider.dart';
import 'services/audio_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
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
      title: 'Tamil Master Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppTheme.primaryRed,
        scaffoldBackgroundColor: AppTheme.offWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryRed,
          primary: AppTheme.primaryRed,
          secondary: AppTheme.accentRed,
        ),
        textTheme: GoogleFonts.notoSansTamilTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: AppTheme.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRed,
            foregroundColor: AppTheme.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
