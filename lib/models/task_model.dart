/// Завдання з чек-листа підготовки події (ФВ 8).
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    this.assignee,
    this.deadline,
    this.isCompleted = false,
  });

  final String id;
  final String title;

  /// Ім'я відповідального (зазвичай один із гостей); null — не призначено.
  final String? assignee;

  /// Термін виконання; null — без дедлайну.
  final DateTime? deadline;

  final bool isCompleted;

  /// Дедлайн минув, а завдання ще не виконане.
  bool isOverdue(DateTime now) {
    final deadline = this.deadline;
    return !isCompleted && deadline != null && deadline.isBefore(now);
  }

  TaskModel copyWith({
    String? title,
    String? assignee,
    bool clearAssignee = false,
    DateTime? deadline,
    bool clearDeadline = false,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      assignee: clearAssignee ? null : (assignee ?? this.assignee),
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
