import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system.dart';
import '../widgets/progress_circle.dart';
import '../providers/mood_provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_objective_provider.dart';
import '../widgets/challenge_card.dart';
import '../models/challenge.dart';
import '../widgets/weekly_insights_chart.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/mood_entry_screen.dart';
import '../screens/challenge_creation_screen.dart';

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
    final stats = ref.watch(moodStatsProvider);
    final challenges = ref
        .watch(allChallengesProvider)
        .where((c) => !c.isDone)
        .take(3)
        .toList();
    final userStreak = ref.watch(userStreakProvider);
    final screenTimeAsync = ref.watch(screenTimeProvider);
    final dailyObjectiveAsync = ref.watch(dailyObjectiveProvider);
    final weeklyProgressAsync = ref.watch(weeklyProgressProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
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
            _buildModernAppBar(context),
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
                          screenTimeAsync.when(
                            data: (screenTime) => _buildStatsGrid(
                                context, userStreak, screenTime, stats),
                            loading: () => _buildStatsGrid(
                              context,
                              userStreak,
                              const Duration(hours: 2, minutes: 30),
                              stats,
                            ),
                            error: (_, __) => _buildStatsGrid(
                                context, userStreak, Duration.zero, stats),
                          ),
                          const SizedBox(height: AppDesignSystem.space32),
                          dailyObjectiveAsync.when(
                            data: (objective) => weeklyProgressAsync.when(
                              data: (progress) => _buildModernObjective(
                                  context, objective, progress),
                              loading: () => _buildModernObjective(
                                  context, objective, 0.0),
                              error: (_, __) => _buildModernObjective(
                                  context, objective, 0.0),
                            ),
                            loading: () => _buildModernObjective(
                              context,
                              "Focus op bewust schermgebruik",
                              0.0,
                            ),
                            error: (_, __) => _buildModernObjective(
                              context,
                              "Focus op bewust schermgebruik",
                              0.0,
                            ),
                          ),
                          const SizedBox(height: AppDesignSystem.space32),
                          _buildModernMoodSection(context, ref, stats),
                          const SizedBox(height: AppDesignSystem.space32),
                          _buildModernChallenges(context, ref, challenges),
                          const SizedBox(height: AppDesignSystem.space32),
                          screenTimeAsync.when(
                            data: (screenTime) => _buildModernInsights(
                                context, ref, stats, screenTime),
                            loading: () => _buildModernInsights(
                              context,
                              ref,
                              stats,
                              const Duration(hours: 2, minutes: 30),
                            ),
                            error: (_, __) => _buildModernInsights(
                                context, ref, stats, Duration.zero),
                          ),
                          const SizedBox(height: AppDesignSystem.space32),
                          _buildQuoteOfTheDay(),
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
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppDesignSystem.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppDesignSystem.radiusXLarge),
              bottomRight: Radius.circular(AppDesignSystem.radiusXLarge),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.space20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welkom terug! 👋',
                        style: AppDesignSystem.heading2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppDesignSystem.space4),
                      Text(
                        _getGreeting(),
                        style: AppDesignSystem.body2.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppDesignSystem.space12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppDesignSystem.borderRadiusLarge,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
      BuildContext context, int streak, Duration screenTime, MoodStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppDesignSystem.space16,
      crossAxisSpacing: AppDesignSystem.space16,
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          title: 'Schermtijd vandaag',
          value: '${screenTime.inHours}u ${screenTime.inMinutes % 60}m',
          icon: Icons.timer_outlined,
          color: AppDesignSystem.info,
          subtitle: 'Vandaag',
        ),
        StatCard(
          title: 'Dagen streak',
          value: '$streak',
          icon: Icons.local_fire_department,
          color: AppDesignSystem.warning,
          subtitle: 'Dagen',
        ),
        StatCard(
          title: 'Gemiddelde stemming',
          value: '${(stats.averageMood / 5.0 * 100).round()}%',
          icon: Icons.sentiment_satisfied_alt,
          color: AppDesignSystem.success,
          subtitle: 'Deze week',
        ),
        StatCard(
          title: 'Actieve doelen',
          value:
              '${ref.watch(allChallengesProvider).where((c) => !c.isDone).length}',
          icon: Icons.flag_outlined,
          color: AppDesignSystem.primaryPurple,
          subtitle: 'Lopend',
        ),
      ],
    );
  }

  Widget _buildModernObjective(
      BuildContext context, String objective, double progress) {
    return ModernCard(
      hasGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppDesignSystem.borderRadiusSmall,
                ),
                child: const Icon(Icons.track_changes,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppDesignSystem.space12),
              Expanded(
                child: Text(
                  'Dagelijkse Focus',
                  style: AppDesignSystem.heading3.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space20),
          Text(
            objective,
            style: AppDesignSystem.body1.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppDesignSystem.space20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voortgang deze week',
                    style: AppDesignSystem.body2.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppDesignSystem.body2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDesignSystem.space8),
              ClipRRect(
                borderRadius: AppDesignSystem.borderRadiusSmall,
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernMoodSection(
      BuildContext context, WidgetRef ref, MoodStats stats) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDesignSystem.space8),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.success.withOpacity(0.1),
                        borderRadius: AppDesignSystem.borderRadiusSmall,
                      ),
                      child: Icon(
                        Icons.mood,
                        color: AppDesignSystem.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDesignSystem.space12),
                    Flexible(
                      child: Text(
                        'Stemming Tracker',
                        style: AppDesignSystem.heading3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDesignSystem.space8),
              ModernButton(
                text: 'Invoeren',
                isPrimary: false,
                icon: Icons.add,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodEntryScreen(),
                    ),
                  );
                  if (result == true) {
                    ref.refresh(moodStatsProvider);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space24),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: ProgressCircle(
                  percentage: stats.count == 0 ? 0.0 : stats.averageMood / 5.0,
                  size: 100,
                  label: stats.count == 0
                      ? 'Geen\ndata'
                      : '${(stats.averageMood / 5.0 * 100).round()}%',
                ),
              ),
              const SizedBox(width: AppDesignSystem.space24),
              Expanded(
                child: Column(
                  children: [
                    _buildMoodMetric('Vandaag', stats.todayMood ?? 0),
                    const SizedBox(height: AppDesignSystem.space12),
                    _buildMoodMetric('Deze week', stats.averageMood),
                    const SizedBox(height: AppDesignSystem.space12),
                    _buildMoodMetric('Vorige week', stats.lastWeekAverage),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodMetric(String label, double value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppDesignSystem.body2.copyWith(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppDesignSystem.space4),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: AppDesignSystem.borderRadiusSmall,
            child: LinearProgressIndicator(
              value: value / 5.0,
              backgroundColor: AppDesignSystem.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(_getMoodColor(value)),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: AppDesignSystem.space4),
        SizedBox(
          width: 30,
          child: Text(
            '${(value / 5.0 * 100).round()}%',
            style: AppDesignSystem.body2.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildModernChallenges(
      BuildContext context, WidgetRef ref, List<Challenge> challenges) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDesignSystem.space8),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.primaryPurple.withOpacity(0.1),
                        borderRadius: AppDesignSystem.borderRadiusSmall,
                      ),
                      child: Icon(
                        Icons.flag_outlined,
                        color: AppDesignSystem.primaryPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDesignSystem.space12),
                    Flexible(
                      child: Text(
                        'Actieve Uitdagingen',
                        style: AppDesignSystem.heading3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDesignSystem.space8),
              ModernButton(
                text: 'Nieuwe',
                isPrimary: false,
                icon: Icons.add,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChallengeCreationScreen(),
                    ),
                  );
                  if (result == true) {
                    ref.refresh(allChallengesProvider);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space20),
          if (challenges.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppDesignSystem.space32),
              decoration: BoxDecoration(
                color: AppDesignSystem.neutral50,
                borderRadius: AppDesignSystem.borderRadiusLarge,
                border: Border.all(color: AppDesignSystem.neutral200),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_flags,
                      size: 48,
                      color: AppDesignSystem.neutral400,
                    ),
                    const SizedBox(height: AppDesignSystem.space12),
                    Text(
                      'Geen actieve uitdagingen',
                      style: AppDesignSystem.body1.copyWith(
                        color: AppDesignSystem.neutral500,
                      ),
                    ),
                    const SizedBox(height: AppDesignSystem.space4),
                    Text(
                      'Maak je eerste uitdaging aan!',
                      style: AppDesignSystem.body2.copyWith(
                        color: AppDesignSystem.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...challenges.map((challenge) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDesignSystem.space12),
                  child: ChallengeCard(
                    challenge: challenge,
                    actionLabel: 'Voltooien',
                    onAction: () => ref
                        .read(challengeProvider(challenge.id).notifier)
                        .toggleDone(),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildModernInsights(
    BuildContext context,
    WidgetRef ref,
    MoodStats stats,
    Duration screenTime,
  ) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDesignSystem.space8),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.info.withOpacity(0.1),
                        borderRadius: AppDesignSystem.borderRadiusSmall,
                      ),
                      child: Icon(
                        Icons.insights,
                        color: AppDesignSystem.info,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDesignSystem.space12),
                    Flexible(
                      child: Text(
                        'Wekelijkse Inzichten',
                        style: AppDesignSystem.heading3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDesignSystem.space8),
              ModernButton(
                text: 'Details',
                isPrimary: false,
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space20),
          WeeklyInsightsChart(
            entries: stats.recentEntries,
            screenTime: screenTime,
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteOfTheDay() {
    final quote = _getMotivationalQuote();
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.warning.withOpacity(0.1),
                  borderRadius: AppDesignSystem.borderRadiusSmall,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppDesignSystem.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDesignSystem.space12),
              Text(
                'Inspiratie van de Dag',
                style: AppDesignSystem.heading3,
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space20),
          Container(
            padding: const EdgeInsets.all(AppDesignSystem.space20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppDesignSystem.warning.withOpacity(0.1),
                  AppDesignSystem.warning.withOpacity(0.05),
                ],
              ),
              borderRadius: AppDesignSystem.borderRadiusLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$quote"',
                  style: AppDesignSystem.body1.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppDesignSystem.neutral700,
                  ),
                ),
                const SizedBox(height: AppDesignSystem.space12),
                Text(
                  '— Social Balans',
                  style: AppDesignSystem.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppDesignSystem.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(double value) {
    if (value >= 4) return AppDesignSystem.success;
    if (value >= 3) return AppDesignSystem.info;
    if (value >= 2) return AppDesignSystem.warning;
    return AppDesignSystem.error;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Goedemorgen! Klaar voor een geweldige dag?';
    if (hour < 17) return 'Goedemiddag! Hoe gaat je dag?';
    return 'Goedenavond! Tijd om te reflecteren.';
  }

  String _getMotivationalQuote() {
    final quotes = [
      "Elke kleine stap naar balans telt.",
      "Bewust leven begint met bewuste keuzes.",
      "Je hebt vandaag de kracht om te groeien.",
      "Minder scherm, meer authentieke momenten.",
      "Rust is niet luiheid, het is wijsheid.",
      "Focus op wat echt waarde toevoegt.",
      "Kwaliteit boven kwantiteit, altijd.",
      "Je bent sterker dan je uitdagingen.",
      "Balans is de sleutel tot duurzaam geluk.",
      "Vandaag is een nieuwe kans om te bloeien.",
    ];
    quotes.shuffle();
    return quotes.first;
  }
}
