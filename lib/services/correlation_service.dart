import 'package:fl_chart/fl_chart.dart';

class CorrelationService {
  Map<String, dynamic> analyzeCorrelation(
      List<dynamic> moodEntries, List<dynamic> screenTimeData) {
    // This is a dummy implementation that returns mock data.
    // In a real application, this service would perform statistical analysis.
    return {
      'correlation': -0.45,
      'moodData': [
        const FlSpot(1, 4),
        const FlSpot(2, 3),
        const FlSpot(3, 5),
        const FlSpot(4, 2),
        const FlSpot(5, 3),
        const FlSpot(6, 4),
        const FlSpot(7, 3),
      ],
      'screenTimeData': [
        const FlSpot(2, 4),
        const FlSpot(4, 3),
        const FlSpot(1, 5),
        const FlSpot(5, 2),
        const FlSpot(3, 3),
        const FlSpot(2, 4),
        const FlSpot(4, 3),
      ],
      'trendlineData': [
        const FlSpot(0, 4.2),
        const FlSpot(8, 2.8),
      ],
      'significantApps': [
        {'name': 'TikTok', 'impact': -0.3, 'isPositive': false},
        {'name': 'Instagram', 'impact': -0.25, 'isPositive': false},
      ],
      'optimalScreenTime': 2,
      'recommendations': [
        'Un temps d\'écran élevé semble correspondre à une humeur plus basse.',
        'Essayez de limiter le temps passé sur TikTok et Instagram.',
        'Votre humeur est optimale autour de 2 heures d\'écran par jour.',
      ],
    };
  }
}
