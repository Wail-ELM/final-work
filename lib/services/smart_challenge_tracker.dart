import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/models/challenge_category_adapter.dart';
import '../providers/challenge_provider.dart';
import '../providers/mood_provider.dart';
import '../services/app_usage_service.dart';
import '../providers/user_objective_provider.dart';
import 'package:hive/hive.dart';

/// Service intelligent pour la détection automatique de la complétion des défis.
/// Analyse les données utilisateur pour valider les progrès de manière asynchrone.
class SmartChallengeTracker {
  final Ref _ref;
  SmartChallengeTracker(this._ref);

  Timer? _checkTimer;
  bool _isTracking = false;

  /// Démarre la surveillance automatique des défis en arrière-plan.
  Future<void> startTracking() async {
    if (_isTracking) return;

    _isTracking = true;

    // Vérifie les défis toutes les 5 minutes.
    _checkTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkAllActiveChallenges();
    });

    debugPrint('SmartChallengeTracker: Started automatic challenge tracking.');
  }

  /// Arrête la surveillance des défis.
  void stopTracking() {
    if (!_isTracking) return;
    _isTracking = false;
    _checkTimer?.cancel();
    _checkTimer = null;
    debugPrint('SmartChallengeTracker: Stopped automatic challenge tracking.');
  }

  /// Vérifie tous les défis actuellement actifs pour détecter une éventuelle complétion.
  Future<void> _checkAllActiveChallenges() async {
    try {
      final challengesNotifier = _ref.read(allChallengesProvider.notifier);
      final activeChallenges = challengesNotifier.state
          .where((c) => !c.isDone && _isChallengeCurrentlyActive(c))
          .toList();

      if (activeChallenges.isEmpty) return;

      debugPrint(
          'SmartChallengeTracker: Checking ${activeChallenges.length} active challenges...');

      for (final challenge in activeChallenges) {
        final isCompleted = await _checkIfChallengeIsCompleted(challenge);
        if (isCompleted) {
          await _markChallengeAsCompleted(challenge);
        }
      }
    } catch (e) {
      debugPrint('SmartChallengeTracker: Error during periodic check: $e');
    }
  }

  /// Logique centrale pour déterminer si un défi est complété.
  Future<bool> _checkIfChallengeIsCompleted(Challenge challenge) async {
    try {
      switch (challenge.category) {
        case ChallengeCategory.screenTime:
          return await _checkScreenTimeChallengeLogic(challenge);
        case ChallengeCategory.focus:
          return await _checkFocusChallengeLogic(challenge);
        case ChallengeCategory.notifications:
          return await _checkNotificationChallengeLogic(challenge);
        default:
          return false;
      }
    } catch (e) {
      debugPrint(
          'SmartChallengeTracker: Error checking challenge ${challenge.id}: $e');
      return false;
    }
  }

  // --- LOGIQUES SPÉCIFIQUES PAR CATÉGORIE ---

  /// Logique pour les défis de "Temps d'écran".
  Future<bool> _checkScreenTimeChallengeLogic(Challenge challenge) async {
    final appUsageService = _ref.read(appUsageServiceProvider);
    final today = DateTime.now();
    final todayUsage = await appUsageService.getTotalScreenTimeForDate(today);

    if (todayUsage == null) return false;

    // Exemple : "Limiter le temps d'écran à 2 heures"
    if (challenge.title.contains('limiter') ||
        challenge.title.contains('max')) {
      // Supposons que la limite est dans le titre, ex: "2 heures"
      final targetHours = _extractHoursFromTitle(challenge.title, 2);
      return todayUsage.inHours < targetHours;
    }

    // Exemple : "Réduire le temps de 30 minutes"
    if (challenge.title.contains('réduire') ||
        challenge.title.contains('minder')) {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayUsage =
          await appUsageService.getTotalScreenTimeForDate(yesterday);
      if (yesterdayUsage == null) return false;
      return (yesterdayUsage - todayUsage).inMinutes >= 30;
    }

    return false;
  }

  /// Logique pour les défis de "Focus".
  Future<bool> _checkFocusChallengeLogic(Challenge challenge) async {
    // Exemple: "Session Pomodoro" - simulé si l'humeur est bonne
    final moodStats = _ref.read(moodStatsProvider);
    final lastMood = moodStats.recentEntries.isNotEmpty
        ? moodStats.recentEntries.first.moodValue
        : 0;
    if (challenge.title.toLowerCase().contains('pomodoro')) {
      return lastMood >= 4; // Complété si l'humeur est bonne (>=4/5)
    }
    return false;
  }

  /// Logique pour les défis de "Notifications".
  Future<bool> _checkNotificationChallengeLogic(Challenge challenge) async {
    // Exemple : "Pas de notifications le soir"
    if (challenge.title.toLowerCase().contains('soir')) {
      // Simulé : on vérifie que le dernier usage de l'app était avant 21h hier.
      final appUsageService = _ref.read(appUsageServiceProvider);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final usage = await appUsageService.getAppUsageForDate(yesterday);
      // Cette logique est une simplification et devrait être affinée.
      return usage.isEmpty;
    }
    return false;
  }

  /// Marque un défi comme complété dans l'état global de l'application.
  Future<void> _markChallengeAsCompleted(Challenge challenge) async {
    try {
      final challengesNotifier = _ref.read(allChallengesProvider.notifier);
      challengesNotifier.update(challenge.copyWith(isDone: true));

      debugPrint(
          'SmartChallengeTracker: Auto-completed challenge: ${challenge.title}');

      // TODO: Déclencher une notification de succès via NotificationService
    } catch (e) {
      debugPrint(
          'SmartChallengeTracker: Error marking challenge as completed: $e');
    }
  }

  // --- HELPERS ---

  bool _isChallengeCurrentlyActive(Challenge challenge) {
    final now = DateTime.now();
    if (challenge.endDate != null && now.isAfter(challenge.endDate!)) {
      return false; // Expiré
    }
    return now.isAfter(challenge.startDate);
  }

  int _extractHoursFromTitle(String title, int defaultValue) {
    final match = RegExp(r'(\d+)\s*heure').firstMatch(title.toLowerCase());
    return match != null
        ? int.tryParse(match.group(1)!) ?? defaultValue
        : defaultValue;
  }

  void dispose() {
    stopTracking();
  }
}

/// Provider pour le service de tracking intelligent des défis.
final smartChallengeTrackerProvider = Provider<SmartChallengeTracker>((ref) {
  final tracker = SmartChallengeTracker(ref);
  // Démarre automatiquement le suivi quand le provider est initialisé.
  tracker.startTracking();
  ref.onDispose(() => tracker.dispose());
  return tracker;
});
