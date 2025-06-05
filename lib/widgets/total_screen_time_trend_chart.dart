import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class TotalScreenTimeTrendChart extends StatelessWidget {
  final Map<DateTime, Duration> dailyScreenTimeData;
  final String periodType; // 'week', 'month', 'year' - for label formatting

  const TotalScreenTimeTrendChart({
    super.key,
    required this.dailyScreenTimeData,
    required this.periodType,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyScreenTimeData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Geen gegevens over schermtijd beschikbaar voor deze periode.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sortedEntries = dailyScreenTimeData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      spots.add(
          FlSpot(i.toDouble(), entry.value.inMinutes / 60.0)); // Y as hours
    }

    double minY = 0;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (maxY < 5) maxY = 5; // Ensure a minimum height for the Y axis

    return AspectRatio(
      aspectRatio: 1.8, // Adjust as needed
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 24.0, bottom: 12.0),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: maxY > 10 ? (maxY / 5).roundToDouble() : 1,
              verticalInterval: _getVerticalInterval(sortedEntries.length),
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
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval:
                      _getBottomTitleInterval(sortedEntries.length, periodType),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < sortedEntries.length) {
                      final date = sortedEntries[index].key;
                      String text;
                      if (periodType == 'week') {
                        text = DateFormat('E', 'nl_NL').format(date); // Ma, Di
                      } else if (periodType == 'month') {
                        text = DateFormat('d', 'nl_NL').format(date); // 1, 2, 3
                        if (sortedEntries.length > 15 &&
                            index % 2 != 0 &&
                            index != sortedEntries.length - 1 &&
                            index != 0) {
                          return const SizedBox
                              .shrink(); // Show fewer labels for month
                        }
                      } else {
                        // year
                        text =
                            DateFormat('MMM', 'nl_NL').format(date); // Jan, Feb
                        // For year, we might want to show fewer labels if data is daily
                        // This assumes data might be aggregated per month for 'year' view in future
                        // For now, if daily, it will be very crowded.
                        // Consider passing aggregated data for 'year'
                        if (index %
                                    (sortedEntries.length / 6)
                                        .round()
                                        .clamp(1, 100) !=
                                0 &&
                            index != sortedEntries.length - 1 &&
                            index != 0) {
                          return const SizedBox.shrink();
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(text, style: const TextStyle(fontSize: 10)),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max || value == meta.min)
                      return const Text('');
                    return Text('${value.toInt()}u',
                        style: const TextStyle(fontSize: 10));
                  },
                  interval:
                      maxY > 10 ? (maxY / 5).roundToDouble().clamp(1, maxY) : 1,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom:
                    BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
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
                  show: sortedEntries.length <=
                      30, // Show dots for smaller datasets
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      strokeColor: Theme.of(context).cardColor,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot spot) {
                    final entry = sortedEntries[spot.x.toInt()];
                    final date = entry.key;
                    final duration = entry.value;
                    final hours = duration.inHours;
                    final minutes = duration.inMinutes % 60;

                    final String dateText =
                        DateFormat('EEE d MMM', 'nl_NL').format(date);
                    final String durationText = '${hours}u ${minutes}m';

                    return LineTooltipItem(
                      '$dateText\n$durationText',
                      TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.left,
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to determine vertical line interval for grid
  double _getVerticalInterval(int dataLength) {
    if (dataLength <= 7) return 1; // Daily for a week
    if (dataLength <= 31)
      return (dataLength / 7)
          .roundToDouble()
          .clamp(1, 5); // ~Weekly for a month
    return (dataLength / 12)
        .roundToDouble()
        .clamp(1, 10); // ~Monthly for a year or more
  }

  // Helper to determine bottom title interval
  double _getBottomTitleInterval(int dataLength, String periodType) {
    if (periodType == 'week') return 1;
    if (periodType == 'month') {
      if (dataLength <= 10) return 1;
      if (dataLength <= 20) return 2;
      return (dataLength / 7).roundToDouble().clamp(1, 5); // approx 4-5 labels
    }
    // For 'year', this logic might need refinement based on how data is provided (daily vs aggregated monthly)
    // Currently aims for about 6-12 labels if data is daily.
    return (dataLength / (dataLength > 100 ? 12 : 6))
        .roundToDouble()
        .clamp(1, 30);
  }
}
