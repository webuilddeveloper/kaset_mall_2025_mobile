import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryHover = Color(0xFF43A047);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFFE8992B);
  static const Color accentHover = Color(0xFFC77A1F);
  static const Color accentTint = Color(0xFFFBE7C9);

  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1C1C1A);
  static const Color textSecondary = Color(0xFF6E6C61);
  static const Color border = Color(0xFFE1EBE0);
  static const Color tintGreen = Color(0xFFDCEFDD);
  static const Color tintGreenSoft = Color(0xFFEEF7EE);
  static const Color infoBlue = Color(0xFF2E7D32);
  static const Color infoBlueSoft = Color(0xFFEEF7EE);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Kanit',
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryHover,
      primaryColorDark: AppColors.primaryDark,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.tintGreen,
        selectionHandleColor: AppColors.primary,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Kanit',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF101311),
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryHover,
      primaryColorDark: AppColors.primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: Color(0xFF1A1D1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF101311),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
