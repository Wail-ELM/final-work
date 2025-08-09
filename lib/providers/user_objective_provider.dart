import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_balans/models/challenge_category_adapter.dart';
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
