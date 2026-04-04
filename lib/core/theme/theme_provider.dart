import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider untuk mengelola status tema
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class AppTheme {
  // --- DARK THEME (Neon Dark) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // Skema Warna Dark
      colorScheme: const ColorScheme.dark(
        primary: AppColors.main,
        onPrimary: Colors.black,
        surface: AppColors.widgetColor,
        onSurface: AppColors.white,
        secondary: AppColors.blue,
        error: AppColors.red,
      ),

      // Tema AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),

      // Tema Card
      cardTheme: CardThemeData(
        color: AppColors.widgetColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Tema Text
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.white),
        bodyMedium: TextStyle(color: AppColors.grey),
      ),
    );
  }

  // --- LIGHT THEME (Clean White) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.whiteBackground,

      // Skema Warna Light
      colorScheme: const ColorScheme.light(
        primary:
            AppColors.main, // Gunakan biru sebagai aksen utama di light mode
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: AppColors.backgroundColor,
        secondary: AppColors.purple,
        error: AppColors.red,
      ),

      // Tema AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.whiteBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.backgroundColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.backgroundColor),
      ),

      // Tema Card
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Tema Text
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.backgroundColor),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
    );
  }
}
