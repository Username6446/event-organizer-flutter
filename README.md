# Eventory — органайзер невеликих подій

Flutter Web застосунок для планування невеликих подій: дні народження,
корпоративи, пікніки. Список гостей, чек-лист завдань та нагадування.

Проєкт виконується в межах курсу «Кросплатформне програмування»
(Національний університет «Львівська політехніка», варіант 14).

## Стан

**Лабораторна робота №4** — автентифікація та інтеграція з Firebase:

- реєстрація та вхід через Firebase Authentication (email/пароль),
  «Запам'ятати мене» (збереження сесії в браузері або лише у вкладці);
- відновлення пароля листом із посиланням;
- профіль: зміна імені, фото за HTTPS-посиланням (готові аватари або
  власне посилання з попереднім переглядом), зміна пароля з повторною
  автентифікацією, вихід;
- валідація форм (`Form` + `GlobalKey<FormState>`), зрозумілі повідомлення
  про помилки Firebase, стан завантаження з блокуванням повторного надсилання;
- Firebase Analytics: `login`, `sign_up`, `screen_view`, власні події;
- Sentry замість Crashlytics (Crashlytics не підтримує Web).

Попередні етапи: Лаба №3 — інтерфейс без бізнес-логіки, адаптивна навігація
(`NavigationRail` на широких екранах, `NavigationBar` на мобільних).

## Запуск

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```

`env.json` не комітиться. Створіть його з шаблону `env.example.json` і вставте
DSN свого проєкту Sentry. Без цього файлу застосунок працює, але Sentry вимкнено.

Конфігурація Firebase — `lib/firebase_options.dart` (згенеровано `flutterfire configure`).

## Перевірка

```bash
dart analyze
flutter test
```

`flutter analyze` у шляху з кирилицею може падати — `dart analyze` виконує ту саму перевірку.

## Структура

```
lib/
├── main.dart                 # ініціалізація Sentry і Firebase, запуск
├── app.dart                  # MaterialApp, тема, AuthGate, спостерігач Analytics
├── firebase_options.dart     # згенеровано FlutterFire CLI
├── core/
│   ├── config/               # AppConfig (SENTRY_DSN з --dart-define)
│   ├── data/                 # mock-дані (події, статистика)
│   ├── services/             # AnalyticsService, ErrorReporter (Sentry)
│   ├── theme/                # кольори, відступи, тема
│   ├── utils/                # валідатори, форматування дат, SnackBar
│   └── widgets/              # перевикористовувані віджети
├── models/                   # AppUser, моделі подій і статистики
└── features/
    ├── auth/
    │   ├── data/             # AuthRepository, FirebaseAuthRepository, AuthFailure
    │   ├── widgets/
    │   ├── auth_gate.dart    # вибір екрана за станом автентифікації
    │   ├── auth_screen.dart  # вхід і реєстрація
    │   └── forgot_password_screen.dart
    ├── shell/                # оболонка з навігацією
    ├── home/                 # дашборд
    ├── profile/              # профіль, вибір фото, зміна пароля
    └── placeholder/          # заглушка для майбутніх розділів
test/
├── fakes/                    # FakeAuthRepository (тести без Firebase)
├── auth_flow_test.dart       # сценарії входу, реєстрації, профілю
├── validators_test.dart
└── widget_test.dart
```

## Залежності

`firebase_core`, `firebase_auth`, `firebase_analytics`, `sentry_flutter`.
