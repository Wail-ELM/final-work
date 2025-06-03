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
  final String difficulty;
  final String reason; 
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

  // Voorgedefinieerde uitdagingen per categorie
  final Map<ChallengeCategory, List<ChallengeSuggestion>>
      _predefinedChallenges = {
    ChallengeCategory.screenTime: [
      ChallengeSuggestion(
        id: 'screen_beginner_1',
        title: 'Verminder schermtijd met 30 minuten',
        description:
            'Verminder je dagelijkse schermtijd met 30 minuten gedurende een week',
        category: ChallengeCategory.screenTime,
        targetValue: 30,
        estimatedDays: 7,
        difficulty: 'makkelijk',
        reason: 'Eerste stap naar bewuster gebruik',
        tips: [
          'Gebruik een timer voor je sessies',
          'Vervang 30 min schermtijd door fysieke activiteit',
          'Schakel niet-essentiële notificaties uit'
        ],
      ),
      ChallengeSuggestion(
        id: 'screen_intermediate_1',
        title: 'Zondag digitale detox',
        description: 'Breng elke zondag door zonder sociale media',
        category: ChallengeCategory.screenTime,
        targetValue: 4,
        estimatedDays: 28,
        difficulty: 'gemiddeld',
        reason: 'Om kwaliteitstijd terug te vinden',
        tips: [
          'Plan alternatieve activiteiten',
          'Informeer je omgeving',
          'Bewaar je telefoon in een andere kamer'
        ],
      ),
      ChallengeSuggestion(
        id: 'screen_advanced_1',
        title: 'Vliegtuigmodus na 21u',
        description: 'Activeer elke avond vliegtuigmodus vanaf 21u',
        category: ChallengeCategory.screenTime,
        targetValue: 21,
        estimatedDays: 21,
        difficulty: 'moeilijk',
        reason: 'Slaapkwaliteit verbeteren',
        tips: [
          'Bereid een boek voor voor de avond',
          'Gebruik een klassieke wekker',
          'Laad je telefoon op buiten de slaapkamer'
        ],
      ),
    ],
    ChallengeCategory.focus: [
      ChallengeSuggestion(
        id: 'focus_beginner_1',
        title: 'Dagelijkse Pomodoro techniek',
        description:
            'Gebruik de Pomodoro techniek (25min focus, 5min pauze) één keer per dag',
        category: ChallengeCategory.focus,
        targetValue: 1,
        estimatedDays: 14,
        difficulty: 'makkelijk',
        reason: 'Je concentratievermogen ontwikkelen',
        tips: [
          'Begin met een eenvoudige taak',
          'Elimineer alle afleidingen',
          'Respecteer strikt de tijden'
        ],
      ),
      ChallengeSuggestion(
        id: 'focus_intermediate_1',
        title: 'Dagelijks 2u Deep Work',
        description: 'Blokkeer 2u per dag zonder onderbreking voor diep werk',
        category: ChallengeCategory.focus,
        targetValue: 2,
        estimatedDays: 21,
        difficulty: 'gemiddeld',
        reason: 'Je productiviteit verbeteren',
        tips: [
          'Kies je beste moment van de dag',
          'Informeer je omgeving',
          'Bereid al het nodige materiaal op voorhand voor'
        ],
      ),
    ],
    ChallengeCategory.notifications: [
      ChallengeSuggestion(
        id: 'notif_beginner_1',
        title: 'Stille modus tijdens maaltijden',
        description: 'Zet je telefoon op stille modus tijdens alle maaltijden',
        category: ChallengeCategory.notifications,
        targetValue: 3,
        estimatedDays: 14,
        difficulty: 'makkelijk',
        reason: 'Het plezier van bewuste maaltijden terugvinden',
        tips: [
          'Leg de telefoon ver van de tafel',
          'Geniet echt van je eten',
          'Ga het gesprek aan met je naasten'
        ],
      ),
      ChallengeSuggestion(
        id: 'notif_intermediate_1',
        title: 'Geen notificaties \'s ochtends',
        description: 'Schakel alle notificaties uit tot 10u \'s ochtends',
        category: ChallengeCategory.notifications,
        targetValue: 10,
        estimatedDays: 21,
        difficulty: 'gemiddeld',
        reason: 'Sereen de dag beginnen',
        tips: [
          'Creëer een ochtendroutine zonder telefoon',
          'Gebruik een traditionele wekker',
          'Bereid je dag de avond ervoor voor'
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

    // Analyse van gebruikersgegevens
    final avgMood = moodStats.averageMood;
    final screenTimeHours = screenTime.inHours;

    // Suggesties gebaseerd op schermtijd
    if (screenTimeHours > 6) {
      suggestions.addAll(_getScreenTimeSuggestions('hoog'));
    } else if (screenTimeHours > 3) {
      suggestions.addAll(_getScreenTimeSuggestions('gemiddeld'));
    } else {
      suggestions.addAll(_getScreenTimeSuggestions('laag'));
    }

    // Suggesties gebaseerd op stemming
    if (avgMood < 3.0) {
      suggestions.addAll(_getMoodBasedSuggestions('laag'));
    } else if (avgMood < 4.0) {
      suggestions.addAll(_getMoodBasedSuggestions('gemiddeld'));
    } else {
      suggestions.addAll(_getMoodBasedSuggestions('hoog'));
    }

    // Algemene focus en notificatie suggesties
    suggestions.addAll(_getFocusSuggestions());
    suggestions.addAll(_getNotificationSuggestions());

    // Mengen en beperken
    suggestions.shuffle();
    return suggestions.take(maxSuggestions).toList();
  }

  List<ChallengeSuggestion> _getScreenTimeSuggestions(String level) {
    switch (level) {
      case 'hoog':
        return [
          _predefinedChallenges[ChallengeCategory.screenTime]![
              0], // Vermindering 30min
          _predefinedChallenges[ChallengeCategory.screenTime]![
              1], // Zondag detox
          _predefinedChallenges[ChallengeCategory.screenTime]![
              2], // Vliegtuigmodus 21u
        ];
      case 'gemiddeld':
        return [
          _predefinedChallenges[ChallengeCategory.screenTime]![
              0], // Vermindering 30min
          _predefinedChallenges[ChallengeCategory.screenTime]![
              1], // Zondag detox
        ];
      case 'laag':
        return [
          _predefinedChallenges[ChallengeCategory.screenTime]![
              1], // Zondag detox
        ];
      default:
        return [];
    }
  }

  List<ChallengeSuggestion> _getMoodBasedSuggestions(String moodLevel) {
    // Als de stemming laag is, zachtere uitdagingen voorstellen
    if (moodLevel == 'laag') {
      return [
        ChallengeSuggestion(
          id: 'mood_boost_1',
          title: 'Dagelijks 5 minuten meditatie',
          description:
              'Neem elke dag 5 minuten om te mediteren of bewust te ademen',
          category: ChallengeCategory.focus,
          targetValue: 5,
          estimatedDays: 14,
          difficulty: 'makkelijk',
          reason: 'Je mentale welzijn verbeteren',
          tips: [
            'Gebruik een begeleide meditatie-app',
            'Zoek een rustige plek',
            'Begin met 2-3 minuten indien nodig'
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

// Provider voor de suggestieservice
final challengeSuggestionServiceProvider =
    Provider<ChallengeSuggestionService>((ref) {
  return ChallengeSuggestionService();
});

// Provider voor gepersonaliseerde suggesties
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

// Provider voor alle voorgedefinieerde uitdagingen
final predefinedChallengesProvider = Provider<List<ChallengeSuggestion>>((ref) {
  final service = ref.watch(challengeSuggestionServiceProvider);
  return service.getAllPredefinedChallenges();
});
