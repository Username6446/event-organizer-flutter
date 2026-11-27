import 'dart:math' as math;

/// Порівняння рядків за українським алфавітом.
///
/// Стандартний `String.compareTo` порівнює коди Unicode, а в таблиці
/// Unicode літери «І», «Ї», «Є», «Ґ» стоять раніше за «А», тому «Ірина»
/// опинялася б перед «Анастасією». Тут кожна літера отримує місце
/// в абетці; латиниця, цифри та знаки йдуть перед кирилицею.
abstract final class UaCollator {
  static const String _alphabet = 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя';

  static int compare(String a, String b) {
    final x = a.toLowerCase();
    final y = b.toLowerCase();
    final length = math.min(x.length, y.length);
    for (var i = 0; i < length; i++) {
      final diff = _rank(x[i]).compareTo(_rank(y[i]));
      if (diff != 0) return diff;
    }
    return x.length.compareTo(y.length);
  }

  static int _rank(String char) {
    final index = _alphabet.indexOf(char);
    return index == -1 ? char.codeUnitAt(0) : 0x10000 + index;
  }
}
