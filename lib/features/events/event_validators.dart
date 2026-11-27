import '../../core/utils/validators.dart';

/// Валідація полів форм подій, гостей і завдань.
abstract final class EventValidators {
  static const int maxTitleLength = 60;

  static String? title(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Введіть назву події';
    if (trimmed.length < 3) return 'Назва має містити щонайменше 3 символи';
    if (trimmed.length > maxTitleLength) {
      return 'Назва не може бути довшою за $maxTitleLength символів';
    }
    return null;
  }

  static String? location(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Вкажіть місце проведення';
    return null;
  }

  static String? maxGuests(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null) return 'Введіть число';
    if (number < 1 || number > 500) return 'Від 1 до 500 гостей';
    return null;
  }

  /// Обкладинка необов'язкова, але якщо задана — лише HTTPS.
  static String? coverUrl(String? value) {
    if ((value?.trim() ?? '').isEmpty) return null;
    return Validators.httpsUrl(value);
  }

  static String? taskTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Введіть назву завдання';
    if (trimmed.length < 3) return 'Щонайменше 3 символи';
    return null;
  }

  /// Контакт гостя необов'язковий: email або телефон.
  static String? contact(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (trimmed.contains('@')) {
      // «@nickname» (Telegram) теж допускається.
      if (trimmed.startsWith('@')) return null;
      return Validators.email(trimmed);
    }
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return 'Вкажіть email або телефон';
    return null;
  }
}
