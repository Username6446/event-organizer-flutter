import 'package:flutter_test/flutter_test.dart';

import 'package:event_organizer/core/data/mock_data.dart';
import 'package:event_organizer/core/theme/app_colors.dart';
import 'package:event_organizer/features/events/bloc/events_bloc.dart';
import 'package:event_organizer/features/events/data/event_repository.dart';
import 'package:event_organizer/features/events/data/in_memory_event_repository.dart';
import 'package:event_organizer/models/event_model.dart';
import 'package:event_organizer/models/guest_model.dart';
import 'package:event_organizer/models/task_model.dart';

/// Репозиторій, що не може зберегти зміни (для перевірки відкату стану).
class _FailingRepository extends InMemoryEventRepository {
  _FailingRepository() : super(latency: Duration.zero);

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    throw const EventRepositoryException('Сервер недоступний');
  }
}

void main() {
  late EventsBloc bloc;

  /// Надсилає подію та чекає на стан, що задовольняє [until].
  Future<EventsState> dispatch(
    EventsEvent event,
    bool Function(EventsState state) until,
  ) {
    final future = bloc.stream.firstWhere(until);
    bloc.add(event);
    return future;
  }

  Future<void> load() => dispatch(
    const EventsLoadRequested(),
    (s) => s.status == EventsStatus.success,
  );

  setUp(() {
    bloc = EventsBloc(InMemoryEventRepository(latency: Duration.zero));
  });

  tearDown(() => bloc.close());

  test('початковий стан — initial без подій', () {
    expect(bloc.state.status, EventsStatus.initial);
    expect(bloc.state.events, isEmpty);
  });

  test('EventsLoadRequested завантажує захардкоджені події', () async {
    final loading = bloc.stream.first;
    bloc.add(const EventsLoadRequested());

    expect((await loading).status, EventsStatus.loading);
    final loaded = await bloc.stream.firstWhere(
      (s) => s.status == EventsStatus.success,
    );
    expect(loaded.events.length, MockData.events.length);
  });

  test('EventCreated додає подію і показує повідомлення', () async {
    await load();
    final event = EventModel(
      id: 'new',
      title: 'Тестова подія',
      category: 'Інше',
      date: DateTime(2026, 12, 1, 18),
      location: 'Львів',
      gradient: AppColors.gradientBlue,
    );

    final state = await dispatch(EventCreated(event), (s) => s.message != null);

    expect(state.eventById('new')?.title, 'Тестова подія');
    expect(state.message, 'Подію «Тестова подія» створено');
  });

  test('EventDeleted видаляє подію', () async {
    await load();
    final state = await dispatch(
      const EventDeleted('e1'),
      (s) => s.message != null,
    );

    expect(state.eventById('e1'), isNull);
    expect(state.events.length, MockData.events.length - 1);
  });

  test('GuestSaved додає гостя, GuestStatusChanged змінює статус', () async {
    await load();
    const guest = GuestModel(id: 'g-new', name: 'Олег Новак');

    var state = await dispatch(
      const GuestSaved('e3', guest),
      (s) => s.message != null,
    );
    expect(state.eventById('e3')!.guests.last.name, 'Олег Новак');

    state = await dispatch(
      const GuestStatusChanged('e3', 'g-new', GuestStatus.confirmed),
      (s) => s.eventById('e3')!.guests.last.status == GuestStatus.confirmed,
    );
    expect(state.eventById('e3')!.confirmedCount, 4);
  });

  test(
    'TaskToggled позначає завдання виконаним, TaskDeleted видаляє',
    () async {
      await load();
      final before = bloc.state.eventById('e3')!.tasksDone;

      var state = await dispatch(
        const TaskToggled('e3', 't11'),
        (s) => s.eventById('e3')!.tasksDone == before + 1,
      );
      expect(
        state
            .eventById('e3')!
            .tasks
            .firstWhere((t) => t.id == 't11')
            .isCompleted,
        isTrue,
      );

      state = await dispatch(
        const TaskDeleted('e3', 't11'),
        (s) => s.message != null,
      );
      expect(state.eventById('e3')!.tasks.any((t) => t.id == 't11'), isFalse);
    },
  );

  test('TaskSaved редагує наявне завдання', () async {
    await load();
    const edited = TaskModel(id: 't12', title: 'Купити піцу');

    final state = await dispatch(
      const TaskSaved('e3', edited),
      (s) => s.message != null,
    );
    final task = state.eventById('e3')!.tasks.firstWhere((t) => t.id == 't12');
    expect(task.title, 'Купити піцу');
  });

  test('помилка репозиторію відкочує зміну та показує повідомлення', () async {
    await bloc.close();
    bloc = EventsBloc(_FailingRepository());
    await load();
    final before = bloc.state.eventById('e3')!.tasksDone;

    final state = await dispatch(
      const TaskToggled('e3', 't11'),
      (s) => s.message != null,
    );

    expect(state.message, 'Сервер недоступний');
    expect(state.eventById('e3')!.tasksDone, before);
  });
}
