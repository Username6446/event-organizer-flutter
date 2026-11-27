part of 'profile_cubit.dart';

/// Етап роботи з профілем.
enum ProfileStatus { ready, saving, saved, failure }

/// Стан профілю: актуальні дані користувача та результат збереження.
class ProfileState {
  const ProfileState({
    required this.user,
    this.status = ProfileStatus.ready,
    this.failure,
    this.passwordChanged = false,
  });

  /// Збережені дані профілю (з Firebase Authentication).
  final AppUser user;

  final ProfileStatus status;

  /// Помилка останнього збереження (для status == failure).
  final AuthFailure? failure;

  /// Останнє збереження змінило пароль (щоб очистити поля пароля).
  final bool passwordChanged;

  bool get isSaving => status == ProfileStatus.saving;

  ProfileState copyWith({
    AppUser? user,
    ProfileStatus? status,
    AuthFailure? failure,
    bool? passwordChanged,
  }) {
    return ProfileState(
      user: user ?? this.user,
      status: status ?? this.status,
      failure: failure,
      passwordChanged: passwordChanged ?? this.passwordChanged,
    );
  }
}
