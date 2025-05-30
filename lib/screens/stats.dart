  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../widgets/progress_circle.dart';
  import '../providers/mood_provider.dart';

  class StatsScreen extends ConsumerWidget {
    const StatsScreen({super.key});
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final stats = ref.watch(moodStatsProvider);
      final avg = stats.count == 0 ? 0.0 : stats.averageMood / 5.0;

      return Center(
        child: ProgressCircle(
          percentage: avg,
          size: 140,
          label: stats.count == 0 ? 'Geen gegevens' : '${(avg * 100).round()}%',
        ),
      );
    }
  }
