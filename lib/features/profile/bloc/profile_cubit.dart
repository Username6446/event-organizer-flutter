import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/app_user.dart';
import '../../auth/data/auth_failure.dart';
import '../../auth/data/auth_repository.dart';

part 'profile_state.dart';

/// Завантаження та редагування профілю користувача (ФВ 4).
///
/// Дані профілю надходять із потоку [AuthRepository.userChanges]:
/// після збереження імені чи фото Firebase надсилає оновленого
/// користувача, і стан оновлюється автоматично.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthRepository repository,
    required AppUser initialUser,
  }) : _repository = repository,
       super(ProfileState(user: initialUser)) {
    _subscription = repository.userChanges().listen((user) {
      // null приходить під час виходу — екран профілю тоді вже закривається.
      if (user != null) {
        emit(state.copyWith(user: user, failure: state.failure));
      }
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  /// Зберігає зміни профілю та/або пароля.
  ///
  /// [updateProfile] — чи змінилися ім'я або фото ([photoUrl] = null
  /// видаляє фото). [currentPassword] і [newPassword] передаються, лише
  /// якщо користувач заповнив блок «Зміна пароля».
  Future<void> saveChanges({
    required bool updateProfile,
    required String displayName,
    required String? photoUrl,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (state.isSaving) return;
    final changePassword = currentPassword != null && newPassword != null;

    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      if (updateProfile) {
        await _repository.updateProfile(
          displayName: displayName,
          photoUrl: photoUrl,
        );
      }
      if (currentPassword != null && newPassword != null) {
        await _repository.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      }
      emit(
        state.copyWith(
          user: _repository.currentUser,
          status: ProfileStatus.saved,
          passwordChanged: changePassword,
        ),
      );
    } on AuthFailure catch (failure) {
      emit(state.copyWith(status: ProfileStatus.failure, failure: failure));
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          failure: AuthFailure.unknown,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
