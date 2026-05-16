import 'dart:ui';

/// Centrálne farby aplikácie.
class AppColors {
  // Brand
  static const Color primary = Color(0xFF8FB8ED);
  static const Color primaryLight = Color(0xFFDCEBFF);
  static const Color primaryDark = Color(0xFF4F78AA);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x12000000);

  // Splash / ikony / logo pozadie
  static const Color splashBackground = primary;

  // Light mode
  static const Color backgroundLight = Color(0xFFF7FAFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF101828);
  static const Color textSecondaryLight = Color(0xFF475467);

  // Dark mode
  static const Color backgroundDark = Color(0xFF101828);
  static const Color surfaceDark = Color(0xFF162033);
  static const Color cardDark = Color(0xFF1D2B3F);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFD0D5DD);

  // Common states
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFF04438);

  // QR
  static const Color qrBackground = Color(0xFFFFFFFF);
  static const Color qrForeground = Color(0xFF000000);
  static const Color qrText = Color(0xFF101828);
  static const Color qrScannerBorder = Color(0xFFFFFFFF);
  static const Color qrScannerOverlay = Color(0x8A000000);
}
