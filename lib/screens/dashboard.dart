import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/progress_circle.dart';
import '../widgets/challenge_card.dart';
import '../providers/challenge_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final challenges = ref.watch(allChallengesProvider);
    final percentDone = challenges.isEmpty
        ? 0.0
        : (challenges.where((c) => c.isDone).length / challenges.length);

    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: ProgressCircle(
            percentage: percentDone,
            size: 120,
            label: '${(percentDone * 100).round()}%',
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Je volgende uitdagingen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        for (final c in challenges.where((c) => !c.isDone))
          ChallengeCard(
            challenge: c,
            actionLabel: 'Voltooi',
            onAction: () =>
                ref.read(challengeProvider(c.id).notifier).markDone(),
          ),
      ],
    );
  }
}
