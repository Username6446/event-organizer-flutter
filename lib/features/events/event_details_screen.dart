import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/ua_date_format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/section_card.dart';
import '../../models/event_model.dart';
import '../../models/guest_model.dart';
import '../../models/task_model.dart';
import 'bloc/events_bloc.dart';
import 'event_navigation.dart';
import 'widgets/guest_form_dialog.dart';
import 'widgets/guest_tile.dart';
import 'widgets/status_styles.dart';
import 'widgets/task_form_dialog.dart';
import 'widgets/task_tile.dart';

/// Фільтр чек-листа завдань.
enum _TaskFilter {
  all('Усі'),
  open('Відкриті'),
  done('Виконані');

  const _TaskFilter(this.label);
  final String label;
}

enum _EventAction { edit, delete }

/// Детальний екран події з вкладками «Гості», «Завдання», «Інформація»
/// (макети рис. 4–5 з лабораторної №2; ФВ 6, ФВ 7, ФВ 8).
///
/// Дані події беруться з [EventsBloc] за ідентифікатором, тож після
/// будь-якої зміни (статус гостя, нове завдання) BlocBuilder перебудовує
/// екран. Вибрана вкладка, пошук і фільтри — ефемерний стан.
class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  )..addListener(_onTabChanged);

  String _guestSearch = '';
  GuestStatus? _guestFilter;
  _TaskFilter _taskFilter = _TaskFilter.all;

  /// Остання відома версія події: після видалення екран ще кілька кадрів
  /// показується під час анімації закриття.
  EventModel? _lastEvent;

  EventsBloc get _bloc => context.read<EventsBloc>();

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _deleteEvent(EventModel event) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Видалити подію?',
      message:
          'Подію «${event.title}» буде видалено разом із '
          '${event.guestsCount} гостями та ${event.tasksTotal} завданнями.',
    );
    if (!confirmed || !mounted) return;
    _bloc.add(EventDeleted(event.id));
    Navigator.of(context).pop();
  }

  Future<void> _addOrEditGuest(EventModel event, [GuestModel? guest]) async {
    final saved = await showGuestFormDialog(context, guest: guest);
    if (saved != null && mounted) _bloc.add(GuestSaved(event.id, saved));
  }

  Future<void> _deleteGuest(EventModel event, GuestModel guest) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Видалити гостя?',
      message: '«${guest.name}» зникне зі списку запрошених.',
    );
    if (confirmed && mounted) _bloc.add(GuestDeleted(event.id, guest.id));
  }

  Future<void> _addOrEditTask(EventModel event, [TaskModel? task]) async {
    final saved = await showTaskFormDialog(
      context,
      task: task,
      guestNames: event.guests.map((g) => g.name).toList(),
    );
    if (saved != null && mounted) _bloc.add(TaskSaved(event.id, saved));
  }

  Future<void> _deleteTask(EventModel event, TaskModel task) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Видалити завдання?',
      message: '«${task.title}» буде видалено з чек-листа.',
    );
    if (confirmed && mounted) _bloc.add(TaskDeleted(event.id, task.id));
  }

  @override
  Widget build(BuildContext context) {
    final event =
        context.select(
          (EventsBloc bloc) => bloc.state.eventById(widget.eventId),
        ) ??
        _lastEvent;
    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.event_busy,
            title: 'Подію не знайдено',
            message: 'Можливо, її вже видалено',
          ),
        ),
      );
    }
    _lastEvent = event;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < AppBreakpoints.compact;
          final horizontal = isNarrow ? AppSpacing.m : AppSpacing.xl;

          return CustomScrollView(
            slivers: [
              _buildAppBar(event),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppSpacing.l,
                  horizontal,
                  AppSpacing.xl,
                ),
                sliver: switch (_tabController.index) {
                  0 => _buildGuestsTab(event),
                  1 => _buildTasksTab(event),
                  _ => _buildInfoTab(event),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Розгортана шапка з обкладинкою (SliverAppBar) і вкладками внизу.
  Widget _buildAppBar(EventModel event) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 240,
      backgroundColor: event.gradient.first,
      foregroundColor: AppColors.onPrimary,
      title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        IconButton(
          tooltip: 'Редагувати',
          icon: const Icon(Icons.edit),
          onPressed: () => openEventForm(context, event: event),
        ),
        PopupMenuButton<_EventAction>(
          tooltip: 'Інші дії',
          iconColor: AppColors.onPrimary,
          onSelected: (action) {
            if (action == _EventAction.edit) {
              openEventForm(context, event: event);
            } else {
              _deleteEvent(event);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _EventAction.edit,
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Редагувати подію'),
              ),
            ),
            PopupMenuItem(
              value: _EventAction.delete,
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Видалити подію'),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.s),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _DetailsHeader(event: event),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.onPrimary.withValues(alpha: 0.7),
        indicatorColor: AppColors.onPrimary,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Гості · ${event.guestsCount}'),
          Tab(text: 'Завдання · ${event.tasksTotal}'),
          const Tab(text: 'Інформація'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Вкладка «Гості» (рис. 4)
  // ---------------------------------------------------------------------------

  Widget _buildGuestsTab(EventModel event) {
    final query = _guestSearch.trim().toLowerCase();
    final guests = event.guests.where((guest) {
      if (_guestFilter != null && guest.status != _guestFilter) return false;
      return query.isEmpty ||
          guest.name.toLowerCase().contains(query) ||
          guest.contact.toLowerCase().contains(query);
    }).toList();

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _GuestsSummary(event: event)),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.m)),
        SliverToBoxAdapter(
          child: Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: AppSearchField(
                  hint: 'Пошук гостя…',
                  onChanged: (value) => setState(() => _guestSearch = value),
                ),
              ),
              ChoiceChip(
                label: Text('Усі ${event.guestsCount}'),
                selected: _guestFilter == null,
                onSelected: (_) => setState(() => _guestFilter = null),
              ),
              for (final status in GuestStatus.values)
                ChoiceChip(
                  label: Text('${status.label} ${event.countGuests(status)}'),
                  selected: _guestFilter == status,
                  onSelected: (_) => setState(() => _guestFilter = status),
                ),
              AppButton(
                label: 'Додати гостя',
                icon: Icons.person_add,
                onPressed: () => _addOrEditGuest(event),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.m)),
        if (guests.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.people_outline,
              title: event.guests.isEmpty
                  ? 'Гостей ще не додано'
                  : 'Нікого не знайдено',
              message: event.guests.isEmpty
                  ? 'Додайте першого гостя до списку запрошених'
                  : 'Змініть пошук або фільтр статусу',
            ),
          )
        else
          // ListView.separated у вигляді слівера: роздільник між гостями.
          SliverList.separated(
            itemCount: guests.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final guest = guests[index];
              return GuestTile(
                key: ValueKey(guest.id),
                guest: guest,
                index: index,
                onStatusChanged: (status) =>
                    _bloc.add(GuestStatusChanged(event.id, guest.id, status)),
                onEdit: () => _addOrEditGuest(event, guest),
                onDelete: () => _deleteGuest(event, guest),
              );
            },
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Вкладка «Завдання» (рис. 5)
  // ---------------------------------------------------------------------------

  Widget _buildTasksTab(EventModel event) {
    final tasks =
        event.tasks.where((task) {
            return switch (_taskFilter) {
              _TaskFilter.all => true,
              _TaskFilter.open => !task.isCompleted,
              _TaskFilter.done => task.isCompleted,
            };
          }).toList()
          // Спочатку невиконані за дедлайном, виконані — в кінці.
          ..sort(_compareTasks);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Чек-лист підготовки',
            subtitle:
                '${event.tasksDone} з ${event.tasksTotal} завдань '
                'виконано',
            child: ProgressBar(value: event.progress, height: 6),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.m)),
        SliverToBoxAdapter(
          child: Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final filter in _TaskFilter.values)
                ChoiceChip(
                  label: Text(filter.label),
                  selected: _taskFilter == filter,
                  onSelected: (_) => setState(() => _taskFilter = filter),
                ),
              AppButton(
                label: 'Нове завдання',
                icon: Icons.add_task,
                onPressed: () => _addOrEditTask(event),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.m)),
        if (tasks.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.checklist,
              title: 'Завдань немає',
              message: 'Додайте завдання до чек-листа підготовки',
            ),
          )
        else
          SliverList.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                key: ValueKey(task.id),
                task: task,
                onToggle: () => _bloc.add(TaskToggled(event.id, task.id)),
                onEdit: () => _addOrEditTask(event, task),
                onDelete: () => _deleteTask(event, task),
              );
            },
          ),
      ],
    );
  }

  static int _compareTasks(TaskModel a, TaskModel b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    final da = a.deadline;
    final db = b.deadline;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  // ---------------------------------------------------------------------------
  // Вкладка «Інформація»
  // ---------------------------------------------------------------------------

  Widget _buildInfoTab(EventModel event) {
    return SliverToBoxAdapter(
      child: SectionCard(
        title: 'Основна інформація',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) ...[
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.l),
            ],
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Дата',
              value: UaDateFormat.fullDate(event.date),
            ),
            _InfoRow(
              icon: Icons.schedule,
              label: 'Час',
              value:
                  '${UaDateFormat.time(event.date)} – '
                  '${UaDateFormat.time(event.endTime)} '
                  '(${event.durationHours} год)',
            ),
            _InfoRow(icon: Icons.place, label: 'Місце', value: event.location),
            _InfoRow(
              icon: Icons.category,
              label: 'Категорія',
              value: event.category,
            ),
            _InfoRow(
              icon: Icons.groups,
              label: 'Місткість',
              value: 'до ${event.maxGuests} гостей',
            ),
            _InfoRow(
              icon: StatusStyles.eventIcon(event.status),
              label: 'Статус',
              value: event.isDraft
                  ? '${event.status.label} (чернетка)'
                  : event.status.label,
            ),
            _InfoRow(
              icon: event.isPrivate ? Icons.lock : Icons.public,
              label: 'Доступ',
              value: event.isPrivate
                  ? 'Приватна — лише за запрошенням'
                  : 'Відкрита подія',
            ),
          ],
        ),
      ),
    );
  }
}

/// Фон шапки: градієнт або обкладинка, категорія, дата, час і місце.
class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final coverUrl = event.coverUrl;
    final muted = AppColors.onPrimary.withValues(alpha: 0.85);
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: event.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        if (coverUrl != null) ...[
          Image.network(
            coverUrl,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          // Затемнення, щоб білий текст читався на будь-якому фото.
          const ColoredBox(color: Color(0x66000000)),
        ],
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.l,
            top + AppSpacing.s,
            AppSpacing.l,
            kTextTabBarHeight + AppSpacing.m,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
                child: Text(
                  [
                    event.category,
                    event.status.label,
                    if (event.isDraft) 'чернетка',
                  ].join(' · '),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.l,
                runSpacing: AppSpacing.xs,
                children: [
                  _HeaderMeta(
                    icon: Icons.calendar_today,
                    text: UaDateFormat.shortDate(event.date),
                    color: muted,
                  ),
                  _HeaderMeta(
                    icon: Icons.schedule,
                    text:
                        '${UaDateFormat.time(event.date)} – '
                        '${UaDateFormat.time(event.endTime)}',
                    color: muted,
                  ),
                  _HeaderMeta(
                    icon: Icons.place,
                    text: event.location,
                    color: muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderMeta extends StatelessWidget {
  const _HeaderMeta({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// Картка «Відповіді гостей»: лічильники статусів і заповненість місць.
class _GuestsSummary extends StatelessWidget {
  const _GuestsSummary({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final capacity = event.maxGuests == 0
        ? 0.0
        : event.confirmedCount / event.maxGuests;

    return SectionCard(
      title: 'Відповіді гостей',
      subtitle:
          '${event.confirmedCount} з ${event.maxGuests} місць '
          'підтверджено',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressBar(value: capacity, height: 6, color: AppColors.success),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.l,
            runSpacing: AppSpacing.s,
            children: [
              for (final status in GuestStatus.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      StatusStyles.guestIcon(status),
                      size: 18,
                      color: StatusStyles.guestColor(status),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${status.label}: ${event.countGuests(status)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Рядок «іконка — підпис — значення» на вкладці «Інформація».
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
