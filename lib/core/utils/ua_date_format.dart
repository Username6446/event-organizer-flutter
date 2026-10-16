/// Форматування дат українською без сторонніх пакетів (intl не підключаємо).
abstract final class UaDateFormat {
  static const List<String> _weekdays = [
    'Понеділок',
    'Вівторок',
    'Середа',
    'Четвер',
    "П'ятниця",
    'Субота',
    'Неділя',
  ];

  static const List<String> _weekdaysShort = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Нд',
  ];

  static const List<String> _monthsGenitive = [
    'січня',
    'лютого',
    'березня',
    'квітня',
    'травня',
    'червня',
    'липня',
    'серпня',
    'вересня',
    'жовтня',
    'листопада',
    'грудня',
  ];

  static const List<String> _monthsShort = [
    'СІЧ',
    'ЛЮТ',
    'БЕР',
    'КВІ',
    'ТРА',
    'ЧЕР',
    'ЛИП',
    'СЕР',
    'ВЕР',
    'ЖОВ',
    'ЛИС',
    'ГРУ',
  ];

  /// «Пʼятниця, 16 жовтня 2026»
  static String fullDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${date.day} '
      '${_monthsGenitive[date.month - 1]} ${date.year}';

  /// «Сб, 18 жовтня»
  static String shortDate(DateTime date) =>
      '${_weekdaysShort[date.weekday - 1]}, ${date.day} '
      '${_monthsGenitive[date.month - 1]}';

  /// «Сб, 18:00»
  static String weekdayTime(DateTime date) =>
      '${_weekdaysShort[date.weekday - 1]}, ${time(date)}';

  /// «18:00»
  static String time(DateTime date) =>
      '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

  /// «18»
  static String day(DateTime date) => _twoDigits(date.day);

  /// «ЖОВ»
  static String monthShort(DateTime date) => _monthsShort[date.month - 1];

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
