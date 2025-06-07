import 'package:flutter/material.dart';
import '../../core/design_system.dart';
import '../../widgets/progress_circle.dart';

class ObjectiveCard extends StatelessWidget {
  final String objective;
  final double progress;

  const ObjectiveCard({
    Key? key,
    required this.objective,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final secondaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppDesignSystem.primaryPurple,
        AppDesignSystem.primaryBlue,
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space20),
      decoration: BoxDecoration(
        gradient: secondaryGradient,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
                child: const Icon(
                  Icons.emoji_objects_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDesignSystem.space12),
              Text(
                'Dagelijks doel',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space16),
          Text(
            objective,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppDesignSystem.space20),
          Row(
            children: [
              ProgressCircle(
                percentage: progress,
                size: 60,
                label: '',
              ),
              const SizedBox(width: AppDesignSystem.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voortgang deze week',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                    const SizedBox(height: AppDesignSystem.space4),
                    Text(
                      '${(progress * 100).toInt()}% voltooid',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
