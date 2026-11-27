import '../../../models/event_model.dart';

/// Контракт доступу до подій (разом із гостями та завданнями).
///
/// BLoC працює лише з цим інтерфейсом, тому джерело даних можна замінити
/// (in-memory → Cloud Firestore) без змін у бізнес-логіці та інтерфейсі.
abstract interface class EventRepository {
  /// Завантажує всі події поточного користувача.
  Future<List<EventModel>> fetchEvents();

  /// Створює нову подію та повертає збережений об'єкт.
  Future<EventModel> createEvent(EventModel event);

  /// Оновлює подію (зокрема її списки гостей і завдань).
  Future<EventModel> updateEvent(EventModel event);

  /// Видаляє подію разом із прив'язаними гостями й завданнями.
  Future<void> deleteEvent(String eventId);
}

/// Помилка роботи з даними подій (текст українською для користувача).
class EventRepositoryException implements Exception {
  const EventRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'EventRepositoryException($message)';
}
