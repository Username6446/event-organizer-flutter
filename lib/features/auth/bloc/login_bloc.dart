import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/data/settings_repository.dart';
import '../data/auth_failure.dart';
import '../data/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

/// BLoC реєстрації та входу користувача (ФВ 1, ФВ 2).
///
/// UI надсилає [LoginSubmitted] або [RegisterSubmitted], BLoC викликає
/// [AuthRepository] і повертає стани Loading → Success / Error.
/// Після успішного входу з позначкою «Запам'ятати мене» email
/// зберігається на пристрої через [SettingsRepository].
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._authRepository, this._settingsRepository)
    : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final AuthRepository _authRepository;
  final SettingsRepository _settingsRepository;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      await _settingsRepository.saveRememberedEmail(
        event.rememberMe ? event.email : null,
      );
      emit(const LoginSuccess());
    } on AuthFailure catch (failure) {
      emit(LoginError(failure));
    } catch (_) {
      emit(const LoginError(AuthFailure.unknown));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      await _authRepository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(const LoginSuccess());
    } on AuthFailure catch (failure) {
      emit(LoginError(failure));
    } catch (_) {
      emit(const LoginError(AuthFailure.unknown));
    }
  }
}
