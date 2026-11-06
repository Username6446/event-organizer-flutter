/// Налаштування, що передаються під час збирання.
///
/// Значення беруться з `--dart-define-from-file=env.json`
/// (файл не комітиться, шаблон — `env.example.json`).
abstract final class AppConfig {
  /// DSN проєкту Sentry. Якщо порожній — Sentry вимкнено.
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get isSentryEnabled => sentryDsn.isNotEmpty;
}
