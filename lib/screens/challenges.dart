import 'package:flutter/material.dart';
import '../widgets/challenge_card.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  static const _challenges = [
    {'title': 'Geen social media na 20h', 'xp': 20, 'icon': Icons.nights_stay},
    {'title': 'Lees 10 pagina’s in een boek',  'xp': 10, 'icon': Icons.book},
    {'title': 'Wandel 15 minuten buiten',      'xp': 15, 'icon': Icons.directions_walk},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _challenges.length,
        itemBuilder: (context, i) {
          final c = _challenges[i];
          return ChallengeCard(
            title: c['title'] as String,
            xp: c['xp'] as int,
            icon: c['icon'] as IconData,
            onComplete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Uitdaging voltooid: ${c['title']}! +${c['xp']} XP'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
