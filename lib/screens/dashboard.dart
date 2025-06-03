import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/progress_circle.dart';
import '../providers/mood_provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_objective_provider.dart';
import '../widgets/challenge_card.dart';
import '../models/challenge.dart';
import '../widgets/weekly_insights_chart.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/mood_entry_screen.dart';
import '../screens/challenge_creation_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(moodStatsProvider);
    final challenges = ref
        .watch(allChallengesProvider)
        .where((c) => !c.isDone)
        .take(3)
        .toList();
    final userStreak = ref.watch(userStreakProvider);
    final screenTimeAsync = ref.watch(screenTimeProvider);
    final dailyObjectiveAsync = ref.watch(dailyObjectiveProvider);
    final weeklyProgressAsync = ref.watch(weeklyProgressProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Rafraîchir les données
        ref.refresh(moodStatsProvider);
        ref.refresh(allChallengesProvider);
        ref.refresh(userStreakProvider);
        ref.refresh(screenTimeProvider);
        ref.refresh(dailyObjectiveProvider);
        ref.refresh(weeklyProgressProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            screenTimeAsync.when(
              data: (screenTime) =>
                  _buildHeader(context, userStreak, screenTime),
              loading: () => _buildHeader(
                  context, userStreak, const Duration(hours: 2, minutes: 30)),
              error: (_, __) =>
                  _buildHeader(context, userStreak, Duration.zero),
            ),
            const SizedBox(height: 24),
            _buildMoodSection(context, ref, stats),
            const SizedBox(height: 24),
            dailyObjectiveAsync.when(
              data: (objective) => weeklyProgressAsync.when(
                data: (progress) =>
                    _buildDailyObjective(context, objective, progress),
                loading: () => _buildDailyObjective(context, objective, 0.0),
                error: (_, __) => _buildDailyObjective(context, objective, 0.0),
              ),
              loading: () => _buildDailyObjective(
                  context, "Focus op bewust schermgebruik", 0.0),
              error: (_, __) => _buildDailyObjective(
                  context, "Focus op bewust schermgebruik", 0.0),
            ),
            const SizedBox(height: 24),
            _buildActiveChallenges(context, ref, challenges),
            const SizedBox(height: 24),
            screenTimeAsync.when(
              data: (screenTime) =>
                  _buildWeeklyInsights(context, ref, stats, screenTime),
              loading: () => _buildWeeklyInsights(
                  context, ref, stats, const Duration(hours: 2, minutes: 30)),
              error: (_, __) =>
                  _buildWeeklyInsights(context, ref, stats, Duration.zero),
            ),
            const SizedBox(height: 24),
            _buildMotivationalQuote(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int streak, Duration screenTime) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welkom terug!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Je streak: $streak dagen",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.timer,
                  "${screenTime.inHours}u ${screenTime.inMinutes % 60}m",
                  "Schermtijd vandaag",
                ),
                _buildStatItem(
                  context,
                  Icons.emoji_events,
                  "$streak",
                  "Dagen streak",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildMoodSection(
      BuildContext context, WidgetRef ref, MoodStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Gemiddelde stemming",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Nouvelle entrée"),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodEntryScreen(),
                      ),
                    );
                    // Si une entrée a été sauvegardée, rafraîchir les données
                    if (result == true) {
                      ref.refresh(moodStatsProvider);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: ProgressCircle(
                    percentage:
                        stats.count == 0 ? 0.0 : stats.averageMood / 5.0,
                    size: 100,
                    label: stats.count == 0
                        ? 'Geen\ngegevens'
                        : '${(stats.averageMood / 5.0 * 100).round()}%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMoodStat("Vandaag", stats.todayMood ?? 0),
                      const SizedBox(height: 8),
                      _buildMoodStat("Deze week", stats.averageMood),
                      const SizedBox(height: 8),
                      _buildMoodStat("Vorige week", stats.lastWeekAverage),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodStat(String label, double value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 5.0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getMoodColor(value)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "${(value / 5.0 * 100).round()}%",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getMoodColor(double value) {
    if (value >= 4) return Colors.green;
    if (value >= 3) return Colors.lightGreen;
    if (value >= 2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDailyObjective(
      BuildContext context, String objective, double progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dagelijkse focus",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(objective, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 4),
            Text(
              "${(progress * 100).round()}% van weekdoel behaald",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChallenges(
    BuildContext context,
    WidgetRef ref,
    List<Challenge> challenges,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Actieve uitdagingen",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Nouvelle"),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChallengeCreationScreen(),
                      ),
                    );
                    // Si un défi a été créé, rafraîchir les données
                    if (result == true) {
                      ref.refresh(allChallengesProvider);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (challenges.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Je hebt momenteel geen actieve uitdagingen."),
                ),
              )
            else
              ...challenges.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChallengeCard(
                    challenge: c,
                    actionLabel: 'Voltooien',
                    onAction: () =>
                        ref.read(challengeProvider(c.id).notifier).toggleDone(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyInsights(
    BuildContext context,
    WidgetRef ref,
    MoodStats stats,
    Duration screenTime,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Wekelijkse inzichten",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Details"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            WeeklyInsightsChart(
              entries: stats.recentEntries,
              screenTime: screenTime,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInsightItem(
                  context,
                  Icons.trending_up,
                  "Gemiddelde stemming",
                  "${(stats.averageMood / 5.0 * 100).round()}%",
                ),
                _buildInsightItem(
                  context,
                  Icons.timer,
                  "Schermtijd",
                  "${screenTime.inHours}u ${screenTime.inMinutes % 60}m",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote() {
    final quote = _getMotivationalQuote();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dagelijkse inspiratie",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"$quote"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "— Social Balans",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalQuote() {
    final quotes = [
      "Elke kleine stap telt.",
      "Bewust leven begint met bewuste keuzes.",
      "Je hebt vandaag een keuze om te groeien.",
      "Minder scherm, meer leven.",
      "Rust is ook productief.",
      "Focus op wat echt belangrijk is.",
      "Kwaliteit boven kwantiteit.",
      "Je bent sterker dan je denkt.",
      "Balans is de sleutel tot geluk.",
      "Vandaag is een nieuwe kans.",
    ];
    quotes.shuffle();
    return quotes.first;
  }
}
