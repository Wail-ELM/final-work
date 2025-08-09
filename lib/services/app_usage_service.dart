import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/screen_time_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/user_preferences_provider.dart';
import './notification_service.dart';
import 'package:uuid/uuid.dart';

class AppUsageService {
  final Ref _ref;
  AppUsageService(this._ref);

  Timer? _appTrackingTimer;
  Timer? _limitCheckTimer;
  String? _currentApp;
  DateTime? _sessionStartTime;
  Box<ScreenTimeEntry> get _box => Hive.box<ScreenTimeEntry>('screen_time');
  static const String _lastLimitNotificationDateKey =
      'lastLimitNotificationDate';

  Future<void> startTracking() async {
    if (kIsWeb) return;

    if (_appTrackingTimer == null || !_appTrackingTimer!.isActive) {
      _appTrackingTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
        await _updateCurrentApp();
      });
    }

    if (_limitCheckTimer == null || !_limitCheckTimer!.isActive) {
      _limitCheckTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
        await _checkScreenTimeLimit();
      });
    }

    _sessionStartTime = DateTime.now();
    await _updateCurrentApp();
    await _checkScreenTimeLimit();
  }

  Future<void> stopTracking() async {
    if (kIsWeb) return;
    _appTrackingTimer?.cancel();
    _appTrackingTimer = null;
    _limitCheckTimer?.cancel();
    _limitCheckTimer = null;

    if (_currentApp != null && _sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!);
      if (duration.inMinutes > 0) {
        await _logAppUsage(_currentApp!, duration);
      }
    }
    _currentApp = null;
    _sessionStartTime = null;
  }

  Future<void> _updateCurrentApp() async {
    if (kIsWeb) return;
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(minutes: 1, seconds: 5));
      final usageInfo = await AppUsage().getAppUsage(startTime, now);
      if (usageInfo.isEmpty) return;

      usageInfo.sort((a, b) => b.usage.compareTo(a.usage));
      final String currentForegroundApp = usageInfo.first.packageName;

      if (currentForegroundApp == _currentApp) return;

      if (_currentApp != null && _sessionStartTime != null) {
        final duration = DateTime.now().difference(_sessionStartTime!);
        if (duration.inSeconds > 10) {
          await _logAppUsage(_currentApp!, duration);
        }
      }

      _currentApp = currentForegroundApp;
      _sessionStartTime = DateTime.now();
    } catch (e) {
      debugPrint('Fout bij app-update: $e');
    }
  }

  Future<void> _logAppUsage(String packageName, Duration duration) async {
    if (kIsWeb) return;
    final now = DateTime.now();
    final String userId =
        _ref.read(authServiceProvider).currentUser?.id ?? 'unknown_user_id';

    if (userId == 'unknown_user_id') {
      debugPrint('AppUsageService: Attempted to log usage for unknown user.');
    }

    final entry = ScreenTimeEntry(
      id: const Uuid().v4(),
      userId: userId,
      appName: packageName,
      duration: duration,
      date: DateTime(now.year, now.month, now.day),
      createdAt: now,
    );

    final existingEntries = _box.values.where((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day &&
        e.appName == entry.appName &&
        e.userId == entry.userId);

    if (existingEntries.isNotEmpty) {
      final totalDuration = existingEntries.fold<Duration>(
            Duration.zero,
            (sum, ex) => sum + ex.duration,
          ) +
          duration;

      List<dynamic> keysToDelete = [];
      for (final ex in existingEntries) {
        keysToDelete.add(ex.key);
      }
      await _box.deleteAll(keysToDelete);

      final updatedEntry = entry.copyWith(duration: totalDuration);
      await _box.put(updatedEntry.id, updatedEntry);
    } else {
      await _box.put(entry.id, entry);
    }
  }

  Future<Map<String, Duration>> getAppUsageForDate(DateTime date) async {
    if (kIsWeb) return {};
    final String userId =
        _ref.read(authServiceProvider).currentUser?.id ?? 'unknown_user_id';
    final entries = _box.values.where((e) =>
        e.userId == userId &&
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day);

    final usage = <String, Duration>{};
    for (final entry in entries) {
      usage[entry.appName] =
          (usage[entry.appName] ?? Duration.zero) + entry.duration;
    }
    return usage;
  }

  Future<Duration?> getTotalScreenTimeForDate(DateTime date) async {
    if (kIsWeb) {
      return null;
    }
    final usage = await getAppUsageForDate(date);
    if (usage.isEmpty &&
        (_ref.read(authServiceProvider).currentUser?.id ?? 'unknown_user_id') ==
            'unknown_user_id') {
      return null;
    }
    return usage.values.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
  }

  Future<List<MapEntry<String, Duration>>> getTopAppsForDate(
    DateTime date, {
    int limit = 5,
  }) async {
    if (kIsWeb) return [];
    final usage = await getAppUsageForDate(date);
    final sorted = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  Future<Map<DateTime, Duration>> getWeeklyScreenTimeData(
      DateTime endDate) async {
    if (kIsWeb) return {};

    final String userId =
        _ref.read(authServiceProvider).currentUser?.id ?? 'unknown_user_id';
    if (userId == 'unknown_user_id') return {}; // No data for unknown user

    final Map<DateTime, Duration> weeklyData = {};
    final normalizedEndDate =
        DateTime(endDate.year, endDate.month, endDate.day);

    for (int i = 0; i < 7; i++) {
      final date = normalizedEndDate.subtract(Duration(days: i));
      // Use getTotalScreenTimeForDate which is already userId-aware and sums up durations for a day
      final Duration? totalDurationForDay =
          await getTotalScreenTimeForDate(date);
      weeklyData[date] =
          totalDurationForDay ?? Duration.zero; // Store zero if null
    }
    return weeklyData;
  }

  Future<Map<String, Duration>> getAggregatedAppUsage(
      DateTime startDate, DateTime endDate) async {
    if (kIsWeb) return {};
    final String userId =
        _ref.read(authServiceProvider).currentUser?.id ?? 'unknown_user_id';
    if (userId == 'unknown_user_id') return {};

    final normalizedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEndDate =
        DateTime(endDate.year, endDate.month, endDate.day);

    final entries = _box.values.where((e) {
      if (e.userId != userId) return false;
      final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
      return (entryDate.isAtSameMomentAs(normalizedStartDate) ||
              entryDate.isAfter(normalizedStartDate)) &&
          (entryDate.isAtSameMomentAs(normalizedEndDate) ||
              entryDate.isBefore(normalizedEndDate));
    });

    final usage = <String, Duration>{};
    for (final entry in entries) {
      usage[entry.appName] =
          (usage[entry.appName] ?? Duration.zero) + entry.duration;
    }
    return usage;
  }

  Future<Map<DateTime, Duration>> getDailyTotalScreenTimeForPeriod(
      DateTime startDate, DateTime endDate) async {
    if (kIsWeb) {
      debugPrint(
          "AppUsageService: Platform is not Android. Returning empty map for period.");
      return {};
    }

    final String userId =
        _ref.read(authServiceProvider).currentUser?.id ?? 'unknown_user_id';
    if (userId == 'unknown_user_id') {
      debugPrint(
          "AppUsageService: User is unknown. Returning empty map for period.");
      return {};
    }

    final Map<DateTime, Duration> periodicData = {};
    final normalizedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEndDate =
        DateTime(endDate.year, endDate.month, endDate.day);

    if (normalizedStartDate.isAfter(normalizedEndDate)) {
      debugPrint(
          "AppUsageService: Start date is after end date. Returning empty map.");
      return {};
    }

    for (var currentDate = normalizedStartDate;
        currentDate.isBefore(normalizedEndDate.add(const Duration(days: 1)));
        currentDate = currentDate.add(const Duration(days: 1))) {
      final Duration? totalDurationForDay =
          await getTotalScreenTimeForDate(currentDate);
      periodicData[currentDate] = totalDurationForDay ?? Duration.zero;
    }

    return periodicData;
  }

  Future<void> _checkScreenTimeLimit() async {
    if (kIsWeb) return;
    try {
      final userPrefs = _ref.read(userPreferencesProvider);
      final screenTimeGoal = userPrefs.dailyScreenTimeGoal;

      if (screenTimeGoal > Duration.zero) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final todayScreenTime =
            await getTotalScreenTimeForDate(today) ?? Duration.zero;

        if (todayScreenTime > screenTimeGoal && await _canShowNotification()) {
          final overage = todayScreenTime - screenTimeGoal;
          final notificationService = _ref.read(notificationServiceProvider);
          await notificationService.showSimpleNotification(
            id: 99, // Unique ID for screen time notifications
            title: 'Schermtijdlimiet overschreden',
            body: 'Je hebt je schermtijd-doel met ${overage.inMinutes} minuten overschreden.',
          );
          await _setLastNotificationDate(today);
        }
      }
    } catch (e) {
      debugPrint('Error checking screen time limit: $e');
    }
  }

  Future<void> _setLastNotificationDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastLimitNotificationDateKey, date.toIso8601String());
  }

  Future<bool> _canShowNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastLimitNotificationDateKey);
    if (lastDateStr == null) return true;

    final lastDate = DateTime.parse(lastDateStr);
    final now = DateTime.now();
    return now.difference(lastDate).inDays >= 1;
  }
}
