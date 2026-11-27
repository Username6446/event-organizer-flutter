/// Автентифікований користувач (дані з Firebase Authentication).
///
/// Окремий клас, щоб екрани не залежали від `firebase_auth` напряму.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String? displayName;

  /// HTTPS-посилання на аватар або null, якщо фото не задано.
  final String? photoUrl;

  /// Ім'я для показу: displayName, а якщо його немає — частина email до «@».
  String get name {
    final trimmed = displayName?.trim() ?? '';
    return trimmed.isNotEmpty ? trimmed : email.split('@').first;
  }

  /// Ім'я та прізвище окремо (displayName зберігається одним рядком).
  String get firstName {
    final parts = _nameParts;
    return parts.isEmpty ? '' : parts.first;
  }

  String get lastName {
    final parts = _nameParts;
    return parts.length < 2 ? '' : parts.sublist(1).join(' ');
  }

  String get initials {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }

  List<String> get _nameParts => (displayName ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
}
