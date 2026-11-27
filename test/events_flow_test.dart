import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:event_organizer/app.dart';
import 'package:event_organizer/core/services/analytics_service.dart';
import 'package:event_organizer/features/events/data/in_memory_event_repository.dart';
import 'package:event_organizer/features/settings/data/settings_repository.dart';
import 'package:event_organizer/models/app_user.dart';

import 'fakes/fake_auth_repository.dart';

/// Сценарії роботи зі списками та CRUD через інтерфейс.
void main() {
  const user = AppUser(
    uid: 'u1',
    email: 'olena@gmail.com',
    displayName: 'Олена Коваль',
  );

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      EventOrganizerApp(
        authRepository: FakeAuthRepository(initialUser: user),
        eventRepository: InMemoryEventRepository(latency: Duration.zero),
        settingsRepository: SettingsRepository(prefs),
        analytics: AnalyticsService.disabled(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text).last;
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openEventsTab(WidgetTester tester) async {
    await tester.tap(find.text('Події').first);
    await tester.pumpAndSettle();
  }

  testWidgets('вкладка «Події» показує список і фільтрує за статусом', (
    tester,
  ) async {
    await pumpApp(tester);
    await openEventsTab(tester);

    expect(find.text('Вечір настільних ігор'), findsOneWidget);
    expect(find.text('Воркшоп з гончарства'), findsOneWidget);

    await tapText(tester, 'Скасовано 1');

    expect(find.text('Воркшоп з гончарства'), findsOneWidget);
    expect(find.text('Вечір настільних ігор'), findsNothing);
  });

  testWidgets('додавання гостя на сторінці події', (tester) async {
    await pumpApp(tester);
    await openEventsTab(tester);

    await tapText(tester, 'Вечір настільних ігор');
    expect(find.text('Гості · 4'), findsOneWidget);

    await tapText(tester, 'Додати гостя');
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('guest-name')),
        matching: find.byType(TextField),
      ),
      'Олег Новак',
    );
    await tapText(tester, 'Додати');

    expect(find.text('Олег Новак'), findsOneWidget);
    expect(find.text('Гості · 5'), findsOneWidget);
  });

  testWidgets('форма події перевіряє обовʼязкові поля і створює подію', (
    tester,
  ) async {
    await pumpApp(tester);
    await openEventsTab(tester);

    await tapText(tester, 'Створити подію');
    expect(find.text('Нова подія'), findsOneWidget);

    // Порожня форма не зберігається.
    await tapText(tester, 'Створити подію');
    expect(find.text('Введіть назву події'), findsOneWidget);
    expect(find.text('Вкажіть місце проведення'), findsOneWidget);

    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );
    await tester.enterText(field('event-title'), 'Тестова подія');
    await tester.enterText(field('event-location'), 'Львів, Ринок');
    await tapText(tester, 'Створити подію');

    expect(find.text('Подію «Тестова подія» створено'), findsOneWidget);
    expect(find.text('Нова подія'), findsNothing);
  });
}
