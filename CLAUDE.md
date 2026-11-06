# Eventory — органайзер невеликих подій

Навчальний Flutter-проєкт (варіант 14, курс «Кросплатформне програмування»,
НУ «Львівська політехніка»). Застосунок для планування невеликих подій:
гості, завдання, розклад.

- Цільова платформа: **лише Web** (Chrome / Edge). Папок `android/`, `ios/` немає.
- Flutter 3.47.4, Dart ^3.13.3. Матеріали лабораторних лежать у `docs/context`
  (методички та звіти) — це довідка, а не код.
- Поточний етап: Лабораторна №4 (автентифікація та інтеграція з Firebase), гілка `lab4`.

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
├── app.dart           # MaterialApp, тема, AuthGate, observer Analytics
├── firebase_options.dart  # згенеровано flutterfire configure (не редагувати)
├── core/
│   ├── config/        # AppConfig: SENTRY_DSN з --dart-define-from-file=env.json
│   ├── data/          # mock-дані (MockData) — заглушки статистики й подій
│   ├── services/      # AnalyticsService (Firebase Analytics), ErrorReporter (Sentry)
│   ├── theme/         # app_colors, app_spacing (AppSpacing, AppRadius, AppBreakpoints), app_theme
│   ├── utils/         # validators, snackbar (showAppSnackBar), ua_date_format
│   └── widgets/       # перевикористовувані віджети (AppButton, AppTextField, PasswordField, SectionCard ...)
├── models/            # AppUser (з Firebase), UserModel, EventModel, DashboardStat
└── features/          # екрани, згруповані за функціями
    ├── auth/          # AuthGate, вхід/реєстрація, відновлення пароля; data/ — AuthRepository
    ├── shell/         # MainShell: NavigationRail (>=600 px) / NavigationBar
    ├── home/          # дашборд
    ├── profile/       # профіль, зміна пароля (+ widgets/)
    └── placeholder/   # заглушка для майбутніх розділів
```

Нові екрани — у `features/<назва>/`, спільні віджети — у `core/widgets/`.
Для роботи з Firebase — окремий шар (репозиторії/сервіси), а не виклики з віджетів напряму.

## Стиль коду

- Навігація: `Navigator` + `MaterialPageRoute` (без роутерних пакетів).
- State management: `StatefulWidget` + `setState` (для автентифікації допускається
  `Stream` від `FirebaseAuth.authStateChanges()` через `StreamBuilder`).
- Адаптивність: `LayoutBuilder` / `MediaQuery`, пороги — `AppBreakpoints`.
  Використовувати токени `AppColors`, `AppSpacing`, `AppRadius`, а не «магічні» числа й кольори.
- Material 3, шрифт `AppRoboto` (локальні файли в `assets/fonts`, без Google Fonts).
- Віджети — `const`, де можливо; `TextEditingController` завжди `dispose()`.
- Дотримуватися `flutter_lints`; перед завершенням завдання запускати `dart analyze`
  (`flutter analyze` падає через кирилицю в шляху проєкту) і `flutter test`.
- Екрани отримують `AuthRepository` / `AnalyticsService` через конструктор;
  у тестах — `test/fakes/fake_auth_repository.dart` і `AnalyticsService.disabled()`.
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

- `main` — стабільна гілка, лабораторна №4 — у гілці `lab4`.
- Sentry DSN лежить у `env.json` (у .gitignore); шаблон — `env.example.json`.
- Обговорювати з користувачем, чи комітити `firebase_options.dart`.
