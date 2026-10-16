/// Відступи застосунку. Усі значення кратні 4/8 (НФВ щодо єдиної сітки).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double sm = 12;
  static const double m = 16;
  static const double ml = 20;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Радіуси заокруглення.
abstract final class AppRadius {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 28;
  static const double pill = 100;
}

/// Точки зламу для адаптивної верстки.
abstract final class AppBreakpoints {
  /// Менше цього значення — мобільний макет (нижня навігація).
  static const double compact = 600;

  /// Від цього значення показується промо-панель на екранах входу.
  static const double medium = 900;

  /// Широкий десктоп: 4 картки статистики в ряд, 3 колонки подій.
  static const double expanded = 1100;
}
