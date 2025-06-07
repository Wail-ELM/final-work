import 'package:flutter/material.dart';
import '../../core/design_system.dart';
import '../../models/mood_entry.dart';

class StatsGrid extends StatelessWidget {
  final int userStreak;
  final int? screenTime;
  final Map<String, dynamic>? stats;

  const StatsGrid({
    Key? key,
    required this.userStreak,
    this.screenTime,
    this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        padding: const EdgeInsets.all(AppDesignSystem.space16),
        mainAxisSpacing: AppDesignSystem.space16,
        crossAxisSpacing: AppDesignSystem.space16,
        children: [
          _buildStatCard(
            context,
            'Stemming',
            stats != null && stats!['averageMood'] != null
                ? _getMoodEmoji(stats!['averageMood'])
                : '😊',
            stats != null && stats!['averageMood'] != null
                ? '${stats!['averageMood'].toStringAsFixed(1)}/5'
                : 'N/A',
          ),
          _buildStatCard(
            context,
            'Streak',
            '🔥',
            '$userStreak dagen',
          ),
          _buildStatCard(
            context,
            'Schermtijd',
            '📱',
            screenTime != null
                ? '${(screenTime! / 60).toStringAsFixed(1)} uur'
                : 'N/A',
          ),
          _buildStatCard(
            context,
            'Notities',
            '📝',
            stats != null && stats!['totalEntries'] != null
                ? '${stats!['totalEntries']} entries'
                : '0 entries',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String emoji,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppDesignSystem.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: AppDesignSystem.space8),
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(double moodValue) {
    if (moodValue >= 4.5) return '😁';
    if (moodValue >= 3.5) return '😊';
    if (moodValue >= 2.5) return '😐';
    if (moodValue >= 1.5) return '😞';
    return '😢';
  }
}
