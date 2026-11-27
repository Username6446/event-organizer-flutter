import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/ua_date_format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/event_card.dart';
import '../../core/widgets/progress_bar.dart';
import '../../models/event_model.dart';
import '../settings/bloc/settings_cubit.dart';
import '../settings/data/app_settings.dart';
import 'bloc/events_bloc.dart';
import 'event_navigation.dart';
import 'event_query.dart';
import 'widgets/status_styles.dart';

/// Вкладка «Події»: список усіх подій користувача (ФВ 5, ФВ 6).
///
/// Побудована на CustomScrollView: шапка й панель фільтрів — звичайні
/// віджети в SliverToBoxAdapter, а самі події — SliverGrid (сітка карток)
/// або SliverList (компактний список). Фільтр за статусом, сортування та
/// вигляд беруться із [SettingsCubit] і зберігаються на пристрої;
/// пошуковий запит — ефемерний стан екрана.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.onCreateEvent});

  final VoidCallback? onCreateEvent;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final eventsState = context.watch<EventsBloc>().state;
    final settings = context.watch<SettingsCubit>().state;

    final visible = EventQuery.apply(
      eventsState.events,
      status: settings.statusFilter,
      sort: settings.eventSort,
      search: _search,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.compact;
        final horizontal = isNarrow ? AppSpacing.m : AppSpacing.xl;
        final padding = EdgeInsets.symmetric(horizontal: horizontal);

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                AppSpacing.l,
                horizontal,
                AppSpacing.m,
              ),
              sliver: SliverToBoxAdapter(
                child: _Header(
                  total: eventsState.events.length,
                  onCreateEvent: widget.onCreateEvent,
                ),
              ),
            ),
            SliverPadding(
              padding: padding,
              sliver: SliverToBoxAdapter(
                child: _Toolbar(
                  events: eventsState.events,
                  settings: settings,
                  onSearchChanged: (value) => setState(() => _search = value),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.m)),
            ..._buildContent(context, eventsState, settings, visible, padding),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        );
      },
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    EventsState state,
    AppSettings settings,
    List<EventModel> visible,
    EdgeInsets padding,
  ) {
    if (state.isLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state.status == EventsStatus.failure) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.cloud_off,
            title: 'Не вдалося завантажити події',
            message: state.errorMessage,
            actionLabel: 'Спробувати ще раз',
            onAction: () =>
                context.read<EventsBloc>().add(const EventsLoadRequested()),
          ),
        ),
      ];
    }

    if (visible.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.event_busy,
            title: state.events.isEmpty
                ? 'Подій ще немає'
                : 'Нічого не знайдено',
            message: state.events.isEmpty
                ? 'Створіть першу подію, щоб почати планування'
                : 'Змініть пошуковий запит або фільтр',
            actionLabel: state.events.isEmpty ? 'Створити подію' : null,
            onAction: widget.onCreateEvent,
          ),
        ),
      ];
    }

    if (settings.gridView) {
      // GridView через слівер: картки будуються ліниво (builder-делегат).
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 264,
              crossAxisSpacing: AppSpacing.m,
              mainAxisSpacing: AppSpacing.m,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final event = visible[index];
              return EventCard(
                event: event,
                onTap: () => openEventDetails(context, event.id),
              );
            }, childCount: visible.length),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: padding,
        sliver: SliverList.separated(
          itemCount: visible.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.s),
          itemBuilder: (context, index) {
            final event = visible[index];
            return _EventListTile(
              event: event,
              onTap: () => openEventDetails(context, event.id),
            );
          },
        ),
      ),
    ];
  }
}

/// Заголовок вкладки з кнопкою створення події.
class _Header extends StatelessWidget {
  const _Header({required this.total, this.onCreateEvent});

  final int total;
  final VoidCallback? onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Події',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Усього подій: $total',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppButton(
          label: 'Створити подію',
          icon: Icons.add,
          onPressed: onCreateEvent,
        ),
      ],
    );
  }
}

/// Пошук, фільтр за статусом, сортування та перемикач «сітка / список».
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.events,
    required this.settings,
    required this.onSearchChanged,
  });

  final List<EventModel> events;
  final AppSettings settings;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();

    int count(EventStatus status) =>
        events.where((e) => e.status == status).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppSearchField(
                hint: 'Пошук за назвою, місцем або категорією…',
                onChanged: onSearchChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            PopupMenuButton<EventSort>(
              tooltip: 'Сортування',
              initialValue: settings.eventSort,
              onSelected: cubit.setEventSort,
              itemBuilder: (context) => [
                for (final sort in EventSort.values)
                  CheckedPopupMenuItem(
                    value: sort,
                    checked: sort == settings.eventSort,
                    child: Text(sort.label),
                  ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(Icons.sort, color: AppColors.textSecondary),
              ),
            ),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.grid_view),
                  tooltip: 'Сітка',
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.view_list),
                  tooltip: 'Список',
                ),
              ],
              selected: {settings.gridView},
              onSelectionChanged: (selection) =>
                  cubit.setGridView(selection.first),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ChoiceChip(
              label: Text('Усі ${events.length}'),
              selected: settings.statusFilter == null,
              onSelected: (_) => cubit.setStatusFilter(null),
            ),
            for (final status in EventStatus.values)
              ChoiceChip(
                label: Text('${status.label} ${count(status)}'),
                selected: settings.statusFilter == status,
                onSelected: (_) => cubit.setStatusFilter(status),
              ),
            const SizedBox(width: AppSpacing.s),
            Text(
              settings.eventSort.label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

/// Компактний рядок події для режиму «Список».
class _EventListTile extends StatelessWidget {
  const _EventListTile({required this.event, required this.onTap});

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  gradient: LinearGradient(
                    colors: event.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      UaDateFormat.day(event.date),
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      UaDateFormat.monthShort(event.date),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${UaDateFormat.weekdayTime(event.date)} · '
                      '${event.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${event.guestsCount} гостей · '
                      '${event.tasksDone}/${event.tasksTotal} завдань',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ProgressBar(value: event.progress),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: StatusStyles.eventBackground(event.status),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      StatusStyles.eventIcon(event.status),
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      event.isDraft ? 'Чернетка' : event.status.label,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
