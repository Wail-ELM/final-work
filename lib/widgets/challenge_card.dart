import 'package:flutter/material.dart';
import '../theme.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final int xp;
  final IconData icon;
  final VoidCallback onComplete;

  const ChallengeCard({
    Key? key,
    required this.title,
    required this.xp,
    required this.icon,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          // Ne pas prendre toute la hauteur disponible
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // On laisse le bouton être à sa taille intrinsèque
                ElevatedButton(
                  onPressed: onComplete,
                  child: const Text('Done'),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 20, color: AppTheme.pastelGold),
                    const SizedBox(width: 4),
                    Text(
                      '$xp XP',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
