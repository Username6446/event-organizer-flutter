# Eventory — органайзер невеликих подій

Flutter Web застосунок для планування невеликих подій: дні народження,
корпоративи, пікніки. Список гостей, чек-лист завдань та нагадування.

Проєкт виконується в межах курсу «Кросплатформне програмування»
(Національний університет «Львівська політехніка», варіант 14).

## Стан

**Лабораторна робота №5** — робота з локальними даними та керування станом:

- керування станом через **BLoC** (`flutter_bloc`): `LoginBloc` (вхід і реєстрація),
  `AuthSessionCubit` (сесія), `ProfileCubit` (профіль), `EventsBloc` (завантаження
  списків і CRUD подій, гостей, завдань), `SettingsCubit` (налаштування);
- шаблон Repository: `EventRepository` → `InMemoryEventRepository` (захардкоджені дані),
  залежності передаються через `RepositoryProvider`;
- нові екрани: «Події» (сітка/список на слівері, пошук, фільтр за статусом, сортування),
  сторінка події з вкладками «Гості», «Завдання», «Інформація», форма створення та
  редагування події, діалоги гостя й завдання, загальні списки гостей і завдань;
- локальне сховище `shared_preferences`: сортування, фільтр і вигляд списку подій,
  налаштування в профілі, email для «Запам'ятати мене» (на Web — localStorage).

Попередні етапи: Лаба №4 — автентифікація Firebase, профіль, Analytics і Sentry;
Лаба №3 — інтерфейс без бізнес-логіки, адаптивна навігація.

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
│   ├── data/                 # MockData — стартові події з гостями й завданнями
│   ├── services/             # AnalyticsService, ErrorReporter (Sentry)
│   ├── theme/                # кольори, відступи, тема
│   ├── utils/                # валідатори, форматування дат, SnackBar
│   └── widgets/              # перевикористовувані віджети
├── models/                   # AppUser, EventModel, GuestModel, TaskModel, DashboardStat
└── features/
    ├── auth/
    │   ├── bloc/             # LoginBloc, AuthSessionCubit
    │   ├── data/             # AuthRepository, FirebaseAuthRepository, AuthFailure
    │   ├── widgets/
    │   ├── auth_gate.dart    # вибір екрана за станом автентифікації
    │   ├── auth_screen.dart  # вхід і реєстрація
    │   └── forgot_password_screen.dart
    ├── shell/                # оболонка з навігацією
    ├── home/                 # дашборд
    ├── events/               # список, деталі, форма; bloc/ (EventsBloc), data/, widgets/
    ├── guests/               # загальний список гостей
    ├── tasks/                # загальний список завдань
    ├── settings/             # SettingsCubit, SettingsRepository (SharedPreferences)
    └── profile/              # профіль, вибір фото, зміна пароля, налаштування; bloc/ (ProfileCubit)
test/
├── fakes/                    # FakeAuthRepository (тести без Firebase)
├── auth_flow_test.dart       # сценарії входу, реєстрації, профілю
├── events_bloc_test.dart     # завантаження та CRUD у EventsBloc
├── events_flow_test.dart     # списки, фільтр, гість, форма події (віджет-тести)
├── settings_test.dart        # SettingsCubit і SharedPreferences
├── validators_test.dart
└── widget_test.dart
```

## Залежності

`firebase_core`, `firebase_auth`, `firebase_analytics`, `sentry_flutter`,
`flutter_bloc`, `shared_preferences`, `flutter_localizations`.
