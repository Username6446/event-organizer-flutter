import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/bloc/auth_session_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/events/bloc/events_bloc.dart';
import 'features/events/data/event_repository.dart';
import 'features/settings/bloc/settings_cubit.dart';
import 'features/settings/data/settings_repository.dart';

/// Кореневий віджет застосунку «Eventory — органайзер невеликих подій».
///
/// Репозиторії надаються через [MultiRepositoryProvider], менеджери стану —
/// через [MultiBlocProvider]. Обидва розміщені над [MaterialApp], тому
/// доступні на всіх екранах, зокрема відкритих через Navigator.push.
class EventOrganizerApp extends StatelessWidget {
  const EventOrganizerApp({
    super.key,
    required this.authRepository,
    required this.eventRepository,
    required this.settingsRepository,
    required this.analytics,
  });

  final AuthRepository authRepository;
  final EventRepository eventRepository;
  final SettingsRepository settingsRepository;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<EventRepository>.value(value: eventRepository),
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
        RepositoryProvider<AnalyticsService>.value(value: analytics),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthSessionCubit(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                SettingsCubit(context.read<SettingsRepository>()),
          ),
          BlocProvider(
            create: (context) => EventsBloc(context.read<EventRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Eventory — органайзер подій',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          // Українська локалізація стандартних віджетів (календар, час).
          locale: const Locale('uk'),
          supportedLocales: const [Locale('uk')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          // FirebaseAnalyticsObserver логує перегляди іменованих маршрутів.
          navigatorObservers: analytics.navigatorObservers,
          // Стартовий екран залежить від стану автентифікації.
          home: const AuthGate(),
        ),
      ),
    );
  }
}
