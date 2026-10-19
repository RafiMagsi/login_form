import 'package:flutter/material.dart';

/// Brand palette: a dark, near-black canvas with a single warm "ember"
/// accent so calories and calls to action always read as the focal point.
class AppColors {
  AppColors._();

  static const base = Color(0xFF0A0C14);
  static const ember = Color(0xFFFF7A3D);
  static const rose = Color(0xFFFF3D81);
  static const lilac = Color(0xFFB8A9FF);
  static const mint = Color(0xFF3DDBA7);
  static const error = Color(0xFFFF8FA0);

  static const accent = LinearGradient(
    colors: [ember, rose],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

ThemeData buildAppTheme() {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.base,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.ember,
      brightness: Brightness.dark,
      surface: AppColors.base,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1E2130),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.28),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      floatingLabelStyle: const TextStyle(color: AppColors.ember),
      errorStyle: const TextStyle(color: AppColors.error),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.white.withValues(alpha: 0.14)),
      focusedBorder: border(AppColors.ember, 1.6),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.6),
    ),
  );
}
