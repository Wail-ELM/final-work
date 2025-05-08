import 'package:flutter/material.dart';
import '../widgets/progress_circle.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const dailyPercent = 0.75;
    const weeklyPercent = 0.60;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistieken')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Dagelijks doel', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ProgressCircle(percent: dailyPercent, label: 'vandaag'),
            const SizedBox(height: 32),
            Text('Wekelijkse doel', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ProgressCircle(percent: weeklyPercent, label: 'deze week'),
          ],
        ),
      ),
    );
  }
}
