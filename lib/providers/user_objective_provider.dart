import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_category_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_usage_service.dart';
import '../providers/mood_provider.dart';
import '../services/auth_service.dart';
import '../models/mood_entry.dart';
import '../services/demo_data_service.dart';
import '../models/screen_time_entry.dart';

// Huidige doelstelling van de gebruiker
final userObjectiveProvider = StateProvider<ChallengeCategory?>((_) => null);

// Provider voor de streak van de gebruiker
final userStreakProvider = Provider<int>((ref) {
  // FORCE MODE DÉMO POUR DÉMONSTRATION TFE
  return 15; // Streak impressionnant de 15 jours

  // Code original commenté:
  /*
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  // Mode démo
  if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
    return 12; // Streak de démo de 12 jours
  }

  final stats = ref.watch(moodStatsProvider);
  // Calculer le streak basé sur les mood entries consécutives
  return _calculateStreak(stats.recentEntries);
  */
});

// Provider voor het scherm tijd
final screenTimeProvider = FutureProvider<Duration>((ref) async {
  // FORCE MODE DÉMO POUR DÉMONSTRATION TFE
  final demoEntries = DemoDataService.generateDemoScreenTimeEntries();
  final today = DateTime.now();
  final todayEntries = demoEntries.where((entry) {
    return entry.date.year == today.year &&
        entry.date.month == today.month &&
        entry.date.day == today.day;
  }).toList();

  if (todayEntries.isEmpty) {
    return const Duration(hours: 4, minutes: 47); // Valeur réaliste
  }

  return todayEntries.fold<Duration>(
    Duration.zero,
    (total, entry) => total + entry.duration,
  );

  // Code original commenté:
  /*
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  // Mode démo
  if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
    final demoEntries = DemoDataService.generateDemoScreenTimeEntries();
    final today = DateTime.now();
    final todayEntries = demoEntries.where((entry) {
      return entry.date.year == today.year &&
             entry.date.month == today.month &&
             entry.date.day == today.day;
    }).toList();
    
    if (todayEntries.isEmpty) {
      return const Duration(hours: 4, minutes: 30); // Valeur par défaut
    }
    
    return todayEntries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );
  }

  try {
    final appUsageService = AppUsageService();
    return await appUsageService.getTotalScreenTimeForDate(DateTime.now());
  } catch (e) {
    // En cas d'erreur, retourner une valeur par défaut
    return const Duration(hours: 2, minutes: 30);
  }
  */
});

// Provider voor het dagelijkse doel
final dailyObjectiveProvider = FutureProvider<String>((ref) async {
  // FORCE MODE DÉMO POUR DÉMONSTRATION TFE
  return "Verminder schermtijd tot onder 4u per dag";

  // Code original commenté:
  /*
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  // Mode démo
  if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
    return "Verminder schermtijd tot onder 4u per dag";
  }

  final stats = ref.watch(moodStatsProvider);
  final screenTime = await ref.watch(screenTimeProvider.future);

  // Générer un objectif basé sur les données de l'utilisateur
  if (screenTime.inHours > 6) {
    return "Focus op drastische vermindering schermtijd";
  } else if (screenTime.inHours > 4) {
    return "Verminder schermtijd met 1u per dag";
  } else if (stats.averageMood < 3.0) {
    return "Focus op verbetering van je stemming";
  } else {
    return "Handhaaf huidige goede gewoonten";
  }
  */
});

// Provider voor wekelijkse voortgang
final weeklyProgressProvider = FutureProvider<double>((ref) async {
  // FORCE MODE DÉMO POUR DÉMONSTRATION TFE
  return 0.78; // Progrès impressionnant de 78%

  // Code original commenté:
  /*
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  // Mode démo - simulation d'un progrès de 75%
  if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
    return 0.75;
  }

  final stats = ref.watch(moodStatsProvider);
  final screenTime = await ref.watch(screenTimeProvider.future);

  // Calculer le progrès basé sur les métriques
  double progress = 0.0;

  // 40% basé sur la stabilité de l'humeur
  if (stats.count > 5) {
    progress += 0.4 * (stats.averageMood / 5.0);
  }

  // 60% basé sur le respect de l'objectif de temps d'écran
  final targetScreenTime = 4 * 60; // 4 heures en minutes
  final actualScreenTime = screenTime.inMinutes;
  if (actualScreenTime <= targetScreenTime) {
    progress += 0.6;
  } else {
    final overage = actualScreenTime - targetScreenTime;
    progress += 0.6 * (1.0 - (overage / targetScreenTime)).clamp(0.0, 1.0);
  }

  return progress.clamp(0.0, 1.0);
  */
});

// Helper functies
int _calculateStreak(List<dynamic> entries) {
  if (entries.isEmpty) return 0;

  int streak = 0;
  final now = DateTime.now();

  for (int i = 0; i < 30; i++) {
    final checkDate = now.subtract(Duration(days: i));
    final hasEntryForDay = entries.any((entry) {
      final entryDate = entry.createdAt;
      return entryDate.year == checkDate.year &&
          entryDate.month == checkDate.month &&
          entryDate.day == checkDate.day;
    });

    if (hasEntryForDay) {
      streak++;
    } else {
      break; // Streak interrompu
    }
  }

  return streak;
}

List<String> _generateDailyObjectives(Duration screenTime) {
  final objectives = <String>[
    "Focus op bewust schermgebruik",
    "Neem pauzes tussen schermtijd",
    "Besteed tijd aan offline activiteiten",
    "Verbind met familie en vrienden",
    "Ga naar buiten voor frisse lucht",
    "Lees een boek in plaats van scrollen",
    "Mediteer 10 minuten vandaag",
    "Doe een digitale detox van 1 uur",
    "Zet notificaties uit tijdens maaltijden",
    "Sluit sociale media voor de avond",
  ];

  // Voeg specifieke doelen toe op basis van schermtijd
  if (screenTime.inHours > 6) {
    objectives.addAll([
      "Probeer schermtijd te reduceren met 30 minuten",
      "Gebruik de 20-20-20 regel",
      "Plan schermvrije tijd voor het slapengaan",
    ]);
  } else if (screenTime.inHours > 4) {
    objectives.addAll([
      "Behoud je goede schermbalans",
      "Focus op kwaliteit boven kwantiteit",
    ]);
  } else {
    objectives.addAll([
      "Geweldig schermgebruik! Behoud dit niveau",
      "Je bent een voorbeeld voor anderen",
    ]);
  }

  return objectives;
}

// Provider voor gebruikersvoorkeuren
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});

class UserPreferences {
  final bool notificationsEnabled;
  final Duration dailyScreenTimeGoal;
  final List<String> focusAreas;

  UserPreferences({
    this.notificationsEnabled = true,
    this.dailyScreenTimeGoal = const Duration(hours: 4),
    this.focusAreas = const ['Focus', 'Ontspanning', 'Sociale contacten'],
  });

  UserPreferences copyWith({
    bool? notificationsEnabled,
    Duration? dailyScreenTimeGoal,
    List<String>? focusAreas,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyScreenTimeGoal: dailyScreenTimeGoal ?? this.dailyScreenTimeGoal,
      focusAreas: focusAreas ?? this.focusAreas,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserPreferences(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      dailyScreenTimeGoal: Duration(
        hours: prefs.getInt('screen_time_goal_hours') ?? 4,
        minutes: prefs.getInt('screen_time_goal_minutes') ?? 0,
      ),
      focusAreas: prefs.getStringList('focus_areas') ??
          ['Focus', 'Ontspanning', 'Sociale contacten'],
    );
  }

  Future<void> updatePreferences(UserPreferences newPreferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'notifications_enabled', newPreferences.notificationsEnabled);
    await prefs.setInt(
        'screen_time_goal_hours', newPreferences.dailyScreenTimeGoal.inHours);
    await prefs.setInt('screen_time_goal_minutes',
        newPreferences.dailyScreenTimeGoal.inMinutes % 60);
    await prefs.setStringList('focus_areas', newPreferences.focusAreas);
    state = newPreferences;
  }
}
