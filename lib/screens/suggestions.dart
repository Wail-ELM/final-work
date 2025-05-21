// lib/screens/suggestions.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge.dart';
import '../models/challenge_category_adapter.dart';
import '../data/challenge_templates.dart';
import '../providers/user_objective_provider.dart';
import '../providers/suggestion_provider.dart';
import '../providers/challenge_provider.dart';
import '../widgets/challenge_card.dart';

/// Scherm waarin de gebruiker eerst een doel kiest,
/// en vervolgens passende challenges kan toevoegen.
class SuggestionsScreen extends ConsumerWidget {
  const SuggestionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Huidig gekozen doel (ChallengeCategory?) of null
    final ChallengeCategory? objective = ref.watch(userObjectiveProvider);
    // Lijst van templates gefilterd op dat doel
    final templates = ref.watch(suggestedTemplatesProvider);

    // 1) Doel nog niet gekozen → laat radio buttons zien
    if (objective == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kies je doel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Eén RadioListTile per categorie
            for (final cat in ChallengeCategory.values)
              RadioListTile<ChallengeCategory>(
                title: Text(cat.name), // bijv. 'screenTime', 'focus', 'notifications'
                value: cat,
                groupValue: objective,
                onChanged: (c) {
                  ref.read(userObjectiveProvider.notifier).state = c;
                },
              ),
          ],
        ),
      );
    }

    if (templates.isEmpty) {
      return const Center(
        child: Text('Geen suggesties beschikbaar voor dit doel.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16),
      children: templates.map((tpl) {
        final challenge = Challenge(
          id: tpl.id,
          title: tpl.title,
          description: tpl.description,
          xpReward: tpl.xp,
        );
        return ChallengeCard(
          challenge: challenge,
          actionLabel: 'Toevoegen',
          onAction: () async {
            await ref.read(allChallengesProvider.notifier).add(challenge);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Uitdaging toegevoegd!')),
            );
          },
        );
      }).toList(),
    );
  }
}
