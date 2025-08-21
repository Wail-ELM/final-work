import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:usage_stats/usage_stats.dart' as us;
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/screen_time_entry.dart';
import '../providers/auth_provider.dart';
import '../services/demo_data_service.dart';
import '../providers/user_preferences_provider.dart';
import './notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Heuristics to exclude system/launcher/input-method packages from totals
  bool _isSystemOrLauncher(String package) {
    final lower = package.toLowerCase();
    // System UI and input methods
    if (lower.contains('systemui')) return true;
    if (lower.contains('inputmethod')) return true;
    if (lower.contains('ime')) return true; // keyboards may include ime
    // Setup/installer/background services
    if (lower.contains('setupwizard')) return true;
    if (lower.contains('packageinstaller')) return true;
    if (lower.contains('printspooler')) return true;
    if (lower.contains('wallpaper')) return true;
    // Common launchers
    if (lower.contains('launcher')) return true;
    if (lower.startsWith('com.miui.home')) return true;
    if (lower.startsWith('com.huawei.android.launcher')) return true;
    if (lower.startsWith('com.sec.android.app.launcher')) return true;
    // Optionally exclude Google Play services background
    if (lower.startsWith('com.google.android.gms')) return true;

    // Explicit allowlist for popular user apps that might match patterns above
    // Never exclude Chrome even though it's under com.android.chrome on many devices
    if (lower == 'com.android.chrome' ||
        lower.startsWith('com.android.chrome')) {
      return false;
    }

    // Keep other packages by default
    return false;
  }

  Future<Duration?> _totalFromUsageEvents(DateTime start, DateTime end) async {
    try {
      final hasAccess = (await us.UsageStats.checkUsagePermission()) ?? false;
      if (!hasAccess) return null;
      final events = await us.UsageStats.queryEvents(start, end);
      if (events.isEmpty) return null;

      // Sort by timestamp
      events.sort((a, b) {
        final ta = _eventTime(a);
        final tb = _eventTime(b);
        return ta.compareTo(tb);
      });

      String? currentPkg;
      DateTime? currentStart;
      Duration total = Duration.zero;

      for (final e in events) {
        final pkg =
            ((e as dynamic).packageName as String?)?.toLowerCase() ?? '';
        final dt = _eventTime(e);
        final type = ((e as dynamic).eventType)?.toString().toUpperCase() ?? '';
        final isFg = type.contains('MOVE_TO_FOREGROUND') ||
            type.contains('ACTIVITY_RESUMED') ||
            type == '1';
        final isBg = type.contains('MOVE_TO_BACKGROUND') ||
            type.contains('ACTIVITY_PAUSED') ||
            type == '2';

        if (isFg) {
          if (_isSystemOrLauncher(pkg)) {
            // ignore
            continue;
          }
          // If another app was in foreground, close it implicitly
          if (currentPkg != null && currentStart != null) {
            final dur = dt.difference(currentStart);
            if (!dur.isNegative) total += dur;
          }
          currentPkg = pkg;
          currentStart = dt;
        } else if (isBg) {
          if (currentPkg != null && currentStart != null) {
            final dur = dt.difference(currentStart);
            if (!dur.isNegative) total += dur;
            currentPkg = null;
            currentStart = null;
          }
        }
      }

      // If still running in foreground at the end, add remaining
      if (currentPkg != null && currentStart != null) {
        final tail = end.difference(currentStart);
        if (!tail.isNegative) total += tail;
      }

      // Clamp
      final interval = end.difference(start);
      if (total > interval) total = interval;
      if (total.isNegative) total = Duration.zero;
      return total;
    } catch (e) {
      debugPrint('totalFromUsageEvents failed: $e');
      return null;
    }
  }

  DateTime _eventTime(dynamic event) {
    try {
      final ts = (event as dynamic).timeStamp;
      if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
      if (ts is String)
        return DateTime.fromMillisecondsSinceEpoch(int.tryParse(ts) ?? 0);
      if (ts is DateTime) return ts;
    } catch (_) {}
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> startTracking() async {
    if (kIsWeb) return;

    // If usage access is not granted, try to fetch once (will throw) and log; UI should guide user to settings.
    try {
      await AppUsage().getAppUsage(
          DateTime.now().subtract(const Duration(seconds: 10)), DateTime.now());
    } catch (e) {
      debugPrint('AppUsageService: Usage access likely not granted: $e');
      // Optional: attempt to open Usage Access settings
      await _openUsageAccessSettings();
    }

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

  Future<void> _openUsageAccessSettings() async {
    const androidSettingsUri = 'android.settings.USAGE_ACCESS_SETTINGS';
    try {
      // Try launching the Android settings intent via intent: scheme
      final intentUri = Uri.parse(
          'intent://$androidSettingsUri#Intent;scheme=android;action=$androidSettingsUri;end');
      await launchUrl(intentUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      debugPrint(
          'AppUsageService: Unable to open Usage Access settings automatically.');
    }
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
      // pick first non-system package
      String currentForegroundApp = usageInfo.first.packageName;
      for (final info in usageInfo) {
        if (!_isSystemOrLauncher(info.packageName)) {
          currentForegroundApp = info.packageName;
          break;
        }
      }

      if (_isSystemOrLauncher(currentForegroundApp)) {
        // If we couldn't find a non-system app, skip logging to avoid skewing totals
        return;
      }

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
    final String userId = _ref.read(authServiceProvider).currentUser?.id ??
        DemoDataService.demoUserId;

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
    final String userId = _ref.read(authServiceProvider).currentUser?.id ??
        DemoDataService.demoUserId;
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
    // 1) Probeer Android systeem-usage (werkt ook als de app niet actief trackte)
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      // Gebruik 'nu' als eindtijd voor de dag van vandaag, anders einde van de dag
      final now = DateTime.now();
      final bool isToday = startOfDay.year == now.year &&
          startOfDay.month == now.month &&
          startOfDay.day == now.day;
      final DateTime endTime =
          isToday ? now : startOfDay.add(const Duration(days: 1));

      // Eerst: exacte reconstructie via UsageEvents (MOVE_TO_FOREGROUND/BACKGROUND)
      final fromEvents = await _totalFromUsageEvents(startOfDay, endTime);
      if (fromEvents != null) {
        return fromEvents;
      }

      // Primary path: UsageStats (closer to Digital Wellbeing)
      try {
        final granted = (await us.UsageStats.checkUsagePermission()) ?? false;
        if (granted == false) {
          // Try to prompt the settings
          await us.UsageStats.grantUsagePermission();
          await Future.delayed(const Duration(milliseconds: 300));
        }
        final grantedAgain =
            (await us.UsageStats.checkUsagePermission()) ?? false;
        if (grantedAgain == true) {
          final begin = startOfDay;
          final end = endTime;
          final stats = await us.UsageStats.queryUsageStats(begin, end);
          int totalMs = 0;
          for (final info in stats) {
            final pkg = (info.packageName ?? '').toLowerCase();
            if (_isSystemOrLauncher(pkg)) continue;
            final ms = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
            totalMs += ms;
          }
          var total = Duration(milliseconds: totalMs);
          final interval = endTime.difference(startOfDay);
          if (total > interval) total = interval;
          return total;
        }
      } catch (e) {
        // Fall back to AppUsage path below
        debugPrint('UsageStats path failed: $e');
      }

      final appUsages = await AppUsage().getAppUsage(startOfDay, endTime);
      // Als de systeemaanroep slaagt, gebruik het resultaat als bron van waarheid,
      // zelfs als het leeg is (0 minuten die dag).
      final filtered =
          appUsages.where((u) => !_isSystemOrLauncher(u.packageName));
      var total = filtered.fold<Duration>(
        Duration.zero,
        (sum, info) => sum + info.usage,
      );
      // Clamp: totale schermtijd kan nooit groter zijn dan de lengte van het interval
      final interval = endTime.difference(startOfDay);
      if (total > interval) {
        total = interval;
      }
      return total;
    } catch (e) {
      // Geen usage access of platform mismatch -> val terug op lokale opslag (Hive)
      debugPrint(
          'AppUsageService.getTotalScreenTimeForDate: system usage not available ($e). Falling back to local.');
      final usage = await getAppUsageForDate(date);
      return usage.values.fold<Duration>(
        Duration.zero,
        (sum, duration) => sum + duration,
      );
    }
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

    // 1) Probeer systeemstatistieken over de volledige periode
    try {
      final normalizedStartDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      DateTime normalizedEndExclusive =
          DateTime(endDate.year, endDate.month, endDate.day)
              .add(const Duration(days: 1)); // end exclusive
      // Laat het einde niet in de toekomst lopen
      final now = DateTime.now();
      if (normalizedEndExclusive.isAfter(now)) {
        normalizedEndExclusive = now;
      }
      // Primary path: UsageStats aggregation
      try {
        final granted = (await us.UsageStats.checkUsagePermission()) ?? false;
        if (granted == false) {
          await us.UsageStats.grantUsagePermission();
          await Future.delayed(const Duration(milliseconds: 300));
        }
        final hasAccess = (await us.UsageStats.checkUsagePermission()) ?? false;
        if (hasAccess == true) {
          final begin = normalizedStartDate;
          final end = normalizedEndExclusive;
          final stats = await us.UsageStats.queryUsageStats(begin, end);
          final usage = <String, Duration>{};
          for (final info in stats) {
            final pkg = (info.packageName ?? '').toLowerCase();
            if (_isSystemOrLauncher(pkg)) continue;
            final ms = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
            if (ms <= 0) continue;
            usage[pkg] =
                (usage[pkg] ?? Duration.zero) + Duration(milliseconds: ms);
          }
          return usage;
        }
      } catch (e) {
        debugPrint('UsageStats aggregation failed: $e');
      }

      // Fallback: AppUsage aggregation
      final appUsages = await AppUsage()
          .getAppUsage(normalizedStartDate, normalizedEndExclusive);
      final usage = <String, Duration>{};
      for (final info in appUsages) {
        if (_isSystemOrLauncher(info.packageName)) continue;
        usage[info.packageName] =
            (usage[info.packageName] ?? Duration.zero) + info.usage;
      }
      return usage;
    } catch (e) {
      debugPrint(
          'AppUsageService.getAggregatedAppUsage: system usage not available ($e). Falling back to local.');
      // 2) Fallback naar lokale opslag gefilterd per periode en gebruiker
      final String userId = _ref.read(authServiceProvider).currentUser?.id ??
          DemoDataService.demoUserId;

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
  }

  Future<Map<DateTime, Duration>> getDailyTotalScreenTimeForPeriod(
      DateTime startDate, DateTime endDate) async {
    if (kIsWeb) {
      debugPrint(
          "AppUsageService: Platform is not Android. Returning empty map for period.");
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
            body:
                'Je hebt je schermtijd-doel met ${overage.inMinutes} minuten overschreden.',
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
