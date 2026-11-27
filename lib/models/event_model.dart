import 'package:flutter/material.dart';

import 'guest_model.dart';
import 'task_model.dart';

/// Статус проведення події.
enum EventStatus {
  planned('Заплановано'),
  completed('Завершено'),
  cancelled('Скасовано');

  const EventStatus(this.label);

  final String label;
}

/// Подія разом зі списком гостей і чек-листом завдань.
///
/// Гості й завдання зберігаються всередині події (як документ із
/// вкладеними колекціями), тому лічильники рахуються з реальних даних.
class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.gradient,
    this.description = '',
    this.durationHours = 3,
    this.maxGuests = 50,
    this.isPrivate = false,
    this.status = EventStatus.planned,
    this.coverUrl,
    this.isDraft = false,
    this.guests = const [],
    this.tasks = const [],
  });

  /// Категорії для форми створення події.
  static const List<String> categories = [
    'День народження',
    'Корпоратив',
    'Дозвілля',
    'Випускний',
    'Пікнік',
    'Свято',
    'Воркшоп',
    'Інше',
  ];

  final String id;
  final String title;
  final String category;
  final String description;

  /// Дата й час початку.
  final DateTime date;

  /// Тривалість у годинах.
  final int durationHours;

  final String location;
  final int maxGuests;
  final bool isPrivate;
  final EventStatus status;

  /// Кольори градієнтної обкладинки (використовуються, якщо немає фото).
  final List<Color> gradient;

  /// HTTPS-посилання на обкладинку; null — лише градієнт.
  final String? coverUrl;

  final bool isDraft;
  final List<GuestModel> guests;
  final List<TaskModel> tasks;

  DateTime get endTime => date.add(Duration(hours: durationHours));

  int get guestsCount => guests.length;

  int countGuests(GuestStatus status) =>
      guests.where((g) => g.status == status).length;

  int get confirmedCount => countGuests(GuestStatus.confirmed);

  /// Ініціали перших трьох гостей для «стопки» аватарів.
  List<String> get guestInitials =>
      guests.take(3).map((g) => g.initials).toList();

  /// Скільки гостей не вмістилося у «стопку» (+9).
  int get extraGuests => guests.length > 3 ? guests.length - 3 : 0;

  int get tasksTotal => tasks.length;

  int get tasksDone => tasks.where((t) => t.isCompleted).length;

  double get progress => tasksTotal == 0 ? 0 : tasksDone / tasksTotal;

  EventModel copyWith({
    String? title,
    String? category,
    String? description,
    DateTime? date,
    int? durationHours,
    String? location,
    int? maxGuests,
    bool? isPrivate,
    EventStatus? status,
    List<Color>? gradient,
    String? coverUrl,
    bool clearCover = false,
    bool? isDraft,
    List<GuestModel>? guests,
    List<TaskModel>? tasks,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      durationHours: durationHours ?? this.durationHours,
      location: location ?? this.location,
      maxGuests: maxGuests ?? this.maxGuests,
      isPrivate: isPrivate ?? this.isPrivate,
      status: status ?? this.status,
      gradient: gradient ?? this.gradient,
      coverUrl: clearCover ? null : (coverUrl ?? this.coverUrl),
      isDraft: isDraft ?? this.isDraft,
      guests: guests ?? this.guests,
      tasks: tasks ?? this.tasks,
    );
  }
}
