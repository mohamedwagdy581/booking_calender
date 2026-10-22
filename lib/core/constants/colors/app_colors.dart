import 'package:flutter/material.dart';

// A more structured and professional color scheme

abstract class AppColors {
  // --- PRIMARY COLORS ---
  static const Color primary = Color(0xFF9B74BF);
  static const Color primaryDark = Color(0xFF9870BD);
  static const Color primaryText = Color(0xFF694588);
  static const Color primaryLight = Color(0xFFA07BC2);
  static const Color primarySoft = Color(0xFFF0E9F6);
  static const Color gradientStart = Color(0xFF9870BD);
  static const Color gradientEnd = Color(0xFFA07BC2);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  // --- UI COLORS ---
  static const Color background = Color(0xFFF8F6FA);
  static const Color surface = Color(0xFFFFFFFF); // For cards, dialogs, etc.
  static const Color onSurface = Color(0xFF302839); // Text on surface
  static const Color onPrimary = Color(0xFFFFFFFF); // Text on primary color

  // --- SEMANTIC COLORS ---
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);
  // Readable dark amber for "pending" text on light backgrounds.
  static const Color pending = Color(0xFF926100);

  // --- NEUTRAL COLORS ---
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE8E1EE); // For dividers
  static const Color greyDark = Color(0xFF424242);
  static const Color greenAccent = Color(0xFF5CF364);
}
