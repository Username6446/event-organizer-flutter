import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar.dart';
import '../../models/app_user.dart';
import '../auth/bloc/auth_session_cubit.dart';
import '../auth/data/auth_failure.dart';
import '../auth/data/auth_repository.dart';
import '../events/bloc/events_bloc.dart';
import '../events/event_navigation.dart';
import '../events/events_screen.dart';
import '../guests/guests_screen.dart';
import '../home/home_screen.dart';
import '../profile/bloc/profile_cubit.dart';
import '../profile/profile_screen.dart';
import '../tasks/tasks_screen.dart';

/// Пункт навігації (іконка, активна іконка, підпис).
class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label, this.screenName);

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Назва екрана для Firebase Analytics (screen_view).
  final String screenName;
}

/// Головна оболонка після входу.
///
/// Адаптивна навігація (НФВ):
/// ширина ≥ 600 px — бічна панель NavigationRail (як у макеті),
/// менше — нижня панель NavigationBar.
///
/// Під час створення оболонка надсилає [EventsLoadRequested], а
/// BlocListener показує повідомлення [EventsBloc] (створено, видалено,
/// помилка збереження) на будь-якому екрані.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user});

  /// Авторизований користувач (оновлюється через AuthSessionCubit).
  final AppUser user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _eventsIndex = 1;
  static const int _profileIndex = 4;

  static const List<_NavItem> _items = [
    _NavItem(Icons.home, Icons.home, 'Головна', 'home'),
    _NavItem(Icons.event, Icons.event, 'Події', 'events'),
    _NavItem(Icons.people, Icons.people, 'Гості', 'guests'),
    _NavItem(Icons.task_alt, Icons.task_alt, 'Завдання', 'tasks'),
    _NavItem(Icons.person, Icons.person, 'Профіль', 'profile'),
  ];

  int _selectedIndex = 0;

  AnalyticsService get _analytics => context.read<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView(_items[_selectedIndex].screenName);
    // Завантаження спискових даних для нового користувача.
    context.read<EventsBloc>().add(const EventsLoadRequested());
  }

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    // Вкладки не є маршрутами Navigator, тому screen_view логуємо вручну.
    _analytics.logScreenView(_items[index].screenName);
  }

  void _createEvent() => openEventForm(context);

  /// Вихід: після signOut() AuthGate сам покаже екран входу.
  Future<void> _logout() async {
    try {
      await context.read<AuthSessionCubit>().signOut();
    } on AuthFailure catch (failure) {
      if (mounted) showAppSnackBar(context, failure.message);
    }
  }

  List<Widget> get _pages => [
    HomeScreen(
      user: widget.user,
      onOpenProfile: () => _select(_profileIndex),
      onOpenEvents: () => _select(_eventsIndex),
      onCreateEvent: _createEvent,
    ),
    EventsScreen(onCreateEvent: _createEvent),
    const GuestsScreen(),
    const TasksScreen(),
    ProfileScreen(onLogout: _logout),
  ];

  @override
  Widget build(BuildContext context) {
    // ProfileCubit живе стільки ж, скільки оболонка поточного користувача.
    return BlocProvider(
      create: (context) => ProfileCubit(
        repository: context.read<AuthRepository>(),
        initialUser: widget.user,
      ),
      child: BlocListener<EventsBloc, EventsState>(
        listenWhen: (previous, current) =>
            previous.messageId != current.messageId && current.message != null,
        listener: (context, state) => showAppSnackBar(context, state.message!),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= AppBreakpoints.compact;
            final body = IndexedStack(index: _selectedIndex, children: _pages);

            if (useRail) {
              return Scaffold(
                body: Row(
                  children: [
                    _buildRail(),
                    Expanded(child: body),
                  ],
                ),
              );
            }

            return Scaffold(
              body: SafeArea(child: body),
              floatingActionButton: _selectedIndex == _profileIndex
                  ? null
                  : FloatingActionButton(
                      onPressed: _createEvent,
                      tooltip: 'Створити подію',
                      child: const Icon(Icons.add),
                    ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _select,
                destinations: [
                  for (final item in _items)
                    NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Бічна панель: меню, кнопка «+», розділи, «Вийти» внизу.
  Widget _buildRail() {
    return Container(
      width: 88,
      color: AppColors.surfaceContainer,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.m),
            IconButton(
              tooltip: 'Меню',
              icon: const Icon(Icons.menu),
              onPressed: () => showAppSnackBar(context, 'Меню'),
            ),
            const SizedBox(height: AppSpacing.s),
            FloatingActionButton(
              heroTag: 'rail-fab',
              elevation: 2,
              tooltip: 'Створити подію',
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              onPressed: _createEvent,
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: AppSpacing.l),
            Expanded(
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                groupAlignment: -1,
                minWidth: 88,
                destinations: [
                  for (final item in _items)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    ),
                ],
              ),
            ),
            _RailAction(icon: Icons.logout, label: 'Вийти', onTap: _logout),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}

/// Кнопка в нижній частині бічної панелі («Вийти»).
class _RailAction extends StatelessWidget {
  const _RailAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.l),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
