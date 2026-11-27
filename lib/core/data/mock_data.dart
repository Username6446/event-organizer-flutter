import '../../models/event_model.dart';
import '../../models/guest_model.dart';
import '../../models/task_model.dart';
import '../theme/app_colors.dart';

/// Тестові (hardcoded) дані: стартовий вміст репозиторію подій.
/// У лабораторній №6 їх замінять дані з Cloud Firestore.
abstract final class MockData {
  static GuestModel _guest(
    String id,
    String name,
    String contact, [
    GuestStatus status = GuestStatus.invited,
    String notes = '',
  ]) => GuestModel(
    id: id,
    name: name,
    contact: contact,
    status: status,
    notes: notes,
  );

  static TaskModel _task(
    String id,
    String title, {
    String? assignee,
    DateTime? deadline,
    bool done = false,
  }) => TaskModel(
    id: id,
    title: title,
    assignee: assignee,
    deadline: deadline,
    isCompleted: done,
  );

  static final List<EventModel> events = [
    EventModel(
      id: 'e1',
      title: 'День народження Марти',
      category: 'День народження',
      description:
          'Святкуємо 25-річчя Марти: вечеря, торт і караоке. '
          'Дрес-код — щось яскраве.',
      date: DateTime(2026, 10, 18, 18, 0),
      durationHours: 4,
      location: 'Кафе «Лімончелло», вул. Фредра, 6',
      maxGuests: 15,
      isPrivate: true,
      status: EventStatus.completed,
      gradient: AppColors.gradientPurple,
      guests: [
        _guest(
          'g1',
          'Марта Ковальчук',
          'marta.k@gmail.com',
          GuestStatus.confirmed,
          'Іменинниця',
        ),
        _guest(
          'g2',
          'Ігор Петренко',
          '+380 67 210 33 45',
          GuestStatus.confirmed,
        ),
        _guest(
          'g3',
          'Тарас Савчук',
          't.savchuk@ukr.net',
          GuestStatus.confirmed,
          '+1',
        ),
        _guest(
          'g4',
          'Юлія Лисенко',
          'yulia.lys@gmail.com',
          GuestStatus.declined,
          'У відрядженні',
        ),
        _guest(
          'g5',
          'Дмитро Мельник',
          '+380 93 555 12 09',
          GuestStatus.confirmed,
        ),
      ],
      tasks: [
        _task(
          't1',
          'Забронювати столик',
          assignee: 'Ігор Петренко',
          deadline: DateTime(2026, 10, 10),
          done: true,
        ),
        _task(
          't2',
          'Замовити торт',
          assignee: 'Тарас Савчук',
          deadline: DateTime(2026, 10, 15),
          done: true,
        ),
        _task(
          't3',
          'Купити подарунок',
          deadline: DateTime(2026, 10, 16),
          done: true,
        ),
      ],
    ),
    EventModel(
      id: 'e2',
      title: 'Осінній корпоратив 2026',
      category: 'Корпоратив',
      description:
          'Щорічна осіння зустріч команди: вечеря, нагородження '
          'найкращих працівників року та жива музика. Дрес-код — smart casual.',
      date: DateTime(2026, 11, 28, 19, 0),
      durationHours: 4,
      location: 'Ресторан «Панорама», вул. Городоцька, 12',
      maxGuests: 50,
      gradient: AppColors.gradientTeal,
      guests: [
        _guest(
          'g6',
          'Марія Коваленко',
          'maria.k@company.ua',
          GuestStatus.confirmed,
          'Керівниця відділу',
        ),
        _guest(
          'g7',
          'Ігор Петрук',
          'igor.petruk@company.ua',
          GuestStatus.confirmed,
        ),
        _guest('g8', 'Тарас Сенько', 't.senko@company.ua'),
        _guest(
          'g9',
          'Юлія Василенко',
          'yulia.v@company.ua',
          GuestStatus.confirmed,
          '+1',
        ),
        _guest(
          'g10',
          'Дмитро Мельничук',
          'd.melnychuk@company.ua',
          GuestStatus.declined,
        ),
        _guest('g11', 'Наталія Коваль', 'n.koval@company.ua'),
        _guest(
          'g12',
          'Олег Дмитренко',
          'o.dmytrenko@company.ua',
          GuestStatus.confirmed,
        ),
        _guest('g13', 'Вікторія Гнатюк', 'v.hnatiuk@company.ua'),
      ],
      tasks: [
        _task(
          't4',
          'Забронювати зал у ресторані',
          assignee: 'Марія Коваленко',
          deadline: DateTime(2026, 11, 1),
          done: true,
        ),
        _task(
          't5',
          'Погодити меню з кейтерингом',
          assignee: 'Ігор Петрук',
          deadline: DateTime(2026, 11, 14),
          done: true,
        ),
        _task(
          't6',
          'Скласти програму вечора',
          assignee: 'Марія Коваленко',
          deadline: DateTime(2026, 11, 18),
        ),
        _task(
          't7',
          'Замовити звукове обладнання',
          assignee: 'Тарас Сенько',
          deadline: DateTime(2026, 11, 22),
        ),
        _task(
          't8',
          'Підготувати нагороди працівникам',
          assignee: 'Наталія Коваль',
          deadline: DateTime(2026, 11, 24),
        ),
        _task(
          't9',
          'Оформити фотозону',
          assignee: 'Дмитро Мельничук',
          deadline: DateTime(2026, 11, 26),
        ),
      ],
    ),
    EventModel(
      id: 'e3',
      title: 'Вечір настільних ігор',
      category: 'Дозвілля',
      description:
          'Збираємося пограти в «Каркасон», «Діксіт» і «Мафію». '
          'Кожен приносить снеки.',
      date: DateTime(2026, 11, 25, 16, 0),
      durationHours: 5,
      location: 'Антикафе «Куб», пл. Ринок, 3',
      maxGuests: 10,
      gradient: AppColors.gradientOrange,
      guests: [
        _guest(
          'g14',
          'Максим Гриценко',
          'max.h@gmail.com',
          GuestStatus.confirmed,
        ),
        _guest('g15', 'Влад Остапчук', '@vlad_ost', GuestStatus.confirmed),
        _guest('g16', 'Роман Білик', '+380 50 123 77 01'),
        _guest(
          'g17',
          'Софія Данилюк',
          'sofia.d@gmail.com',
          GuestStatus.confirmed,
        ),
      ],
      tasks: [
        _task(
          't10',
          'Забронювати стіл в антикафе',
          assignee: 'Максим Гриценко',
          deadline: DateTime(2026, 11, 21),
          done: true,
        ),
        _task(
          't11',
          'Взяти «Каркасон» і «Діксіт»',
          assignee: 'Влад Остапчук',
          deadline: DateTime(2026, 11, 25),
        ),
        _task('t12', 'Купити снеки та напої', deadline: DateTime(2026, 11, 25)),
      ],
    ),
    EventModel(
      id: 'e4',
      title: 'Випускний вечір ПЗ-21',
      category: 'Випускний',
      description:
          'Урочиста частина, банкет і дискотека для випускників '
          'та викладачів кафедри.',
      date: DateTime(2026, 12, 5, 17, 0),
      durationHours: 6,
      location: 'Палац мистецтв, вул. Коперника, 17',
      maxGuests: 80,
      gradient: AppColors.gradientBlue,
      guests: [
        _guest(
          'g18',
          'Світлана Руденко',
          's.rudenko@lpnu.ua',
          GuestStatus.confirmed,
          'Куратор групи',
        ),
        _guest(
          'g19',
          'Павло Василишин',
          'p.vasylyshyn@gmail.com',
          GuestStatus.confirmed,
        ),
        _guest('g20', 'Леся Ткачук', 'lesia.t@gmail.com'),
        _guest('g21', 'Андрій Бойко', '+380 96 410 20 30'),
        _guest(
          'g22',
          'Олена Дорош',
          'olena.dorosh@gmail.com',
          GuestStatus.declined,
        ),
        _guest('g23', 'Богдан Захарків', 'b.zakharkiv@gmail.com'),
      ],
      tasks: [
        _task(
          't13',
          'Орендувати зал',
          assignee: 'Світлана Руденко',
          deadline: DateTime(2026, 11, 10),
          done: true,
        ),
        _task(
          't14',
          'Замовити фотографа',
          assignee: 'Павло Василишин',
          deadline: DateTime(2026, 11, 15),
        ),
        _task(
          't15',
          'Скласти програму вечора',
          assignee: 'Леся Ткачук',
          deadline: DateTime(2026, 11, 28),
        ),
        _task(
          't16',
          'Замовити дипломні рамки',
          deadline: DateTime(2026, 12, 1),
        ),
        _task(
          't17',
          'Підготувати відеопривітання',
          assignee: 'Андрій Бойко',
          deadline: DateTime(2026, 12, 3),
        ),
      ],
    ),
    EventModel(
      id: 'e5',
      title: 'Пікнік у Стрийському парку',
      category: 'Пікнік',
      description:
          'Зимовий пікнік із глінтвейном, грилем і настільними іграми.',
      date: DateTime(2026, 12, 13, 12, 0),
      durationHours: 4,
      location: 'Стрийський парк',
      maxGuests: 20,
      gradient: AppColors.gradientGreen,
      isDraft: true,
      guests: [
        _guest('g24', "Катерина Лук'янець", 'kate.l@gmail.com'),
        _guest('g25', 'Михайло Царук', '+380 63 777 88 99'),
      ],
      tasks: [
        _task(
          't18',
          'Купити вугілля та решітку',
          deadline: DateTime(2026, 12, 12),
        ),
        _task('t19', 'Взяти термоси та пледи', assignee: 'Михайло Царук'),
      ],
    ),
    EventModel(
      id: 'e6',
      title: 'Новорічна вечірка',
      category: 'Свято',
      description:
          'Зустрічаємо Новий рік з друзями: секретний Санта, '
          'конкурси і бенгальські вогні.',
      date: DateTime(2026, 12, 27, 20, 0),
      durationHours: 6,
      location: 'Loft Space, вул. Під Дубом, 7',
      maxGuests: 30,
      isPrivate: true,
      gradient: AppColors.gradientMagenta,
      isDraft: true,
      guests: [
        _guest(
          'g26',
          'Оксана Кравець',
          'oksana.k@gmail.com',
          GuestStatus.confirmed,
        ),
        _guest('g27', 'Валентин Бондар', 'v.bondar@gmail.com'),
        _guest('g28', 'Анастасія Савицька', 'a.savytska@gmail.com'),
      ],
      tasks: [
        _task(
          't20',
          'Організувати секретного Санту',
          assignee: 'Оксана Кравець',
          deadline: DateTime(2026, 12, 15),
        ),
        _task('t21', 'Прикрасити лофт', deadline: DateTime(2026, 12, 27)),
      ],
    ),
    EventModel(
      id: 'e7',
      title: 'Воркшоп з гончарства',
      category: 'Воркшоп',
      description:
          'Майстер-клас для початківців. Скасовано через хворобу '
          'майстра, перенесемо на весну.',
      date: DateTime(2026, 11, 15, 11, 0),
      durationHours: 2,
      location: 'Студія «Глина», вул. Лепкого, 4',
      maxGuests: 8,
      status: EventStatus.cancelled,
      gradient: AppColors.gradientOrange,
      guests: [
        _guest(
          'g29',
          'Ірина Павлюк',
          'iryna.p@gmail.com',
          GuestStatus.declined,
        ),
      ],
      tasks: const [],
    ),
  ];

  /// Найближча подія для промо-панелі на екрані входу.
  static EventModel get nextEvent => events[1];
}
