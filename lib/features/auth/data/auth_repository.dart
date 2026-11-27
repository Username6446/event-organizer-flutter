import '../../../models/app_user.dart';

/// Контракт роботи з автентифікацією.
///
/// Екрани працюють лише з цим інтерфейсом. Реалізація для Firebase —
/// `FirebaseAuthRepository`; у тестах підставляється фейкова реалізація.
/// Усі методи у разі помилки кидають `AuthFailure` з текстом українською.
abstract interface class AuthRepository {
  /// Поточний користувач або null, якщо вхід не виконано.
  AppUser? get currentUser;

  /// Потік змін користувача: вхід, вихід, оновлення профілю.
  /// Перша подія — поточний стан (зокрема відновлена сесія).
  Stream<AppUser?> userChanges();

  /// Реєстрація (ФВ 1). Після успіху користувач одразу авторизований.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Вхід (ФВ 2). [rememberMe] = false — сесія живе лише до закриття вкладки.
  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  });

  /// Надсилає лист із посиланням для скидання пароля (ФВ 3).
  Future<void> sendPasswordResetEmail({required String email});

  /// Оновлює ім'я та фото (ФВ 4). [photoUrl] = null — видалити фото.
  Future<void> updateProfile({
    required String displayName,
    required String? photoUrl,
  });

  /// Змінює пароль із попередньою повторною автентифікацією (ФВ 4).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOut();
}
