import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'assessment_model.g.dart';

@HiveType(typeId: 5)
class UserAssessment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final Map<String, double> scores;

  @HiveField(3)
  final AssessmentResult result;

  @HiveField(4)
  final String userId;

  UserAssessment({
    String? id,
    DateTime? createdAt,
    required this.scores,
    required this.result,
    required this.userId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Méthode pour calculer la progression entre deux évaluations
  Map<String, dynamic> calculateProgressionSince(UserAssessment previous) {
    final progression = <String, dynamic>{};

    for (final category in scores.keys) {
      if (previous.scores.containsKey(category)) {
        final diff = scores[category]! - previous.scores[category]!;
        final percentChange = (diff / previous.scores[category]!) * 100;

        progression[category] = {
          'absolute': diff,
          'percent': percentChange,
          'improved': diff > 0,
        };
      }
    }

    // Calcul du score global
    final previousAvg =
        previous.scores.values.reduce((a, b) => a + b) / previous.scores.length;
    final currentAvg = scores.values.reduce((a, b) => a + b) / scores.length;
    final globalDiff = currentAvg - previousAvg;
    final globalPercent = (globalDiff / previousAvg) * 100;

    progression['global'] = {
      'absolute': globalDiff,
      'percent': globalPercent,
      'improved': globalDiff > 0,
    };

    return progression;
  }

  // Factory method pour créer une évaluation à partir des réponses
  factory UserAssessment.fromResponses(
      Map<String, int> responses, String userId) {
    // Calculer les scores par catégorie
    final screenTimeScore = _calculateScreenTimeScore(responses);
    final mindfulnessScore = _calculateMindfulnessScore(responses);
    final wellBeingScore = _calculateWellBeingScore(responses);
    final productivityScore = _calculateProductivityScore(responses);

    // Calculer le score global
    final totalScore = (screenTimeScore +
            mindfulnessScore +
            wellBeingScore +
            productivityScore) /
        4;

    // Déterminer le résultat
    final result = _determineResult(
        screenTimeScore, mindfulnessScore, wellBeingScore, productivityScore);

    return UserAssessment(
      scores: {
        'screenTime': screenTimeScore,
        'mindfulness': mindfulnessScore,
        'wellBeing': wellBeingScore,
        'productivity': productivityScore,
        'total': totalScore,
      },
      result: result,
      userId: userId,
    );
  }

  static double _calculateScreenTimeScore(Map<String, int> responses) {
    // Questions liées au temps d'écran (Q1, Q5, Q9)
    final q1 = responses['Q1'] ?? 0;
    final q5 = responses['Q5'] ?? 0;
    final q9 = responses['Q9'] ?? 0;

    // Algorithme basé sur les recherches en psychologie numérique
    return ((5 - q1) * 0.4 + (5 - q5) * 0.3 + (5 - q9) * 0.3) * 20;
  }

  static double _calculateMindfulnessScore(Map<String, int> responses) {
    // Questions liées à la pleine conscience (Q2, Q6, Q10)
    final q2 = responses['Q2'] ?? 0;
    final q6 = responses['Q6'] ?? 0;
    final q10 = responses['Q10'] ?? 0;

    return (q2 * 0.4 + q6 * 0.3 + q10 * 0.3) * 20;
  }

  static double _calculateWellBeingScore(Map<String, int> responses) {
    // Questions liées au bien-être (Q3, Q7, Q11)
    final q3 = responses['Q3'] ?? 0;
    final q7 = responses['Q7'] ?? 0;
    final q11 = responses['Q11'] ?? 0;

    return (q3 * 0.4 + q7 * 0.3 + q11 * 0.3) * 20;
  }

  static double _calculateProductivityScore(Map<String, int> responses) {
    // Questions liées à la productivité (Q4, Q8, Q12)
    final q4 = responses['Q4'] ?? 0;
    final q8 = responses['Q8'] ?? 0;
    final q12 = responses['Q12'] ?? 0;

    return (q4 * 0.4 + q8 * 0.3 + q12 * 0.3) * 20;
  }

  static AssessmentResult _determineResult(
      double screenTimeScore,
      double mindfulnessScore,
      double wellBeingScore,
      double productivityScore) {
    // Déterminer le profil principal basé sur les scores
    final lowestScore = [
      screenTimeScore,
      mindfulnessScore,
      wellBeingScore,
      productivityScore
    ].reduce((a, b) => a < b ? a : b);

    if (lowestScore == screenTimeScore) {
      return AssessmentResult.screenTimeImbalance;
    } else if (lowestScore == mindfulnessScore) {
      return AssessmentResult.attentionDivided;
    } else if (lowestScore == wellBeingScore) {
      return AssessmentResult.digitalStress;
    } else {
      return AssessmentResult.productivityDisrupted;
    }
  }
}

@HiveType(typeId: 6)
enum AssessmentResult {
  @HiveField(0)
  screenTimeImbalance, // Déséquilibre de temps d'écran

  @HiveField(1)
  attentionDivided, // Attention divisée

  @HiveField(2)
  digitalStress, // Stress numérique

  @HiveField(3)
  productivityDisrupted, // Productivité perturbée

  @HiveField(4)
  balanced // Équilibré (rare pour première évaluation)
}

// Extension pour obtenir des informations sur chaque résultat
extension AssessmentResultExtension on AssessmentResult {
  String get title {
    switch (this) {
      case AssessmentResult.screenTimeImbalance:
        return 'Déséquilibre de Temps d\'Écran';
      case AssessmentResult.attentionDivided:
        return 'Attention Divisée';
      case AssessmentResult.digitalStress:
        return 'Stress Numérique';
      case AssessmentResult.productivityDisrupted:
        return 'Productivité Perturbée';
      case AssessmentResult.balanced:
        return 'Équilibre Numérique';
    }
  }

  String get description {
    switch (this) {
      case AssessmentResult.screenTimeImbalance:
        return 'Votre utilisation des écrans est supérieure à la moyenne et pourrait affecter votre bien-être global. Nous vous aiderons à établir un équilibre plus sain.';
      case AssessmentResult.attentionDivided:
        return 'Vous avez du mal à rester concentré et êtes souvent distrait par les notifications et les interruptions numériques. Nous vous aiderons à retrouver votre focus.';
      case AssessmentResult.digitalStress:
        return 'L\'utilisation de la technologie semble créer du stress et de l\'anxiété dans votre vie quotidienne. Nous vous aiderons à développer une relation plus sereine avec vos appareils.';
      case AssessmentResult.productivityDisrupted:
        return 'Les distractions numériques affectent votre productivité et votre capacité à accomplir vos tâches. Nous vous aiderons à reprendre le contrôle de votre temps.';
      case AssessmentResult.balanced:
        return 'Vous maintenez un bon équilibre dans votre vie numérique. Nous vous aiderons à préserver et améliorer cet équilibre.';
    }
  }

  List<String> get recommendedChallenges {
    switch (this) {
      case AssessmentResult.screenTimeImbalance:
        return [
          'digital_detox_30min',
          'no_phone_morning',
          'app_limits',
        ];
      case AssessmentResult.attentionDivided:
        return [
          'notification_cleanse',
          'single_tasking',
          'focus_sessions',
        ];
      case AssessmentResult.digitalStress:
        return [
          'mindful_usage',
          'evening_wind_down',
          'gratitude_practice',
        ];
      case AssessmentResult.productivityDisrupted:
        return [
          'pomodoro_technique',
          'device_free_work',
          'priority_planning',
        ];
      case AssessmentResult.balanced:
        return [
          'maintenance_routine',
          'mindful_check_ins',
          'tech_boundaries',
        ];
    }
  }
}
