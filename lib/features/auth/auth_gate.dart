import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_logo.dart';
import '../settings/data/settings_repository.dart';
import '../shell/main_shell.dart';
import 'auth_screen.dart';
import 'bloc/auth_session_cubit.dart';
import 'bloc/login_bloc.dart';
import 'data/auth_repository.dart';

/// Вибирає стартовий екран за станом [AuthSessionCubit].
///
/// Поки Firebase відновлює сесію — показує завантаження, далі — вхід або
/// головну оболонку. Вхід і вихід не потребують ручної навігації:
/// BlocBuilder перебудовує екран, щойно змінюється стан сесії.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, state) {
        final user = state.user;
        if (state.status == AuthSessionStatus.unknown) {
          return const _SplashScreen();
        }
        if (user == null) {
          // Форма входу отримує власний LoginBloc (RepositoryProvider
          // над MaterialApp передає йому залежності).
          return BlocProvider(
            create: (context) => LoginBloc(
              context.read<AuthRepository>(),
              context.read<SettingsRepository>(),
            ),
            child: const AuthScreen(),
          );
        }
        return MainShell(
          // Новий користувач — новий стан оболонки (вкладка, форми).
          key: ValueKey(user.uid),
          user: user,
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
