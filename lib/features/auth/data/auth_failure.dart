import 'package:firebase_auth/firebase_auth.dart';

/// Поле форми, до якого належить помилка (щоб підсвітити саме його).
enum AuthField { email, password, currentPassword }

/// Помилка автентифікації з повідомленням українською.
///
/// Репозиторій перетворює [FirebaseAuthException] на [AuthFailure],
/// тож екрани не бачать технічних кодів Firebase.
class AuthFailure implements Exception {
  const AuthFailure(
    this.message, {
    this.field,
    this.requiresRecentLogin = false,
    this.isUnexpected = false,
  });

  /// Зрозумілий користувачу текст.
  final String message;

  /// Поле, яке слід підсвітити; null — загальна помилка форми.
  final AuthField? field;

  /// Firebase вимагає повторного входу (requires-recent-login).
  final bool requiresRecentLogin;

  /// Непередбачена помилка — її варто надіслати в Sentry.
  final bool isUnexpected;

  static const unknown = AuthFailure(
    'Щось пішло не так. Спробуйте ще раз.',
    isUnexpected: true,
  );

  factory AuthFailure.fromFirebase(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => const AuthFailure(
          'Некоректний формат електронної пошти',
          field: AuthField.email,
        ),
      'user-disabled' => const AuthFailure(
          'Цей обліковий запис заблоковано',
          field: AuthField.email,
        ),
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'INVALID_LOGIN_CREDENTIALS' =>
        const AuthFailure(
          'Неправильний email або пароль',
          field: AuthField.password,
        ),
      'email-already-in-use' => const AuthFailure(
          'Акаунт із таким email уже існує',
          field: AuthField.email,
        ),
      'weak-password' => const AuthFailure(
          'Пароль надто простий. Використайте щонайменше 8 символів',
          field: AuthField.password,
        ),
      'too-many-requests' => const AuthFailure(
          'Забагато спроб. Зачекайте кілька хвилин і спробуйте знову',
        ),
      'network-request-failed' => const AuthFailure(
          "Немає з'єднання з інтернетом. Перевірте мережу та спробуйте знову",
        ),
      'requires-recent-login' ||
      'user-token-expired' ||
      'user-mismatch' =>
        const AuthFailure(
          'З міркувань безпеки потрібно увійти повторно',
          requiresRecentLogin: true,
        ),
      'operation-not-allowed' => const AuthFailure(
          'Вхід через email і пароль вимкнено в налаштуваннях Firebase',
          isUnexpected: true,
        ),
      _ => unknown,
    };
  }

  @override
  String toString() => 'AuthFailure($message)';
}
