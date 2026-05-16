import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_spacing.dart';

/// Globálny theme aplikácie.
class AppTheme {
  static Color splashBackground(Brightness brightness) {
    return AppColors.splashBackground;
  }

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      card: AppColors.cardLight,
      textPrimary: AppColors.textPrimaryLight,
      textSecondary: AppColors.textSecondaryLight,
      appBarBackground: AppColors.backgroundLight,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      card: AppColors.cardDark,
      textPrimary: AppColors.textPrimaryDark,
      textSecondary: AppColors.textSecondaryDark,
      appBarBackground: AppColors.backgroundDark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
    required Color appBarBackground,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      surface: surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppFonts.defaultFont,
      scaffoldBackgroundColor: background,
      iconTheme: const IconThemeData(color: AppColors.primary),

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: textPrimary,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.screenTitle,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          decoration: TextDecoration.none,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.screenTitle,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.sectionTitle,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.cardTitle,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.body,
          fontWeight: FontWeight.w400,
          height: AppFonts.lineHeight,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.body,
          fontWeight: FontWeight.w400,
          height: AppFonts.lineHeight,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.bodySmall,
          fontWeight: FontWeight.w400,
          height: AppFonts.lineHeight,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.button,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: textPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.listTileVerticalPadding,
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.cardTitle,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.body,
          fontWeight: FontWeight.w400,
          height: AppFonts.lineHeight,
          color: textSecondary,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.14),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : textSecondary,
            size: selected ? 26 : 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: AppFonts.defaultFont,
            fontSize: AppFonts.navigationLabel,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? AppColors.primary : textSecondary,
          );
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: const TextStyle(
            fontFamily: AppFonts.defaultFont,
            fontSize: AppFonts.button,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontalPadding,
            vertical: AppSpacing.buttonVerticalPadding,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: const TextStyle(
            fontFamily: AppFonts.defaultFont,
            fontSize: AppFonts.button,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontalPadding,
            vertical: AppSpacing.buttonVerticalPadding,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          textStyle: const TextStyle(
            fontFamily: AppFonts.defaultFont,
            fontSize: AppFonts.button,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontalPadding,
            vertical: AppSpacing.buttonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: AppFonts.defaultFont,
            fontSize: AppFonts.button,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        extendedTextStyle: const TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.button,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.inputVerticalPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? AppColors.surfaceLight
            : AppColors.surfaceDark,
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.defaultFont,
          fontSize: AppFonts.body,
          color: brightness == Brightness.dark
              ? AppColors.textPrimaryLight
              : AppColors.textPrimaryDark,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.20),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
