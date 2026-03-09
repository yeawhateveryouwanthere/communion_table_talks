import 'package:flutter/material.dart';

/// App-wide theme for Communion Table Talks.
///
/// Uses a warm, reverent color palette suitable for
/// a worship-focused application.
class AppTheme {
  // Primary colors - deep burgundy/wine (evokes communion)
  static const Color primaryColor = Color(0xFF6B2D3E);
  static const Color primaryLight = Color(0xFF9C5A6B);
  static const Color primaryDark = Color(0xFF3E0A1B);

  // Accent - warm gold
  static const Color accentColor = Color(0xFFD4A843);
  static const Color accentLight = Color(0xFFE8CC7A);

  // Neutrals
  static const Color backgroundColor = Color(0xFFF8F5F0);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color dividerColor = Color(0xFFE0D8D0);

  // Length category colors
  static const Color briefColor = Color(0xFF4A8C6F);
  static const Color mediumColor = Color(0xFF4A6F8C);
  static const Color substantiveColor = Color(0xFF6B2D3E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Serif',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        labelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Returns the color associated with a presentation length category.
  static Color lengthColor(String length) {
    switch (length.toLowerCase()) {
      case 'brief':
        return briefColor;
      case 'medium':
        return mediumColor;
      case 'substantive':
        return substantiveColor;
      default:
        return mediumColor;
    }
  }
}
