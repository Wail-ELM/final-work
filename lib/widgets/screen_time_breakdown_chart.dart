import 'package:flutter/material.dart';

class ScreenTimeBreakdownChart extends StatelessWidget {
  final Map<String, Duration> appBreakdown;
  final Duration totalTime;

  const ScreenTimeBreakdownChart({
    super.key,
    required this.appBreakdown,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final sortedApps = _getSortedApps();
    final maxHours = _getMaxHours();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verdeling per app',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (appBreakdown.isEmpty)
              const Center(
                child: Text('Geen gegevens beschikbaar'),
              )
            else
              Column(
                children: [
                  ...List.generate(
                    sortedApps.length,
                    (index) => _buildAppBar(
                      context,
                      sortedApps[index],
                      appBreakdown[sortedApps[index]]!,
                      totalTime,
                      maxHours,
                      index,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLegend(context, maxHours),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<String> _getSortedApps() {
    final apps = appBreakdown.keys.toList();
    apps.sort((a, b) => appBreakdown[b]!.compareTo(appBreakdown[a]!));
    return apps;
  }

  double _getMaxHours() {
    if (appBreakdown.isEmpty) return 24.0;
    return appBreakdown.values
        .map((duration) => duration.inHours.toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  Widget _buildAppBar(
    BuildContext context,
    String appName,
    Duration duration,
    Duration totalTime,
    double maxHours,
    int index,
  ) {
    final percentage = totalTime.inSeconds > 0
        ? duration.inSeconds / totalTime.inSeconds
        : 0.0;
    final hours = duration.inHours.toDouble();
    final minutes = duration.inMinutes % 60;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getAppDisplayName(appName),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${hours.toInt()}u ${minutes}m',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getAppColor(index),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, double maxHours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '0u',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '${maxHours.toInt()}u',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getAppDisplayName(String appName) {
    // TODO: Implémenter une meilleure gestion des noms d'applications
    switch (appName.toLowerCase()) {
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'tiktok':
        return 'TikTok';
      case 'whatsapp':
        return 'WhatsApp';
      case 'youtube':
        return 'YouTube';
      case 'twitter':
        return 'Twitter';
      case 'snapchat':
        return 'Snapchat';
      default:
        return appName;
    }
  }

  Color _getAppColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
