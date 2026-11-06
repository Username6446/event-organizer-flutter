import 'package:flutter/material.dart';

import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/data/auth_repository.dart';

/// Кореневий віджет застосунку «Eventory — органайзер невеликих подій».
class EventOrganizerApp extends StatelessWidget {
  const EventOrganizerApp({
    super.key,
    required this.authRepository,
    required this.analytics,
  });

  final AuthRepository authRepository;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventory — органайзер подій',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // FirebaseAnalyticsObserver логує перегляди іменованих маршрутів.
      navigatorObservers: analytics.navigatorObservers,
      // Стартовий екран залежить від стану автентифікації.
      home: AuthGate(repository: authRepository, analytics: analytics),
    );
  }
}
