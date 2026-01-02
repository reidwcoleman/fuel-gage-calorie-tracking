import 'package:flutter/material.dart';

class AppTheme {
  // Primary accent - Vibrant Teal (main action color)
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryTealLight = Color(0xFF2DD4BF);
  static const Color primaryTealDark = Color(0xFF0D9488);

  // Secondary accent - Warm Orange
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentOrangeLight = Color(0xFFFB923C);

  // Legacy alias (for backward compatibility)
  static const Color primaryGreen = primaryTeal;

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warningYellow = Color(0xFFFBBF24);
  static const Color dangerRed = Color(0xFFEF4444);

  // Fuel gauge colors - teal to orange gradient
  static const Color fuelEmpty = Color(0xFF374151);
  static const Color fuelLow = Color(0xFFDC2626);
  static const Color fuelMedium = Color(0xFFF97316);  // Orange
  static const Color fuelGood = Color(0xFF14B8A6);    // Teal
  static const Color fuelFull = Color(0xFF2DD4BF);    // Light teal
  static const Color fuelOverflow = Color(0xFFEF4444);

  // Background colors - Dark Navy
  static const Color background = Color(0xFF0F172A);
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFF334155);

  // Glassmorphism colors
  static const Color glassBackground = Color(0x1AFFFFFF);  // 10% white
  static const Color glassBorder = Color(0x33FFFFFF);      // 20% white
  static const Color glassShadow = Color(0x40000000);      // 25% black

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Accent colors
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);

  static Color getFuelColor(double percent) {
    if (percent > 1.0) return fuelOverflow;
    if (percent >= 0.75) return fuelFull;
    if (percent >= 0.5) return fuelGood;
    if (percent >= 0.25) return fuelMedium;
    return fuelLow;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: accentOrange,
        surface: cardBackground,
        error: dangerRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryTeal,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceLight,
        thickness: 1,
      ),
    );
  }
}
