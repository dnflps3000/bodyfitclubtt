import 'package:flutter/material.dart';

class AppColors {

  // ===== PRIMARY =====

  static const Color primary = Color(0xFF8FB8ED);
  static const Color primaryDark = Color(0xFF5F88C2);
  static const Color primaryLight = Color(0xFFDCEBFF);

  // ===== ACCENT =====

  static const Color accent = Color(0xFFAEC8F5);
  static const Color secondary = Color(0xFFC9DCFF);

  // ===== LIGHT MODE =====

  static const Color backgroundLight = Color(0xFFF4F8FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  static const Color textPrimaryLight = Color(0xFF1E2A3A);
  static const Color textSecondaryLight = Color(0xFF6B7A90);

  // ===== DARK MODE =====

  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1B2435);
  static const Color cardDark = Color(0xFF202C40);

  static const Color textPrimaryDark = Color(0xFFF4F7FC);
  static const Color textSecondaryDark = Color(0xFFAEB9CC);

  // ===== NAVIGATION =====

  static const Color navigationLight = Color(0xFFFFFFFF);
  static const Color navigationDark = Color(0xFF172033);

  static const Color navigationIndicatorLight = Color(0xFFDCEBFF);
  static const Color navigationIndicatorDark = Color(0xFF31415C);

  static const Color navigationSelectedLight = primary;
  static const Color navigationUnselectedLight = textSecondaryLight;

  static const Color navigationSelectedDark = accent;
  static const Color navigationUnselectedDark = textSecondaryDark;

  // ===== BORDERS =====

  static const Color borderLight = Color(0x1A8FB8ED);
  static const Color borderDark = Color(0x338FB8ED);

  // ===== STATES =====

  static const Color success = Color(0xFF7BC6A4);
  static const Color warning = Color(0xFFF2C46F);
  static const Color error = Color(0xFFE58A8A);

  // ===== QR =====

  static const Color qrBackground = Colors.white;
  static const Color qrForeground = Color(0xFF1E2A3A);

  // ===== SPLASH =====

  static const Color splashBackground = primary;
}