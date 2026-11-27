import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/event_model.dart';
import '../data/app_settings.dart';
import '../data/settings_repository.dart';

/// Керує налаштуваннями користувача (Cubit — спрощений BLoC без подій).
///
/// Початковий стан зчитується із SharedPreferences, а кожна зміна одразу
/// показується в інтерфейсі (emit) і зберігається на пристрої.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(SettingsRepository repository)
    : _repository = repository,
      super(repository.load());

  final SettingsRepository _repository;

  Future<void> setEventSort(EventSort sort) async {
    emit(state.copyWith(eventSort: sort));
    await _repository.saveEventSort(sort);
  }

  /// null — показати події з усіма статусами.
  Future<void> setStatusFilter(EventStatus? status) async {
    emit(
      status == null
          ? state.copyWith(clearStatusFilter: true)
          : state.copyWith(statusFilter: status),
    );
    await _repository.saveStatusFilter(status);
  }

  Future<void> setGridView(bool value) async {
    emit(state.copyWith(gridView: value));
    await _repository.saveGridView(value);
  }

  Future<void> setEmailNotifications(bool value) async {
    emit(state.copyWith(emailNotifications: value));
    await _repository.saveEmailNotifications(value);
  }

  Future<void> setTaskReminders(bool value) async {
    emit(state.copyWith(taskReminders: value));
    await _repository.saveTaskReminders(value);
  }
}
