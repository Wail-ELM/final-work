import 'dart:math';
import '../models/mood_entry.dart';
import '../models/challenge.dart';
import '../models/challenge_category_adapter.dart';
import '../models/screen_time_entry.dart';
import 'package:uuid/uuid.dart';
import '../models/assessment_model.dart';

class DemoDataService {
  static const String _demoUserId = "demo-user-123";

  /// Génère des données de démo pour les 30 derniers jours
  static List<MoodEntry> generateDemoMoodEntries() {
    final List<MoodEntry> entries = [];
    final random = Random();
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));

      // Simulation de patterns réalistes
      double baseMood = 3.0;

      // Weekend = meilleure humeur
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        baseMood += 0.8;
      }

      // Lundi = humeur plus basse
      if (date.weekday == DateTime.monday) {
        baseMood -= 0.5;
      }

      // Variation aléatoire
      baseMood += (random.nextDouble() - 0.5) * 1.5;
      baseMood = baseMood.clamp(1.0, 5.0);

      entries.add(MoodEntry(
        id: const Uuid().v4(),
        userId: _demoUserId,
        moodValue: baseMood.round(),
        note: _getDemoMoodNote(baseMood.round()),
        createdAt: date,
      ));
    }

    return entries.reversed.toList(); // Plus récent en premier
  }

  /// Génère des données de screen time pour les 30 derniers jours
  static List<ScreenTimeEntry> generateDemoScreenTimeEntries() {
    final List<ScreenTimeEntry> entries = [];
    final random = Random();
    final now = DateTime.now();

    final apps = [
      'TikTok',
      'Instagram',
      'WhatsApp',
      'YouTube',
      'Netflix',
      'Facebook',
      'Twitter',
      'Safari',
      'Chrome',
      'Spotify'
    ];

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));

      // Simulation patterns réalistes par jour
      int baseTotalMinutes = 240; // 4h base

      // Weekend = plus de temps d'écran
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        baseTotalMinutes += 120; // +2h
      }

      // Variation aléatoire
      baseTotalMinutes += random.nextInt(180) - 60; // ±1-3h
      baseTotalMinutes = baseTotalMinutes.clamp(60, 600); // 1h min, 10h max

      // Distribuer le temps entre les apps
      int remainingMinutes = baseTotalMinutes;
      final appsToUse =
          apps.take(random.nextInt(5) + 3).toList(); // 3-7 apps par jour

      for (int j = 0; j < appsToUse.length; j++) {
        final app = appsToUse[j];
        int appMinutes;

        if (j == appsToUse.length - 1) {
          appMinutes = remainingMinutes;
        } else {
          final maxForThisApp = (remainingMinutes * 0.5).round();
          appMinutes =
              random.nextInt(maxForThisApp + 1) + 1; // Au moins 1 minute
        }

        if (appMinutes > 0) {
          entries.add(ScreenTimeEntry(
            id: const Uuid().v4(),
            userId: _demoUserId,
            appName: app,
            duration: Duration(minutes: appMinutes),
            date: date,
            createdAt: date,
          ));
          remainingMinutes -= appMinutes;

          if (remainingMinutes <= 0) break;
        }
      }
    }

    return entries.reversed.toList();
  }

  /// Génère des challenges de démo
  static List<Challenge> generateDemoChallenges() {
    final now = DateTime.now();

    return [
      // Challenge completé
      Challenge(
        id: const Uuid().v4(),
        userId: _demoUserId,
        title: "30 minuten minder schermtijd",
        description: "Verminder dagelijkse schermtijd met 30 minuten",
        category: ChallengeCategory.screenTime,
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 7)),
        isDone: true,
      ),

      // Challenge actif
      Challenge(
        id: const Uuid().v4(),
        userId: _demoUserId,
        title: "Dagelijkse 10 minuten meditatie",
        description: "Elke dag 10 minuten meditatie om stress te verminderen",
        category: ChallengeCategory.focus,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 9)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
        isDone: false,
      ),

      // Challenge récent
      Challenge(
        id: const Uuid().v4(),
        userId: _demoUserId,
        title: "Geen notificaties tijdens maaltijden",
        description: "Telefoon op stil tijdens ontbijt, lunch en diner",
        category: ChallengeCategory.notifications,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 12)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
        isDone: false,
      ),
    ];
  }

  static List<UserAssessment> generateDemoAssessments() {
    // Implémentation factice pour éviter les erreurs
    return [];
  }

  /// Génère des notes de humeur réalistes
  static String? _getDemoMoodNote(int mood) {
    final notes = {
      1: [
        "Moeilijke dag gehad",
        "Veel stress op werk",
        "Weinig geslapen",
        "Veel social media gebruikt"
      ],
      2: ["Beetje down vandaag", "Niet zo'n goede dag", "Moe en gestrest"],
      3: ["Normale dag", "Oké gevoeld", "Niets bijzonders"],
      4: ["Goede dag gehad", "Productief geweest", "Leuk met vrienden geweest"],
      5: [
        "Fantastische dag!",
        "Heel blij en energiek",
        "Alles liep perfect",
        "Geweldige stemming"
      ]
    };

    final moodNotes = notes[mood] ?? [];
    if (moodNotes.isEmpty) return null;

    final random = Random();
    return random.nextBool()
        ? moodNotes[random.nextInt(moodNotes.length)]
        : null;
  }

  /// Check si on est en mode démo
  static bool isDemoMode(String? userId) {
    return userId == null || userId == _demoUserId;
  }

  /// ID de l'utilisateur démo
  static String get demoUserId => _demoUserId;
}
 