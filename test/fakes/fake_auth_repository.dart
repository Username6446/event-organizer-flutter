import 'dart:async';

import 'package:event_organizer/features/auth/data/auth_failure.dart';
import 'package:event_organizer/features/auth/data/auth_repository.dart';
import 'package:event_organizer/models/app_user.dart';

/// Репозиторій у пам'яті для віджет-тестів (без Firebase).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _user = initialUser;

  AppUser? _user;
  final _controller = StreamController<AppUser?>.broadcast();

  /// Якщо задано — наступний виклик кине цю помилку.
  AuthFailure? nextFailure;

  /// Журнал викликів для перевірок у тестах.
  final List<String> calls = [];

  static const validPassword = 'password123';

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> userChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  void _emit(AppUser? user) {
    _user = user;
    _controller.add(user);
  }

  void _throwIfNeeded() {
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      throw failure;
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    calls.add('signIn:$email:$rememberMe');
    _throwIfNeeded();
    if (password != validPassword) {
      throw const AuthFailure(
        'Неправильний email або пароль',
        field: AuthField.password,
      );
    }
    _emit(AppUser(uid: 'u1', email: email, displayName: 'Олена Коваль'));
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    calls.add('signUp:$name:$email');
    _throwIfNeeded();
    _emit(AppUser(uid: 'u1', email: email, displayName: name));
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    calls.add('reset:$email');
    _throwIfNeeded();
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    required String? photoUrl,
  }) async {
    calls.add('updateProfile:$displayName:$photoUrl');
    _throwIfNeeded();
    final user = _user!;
    _emit(AppUser(
      uid: user.uid,
      email: user.email,
      displayName: displayName,
      photoUrl: photoUrl,
    ));
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    calls.add('changePassword');
    _throwIfNeeded();
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _throwIfNeeded();
    _emit(null);
  }
}
