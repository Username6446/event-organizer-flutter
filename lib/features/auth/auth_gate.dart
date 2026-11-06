import 'package:flutter/material.dart';

import '../../core/services/analytics_service.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_logo.dart';
import '../../models/app_user.dart';
import '../shell/main_shell.dart';
import 'auth_screen.dart';
import 'data/auth_repository.dart';

/// Вибирає стартовий екран за станом автентифікації.
///
/// Підписується на [AuthRepository.userChanges]: поки Firebase відновлює
/// сесію — показує завантаження, далі — вхід або головну оболонку.
/// Вхід і вихід не потребують ручної навігації: екран змінюється сам.
class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.repository,
    required this.analytics,
  });

  final AuthRepository repository;
  final AnalyticsService analytics;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Потік створюється один раз, щоб StreamBuilder не перепідписувався
  // під час кожного build().
  late final Stream<AppUser?> _userStream = widget.repository.userChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return AuthScreen(
            repository: widget.repository,
            analytics: widget.analytics,
          );
        }

        return MainShell(
          // Новий користувач — новий стан оболонки (вкладка, форми).
          key: ValueKey(user.uid),
          user: user,
          repository: widget.repository,
          analytics: widget.analytics,
        );
      },
    );
  }
}

/// Екран відновлення сесії під час запуску.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(),
            SizedBox(height: AppSpacing.l),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
