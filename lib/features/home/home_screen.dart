import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar.dart';
import '../../core/utils/ua_date_format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/event_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/user_avatar.dart';
import '../../models/app_user.dart';
import '../../models/dashboard_stat.dart';
import '../../models/event_model.dart';
import '../events/bloc/events_bloc.dart';
import '../events/event_navigation.dart';

/// Фільтри списку «Найближчі події».
enum _EventFilter {
  all('Усі'),
  thisMonth('Цього місяця'),
  drafts('Чернетки');

  const _EventFilter(this.label);
  final String label;
}

/// Головна сторінка — дашборд організатора (ФВ 5).
///
/// Статистика й картки найближчих подій будуються зі стану [EventsBloc]
/// (BlocBuilder), фільтр і пошук — ефемерний стан екрана.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
    this.onOpenProfile,
    this.onOpenEvents,
    this.onCreateEvent,
  });

  /// Авторизований користувач (для аватара в шапці).
  final AppUser user;

  /// Натискання на аватар у шапці відкриває профіль.
  final VoidCallback? onOpenProfile;

  /// Перехід на вкладку «Події» (кнопка «Усі події»).
  final VoidCallback? onOpenEvents;

  final VoidCallback? onCreateEvent;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _EventFilter _filter = _EventFilter.all;
  String _search = '';

  /// Заплановані події за датою з урахуванням фільтра та пошуку.
  List<EventModel> _visibleEvents(List<EventModel> events) {
    final now = DateTime.now();
    final query = _search.trim().toLowerCase();
    final upcoming =
        events
            .where((e) => e.status == EventStatus.planned)
            .where(
              (e) => query.isEmpty || e.title.toLowerCase().contains(query),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return switch (_filter) {
      _EventFilter.all => upcoming,
      _EventFilter.thisMonth =>
        upcoming
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList(),
      _EventFilter.drafts => upcoming.where((e) => e.isDraft).toList(),
    };
  }

  void _openEvent(EventModel event) => openEventDetails(context, event.id);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) => _buildDashboard(context, state),
    );
  }

  Widget _buildDashboard(BuildContext context, EventsState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.compact;
        final horizontal = isNarrow ? AppSpacing.m : AppSpacing.xl;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSpacing.l,
            horizontal,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                user: widget.user,
                showSearchInline: constraints.maxWidth >= AppBreakpoints.medium,
                onAvatarTap: widget.onOpenProfile,
                onSearchChanged: (value) => setState(() => _search = value),
              ),
              const SizedBox(height: AppSpacing.l),
              _StatsGrid(stats: _buildStats(state.events)),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionHeader(context),
              const SizedBox(height: AppSpacing.m),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _EventsGrid(
                  events: _visibleEvents(state.events),
                  onEventTap: _openEvent,
                ),
            ],
          ),
        );
      },
    );
  }

  /// Показники дашборду рахуються з поточного списку подій.
  List<DashboardStat> _buildStats(List<EventModel> events) {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    final planned = events.where((e) => e.status == EventStatus.planned);
    final thisWeek = planned
        .where((e) => e.date.isAfter(now) && e.date.isBefore(weekEnd))
        .length;
    final guests = events.fold<int>(0, (sum, e) => sum + e.guestsCount);
    final confirmed = events.fold<int>(0, (sum, e) => sum + e.confirmedCount);
    final openTasks = events.fold<int>(
      0,
      (sum, e) => sum + e.tasksTotal - e.tasksDone,
    );

    return [
      DashboardStat(
        label: 'Усього подій',
        value: '${events.length}',
        delta: '${planned.length} заплан.',
        icon: Icons.event,
        iconBackground: AppColors.primaryContainer,
        iconColor: AppColors.primary,
      ),
      DashboardStat(
        label: 'Цього тижня',
        value: '$thisWeek',
        icon: Icons.today,
        iconBackground: AppColors.pinkContainer,
        iconColor: AppColors.onPinkContainer,
      ),
      DashboardStat(
        label: 'Гостей запрошено',
        value: '$guests',
        delta: '$confirmed підтв.',
        icon: Icons.people,
        iconBackground: AppColors.greenContainer,
        iconColor: AppColors.onGreenContainer,
      ),
      DashboardStat(
        label: 'Відкриті завдання',
        value: '$openTasks',
        icon: Icons.task_alt,
        iconBackground: AppColors.orangeContainer,
        iconColor: AppColors.onOrangeContainer,
      ),
    ];
  }

  Widget _buildSectionHeader(BuildContext context) {
    // SizedBox на всю ширину, інакше Wrap «стискається» до вмісту
    // і spaceBetween не відсуває фільтри праворуч.
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.m,
        runSpacing: AppSpacing.sm,
        children: [
          Text(
            'Найближчі події',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: AppColors.textPrimary),
          ),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final filter in _EventFilter.values)
                ChoiceChip(
                  label: Text(filter.label),
                  selected: _filter == filter,
                  showCheckmark: true,
                  onSelected: (_) => setState(() => _filter = filter),
                ),
              const SizedBox(width: AppSpacing.s),
              AppButton(
                label: 'Усі події',
                variant: AppButtonVariant.text,
                onPressed: widget.onOpenEvents,
              ),
              AppButton(
                label: 'Створити подію',
                icon: Icons.add,
                onPressed: widget.onCreateEvent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Шапка: заголовок, сьогоднішня дата, пошук, сповіщення, аватар.
class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.showSearchInline,
    this.onAvatarTap,
    this.onSearchChanged,
  });

  final AppUser user;
  final bool showSearchInline;
  final VoidCallback? onAvatarTap;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final search = AppSearchField(
      hint: 'Пошук найближчих подій…',
      onChanged: onSearchChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Мої події',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    UaDateFormat.fullDate(DateTime.now()),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showSearchInline) ...[
              const SizedBox(width: AppSpacing.l),
              SizedBox(width: 360, child: search),
            ],
            const SizedBox(width: AppSpacing.m),
            IconButton(
              tooltip: 'Сповіщення',
              onPressed: () =>
                  showAppSnackBar(context, 'Нових сповіщень немає'),
              icon: const Badge(smallSize: 8, child: Icon(Icons.notifications)),
            ),
            const SizedBox(width: AppSpacing.s),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onAvatarTap,
              child: Tooltip(
                message: user.name,
                child: UserAvatar(
                  initials: user.initials,
                  imageUrl: user.photoUrl,
                ),
              ),
            ),
          ],
        ),
        if (!showSearchInline) ...[
          const SizedBox(height: AppSpacing.m),
          search,
        ],
      ],
    );
  }
}

/// Чотири картки статистики: 4 / 2 / 1 у ряд залежно від ширини.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<DashboardStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 480
            ? 2
            : 1;
        const spacing = AppSpacing.m;
        final itemWidth =
            ((constraints.maxWidth - spacing * (columns - 1)) / columns)
                .floorToDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: itemWidth,
                child: StatCard(
                  icon: stat.icon,
                  label: stat.label,
                  value: stat.value,
                  delta: stat.delta,
                  iconBackground: stat.iconBackground,
                  iconColor: stat.iconColor,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Адаптивна сітка карток подій: 3 / 2 / 1 колонки.
class _EventsGrid extends StatelessWidget {
  const _EventsGrid({required this.events, required this.onEventTap});

  final List<EventModel> events;
  final ValueChanged<EventModel> onEventTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: Text(
            'Тут поки порожньо',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.expanded
            ? 3
            : constraints.maxWidth >= 640
            ? 2
            : 1;
        const spacing = AppSpacing.m;
        final itemWidth =
            ((constraints.maxWidth - spacing * (columns - 1)) / columns)
                .floorToDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final event in events)
              SizedBox(
                width: itemWidth,
                child: EventCard(event: event, onTap: () => onEventTap(event)),
              ),
          ],
        );
      },
    );
  }
}
