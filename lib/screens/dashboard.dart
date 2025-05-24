import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/progress_circle.dart';
import '../providers/mood_provider.dart';
import '../providers/challenge_provider.dart';
import '../widgets/challenge_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(moodStatsProvider);
    final challenges = ref.watch(allChallengesProvider)
        .where((c) => !c.isDone)
        .take(3)
        .toList();

    final moodLabel = stats.count == 0 ? 'Geen gegevens' : '${(stats.averageMood / 5.0 * 100).round()}%';
    final quote = _getMotivationalQuote();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welkom terug!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Mood Section
          const Text("Gemiddelde stemming", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Center(
            child: ProgressCircle(
              percentage: stats.count == 0 ? 0.0 : stats.averageMood / 5.0,
              size: 120,
              label: moodLabel,
            ),
          ),
          const SizedBox(height: 24),

          // Active Challenges
          const Text("Actieve uitdagingen", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (challenges.isEmpty)
            const Text("Je hebt momenteel geen actieve uitdagingen."),
          for (var c in challenges)
            ChallengeCard(
              challenge: c,
              actionLabel: 'Voltooien',
              onAction: () =>
                  ref.read(challengeProvider(c.id).notifier).toggleDone(),
            ),
          const SizedBox(height: 24),

          // Motivational Quote
          const Text("Dagelijkse inspiratie", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('“$quote”', style: const TextStyle(fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  String _getMotivationalQuote() {
    final quotes = [
      "Elke kleine stap telt.",
      "Bewust leven begint met bewuste keuzes.",
      "Je hebt vandaag een keuze om te groeien.",
      "Minder scherm, meer leven.",
      "Rust is ook productief."
    ];
    quotes.shuffle();
    return quotes.first;
  }
}
