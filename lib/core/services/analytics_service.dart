import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

import 'error_reporter.dart';

/// Обгортка над Firebase Analytics.
///
/// [AnalyticsService.disabled] нічого не надсилає — для тестів.
/// Помилки аналітики не повинні ламати інтерфейс, тому вони лише
/// передаються в [ErrorReporter].
class AnalyticsService {
  AnalyticsService(FirebaseAnalytics analytics) : _analytics = analytics;

  AnalyticsService.disabled() : _analytics = null;

  final FirebaseAnalytics? _analytics;

  /// Автоматично логує screen_view для іменованих маршрутів Navigator.
  late final List<NavigatorObserver> navigatorObservers = [
    if (_analytics != null) FirebaseAnalyticsObserver(analytics: _analytics),
  ];

  Future<void> logLogin() =>
      _run('login', (a) => a.logLogin(loginMethod: 'password'));

  Future<void> logSignUp() =>
      _run('sign_up', (a) => a.logSignUp(signUpMethod: 'password'));

  /// Перегляд вкладки всередині MainShell (вкладки не є маршрутами).
  Future<void> logScreenView(String screenName) =>
      _run('screen_view', (a) => a.logScreenView(screenName: screenName));

  /// Власна подія, наприклад `password_reset_requested`.
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) =>
      _run(name, (a) => a.logEvent(name: name, parameters: parameters));

  Future<void> setUserId(String? id) =>
      _run('set_user_id', (a) => a.setUserId(id: id));

  Future<void> _run(
    String action,
    Future<void> Function(FirebaseAnalytics analytics) body,
  ) async {
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await body(analytics);
    } catch (error, stackTrace) {
      await ErrorReporter.recordError(
        error,
        stackTrace,
        reason: 'analytics_$action',
      );
    }
  }
}
