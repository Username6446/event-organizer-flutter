import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:event_organizer/app.dart';
import 'package:event_organizer/core/services/analytics_service.dart';
import 'package:event_organizer/features/auth/data/auth_failure.dart';
import 'package:event_organizer/features/events/data/in_memory_event_repository.dart';
import 'package:event_organizer/features/settings/data/settings_repository.dart';
import 'package:event_organizer/models/app_user.dart';

import 'fakes/fake_auth_repository.dart';

void main() {
  Future<FakeAuthRepository> pumpApp(
    WidgetTester tester, {
    AppUser? user,
  }) async {
    // Десктопне вікно браузера: бічна навігація MainShell не вміщається
    // у стандартне тестове вікно 800×600.
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Порожнє сховище SharedPreferences для кожного тесту.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final repository = FakeAuthRepository(initialUser: user);
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

  /// Текстове поле всередині AppTextField / PasswordField з ключем [key].
  Finder field(String key) => find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(TextField),
  );

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  group('Вхід', () {
    testWidgets('порожня форма показує помилки й не надсилає запит', (
      tester,
    ) async {
      final repository = await pumpApp(tester);

      await tapText(tester, 'Увійти');

      expect(find.text('Введіть електронну пошту'), findsOneWidget);
      // «Введіть пароль» — і підказка в полі, і текст помилки.
      expect(find.text('Введіть пароль'), findsNWidgets(2));
      expect(repository.calls, isEmpty);
    });

    testWidgets('неправильний пароль підсвічує поле пароля', (tester) async {
      final repository = await pumpApp(tester);

      await tester.enterText(field('email'), 'olena@gmail.com');
      await tester.enterText(field('password'), 'wrong-password');
      await tapText(tester, 'Увійти');

      expect(repository.calls, ['signIn:olena@gmail.com:true']);
      expect(find.text('Неправильний email або пароль'), findsOneWidget);
      expect(find.text('Вхід до акаунта'), findsOneWidget);
    });

    testWidgets('мережева помилка показується банером', (tester) async {
      final repository = await pumpApp(tester);
      repository.nextFailure = const AuthFailure("Немає з'єднання");

      await tester.enterText(field('email'), 'olena@gmail.com');
      await tester.enterText(field('password'), 'password123');
      await tapText(tester, 'Увійти');

      expect(find.text("Немає з'єднання"), findsOneWidget);
    });

    testWidgets('успішний вхід відкриває головну', (tester) async {
      final repository = await pumpApp(tester);

      await tester.enterText(field('email'), 'olena@gmail.com');
      await tester.enterText(
        field('password'),
        FakeAuthRepository.validPassword,
      );
      await tapText(tester, "Запам'ятати мене");
      await tapText(tester, 'Увійти');

      expect(repository.calls, ['signIn:olena@gmail.com:false']);
      expect(find.text('Мої події'), findsOneWidget);
    });
  });

  testWidgets("«Запам'ятати мене» зберігає email на пристрої", (tester) async {
    await pumpApp(tester);

    await tester.enterText(field('email'), 'olena@gmail.com');
    await tester.enterText(field('password'), FakeAuthRepository.validPassword);
    await tapText(tester, 'Увійти');

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(SettingsRepository.rememberedEmailKey),
      'olena@gmail.com',
    );

    // Після виходу форма входу підставляє збережений email.
    await tapText(tester, 'Вийти');
    expect(find.text('Вхід до акаунта'), findsOneWidget);
    expect(find.text('olena@gmail.com'), findsOneWidget);
  });

  group('Реєстрація', () {
    testWidgets('паролі мають збігатися, а умови — бути прийнятими', (
      tester,
    ) async {
      final repository = await pumpApp(tester);
      await tapText(tester, 'Створити акаунт');

      await tester.enterText(field('name'), 'Олена Коваль');
      await tester.enterText(field('email'), 'olena@gmail.com');
      await tester.enterText(field('password'), 'password123');
      await tester.enterText(field('confirm'), 'password124');
      await tapText(tester, 'Зареєструватися');

      expect(find.text('Паролі не збігаються'), findsOneWidget);
      expect(
        find.text('Щоб продовжити, погодьтеся з умовами використання'),
        findsOneWidget,
      );
      expect(repository.calls, isEmpty);

      await tester.enterText(field('confirm'), 'password123');
      await tapText(tester, 'Погоджуюся з умовами використання');
      await tapText(tester, 'Зареєструватися');

      expect(repository.calls, ['signUp:Олена Коваль:olena@gmail.com']);
      expect(find.text('Мої події'), findsOneWidget);
    });

    testWidgets('зайнятий email показується біля поля email', (tester) async {
      final repository = await pumpApp(tester);
      repository.nextFailure = const AuthFailure(
        'Акаунт із таким email уже існує',
        field: AuthField.email,
      );
      await tapText(tester, 'Створити акаунт');

      await tester.enterText(field('name'), 'Олена');
      await tester.enterText(field('email'), 'olena@gmail.com');
      await tester.enterText(field('password'), 'password123');
      await tester.enterText(field('confirm'), 'password123');
      await tapText(tester, 'Погоджуюся з умовами використання');
      await tapText(tester, 'Зареєструватися');

      expect(find.text('Акаунт із таким email уже існує'), findsOneWidget);
    });
  });

  testWidgets('відновлення пароля надсилає лист', (tester) async {
    final repository = await pumpApp(tester);

    await tester.enterText(field('email'), 'olena@gmail.com');
    await tapText(tester, 'Забули пароль?');

    // Email підставився з екрана входу.
    expect(find.text('olena@gmail.com'), findsOneWidget);
    await tapText(tester, 'Надіслати інструкції');

    expect(repository.calls, ['reset:olena@gmail.com']);
    expect(find.text('Перевірте пошту'), findsOneWidget);

    await tapText(tester, 'Повернутися до входу');
    expect(find.text('Вхід до акаунта'), findsOneWidget);
  });

  group('Профіль', () {
    const user = AppUser(
      uid: 'u1',
      email: 'olena@gmail.com',
      displayName: 'Олена Коваль',
    );

    Future<void> openProfile(WidgetTester tester) async {
      await tester.tap(find.text('Профіль').first);
      await tester.pumpAndSettle();
    }

    testWidgets('збережена сесія одразу відкриває головну', (tester) async {
      await pumpApp(tester, user: user);
      expect(find.text('Мої події'), findsOneWidget);
    });

    testWidgets('зміна імені зберігається через репозиторій', (tester) async {
      final repository = await pumpApp(tester, user: user);
      await openProfile(tester);

      final firstName = find.widgetWithText(TextField, 'Олена');
      await tester.enterText(firstName, 'Олеся');
      await tapText(tester, 'Зберегти зміни');

      expect(repository.calls, ['updateProfile:Олеся Коваль:null']);
      expect(find.text('Зміни збережено'), findsOneWidget);
    });

    testWidgets('неправильний поточний пароль показується біля поля', (
      tester,
    ) async {
      final repository = await pumpApp(tester, user: user);
      repository.nextFailure = const AuthFailure(
        'Поточний пароль неправильний',
        field: AuthField.currentPassword,
      );
      await openProfile(tester);

      final passwords = find.byType(TextField);
      // Порядок полів: ім'я, прізвище, email, поточний, новий, підтвердження.
      await tester.enterText(passwords.at(3), 'old-pass1');
      await tester.enterText(passwords.at(4), 'new-pass1');
      await tester.enterText(passwords.at(5), 'new-pass1');
      await tapText(tester, 'Зберегти зміни');

      expect(repository.calls, ['changePassword']);
      expect(find.text('Поточний пароль неправильний'), findsOneWidget);
    });

    testWidgets('вихід повертає на екран входу', (tester) async {
      final repository = await pumpApp(tester, user: user);
      await openProfile(tester);

      await tapText(tester, 'Вийти з акаунта');

      expect(repository.calls, ['signOut']);
      expect(find.text('Вхід до акаунта'), findsOneWidget);
    });
  });
}
