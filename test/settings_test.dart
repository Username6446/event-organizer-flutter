import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:event_organizer/features/settings/bloc/settings_cubit.dart';
import 'package:event_organizer/features/settings/data/app_settings.dart';
import 'package:event_organizer/features/settings/data/settings_repository.dart';
import 'package:event_organizer/models/event_model.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('без збережених значень повертаються типові налаштування', () async {
    final repository = await SettingsRepository.create();
    final settings = repository.load();

    expect(settings.eventSort, EventSort.dateAsc);
    expect(settings.statusFilter, isNull);
    expect(settings.gridView, isTrue);
    expect(repository.rememberedEmail, isNull);
  });

  test('SettingsCubit зберігає зміни в SharedPreferences', () async {
    final cubit = SettingsCubit(await SettingsRepository.create());

    await cubit.setEventSort(EventSort.title);
    await cubit.setStatusFilter(EventStatus.cancelled);
    await cubit.setGridView(false);
    await cubit.setTaskReminders(false);

    expect(cubit.state.eventSort, EventSort.title);

    // Нове читання зі сховища — як після перезапуску застосунку.
    final prefs = await SharedPreferences.getInstance();
    final reloaded = SettingsRepository(prefs).load();
    expect(reloaded.eventSort, EventSort.title);
    expect(reloaded.statusFilter, EventStatus.cancelled);
    expect(reloaded.gridView, isFalse);
    expect(reloaded.taskReminders, isFalse);
    expect(prefs.getString(SettingsRepository.eventSortKey), 'title');

    await cubit.setStatusFilter(null);
    expect(prefs.containsKey(SettingsRepository.statusFilterKey), isFalse);
    await cubit.close();
  });

  test('значення зі старих версій ігноруються', () async {
    SharedPreferences.setMockInitialValues({
      SettingsRepository.eventSortKey: 'unknown',
      SettingsRepository.statusFilterKey: 'archived',
    });
    final settings = (await SettingsRepository.create()).load();

    expect(settings.eventSort, EventSort.dateAsc);
    expect(settings.statusFilter, isNull);
  });

  test('email для входу зберігається і видаляється', () async {
    final repository = await SettingsRepository.create();

    await repository.saveRememberedEmail('olena@gmail.com');
    expect(repository.rememberedEmail, 'olena@gmail.com');

    await repository.saveRememberedEmail(null);
    expect(repository.rememberedEmail, isNull);
  });
}
