import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:hive/hive.dart';
import '../models/screen_time_entry.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppUsageService {
  static final AppUsageService _instance = AppUsageService._internal();
  factory AppUsageService() => _instance;
  AppUsageService._internal();

  Timer? _trackingTimer;
  String? _currentApp;
  DateTime? _sessionStartTime;
  final _box = Hive.box<ScreenTimeEntry>('screen_time');

  Future<void> startTracking() async {
    if (_trackingTimer != null) return;

    // Start tracking
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _updateCurrentApp();
    });

    // Initialiseer sessie
    _sessionStartTime = DateTime.now();
    await _updateCurrentApp();
  }

  Future<void> stopTracking() async {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    await _updateCurrentApp();
    _sessionStartTime = null;
    _currentApp = null;
  }

  Future<void> _updateCurrentApp() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(minutes: 1));
      final usageInfo = await AppUsage().getAppUsage(startTime, now);
      if (usageInfo.isEmpty) return;

      final currentApp = usageInfo.first.packageName;
      if (currentApp == _currentApp) return;

      // Sla vorige sessie op
      if (_currentApp != null && _sessionStartTime != null) {
        final duration = DateTime.now().difference(_sessionStartTime!);
        if (duration.inMinutes > 0) {
          await _logAppUsage(_currentApp!, duration);
        }
      }

      // Update huidige app
      _currentApp = currentApp;
      _sessionStartTime = DateTime.now();
    } catch (e) {
      debugPrint('Fout bij app-update: $e');
    }
  }

  Future<void> _logAppUsage(String packageName, Duration duration) async {
    final now = DateTime.now();
    final entry = ScreenTimeEntry(
      id: const Uuid().v4(),
      userId: '', // TODO: Get from auth service
      appName: packageName,
      duration: duration,
      date: DateTime(now.year, now.month, now.day),
      createdAt: now,
    );

    // Voeg samen met bestaande invoer
    final existingEntries = _box.values.where((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day &&
        e.appName == entry.appName);

    if (existingEntries.isNotEmpty) {
      final totalDuration = existingEntries.fold<Duration>(
            Duration.zero,
            (sum, e) => sum + e.duration,
          ) +
          duration;

      // Verwijder oude invoer
      for (final e in existingEntries) {
        await e.delete();
      }

      // Voeg samengevoegde invoer toe
      final updatedEntry = entry.copyWith(duration: totalDuration);
      await _box.add(updatedEntry);
    } else {
      await _box.add(entry);
    }
  }

  Future<Map<String, Duration>> getAppUsageForDate(DateTime date) async {
    final entries = _box.values.where((e) =>
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

  Future<Duration> getTotalScreenTimeForDate(DateTime date) async {
    final usage = await getAppUsageForDate(date);
    return usage.values.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
  }

  Future<List<MapEntry<String, Duration>>> getTopAppsForDate(
    DateTime date, {
    int limit = 5,
  }) async {
    final usage = await getAppUsageForDate(date);
    final sorted = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }
}
