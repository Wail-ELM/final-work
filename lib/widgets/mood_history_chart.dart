import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import '../core/design_system.dart';
import '../providers/mood_provider.dart';

class MoodHistoryChart extends ConsumerWidget {
  const MoodHistoryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodEntries =
        ref.watch(moodStatsProvider.select((stats) => stats.recentEntries));

    // 1. Compter les occurrences de chaque humeur
    final moodCounts = groupBy(moodEntries, (entry) => entry.moodValue)
        .map((key, value) => MapEntry(key, value.length));

    // 2. Préparer les données pour le graphique
    final barGroups = List.generate(5, (index) {
      final moodValue = index + 1;
      final count = moodCounts[moodValue]?.toDouble() ?? 0;
      return BarChartGroupData(
        x: moodValue,
        barRods: [
          BarChartRodData(
            toY: count,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDesignSystem.radiusSmall),
              topRight: Radius.circular(AppDesignSystem.radiusSmall),
            ),
            gradient: LinearGradient(
              colors: [
                _getColorForMood(moodValue).withOpacity(0.8),
                _getColorForMood(moodValue),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _getBottomTitles,
                reservedSize: 38,
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} jours',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Helper pour les titres en bas
  Widget _getBottomTitles(double value, TitleMeta meta) {
    Widget icon;
    switch (value.toInt()) {
      case 1:
        icon =
            Icon(Icons.sentiment_very_dissatisfied, color: _getColorForMood(1));
        break;
      case 2:
        icon = Icon(Icons.sentiment_dissatisfied, color: _getColorForMood(2));
        break;
      case 3:
        icon = Icon(Icons.sentiment_neutral, color: _getColorForMood(3));
        break;
      case 4:
        icon = Icon(Icons.sentiment_satisfied, color: _getColorForMood(4));
        break;
      case 5:
        icon = Icon(Icons.sentiment_very_satisfied, color: _getColorForMood(5));
        break;
      default:
        icon = const SizedBox.shrink();
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppDesignSystem.space8),
      child: icon,
    );
  }

  // Helper pour les couleurs
  Color _getColorForMood(int mood) {
    switch (mood) {
      case 1:
        return AppDesignSystem.error;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.grey;
      case 4:
        return AppDesignSystem.secondaryBlue;
      case 5:
        return AppDesignSystem.primaryGreen;
      default:
        return Colors.transparent;
    }
  }
}
