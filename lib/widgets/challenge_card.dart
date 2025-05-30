import 'package:flutter/material.dart';
import '../models/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final String actionLabel;
  final VoidCallback onAction;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.title, style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (challenge.description != null)
              Text(challenge.description!, style: t.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
