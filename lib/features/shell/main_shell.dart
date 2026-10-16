import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar.dart';
import '../auth/auth_screen.dart';
import '../home/home_screen.dart';
import '../placeholder/placeholder_screen.dart';
import '../profile/profile_screen.dart';

/// Пункт навігації (іконка, активна іконка, підпис).
class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Головна оболонка після входу.
///
/// Адаптивна навігація (НФВ):
/// ширина ≥ 600 px — бічна панель NavigationRail (як у макеті),
/// менше — нижня панель NavigationBar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _profileIndex = 4;

  static const List<_NavItem> _items = [
    _NavItem(Icons.home, Icons.home, 'Головна'),
    _NavItem(Icons.event, Icons.event, 'Події'),
    _NavItem(Icons.people, Icons.people, 'Гості'),
    _NavItem(Icons.task_alt, Icons.task_alt, 'Завдання'),
    _NavItem(Icons.person, Icons.person, 'Профіль'),
  ];

  int _selectedIndex = 0;

  void _select(int index) => setState(() => _selectedIndex = index);

  void _createEvent() {
    showAppSnackBar(
      context,
      'Створення події буде реалізовано в наступній лабораторній роботі',
    );
  }

  /// Вихід: прибираємо всі екрани зі стеку й повертаємося на вхід.
  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  List<Widget> get _pages => [
        HomeScreen(
          onOpenProfile: () => _select(_profileIndex),
          onCreateEvent: _createEvent,
        ),
        const PlaceholderScreen(title: 'Події', icon: Icons.event),
        const PlaceholderScreen(title: 'Гості', icon: Icons.people),
        const PlaceholderScreen(title: 'Завдання', icon: Icons.task_alt),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
          floatingActionButton: FloatingActionButton(
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
            _RailAction(
              icon: Icons.logout,
              label: 'Вийти',
              onTap: _logout,
            ),
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
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
