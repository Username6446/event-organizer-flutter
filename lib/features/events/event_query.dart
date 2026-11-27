import '../../core/utils/ua_collator.dart';
import '../../models/event_model.dart';
import '../settings/data/app_settings.dart';

/// Фільтрування, пошук і сортування списку подій (на клієнті).
abstract final class EventQuery {
  static List<EventModel> apply(
    List<EventModel> events, {
    EventStatus? status,
    EventSort sort = EventSort.dateAsc,
    String search = '',
  }) {
    final query = search.trim().toLowerCase();

    final result = events.where((event) {
      if (status != null && event.status != status) return false;
      if (query.isEmpty) return true;
      return event.title.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query) ||
          event.category.toLowerCase().contains(query);
    }).toList();

    switch (sort) {
      case EventSort.dateAsc:
        result.sort((a, b) => a.date.compareTo(b.date));
      case EventSort.dateDesc:
        result.sort((a, b) => b.date.compareTo(a.date));
      case EventSort.title:
        result.sort((a, b) => UaCollator.compare(a.title, b.title));
      case EventSort.guests:
        result.sort((a, b) => b.guestsCount.compareTo(a.guestsCount));
    }
    return result;
  }
}
