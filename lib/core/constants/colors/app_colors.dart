import 'package:flutter/material.dart';

// A more structured and professional color scheme

abstract class AppColors {
  // --- PRIMARY COLORS ---
  static const Color primary = Color(0xFF0D47A1); // A strong blue
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF5472D3);

  // --- UI COLORS ---
  static const Color background = Color(0xFFF5F5F5); // Light grey background
  static const Color surface = Color(0xFFFFFFFF); // For cards, dialogs, etc.
  static const Color onSurface = Color(0xFF212121); // Text on surface
  static const Color onPrimary = Color(0xFFFFFFFF); // Text on primary color

  // --- SEMANTIC COLORS ---
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);

  // --- NEUTRAL COLORS ---
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0); // For dividers
  static const Color greyDark = Color(0xFF424242);
}
