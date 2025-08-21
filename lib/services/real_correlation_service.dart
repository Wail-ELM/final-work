import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import '../models/mood_entry.dart';
import '../models/screen_time_entry.dart';

/// Service d'analyse statistique pour calculer les corrélations réelles
/// entre les données de l'utilisateur.
class RealCorrelationService {
  /// Analyse la corrélation entre les entrées d'humeur et les données de temps d'écran.
  Map<String, dynamic> analyzeRealCorrelation({
    required List<MoodEntry> moodEntries,
    required Map<DateTime, Duration> screenTimeData,
  }) {
    // 1. Préparer les données pour l'analyse
    final (moodValues, screenTimeValues) =
        _prepareDataForAnalysis(moodEntries, screenTimeData);

    // Exiger au moins 2 jours qui se recoupent pour produire un résultat utile
    if (moodValues.length < 2) {
      return _getEmptyResult('Niet genoeg dagen met overeenkomende gegevens.');
    }

    // 2. Calculer le coefficient de corrélation de Pearson
    final double correlation =
        _calculatePearsonCorrelation(moodValues, screenTimeValues);

    // 3. Calculer la ligne de tendance (régression linéaire simple)
    final (slope, intercept) =
        _calculateLinearRegression(screenTimeValues, moodValues);

    // 4. Créer les points pour le graphique
    final List<FlSpot> spots = IterableZip([screenTimeValues, moodValues])
        .map((e) => FlSpot(e[0], e[1]))
        .toList();

    // 5. Créer les points pour la ligne de tendance
    final double minX = screenTimeValues.reduce(min);
    final double maxX = screenTimeValues.reduce(max);
    final List<FlSpot> trendlineSpots = [
      FlSpot(minX, slope * minX + intercept),
      FlSpot(maxX, slope * maxX + intercept),
    ];

    // 6. Analyser l'impact et générer des recommandations
    final insights = _generateInsights(correlation, spots, screenTimeData);

    return {
      'correlation': correlation.isNaN ? 0.0 : correlation,
      'trendlineData': trendlineSpots,
      'correlationSpots': spots,
      'significantApps': insights['significantApps'],
      'optimalScreenTime': insights['optimalScreenTime'],
      'recommendations': insights['recommendations'],
      'isEmpty': false,
    };
  }

  /// Prépare et aligne les données d'humeur et de temps d'écran par jour.
  (List<double> mood, List<double> screenTime) _prepareDataForAnalysis(
      List<MoodEntry> moodEntries, Map<DateTime, Duration> screenTimeData) {
    // Accumulate sum and count per day to compute a TRUE average of moods per day
    final Map<DateTime, double> dailyMoodSums = {};
    final Map<DateTime, int> dailyMoodCounts = {};
    for (var entry in moodEntries) {
      final day = DateTime(
          entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      dailyMoodSums.update(day, (sum) => sum + entry.moodValue.toDouble(),
          ifAbsent: () => entry.moodValue.toDouble());
      dailyMoodCounts.update(day, (count) => count + 1, ifAbsent: () => 1);
    }

    final List<double> moodValues = [];
    final List<double> screenTimeValues = [];

    dailyMoodSums.forEach((date, sum) {
      final screenTimeDate = DateTime(date.year, date.month, date.day);
      if (screenTimeData.containsKey(screenTimeDate)) {
        final count = dailyMoodCounts[date] ?? 1;
        final avgMood = sum / count;
        moodValues.add(avgMood);
        // Convertir en heures pour l'analyse
        screenTimeValues.add(screenTimeData[screenTimeDate]!.inMinutes / 60.0);
      }
    });

    return (moodValues, screenTimeValues);
  }

  /// Calcule le coefficient de corrélation de Pearson.
  /// Résultat entre -1 (corrélation négative parfaite) et 1 (corrélation positive parfaite).
  double _calculatePearsonCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return 0.0;

    final double meanX = x.average;
    final double meanY = y.average;

    double numerator = 0.0;
    double sumXSquared = 0.0;
    double sumYSquared = 0.0;

    for (int i = 0; i < x.length; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      numerator += diffX * diffY;
      sumXSquared += pow(diffX, 2);
      sumYSquared += pow(diffY, 2);
    }

    final double denominator = sqrt(sumXSquared * sumYSquared);
    return denominator == 0 ? 0 : numerator / denominator;
  }

  /// Calcule la pente (slope) et l'ordonnée à l'origine (intercept) pour une régression linéaire.
  (double slope, double intercept) _calculateLinearRegression(
      List<double> x, List<double> y) {
    final n = x.length;
    final sumX = x.sum;
    final sumY = y.sum;
    final sumXY = IterableZip([x, y]).map((e) => e[0] * e[1]).sum;
    final sumX2 = x.map((e) => e * e).sum;

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return (slope.isNaN ? 0.0 : slope, intercept.isNaN ? y.average : intercept);
  }

  /// Génère des insights et recommandations basés sur les résultats.
  Map<String, dynamic> _generateInsights(double correlation, List<FlSpot> spots,
      Map<DateTime, Duration> screenTimeData) {
    // Pour l'instant, on retourne des recommandations génériques.
    // Une future version pourrait analyser les applications spécifiques.
    List<String> recommendations = [];
    if (correlation < -0.3) {
      recommendations.add(
          'Een hoge schermtijd lijkt samen te hangen met een lagere stemming.');
      recommendations.add('Stel limieten in voor de meest gebruikte apps.');
    } else if (correlation > 0.3) {
      recommendations
          .add('Je schermgebruik lijkt je stemming niet te schaden.');
      recommendations.add('Blijf apps gebruiken die je positiviteit verhogen.');
    } else {
      recommendations
          .add('Je stemming en schermtijd lijken niet sterk gekoppeld.');
    }

    // Estimer le temps d'écran optimal (simplifié)
    final optimalSpot =
        spots.isNotEmpty ? spots.reduce((a, b) => a.y > b.y ? a : b) : null;

    return {
      'significantApps': [], // TODO: Implémenter l'analyse par application
      'optimalScreenTime': optimalSpot?.x.round() ?? 3,
      'recommendations': recommendations,
    };
  }

  /// Retourne un résultat vide avec un message explicatif.
  Map<String, dynamic> _getEmptyResult(String reason) {
    return {
      'correlation': 0.0,
      'trendlineData': <FlSpot>[],
      'correlationSpots': <FlSpot>[],
      'significantApps': [],
      'optimalScreenTime': 0,
      'recommendations': [
        reason,
        'Blijf je humeur en schermtijd registreren voor een nauwkeurigere analyse.'
      ],
      'isEmpty': true,
    };
  }
}
