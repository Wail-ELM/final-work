import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/challenge_card.dart';
import '../providers/challenge_provider.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(allChallengesProvider);
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: all.length,
      itemBuilder: (_, i) {
        final c = all[i];
        return ChallengeCard(
          challenge: c,
          actionLabel: c.isDone ? 'Ongedaan maken' : 'Voltooien',
          onAction: () =>
              ref.read(challengeProvider(c.id).notifier).toggleDone(),
        );
      },
    );
  }
}
