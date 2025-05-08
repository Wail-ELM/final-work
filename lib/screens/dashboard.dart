import 'package:flutter/material.dart';
import '../widgets/progress_circle.dart';
import '../widgets/challenge_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social Balans'), centerTitle: true, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          Text(
            '“Een goede balans is een bewuste keuze.”',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Center(child: ProgressCircle(percent: 0.7, label: 'vandaag')),
          const SizedBox(height: 32),
          ChallengeCard(
            title: '30 min zonder telefoon tijdens ontbijt',
            xp: 15,
            icon: Icons.free_breakfast,
            onComplete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goed gedaan! +15 XP')),
              );
            },
          ),
        ],
      ),
    );
  }
}
