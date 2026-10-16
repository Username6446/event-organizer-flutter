import 'package:flutter/material.dart';

import '../../models/dashboard_stat.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../theme/app_colors.dart';

/// Тестові (hardcoded) дані для відображення інтерфейсу.
/// У наступних лабораторних їх замінять дані з бекенду.
abstract final class MockData {
  static const UserModel currentUser = UserModel(
    firstName: 'Олена',
    lastName: 'Коваль',
    email: 'olena.koval@gmail.com',
    phone: '+380 67 123 45 67',
    role: 'Організаторка',
    eventsCount: 12,
    guestsCount: 148,
    tasksCount: 36,
  );

  static const List<DashboardStat> stats = [
    DashboardStat(
      label: 'Усього подій',
      value: '12',
      delta: '+3',
      icon: Icons.event,
      iconBackground: AppColors.primaryContainer,
      iconColor: AppColors.primary,
    ),
    DashboardStat(
      label: 'Цього тижня',
      value: '3',
      delta: '+1',
      icon: Icons.today,
      iconBackground: AppColors.pinkContainer,
      iconColor: AppColors.onPinkContainer,
    ),
    DashboardStat(
      label: 'Гостей запрошено',
      value: '148',
      delta: '+24',
      icon: Icons.people,
      iconBackground: AppColors.greenContainer,
      iconColor: AppColors.onGreenContainer,
    ),
    DashboardStat(
      label: 'Відкриті завдання',
      value: '9',
      delta: '-4',
      icon: Icons.task_alt,
      iconBackground: AppColors.orangeContainer,
      iconColor: AppColors.onOrangeContainer,
    ),
  ];

  static final List<EventModel> events = [
    EventModel(
      id: 'e1',
      title: 'День народження Марти',
      category: 'День народження',
      date: DateTime(2026, 10, 18, 18, 0),
      location: 'Кафе «Лімончелло»',
      guestInitials: const ['МК', 'ІП', 'ТС'],
      extraGuests: 9,
      tasksDone: 5,
      tasksTotal: 8,
      gradient: AppColors.gradientPurple,
    ),
    EventModel(
      id: 'e2',
      title: 'Осінній корпоратив 2026',
      category: 'Корпоратив',
      date: DateTime(2026, 10, 24, 19, 0),
      location: 'Ресторан «Панорама»',
      guestInitials: const ['АБ', 'ОД', 'ВГ'],
      extraGuests: 45,
      tasksDone: 9,
      tasksTotal: 14,
      gradient: AppColors.gradientTeal,
    ),
    EventModel(
      id: 'e3',
      title: 'Вечір настільних ігор',
      category: 'Дозвілля',
      date: DateTime(2026, 10, 26, 16, 0),
      location: 'Антикафе «Куб»',
      guestInitials: const ['ЮЛ', 'ДМ', 'НК'],
      extraGuests: 5,
      tasksDone: 3,
      tasksTotal: 3,
      gradient: AppColors.gradientOrange,
    ),
    EventModel(
      id: 'e4',
      title: 'Випускний вечір ПЗ-21',
      category: 'Випускний',
      date: DateTime(2026, 11, 1, 17, 0),
      location: 'Палац мистецтв',
      guestInitials: const ['СР', 'ПВ', 'ЛТ'],
      extraGuests: 61,
      tasksDone: 4,
      tasksTotal: 12,
      gradient: AppColors.gradientBlue,
    ),
    EventModel(
      id: 'e5',
      title: 'Пікнік у Стрийському парку',
      category: 'Пікнік',
      date: DateTime(2026, 11, 9, 12, 0),
      location: 'Стрийський парк',
      guestInitials: const ['КЛ', 'МЦ', 'ГЗ'],
      extraGuests: 12,
      tasksDone: 2,
      tasksTotal: 6,
      gradient: AppColors.gradientGreen,
      isDraft: true,
    ),
    EventModel(
      id: 'e6',
      title: 'Новорічна вечірка',
      category: 'Свято',
      date: DateTime(2026, 12, 27, 20, 0),
      location: 'Loft Space, вул. Під Дубом, 7',
      guestInitials: const ['ОК', 'ВБ', 'АС'],
      extraGuests: 27,
      tasksDone: 1,
      tasksTotal: 10,
      gradient: AppColors.gradientMagenta,
      isDraft: true,
    ),
  ];

  /// Найближча подія для промо-панелі на екрані входу.
  static EventModel get nextEvent => events.first;
}
