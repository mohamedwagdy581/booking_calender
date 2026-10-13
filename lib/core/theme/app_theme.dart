import 'package:flutter/material.dart';
import '../constants/colors/app_colors.dart';
import 'app_text_theme.dart';

ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'NotoSansArabic',
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
      error: AppColors.error,
    ),

    // --- SCAFFOLD ---
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.greyLight,
    dividerTheme:
        const DividerThemeData(color: AppColors.greyLight, thickness: 1),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primaryText,
      unselectedItemColor: AppColors.greyDark,
    ),

    // --- APP BAR ---
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface, // Color for title and icons
      elevation: 0,
      centerTitle: true,
    ),

    // --- TEXT THEME ---
    textTheme: appTextTheme,

    // --- BUTTON THEME ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),

    // --- INPUT DECORATION THEME (for TextFormFields) ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryText,
        side: const BorderSide(color: AppColors.greyLight),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryText),
    ),
  );
}
