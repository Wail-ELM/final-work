import 'package:flutter/material.dart';
import '../../core/design_system.dart';

class OnboardingScienceScreen extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingScienceScreen({Key? key, required this.onNext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDesignSystem.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppDesignSystem.space32),
                _buildScienceCard(
                  context,
                  title: 'Impact des écrans sur le bien-être mental',
                  icon: Icons.psychology,
                  content:
                      'Des recherches publiées dans le Journal of Behavioral Addictions montrent qu\'une utilisation excessive des smartphones est associée à une augmentation de 30% de l\'anxiété et une diminution de 25% de la qualité du sommeil.',
                  source: 'Journal of Behavioral Addictions, 2022',
                ),
                const SizedBox(height: AppDesignSystem.space24),
                _buildScienceCard(
                  context,
                  title: 'Le phénomène de "doom scrolling"',
                  icon: Icons.screen_rotation,
                  content:
                      'L\'Université de Stanford a démontré que le "doom scrolling" (défilement sans fin) déclenche les mêmes circuits de récompense dans le cerveau que ceux activés par certaines substances addictives.',
                  source: 'Stanford University, 2023',
                ),
                const SizedBox(height: AppDesignSystem.space24),
                _buildScienceCard(
                  context,
                  title: 'Temps d\'écran et productivité',
                  icon: Icons.access_time,
                  content:
                      'Les chercheurs de Harvard Business School ont constaté qu\'une réduction de 20% du temps d\'écran non essentiel peut augmenter la productivité quotidienne de jusqu\'à 37%.',
                  source: 'Harvard Business School, 2021',
                ),
                const SizedBox(height: AppDesignSystem.space24),
                _buildScienceCard(
                  context,
                  title: 'Social Balans: notre approche',
                  icon: Icons.balance,
                  content:
                      'Social Balans utilise des méthodes validées scientifiquement pour vous aider à établir une relation saine avec la technologie. Notre système de suivi et d\'analyse est basé sur les principes de la thérapie cognitivo-comportementale et l\'économie comportementale.',
                  source:
                      'En collaboration avec des chercheurs en psychologie numérique',
                ),
                const SizedBox(height: AppDesignSystem.space40),
                _buildActionButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basé sur la Science',
          style: AppDesignSystem.heading1.copyWith(
            color: AppDesignSystem.primaryGreen,
          ),
        ),
        const SizedBox(height: AppDesignSystem.space8),
        Text(
          'Social Balans utilise des approches validées scientifiquement pour améliorer votre bien-être numérique',
          style: AppDesignSystem.body1.copyWith(
            color:
                Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildScienceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    required String source,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space20),
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
                  color: AppDesignSystem.primaryGreen.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: AppDesignSystem.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDesignSystem.space12),
              Expanded(
                child: Text(
                  title,
                  style: AppDesignSystem.heading3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space16),
          Text(
            content,
            style: AppDesignSystem.body2,
          ),
          const SizedBox(height: AppDesignSystem.space12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Source: $source',
              style: AppDesignSystem.caption.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesignSystem.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space32,
            vertical: AppDesignSystem.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Commencer mon parcours',
              style: AppDesignSystem.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppDesignSystem.space8),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}
