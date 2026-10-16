import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';

/// Кореневий віджет застосунку «Eventory — органайзер невеликих подій».
class EventOrganizerApp extends StatelessWidget {
  const EventOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventory — органайзер подій',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Стартовий екран — авторизація. Після входу користувач
      // потрапляє на MainShell з адаптивною навігацією.
      home: const AuthScreen(),
    );
  }
}
