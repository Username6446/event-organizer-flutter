import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
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
import '../../models/event_model.dart';

/// Фільтри списку «Найближчі події».
enum _EventFilter {
  all('Усі'),
  thisMonth('Цього місяця'),
  drafts('Чернетки');

  const _EventFilter(this.label);
  final String label;
}

/// Головна сторінка — дашборд організатора (ФВ 5).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
    this.onOpenProfile,
    this.onCreateEvent,
  });

  /// Авторизований користувач (для аватара в шапці).
  final AppUser user;

  /// Натискання на аватар у шапці відкриває профіль.
  final VoidCallback? onOpenProfile;

  final VoidCallback? onCreateEvent;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _EventFilter _filter = _EventFilter.all;

  List<EventModel> get _visibleEvents {
    final now = DateTime.now();
    return switch (_filter) {
      _EventFilter.all => MockData.events,
      _EventFilter.thisMonth => MockData.events
          .where((e) => e.date.year == now.year && e.date.month == now.month)
          .toList(),
      _EventFilter.drafts => MockData.events.where((e) => e.isDraft).toList(),
    };
  }

  void _openEvent(EventModel event) {
    showAppSnackBar(
      context,
      'Сторінка події «${event.title}» буде доступна в наступних лабораторних',
    );
  }

  @override
  Widget build(BuildContext context) {
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
              ),
              const SizedBox(height: AppSpacing.l),
              const _StatsGrid(),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionHeader(context),
              const SizedBox(height: AppSpacing.m),
              _EventsGrid(events: _visibleEvents, onEventTap: _openEvent),
            ],
          ),
        );
      },
    );
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
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
  });

  final AppUser user;
  final bool showSearchInline;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const search = AppSearchField(hint: 'Пошук подій і гостей…');

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
              const SizedBox(width: 360, child: search),
            ],
            const SizedBox(width: AppSpacing.m),
            IconButton(
              tooltip: 'Сповіщення',
              onPressed: () =>
                  showAppSnackBar(context, 'Нових сповіщень немає'),
              icon: const Badge(
                smallSize: 8,
                child: Icon(Icons.notifications),
              ),
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
  const _StatsGrid();

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
            for (final stat in MockData.stats)
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                child: EventCard(
                  event: event,
                  onTap: () => onEventTap(event),
                ),
              ),
          ],
        );
      },
    );
  }
}
