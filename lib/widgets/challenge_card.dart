import 'package:flutter/material.dart';
import 'package:social_balans/core/design_system.dart';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/models/challenge_category_adapter.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onToggle;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onToggle,
  });

  Color _getCategoryColor(ChallengeCategory category, BuildContext context) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return AppDesignSystem.primaryBlue;
      case ChallengeCategory.focus:
        return AppDesignSystem.success;
      case ChallengeCategory.notifications:
        return AppDesignSystem.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(challenge.category, context);
    final progress = _calculateProgress();
    final bool isExpired = challenge.endDate != null &&
        !challenge.isDone &&
        DateTime.now().isAfter(challenge.endDate!);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Progress bar at the top
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.scaffoldBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            minHeight: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(AppDesignSystem.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, categoryColor, isExpired),
                const SizedBox(height: AppDesignSystem.space12),
                if (challenge.description?.isNotEmpty ?? false)
                  Text(
                    challenge.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                const SizedBox(height: AppDesignSystem.space16),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    if (challenge.isDone) return 1.0;
    if (challenge.endDate == null) return 0.0;

    final total =
        challenge.endDate!.difference(challenge.startDate).inMilliseconds;
    if (total <= 0) return 1.0;

    final elapsed =
        DateTime.now().difference(challenge.startDate).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Widget _buildHeader(
      BuildContext context, Color categoryColor, bool isExpired) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(challenge.category.icon, color: categoryColor, size: 28),
        const SizedBox(width: AppDesignSystem.space12),
        Expanded(
          child: Text(
            challenge.title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: AppDesignSystem.space8),
        if (challenge.isDone)
          _StatusChip(
            label: 'Voltooid',
            color: AppDesignSystem.success,
            icon: Icons.check_circle,
          )
        else if (isExpired)
          _StatusChip(
            label: 'Verlopen',
            color: AppDesignSystem.error,
            icon: Icons.timer_off,
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final timeLeft = _getTimeLeft();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (timeLeft != null)
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppDesignSystem.space4),
              Text(
                timeLeft,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor: challenge.isDone
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: Row(
            children: [
              Icon(
                challenge.isDone ? Icons.repeat : Icons.check,
                size: 18,
              ),
              const SizedBox(width: AppDesignSystem.space8),
              Text(challenge.isDone ? 'Herstarten' : 'Voltooien'),
            ],
          ),
        ),
      ],
    );
  }

  String? _getTimeLeft() {
    if (challenge.isDone || challenge.endDate == null) return null;
    final remaining = challenge.endDate!.difference(DateTime.now());

    if (remaining.isNegative) return "Verlopen";
    if (remaining.inDays > 1) return '${remaining.inDays} dagen resterend';
    if (remaining.inHours > 1) return '${remaining.inHours} uur resterend';
    return '${remaining.inMinutes} min resterend';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.space12,
          vertical: AppDesignSystem.space8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppDesignSystem.space8),
          Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
