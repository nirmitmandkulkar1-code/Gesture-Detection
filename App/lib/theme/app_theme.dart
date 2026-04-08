import 'package:flutter/material.dart';

class AppTheme {
  static const Color clinicalBlue = Color(0xFF0D3B66);
  static const Color calmCyan = Color(0xFF16A6B6);
  static const Color sterileWhite = Color(0xFFF7FBFC);
  static const Color urgentRed = Color(0xFFD64545);
  static const Color safeGreen = Color(0xFF2F9E44);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: sterileWhite,
      colorScheme: const ColorScheme.light(
        primary: clinicalBlue,
        secondary: calmCyan,
        surface: Colors.white,
        error: urgentRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: clinicalBlue.withValues(alpha: 0.12)),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: clinicalBlue,
          letterSpacing: 0.2,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: clinicalBlue,
        ),
        titleMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: clinicalBlue,
        ),
        bodyLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF213547),
        ),
        bodyMedium: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF3D5A71),
        ),
      ),
    );
  }
}
