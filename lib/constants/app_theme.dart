import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFE53935);
  static const Color darkRed = Color(0xFFC62828);
  static const Color lightRed = Color(0xFFEF5350);
  static const Color accentRed = Color(0xFFFF5252);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color textDark = Color(0xFF212121);
  static const Color textGray = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFD32F2F);
  
  static BoxDecoration glassCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          white.withOpacity(0.9),
          white.withOpacity(0.6),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: white.withOpacity(0.3), width: 2),
      boxShadow: [
        BoxShadow(
          color: primaryRed.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
  
  static BoxDecoration premiumCard() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [primaryRed, darkRed],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: primaryRed.withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
  
  static BoxDecoration gameCard() {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: primaryRed, width: 3),
      boxShadow: [
        BoxShadow(
          color: primaryRed.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
