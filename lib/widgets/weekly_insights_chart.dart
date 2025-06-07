import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io' show Platform;
import '../models/mood_entry.dart';
import '../core/design_system.dart';
import '../providers/user_objective_provider.dart';

class WeeklyInsightsChart extends ConsumerWidget {
  final List<MoodEntry> entries;

  const WeeklyInsightsChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppDesignSystem.space40),
        child: Center(
          child: Text(
            'Geen stemmingsdata beschikbaar om inzichten te genereren.',
            style: AppDesignSystem.body2
                .copyWith(color: AppDesignSystem.neutral500),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final weeklyScreenTimeAsync = ref.watch(weeklyScreenTimeDataProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Jouw Weekoverzicht", style: AppDesignSystem.heading3),
        const SizedBox(height: AppDesignSystem.space8),
        Text(
          "Analyse van je humeur en schermtijd.",
          style:
              AppDesignSystem.body2.copyWith(color: AppDesignSystem.neutral500),
        ),
        const SizedBox(height: AppDesignSystem.space24),
        _buildMoodChart(context),
        const SizedBox(height: AppDesignSystem.space32),
        weeklyScreenTimeAsync.when(
          data: (weeklyData) {
            if (weeklyData.isEmpty || !Platform.isAndroid) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScreenTimeChart(context, weeklyData),
                const SizedBox(height: AppDesignSystem.space24),
                _buildInsightSummary(context, weeklyData),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMoodChart(BuildContext context) {
    final spots = _getMoodSpots();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.sentiment_very_satisfied_outlined,
                color: AppDesignSystem.primaryBlue, size: 20),
            const SizedBox(width: AppDesignSystem.space8),
            Text("Humeur Trend",
                style: AppDesignSystem.body1
                    .copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: AppDesignSystem.space16),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 1) return _leftTitleWidgets('😔');
                      if (value == 3) return _leftTitleWidgets('😐');
                      if (value == 5) return _leftTitleWidgets('😊');
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final days = ['M', 'D', 'W', 'D', 'V', 'Z', 'Z'];
                      return Text(days[value.toInt()],
                          style: AppDesignSystem.caption);
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0.5,
              maxY: 5.5,
              minX: 0,
              maxX: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppDesignSystem.primaryBlue,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppDesignSystem.primaryBlue.withOpacity(0.3),
                        AppDesignSystem.primaryBlue.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScreenTimeChart(
      BuildContext context, Map<DateTime, Duration> weeklyData) {
    final barGroups = _getScreenTimeBars(context, weeklyData);
    final maxHours = barGroups.isEmpty
        ? 1.0
        : barGroups.map((group) => group.barRods.first.toY).reduce(max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer_outlined,
                color: AppDesignSystem.neutral500, size: 20),
            const SizedBox(width: AppDesignSystem.space8),
            Text("Schermtijd per Dag",
                style: AppDesignSystem.body1
                    .copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: AppDesignSystem.space16),
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      if (value % (max(1, (maxHours / 4).round())) == 0) {
                        return Text('${value.toInt()}u',
                            style: AppDesignSystem.caption);
                      }
                      return const Text('');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final days = ['M', 'D', 'W', 'D', 'V', 'Z', 'Z'];
                      return Text(days[value.toInt()],
                          style: AppDesignSystem.caption);
                    },
                  ),
                ),
              ),
              barGroups: barGroups)),
        ),
      ],
    );
  }

  Widget _buildInsightSummary(
      BuildContext context, Map<DateTime, Duration> weeklyData) {
    if (entries.isEmpty || weeklyData.isEmpty || !Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    final correlation = _calculateCorrelation(weeklyData);
    String insightText;

    if (correlation < -0.3) {
      insightText =
          "Het lijkt erop dat wanneer je schermtijd daalt, je humeur stijgt. Een goede reden om af en toe een pauze te nemen!";
    } else if (correlation > 0.3) {
      insightText =
          "Interessant, je humeur lijkt deze week beter te zijn op dagen met meer schermtijd. Misschien had je leuke sociale interacties?";
    } else {
      insightText =
          "Je schermtijd en humeur lijken deze week niet sterk verbonden. Blijf je bewust van je gewoontes.";
    }

    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      decoration: BoxDecoration(
        color: AppDesignSystem.primaryBlue.withOpacity(0.05),
        borderRadius: AppDesignSystem.borderRadiusMedium,
        border: Border.all(color: AppDesignSystem.primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppDesignSystem.primaryBlue, size: 28),
          const SizedBox(width: AppDesignSystem.space12),
          Expanded(
            child: Text(
              insightText,
              style: AppDesignSystem.body2
                  .copyWith(color: AppDesignSystem.neutral700, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getScreenTimeBars(
      BuildContext context, Map<DateTime, Duration> weeklyData) {
    return List.generate(7, (index) {
      final dayToFind = DateTime.now().subtract(Duration(days: 6 - index));
      DateTime? dateKey;
      for (var key in weeklyData.keys) {
        if (key.year == dayToFind.year &&
            key.month == dayToFind.month &&
            key.day == dayToFind.day) {
          dateKey = key;
          break;
        }
      }

      final screenTimeHours = (weeklyData[dateKey]?.inMinutes ?? 0) / 60.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: screenTimeHours,
            color: AppDesignSystem.neutral300,
            width: 12,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        ],
      );
    });
  }

  double _calculateCorrelation(Map<DateTime, Duration> weeklyData) {
    final dailyMoods = <DateTime, double>{};
    for (var entry in entries) {
      final day = DateTime(
          entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      dailyMoods[day] = entry.moodValue.toDouble();
    }

    final commonDays =
        weeklyData.keys.where((d) => dailyMoods.containsKey(d)).toList();

    if (commonDays.length < 2) return 0.0;

    final x =
        commonDays.map((day) => weeklyData[day]!.inMinutes.toDouble()).toList();
    final y = commonDays.map((day) => dailyMoods[day]!).toList();

    final n = commonDays.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumX2 = x.map((v) => v * v).reduce((a, b) => a + b);
    final sumY2 = y.map((v) => v * v).reduce((a, b) => a + b);

    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);

    final numerator = n * sumXY - sumX * sumY;
    final denominator =
        sqrt((n * sumX2 - pow(sumX, 2)) * (n * sumY2 - pow(sumY, 2)));

    return denominator == 0 ? 0.0 : numerator / denominator;
  }

  Widget _leftTitleWidgets(String emoji) {
    return Text(emoji, style: const TextStyle(fontSize: 16));
  }

  List<FlSpot> _getMoodSpots() {
    final dailyAverages = <int, List<int>>{};

    // Initialize with empty lists for all days of the week
    for (int i = 0; i < 7; i++) {
      dailyAverages[i] = [];
    }

    for (var entry in entries) {
      // Consider only entries from the last 7 days
      if (DateTime.now().difference(entry.createdAt).inDays < 7) {
        final dayOfWeek = entry.createdAt.weekday - 1; // Monday is 0
        dailyAverages[dayOfWeek]!.add(entry.moodValue);
      }
    }

    return List.generate(7, (index) {
      final dayEntries = dailyAverages[index];
      if (dayEntries == null || dayEntries.isEmpty) {
        return FlSpot.nullSpot;
      }
      final averageMood =
          dayEntries.reduce((a, b) => a + b) / dayEntries.length;
      return FlSpot(index.toDouble(), averageMood);
    }).toList();
  }
}

extension MathExtension on double {
  double sqrt() => this > 0 ? pow(this, 0.5) as double : 0;
}
