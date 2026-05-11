import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

// Globálny theme aplikácie, pripravený light aj dark mode.
class AppTheme {
  static Color splashBackground(Brightness brightness) {
    return AppColors.splashBackground;
  }

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: AppFonts.defaultFont,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textDark,
      centerTitle: true,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    fontFamily: AppFonts.defaultFont,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textLight,
      centerTitle: true,
    ),
  );
}
