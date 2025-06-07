import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../widgets/weekly_insights_chart.dart';
import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';

class InsightsSection extends ConsumerWidget {
  final Map<String, dynamic>? stats;

  const InsightsSection({
    Key? key,
    this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodEntries = ref.watch(moodEntriesProvider).asData?.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Inzichten',
              style: AppDesignSystem.heading3,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/stats');
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
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDesignSystem.space16),
                child: _buildInsightHeader(context),
              ),
              SizedBox(
                height: 220,
                child: WeeklyInsightsChart(entries: moodEntries),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDesignSystem.space16),
                child: _buildInsightSummary(context, stats),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDesignSystem.space8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          ),
          child: Icon(
            Icons.insights,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDesignSystem.space12),
        Text(
          'Wekelijkse schermtijd',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildInsightSummary(
      BuildContext context, Map<String, dynamic>? stats) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_down,
                size: 16,
                color: AppDesignSystem.success,
              ),
              const SizedBox(width: AppDesignSystem.space8),
              Text(
                'Samenvatting',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space8),
          Text(
            _getInsightSummary(stats),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getInsightSummary(Map<String, dynamic>? stats) {
    if (stats == null) {
      return 'Gebruik je telefoon gedurende de week om trends en inzichten te zien.';
    }

    if (stats.containsKey('screenTimeReduction') &&
        stats['screenTimeReduction'] != null) {
      final reduction = stats['screenTimeReduction'];
      if (reduction > 0) {
        return 'Je hebt je schermtijd met $reduction% verminderd deze week. Goed bezig!';
      } else if (reduction < 0) {
        return 'Je schermtijd is met ${-reduction}% toegenomen deze week. Probeer je doelen in gedachten te houden.';
      } else {
        return 'Je schermtijd is gelijk gebleven deze week.';
      }
    }

    return 'Bekijk je trends om inzicht te krijgen in je schermgebruik.';
  }
}
