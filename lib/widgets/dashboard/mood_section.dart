import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';

class MoodSection extends ConsumerWidget {
  final Map<String, dynamic>? stats;

  const MoodSection({
    Key? key,
    this.stats,
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
              'Stemming',
              style: AppDesignSystem.heading3,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/mood-entry');
              },
              child: Row(
                children: [
                  const Icon(Icons.add, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Registreren',
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
        Container(
          padding: const EdgeInsets.all(AppDesignSystem.space16),
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
            children: [
              _buildMoodHeader(context),
              const SizedBox(height: AppDesignSystem.space16),
              _buildMoodCircles(context, stats),
              const SizedBox(height: AppDesignSystem.space16),
              _buildMoodInsight(context, stats),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDesignSystem.space8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          ),
          child: Icon(
            Icons.mood,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDesignSystem.space12),
        Text(
          'Hoe voel je je vandaag?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildMoodCircles(BuildContext context, Map<String, dynamic>? stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMoodOption(context, '😢', 'Heel slecht', 1),
        _buildMoodOption(context, '😞', 'Slecht', 2),
        _buildMoodOption(context, '😐', 'Neutraal', 3),
        _buildMoodOption(context, '😊', 'Goed', 4),
        _buildMoodOption(context, '😁', 'Heel goed', 5),
      ],
    );
  }

  Widget _buildMoodOption(
      BuildContext context, String emoji, String label, int value) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/mood-entry',
          arguments: value,
        );
      },
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: AppDesignSystem.space8),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodInsight(BuildContext context, Map<String, dynamic>? stats) {
    final String insightText = _getMoodInsight(stats);

    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: AppDesignSystem.space8),
          Expanded(
            child: Text(
              insightText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodInsight(Map<String, dynamic>? stats) {
    if (stats == null || stats['averageMood'] == null) {
      return 'Registreer je stemming om meer inzichten te krijgen.';
    }

    final double avgMood = stats['averageMood'];

    if (avgMood >= 4) {
      return 'Je gemiddelde stemming is erg positief. Goed bezig!';
    } else if (avgMood >= 3) {
      return 'Je gemiddelde stemming is stabiel en positief.';
    } else if (avgMood >= 2) {
      return 'Je stemming is neutraal tot licht negatief. Probeer wat meer aandacht te besteden aan zelfzorg.';
    } else {
      return 'Je stemming is lager dan gemiddeld. Probeer activiteiten te doen die je stemming kunnen verbeteren.';
    }
  }
}
