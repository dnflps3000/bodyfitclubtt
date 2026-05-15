import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  static Color splashBackground(Brightness brightness) {
    return AppColors.splashBackground;
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.defaultFont,

    iconTheme: const IconThemeData(
      color: AppColors.accent,
    ),

    scaffoldBackgroundColor: AppColors.backgroundLight,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
    ),

    appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    foregroundColor: AppColors.textPrimaryLight,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
    fontFamily: AppFonts.defaultFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryLight,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
    decorationThickness: 0.5,
    decorationStyle: TextDecorationStyle.solid,
  ),
),

    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.accent,
      textColor: AppColors.textPrimaryLight,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 15,
        height: 1.35,
        color: AppColors.textSecondaryLight,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 15,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(
          color: AppColors.primary,
          width: 1.4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navigationLight,
      selectedItemColor: AppColors.navigationSelectedLight,
      unselectedItemColor: AppColors.navigationUnselectedLight,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navigationLight,
      indicatorColor: AppColors.navigationIndicatorLight,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: AppColors.navigationSelectedLight,
          );
        }

        return const IconThemeData(
          color: AppColors.navigationUnselectedLight,
        );
      }),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AppColors.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.6,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.defaultFont,

    iconTheme: const IconThemeData(
      color: AppColors.accent,
    ),

    scaffoldBackgroundColor: AppColors.backgroundDark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
    ),

    appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    foregroundColor: AppColors.textPrimaryDark,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
    fontFamily: AppFonts.defaultFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryDark,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.secondary,
    decorationThickness: 0.5,
    decorationStyle: TextDecorationStyle.solid,
  ),
),

    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: Colors.black.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.accent,
      textColor: AppColors.textPrimaryDark,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 15,
        height: 1.35,
        color: AppColors.textSecondaryDark,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 15,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(
          color: AppColors.secondary,
          width: 1.4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navigationDark,
      selectedItemColor: AppColors.navigationSelectedDark,
      unselectedItemColor: AppColors.navigationUnselectedDark,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navigationDark,
      indicatorColor: AppColors.navigationIndicatorDark,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: AppColors.navigationSelectedDark,
          );
        }

        return const IconThemeData(
          color: AppColors.navigationUnselectedDark,
        );
      }),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AppColors.borderDark,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AppColors.secondary,
          width: 1.6,
        ),
      ),
    ),
  );
}