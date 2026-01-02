import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Primary palette - Refined Teal
  static const Color primaryTeal = Color(0xFF0EA5A0);
  static const Color primaryTealLight = Color(0xFF2DD4BF);
  static const Color primaryTealDark = Color(0xFF0D8A86);
  static const Color primaryTealSubtle = Color(0xFF134E4A);

  // Secondary accent - Warm Amber
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentOrangeLight = Color(0xFFFBBF24);
  static const Color accentOrangeDark = Color(0xFFD97706);

  // Legacy alias
  static const Color primaryGreen = primaryTeal;

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFFBBF24);
  static const Color dangerRed = Color(0xFFEF4444);

  // Fuel gauge colors - smooth gradient
  static const Color fuelEmpty = Color(0xFF374151);
  static const Color fuelLow = Color(0xFFEF4444);
  static const Color fuelMedium = Color(0xFFF59E0B);
  static const Color fuelGood = Color(0xFF0EA5A0);
  static const Color fuelFull = Color(0xFF2DD4BF);
  static const Color fuelOverflow = Color(0xFFEF4444);

  // Background - Deep slate with subtle warmth
  static const Color background = Color(0xFF0C1222);
  static const Color backgroundElevated = Color(0xFF111827);
  static const Color cardBackground = Color(0xFF1A2332);
  static const Color surfaceLight = Color(0xFF283548);
  static const Color surfaceLighter = Color(0xFF374357);

  // Glass effects
  static const Color glassBackground = Color(0x12FFFFFF);
  static const Color glassBorder = Color(0x18FFFFFF);
  static const Color glassShadow = Color(0x30000000);

  // Text colors - refined hierarchy
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textSubtle = Color(0xFF4B5563);

  // Accent colors
  static const Color accent = Color(0xFF6366F1);
  static const Color accentLight = Color(0xFF818CF8);

  static Color getFuelColor(double percent) {
    if (percent > 1.0) return fuelOverflow;
    if (percent >= 0.75) return fuelFull;
    if (percent >= 0.5) return fuelGood;
    if (percent >= 0.25) return fuelMedium;
    return fuelLow;
  }

  // Gradient backgrounds
  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0C1222),
          Color(0xFF111827),
          Color(0xFF0F172A),
        ],
        stops: [0.0, 0.5, 1.0],
      );

  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryTeal, primaryTealLight],
      );

  static LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accentOrange, accentOrangeLight],
      );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> primaryGlow(double opacity) => [
        BoxShadow(
          color: primaryTeal.withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundElevated,
        selectedItemColor: primaryTeal,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 56,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
          height: 1.0,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 15),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: glassBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryTeal,
        unselectedLabelColor: textMuted,
        indicatorColor: primaryTeal,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primaryTealSubtle,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLighter,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: glassBorder,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryTeal,
        linearTrackColor: surfaceLight,
        circularTrackColor: surfaceLight,
      ),
    );
  }
}
