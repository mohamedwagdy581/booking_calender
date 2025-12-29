import 'package:flutter/material.dart';
import '../constants/colors/app_colors.dart';

ThemeData getAppTheme() {
  return ThemeData(
    // --- PRIMARY COLORS ---
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onPrimary,
      onSurface: AppColors.onSurface,
      onError: AppColors.onPrimary,
    ),

    // --- SCAFFOLD ---
    scaffoldBackgroundColor: AppColors.background,

    // --- APP BAR ---
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface, // Color for title and icons
      elevation: 0,
      centerTitle: true,
    ),

    // --- TEXT THEME ---
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.onSurface),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurface),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.onSurface),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.greyDark),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onPrimary), // For buttons
    ),

    // --- BUTTON THEME ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
    ),

    // --- INPUT DECORATION THEME (for TextFormFields) ---
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.greyLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.greyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
    ),
  );
}
