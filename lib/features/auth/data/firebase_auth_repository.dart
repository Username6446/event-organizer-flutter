import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/error_reporter.dart';
import '../../../models/app_user.dart';
import 'auth_failure.dart';
import 'auth_repository.dart';

/// Реалізація [AuthRepository] на Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required this._analytics,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final AnalyticsService _analytics;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_toAppUser);

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard('sign_up', () async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        // reload() надсилає подію в userChanges() уже з новим іменем.
        await user.reload();
        await _analytics.setUserId(user.uid);
      }
      await _analytics.logSignUp();
    });
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) {
    return _guard('sign_in', () async {
      // «Запам'ятати мене»: LOCAL — сесія переживає закриття браузера,
      // SESSION — лише до закриття вкладки. setPersistence є тільки на Web.
      if (kIsWeb) {
        await _auth.setPersistence(
          rememberMe ? Persistence.LOCAL : Persistence.SESSION,
        );
      }
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _analytics.setUserId(credential.user?.uid);
      await _analytics.logLogin();
    });
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _guard('password_reset', () async {
      await _auth.setLanguageCode('uk');
      await _auth.sendPasswordResetEmail(email: email);
      await _analytics.logEvent('password_reset_requested');
    });
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    required String? photoUrl,
  }) {
    return _guard('update_profile', () async {
      final user = _requireUser();
      await user.updateProfile(displayName: displayName, photoURL: photoUrl);
      await user.reload();
      await _analytics.logEvent('profile_updated');
    });
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _guard('change_password', () async {
      final user = _requireUser();
      final email = user.email;
      if (email == null) throw AuthFailure.unknown;

      // Firebase вимагає «свіжого» входу для зміни пароля, тому спершу
      // повторно автентифікуємо користувача поточним паролем.
      try {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: currentPassword),
        );
      } on FirebaseAuthException catch (e) {
        final failure = AuthFailure.fromFirebase(e);
        if (failure.field == AuthField.password) {
          throw const AuthFailure(
            'Поточний пароль неправильний',
            field: AuthField.currentPassword,
          );
        }
        rethrow;
      }

      await user.updatePassword(newPassword);
      await _analytics.logEvent('password_changed');
    });
  }

  @override
  Future<void> signOut() {
    return _guard('sign_out', () async {
      await _auth.signOut();
      await _analytics.setUserId(null);
      await _analytics.logEvent('logout');
    });
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure(
        'Сесія завершилась. Увійдіть повторно',
        requiresRecentLogin: true,
      );
    }
    return user;
  }

  /// Перетворює будь-яку помилку на [AuthFailure];
  /// непередбачені помилки надсилає в Sentry як non-fatal.
  Future<void> _guard(String action, Future<void> Function() body) async {
    try {
      await body();
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (error, stackTrace) {
      final failure = AuthFailure.fromFirebase(error);
      if (failure.isUnexpected) {
        await ErrorReporter.recordError(
          error,
          stackTrace,
          reason: 'auth_$action:${error.code}',
        );
      }
      throw failure;
    } catch (error, stackTrace) {
      await ErrorReporter.recordError(error, stackTrace, reason: 'auth_$action');
      throw AuthFailure.unknown;
    }
  }

  static AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
