import 'package:flutter_test/flutter_test.dart';

import 'package:event_organizer/core/utils/validators.dart';

void main() {
  group('Validators.name', () {
    test("порожнє ім'я — помилка", () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('   '), isNotNull);
    });

    test("коректне ім'я", () {
      expect(Validators.name('Олена Коваль'), isNull);
    });
  });

  group('Validators.email', () {
    test('порожній email — помилка', () {
      expect(Validators.email(''), 'Введіть електронну пошту');
    });

    test('неправильний формат — помилка', () {
      expect(Validators.email('olena'), isNotNull);
      expect(Validators.email('olena@gmail'), isNotNull);
      expect(Validators.email('olena @gmail.com'), isNotNull);
    });

    test('коректний email (з пробілами по краях)', () {
      expect(Validators.email(' olena.koval@gmail.com '), isNull);
    });
  });

  group('Validators.newPassword', () {
    test('короткий пароль — помилка', () {
      expect(Validators.newPassword('abc12'), isNotNull);
    });

    test('без цифр або без літер — помилка', () {
      expect(Validators.newPassword('abcdefgh'), isNotNull);
      expect(Validators.newPassword('12345678'), isNotNull);
    });

    test('надійний пароль', () {
      expect(Validators.newPassword('пароль2026'), isNull);
      expect(Validators.newPassword('password1'), isNull);
    });
  });

  test('Validators.confirmPassword порівнює з першим полем', () {
    final validator = Validators.confirmPassword(() => 'password1');
    expect(validator('password1'), isNull);
    expect(validator('password2'), 'Паролі не збігаються');
    expect(validator(''), isNotNull);
  });

  test('Validators.httpsUrl приймає лише https', () {
    expect(Validators.httpsUrl('https://example.com/a.png'), isNull);
    expect(Validators.httpsUrl('http://example.com/a.png'), isNotNull);
    expect(Validators.httpsUrl('example.com/a.png'), isNotNull);
    expect(Validators.httpsUrl(''), isNotNull);
  });
}
