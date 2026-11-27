part of 'login_bloc.dart';

/// Стани операції входу чи реєстрації.
sealed class LoginState {
  const LoginState();
}

/// Форма ще не надсилалася.
final class LoginInitial extends LoginState {
  const LoginInitial();
}

/// Запит до Firebase виконується — кнопка показує індикатор.
final class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Вхід або реєстрація успішні. Екран змінить AuthGate.
final class LoginSuccess extends LoginState {
  const LoginSuccess();
}

/// Помилка: текст українською та поле, яке треба підсвітити.
final class LoginError extends LoginState {
  const LoginError(this.failure);

  final AuthFailure failure;
}
