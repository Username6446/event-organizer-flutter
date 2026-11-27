import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/event_model.dart';
import '../../../models/guest_model.dart';
import '../../../models/task_model.dart';
import '../data/event_repository.dart';

part 'events_event.dart';
part 'events_state.dart';

/// BLoC подій: завантаження списку та CRUD подій, гостей і завдань.
///
/// Отримує [EventRepository] через конструктор (Dependency Injection),
/// тому працює з інтерфейсом, а не з конкретним джерелом даних.
/// Зміни показуються одразу (оптимістичне оновлення), а якщо репозиторій
/// поверне помилку — стан відкочується і показується повідомлення.
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc(EventRepository repository)
    : _repository = repository,
      super(const EventsState()) {
    on<EventsLoadRequested>(_onLoadRequested);
    on<EventCreated>(_onEventCreated);
    on<EventUpdated>(_onEventUpdated);
    on<EventDeleted>(_onEventDeleted);
    on<GuestSaved>(_onGuestSaved);
    on<GuestStatusChanged>(_onGuestStatusChanged);
    on<GuestDeleted>(_onGuestDeleted);
    on<TaskSaved>(_onTaskSaved);
    on<TaskToggled>(_onTaskToggled);
    on<TaskDeleted>(_onTaskDeleted);
  }

  final EventRepository _repository;

  static const _saveError = 'Не вдалося зберегти зміни. Спробуйте ще раз.';

  Future<void> _onLoadRequested(
    EventsLoadRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(state.copyWith(status: EventsStatus.loading));
    try {
      final events = await _repository.fetchEvents();
      emit(state.copyWith(status: EventsStatus.success, events: events));
    } catch (_) {
      emit(
        state.copyWith(
          status: EventsStatus.failure,
          errorMessage: 'Не вдалося завантажити події. Спробуйте ще раз.',
        ),
      );
    }
  }

  Future<void> _onEventCreated(
    EventCreated event,
    Emitter<EventsState> emit,
  ) async {
    final created = event.event;
    emit(state.copyWith(events: [...state.events, created]));
    try {
      await _repository.createEvent(created);
      emit(state.withMessage('Подію «${created.title}» створено'));
    } catch (error) {
      emit(
        state
            .copyWith(events: _without(state.events, created.id))
            .withMessage(_errorText(error)),
      );
    }
  }

  Future<void> _onEventUpdated(EventUpdated event, Emitter<EventsState> emit) {
    return _changeEvent(
      event.event.id,
      (_) => event.event,
      emit,
      successMessage: 'Зміни в події збережено',
    );
  }

  Future<void> _onEventDeleted(
    EventDeleted event,
    Emitter<EventsState> emit,
  ) async {
    final deleted = state.eventById(event.eventId);
    if (deleted == null) return;

    emit(state.copyWith(events: _without(state.events, deleted.id)));
    try {
      await _repository.deleteEvent(deleted.id);
      emit(state.withMessage('Подію «${deleted.title}» видалено'));
    } catch (error) {
      emit(
        state
            .copyWith(events: [...state.events, deleted])
            .withMessage(_errorText(error)),
      );
    }
  }

  Future<void> _onGuestSaved(GuestSaved event, Emitter<EventsState> emit) {
    final guest = event.guest;
    return _changeEvent(
      event.eventId,
      (current) {
        final exists = current.guests.any((g) => g.id == guest.id);
        return current.copyWith(
          guests: exists
              ? [for (final g in current.guests) g.id == guest.id ? guest : g]
              : [...current.guests, guest],
        );
      },
      emit,
      successMessage: 'Гостя «${guest.name}» збережено',
    );
  }

  Future<void> _onGuestStatusChanged(
    GuestStatusChanged event,
    Emitter<EventsState> emit,
  ) {
    return _changeEvent(
      event.eventId,
      (current) => current.copyWith(
        guests: [
          for (final g in current.guests)
            g.id == event.guestId ? g.copyWith(status: event.status) : g,
        ],
      ),
      emit,
    );
  }

  Future<void> _onGuestDeleted(GuestDeleted event, Emitter<EventsState> emit) {
    return _changeEvent(
      event.eventId,
      (current) => current.copyWith(
        guests: current.guests.where((g) => g.id != event.guestId).toList(),
      ),
      emit,
      successMessage: 'Гостя видалено',
    );
  }

  Future<void> _onTaskSaved(TaskSaved event, Emitter<EventsState> emit) {
    final task = event.task;
    return _changeEvent(
      event.eventId,
      (current) {
        final exists = current.tasks.any((t) => t.id == task.id);
        return current.copyWith(
          tasks: exists
              ? [for (final t in current.tasks) t.id == task.id ? task : t]
              : [...current.tasks, task],
        );
      },
      emit,
      successMessage: 'Завдання збережено',
    );
  }

  Future<void> _onTaskToggled(TaskToggled event, Emitter<EventsState> emit) {
    return _changeEvent(
      event.eventId,
      (current) => current.copyWith(
        tasks: [
          for (final t in current.tasks)
            t.id == event.taskId ? t.copyWith(isCompleted: !t.isCompleted) : t,
        ],
      ),
      emit,
    );
  }

  Future<void> _onTaskDeleted(TaskDeleted event, Emitter<EventsState> emit) {
    return _changeEvent(
      event.eventId,
      (current) => current.copyWith(
        tasks: current.tasks.where((t) => t.id != event.taskId).toList(),
      ),
      emit,
      successMessage: 'Завдання видалено',
    );
  }

  /// Спільна логіка зміни однієї події: оптимістичний emit, збереження
  /// в репозиторії, відкат у разі помилки.
  Future<void> _changeEvent(
    String eventId,
    EventModel Function(EventModel current) change,
    Emitter<EventsState> emit, {
    String? successMessage,
  }) async {
    final current = state.eventById(eventId);
    if (current == null) return;

    final updated = change(current);
    emit(state.copyWith(events: _replace(state.events, updated)));
    try {
      await _repository.updateEvent(updated);
      if (successMessage != null) emit(state.withMessage(successMessage));
    } catch (error) {
      emit(
        state
            .copyWith(events: _replace(state.events, current))
            .withMessage(_errorText(error)),
      );
    }
  }

  static List<EventModel> _replace(List<EventModel> events, EventModel event) =>
      [for (final e in events) e.id == event.id ? event : e];

  static List<EventModel> _without(List<EventModel> events, String id) =>
      events.where((e) => e.id != id).toList();

  static String _errorText(Object error) =>
      error is EventRepositoryException ? error.message : _saveError;
}
