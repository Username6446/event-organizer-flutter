import 'package:flutter/material.dart';

/// Варіанти кнопок з дизайн-системи (Material 3).
enum AppButtonVariant {
  /// Основна дія: «Увійти», «Зберегти зміни».
  filled,

  /// Другорядна заповнена: «Змінити фото».
  tonal,

  /// Контурна: «Створити акаунт».
  outlined,

  /// Текстова: «Скасувати», «Видалити фото».
  text,
}

/// Єдина кнопка застосунку з однаковою висотою, відступами та іконкою.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.expanded = false,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;

  /// Розтягнути кнопку на всю ширину батьківського віджета.
  final bool expanded;

  /// Колір тексту/іконки (наприклад, червоний для «Видалити»).
  final Color? foregroundColor;

  ButtonStyle get _style => ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(64, 40)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24),
        ),
        foregroundColor: foregroundColor == null
            ? null
            : WidgetStatePropertyAll(foregroundColor),
      );

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon == null ? null : Icon(icon, size: 18);
    final text = Text(label);

    final Widget button = switch (variant) {
      AppButtonVariant.filled => iconWidget == null
          ? FilledButton(onPressed: onPressed, style: _style, child: text)
          : FilledButton.icon(
              onPressed: onPressed,
              style: _style,
              icon: iconWidget,
              label: text,
            ),
      AppButtonVariant.tonal => iconWidget == null
          ? FilledButton.tonal(onPressed: onPressed, style: _style, child: text)
          : FilledButton.tonalIcon(
              onPressed: onPressed,
              style: _style,
              icon: iconWidget,
              label: text,
            ),
      AppButtonVariant.outlined => iconWidget == null
          ? OutlinedButton(onPressed: onPressed, style: _style, child: text)
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: _style,
              icon: iconWidget,
              label: text,
            ),
      AppButtonVariant.text => iconWidget == null
          ? TextButton(onPressed: onPressed, style: _style, child: text)
          : TextButton.icon(
              onPressed: onPressed,
              style: _style,
              icon: iconWidget,
              label: text,
            ),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
