import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/models/mood_entry.dart';

void main() {
  group('MoodEntry model', () {
    final now = DateTime.now();
    final entry = MoodEntry(
      id: 'm1',
      userId: 'u1',
      moodValue: 4,
      note: 'Goed',
      createdAt: now,
    );

    test('eigenschappen basis', () {
      expect(entry.moodValue, 4);
      expect(entry.note, 'Goed');
    });

    test('toJson/fromJson rondje', () {
      final json = entry.toJson();
      final from = MoodEntry.fromJson(json);
      expect(from, equals(entry));
    });

    test('copyWith wijzigt moodValue', () {
      final copy = entry.copyWith(moodValue: 2);
      expect(copy.moodValue, 2);
      expect(copy.id, entry.id);
    });

    test('gelijkheid onderscheidt verschillende instanties', () {
      final other = entry.copyWith(id: 'm2');
      expect(other == entry, false);
    });
  });
}
