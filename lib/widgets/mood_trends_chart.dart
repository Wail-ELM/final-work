import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';

class MoodTrendsChart extends StatelessWidget {
  final List<MoodEntry> entries;
  final String period;

  const MoodTrendsChart({
    super.key,
    required this.entries,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final spots = _getMoodSpots();
    final minY = spots.isEmpty
        ? 0.0
        : spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.isEmpty
        ? 5.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendensen over $period',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (entries.isEmpty)
              const Center(
                child: Text('Geen gegevens beschikbaar'),
              )
            else
              AspectRatio(
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
                          interval: _getInterval(),
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _getDateLabel(value.toInt()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
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
                    maxX: _getMaxX().toDouble(),
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
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
              ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getMoodSpots() {
    final now = DateTime.now();
    DateTime startDate;
    int interval;

    switch (period) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        interval = 1;
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        interval = 3;
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        interval = 30;
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
        interval = 1;
    }

    final spots = <FlSpot>[];
    var x = 0.0;

    for (var date = startDate;
        date.isBefore(now.add(const Duration(days: 1)));
        date = date.add(Duration(days: interval))) {
      final dayEntries = entries
          .where((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day)
          .toList();

      if (dayEntries.isNotEmpty) {
        final average = dayEntries.map((e) => e.value).reduce((a, b) => a + b) /
            dayEntries.length;
        spots.add(FlSpot(x, average));
      }
      x += 1;
    }

    return spots;
  }

  double _getInterval() {
    switch (period) {
      case 'week':
        return 1;
      case 'month':
        return 3;
      case 'year':
        return 30;
      default:
        return 1;
    }
  }

  double _getMaxX() {
    switch (period) {
      case 'week':
        return 7;
      case 'month':
        return 10;
      case 'year':
        return 12;
      default:
        return 7;
    }
  }

  String _getDateLabel(int index) {
    final now = DateTime.now();
    DateTime date;

    switch (period) {
      case 'week':
        date = now.subtract(Duration(days: 7 - index));
        return '${date.day}/${date.month}';
      case 'month':
        date = now.subtract(Duration(days: 30 - (index * 3)));
        return '${date.day}/${date.month}';
      case 'year':
        date = now.subtract(Duration(days: 365 - (index * 30)));
        return '${date.day}/${date.month}';
      default:
        date = now.subtract(Duration(days: 7 - index));
        return '${date.day}/${date.month}';
    }
  }
}
