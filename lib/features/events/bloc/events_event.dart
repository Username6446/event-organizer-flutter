part of 'events_bloc.dart';

/// Події (Event) для [EventsBloc]: дії користувача над подіями,
/// гостями та завданнями.
sealed class EventsEvent {
  const EventsEvent();
}

/// Завантажити список подій із репозиторію.
final class EventsLoadRequested extends EventsEvent {
  const EventsLoadRequested();
}

/// Створити нову подію (ФВ 6).
final class EventCreated extends EventsEvent {
  const EventCreated(this.event);

  final EventModel event;
}

/// Зберегти зміни параметрів події (ФВ 6).
final class EventUpdated extends EventsEvent {
  const EventUpdated(this.event);

  final EventModel event;
}

/// Видалити подію разом із гостями та завданнями (ФВ 6).
final class EventDeleted extends EventsEvent {
  const EventDeleted(this.eventId);

  final String eventId;
}

/// Додати нового або оновити наявного гостя (ФВ 7).
final class GuestSaved extends EventsEvent {
  const GuestSaved(this.eventId, this.guest);

  final String eventId;
  final GuestModel guest;
}

/// Змінити статус відповіді гостя (ФВ 7).
final class GuestStatusChanged extends EventsEvent {
  const GuestStatusChanged(this.eventId, this.guestId, this.status);

  final String eventId;
  final String guestId;
  final GuestStatus status;
}

/// Видалити гостя з події (ФВ 7).
final class GuestDeleted extends EventsEvent {
  const GuestDeleted(this.eventId, this.guestId);

  final String eventId;
  final String guestId;
}

/// Додати нове або оновити наявне завдання (ФВ 8).
final class TaskSaved extends EventsEvent {
  const TaskSaved(this.eventId, this.task);

  final String eventId;
  final TaskModel task;
}

/// Позначити завдання виконаним / невиконаним (ФВ 8).
final class TaskToggled extends EventsEvent {
  const TaskToggled(this.eventId, this.taskId);

  final String eventId;
  final String taskId;
}

/// Видалити завдання (ФВ 8).
final class TaskDeleted extends EventsEvent {
  const TaskDeleted(this.eventId, this.taskId);

  final String eventId;
  final String taskId;
}
