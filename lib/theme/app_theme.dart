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
  static const Color accentDark = Color(0xFFB8912E);

  // Neutrals
  static const Color backgroundColor = Color(0xFFF5F0EA);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFFFFCF8);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color dividerColor = Color(0xFFE0D8D0);

  // Length category colors
  static const Color briefColor = Color(0xFF4A8C6F);
  static const Color mediumColor = Color(0xFF4A6F8C);
  static const Color substantiveColor = Color(0xFF6B2D3E);

  // Gradient for headers
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B3A4E), Color(0xFF4E1528)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6B2D3E), Color(0xFF8B4A5E)],
  );

  /// Subtle card shadow for a lifted, premium feel.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF6B2D3E).withOpacity(0.06),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          offset: const Offset(0, 1),
          blurRadius: 3,
          spreadRadius: 0,
        ),
      ];

  /// Stronger shadow for elevated elements.
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF6B2D3E).withOpacity(0.10),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: const Offset(0, 2),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ];

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
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.08),
        labelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
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
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.7,
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
          fontWeight: FontWeight.w500,
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

  /// Returns an icon for the length category.
  static IconData lengthIcon(String length) {
    switch (length.toLowerCase()) {
      case 'brief':
        return Icons.short_text;
      case 'medium':
        return Icons.subject;
      case 'substantive':
        return Icons.article;
      default:
        return Icons.subject;
    }
  }
}
