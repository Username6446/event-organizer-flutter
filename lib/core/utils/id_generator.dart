/// Генерує унікальні ідентифікатори для нових об'єктів (подій, гостей,
/// завдань). Поки дані зберігаються локально, цього достатньо;
/// у Firestore ідентифікатори призначатиме база.
abstract final class IdGenerator {
  static int _counter = 0;

  /// Наприклад: `guest-1763650000000-3`.
  static String next(String prefix) {
    _counter++;
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}-$_counter';
  }
}
