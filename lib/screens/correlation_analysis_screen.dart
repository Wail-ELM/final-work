import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/design_system.dart';
import '../providers/mood_provider.dart';
import '../providers/user_objective_provider.dart';
import '../services/correlation_service.dart';

class CorrelationAnalysisScreen extends ConsumerWidget {
  const CorrelationAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodStats = ref.watch(moodStatsProvider);
    final screenTimeAsync = ref.watch(weeklyScreenTimeDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse de Corrélation'),
        elevation: 0,
      ),
      body: screenTimeAsync.when(
        data: (screenTimeData) {
          // Créer un service de corrélation pour analyser les données
          final correlationService = CorrelationService();
          final correlationData = correlationService.analyzeCorrelation(
            moodStats.recentEntries,
            screenTimeData,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildCorrelationChart(context, correlationData),
                _buildInsights(context, correlationData),
                _buildRecommendations(context, correlationData),
                const SizedBox(height: AppDesignSystem.space24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur lors du chargement des données: $error'),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impact de vos habitudes numériques',
            style: AppDesignSystem.heading2.copyWith(
              color: AppDesignSystem.primaryBlue,
            ),
          ),
          const SizedBox(height: AppDesignSystem.space8),
          Text(
            'Découvrez comment votre temps d\'écran influence votre bien-être et votre humeur. Ces analyses sont basées sur vos données personnelles.',
            style: AppDesignSystem.body1.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationChart(
      BuildContext context, Map<String, dynamic> correlationData) {
    final correlation = correlationData['correlation'] as double;
    final moodData = correlationData['moodData'] as List<FlSpot>;
    final screenTimeData = correlationData['screenTimeData'] as List<FlSpot>;
    final trendlineData = correlationData['trendlineData'] as List<FlSpot>;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDesignSystem.space24),
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
                child: Icon(
                  Icons.insights,
                  color: AppDesignSystem.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDesignSystem.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corrélation Temps d\'écran / Humeur',
                      style: AppDesignSystem.heading3,
                    ),
                    const SizedBox(height: AppDesignSystem.space4),
                    _buildCorrelationStrength(context, correlation),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space24),
          SizedBox(
            height: 300,
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
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}h',
                              style: style,
                            ),
                          );
                        }),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink();

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                minX: 0,
                maxX: 8,
                minY: 1,
                maxY: 5,
                lineBarsData: [
                  // Points pour chaque jour
                  LineChartBarData(
                    spots: screenTimeData,
                    isCurved: false,
                    color: Colors.transparent,
                    barWidth: 0,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: AppDesignSystem.primaryBlue.withOpacity(0.7),
                          strokeWidth: 0,
                        );
                      },
                    ),
                  ),
                  // Ligne de tendance
                  LineChartBarData(
                    spots: trendlineData,
                    isCurved: false,
                    color: correlation < 0
                        ? AppDesignSystem.error
                        : AppDesignSystem.success,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (correlation < 0
                              ? AppDesignSystem.error
                              : AppDesignSystem.success)
                          .withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDesignSystem.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppDesignSystem.primaryBlue,
                ),
              ),
              const SizedBox(width: AppDesignSystem.space8),
              const Text('Votre temps d\'écran et humeur'),
              const SizedBox(width: AppDesignSystem.space16),
              Container(
                width: 12,
                height: 3,
                decoration: BoxDecoration(
                  color: correlation < 0
                      ? AppDesignSystem.error
                      : AppDesignSystem.success,
                ),
              ),
              const SizedBox(width: AppDesignSystem.space8),
              Text(
                'Ligne de tendance',
                style: TextStyle(
                  color: correlation < 0
                      ? AppDesignSystem.error
                      : AppDesignSystem.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationStrength(BuildContext context, double correlation) {
    final absCorrelation = correlation.abs();
    String strength;
    Color color;

    if (absCorrelation >= 0.7) {
      strength = 'Forte';
      color = correlation < 0 ? AppDesignSystem.error : AppDesignSystem.success;
    } else if (absCorrelation >= 0.5) {
      strength = 'Modérée';
      color = correlation < 0 ? Colors.orange : Colors.lightGreen;
    } else if (absCorrelation >= 0.3) {
      strength = 'Faible';
      color = correlation < 0 ? Colors.deepOrange[300]! : Colors.green[300]!;
    } else {
      strength = 'Très faible';
      color = Colors.grey;
    }

    return Row(
      children: [
        Text(
          'Corrélation ${correlation < 0 ? "négative" : "positive"} ',
          style: AppDesignSystem.body2,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
          ),
          child: Text(
            strength,
            style: AppDesignSystem.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsights(
      BuildContext context, Map<String, dynamic> correlationData) {
    final correlation = correlationData['correlation'] as double;
    final significantApps =
        correlationData['significantApps'] as List<Map<String, dynamic>>;
    final optimalScreenTime = correlationData['optimalScreenTime'] as int;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDesignSystem.space24,
        AppDesignSystem.space24,
        AppDesignSystem.space24,
        0,
      ),
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos Insights Personnalisés',
            style: AppDesignSystem.heading3,
          ),
          const SizedBox(height: AppDesignSystem.space16),
          _buildInsightCard(
            context,
            title: 'Impact sur votre humeur',
            icon: Icons.psychology,
            content: correlation < -0.3
                ? 'Nos analyses montrent que plus vous utilisez vos écrans, plus votre humeur tend à diminuer.'
                : correlation > 0.3
                    ? 'Fait intéressant: votre utilisation des écrans semble associée à une meilleure humeur, ce qui est inhabituel. Cela pourrait être lié à l\'utilisation d\'applications qui vous apportent du bien-être.'
                    : 'Votre humeur ne semble pas significativement influencée par votre temps d\'écran total. Cependant, certaines applications spécifiques pourraient avoir un impact plus important.',
          ),
          const SizedBox(height: AppDesignSystem.space16),
          _buildInsightCard(
            context,
            title: 'Temps d\'écran optimal',
            icon: Icons.hourglass_bottom,
            content:
                'Selon vos données, votre humeur semble optimale lorsque vous utilisez vos écrans environ $optimalScreenTime heures par jour. Au-delà, nous observons une tendance à la baisse.',
          ),
          const SizedBox(height: AppDesignSystem.space16),
          _buildInsightCard(
            context,
            title: 'Applications impactantes',
            icon: Icons.apps,
            content: significantApps.isEmpty
                ? 'Nous n\'avons pas encore identifié d\'applications ayant un impact significatif sur votre humeur. Continuez à enregistrer vos données pour des analyses plus précises.'
                : 'Nous avons identifié ces applications comme ayant un impact important sur votre humeur:',
            extraWidget: significantApps.isEmpty
                ? null
                : Column(
                    children: significantApps
                        .map((app) => _buildAppImpactItem(context, app))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    Widget? extraWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: AppDesignSystem.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDesignSystem.space12),
              Expanded(
                child: Text(
                  title,
                  style: AppDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space12),
          Text(
            content,
            style: AppDesignSystem.body2,
          ),
          if (extraWidget != null) ...[
            const SizedBox(height: AppDesignSystem.space12),
            extraWidget,
          ],
        ],
      ),
    );
  }

  Widget _buildAppImpactItem(BuildContext context, Map<String, dynamic> app) {
    final String name = app['name'] as String;
    final double impact = app['impact'] as double;
    final bool isPositive = app['isPositive'] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignSystem.space8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
            ),
            child: const Icon(
              Icons.android,
              size: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: AppDesignSystem.space12),
          Expanded(
            child: Text(
              name,
              style: AppDesignSystem.body2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignSystem.space8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color:
                  (isPositive ? AppDesignSystem.success : AppDesignSystem.error)
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive
                      ? AppDesignSystem.success
                      : AppDesignSystem.error,
                ),
                const SizedBox(width: 2),
                Text(
                  '${(impact * 100).round()}%',
                  style: AppDesignSystem.caption.copyWith(
                    color: isPositive
                        ? AppDesignSystem.success
                        : AppDesignSystem.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(
      BuildContext context, Map<String, dynamic> correlationData) {
    final recommendations = correlationData['recommendations'] as List<String>;

    return Container(
      margin: const EdgeInsets.all(AppDesignSystem.space24),
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommandations Basées sur les Données',
            style: AppDesignSystem.heading3,
          ),
          const SizedBox(height: AppDesignSystem.space16),
          ...recommendations.map((recommendation) =>
              _buildRecommendationItem(context, recommendation)),
          const SizedBox(height: AppDesignSystem.space16),
          OutlinedButton(
            onPressed: () {
              // Naviguer vers l'écran des challenges
              Navigator.of(context).pushNamed('/challenges');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppDesignSystem.space12,
                horizontal: AppDesignSystem.space16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.radiusMedium),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flag_outlined),
                const SizedBox(width: AppDesignSystem.space8),
                const Text('Voir les défis associés'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(BuildContext context, String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignSystem.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppDesignSystem.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: AppDesignSystem.space12),
          Expanded(
            child: Text(
              recommendation,
              style: AppDesignSystem.body2,
            ),
          ),
        ],
      ),
    );
  }
}
