import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/ua_date_format.dart';
import 'avatar_stack.dart';
import 'progress_bar.dart';

/// Картка події для сітки «Найближчі події».
///
/// Шапка — градієнт (замість зображення), бейдж дати та категорія;
/// нижче — назва, час, місце, гості та прогрес виконання завдань.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap});

  final EventModel event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(event: event),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _MetaRow(event: event),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      AvatarStack(
                        initials: event.guestInitials,
                        extraCount: event.extraGuests,
                      ),
                      const Spacer(),
                      Text(
                        '${event.tasksDone}/${event.tasksTotal} завдань',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ProgressBar(value: event.progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 112,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: event.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Бейдж з датою
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  UaDateFormat.day(event.date),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  UaDateFormat.monthShort(event.date),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          // Категорія
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
                child: Text(
                  event.isDraft
                      ? '${event.category} · чернетка'
                      : event.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        );

    return Row(
      children: [
        const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(UaDateFormat.weekdayTime(event.date), style: style),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s),
          child: Text('•', style: TextStyle(color: AppColors.textSecondary)),
        ),
        const Icon(Icons.place, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            event.location,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
