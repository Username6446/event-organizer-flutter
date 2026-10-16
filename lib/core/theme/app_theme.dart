import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Глобальна тема застосунку (Material 3).
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      surface: AppColors.background,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      // Локальний Roboto з assets/fonts (див. pubspec.yaml).
      fontFamily: 'AppRoboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
