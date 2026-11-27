part of 'login_bloc.dart';

/// Події форми автентифікації.
sealed class LoginEvent {
  const LoginEvent();
}

/// Натиснуто «Увійти» (ФВ 2).
final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
    required this.rememberMe,
  });

  final String email;
  final String password;
  final bool rememberMe;
}

/// Натиснуто «Зареєструватися» (ФВ 1).
final class RegisterSubmitted extends LoginEvent {
  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}
