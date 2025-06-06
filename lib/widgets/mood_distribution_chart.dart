import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';
import './empty_state_widget.dart';

class MoodDistributionChart extends StatelessWidget {
  final List<MoodEntry> entries;

  const MoodDistributionChart({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final sections = _getMoodSections();
    final totalValue =
        sections.fold<double>(0.0, (sum, section) => sum + section.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verdeling van stemmingen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (totalValue == 0)
              const EmptyStateWidget(
                icon: Icons.pie_chart_outline,
                title: 'Geen data beschikbaar',
                message: 'Voer je stemming in om hier een verdeling te zien.',
              )
            else
              AspectRatio(
                aspectRatio: 1.5,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                          startDegreeOffset: -90,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildLegendItems(sections),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getMoodSections() {
    final moodCounts = <int, int>{};
    for (var entry in entries) {
      final moodValue = entry.moodValue.round();
      moodCounts[moodValue] = (moodCounts[moodValue] ?? 0) + 1;
    }

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green,
    ];

    final labels = [
      'Zeer slecht',
      'Slecht',
      'Neutraal',
      'Goed',
      'Zeer goed',
    ];

    return List.generate(5, (index) {
      final value = index + 1;
      final count = moodCounts[value] ?? 0;
      final percentage = entries.isEmpty ? 0.0 : count / entries.length * 100;

      return PieChartSectionData(
        value: count.toDouble(),
        title: '${percentage.round()}%',
        color: colors[index],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _buildLegendItems(List<PieChartSectionData> sections) {
    final labels = [
      'Zeer slecht',
      'Slecht',
      'Neutraal',
      'Goed',
      'Zeer goed',
    ];

    return List.generate(sections.length, (index) {
      final section = sections[index];
      final percentage =
          entries.isEmpty ? 0.0 : section.value / entries.length * 100;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: section.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${percentage.round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
