import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/analytics_service.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/events/data/in_memory_event_repository.dart';
import 'features/settings/data/settings_repository.dart';
import 'firebase_options.dart';

/// Точка входу в програму.
///
/// Якщо задано SENTRY_DSN (`--dart-define-from-file=env.json`), застосунок
/// запускається всередині SentryFlutter.init. Sentry сам підключає
/// FlutterError.onError (помилки фреймворку) і PlatformDispatcher.onError
/// (неперехоплені асинхронні помилки) — аналог налаштування Crashlytics.
Future<void> main() async {
  if (!AppConfig.isSentryEnabled) {
    await _runApp();
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = AppConfig.sentryDsn;
    options.environment = kReleaseMode ? 'production' : 'development';
    options.sendDefaultPii = false;
  }, appRunner: _runApp);
}

Future<void> _runApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final analytics = AnalyticsService(FirebaseAnalytics.instance);
  final authRepository = FirebaseAuthRepository(analytics: analytics);
  // Локальне сховище налаштувань (SharedPreferences → localStorage на Web).
  final settingsRepository = await SettingsRepository.create();
  // Поки що дані подій зберігаються в пам'яті (Firestore — у лабораторній №6).
  final eventRepository = InMemoryEventRepository();

  final Widget app = EventOrganizerApp(
    authRepository: authRepository,
    eventRepository: eventRepository,
    settingsRepository: settingsRepository,
    analytics: analytics,
  );

  runApp(AppConfig.isSentryEnabled ? SentryWidget(child: app) : app);
}
