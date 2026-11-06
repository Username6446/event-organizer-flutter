import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_config.dart';

/// Надсилання некритичних (non-fatal) помилок у Sentry.
///
/// Аналог `FirebaseCrashlytics.instance.recordError(..., fatal: false)`:
/// Crashlytics не підтримує Web, тому використовується Sentry.
/// Фатальні помилки (FlutterError.onError, PlatformDispatcher.onError)
/// Sentry перехоплює сам після `SentryFlutter.init`.
abstract final class ErrorReporter {
  static Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    debugPrint('Помилка${reason == null ? '' : ' ($reason)'}: $error');
    if (!AppConfig.isSentryEnabled) return;

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: reason == null
          ? null
          : (scope) => scope.setTag('reason', reason),
    );
  }

  /// Генерує й надсилає тестову помилку (завдання 2 лабораторної).
  static Future<void> sendTestError() async {
    try {
      throw StateError('Тестова помилка Eventory для перевірки Sentry');
    } catch (error, stackTrace) {
      await recordError(error, stackTrace, reason: 'manual_test');
    }
  }
}
