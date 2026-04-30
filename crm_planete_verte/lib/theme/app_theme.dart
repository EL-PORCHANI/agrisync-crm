import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF2E7D32);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    primaryColor: primaryColor,
    fontFamily: 'Roboto',

    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
  );
}