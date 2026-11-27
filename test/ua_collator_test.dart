import 'package:flutter_test/flutter_test.dart';

import 'package:event_organizer/core/utils/ua_collator.dart';

void main() {
  test('імена сортуються за українською абеткою', () {
    final names = ['Ірина', 'Ігор', 'Анастасія', 'Єва', 'Богдан', 'Ґанна']
      ..sort(UaCollator.compare);

    expect(names, ['Анастасія', 'Богдан', 'Ґанна', 'Єва', 'Ігор', 'Ірина']);
  });

  test('регістр не впливає на порядок', () {
    expect(UaCollator.compare('олег', 'Олег'), 0);
    expect(UaCollator.compare('Олег', 'Олександр') < 0, isTrue);
  });
}
