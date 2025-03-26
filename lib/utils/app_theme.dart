import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color.fromARGB(255, 225, 113, 0);
  static const Color primaryDarkColor = Color.fromARGB(255, 183, 91, 0);
  static const Color primaryLightColor = Color.fromARGB(255, 255, 138, 30);
  
  // Secondary colors
  static const Color secondaryColor = Color.fromARGB(255, 0, 132, 188);
  static const Color secondaryDarkColor = Color.fromARGB(255, 0, 105, 150);
  static const Color secondaryLightColor = Color.fromARGB(255, 41, 182, 246);
  
  // Feedback colors
  static const Color errorColor = Color.fromARGB(255, 211, 47, 47);
  static const Color successColor = Color.fromARGB(255, 56, 142, 60);
  static const Color warningColor = Color.fromARGB(255, 245, 124, 0);
  static const Color infoColor = Color.fromARGB(255, 2, 119, 189);
  
  // Background colors
  static const Color backgroundColor = Color.fromARGB(255, 250, 250, 250);
  static const Color surfaceColor = Color.fromARGB(255, 255, 255, 255);
  
  // Text colors
  static const Color textPrimaryColor = Color.fromARGB(255, 33, 33, 33);
  static const Color textSecondaryColor = Color.fromARGB(255, 117, 117, 117);
  static const Color textDisabledColor = Color.fromARGB(255, 189, 189, 189);
  
  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Create theme data
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLightColor,
        onPrimaryContainer: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: secondaryLightColor,
        onSecondaryContainer: Colors.white,
        error: errorColor,
        onError: Colors.white,
        surface: backgroundColor,
        onSurface: textPrimaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, 
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28, 
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimaryColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
    );
  }
} 