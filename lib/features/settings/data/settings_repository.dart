import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/event_model.dart';
import 'app_settings.dart';

/// Локальне сховище налаштувань на основі SharedPreferences.
///
/// На Web значення потрапляють у localStorage браузера (ключі з
/// префіксом `flutter.`), тож переживають оновлення сторінки й
/// перезапуск застосунку. Зберігаються лише прості типи: рядки та булеві.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String eventSortKey = 'events_sort';
  static const String statusFilterKey = 'events_status_filter';
  static const String gridViewKey = 'events_grid_view';
  static const String emailNotificationsKey = 'email_notifications';
  static const String taskRemindersKey = 'task_reminders';
  static const String rememberedEmailKey = 'remembered_email';

  /// Створює репозиторій (SharedPreferences ініціалізується асинхронно).
  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  /// Зчитує всі налаштування. Відсутні значення замінюються типовими.
  AppSettings load() {
    const defaults = AppSettings();
    final sortName = _prefs.getString(eventSortKey);
    final statusName = _prefs.getString(statusFilterKey);

    return AppSettings(
      eventSort: EventSort.values.asNameMap()[sortName] ?? defaults.eventSort,
      statusFilter: EventStatus.values.asNameMap()[statusName],
      gridView: _prefs.getBool(gridViewKey) ?? defaults.gridView,
      emailNotifications:
          _prefs.getBool(emailNotificationsKey) ?? defaults.emailNotifications,
      taskReminders: _prefs.getBool(taskRemindersKey) ?? defaults.taskReminders,
    );
  }

  Future<void> saveEventSort(EventSort sort) =>
      _prefs.setString(eventSortKey, sort.name);

  /// null — фільтр знято, ключ видаляється.
  Future<void> saveStatusFilter(EventStatus? status) => status == null
      ? _prefs.remove(statusFilterKey)
      : _prefs.setString(statusFilterKey, status.name);

  Future<void> saveGridView(bool value) => _prefs.setBool(gridViewKey, value);

  Future<void> saveEmailNotifications(bool value) =>
      _prefs.setBool(emailNotificationsKey, value);

  Future<void> saveTaskReminders(bool value) =>
      _prefs.setBool(taskRemindersKey, value);

  /// Email, який підставляється на екрані входу («Запам'ятати мене»).
  String? get rememberedEmail => _prefs.getString(rememberedEmailKey);

  Future<void> saveRememberedEmail(String? email) => email == null
      ? _prefs.remove(rememberedEmailKey)
      : _prefs.setString(rememberedEmailKey, email);
}
