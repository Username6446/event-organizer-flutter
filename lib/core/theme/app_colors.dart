import 'package:flutter/material.dart';

/// Палітра застосунку, перенесена з макетів Figma (Material 3, фіолетова гама).
abstract final class AppColors {
  // Основні кольори
  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // Поверхні
  static const Color background = Color(0xFFFEF7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F2FA);
  static const Color surfaceContainer = Color(0xFFF3EDF7);
  static const Color surfaceContainerHigh = Color(0xFFECE6F0);

  // Контури
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Текст
  static const Color textPrimary = Color(0xFF1D1B20);
  static const Color textSecondary = Color(0xFF49454F);

  // Статуси
  static const Color success = Color(0xFF146C2E);
  static const Color successContainer = Color(0xFFC4EED0);
  static const Color warning = Color(0xFFE8A33D);
  static const Color error = Color(0xFFB3261E);
  static const Color errorContainer = Color(0xFFF9DEDC);

  // Контейнери для іконок карток статистики
  static const Color pinkContainer = Color(0xFFFFD8E4);
  static const Color onPinkContainer = Color(0xFF8C1D47);
  static const Color greenContainer = Color(0xFFC4EED0);
  static const Color onGreenContainer = Color(0xFF0F5223);
  static const Color orangeContainer = Color(0xFFFFDDB3);
  static const Color onOrangeContainer = Color(0xFF7A4A00);

  /// Фони для аватарів з ініціалами (беруться по колу).
  static const List<Color> avatarBackgrounds = [
    primaryContainer,
    pinkContainer,
    greenContainer,
    orangeContainer,
  ];

  // Градієнти
  static const List<Color> promoGradient = [
    Color(0xFF4F378B),
    Color(0xFF6B4FA8),
    Color(0xFF8E5A86),
  ];
  static const List<Color> avatarGradient = [
    Color(0xFF7B5EA7),
    Color(0xFFD0607E),
  ];

  // Градієнти шапок карток подій
  static const List<Color> gradientPurple = [Color(0xFF7B5EA7), Color(0xFFB97AA3)];
  static const List<Color> gradientTeal = [Color(0xFF0B6B6B), Color(0xFF4DB6A8)];
  static const List<Color> gradientOrange = [Color(0xFFA0501A), Color(0xFFE89A48)];
  static const List<Color> gradientBlue = [Color(0xFF3F51A5), Color(0xFF7D8FE0)];
  static const List<Color> gradientGreen = [Color(0xFF3E6E1F), Color(0xFF8BC15A)];
  static const List<Color> gradientMagenta = [Color(0xFF6A1B6A), Color(0xFFD35D7A)];
}
