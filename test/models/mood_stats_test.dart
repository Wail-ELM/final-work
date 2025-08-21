import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/models/mood_entry.dart';
import 'package:social_balans/providers/mood_provider.dart';

void main() {
  group('MoodStats.fromEntries', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eightDaysAgo = today.subtract(const Duration(days: 8));

    test('berekent statistieken correct', () {
      // Arrange
      final entries = [
        // Invoeren van vandaag (gemiddelde 4.0)
        MoodEntry(
            id: 't1',
            userId: 'u1',
            moodValue: 5,
            createdAt: today.add(const Duration(hours: 9))),
        MoodEntry(
            id: 't2',
            userId: 'u1',
            moodValue: 3,
            createdAt: today.add(const Duration(hours: 14))),
        // Invoer van gisteren (binnen de week)
        MoodEntry(id: 'y1', userId: 'u1', moodValue: 2, createdAt: yesterday),
        // Invoer van 8 dagen geleden (buiten de week)
        MoodEntry(
            id: 'o1', userId: 'u1', moodValue: 5, createdAt: eightDaysAgo),
      ];

      // Act
      final stats = MoodStats.fromEntries(entries);

      // Assert
      expect(stats.count, 4);
      // Algemeen gemiddelde : (5+3+2+5)/4 = 3.75
      expect(stats.averageMood, 3.75);
      // Stemming van vandaag : (5+3)/2 = 4.0
      expect(stats.todayMood, 4.0);
      // Gemiddelde van de week : (5+3+2)/3 = 3.333...
      expect(stats.lastWeekAverage, closeTo(3.333, 0.001));
    });

    test('lege lijst', () {
      // Arrange
      final entries = <MoodEntry>[];

      // Act
      final stats = MoodStats.fromEntries(entries);

      // Assert
      expect(stats.count, 0);
      expect(stats.averageMood, 0.0);
      expect(stats.todayMood, isNull);
      expect(stats.lastWeekAverage, 0.0);
    });

    test('geen invoer vandaag', () {
      // Arrange
      final entries = [
        MoodEntry(id: 'y1', userId: 'u1', moodValue: 2, createdAt: yesterday),
      ];

      // Act
      final stats = MoodStats.fromEntries(entries);

      // Assert
      expect(stats.count, 1);
      expect(stats.averageMood, 2.0);
      expect(stats.todayMood, isNull);
      expect(stats.lastWeekAverage, 2.0);
    });
  });
}
