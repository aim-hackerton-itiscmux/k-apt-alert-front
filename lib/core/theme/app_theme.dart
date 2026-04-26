import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF006565);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryFixedVariant = Color(0xFF004F4F);

  static const Color background = Color(0xFFF6FAF9);
  static const Color surface = Color(0xFFF6FAF9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F4F3);
  static const Color surfaceContainer = Color(0xFFEBEFEE);
  static const Color surfaceContainerHigh = Color(0xFFE5E9E8);

  static const Color onSurface = Color(0xFF181C1C);
  static const Color onSurfaceVariant = Color(0xFF3E4949);
  static const Color outline = Color(0xFF6E7979);
  static const Color outlineVariant = Color(0xFFBDC9C8);

  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color tertiaryContainer = Color(0xFFCCA830);
  static const Color onTertiaryContainer = Color(0xFF4F3E00);

  static const Color secondaryContainer = Color(0xFF90C9FF);
  static const Color onSecondaryContainer = Color(0xFF035584);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryFixedVariant,
      secondary: Color(0xFF206393),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: Color(0xFF735C00),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: Color(0xFFDFE3E2),
      inverseSurface: Color(0xFF2C3131),
      onInverseSurface: Color(0xFFEDF2F1),
      inversePrimary: Color(0xFF76D6D5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAF9F6),
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        hintStyle: const TextStyle(color: AppColors.outline),
        prefixIconColor: AppColors.outline,
      ),
    );
  }
}
