import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Playful Design System Palette
  static const Color primary = Color(0xFFFF7A00); // Playful Orange
  static const Color primaryDark = Color(0xFFE05A00); 
  static const Color secondary = Color(0xFF00C2FF); // Sky Blue
  static const Color accent = Color(0xFFFFD93D); // Sunshine Yellow
  
  // Topographic Theme Accents
  static const Color topoSilver = Color(0xFFE0E0E0); // Light Gray
  static const Color topoLight = Color(0xFFF5F5F5);
  
  // Backgrounds
  static const Color backgroundLight = Color(0xFFFFFFFF); 
  static const Color backgroundDark = Color(0xFF121212); 
  
  // Neutrals 
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF1A1A1B); 
  static const Color textGray = Color(0xFF757575); 
  static const Color textSlate = Color(0xFF455A64); 
  static const Color borderLight = Color(0xFFEEEEEE);
  
  // Semantic
  static const Color success = Color(0xFF4CAF50); // Leaf Green
  static const Color warning = Color(0xFFFFD93D); // Accent Yellow
  static const Color error = Color(0xFFF44336); // Soft Red
  static const Color info = Color(0xFF00C2FF); // Sky Blue
  static const Color gold = Color(0xFFFFD700);

  // Backward compatibility aliases
  static const Color primaryRed = primary;
  static const Color darkRed = primaryDark;
  static const Color accentRed = primary; 
  static const Color lightRed = Color(0xFFFFEBEE);

  // Glass card - Sophisticated high-contrast
  static BoxDecoration glassCard({double opacity = 0.9, double radius = 24}) {
    return BoxDecoration(
      color: white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: topoSilver.withOpacity(0.5), width: 1),
      boxShadow: [
        BoxShadow(
          color: secondary.withOpacity(0.05),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Premium Logo-Themed Card (Black to Red Gradient)
  static BoxDecoration premiumCard({double radius = 24}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [secondary, primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  // White card with "Topographic" subtle border
  static BoxDecoration whiteCard({double radius = 20}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderLight, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: secondary.withOpacity(0.03),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration gameCard({double radius = 24}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: primary.withOpacity(0.1), width: 2),
    );
  }

  static BoxDecoration pillBadge({Color? bgColor, double radius = 30}) {
    return BoxDecoration(
      color: bgColor ?? primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  // Material theme data - High Contrast Pro
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: GoogleFonts.outfit().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: backgroundLight,
      onSurface: textDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: textDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: textGray,
      indicatorColor: primary,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: white,
    ),
  );
}
