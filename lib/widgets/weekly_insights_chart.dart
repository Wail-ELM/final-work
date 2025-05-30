import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';

class WeeklyInsightsChart extends StatelessWidget {
  final List<MoodEntry> entries;
  final Duration screenTime;

  const WeeklyInsightsChart({
    super.key,
    required this.entries,
    required this.screenTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMoodChart(context),
        const SizedBox(height: 24),
        _buildScreenTimeChart(context),
      ],
    );
  }

  Widget _buildMoodChart(BuildContext context) {
    final spots = _getMoodSpots();
    final minY = spots.isEmpty
        ? 0.0
        : spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.isEmpty
        ? 5.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
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
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const days = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];
                  if (value >= 0 && value < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: minY - 0.5,
          maxY: maxY + 0.5,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.toStringAsFixed(1),
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTimeChart(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 24,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()} uur',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];
                  if (value >= 0 && value < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}u',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: _getScreenTimeBars(context),
        ),
      ),
    );
  }

  List<FlSpot> _getMoodSpots() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final dayEntries = entries
          .where((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day)
          .toList();

      if (dayEntries.isEmpty) {
        return FlSpot(index.toDouble(), 0);
      }

      final average = dayEntries.map((e) => e.value).reduce((a, b) => a + b) /
          dayEntries.length;

      return FlSpot(index.toDouble(), average);
    });
  }

  List<BarChartGroupData> _getScreenTimeBars(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: _getScreenTimeForDate(date),
            color: isToday
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withOpacity(0.6),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 24,
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }

  double _getScreenTimeForDate(DateTime date) {
    // Pour l'instant, on utilise des données de test
    // TODO: Remplacer par les données réelles du ScreenTimeService
    if (date.isAfter(DateTime.now())) return 0;

    // Simuler des données réalistes (entre 2 et 7 heures)
    final random = (date.day * 7 + date.month * 13) % 24;
    return (random % 6 + 2).toDouble();
  }
}
