import '../../../models/event_model.dart';

/// Порядок сортування списку подій.
enum EventSort {
  dateAsc('Спочатку найближчі'),
  dateDesc('Спочатку пізніші'),
  title('За назвою'),
  guests('За кількістю гостей');

  const EventSort(this.label);

  final String label;
}

/// Налаштування користувача, які зберігаються на пристрої
/// (SharedPreferences) і відновлюються після перезапуску застосунку.
class AppSettings {
  const AppSettings({
    this.eventSort = EventSort.dateAsc,
    this.statusFilter,
    this.gridView = true,
    this.emailNotifications = true,
    this.taskReminders = true,
  });

  /// Сортування на вкладці «Події».
  final EventSort eventSort;

  /// Фільтр за статусом на вкладці «Події»; null — усі події.
  final EventStatus? statusFilter;

  /// true — сітка карток, false — компактний список.
  final bool gridView;

  /// Сповіщення на email про відповіді гостей.
  final bool emailNotifications;

  /// Нагадування про дедлайни завдань.
  final bool taskReminders;

  AppSettings copyWith({
    EventSort? eventSort,
    EventStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? gridView,
    bool? emailNotifications,
    bool? taskReminders,
  }) {
    return AppSettings(
      eventSort: eventSort ?? this.eventSort,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      gridView: gridView ?? this.gridView,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      taskReminders: taskReminders ?? this.taskReminders,
    );
  }
}
