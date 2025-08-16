import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_balans/core/design_system.dart';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/widgets/challenge_card.dart';

class ChallengesSection extends ConsumerWidget {
  final List<Challenge> challenges;

  const ChallengesSection({
    Key? key,
    required this.challenges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uitdagingen',
              style: AppDesignSystem.heading3,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/challenges');
              },
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Bekijk alles',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDesignSystem.space16),
        if (challenges.isEmpty)
          _buildEmptyChallenges(context)
        else
          _buildChallengesList(context, challenges),
      ],
    );
  }

  Widget _buildEmptyChallenges(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDesignSystem.space16),
          Text(
            'Geen actieve uitdagingen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignSystem.space8),
          Text(
            'Start een nieuwe uitdaging om je schermtijd te verminderen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignSystem.space20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/suggestions');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignSystem.space24,
                vertical: AppDesignSystem.space12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.radiusMedium),
              ),
            ),
            child: const Text('Ontdek uitdagingen'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList(
      BuildContext context, List<Challenge> challenges) {
    return Column(
      children: challenges.map((challenge) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDesignSystem.space16),
          child: ChallengeCard(
            challenge: challenge,
            onToggle: () {
              // Logique de basculement de défi
            },
          ),
        );
      }).toList(),
    );
  }
}
