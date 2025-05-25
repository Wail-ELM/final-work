import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_category_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Huidige doelstelling van de gebruiker
final userObjectiveProvider = StateProvider<ChallengeCategory?>((_) => null);

// Provider voor de streak van de gebruiker
final userStreakProvider = StateProvider<int>((ref) {
  // TODO: Implémenter de logica van streak
  return 0;
});

// Provider voor het scherm tijd
final screenTimeProvider = StateProvider<Duration>((ref) {
  // TODO: Implémenter de logica van scherm tijd
  return const Duration(hours: 2, minutes: 30);
});

// Provider voor het dagelijkse doel
final dailyObjectiveProvider = StateProvider<String>((ref) {
  // TODO: Implémenter de logica van dagelijkse doel
  return "Focus op bewust schermgebruik";
});

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
