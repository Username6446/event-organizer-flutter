/// Статус відповіді гостя на запрошення (ФВ 7).
enum GuestStatus {
  invited('Очікується'),
  confirmed('Підтверджено'),
  declined('Відхилено');

  const GuestStatus(this.label);

  /// Підпис українською для чіпів і фільтрів.
  final String label;
}

/// Гість події.
class GuestModel {
  const GuestModel({
    required this.id,
    required this.name,
    this.contact = '',
    this.status = GuestStatus.invited,
    this.notes = '',
  });

  final String id;
  final String name;

  /// Email або телефон.
  final String contact;

  final GuestStatus status;

  /// Примітка організатора («Буде з дитиною», «+1»).
  final String notes;

  /// Ініціали для аватара: «Марта Коваль» → «МК».
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }

  GuestModel copyWith({
    String? name,
    String? contact,
    GuestStatus? status,
    String? notes,
  }) {
    return GuestModel(
      id: id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
