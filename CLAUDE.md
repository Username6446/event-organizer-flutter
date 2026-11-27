# Eventory — органайзер невеликих подій

Навчальний Flutter-проєкт (варіант 14, курс «Кросплатформне програмування»,
НУ «Львівська політехніка»). Застосунок для планування невеликих подій:
гості, завдання, розклад.

- Цільова платформа: **лише Web** (Chrome / Edge). Папок `android/`, `ios/` немає.
- Flutter 3.47.4, Dart ^3.13.3. Матеріали лабораторних лежать у `docs/context`
  (методички та звіти) — це довідка, а не код.
- Поточний етап: Лабораторна №5 (локальні дані та керування станом), гілка `lab5`.

## Рішення для Лаби 5 (за методичкою та макетами Лаби 2)

- Керування станом — **BLoC** (`flutter_bloc`): `LoginBloc` (вхід/реєстрація), `AuthSessionCubit`
  (сесія), `ProfileCubit` (профіль), `EventsBloc` (завантаження та CRUD подій, гостей, завдань),
  `SettingsCubit` (налаштування). Репозиторії — через `RepositoryProvider`, блоки — через
  `BlocProvider`; усе над `MaterialApp` (див. `app.dart`), лише `ProfileCubit` — у `MainShell`.
- Дані подій: інтерфейс `EventRepository` + `InMemoryEventRepository` (захардкоджені `MockData`,
  затримка 600 мс). Гості й завдання вкладені в `EventModel`. У Лабі 6 — заміна на Firestore.
- Локальне сховище: `shared_preferences` через `SettingsRepository` (сортування, фільтр статусу,
  вигляд списку, перемикачі в профілі, email для «Запам'ятати мене»).
- Ефемерний стан (поля форм, вибрана вкладка, пошук, локальні фільтри) — `setState`.
- Екрани: «Події» (CustomScrollView + SliverGrid/SliverList), деталі події (SliverAppBar + вкладки
  «Гості»/«Завдання»/«Інформація»), форма створення/редагування, загальні «Гості» й «Завдання».
- Завантаження обкладинок/файлів не робимо (Лаба 6): обкладинка — градієнт або HTTPS-посилання.

## Рішення для Лаби 4 (за звітом Лаби 2 і методичкою)

- Вхід і реєстрація: лише email/password (Firebase Auth). Соцмережі у ФВ Лаби 2 не передбачені, тому їх не додаємо.
- Скидання пароля: лист із посиланням від Firebase (`sendPasswordResetEmail`).
- Профіль: ім'я, аватар за HTTPS-посиланням (готові зображення або власне посилання з попереднім переглядом), зміна пароля з повторною автентифікацією. Завантаження файлів у сховище не робимо (Лаба 6).
- Заглушки допустимі для Firestore, push-сповіщень і статистики.
- Analytics — `firebase_analytics`; Crashlytics на web недоступний, тому `sentry_flutter`.
- Взаємодію з Firebase виносимо в `AuthRepository`; усі форми — через `Form` + `GlobalKey<FormState>`.

## Мова

- **Усі повідомлення користувачу — українською**: тексти в UI, SnackBar, помилки
  валідації, підписи, відповіді в чаті, повідомлення комітів.
- Ідентифікатори в коді — англійською. Коментарі й doc-коментарі (`///`) — українською.

## Структура `lib/`

```
lib/
├── main.dart          # SentryFlutter.init + Firebase.initializeApp, запуск
├── app.dart           # RepositoryProvider/BlocProvider, MaterialApp, тема, AuthGate
├── firebase_options.dart  # згенеровано flutterfire configure (не редагувати)
├── core/
│   ├── config/        # AppConfig: SENTRY_DSN з --dart-define-from-file=env.json
│   ├── data/          # MockData — стартові (hardcoded) події з гостями й завданнями
│   ├── services/      # AnalyticsService (Firebase Analytics), ErrorReporter (Sentry)
│   ├── theme/         # app_colors, app_spacing (AppSpacing, AppRadius, AppBreakpoints), app_theme
│   ├── utils/         # validators, snackbar (showAppSnackBar), ua_date_format, id_generator
│   └── widgets/       # перевикористовувані віджети (AppButton, AppTextField, PasswordField, SectionCard ...)
├── models/            # AppUser (з Firebase), EventModel, GuestModel, TaskModel, DashboardStat
└── features/          # екрани, згруповані за функціями
    ├── auth/          # AuthGate, вхід/реєстрація, відновлення пароля; bloc/ — LoginBloc, AuthSessionCubit; data/ — AuthRepository
    ├── events/        # список, деталі, форма події; bloc/ — EventsBloc; data/ — EventRepository; widgets/ — плитки й діалоги
    ├── guests/        # загальний список гостей
    ├── tasks/         # загальний список завдань
    ├── settings/      # SettingsCubit, SettingsRepository (SharedPreferences), AppSettings
    ├── shell/         # MainShell: NavigationRail (>=600 px) / NavigationBar
    ├── home/          # дашборд
    └── profile/       # профіль, зміна пароля; bloc/ — ProfileCubit; widgets/ — налаштування, вибір фото
```

Нові екрани — у `features/<назва>/`, спільні віджети — у `core/widgets/`.
Для роботи з Firebase — окремий шар (репозиторії/сервіси), а не виклики з віджетів напряму.

## Стиль коду

- Навігація: `Navigator` + `MaterialPageRoute` (без роутерних пакетів).
- State management: BLoC/Cubit для app state (див. «Рішення для Лаби 5»), `setState` — лише для
  ефемерного стану. Одноразові дії (SnackBar, навігація) — у `BlocListener`, UI — у `BlocBuilder`.
- Адаптивність: `LayoutBuilder` / `MediaQuery`, пороги — `AppBreakpoints`.
  Використовувати токени `AppColors`, `AppSpacing`, `AppRadius`, а не «магічні» числа й кольори.
- Material 3, шрифт `AppRoboto` (локальні файли в `assets/fonts`, без Google Fonts).
- Віджети — `const`, де можливо; `TextEditingController` завжди `dispose()`.
- Дотримуватися `flutter_lints`; перед завершенням завдання запускати `dart analyze`
  (`flutter analyze` падає через кирилицю в шляху проєкту) і `flutter test`.
- Залежності беруться з дерева віджетів (`context.read<AuthRepository>()` тощо);
  у тестах `EventOrganizerApp` отримує `FakeAuthRepository`, `InMemoryEventRepository(latency: Duration.zero)`,
  `SettingsRepository` поверх `SharedPreferences.setMockInitialValues({})` і `AnalyticsService.disabled()`.
- Помилки Firebase перетворюються на `AuthFailure` (текст українською, поле для підсвічування).
- Файли й класи: `snake_case.dart` / `UpperCamelCase`; приватні допоміжні віджети — у тому ж файлі.

## Команди

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
dart analyze
flutter test
```

## Git

- `main` — стабільна гілка, лабораторна №4 — у гілці `lab4`, №5 — у `lab5`.
- Sentry DSN лежить у `env.json` (у .gitignore); шаблон — `env.example.json`.
- Обговорювати з користувачем, чи комітити `firebase_options.dart`.
