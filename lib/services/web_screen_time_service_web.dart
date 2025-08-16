import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../models/screen_time_entry.dart';
import 'package:uuid/uuid.dart';

/// Implémentation Web réelle (séparée) – ne sera compilée que sur le web.
class WebScreenTimeService {
  static final WebScreenTimeService _instance = WebScreenTimeService._internal();
  factory WebScreenTimeService() => _instance;
  WebScreenTimeService._internal();

  Timer? _trackingTimer;
  DateTime? _sessionStartTime;
  DateTime? _lastActiveTime;
  Duration _currentSessionDuration = Duration.zero;
  bool _isPageVisible = true;
  bool _isWindowFocused = true;
  bool _isTracking = false;

  Function(Duration)? onSessionUpdate;
  Function(ScreenTimeEntry)? onEntryCompleted;

  Future<void> initialize() async {
    if (!kIsWeb) return;
    try {
      _setupPageVisibilityAPI();
      _setupWindowFocusEvents();
      _setupBeforeUnloadHandler();
      debugPrint('WebScreenTimeService(Web): Initialized');
    } catch (e) {
      debugPrint('WebScreenTimeService(Web): Init error: $e');
    }
  }

  void _setupPageVisibilityAPI() {
    html.document.addEventListener('visibilitychange', (event) {
      final isVisible = !html.document.hidden!;
      _handleVisibilityChange(isVisible);
    });
    _isPageVisible = !html.document.hidden!;
  }

  void _setupWindowFocusEvents() {
    html.window.addEventListener('focus', (event) => _handleWindowFocus(true));
    html.window.addEventListener('blur', (event) => _handleWindowFocus(false));
    _isWindowFocused = true;
  }

  void _setupBeforeUnloadHandler() {
    html.window.addEventListener('beforeunload', (event) {
      if (_isTracking) {
        _endCurrentSession();
      }
    });
  }

  Future<void> startTracking() async {
    if (_isTracking) return;
    _isTracking = true;
    _sessionStartTime = DateTime.now();
    _lastActiveTime = DateTime.now();
    _currentSessionDuration = Duration.zero;
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateSession());
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;
    _isTracking = false;
    _trackingTimer?.cancel();
    _trackingTimer = null;
    await _endCurrentSession();
  }

  void _updateSession() {
    if (!_isTracking || !_isActivelyUsing()) return;
    final now = DateTime.now();
    final secondsElapsed = now.difference(_lastActiveTime!).inSeconds;
    if (secondsElapsed <= 5) {
      _currentSessionDuration += Duration(seconds: secondsElapsed);
      onSessionUpdate?.call(_currentSessionDuration);
    }
    _lastActiveTime = now;
  }

  bool _isActivelyUsing() => _isPageVisible && _isWindowFocused;

  void _handleVisibilityChange(bool isVisible) {
    final wasActive = _isActivelyUsing();
    _isPageVisible = isVisible;
    final isNowActive = _isActivelyUsing();
    if (wasActive && !isNowActive) {
      _updateSession();
    } else if (!wasActive && isNowActive) {
      _lastActiveTime = DateTime.now();
    }
  }

  void _handleWindowFocus(bool hasFocus) {
    final wasActive = _isActivelyUsing();
    _isWindowFocused = hasFocus;
    final isNowActive = _isActivelyUsing();
    if (wasActive && !isNowActive) {
      _updateSession();
    } else if (!wasActive && isNowActive) {
      _lastActiveTime = DateTime.now();
    }
  }

  Future<void> _endCurrentSession() async {
    if (_sessionStartTime == null) return;
    _updateSession();
    if (_currentSessionDuration.inSeconds >= 30) {
      final entry = ScreenTimeEntry(
        id: const Uuid().v4(),
        userId: 'current_user',
        appName: 'Social Balans Web',
        duration: _currentSessionDuration,
        date: _sessionStartTime!,
        createdAt: DateTime.now(),
      );
      onEntryCompleted?.call(entry);
    }
    _sessionStartTime = null;
    _lastActiveTime = null;
    _currentSessionDuration = Duration.zero;
  }

  Duration getCurrentSessionDuration() {
    if (!_isTracking) return Duration.zero;
    if (_isActivelyUsing() && _lastActiveTime != null) {
      final now = DateTime.now();
      final additional = now.difference(_lastActiveTime!);
      if (additional.inSeconds <= 5) {
        return _currentSessionDuration + additional;
      }
    }
    return _currentSessionDuration;
  }

  bool get isTracking => _isTracking;
  bool get isCurrentlyActive => _isActivelyUsing();

  Map<String, dynamic> getDebugStats() => {
        'isTracking': _isTracking,
        'isPageVisible': _isPageVisible,
        'isWindowFocused': _isWindowFocused,
        'isActivelyUsing': _isActivelyUsing(),
        'sessionStartTime': _sessionStartTime?.toIso8601String(),
        'currentSessionDuration': _currentSessionDuration.inSeconds,
        'lastActiveTime': _lastActiveTime?.toIso8601String(),
      };

  void dispose() => stopTracking();
}
