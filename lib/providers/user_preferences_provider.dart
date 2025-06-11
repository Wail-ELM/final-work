import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Model for User Preferences
@immutable
class UserPreferences {
  const UserPreferences({
    required this.darkMode,
    required this.notificationsEnabled,
    required this.dailyReminderEnabled,
    required this.dailyReminderTime,
    required this.challengeUpdatesEnabled,
    required this.dailyScreenTimeGoal,
    required this.isScreenTimeLimitEnabled,
    required this.focusAreas,
  });

  final bool darkMode;
  // Notifications
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final TimeOfDay dailyReminderTime;
  final bool challengeUpdatesEnabled;
  // Screen Time
  final Duration dailyScreenTimeGoal;
  final bool isScreenTimeLimitEnabled;
  // Focus Areas
  final List<String> focusAreas;

  UserPreferences copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    TimeOfDay? dailyReminderTime,
    bool? challengeUpdatesEnabled,
    Duration? dailyScreenTimeGoal,
    bool? isScreenTimeLimitEnabled,
    List<String>? focusAreas,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      challengeUpdatesEnabled:
          challengeUpdatesEnabled ?? this.challengeUpdatesEnabled,
      dailyScreenTimeGoal: dailyScreenTimeGoal ?? this.dailyScreenTimeGoal,
      isScreenTimeLimitEnabled:
          isScreenTimeLimitEnabled ?? this.isScreenTimeLimitEnabled,
      focusAreas: focusAreas ?? this.focusAreas,
    );
  }
}

// 2. Notifier to manage the state
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier()
      : super(const UserPreferences(
          darkMode: false,
          notificationsEnabled: true,
          dailyReminderEnabled: true,
          dailyReminderTime: TimeOfDay(hour: 20, minute: 0),
          challengeUpdatesEnabled: true,
          dailyScreenTimeGoal: Duration(hours: 3),
          isScreenTimeLimitEnabled: true,
          focusAreas: ['Werk', 'Studie', 'Mindfulness'],
        )) {
    _loadPreferences();
  }

  late SharedPreferences _prefs;

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final focusAreasString = _prefs.getString('focusAreas');

    state = UserPreferences(
      darkMode: _prefs.getBool('darkMode') ?? false,
      notificationsEnabled: _prefs.getBool('notificationsEnabled') ?? true,
      dailyReminderEnabled: _prefs.getBool('dailyReminderEnabled') ?? true,
      dailyReminderTime: TimeOfDay(
        hour: _prefs.getInt('dailyReminderHour') ?? 20,
        minute: _prefs.getInt('dailyReminderMinute') ?? 0,
      ),
      challengeUpdatesEnabled:
          _prefs.getBool('challengeUpdatesEnabled') ?? true,
      dailyScreenTimeGoal:
          Duration(minutes: _prefs.getInt('dailyScreenTimeGoal') ?? 180),
      isScreenTimeLimitEnabled:
          _prefs.getBool('isScreenTimeLimitEnabled') ?? true,
      focusAreas: focusAreasString != null
          ? List<String>.from(jsonDecode(focusAreasString))
          : ['Werk', 'Studie', 'Mindfulness'],
    );
  }

  void setDarkMode(bool value) {
    _prefs.setBool('darkMode', value);
    state = state.copyWith(darkMode: value);
  }

  void setNotificationsEnabled(bool value) {
    _prefs.setBool('notificationsEnabled', value);
    state = state.copyWith(notificationsEnabled: value);
  }

  void setDailyReminderEnabled(bool value) {
    _prefs.setBool('dailyReminderEnabled', value);
    state = state.copyWith(dailyReminderEnabled: value);
  }

  void setDailyReminderTime(TimeOfDay value) {
    _prefs.setInt('dailyReminderHour', value.hour);
    _prefs.setInt('dailyReminderMinute', value.minute);
    state = state.copyWith(dailyReminderTime: value);
  }

  void setChallengeUpdatesEnabled(bool value) {
    _prefs.setBool('challengeUpdatesEnabled', value);
    state = state.copyWith(challengeUpdatesEnabled: value);
  }

  void setDailyScreenTimeGoal(Duration value) {
    _prefs.setInt('dailyScreenTimeGoal', value.inMinutes);
    state = state.copyWith(dailyScreenTimeGoal: value);
  }

  void setIsScreenTimeLimitEnabled(bool value) {
    _prefs.setBool('isScreenTimeLimitEnabled', value);
    state = state.copyWith(isScreenTimeLimitEnabled: value);
  }

  void setFocusAreas(List<String> value) {
    _prefs.setString('focusAreas', jsonEncode(value));
    state = state.copyWith(focusAreas: value);
  }
}

// 3. Provider
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});
