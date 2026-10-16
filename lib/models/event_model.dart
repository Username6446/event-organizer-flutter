import 'package:flutter/material.dart';

/// Модель події (поки що без бізнес-логіки — лише дані для відображення).
class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.guestInitials,
    required this.extraGuests,
    required this.tasksDone,
    required this.tasksTotal,
    required this.gradient,
    this.isDraft = false,
  });

  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String location;

  /// Ініціали перших гостей для «стопки» аватарів.
  final List<String> guestInitials;

  /// Скільки ще гостей не показано (+9).
  final int extraGuests;

  final int tasksDone;
  final int tasksTotal;

  /// Кольори градієнтної шапки картки.
  final List<Color> gradient;

  final bool isDraft;

  int get guestsCount => guestInitials.length + extraGuests;

  double get progress => tasksTotal == 0 ? 0 : tasksDone / tasksTotal;
}
