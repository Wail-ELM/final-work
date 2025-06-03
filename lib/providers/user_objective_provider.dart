import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_category_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_usage_service.dart';
import '../providers/mood_provider.dart';
import '../services/auth_service.dart';
import '../models/mood_entry.dart';

// Huidige doelstelling van de gebruiker
final userObjectiveProvider = StateProvider<ChallengeCategory?>((_) => null);

// Provider voor de streak van de gebruiker
final userStreakProvider = Provider<int>((ref) {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser == null) return 0;

  // Bereken streak gebaseerd op mood entries
  final moodStats = ref.watch(moodStatsProvider);
  return _calculateStreak(moodStats.recentEntries);
});

// Provider voor het scherm tijd
final screenTimeProvider = FutureProvider<Duration>((ref) async {
  final appUsageService = AppUsageService();
  final today = DateTime.now();
  return await appUsageService.getTotalScreenTimeForDate(today);
});

// Provider voor het dagelijkse doel
final dailyObjectiveProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final storedObjective = prefs.getString('daily_objective');

  if (storedObjective != null) {
    return storedObjective;
  }

  // Genereer objectief gebaseerd op gebruikerspatronen
  final screenTime = await ref.watch(screenTimeProvider.future);
  final objectives = _generateDailyObjectives(screenTime);

  // Sla het objectief op voor vandaag
  final todayKey = DateTime.now().toIso8601String().split('T')[0];
  final lastObjectiveDate = prefs.getString('last_objective_date');

  if (lastObjectiveDate != todayKey) {
    objectives.shuffle();
    final newObjective = objectives.first;
    await prefs.setString('daily_objective', newObjective);
    await prefs.setString('last_objective_date', todayKey);
    return newObjective;
  }

  return "Focus op bewust schermgebruik";
});

// Provider voor wekelijkse voortgang
final weeklyProgressProvider = FutureProvider<double>((ref) async {
  final appUsageService = AppUsageService();
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));

  double totalProgress = 0.0;
  int daysWithData = 0;

  for (int i = 0; i < 7; i++) {
    final date = weekStart.add(Duration(days: i));
    if (date.isAfter(now)) break;

    final screenTime = await appUsageService.getTotalScreenTimeForDate(date);
    if (screenTime.inMinutes > 0) {
      // Bereken dagelijkse voortgang (lager schermtijd = hogere score)
      final dailyGoal = const Duration(hours: 4); // 4 uur per dag doel
      final progress =
          (dailyGoal.inMinutes - screenTime.inMinutes) / dailyGoal.inMinutes;
      totalProgress += progress.clamp(0.0, 1.0);
      daysWithData++;
    }
  }

  return daysWithData > 0 ? totalProgress / daysWithData : 0.0;
});

// Helper functies
int _calculateStreak(List<MoodEntry> moodEntries) {
  if (moodEntries.isEmpty) return 0;

  final now = DateTime.now();
  int streak = 0;

  // Sorteer entries op datum (nieuwste eerst)
  final sortedEntries = moodEntries.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Check voor consecutieve dagen
  DateTime currentDate = DateTime(now.year, now.month, now.day);

  for (final entry in sortedEntries) {
    final entryDate = DateTime(
      entry.createdAt.year,
      entry.createdAt.month,
      entry.createdAt.day,
    );

    if (entryDate == currentDate) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    } else if (entryDate.isBefore(currentDate)) {
      // Gap gevonden, stop streak
      break;
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
