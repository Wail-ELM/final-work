import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/empty_state_widget.dart';

class AppUsageChart extends StatefulWidget {
  final Map<String, Duration> appUsageData;
  final int limit;

  const AppUsageChart({
    super.key,
    required this.appUsageData,
    this.limit = 5,
  });

  @override
  State<AppUsageChart> createState() => _AppUsageChartState();
}

class _AppUsageChartState extends State<AppUsageChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Common package name substrings mapped to user-friendly app names
  static const Map<String, String> _knownAppNames = {
    // Social & messaging
    'zhiliaoapp': 'TikTok', // com.zhiliaoapp.musically
    'musically': 'TikTok',
    'tiktok': 'TikTok',
    'instagram': 'Instagram',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'snapchat': 'Snapchat',
    'telegram': 'Telegram',
    'signal': 'Signal',
    'discord': 'Discord',
    'twitter': 'X', // com.twitter.android → X

    // Video & music
    'youtube': 'YouTube',
    'netflix': 'Netflix',
    'avod': 'Prime Video', // com.amazon.avod.thirdpartyclient
    'primevideo': 'Prime Video',
    'spotify': 'Spotify',

    // Browsers & tools
    'chrome': 'Chrome',

    // Productivity & comms
    'gmail': 'Gmail',
    'outlook': 'Outlook',
    'teams': 'Microsoft Teams',
    'meet': 'Google Meet',
    'zoom': 'Zoom',

    // AI
    'openai': 'ChatGPT',
  };

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
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant AppUsageChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appUsageData != oldWidget.appUsageData) {
      _controller.forward(from: 0);
  }
    }
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedApps = widget.appUsageData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topApps = sortedApps.take(widget.limit).toList();

    if (topApps.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.hourglass_empty_outlined,
        title: 'Geen app-gebruiksdata',
        message: 'Gebruik de app een paar dagen om hier je top apps te zien.',
      );
    }

    final maxY =
        topApps.isNotEmpty ? topApps.first.value.inMinutes.toDouble() : 1.0;

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
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final app = topApps[groupIndex];
                        return BarTooltipItem(
                          '${_getAppName(app.key)}\n${_formatDuration(app.value)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent && response?.spot != null) {
                        _showAppDetails(context,
                            topApps[response!.spot!.touchedBarGroupIndex]);
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= topApps.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _getAppName(topApps[value.toInt()].key),
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
                          if (value.toInt() % (maxY / 5).ceil() == 0 ||
                              value == maxY) {
                            return Text(
                              '${value.toInt()}m',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox();
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
                  barGroups: topApps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final app = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY:
                              app.value.inMinutes.toDouble() * _animation.value,
                          color: _getAppColor(index).withOpacity(0.8),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
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
            alignment: WrapAlignment.center,
            children: topApps.asMap().entries.map((entry) {
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
              'Gebruikerstijd',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _getAppName(String packageName) {
    if (packageName.isEmpty) return 'Onbekend';
    final lower = packageName.toLowerCase();

    // Try known mappings by substring
    for (final entry in _knownAppNames.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    // Heuristic fallback: last (or second-last) segment, cleaned and title-cased
    final parts = packageName.split('.');
    String guess = parts.isNotEmpty ? parts.last : packageName;
    if (guess.isEmpty || guess == 'app' || guess == 'android' || guess == 'musically') {
      if (parts.length >= 2) {
        guess = parts[parts.length - 2];
      }
    }
    guess = guess.replaceAll('_', ' ').trim();
    if (guess.isEmpty) return packageName;
    return guess.substring(0, 1).toUpperCase() + guess.substring(1);
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
