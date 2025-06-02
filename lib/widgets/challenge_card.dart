import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../models/challenge_category_adapter.dart';

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

  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return Colors.blue;
      case ChallengeCategory.focus:
        return Colors.green;
      case ChallengeCategory.notifications:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return Icons.phone_android;
      case ChallengeCategory.focus:
        return Icons.center_focus_strong;
      case ChallengeCategory.notifications:
        return Icons.notifications;
    }
  }

  int _getDaysCompleted() {
    final now = DateTime.now();
    final daysPassed = now.difference(challenge.startDate).inDays;
    return daysPassed.clamp(0, _getTotalDays());
  }

  int _getTotalDays() {
    if (challenge.endDate == null) return 30; // Default 30 days
    return challenge.endDate!.difference(challenge.startDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final categoryColor = _getCategoryColor(challenge.category);
    final daysCompleted = _getDaysCompleted();
    final totalDays = _getTotalDays();
    final progress = totalDays > 0 ? daysCompleted / totalDays : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor.withOpacity(0.05),
                categoryColor.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(challenge.category),
                        color: categoryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (challenge.description != null)
                            Text(
                              challenge.description!,
                              style: t.textTheme.bodySmall?.copyWith(
                                color: t.textTheme.bodySmall?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (challenge.isDone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Terminé',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progrès',
                          style: t.textTheme.bodySmall,
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: t.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(categoryColor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$daysCompleted/$totalDays jours',
                          style: t.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Commencé le ${challenge.startDate.day}/${challenge.startDate.month}',
                          style: t.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: challenge.isDone ? null : onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(challenge.isDone ? 'Complété' : actionLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
