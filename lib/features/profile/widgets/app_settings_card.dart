import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_card.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../../settings/data/app_settings.dart';

/// Блок «Налаштування застосунку» у профілі.
///
/// Значення беруться із [SettingsCubit] (BlocBuilder) і зберігаються на
/// пристрої через SharedPreferences одразу після зміни перемикача.
class AppSettingsCard extends StatelessWidget {
  const AppSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        final cubit = context.read<SettingsCubit>();

        return SectionCard(
          title: 'Налаштування застосунку',
          subtitle: 'Зберігаються на цьому пристрої автоматично',
          // Прозорий Material: SwitchListTile малює ефект натискання на
          // найближчому Material, а не під білим фоном картки.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.mark_email_unread),
                  title: const Text('Сповіщення на email'),
                  subtitle: const Text('Коли гості підтверджують участь'),
                  value: settings.emailNotifications,
                  onChanged: cubit.setEmailNotifications,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.alarm),
                  title: const Text('Нагадування про дедлайни'),
                  subtitle: const Text('За день до терміну виконання завдання'),
                  value: settings.taskReminders,
                  onChanged: cubit.setTaskReminders,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.grid_view),
                  title: const Text('Події у вигляді сітки'),
                  subtitle: const Text(
                    'Вимкніть, щоб бачити компактний список',
                  ),
                  value: settings.gridView,
                  onChanged: cubit.setGridView,
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    const Icon(Icons.sort),
                    const SizedBox(width: AppSpacing.m),
                    const Expanded(child: Text('Сортування подій')),
                    DropdownButton<EventSort>(
                      value: settings.eventSort,
                      onChanged: (value) {
                        if (value != null) cubit.setEventSort(value);
                      },
                      items: [
                        for (final sort in EventSort.values)
                          DropdownMenuItem(
                            value: sort,
                            child: Text(sort.label),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
