import 'package:flutter/material.dart';
import '../constants/colors/app_colors.dart';

const appTextTheme = TextTheme(
  displayLarge: TextStyle(
      fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.onSurface),
  displayMedium: TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurface),
  bodyLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.onSurface),
  bodyMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.greyDark),
  labelLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
);
