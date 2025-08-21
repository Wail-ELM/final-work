import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/services/real_correlation_service.dart';
import 'package:social_balans/models/mood_entry.dart';
import 'package:fl_chart/fl_chart.dart'; // toegevoegd voor FlSpot

void main() {
  group('RealCorrelationService.analyzeRealCorrelation', () {
    final service = RealCorrelationService();

    MoodEntry mood(String id, int value, DateTime dt) => MoodEntry(
          id: id,
          userId: 'u1',
          moodValue: value,
          createdAt: dt,
        );

    test('geeft leeg resultaat bij te weinig data', () {
      final result = service.analyzeRealCorrelation(
        moodEntries: [mood('m1', 3, DateTime.now())],
        screenTimeData: {DateTime.now(): const Duration(hours: 2)},
      );
      expect(result['isEmpty'], true);
      expect(result['correlation'], 0.0);
    });

    test('berekent negatieve correlatie (meer scherm, lagere mood)', () {
      final base = DateTime(2025, 1, 1);
      final moods = [
        mood('m1', 5, base),
        mood('m2', 4, base.add(const Duration(days: 1))),
        mood('m3', 2, base.add(const Duration(days: 2))),
        mood('m4', 1, base.add(const Duration(days: 3))),
      ];
      final screen = {
        base: const Duration(hours: 1),
        base.add(const Duration(days: 1)): const Duration(hours: 2),
        base.add(const Duration(days: 2)): const Duration(hours: 5),
        base.add(const Duration(days: 3)): const Duration(hours: 6),
      };
      final result = service.analyzeRealCorrelation(
        moodEntries: moods,
        screenTimeData: screen,
      );
      expect(result['isEmpty'], false);
      final corr = result['correlation'] as double;
      expect(corr < -0.3, true,
          reason: 'verwacht duidelijke negatieve correlatie');
      // trendline data 2 punten
      final trend = result['trendlineData'] as List;
      expect(trend.length, 2);
      // aanbevelingen aanwezig
      final recs = result['recommendations'] as List;
      expect(recs.isNotEmpty, true);
    });

    test('berekent positieve correlatie (meer scherm, hogere mood)', () {
      final base = DateTime(2025, 2, 1);
      final moods = [
        mood('m1', 1, base),
        mood('m2', 2, base.add(const Duration(days: 1))),
        mood('m3', 4, base.add(const Duration(days: 2))),
        mood('m4', 5, base.add(const Duration(days: 3))),
      ];
      final screen = {
        base: const Duration(hours: 1),
        base.add(const Duration(days: 1)): const Duration(hours: 2),
        base.add(const Duration(days: 2)): const Duration(hours: 3),
        base.add(const Duration(days: 3)): const Duration(hours: 4),
      };
      final result = service.analyzeRealCorrelation(
        moodEntries: moods,
        screenTimeData: screen,
      );
      expect(result['isEmpty'], false);
      final corr = result['correlation'] as double;
      expect(corr > 0.3, true,
          reason: 'verwacht duidelijke positieve correlatie');
    });

    test('geen sterke correlatie', () {
      final base = DateTime(2025, 3, 1);
      final moods = [
        mood('m1', 3, base),
        mood('m2', 4, base.add(const Duration(days: 1))),
        mood('m3', 3, base.add(const Duration(days: 2))),
        mood('m4', 4, base.add(const Duration(days: 3))),
      ];
      final screen = {
        base: const Duration(hours: 2),
        base.add(const Duration(days: 1)): const Duration(hours: 2),
        base.add(const Duration(days: 2)): const Duration(hours: 3),
        base.add(const Duration(days: 3)): const Duration(hours: 3),
      };
      final result = service.analyzeRealCorrelation(
        moodEntries: moods,
        screenTimeData: screen,
      );
      final corr = result['correlation'] as double;
      expect(corr.abs() < 0.3, true, reason: 'verwacht zwakke correlatie');
    });

    test(
        'isEmpty wanneer minder dan 3 dagen overlappen (veel entries zelfde dag)',
        () {
      final base = DateTime(2025, 4, 1);
      final moods = [
        mood('a1', 3, base.add(const Duration(hours: 8))),
        mood('a2', 5, base.add(const Duration(hours: 10))),
        mood('a3', 4, base.add(const Duration(hours: 12))),
      ];
      final screen = {
        base: const Duration(hours: 2)
      }; // slechts 1 dag screen time
      final result = service.analyzeRealCorrelation(
        moodEntries: moods,
        screenTimeData: screen,
      );
      expect(result['isEmpty'], true);
    });

    test('optimalScreenTime kiest dag met hoogste humeur', () {
      final base = DateTime(2025, 5, 1);
      final moods = [
        mood('d1', 3, base),
        mood('d2', 8, base.add(const Duration(days: 1))), // hoogste mood bij 2u
        mood('d3', 5, base.add(const Duration(days: 2))),
        mood('d4', 4, base.add(const Duration(days: 3))),
        mood('d5', 2, base.add(const Duration(days: 4))),
      ];
      final screen = {
        base: const Duration(hours: 1),
        base.add(const Duration(days: 1)): const Duration(hours: 2),
        base.add(const Duration(days: 2)): const Duration(hours: 3),
        base.add(const Duration(days: 3)): const Duration(hours: 4),
        base.add(const Duration(days: 4)): const Duration(hours: 5),
      };
      final result = service.analyzeRealCorrelation(
        moodEntries: moods,
        screenTimeData: screen,
      );
      expect(result['optimalScreenTime'], 2);
    });

    test('onafgemaakte dagen worden genegeerd (alleen doorsnede telt)', () {
      final base = DateTime(2025, 6, 1);
      final moods = [
        mood('m1', 4, base),
        mood('m2', 5, base.add(const Duration(days: 1))),
        mood('m3', 3, base.add(const Duration(days: 2))),
        mood('m4', 2, base.add(const Duration(days: 3))),
      ];
      final screen = {
        base: const Duration(hours: 2),
        base.add(const Duration(days: 1)): const Duration(hours: 2),
        base.add(const Duration(days: 2)): const Duration(hours: 3),
        // extra dag zonder mood
        base.add(const Duration(days: 10)): const Duration(hours: 5),
      };
      final result = service.analyzeRealCorrelation(
        moodEntries: moods,
        screenTimeData: screen,
      );
      final spots = result['correlationSpots'] as List;
      // verwacht 3 overlappende dagen (dag 0,1,2)
      expect(spots.length, 3);
    });

    test('perfecte lineaire relatie levert slope ~ verwacht', () {
      final base = DateTime(2025, 7, 1);
      // mood = 1 + 2 * uren
      final screen = <DateTime, Duration>{};
      final moods = <MoodEntry>[];
      for (int i = 1; i <= 4; i++) {
        final day = base.add(Duration(days: i));
        screen[day] = Duration(hours: i); // x=i
        final moodValue = 1 + 2 * i; // y
        moods.add(mood('lin$i', moodValue, day));
      }
      final result = service.analyzeRealCorrelation(
        moodEntries: moods,
        screenTimeData: screen,
      );
      final trend = result['trendlineData'] as List<FlSpot>;
      expect(trend.length, 2);
      final slope = (trend[1].y - trend[0].y) / (trend[1].x - trend[0].x);
      expect(slope, closeTo(2.0, 0.05));
      final corr = result['correlation'] as double;
      expect(corr > 0.95, true); // bijna perfecte correlatie
    });
  });
}
