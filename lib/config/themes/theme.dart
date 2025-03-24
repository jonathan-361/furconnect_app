import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(223, 165, 68, 22),
    ).copyWith(
      primary: Color.fromARGB(223, 165, 68, 22),
      secondary: const Color.fromARGB(255, 201, 134, 60),
      surface: Colors.white,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
        displayMedium: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
        displaySmall: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
        titleLarge: TextStyle(fontSize: 20),
        titleMedium: TextStyle(fontSize: 16),
        titleSmall: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
        bodyLarge: TextStyle(
            fontSize: 18, fontWeight: FontWeight.normal, fontFamily: 'Nunito'),
        bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.normal, fontFamily: 'Nunito'),
        bodySmall: TextStyle(
            fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'Nunito'),
      ),
    );
  }
}
