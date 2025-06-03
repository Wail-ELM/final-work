import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';
import '../models/challenge_category_adapter.dart';
import '../providers/mood_provider.dart';
import '../providers/user_objective_provider.dart';
import '../services/app_usage_service.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class ChallengeSuggestion {
  final String id;
  final String title;
  final String description;
  final ChallengeCategory category;
  final int targetValue;
  final int estimatedDays;
  final String difficulty; // 'facile', 'moyen', 'difficile'
  final String reason; // Pourquoi ce défi est suggéré
  final List<String> tips;

  ChallengeSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    required this.estimatedDays,
    required this.difficulty,
    required this.reason,
    required this.tips,
  });

  Challenge toChallenge(String userId) {
    return Challenge(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      description: description,
      category: category,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: estimatedDays)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class ChallengeSuggestionService {
  static final ChallengeSuggestionService _instance =
      ChallengeSuggestionService._internal();
  factory ChallengeSuggestionService() => _instance;
  ChallengeSuggestionService._internal();

  // Challenges prédéfinis par catégorie
  final Map<ChallengeCategory, List<ChallengeSuggestion>>
      _predefinedChallenges = {
    ChallengeCategory.screenTime: [
      ChallengeSuggestion(
        id: 'screen_beginner_1',
        title: 'Réduire le temps d\'écran de 30 minutes',
        description:
            'Diminuez votre temps d\'écran quotidien de 30 minutes pendant une semaine',
        category: ChallengeCategory.screenTime,
        targetValue: 30,
        estimatedDays: 7,
        difficulty: 'facile',
        reason: 'Premier pas vers une utilisation plus consciente',
        tips: [
          'Utilisez un minuteur pour vos sessions',
          'Remplacez 30 min d\'écran par une activité physique',
          'Éteignez les notifications non essentielles'
        ],
      ),
      ChallengeSuggestion(
        id: 'screen_intermediate_1',
        title: 'Dimanche détox digital',
        description: 'Passez tous les dimanches sans réseaux sociaux',
        category: ChallengeCategory.screenTime,
        targetValue: 4,
        estimatedDays: 28,
        difficulty: 'moyen',
        reason: 'Pour retrouver du temps de qualité',
        tips: [
          'Planifiez des activités alternatives',
          'Prévenez vos proches',
          'Gardez votre téléphone dans une autre pièce'
        ],
      ),
      ChallengeSuggestion(
        id: 'screen_advanced_1',
        title: 'Mode avion après 21h',
        description: 'Activez le mode avion chaque soir à partir de 21h',
        category: ChallengeCategory.screenTime,
        targetValue: 21,
        estimatedDays: 21,
        difficulty: 'difficile',
        reason: 'Améliorer la qualité de sommeil',
        tips: [
          'Préparez un livre pour la soirée',
          'Utilisez un réveil classique',
          'Chargez votre téléphone hors de la chambre'
        ],
      ),
    ],
    ChallengeCategory.focus: [
      ChallengeSuggestion(
        id: 'focus_beginner_1',
        title: 'Technique Pomodoro quotidienne',
        description:
            'Utilisez la technique Pomodoro (25min focus, 5min pause) une fois par jour',
        category: ChallengeCategory.focus,
        targetValue: 1,
        estimatedDays: 14,
        difficulty: 'facile',
        reason: 'Développer votre capacité de concentration',
        tips: [
          'Commencez par une tâche simple',
          'Éliminez toutes les distractions',
          'Respectez strictement les temps'
        ],
      ),
      ChallengeSuggestion(
        id: 'focus_intermediate_1',
        title: 'Deep Work de 2h quotidiennes',
        description:
            'Bloquez 2h par jour sans interruption pour du travail profond',
        category: ChallengeCategory.focus,
        targetValue: 2,
        estimatedDays: 21,
        difficulty: 'moyen',
        reason: 'Améliorer votre productivité',
        tips: [
          'Choisissez votre meilleur moment de la journée',
          'Informez votre entourage',
          'Préparez tout le matériel nécessaire à l\'avance'
        ],
      ),
    ],
    ChallengeCategory.notifications: [
      ChallengeSuggestion(
        id: 'notif_beginner_1',
        title: 'Mode silencieux pendant les repas',
        description:
            'Mettez votre téléphone en mode silencieux pendant tous les repas',
        category: ChallengeCategory.notifications,
        targetValue: 3,
        estimatedDays: 14,
        difficulty: 'facile',
        reason: 'Retrouver le plaisir des repas conscients',
        tips: [
          'Posez le téléphone loin de la table',
          'Savourez vraiment votre nourriture',
          'Engagez la conversation avec vos proches'
        ],
      ),
      ChallengeSuggestion(
        id: 'notif_intermediate_1',
        title: 'Pas de notifications le matin',
        description:
            'Désactivez toutes les notifications jusqu\'à 10h du matin',
        category: ChallengeCategory.notifications,
        targetValue: 10,
        estimatedDays: 21,
        difficulty: 'moyen',
        reason: 'Commencer la journée sereinement',
        tips: [
          'Créez une routine matinale sans téléphone',
          'Utilisez un réveil traditionnel',
          'Préparez votre journée la veille'
        ],
      ),
    ],
  };

  Future<List<ChallengeSuggestion>> getPersonalizedSuggestions({
    required String userId,
    required MoodStats moodStats,
    required Duration screenTime,
    int maxSuggestions = 6,
  }) async {
    final suggestions = <ChallengeSuggestion>[];

    // Analyse des données utilisateur
    final avgMood = moodStats.averageMood;
    final screenTimeHours = screenTime.inHours;

    // Suggestions basées sur le temps d'écran
    if (screenTimeHours > 6) {
      suggestions.addAll(_getScreenTimeSuggestions('high'));
    } else if (screenTimeHours > 3) {
      suggestions.addAll(_getScreenTimeSuggestions('medium'));
    } else {
      suggestions.addAll(_getScreenTimeSuggestions('low'));
    }

    // Suggestions basées sur l'humeur
    if (avgMood < 3.0) {
      suggestions.addAll(_getMoodBasedSuggestions('low'));
    } else if (avgMood < 4.0) {
      suggestions.addAll(_getMoodBasedSuggestions('medium'));
    } else {
      suggestions.addAll(_getMoodBasedSuggestions('high'));
    }

    // Suggestions générales de focus et notifications
    suggestions.addAll(_getFocusSuggestions());
    suggestions.addAll(_getNotificationSuggestions());

    // Mélanger et limiter
    suggestions.shuffle();
    return suggestions.take(maxSuggestions).toList();
  }

  List<ChallengeSuggestion> _getScreenTimeSuggestions(String level) {
    switch (level) {
      case 'high':
        return [
          _predefinedChallenges[ChallengeCategory.screenTime]![
              0], // Réduction 30min
          _predefinedChallenges[ChallengeCategory.screenTime]![
              1], // Dimanche détox
          _predefinedChallenges[ChallengeCategory.screenTime]![
              2], // Mode avion 21h
        ];
      case 'medium':
        return [
          _predefinedChallenges[ChallengeCategory.screenTime]![
              0], // Réduction 30min
          _predefinedChallenges[ChallengeCategory.screenTime]![
              1], // Dimanche détox
        ];
      case 'low':
        return [
          _predefinedChallenges[ChallengeCategory.screenTime]![
              1], // Dimanche détox
        ];
      default:
        return [];
    }
  }

  List<ChallengeSuggestion> _getMoodBasedSuggestions(String moodLevel) {
    // Si l'humeur est basse, suggérer des défis plus doux
    if (moodLevel == 'low') {
      return [
        ChallengeSuggestion(
          id: 'mood_boost_1',
          title: 'Méditation de 5 minutes quotidienne',
          description:
              'Prenez 5 minutes chaque jour pour méditer ou faire de la respiration consciente',
          category: ChallengeCategory.focus,
          targetValue: 5,
          estimatedDays: 14,
          difficulty: 'facile',
          reason: 'Améliorer votre bien-être mental',
          tips: [
            'Utilisez une app de méditation guidée',
            'Trouvez un endroit calme',
            'Commencez par 2-3 minutes si nécessaire'
          ],
        ),
      ];
    }
    return [];
  }

  List<ChallengeSuggestion> _getFocusSuggestions() {
    return _predefinedChallenges[ChallengeCategory.focus]!.take(2).toList();
  }

  List<ChallengeSuggestion> _getNotificationSuggestions() {
    return _predefinedChallenges[ChallengeCategory.notifications]!
        .take(2)
        .toList();
  }

  List<ChallengeSuggestion> getAllPredefinedChallenges() {
    final all = <ChallengeSuggestion>[];
    _predefinedChallenges.values.forEach((challenges) {
      all.addAll(challenges);
    });
    return all;
  }

  List<ChallengeSuggestion> getChallengesByCategory(
      ChallengeCategory category) {
    return _predefinedChallenges[category] ?? [];
  }

  List<ChallengeSuggestion> getChallengesByDifficulty(String difficulty) {
    final all = getAllPredefinedChallenges();
    return all.where((c) => c.difficulty == difficulty).toList();
  }
}

// Provider pour le service de suggestions
final challengeSuggestionServiceProvider =
    Provider<ChallengeSuggestionService>((ref) {
  return ChallengeSuggestionService();
});

// Provider pour les suggestions personnalisées
final personalizedSuggestionsProvider =
    FutureProvider<List<ChallengeSuggestion>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser == null) return [];

  final suggestionService = ref.watch(challengeSuggestionServiceProvider);
  final moodStats = ref.watch(moodStatsProvider);
  final screenTime = await ref.watch(screenTimeProvider.future);

  return await suggestionService.getPersonalizedSuggestions(
    userId: currentUser.id,
    moodStats: moodStats,
    screenTime: screenTime,
    maxSuggestions: 6,
  );
});

// Provider pour tous les challenges prédéfinis
final predefinedChallengesProvider = Provider<List<ChallengeSuggestion>>((ref) {
  final service = ref.watch(challengeSuggestionServiceProvider);
  return service.getAllPredefinedChallenges();
});
