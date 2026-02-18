import 'package:flutter/material.dart';

class AppTheme {
  // Primary palette (from HTML mockup: #f2200d)
  static const Color primaryRed = Color(0xFFF2200D);
  static const Color darkRed = Color(0xFFD41B0A);
  static const Color lightRed = Color(0xFFFFCDD2);
  static const Color accentRed = Color(0xFFFF6B5B);
  
  // Backgrounds (from HTML mockup)
  static const Color backgroundLight = Color(0xFFF8F6F5);
  static const Color backgroundDark = Color(0xFF221110);
  
  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF221110);
  static const Color textGray = Color(0xFF757575);
  static const Color textSlate = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  
  // Accents
  static const Color gold = Color(0xFFFFD700);
  static const Color amber = Color(0xFFF59E0B);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  
  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);

  // Glass card (from HTML: rgba(255,255,255,0.7) + blur)
  static BoxDecoration glassCard({double opacity = 0.7, double radius = 16}) {
    return BoxDecoration(
      color: white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: primaryRed.withOpacity(0.1), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Glass red card (from HTML: rgba(242,32,13,0.05) + blur)
  static BoxDecoration glassRedCard({double radius = 16}) {
    return BoxDecoration(
      color: primaryRed.withOpacity(0.05),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: primaryRed.withOpacity(0.15), width: 1),
      boxShadow: [
        BoxShadow(
          color: primaryRed.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Premium gradient card (header cards, CTAs)
  static BoxDecoration premiumCard({double radius = 16}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [primaryRed, darkRed],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: primaryRed.withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // White card with subtle shadow (story list cards)
  static BoxDecoration whiteCard({double radius = 16}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderLight, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Game card
  static BoxDecoration gameCard({double radius = 16}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: primaryRed, width: 2.5),
      boxShadow: [
        BoxShadow(
          color: primaryRed.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
  
  // Pill badge
  static BoxDecoration pillBadge({Color? bgColor, Color? borderColor}) {
    return BoxDecoration(
      color: bgColor ?? primaryRed.withOpacity(0.1),
      borderRadius: BorderRadius.circular(999),
      border: borderColor != null 
          ? Border.all(color: borderColor, width: 1) 
          : Border.all(color: primaryRed.withOpacity(0.2), width: 1),
    );
  }

  // Material theme data
  static ThemeData get themeData => ThemeData(
    primaryColor: primaryRed,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'Lexend',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryRed,
      primary: primaryRed,
      surface: backgroundLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryRed,
      foregroundColor: white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: white,
        letterSpacing: 0.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
  );
}
