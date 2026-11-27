import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/ua_collator.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/guest_model.dart';
import '../events/bloc/events_bloc.dart';
import '../events/event_navigation.dart';
import '../events/widgets/guest_form_dialog.dart';
import '../events/widgets/guest_tile.dart';

/// Вкладка «Гості»: усі запрошені на всі події (ФВ 7).
///
/// Дані — із [EventsBloc]; пошук і фільтри (статус, подія) — ефемерний
/// стан. Додавання гостя виконується на екрані конкретної події.
class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  String _search = '';
  GuestStatus? _statusFilter;

  /// null — гості всіх подій.
  String? _eventFilter;

  Future<void> _edit(GuestEntry entry) async {
    final saved = await showGuestFormDialog(context, guest: entry.guest);
    if (saved != null && mounted) {
      context.read<EventsBloc>().add(GuestSaved(entry.event.id, saved));
    }
  }

  Future<void> _delete(GuestEntry entry) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Видалити гостя?',
      message:
          '«${entry.guest.name}» зникне зі списку події '
          '«${entry.event.title}».',
    );
    if (confirmed && mounted) {
      context.read<EventsBloc>().add(
        GuestDeleted(entry.event.id, entry.guest.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EventsBloc>().state;
    final all = state.allGuests;
    final query = _search.trim().toLowerCase();

    // Якщо вибрану подію видалили — показуємо гостей усіх подій.
    final eventFilter = state.eventById(_eventFilter ?? '') == null
        ? null
        : _eventFilter;
    final byEvent = eventFilter == null
        ? all
        : all.where((e) => e.event.id == eventFilter).toList();
    final visible = byEvent.where((entry) {
      if (_statusFilter != null && entry.guest.status != _statusFilter) {
        return false;
      }
      return query.isEmpty ||
          entry.guest.name.toLowerCase().contains(query) ||
          entry.guest.contact.toLowerCase().contains(query);
    }).toList()..sort((a, b) => UaCollator.compare(a.guest.name, b.guest.name));

    int count(GuestStatus status) =>
        byEvent.where((e) => e.guest.status == status).length;

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
                      'Гості',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Усі запрошені на ваші події. Нового гостя можна '
                      'додати на сторінці події.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _CountersRow(
                      total: byEvent.length,
                      confirmed: count(GuestStatus.confirmed),
                      invited: count(GuestStatus.invited),
                      declined: count(GuestStatus.declined),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.s,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          child: AppSearchField(
                            hint: 'Пошук за іменем або контактом…',
                            onChanged: (value) =>
                                setState(() => _search = value),
                          ),
                        ),
                        Container(
                          width: 280,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.m,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outline),
                            borderRadius: BorderRadius.circular(AppRadius.s),
                          ),
                          child: DropdownButtonHideUnderline(
                            // Звичайний DropdownButton (не FormField): значення
                            // завжди береться з поточного стану фільтра.
                            child: DropdownButton<String>(
                              value: eventFilter ?? '',
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('Усі події'),
                                ),
                                for (final event in state.events)
                                  DropdownMenuItem(
                                    value: event.id,
                                    child: Text(
                                      event.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (value) => setState(() {
                                _eventFilter = (value == null || value.isEmpty)
                                    ? null
                                    : value;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.s,
                      children: [
                        ChoiceChip(
                          label: Text('Усі ${byEvent.length}'),
                          selected: _statusFilter == null,
                          onSelected: (_) =>
                              setState(() => _statusFilter = null),
                        ),
                        for (final status in GuestStatus.values)
                          ChoiceChip(
                            label: Text('${status.label} ${count(status)}'),
                            selected: _statusFilter == status,
                            onSelected: (_) =>
                                setState(() => _statusFilter = status),
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
                  icon: Icons.people_outline,
                  title: 'Гостей не знайдено',
                  message: 'Змініть пошук або фільтри',
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
                    return GuestTile(
                      key: ValueKey('${entry.event.id}-${entry.guest.id}'),
                      guest: entry.guest,
                      index: index,
                      eventTitle: entry.event.title,
                      onTap: () => openEventDetails(context, entry.event.id),
                      onStatusChanged: (status) =>
                          context.read<EventsBloc>().add(
                            GuestStatusChanged(
                              entry.event.id,
                              entry.guest.id,
                              status,
                            ),
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

/// Лічильники гостей за статусами (картки як на дашборді).
class _CountersRow extends StatelessWidget {
  const _CountersRow({
    required this.total,
    required this.confirmed,
    required this.invited,
    required this.declined,
  });

  final int total;
  final int confirmed;
  final int invited;
  final int declined;

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(icon: Icons.people, label: 'Усього гостей', value: '$total'),
      StatCard(
        icon: Icons.check_circle,
        label: 'Підтвердили',
        value: '$confirmed',
        iconBackground: AppColors.greenContainer,
        iconColor: AppColors.onGreenContainer,
      ),
      StatCard(
        icon: Icons.schedule,
        label: 'Очікують',
        value: '$invited',
        iconBackground: AppColors.orangeContainer,
        iconColor: AppColors.onOrangeContainer,
      ),
      StatCard(
        icon: Icons.cancel,
        label: 'Відхилили',
        value: '$declined',
        iconBackground: AppColors.pinkContainer,
        iconColor: AppColors.onPinkContainer,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 480
            ? 2
            : 1;
        const spacing = AppSpacing.m;
        final width =
            ((constraints.maxWidth - spacing * (columns - 1)) / columns)
                .floorToDouble();
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}
