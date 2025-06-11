import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../models/screen_time_entry.dart';
import 'package:uuid/uuid.dart';

/// Service de suivi réel du temps d'écran pour le web
/// Utilise Page Visibility API et focus/blur events pour un tracking précis
class WebScreenTimeService {
  static final WebScreenTimeService _instance =
      WebScreenTimeService._internal();
  factory WebScreenTimeService() => _instance;
  WebScreenTimeService._internal();

  Timer? _trackingTimer;
  DateTime? _sessionStartTime;
  DateTime? _lastActiveTime;
  Duration _currentSessionDuration = Duration.zero;
  bool _isPageVisible = true;
  bool _isWindowFocused = true;
  bool _isTracking = false;

  // Callbacks pour notifier les changements
  Function(Duration)? onSessionUpdate;
  Function(ScreenTimeEntry)? onEntryCompleted;

  /// Initialise le service et configure les listeners
  Future<void> initialize() async {
    if (!kIsWeb) {
      debugPrint('WebScreenTimeService: Not running on web platform');
      return;
    }

    try {
      _setupPageVisibilityAPI();
      _setupWindowFocusEvents();
      _setupBeforeUnloadHandler();
      debugPrint('WebScreenTimeService: Initialized successfully');
    } catch (e) {
      debugPrint('WebScreenTimeService: Error during initialization: $e');
    }
  }

  /// Configure l'API de visibilité de page
  void _setupPageVisibilityAPI() {
    html.document.addEventListener('visibilitychange', (event) {
      final isVisible = !html.document.hidden!;
      _handleVisibilityChange(isVisible);
    });

    // État initial
    _isPageVisible = !html.document.hidden!;
  }

  /// Configure les événements de focus/blur de la fenêtre
  void _setupWindowFocusEvents() {
    html.window.addEventListener('focus', (event) {
      _handleWindowFocus(true);
    });

    html.window.addEventListener('blur', (event) {
      _handleWindowFocus(false);
    });

    // État initial (assumé focusé au démarrage)
    _isWindowFocused = true;
  }

  /// Configure le handler avant fermeture de page
  void _setupBeforeUnloadHandler() {
    html.window.addEventListener('beforeunload', (event) {
      if (_isTracking) {
        _endCurrentSession();
      }
    });
  }

  /// Démarre le suivi du temps d'écran
  Future<void> startTracking() async {
    if (_isTracking) {
      debugPrint('WebScreenTimeService: Already tracking');
      return;
    }

    _isTracking = true;
    _sessionStartTime = DateTime.now();
    _lastActiveTime = DateTime.now();
    _currentSessionDuration = Duration.zero;

    // Timer qui vérifie et met à jour toutes les secondes
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateSession();
    });

    debugPrint(
        'WebScreenTimeService: Started tracking at ${_sessionStartTime}');
  }

  /// Arrête le suivi du temps d'écran
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    _isTracking = false;
    _trackingTimer?.cancel();
    _trackingTimer = null;

    await _endCurrentSession();
    debugPrint('WebScreenTimeService: Stopped tracking');
  }

  /// Met à jour la session actuelle
  void _updateSession() {
    if (!_isTracking || !_isActivelyUsing()) return;

    final now = DateTime.now();
    final secondsElapsed = now.difference(_lastActiveTime!).inSeconds;

    // Ne compter que si moins de 5 secondes se sont écoulées (évite les gros gaps)
    if (secondsElapsed <= 5) {
      _currentSessionDuration += Duration(seconds: secondsElapsed);
      onSessionUpdate?.call(_currentSessionDuration);
    }

    _lastActiveTime = now;
  }

  /// Vérifie si l'utilisateur utilise activement l'app
  bool _isActivelyUsing() {
    return _isPageVisible && _isWindowFocused;
  }

  /// Gère les changements de visibilité de page
  void _handleVisibilityChange(bool isVisible) {
    final wasActive = _isActivelyUsing();
    _isPageVisible = isVisible;
    final isNowActive = _isActivelyUsing();

    debugPrint('WebScreenTimeService: Page visibility changed to $isVisible');

    if (wasActive && !isNowActive) {
      // Passage à inactif - pauser le suivi
      _updateSession();
    } else if (!wasActive && isNowActive) {
      // Retour à actif - reprendre le suivi
      _lastActiveTime = DateTime.now();
    }
  }

  /// Gère les changements de focus de fenêtre
  void _handleWindowFocus(bool hasFocus) {
    final wasActive = _isActivelyUsing();
    _isWindowFocused = hasFocus;
    final isNowActive = _isActivelyUsing();

    debugPrint('WebScreenTimeService: Window focus changed to $hasFocus');

    if (wasActive && !isNowActive) {
      // Passage à inactif
      _updateSession();
    } else if (!wasActive && isNowActive) {
      // Retour à actif
      _lastActiveTime = DateTime.now();
    }
  }

  /// Termine la session actuelle et crée une entrée
  Future<void> _endCurrentSession() async {
    if (_sessionStartTime == null) return;

    // Dernière mise à jour
    _updateSession();

    // Créer l'entrée seulement si on a au moins 30 secondes
    if (_currentSessionDuration.inSeconds >= 30) {
      final entry = ScreenTimeEntry(
        id: const Uuid().v4(),
        userId: 'current_user', // À remplacer par l'ID utilisateur réel
        appName: 'Social Balans Web',
        duration: _currentSessionDuration,
        date: _sessionStartTime!,
        createdAt: DateTime.now(),
      );

      onEntryCompleted?.call(entry);
      debugPrint(
          'WebScreenTimeService: Session completed - Duration: ${_currentSessionDuration}');
    } else {
      debugPrint(
          'WebScreenTimeService: Session too short (${_currentSessionDuration.inSeconds}s), not saved');
    }

    // Reset
    _sessionStartTime = null;
    _lastActiveTime = null;
    _currentSessionDuration = Duration.zero;
  }

  /// Obtient la durée de la session actuelle
  Duration getCurrentSessionDuration() {
    if (!_isTracking) return Duration.zero;

    // Mise à jour en temps réel
    if (_isActivelyUsing() && _lastActiveTime != null) {
      final now = DateTime.now();
      final additionalTime = now.difference(_lastActiveTime!);
      if (additionalTime.inSeconds <= 5) {
        return _currentSessionDuration + additionalTime;
      }
    }

    return _currentSessionDuration;
  }

  /// Vérifie si le service suit actuellement
  bool get isTracking => _isTracking;

  /// Vérifie si l'utilisateur est actuellement actif
  bool get isCurrentlyActive => _isActivelyUsing();

  /// Statistiques de debug
  Map<String, dynamic> getDebugStats() {
    return {
      'isTracking': _isTracking,
      'isPageVisible': _isPageVisible,
      'isWindowFocused': _isWindowFocused,
      'isActivelyUsing': _isActivelyUsing(),
      'sessionStartTime': _sessionStartTime?.toIso8601String(),
      'currentSessionDuration': _currentSessionDuration.inSeconds,
      'lastActiveTime': _lastActiveTime?.toIso8601String(),
    };
  }

  /// Nettoie les ressources
  void dispose() {
    stopTracking();
  }
}
