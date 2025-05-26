import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_usage_service.dart';

class AppUsageChart extends StatefulWidget {
  final DateTime date;
  final int limit;

  const AppUsageChart({
    super.key,
    required this.date,
    this.limit = 5,
  });

  @override
  State<AppUsageChart> createState() => _AppUsageChartState();
}

class _AppUsageChartState extends State<AppUsageChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<MapEntry<String, Duration>>? _cachedApps;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MapEntry<String, Duration>>>(
      future:
          AppUsageService().getTopAppsForDate(widget.date, limit: widget.limit),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Fout bij laden: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final apps = snapshot.data ?? [];
        if (apps.isEmpty) {
          return const Center(
            child: Text('Geen gegevens beschikbaar'),
          );
        }

        // Cache the apps data for smooth animations
        _cachedApps = apps;

        return Column(
          children: [
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: apps.first.value.inMinutes.toDouble(),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final app = apps[groupIndex];
                            return BarTooltipItem(
                              '${app.key}\n${_formatDuration(app.value)}',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                        handleBuiltInTouches: true,
                        touchCallback: (event, response) {
                          if (event is FlTapUpEvent && response?.spot != null) {
                            _showAppDetails(context,
                                apps[response!.spot!.touchedBarGroupIndex]);
                          }
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= apps.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _getAppName(apps[value.toInt()].key),
                                  style: const TextStyle(
                                    fontSize: 10,
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
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}m',
                                style: const TextStyle(fontSize: 10),
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
                      gridData: const FlGridData(show: false),
                      barGroups: apps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final app = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: app.value.inMinutes.toDouble() *
                                  _animation.value,
                              color: _getAppColor(index).withOpacity(0.8),
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: apps.first.value.inMinutes.toDouble(),
                                color: Colors.grey.withOpacity(0.1),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _animation.value,
              duration: const Duration(milliseconds: 500),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: apps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final app = entry.value;
                  return InkWell(
                    onTap: () => _showAppDetails(context, app),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getAppColor(index),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_getAppName(app.key)} (${_formatDuration(app.value)})',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAppDetails(BuildContext context, MapEntry<String, Duration> app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              _getAppName(app.key),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(app.value),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gebruikstijd vandaag',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _getAppName(String packageName) {
    // Vereenvoudigde naam van de app
    final parts = packageName.split('.');
    if (parts.length > 2) {
      return parts[parts.length - 2];
    }
    return packageName;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}u ${minutes}m';
    }
    return '${minutes}m';
  }

  Color _getAppColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
