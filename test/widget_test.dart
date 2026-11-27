import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:event_organizer/app.dart';
import 'package:event_organizer/core/services/analytics_service.dart';
import 'package:event_organizer/features/events/data/in_memory_event_repository.dart';
import 'package:event_organizer/features/settings/data/settings_repository.dart';

import 'fakes/fake_auth_repository.dart';

void main() {
  Future<FakeAuthRepository> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      EventOrganizerApp(
        authRepository: repository,
        eventRepository: InMemoryEventRepository(latency: Duration.zero),
        settingsRepository: SettingsRepository(prefs),
        analytics: AnalyticsService.disabled(),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('Застосунок відкривається на екрані входу', (tester) async {
    await pumpApp(tester);

    expect(find.text('Вхід до акаунта'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });

  testWidgets('Кнопка «Створити акаунт» перемикає форму на реєстрацію', (
    tester,
  ) async {
    await pumpApp(tester);

    // Форма довша за тестове вікно 800×600, тож спершу прокручуємо до кнопки.
    await tester.ensureVisible(find.text('Створити акаунт'));
    await tester.tap(find.text('Створити акаунт'));
    await tester.pumpAndSettle();

    expect(find.text('Створення акаунта'), findsOneWidget);
    expect(find.text('Зареєструватися'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
