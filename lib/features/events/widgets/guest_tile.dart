import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/guest_model.dart';
import 'status_styles.dart';

enum _GuestAction { edit, delete }

/// Рядок списку гостей: аватар, ім'я, контакт, статус (змінюється
/// з випадного меню) і меню «Редагувати / Видалити».
class GuestTile extends StatelessWidget {
  const GuestTile({
    super.key,
    required this.guest,
    required this.index,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
    this.eventTitle,
    this.onTap,
  });

  final GuestModel guest;

  /// Порядковий номер — для кольору аватара.
  final int index;

  final ValueChanged<GuestStatus> onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Назва події (у загальному списку гостей).
  final String? eventTitle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = [
      if (guest.contact.isNotEmpty) guest.contact,
      if (guest.notes.isNotEmpty) guest.notes,
    ].join(' · ');

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              UserAvatar(
                initials: guest.initials,
                backgroundColor: UserAvatar.colorForIndex(index),
                foregroundColor: AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (eventTitle != null)
                      Text(
                        eventTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    if (details.isNotEmpty)
                      Text(
                        details,
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
              GuestStatusMenu(status: guest.status, onChanged: onStatusChanged),
              PopupMenuButton<_GuestAction>(
                tooltip: 'Дії',
                onSelected: (action) {
                  if (action == _GuestAction.edit) {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _GuestAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Редагувати'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _GuestAction.delete,
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

/// Чіп статусу гостя з меню для швидкої зміни (ФВ 7).
class GuestStatusMenu extends StatelessWidget {
  const GuestStatusMenu({
    super.key,
    required this.status,
    required this.onChanged,
  });

  final GuestStatus status;
  final ValueChanged<GuestStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GuestStatus>(
      tooltip: 'Змінити статус',
      initialValue: status,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final value in GuestStatus.values)
          PopupMenuItem(
            value: value,
            child: Row(
              children: [
                Icon(
                  StatusStyles.guestIcon(value),
                  size: 18,
                  color: StatusStyles.guestColor(value),
                ),
                const SizedBox(width: AppSpacing.s),
                Text(value.label),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: StatusStyles.guestBackground(status),
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              StatusStyles.guestIcon(status),
              size: 16,
              color: StatusStyles.guestColor(status),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              status.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}
