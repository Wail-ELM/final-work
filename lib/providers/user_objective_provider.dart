import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import main.dart to get access to sharedPreferencesProvider
import '../models/challenge_category_adapter.dart';
import '../services/app_usage_service.dart';
import '../providers/mood_provider.dart';
import '../providers/auth_provider.dart';
import '../services/demo_data_service.dart';
import '../services/user_data_service.dart';

// Define the new AppUsageService provider
final appUsageServiceProvider = Provider<AppUsageService>((ref) {
  return AppUsageService(ref);
});

// Huidige doelstelling van de gebruiker
final userObjectiveProvider = StateProvider<ChallengeCategory?>((_) => null);

// Provider voor de streak van de gebruiker
final userStreakProvider = Provider<int>((ref) {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  // Mode démo
  if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
    return 12; // Streak de démo de 12 jours
  }

  final stats = ref.watch(moodStatsProvider);
  // Calculer le streak basé sur les mood entries consécutives
  return _calculateStreak(stats.recentEntries);
});

// Provider voor het scherm tijd
final screenTimeProvider = FutureProvider<Duration?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  final appUsageService = ref.watch(appUsageServiceProvider);

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
      return const Duration(hours: 4, minutes: 30);
    }

    return todayEntries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );
  }

  try {
    final result =
        await appUsageService.getTotalScreenTimeForDate(DateTime.now());
    return result;
  } catch (e) {
    // En cas d'erreur, retourner null pour indiquer l'indisponibilité
    print('Erreur lors de la récupération du temps d\'écran: $e');
    return null;
  }
});

// Provider for weekly screen time data (last 7 days)
final weeklyScreenTimeDataProvider =
    FutureProvider<Map<DateTime, Duration>>((ref) async {
  final appUsageService = ref.watch(appUsageServiceProvider);
  // Fetch data for the week ending today
  final endDate = DateTime.now();
  return await appUsageService.getWeeklyScreenTimeData(endDate);
});

// Provider for daily total screen time over a specified period
final periodicScreenTimeDataProvider = FutureProvider.family<
    Map<DateTime, Duration>, ({DateTime startDate, DateTime endDate})>(
  (ref, dateRange) async {
    final appUsageService = ref.watch(appUsageServiceProvider);
    // Call the new method in AppUsageService
    return await appUsageService.getDailyTotalScreenTimeForPeriod(
      dateRange.startDate,
      dateRange.endDate,
    );
  },
);

// Provider voor het dagelijkse doel
final dailyObjectiveProvider = FutureProvider<String>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  // Mode démo
  if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
    return "Verminder schermtijd tot onder 4u per dag";
  }

  final stats = ref.watch(moodStatsProvider);
  final screenTime = await ref.watch(screenTimeProvider.future);

  // Générer un objectif basé sur les données de l'utilisateur
  if ((screenTime?.inHours ?? 0) > 6) {
    return "Focus op drastische vermindering schermtijd";
  } else if ((screenTime?.inHours ?? 0) > 4) {
    return "Verminder schermtijd met 1u per dag";
  } else if (stats.averageMood < 3.0) {
    return "Focus op verbetering van je stemming";
  } else {
    return "Handhaaf huidige goede gewoonten";
  }
});

// Provider voor wekelijkse voortgang
final weeklyProgressProvider = FutureProvider<double>((ref) async {
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
  final actualScreenTime = screenTime?.inMinutes ?? 0;
  if (actualScreenTime <= targetScreenTime) {
    progress += 0.6;
  } else {
    final overage = actualScreenTime - targetScreenTime;
    progress += 0.6 * (1.0 - (overage / targetScreenTime)).clamp(0.0, 1.0);
  }

  return progress.clamp(0.0, 1.0);
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

// Provider for user preferences
// This provider now correctly depends on the sharedPreferencesProvider from main.dart
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final sharedPreferencesAsyncValue = ref.watch(sharedPreferencesProvider);

  // We must handle the async states of the SharedPreferences provider.
  // When it's loading or has an error, we can't create the UserPreferencesNotifier yet.
  // We provide a dummy/default notifier in those cases. The UI should handle this.
  // A better approach might involve a provider that returns AsyncValue<UserPreferencesNotifier>.
  // For now, this will allow compilation.
  return sharedPreferencesAsyncValue.when(
    data: (sharedPreferences) => UserPreferencesNotifier(sharedPreferences),
    loading: () => UserPreferencesNotifier(
      // This is a temporary Notifier with an in-memory map that won't be persisted.
      // The provider will automatically re-evaluate and provide the real one once prefs are loaded.
      _InMemorySharedPreferences(),
    ),
    error: (err, stack) => UserPreferencesNotifier(
      // Same as above in case of error
      _InMemorySharedPreferences(),
    ),
  );
});

class UserPreferences {
  final bool notificationsEnabled;
  final Duration dailyScreenTimeGoal;
  final List<String> focusAreas;
  final bool darkMode;
  final bool onboardingComplete;
  final bool isScreenTimeLimitEnabled;

  UserPreferences({
    this.notificationsEnabled = true,
    this.dailyScreenTimeGoal = const Duration(hours: 4),
    this.focusAreas = const [],
    this.darkMode = true,
    this.onboardingComplete = false,
    this.isScreenTimeLimitEnabled = true,
  });

  factory UserPreferences.defaultValues() {
    return UserPreferences(
      notificationsEnabled: true,
      dailyScreenTimeGoal: const Duration(hours: 3),
      focusAreas: ['Werk', 'Studie', 'Persoonlijke ontwikkeling'],
      darkMode: false,
      isScreenTimeLimitEnabled: true,
    );
  }

  UserPreferences copyWith({
    bool? notificationsEnabled,
    Duration? dailyScreenTimeGoal,
    List<String>? focusAreas,
    bool? darkMode,
    bool? onboardingComplete,
    bool? isScreenTimeLimitEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyScreenTimeGoal: dailyScreenTimeGoal ?? this.dailyScreenTimeGoal,
      focusAreas: focusAreas ?? this.focusAreas,
      darkMode: darkMode ?? this.darkMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      isScreenTimeLimitEnabled:
          isScreenTimeLimitEnabled ?? this.isScreenTimeLimitEnabled,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dailyScreenTimeGoal:
          Duration(seconds: json['dailyScreenTimeGoalInSeconds'] ?? 10800),
      focusAreas: List<String>.from(json['focusAreas'] ?? []),
      darkMode: json['darkMode'] ?? false,
      isScreenTimeLimitEnabled: json['isScreenTimeLimitEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'dailyScreenTimeGoalInSeconds': dailyScreenTimeGoal.inSeconds,
      'focusAreas': focusAreas,
      'darkMode': darkMode,
      'isScreenTimeLimitEnabled': isScreenTimeLimitEnabled,
    };
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final SharedPreferences _prefs;

  UserPreferencesNotifier(this._prefs) : super(UserPreferences()) {
    _loadPreferences();
  }

  void _loadPreferences() {
    final notifications = _prefs.getBool('notificationsEnabled') ?? true;
    final goalMinutes = _prefs.getInt('dailyScreenTimeGoal') ?? 240;
    final areas = _prefs.getStringList('focusAreas') ?? [];
    // Set darkMode to true if it's not set (first launch)
    final darkMode = _prefs.getBool('darkMode') ?? true;
    final onboardingComplete = _prefs.getBool('onboarding_complete') ?? false;
    final isLimitEnabled = _prefs.getBool('isScreenTimeLimitEnabled') ?? true;

    // Persist default dark mode on first load if not set
    if (_prefs.getBool('darkMode') == null) {
      _prefs.setBool('darkMode', true);
    }

    state = UserPreferences(
      notificationsEnabled: notifications,
      dailyScreenTimeGoal: Duration(minutes: goalMinutes),
      focusAreas: areas,
      darkMode: darkMode,
      onboardingComplete: onboardingComplete,
      isScreenTimeLimitEnabled: isLimitEnabled,
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
    await _prefs.setStringList('focusAreas', state.focusAreas);
    state = state.copyWith(focusAreas: state.focusAreas);
  }

  Future<void> setDarkMode(bool enabled) async {
    await _prefs.setBool('darkMode', enabled);
    state = state.copyWith(darkMode: enabled);
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool('onboarding_complete', complete);
    state = state.copyWith(onboardingComplete: complete);
  }

  Future<void> updatePreferences(UserPreferences newPreferences) async {
    state = newPreferences;
    final jsonString = jsonEncode(state.toJson());
    await _prefs.setString('user_preferences', jsonString);
    // Here we could also sync to Supabase user_preferences table
  }
}

// A mock/in-memory implementation of SharedPreferences to use while the real one is loading.
// This prevents the app from crashing on startup.
class _InMemorySharedPreferences implements SharedPreferences {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<bool> setString(String key, String value) {
    _values[key] = value;
    return Future.value(true);
  }

  @override
  String? getString(String key) {
    return _values[key] as String?;
  }

  // Implement other methods used by UserPreferencesNotifier if any, otherwise they can be left empty or throw UnimplementedError.
  // Based on the code, only getString and setString are needed for the JSON implementation.

  @override
  Set<String> getKeys() => _values.keys.toSet();

  @override
  Object? get(String key) => _values[key];

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  double? getDouble(String key) => _values[key] as double?;

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  List<String>? getStringList(String key) => _values[key] as List<String>?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    return _values.remove(key) != null;
  }

  @override
  Future<bool> commit() async => true;

  @override
  Future<void> reload() async {}

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  bool containsKey(String key) => _values.containsKey(key);
}

final activeDaysProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) {
    return 0;
  }
  final userDataService = ref.read(userDataServiceProvider);
  return await userDataService.getUniqueMoodEntryDaysCount(user.id);
});

final aggregatedAppUsageProvider = FutureProvider.family<Map<String, Duration>,
    ({DateTime startDate, DateTime endDate})>((ref, dates) async {
  final appUsageService = ref.watch(appUsageServiceProvider);
  return await appUsageService.getAggregatedAppUsage(
      dates.startDate, dates.endDate);
});
