import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/ua_date_format.dart';
import '../../../models/task_model.dart';

enum _TaskAction { edit, delete }

/// Рядок чек-листа: чекбокс, назва (перекреслена після виконання),
/// відповідальний, дедлайн і меню дій (ФВ 8).
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.eventTitle,
    this.onTap,
  });

  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Назва події (у загальному списку завдань).
  final String? eventTitle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = [
      ?eventTitle,
      'Відповідальний: ${task.assignee ?? 'не призначено'}',
    ].join(' · ');

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Checkbox(value: task.isCompleted, onChanged: (_) => onToggle()),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: task.isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              _DeadlineBadge(task: task),
              PopupMenuButton<_TaskAction>(
                tooltip: 'Дії',
                onSelected: (action) {
                  if (action == _TaskAction.edit) {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _TaskAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Редагувати'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _TaskAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Видалити'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Бейдж дедлайну: «Виконано», «Прострочено · 18 лист.» або «до 22 листопада».
class _DeadlineBadge extends StatelessWidget {
  const _DeadlineBadge({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final deadline = task.deadline;
    final (String label, IconData icon, Color background) = task.isCompleted
        ? ('Виконано', Icons.check, AppColors.successContainer)
        : deadline == null
        ? ('Без дедлайну', Icons.remove, AppColors.surfaceContainerHigh)
        : task.isOverdue(DateTime.now())
        ? (
            'Прострочено · ${UaDateFormat.dayMonth(deadline)}',
            Icons.warning_amber,
            AppColors.errorContainer,
          )
        : (
            'до ${UaDateFormat.dayMonth(deadline)}',
            Icons.schedule,
            AppColors.surfaceContainerHigh,
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
