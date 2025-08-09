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
                  title: 'Impact van schermgebruik op mentaal welzijn',
                  icon: Icons.psychology,
                  content:
                      'Onderzoek gepubliceerd in het Journal of Behavioral Addictions toont dat overmatig smartphonegebruik samenhangt met 30% meer angst en 25% lagere slaapkwaliteit.',
                  source: 'Journal of Behavioral Addictions, 2022',
                ),
                const SizedBox(height: AppDesignSystem.space24),
                _buildScienceCard(
                  context,
                  title: 'Het fenomeen "doom scrolling"',
                  icon: Icons.screen_rotation,
                  content:
                      'Onderzoek van Stanford toont aan dat "doom scrolling" (eindeloos scrollen) dezelfde beloningscircuits in het brein activeert als bepaalde verslavende stoffen.',
                  source: 'Stanford University, 2023',
                ),
                const SizedBox(height: AppDesignSystem.space24),
                _buildScienceCard(
                  context,
                  title: 'Schermtijd en productiviteit',
                  icon: Icons.access_time,
                  content:
                      'Harvard Business School vond dat 20% minder niet-essentiële schermtijd de dagelijkse productiviteit tot 37% kan verhogen.',
                  source: 'Harvard Business School, 2021',
                ),
                const SizedBox(height: AppDesignSystem.space24),
                _buildScienceCard(
                  context,
                  title: 'Social Balans: onze aanpak',
                  icon: Icons.balance,
                  content:
                      'Social Balans gebruikt wetenschappelijk onderbouwde methodes om je te helpen een gezonde relatie met technologie op te bouwen. Ons volg- en analysesysteem steunt op principes uit cognitieve gedragstherapie en gedrags­economie.',
                  source:
                      'In samenwerking met onderzoekers in digitale psychologie',
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
          'Wetenschappelijk Onderbouwd',
          style: AppDesignSystem.heading1.copyWith(
            color: AppDesignSystem.primaryGreen,
          ),
        ),
        const SizedBox(height: AppDesignSystem.space8),
        Text(
          'Social Balans gebruikt wetenschappelijk gevalideerde aanpakken om jouw digitale welzijn te verbeteren',
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
              'Start mijn traject',
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
