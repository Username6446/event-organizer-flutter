import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/app_user.dart';
import '../data/auth_repository.dart';

/// Стан сесії: чи відомо, хто увійшов.
enum AuthSessionStatus { unknown, authenticated, unauthenticated }

class AuthSessionState {
  const AuthSessionState._(this.status, this.user);

  /// Firebase ще відновлює сесію після запуску.
  const AuthSessionState.unknown() : this._(AuthSessionStatus.unknown, null);

  const AuthSessionState.authenticated(AppUser user)
    : this._(AuthSessionStatus.authenticated, user);

  const AuthSessionState.unauthenticated()
    : this._(AuthSessionStatus.unauthenticated, null);

  final AuthSessionStatus status;

  /// Авторизований користувач; null, якщо вхід не виконано.
  final AppUser? user;
}

/// Глобальний стан автентифікації (app state).
///
/// Підписується на [AuthRepository.userChanges] і перетворює потік
/// користувача на стани, за якими AuthGate вибирає стартовий екран.
class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit(AuthRepository repository)
    : _repository = repository,
      super(const AuthSessionState.unknown()) {
    _subscription = repository.userChanges().listen(_onUserChanged);
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  void _onUserChanged(AppUser? user) {
    emit(
      user == null
          ? const AuthSessionState.unauthenticated()
          : AuthSessionState.authenticated(user),
    );
  }

  /// Вихід з акаунта. Після signOut() потік поверне null, і стан
  /// зміниться на unauthenticated. Помилки — AuthFailure.
  Future<void> signOut() => _repository.signOut();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
