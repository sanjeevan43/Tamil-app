import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Bold Red Palette (True Red Theme)
  static const Color primary = Color(0xFFD32F2F); // Material Red 700
  static const Color primaryDark = Color(0xFFB71C1C); // Material Red 900
  static const Color primaryLight = Color(0xFFFFEBEE); // Material Red 50
  static const Color accent = Color(0xFFFFD700); // Gold
  
  // Backgrounds
  static const Color backgroundLight = Color(0xFFFFFBFA); 
  static const Color backgroundDark = Color(0xFF310000); 
  
  // Neutrals 
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFDF2F2);
  static const Color textDark = Color(0xFF210000); 
  static const Color textGray = Color(0xFF7F0000); 
  static const Color textSlate = Color(0xFF420000); 
  static const Color borderLight = Color(0xFFFFEAEA);
  
  // Accents & Meta
  static const Color gold = Color(0xFFFFD700);
  static const Color amber = Color(0xFFFFA000);
  static const Color silver = Color(0xFFE0E0E0);
  
  // Semantic
  static const Color success = Color(0xFF2E7D32); 
  static const Color warning = Color(0xFFF9A825); 
  static const Color error = Color(0xFFC62828); 
  static const Color info = Color(0xFF1565C0); 

  // Backward compatibility aliases
  static const Color primaryRed = primary;
  static const Color darkRed = primaryDark;
  static const Color accentRed = primary; 
  static const Color lightRed = primaryLight;

  // Glass card - Professional look
  static BoxDecoration glassCard({double opacity = 0.8, double radius = 20}) {
    return BoxDecoration(
      color: white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: white.withOpacity(0.2), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Premium professional card
  static BoxDecoration premiumCard({double radius = 24}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [primary, primaryDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // White card with sophisticated styling
  static BoxDecoration whiteCard({double radius = 16}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderLight, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Professional Game card
  static BoxDecoration gameCard({double radius = 20}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: primary.withOpacity(0.1), width: 1),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  // Badge logic
  static BoxDecoration pillBadge({Color? bgColor, Color? borderColor}) {
    return BoxDecoration(
      color: bgColor ?? primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: borderColor ?? primary.withOpacity(0.1), 
        width: 1,
      ),
    );
  }

  // Material theme data - Professional overhaul
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      surface: backgroundLight,
      onSurface: textDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: white,
    ),
  );
}

