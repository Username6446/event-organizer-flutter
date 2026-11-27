import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/section_card.dart';
import '../events/bloc/events_bloc.dart';
import '../events/event_navigation.dart';
import '../events/widgets/task_form_dialog.dart';
import '../events/widgets/task_tile.dart';

/// Фільтри загального списку завдань.
enum _TaskFilter {
  open('Відкриті'),
  overdue('Прострочені'),
  done('Виконані'),
  all('Усі');

  const _TaskFilter(this.label);
  final String label;
}

/// Вкладка «Завдання»: завдання з усіх подій, відсортовані за дедлайном
/// (ФВ 8). Відмітка про виконання, редагування й видалення — через
/// [EventsBloc]; фільтр — ефемерний стан.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _TaskFilter _filter = _TaskFilter.open;

  Future<void> _edit(TaskEntry entry) async {
    final saved = await showTaskFormDialog(
      context,
      task: entry.task,
      guestNames: entry.event.guests.map((g) => g.name).toList(),
    );
    if (saved != null && mounted) {
      context.read<EventsBloc>().add(TaskSaved(entry.event.id, saved));
    }
  }

  Future<void> _delete(TaskEntry entry) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Видалити завдання?',
      message:
          '«${entry.task.title}» буде видалено з чек-листа події '
          '«${entry.event.title}».',
    );
    if (confirmed && mounted) {
      context.read<EventsBloc>().add(
        TaskDeleted(entry.event.id, entry.task.id),
      );
    }
  }

  static int _byDeadline(TaskEntry a, TaskEntry b) {
    final da = a.task.deadline;
    final db = b.task.deadline;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EventsBloc>().state;
    final now = DateTime.now();
    final all = state.allTasks;
    final done = all.where((e) => e.task.isCompleted).length;
    final overdue = all.where((e) => e.task.isOverdue(now)).length;

    int count(_TaskFilter filter) => switch (filter) {
      _TaskFilter.open => all.length - done,
      _TaskFilter.overdue => overdue,
      _TaskFilter.done => done,
      _TaskFilter.all => all.length,
    };

    final visible = all.where((entry) {
      final task = entry.task;
      return switch (_filter) {
        _TaskFilter.open => !task.isCompleted,
        _TaskFilter.overdue => task.isOverdue(now),
        _TaskFilter.done => task.isCompleted,
        _TaskFilter.all => true,
      };
    }).toList()..sort(_byDeadline);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.compact;
        final horizontal = isNarrow ? AppSpacing.m : AppSpacing.xl;
        final textTheme = Theme.of(context).textTheme;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Завдання',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Чек-листи підготовки всіх подій, відсортовані за '
                      'дедлайном',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SectionCard(
                      title: 'Загальний прогрес',
                      subtitle:
                          'Виконано $done з ${all.length} завдань'
                          '${overdue > 0 ? ' · прострочено: $overdue' : ''}',
                      child: ProgressBar(
                        value: all.isEmpty ? 0 : done / all.length,
                        height: 6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.s,
                      children: [
                        for (final filter in _TaskFilter.values)
                          ChoiceChip(
                            label: Text('${filter.label} ${count(filter)}'),
                            selected: _filter == filter,
                            onSelected: (_) => setState(() => _filter = filter),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (state.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (visible.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.checklist,
                  title: 'Завдань немає',
                  message: 'Додати завдання можна на сторінці події',
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  0,
                  horizontal,
                  AppSpacing.xl,
                ),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = visible[index];
                    return TaskTile(
                      key: ValueKey('${entry.event.id}-${entry.task.id}'),
                      task: entry.task,
                      eventTitle: entry.event.title,
                      onTap: () => openEventDetails(context, entry.event.id),
                      onToggle: () => context.read<EventsBloc>().add(
                        TaskToggled(entry.event.id, entry.task.id),
                      ),
                      onEdit: () => _edit(entry),
                      onDelete: () => _delete(entry),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
