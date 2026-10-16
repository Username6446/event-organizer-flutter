import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:event_organizer/app.dart';

void main() {
  testWidgets('Застосунок відкривається на екрані входу', (tester) async {
    await tester.pumpWidget(const EventOrganizerApp());

    expect(find.text('Вхід до акаунта'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });

  testWidgets('Кнопка «Створити акаунт» перемикає форму на реєстрацію',
      (tester) async {
    await tester.pumpWidget(const EventOrganizerApp());

    // Форма довша за тестове вікно 800×600, тож спершу прокручуємо до кнопки.
    await tester.ensureVisible(find.text('Створити акаунт'));
    await tester.tap(find.text('Створити акаунт'));
    await tester.pumpAndSettle();

    expect(find.text('Створення акаунта'), findsOneWidget);
    expect(find.text('Зареєструватися'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
