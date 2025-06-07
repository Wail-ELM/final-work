import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/mood_provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_objective_provider.dart';
import '../widgets/dashboard/index.dart';
import '../core/design_system.dart';
import '../widgets/progress_circle.dart';
import '../widgets/challenge_card.dart';
import '../models/challenge.dart';
import '../widgets/weekly_insights_chart.dart';
import '../screens/settings_screen.dart';
import '../screens/mood_entry_screen.dart';
import '../screens/suggestions.dart';
import '../screens/profile_screen.dart';

// Widgets modulaires
import '../widgets/dashboard/dashboard_app_bar.dart';
import '../widgets/dashboard/stats_grid.dart';
import '../widgets/dashboard/objective_card.dart';
import '../widgets/dashboard/mood_section.dart';
import '../widgets/dashboard/challenges_section.dart';
import '../widgets/dashboard/insights_section.dart';
import '../widgets/dashboard/quote_card.dart';

/// ModernDashboard est l'écran principal de l'application.
/// Il affiche un aperçu des statistiques, de l'humeur, des défis et des insights de l'utilisateur.
class ModernDashboard extends ConsumerStatefulWidget {
  const ModernDashboard({super.key});

  @override
  ConsumerState<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends ConsumerState<ModernDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des données
    final moodStats = ref.watch(moodStatsProvider);
    final challenges = ref
        .watch(allChallengesProvider)
        .where((c) => !c.isDone)
        .take(3)
        .toList();
    final userStreak = ref.watch(userStreakProvider);
    final screenTimeAsync = ref.watch(screenTimeProvider);
    final dailyObjectiveAsync = ref.watch(dailyObjectiveProvider);
    final weeklyProgressAsync = ref.watch(weeklyProgressProvider);

    // Convertir MoodStats en Map pour les widgets qui attendent Map<String, dynamic>
    final statsMap = <String, dynamic>{
      'averageMood': moodStats.averageMood,
      'todayMood': moodStats.todayMood,
      'lastWeekAverage': moodStats.lastWeekAverage,
      'totalEntries': moodStats.count,
      'recentEntries': moodStats.recentEntries,
    };

    return RefreshIndicator(
      onRefresh: () async {
        // Actualiser toutes les données
        ref.refresh(moodStatsProvider);
        ref.refresh(allChallengesProvider);
        ref.refresh(userStreakProvider);
        ref.refresh(screenTimeProvider);
        ref.refresh(dailyObjectiveProvider);
        ref.refresh(weeklyProgressProvider);
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar personnalisée
          const DashboardAppBar(),

          // Contenu principal
          SliverPadding(
            padding: const EdgeInsets.all(AppDesignSystem.space20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Grille de statistiques
                        screenTimeAsync.when(
                          data: (screenTime) => StatsGrid(
                            userStreak: userStreak,
                            screenTime: screenTime?.inMinutes,
                            stats: statsMap,
                          ),
                          loading: () => StatsGrid(
                            userStreak: userStreak,
                            screenTime: null,
                            stats: statsMap,
                          ),
                          error: (_, __) => StatsGrid(
                            userStreak: userStreak,
                            screenTime: null,
                            stats: statsMap,
                          ),
                        ),

                        const SizedBox(height: AppDesignSystem.space32),

                        // Objectif quotidien
                        dailyObjectiveAsync.when(
                          data: (objective) => weeklyProgressAsync.when(
                            data: (progress) => ObjectiveCard(
                              objective: objective,
                              progress: progress,
                            ),
                            loading: () => ObjectiveCard(
                              objective: objective,
                              progress: 0.0,
                            ),
                            error: (_, __) => ObjectiveCard(
                              objective: objective,
                              progress: 0.0,
                            ),
                          ),
                          loading: () => const ObjectiveCard(
                            objective: "Focus op bewust schermgebruik",
                            progress: 0.0,
                          ),
                          error: (_, __) => const ObjectiveCard(
                            objective: "Focus op bewust schermgebruik",
                            progress: 0.0,
                          ),
                        ),

                        const SizedBox(height: AppDesignSystem.space32),

                        // Section Humeur
                        MoodSection(stats: statsMap),

                        const SizedBox(height: AppDesignSystem.space32),

                        // Section Défis
                        ChallengesSection(challenges: challenges),

                        const SizedBox(height: AppDesignSystem.space32),

                        // Section Insights
                        InsightsSection(stats: statsMap),

                        const SizedBox(height: AppDesignSystem.space32),

                        // Citation du jour
                        const QuoteCard(),

                        const SizedBox(height: AppDesignSystem.space64),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
