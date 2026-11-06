import 'package:flutter/widgets.dart';

/// Локальна валідація полів форм (до надсилання запиту в Firebase).
///
/// Кожен метод повертає текст помилки або null, якщо значення коректне —
/// саме такий контракт очікує `TextFormField.validator`.
abstract final class Validators {
  static const int minPasswordLength = 8;

  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return "Введіть ім'я";
    if (trimmed.length < 2) return "Ім'я має містити щонайменше 2 символи";
    if (trimmed.length > 50) return "Ім'я не може бути довшим за 50 символів";
    return null;
  }

  /// Прізвище необов'язкове, але обмежене за довжиною.
  static String? lastName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > 50) return 'Прізвище не може бути довшим за 50 символів';
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Введіть електронну пошту';
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Некоректний формат email, наприклад name@example.com';
    }
    return null;
  }

  /// Пароль під час входу: лише перевірка, що поле не порожнє.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Введіть пароль';
    return null;
  }

  /// Новий пароль: довжина, літери та цифри.
  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Введіть пароль';
    if (password.length < minPasswordLength) {
      return 'Пароль має містити щонайменше $minPasswordLength символів';
    }
    final hasLetter = RegExp(r'[A-Za-zА-Яа-яІіЇїЄєҐґ]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    if (!hasLetter || !hasDigit) return 'Пароль має містити літери та цифри';
    return null;
  }

  /// Підтвердження пароля порівнюється з поточним значенням іншого поля.
  static FormFieldValidator<String> confirmPassword(
    String Function() original,
  ) {
    return (value) {
      if (value == null || value.isEmpty) return 'Повторіть пароль';
      if (value != original()) return 'Паролі не збігаються';
      return null;
    };
  }

  /// Посилання на зображення: лише HTTPS.
  static String? httpsUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Вставте посилання на зображення';
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return 'Посилання має починатися з https://';
    }
    return null;
  }
}
