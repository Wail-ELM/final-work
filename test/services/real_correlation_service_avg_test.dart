import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/services/real_correlation_service.dart';
import 'package:social_balans/models/mood_entry.dart';

void main() {
  group('RealCorrelationService moyenne journalière', () {
    final service = RealCorrelationService();
    final base = DateTime(2025, 1, 1);
    // 2 entrées le même jour, mood 2 et 6 => moyenne 4
    final moods = [
      MoodEntry(
          id: 'm1',
          userId: 'u1',
          moodValue: 2,
          createdAt: base.add(const Duration(hours: 8))),
      MoodEntry(
          id: 'm2',
          userId: 'u1',
          moodValue: 6,
          createdAt: base.add(const Duration(hours: 18))),
      MoodEntry(
          id: 'm3',
          userId: 'u1',
          moodValue: 4,
          createdAt: base.add(const Duration(days: 1))),
    ];
    final screen = {
      base: const Duration(hours: 3),
      base.add(const Duration(days: 1)): const Duration(hours: 2),
    };
    test('calcule la vraie moyenne par jour', () {
      final result = service.analyzeRealCorrelation(
        moodEntries: moods,
        screenTimeData: screen,
      );
      final spots = result['correlationSpots'] as List;
      // On attend 2 jours, mood du premier = (2+6)/2 = 4, du second = 4
      expect(spots.length, 2);
      expect(spots[0].y, 4.0);
      expect(spots[1].y, 4.0);
    });
  });
}
