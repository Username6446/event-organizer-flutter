part of 'events_bloc.dart';

/// Етап завантаження списку подій.
enum EventsStatus { initial, loading, success, failure }

/// Пара «подія — гість» для загального списку гостей.
typedef GuestEntry = ({EventModel event, GuestModel guest});

/// Пара «подія — завдання» для загального списку завдань.
typedef TaskEntry = ({EventModel event, TaskModel task});

/// Стан (State) [EventsBloc].
///
/// [message] — одноразове повідомлення для SnackBar («Подію створено»).
/// [messageId] збільшується з кожним новим повідомленням, щоб BlocListener
/// показав його навіть тоді, коли текст повторюється.
class EventsState {
  const EventsState({
    this.status = EventsStatus.initial,
    this.events = const [],
    this.errorMessage,
    this.message,
    this.messageId = 0,
  });

  final EventsStatus status;
  final List<EventModel> events;

  /// Причина невдалого завантаження списку.
  final String? errorMessage;

  final String? message;
  final int messageId;

  bool get isLoading =>
      status == EventsStatus.initial || status == EventsStatus.loading;

  EventModel? eventById(String id) {
    for (final event in events) {
      if (event.id == id) return event;
    }
    return null;
  }

  /// Усі гості з усіх подій.
  List<GuestEntry> get allGuests => [
    for (final event in events)
      for (final guest in event.guests) (event: event, guest: guest),
  ];

  /// Усі завдання з усіх подій.
  List<TaskEntry> get allTasks => [
    for (final event in events)
      for (final task in event.tasks) (event: event, task: task),
  ];

  EventsState copyWith({
    EventsStatus? status,
    List<EventModel>? events,
    String? errorMessage,
  }) {
    return EventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message,
      messageId: messageId,
    );
  }

  /// Новий стан з одноразовим повідомленням для користувача.
  EventsState withMessage(String text) {
    return EventsState(
      status: status,
      events: events,
      errorMessage: errorMessage,
      message: text,
      messageId: messageId + 1,
    );
  }
}
