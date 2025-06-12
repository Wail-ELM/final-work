import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../models/assessment_model.dart';
import 'package:fl_chart/fl_chart.dart';

class AssessmentResultScreen extends ConsumerWidget {
  final UserAssessment assessment;

  const AssessmentResultScreen({Key? key, required this.assessment})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uw Digitale Profiel'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildResultCard(context),
            _buildScoreChart(context),
            _buildRecommendations(context),
            _buildActionPlan(context),
            const SizedBox(height: AppDesignSystem.space32),
          ],
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
            'Uw Analyse',
            style: AppDesignSystem.heading1.copyWith(
              color: AppDesignSystem.primaryGreen,
            ),
          ),
          const SizedBox(height: AppDesignSystem.space8),
          Text(
            'Op basis van uw antwoorden hebben we een gepersonaliseerd digitaal profiel voor u opgesteld om u te helpen uw digitale balans te verbeteren.',
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

  Widget _buildResultCard(BuildContext context) {
    final result = assessment.result;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDesignSystem.space24),
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      decoration: BoxDecoration(
        gradient: AppDesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                padding: const EdgeInsets.all(AppDesignSystem.space12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
                child: _getResultIcon(result),
              ),
              const SizedBox(width: AppDesignSystem.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uw profiel',
                      style: AppDesignSystem.body2.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: AppDesignSystem.space4),
                    Text(
                      result.title,
                      style: AppDesignSystem.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space20),
          Text(
            result.description,
            style: AppDesignSystem.body1.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChart(BuildContext context) {
    final scores = assessment.scores;
    final List<ScoreCategory> categories = [
      ScoreCategory(
        name: 'Schermtijd',
        score: scores['screenTime'] ?? 0,
        color: AppDesignSystem.secondaryBlue,
        icon: Icons.phone_android,
      ),
      ScoreCategory(
        name: 'Mindfulness',
        score: scores['mindfulness'] ?? 0,
        color: AppDesignSystem.success,
        icon: Icons.spa,
      ),
      ScoreCategory(
        name: 'Welzijn',
        score: scores['wellBeing'] ?? 0,
        color: Colors.orange,
        icon: Icons.sentiment_satisfied_alt,
      ),
      ScoreCategory(
        name: 'Productiviteit',
        score: scores['productivity'] ?? 0,
        color: Colors.purple,
        icon: Icons.trending_up,
      ),
    ];

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
            'Uw scores per categorie',
            style: AppDesignSystem.heading3,
          ),
          const SizedBox(height: AppDesignSystem.space24),
          SizedBox(
            height: 200,
            child: RadarChart(
              RadarChartData(
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                tickBorderData: const BorderSide(color: Colors.transparent),
                gridBorderData: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                tickCount: 5,
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 10,
                ),
                titleTextStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
                getTitle: (index, angle) => RadarChartTitle(
                  text: categories[index % categories.length].name,
                ),
                titlePositionPercentageOffset: 0.2,
                dataSets: [
                  RadarDataSet(
                    fillColor: AppDesignSystem.primaryGreen.withOpacity(0.2),
                    borderColor: AppDesignSystem.primaryGreen,
                    borderWidth: 2,
                    entryRadius: 5,
                    dataEntries: [
                      for (var category in categories)
                        RadarEntry(value: category.score / 100),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDesignSystem.space16),
          ...categories.map((category) => _buildScoreItem(context, category)),
        ],
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, ScoreCategory category) {
    final score = category.score;
    String evaluation;
    Color evaluationColor;

    if (score >= 80) {
      evaluation = 'Uitstekend';
      evaluationColor = AppDesignSystem.success;
    } else if (score >= 60) {
      evaluation = 'Goed';
      evaluationColor = Colors.green[300]!;
    } else if (score >= 40) {
      evaluation = 'Gemiddeld';
      evaluationColor = Colors.orange;
    } else if (score >= 20) {
      evaluation = 'Te verbeteren';
      evaluationColor = Colors.deepOrange;
    } else {
      evaluation = 'Kritiek';
      evaluationColor = AppDesignSystem.error;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignSystem.space12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 16,
            ),
          ),
          const SizedBox(width: AppDesignSystem.space12),
          Expanded(
            child: Text(
              category.name,
              style: AppDesignSystem.body1,
            ),
          ),
          Text(
            '${score.round()}/100',
            style: AppDesignSystem.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppDesignSystem.space8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignSystem.space8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: evaluationColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
            ),
            child: Text(
              evaluation,
              style: AppDesignSystem.caption.copyWith(
                color: evaluationColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final recommendedChallenges = assessment.result.recommendedChallenges;

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
          Text(
            'Gepersonaliseerde Aanbevelingen',
            style: AppDesignSystem.heading3,
          ),
          const SizedBox(height: AppDesignSystem.space16),
          Text(
            'Op basis van uw profiel zijn dit de uitdagingen die u het meest zullen helpen uw digitale balans te verbeteren:',
            style: AppDesignSystem.body2,
          ),
          const SizedBox(height: AppDesignSystem.space16),
          ...recommendedChallenges
              .map((challengeId) => _buildChallengeItem(context, challengeId)),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(BuildContext context, String challengeId) {
    // Hier, on pourrait idéalement chercher les détails du défi dans une base de données
    // Pour l'instant, on utilise des valeurs par défaut basées sur l'ID
    String title;
    String description;
    IconData icon;

    if (challengeId.contains('detox')) {
      title = 'Digitale Detox';
      description = 'Neem elke dag een pauze van 30 minuten zonder schermen';
      icon = Icons.phonelink_off_outlined;
    } else if (challengeId.contains('notification')) {
      title = 'Notificatie Opschoning';
      description = 'Schakel niet-essentiële meldingen uit';
      icon = Icons.notifications_off_outlined;
    } else if (challengeId.contains('morning')) {
      title = 'Ochtenden Zonder Telefoon';
      description =
          'Controleer uw telefoon niet gedurende het eerste uur na het wakker worden';
      icon = Icons.wb_sunny_outlined;
    } else if (challengeId.contains('focus')) {
      title = 'Focus Sessies';
      description =
          'Werk in focusmodus (zonder afleiding) gedurende 25 minuten';
      icon = Icons.timer_outlined;
    } else if (challengeId.contains('mindful')) {
      title = 'Bewust Gebruik';
      description =
          'Neem voor elk gebruik 10 seconden de tijd om te ademen en uw intentie te verduidelijken';
      icon = Icons.spa_outlined;
    } else {
      title = 'Gepersonaliseerde Uitdaging';
      description = 'Een uitdaging aangepast aan uw digitale profiel';
      icon = Icons.emoji_events_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDesignSystem.space16),
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDesignSystem.space8),
            decoration: BoxDecoration(
              color: AppDesignSystem.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppDesignSystem.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDesignSystem.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDesignSystem.space4),
                Text(
                  description,
                  style: AppDesignSystem.body2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlan(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDesignSystem.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Uw Actieplan',
            style: AppDesignSystem.heading3,
          ),
          const SizedBox(height: AppDesignSystem.space16),
          ElevatedButton.icon(
            onPressed: () {
              // Naviguer vers l'écran des défis
              Navigator.of(context).pushReplacementNamed('/challenges');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppDesignSystem.space16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.radiusMedium),
              ),
            ),
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Start de Aanbevolen Uitdagingen'),
          ),
          const SizedBox(height: AppDesignSystem.space16),
          OutlinedButton.icon(
            onPressed: () {
              // Naviguer vers le tableau de bord
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppDesignSystem.space16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.radiusMedium),
              ),
            ),
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('Ga naar het Dashboard'),
          ),
        ],
      ),
    );
  }

  Icon _getResultIcon(AssessmentResult result) {
    switch (result) {
      case AssessmentResult.screenTimeImbalance:
        return const Icon(Icons.smartphone, color: Colors.white, size: 24);
      case AssessmentResult.attentionDivided:
        return const Icon(Icons.hub, color: Colors.white, size: 24);
      case AssessmentResult.digitalStress:
        return const Icon(Icons.mood_bad, color: Colors.white, size: 24);
      case AssessmentResult.productivityDisrupted:
        return const Icon(Icons.trending_down, color: Colors.white, size: 24);
      case AssessmentResult.balanced:
        return const Icon(Icons.balance, color: Colors.white, size: 24);
    }
  }
}

class ScoreCategory {
  final String name;
  final double score;
  final Color color;
  final IconData icon;

  const ScoreCategory({
    required this.name,
    required this.score,
    required this.color,
    required this.icon,
  });
}
