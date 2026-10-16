/// Модель користувача-організатора.
class UserModel {
  const UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.eventsCount,
    required this.guestsCount,
    required this.tasksCount,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final int eventsCount;
  final int guestsCount;
  final int tasksCount;

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isEmpty ? '' : firstName[0];
    final last = lastName.isEmpty ? '' : lastName[0];
    return (first + last).toUpperCase();
  }
}
