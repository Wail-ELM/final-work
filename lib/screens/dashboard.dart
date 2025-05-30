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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(moodStatsProvider);
    final challenges =
        ref
            .watch(allChallengesProvider)
            .where((c) => !c.isDone)
            .take(3)
            .toList();
    final userStreak = ref.watch(userStreakProvider);
    final screenTime = ref.watch(screenTimeProvider);
    final dailyObjective = ref.watch(dailyObjectiveProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Rafraîchir les données
        ref.refresh(moodStatsProvider);
        ref.refresh(allChallengesProvider);
        ref.refresh(userStreakProvider);
        ref.refresh(screenTimeProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, userStreak, screenTime),
            const SizedBox(height: 24),
            _buildMoodSection(context, stats),
            const SizedBox(height: 24),
            _buildDailyObjective(context, dailyObjective),
            const SizedBox(height: 24),
            _buildActiveChallenges(context, ref, challenges),
            const SizedBox(height: 24),
            _buildWeeklyInsights(context, ref, stats),
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

  Widget _buildMoodSection(BuildContext context, MoodStats stats) {
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
                  label: const Text("Nieuwe entry"),
                  onPressed: () {
                    // TODO: Navigate to mood entry
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ProgressCircle(
                    percentage:
                        stats.count == 0 ? 0.0 : stats.averageMood / 5.0,
                    size: 120,
                    label:
                        stats.count == 0
                            ? 'Geen gegevens'
                            : '${(stats.averageMood / 5.0 * 100).round()}%',
                  ),
                ),
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

  Widget _buildDailyObjective(BuildContext context, String objective) {
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
              value: 0.6, // TODO: Implement real progress
              backgroundColor: Colors.grey[200],
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
                  label: const Text("Nieuwe"),
                  onPressed: () {
                    // TODO: Navigate to new challenge
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
                    onAction:
                        () =>
                            ref
                                .read(challengeProvider(c.id).notifier)
                                .toggleDone(),
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
  ) {
    final screenTime = ref.watch(screenTimeProvider);

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
