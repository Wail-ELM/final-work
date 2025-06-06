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
        id: 'screen_beginner_2',
        title: 'Schermvrije slaapkamer',
        description:
            'Houd je telefoon en andere schermen buiten de slaapkamer.',
        category: ChallengeCategory.screenTime,
        targetValue: 1,
        estimatedDays: 14,
        difficulty: 'makkelijk',
        reason: 'Verbeter je slaaphygiëne.',
        tips: [
          'Gebruik een traditionele wekker.',
          'Lees een boek voor het slapengaan.',
          'Laad je apparaten \'s nachts op in een andere kamer.'
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
        id: 'screen_intermediate_2',
        title: 'Grijsschaal modus',
        description:
            'Zet je telefoon 3 dagen per week in grijsschaal modus om de aantrekkingskracht te verminderen.',
        category: ChallengeCategory.screenTime,
        targetValue: 3,
        estimatedDays: 21,
        difficulty: 'gemiddeld',
        reason: 'Maakt je telefoon minder verslavend.',
        tips: [
          'Zoek online hoe je dit instelt voor jouw toestel.',
          'Observeer hoe dit je drang om te scrollen beïnvloedt.',
          'Combineer met het verwijderen van onnodige apps.'
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
      ChallengeSuggestion(
        id: 'screen_advanced_2',
        title: 'Verwijder één social media app',
        description:
            'Kies de social media app die je het meest afleidt en verwijder deze voor een maand.',
        category: ChallengeCategory.screenTime,
        targetValue: 1,
        estimatedDays: 30,
        difficulty: 'moeilijk',
        reason: 'Een radicale stap voor maximale focus.',
        tips: [
          'Je kunt de app later altijd opnieuw installeren.',
          'Gebruik de browserversie als je echt iets moet controleren.',
          'Observeer wat je met de teruggewonnen tijd doet.'
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
        id: 'focus_beginner_2',
        title: 'Mindful moment voor werk',
        description:
            'Neem 3 minuten de tijd voor ademhalingsoefeningen voor je aan een belangrijke taak begint.',
        category: ChallengeCategory.focus,
        targetValue: 3,
        estimatedDays: 7,
        difficulty: 'makkelijk',
        reason: 'Verhoogt de kalmte en focus.',
        tips: [
          'Adem 4 seconden in, houd 4 seconden vast, adem 6 seconden uit.',
          'Focus alleen op je ademhaling.',
          'Sluit je ogen voor een beter effect.'
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
      ChallengeSuggestion(
        id: 'focus_intermediate_2',
        title: 'Taak Batching',
        description:
            'Groepeer vergelijkbare kleine taken (e-mails, berichten beantwoorden) en voer ze in één keer uit.',
        category: ChallengeCategory.focus,
        targetValue: 1,
        estimatedDays: 14,
        difficulty: 'gemiddeld',
        reason: 'Verhoogt de efficiëntie en vermindert afleiding.',
        tips: [
          'Plan 1-2 vaste momenten per dag voor e-mail.',
          'Zet notificaties uit buiten deze blokken.',
          'Communiceer je nieuwe werkwijze aan je collega\'s.'
        ],
      ),
      ChallengeSuggestion(
        id: 'focus_advanced_1',
        title: 'Thema Dagen',
        description:
            'Wijd specifieke dagen van de week aan specifieke soorten werk (bv. maandag=planning, dinsdag=creatie).',
        category: ChallengeCategory.focus,
        targetValue: 2,
        estimatedDays: 28,
        difficulty: 'moeilijk',
        reason: 'Vermindert context-switching en verhoogt diepgang.',
        tips: [
          'Analyseer je terugkerende taken.',
          'Groepeer vergelijkbare taken op dezelfde dag.',
          'Wees flexibel, maar probeer je aan het thema te houden.'
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
        id: 'notif_beginner_2',
        title: 'Review Notificatie-instellingen',
        description:
            'Kies 3 apps en bekijk hun notificatie-instellingen. Schakel alles uit wat niet essentieel is.',
        category: ChallengeCategory.notifications,
        targetValue: 3,
        estimatedDays: 3,
        difficulty: 'makkelijk',
        reason: 'Begin met het terugnemen van controle.',
        tips: [
          'Begin met de apps die je het meest storen.',
          'Wees kritisch: heb je deze alert echt nu nodig?',
          'Groepschats zijn vaak de grootste boosdoeners.'
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
      ChallengeSuggestion(
        id: 'notif_advanced_1',
        title: 'Notificatie Audit',
        description:
            'Controleer elke app en schakel alle niet-essentiële notificaties permanent uit.',
        category: ChallengeCategory.notifications,
        targetValue: 1,
        estimatedDays: 1,
        difficulty: 'moeilijk',
        reason: 'Herwin de controle over je aandacht.',
        tips: [
          'Plan een uur in je agenda voor deze taak.',
          'Vraag je af: "Heeft deze app het recht om mij te onderbreken?"',
          'Behoud alleen notificaties van echte mensen (berichten, telefoontjes).'
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
    switch (moodLevel) {
      case 'laag':
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
          ChallengeSuggestion(
            id: 'mood_boost_2',
            title: 'Maak een wandeling van 15 min',
            description:
                'Ga naar buiten en maak een korte wandeling zonder je telefoon te gebruiken.',
            category: ChallengeCategory.screenTime,
            targetValue: 15,
            estimatedDays: 7,
            difficulty: 'makkelijk',
            reason:
                'Fysieke activiteit en natuur hebben een bewezen positief effect.',
            tips: [
              'Luister naar de geluiden om je heen.',
              'Focus op je ademhaling.',
              'Laat je telefoon thuis als het kan.'
            ],
          ),
        ];
      case 'gemiddeld':
        return [
          ChallengeSuggestion(
            id: 'mood_maintain_1',
            title: 'Plan een sociale activiteit',
            description:
                'Plan deze week een offline activiteit met een vriend of familielid.',
            category: ChallengeCategory.focus,
            targetValue: 1,
            estimatedDays: 7,
            difficulty: 'makkelijk',
            reason:
                'Echte sociale connecties zijn een belangrijke factor voor geluk.',
            tips: [
              'Bel iemand op in plaats van te appen.',
              'Stel voor om samen te eten of te sporten.',
              'Kies een activiteit waar praten centraal staat.'
            ],
          ),
        ];
      default:
        return [];
    }
  }

  List<ChallengeSuggestion> _getFocusSuggestions() {
    return _predefinedChallenges[ChallengeCategory.focus]!.toList();
  }

  List<ChallengeSuggestion> _getNotificationSuggestions() {
    return _predefinedChallenges[ChallengeCategory.notifications]!.toList();
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
    screenTime: screenTime ?? Duration.zero,
    maxSuggestions: 6,
  );
});

// Provider voor alle voorgedefinieerde uitdagingen
final predefinedChallengesProvider = Provider<List<ChallengeSuggestion>>((ref) {
  final service = ref.watch(challengeSuggestionServiceProvider);
  return service.getAllPredefinedChallenges();
});
