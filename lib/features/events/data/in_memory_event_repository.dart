import '../../../core/data/mock_data.dart';
import '../../../models/event_model.dart';
import 'event_repository.dart';

/// Реалізація [EventRepository], що зберігає дані в оперативній пам'яті.
///
/// Стартовий вміст — захардкоджені дані [MockData]. Затримка [latency]
/// імітує запит до сервера, щоб в інтерфейсі було видно стан завантаження
/// (у тестах передається Duration.zero).
class InMemoryEventRepository implements EventRepository {
  InMemoryEventRepository({
    List<EventModel>? initialEvents,
    this.latency = const Duration(milliseconds: 600),
  }) : _events = List.of(initialEvents ?? MockData.events);

  final Duration latency;
  final List<EventModel> _events;

  Future<void> _delay() => Future<void>.delayed(latency);

  @override
  Future<List<EventModel>> fetchEvents() async {
    await _delay();
    return List.unmodifiable(_events);
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    await _delay();
    _events.add(event);
    return event;
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    await _delay();
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      throw const EventRepositoryException('Подію не знайдено');
    }
    _events[index] = event;
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _delay();
    _events.removeWhere((e) => e.id == eventId);
  }
}
