import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color deepGreen = Color(0xFF073D36);
  static const Color forest = Color(0xFF0F5D50);
  static const Color teal = Color(0xFF16806F);
  static const Color mint = Color(0xFF9EE8D6);
  static const Color lime = Color(0xFF8BC34A);
  static const Color olive = Color(0xFF6E9D3F);
  static const Color amber = Color(0xFFF2B84B);
  static const Color blue = Color(0xFF3D82C4);
  static const Color purple = Color(0xFF7C5CC4);
  static const Color red = Color(0xFFD95F5F);

  static const Color background = Color(0xFFF4F7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8FBF7);
  static const Color border = Color(0xFFDDE7DF);
  static const Color textPrimary = Color(0xFF123C35);
  static const Color textSecondary = Color(0xFF66756E);
  static const Color textMuted = Color(0xFF8A9891);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [deepGreen, forest, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBrandGradient = LinearGradient(
    colors: [Color(0xFFEAF8F2), Color(0xFFF7FBF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
