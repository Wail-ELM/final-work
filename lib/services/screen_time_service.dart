import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class ScreenTimeEntry {
  final DateTime date;
  final Duration duration;
  final String appName;

  ScreenTimeEntry({
    required this.date,
    required this.duration,
    required this.appName,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'duration': duration.inSeconds,
        'appName': appName,
      };

  factory ScreenTimeEntry.fromJson(Map<String, dynamic> json) {
    return ScreenTimeEntry(
      date: DateTime.parse(json['date'] as String),
      duration: Duration(seconds: json['duration'] as int),
      appName: json['appName'] as String,
    );
  }
}

class ScreenTimeService {
  static const String _boxName = 'screen_time';
  late Box<Map<dynamic, dynamic>> _box;
  Timer? _trackingTimer;
  DateTime? _lastStartTime;
  String _currentApp = 'unknown';

  Future<void> init() async {
    _box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
  }

  Future<void> startTracking() async {
    _lastStartTime = DateTime.now();
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCurrentSession();
    });
  }

  Future<void> stopTracking() async {
    _trackingTimer?.cancel();
    if (_lastStartTime != null) {
      await _updateCurrentSession();
      _lastStartTime = null;
    }
  }

  Future<void> setCurrentApp(String appName) async {
    if (_currentApp != appName) {
      await _updateCurrentSession();
      _currentApp = appName;
      _lastStartTime = DateTime.now();
    }
  }

  Future<void> _updateCurrentSession() async {
    if (_lastStartTime == null) return;

    final now = DateTime.now();
    final duration = now.difference(_lastStartTime!);
    if (duration.inSeconds > 0) {
      await addScreenTime(
        ScreenTimeEntry(
          date: _lastStartTime!,
          duration: duration,
          appName: _currentApp,
        ),
      );
      _lastStartTime = now;
    }
  }

  Future<void> addScreenTime(ScreenTimeEntry entry) async {
    final key = _getDateKey(entry.date);
    final existingData = _box.get(key) ?? {};
    final appData = existingData[entry.appName] ?? {'duration': 0};

    appData['duration'] =
        (appData['duration'] as int) + entry.duration.inSeconds;
    existingData[entry.appName] = appData;

    await _box.put(key, existingData);
  }

  Future<Duration> getScreenTimeForDate(DateTime date) async {
    final key = _getDateKey(date);
    final data = _box.get(key);
    if (data == null) return Duration.zero;

    int totalSeconds = 0;
    data.forEach((_, appData) {
      totalSeconds += appData['duration'] as int;
    });

    return Duration(seconds: totalSeconds);
  }

  Future<Map<String, Duration>> getAppBreakdownForDate(DateTime date) async {
    final key = _getDateKey(date);
    final data = _box.get(key);
    if (data == null) return {};

    final breakdown = <String, Duration>{};
    data.forEach((appName, appData) {
      breakdown[appName as String] =
          Duration(seconds: appData['duration'] as int);
    });

    return breakdown;
  }

  Future<Duration> getAverageScreenTimeForPeriod(
      DateTime start, DateTime end) async {
    int totalSeconds = 0;
    int daysCount = 0;

    for (var date = start;
        date.isBefore(end.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final duration = await getScreenTimeForDate(date);
      if (duration.inSeconds > 0) {
        totalSeconds += duration.inSeconds;
        daysCount++;
      }
    }

    return daysCount > 0
        ? Duration(seconds: totalSeconds ~/ daysCount)
        : Duration.zero;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) {
  final service = ScreenTimeService();
  service.init();
  return service;
});

final screenTimeProvider =
    StateNotifierProvider<ScreenTimeNotifier, Duration>((ref) {
  final service = ref.watch(screenTimeServiceProvider);
  return ScreenTimeNotifier(service);
});

class ScreenTimeNotifier extends StateNotifier<Duration> {
  final ScreenTimeService _service;
  Timer? _updateTimer;

  ScreenTimeNotifier(this._service) : super(Duration.zero) {
    _startPeriodicUpdate();
    _updateScreenTime();
  }

  void _startPeriodicUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateScreenTime();
    });
  }

  Future<void> _updateScreenTime() async {
    final today = DateTime.now();
    final screenTime = await _service.getScreenTimeForDate(today);
    state = screenTime;
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
